{{
    config(
        materialized='table',
        tags=['marts', 'core', 'facts']
    )
}}

with orders_enriched as (
    select * from {{ ref('int_orders_enriched') }}
),

order_items as (
    select
        order_id,
        count(*) as items_count,
        sum(item_price) as items_total_price,
        sum(item_freight_value) as items_total_freight,
        sum(item_total_value) as items_total_value,
        avg(item_price) as avg_item_price
    from {{ ref('int_order_items_enriched') }}
    group by order_id
),

final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['o.order_id']) }} as order_key,
        
        -- Natural key
        o.order_id,
        
        -- Foreign keys to dimensions
        {{ dbt_utils.generate_surrogate_key(['o.customer_id']) }} as customer_key,
        o.customer_id,
        
        -- Date key (YYYYMMDD format for dim_date join)
        to_number(to_char(o.order_purchase_timestamp, 'YYYYMMDD')) as order_date_key,
        
        -- Order attributes
        o.order_status,
        
        -- Timestamps
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        
        -- Payment metrics
        o.total_payment_value,
        o.payment_methods_count,
        o.max_installments,
        
        -- Payment method flags
        o.has_credit_card,
        o.has_boleto,
        o.has_voucher,
        o.has_debit_card,
        
        -- Items metrics (from order_items)
        coalesce(i.items_count, 0) as items_count,
        coalesce(i.items_total_price, 0) as items_total_price,
        coalesce(i.items_total_freight, 0) as items_total_freight,
        coalesce(i.items_total_value, 0) as items_total_value,
        coalesce(i.avg_item_price, 0) as avg_item_price,
        
        -- Delivery metrics (in days)
        o.actual_delivery_days,
        o.estimated_delivery_days,
        o.days_to_carrier,
        o.days_carrier_to_customer,
        o.delivery_vs_estimated_days,
        
        -- Flags
        o.is_on_time,
        o.is_delivered,
        o.is_canceled,
        
        -- Time dimensions (for slicing without dim_date)
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.order_day_of_week,
        o.order_hour,
        
        -- Calculated metrics
        case 
            when o.is_delivered = 1 and o.is_on_time = 1 then 'Delivered On-Time'
            when o.is_delivered = 1 and o.is_on_time = 0 then 'Delivered Late'
            when o.is_canceled = 1 then 'Canceled'
            else 'In Progress'
        end as delivery_status_category,
        
        -- Revenue categorization
        case 
            when o.total_payment_value >= 500 then 'High Value'
            when o.total_payment_value >= 100 then 'Medium Value'
            else 'Low Value'
        end as order_value_category,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from orders_enriched o
    left join order_items i on o.order_id = i.order_id
)

select * from final