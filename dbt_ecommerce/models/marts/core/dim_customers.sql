{{
    config(
        materialized='table',
        tags=['marts', 'core', 'dimensions']
    )
}}

with customer_orders as (
    select * from {{ ref('int_customer_orders') }}
),

final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
        
        -- Natural key
        customer_id,
        customer_unique_id,
        
        -- Location attributes
        customer_city,
        customer_state,
        customer_zip_code,
        
        -- Customer metrics (SCD Type 1 - always current values)
        total_orders,
        delivered_orders,
        canceled_orders,
        
        -- Financial metrics
        lifetime_value,
        avg_order_value,
        min_order_value,
        max_order_value,
        
        -- Delivery performance
        avg_delivery_days,
        on_time_delivery_rate,
        
        -- Payment behavior
        avg_payment_methods,
        avg_installments,
        credit_card_orders,
        boleto_orders,
        
        -- Temporal metrics
        first_order_date,
        last_order_date,
        customer_lifespan_days,
        days_since_last_order,
        orders_per_month,
        
        -- Segmentation (RFM)
        customer_status,
        customer_frequency_segment,
        customer_value_segment,
        customer_tier,
        
        -- Derived flags
        case when total_orders = 1 then 1 else 0 end as is_one_time_customer,
        case when total_orders >= 3 then 1 else 0 end as is_repeat_customer,
        case when customer_tier = 'VIP' then 1 else 0 end as is_vip,
        case when days_since_last_order <= 90 then 1 else 0 end as is_active,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from customer_orders
)

select * from final