{{
    config(
        materialized='view',
        tags=['intermediate', 'orders']
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

-- Aggregate payments by order
payments_agg as (
    select
        order_id,
        count(*) as payment_methods_count,
        sum(payment_value) as total_payment_value,
        max(payment_installments) as max_installments,
        
        -- Payment type flags
        max(case when payment_type = 'credit_card' then 1 else 0 end) as has_credit_card,
        max(case when payment_type = 'boleto' then 1 else 0 end) as has_boleto,
        max(case when payment_type = 'voucher' then 1 else 0 end) as has_voucher,
        max(case when payment_type = 'debit_card' then 1 else 0 end) as has_debit_card
        
    from payments
    group by order_id
),

-- Join all together
enriched as (
    select
        -- Order identifiers
        o.order_id,
        o.customer_id,
        
        -- Customer information
        c.customer_unique_id,
        c.city as customer_city,
        c.state as customer_state,
        c.zip_code as customer_zip_code,
        
        -- Order status and dates
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        
        -- Payment information
        coalesce(p.total_payment_value, 0) as total_payment_value,
        coalesce(p.payment_methods_count, 0) as payment_methods_count,
        coalesce(p.max_installments, 0) as max_installments,
        coalesce(p.has_credit_card, 0) as has_credit_card,
        coalesce(p.has_boleto, 0) as has_boleto,
        coalesce(p.has_voucher, 0) as has_voucher,
        coalesce(p.has_debit_card, 0) as has_debit_card,
        
        -- Calculated delivery metrics (in days)
        datediff(day, o.order_purchase_timestamp, o.order_delivered_customer_date) as actual_delivery_days,
        datediff(day, o.order_purchase_timestamp, o.order_estimated_delivery_date) as estimated_delivery_days,
        datediff(day, o.order_approved_at, o.order_delivered_carrier_date) as days_to_carrier,
        datediff(day, o.order_delivered_carrier_date, o.order_delivered_customer_date) as days_carrier_to_customer,
        
        -- Delivery performance flags
        case 
            when o.order_delivered_customer_date is not null 
            then datediff(day, o.order_delivered_customer_date, o.order_estimated_delivery_date)
            else null
        end as delivery_vs_estimated_days,
        
        case 
            when o.order_delivered_customer_date <= o.order_estimated_delivery_date then 1
            when o.order_delivered_customer_date is null then null
            else 0
        end as is_on_time,
        
        case 
            when o.order_status = 'delivered' then 1
            else 0
        end as is_delivered,
        
        case 
            when o.order_status = 'canceled' then 1
            else 0
        end as is_canceled,
        
        -- Time metrics
        datediff(day, o.order_purchase_timestamp, current_timestamp()) as days_since_purchase,
        extract(year from o.order_purchase_timestamp) as order_year,
        extract(month from o.order_purchase_timestamp) as order_month,
        extract(quarter from o.order_purchase_timestamp) as order_quarter,
        extract(dayofweek from o.order_purchase_timestamp) as order_day_of_week,
        extract(hour from o.order_purchase_timestamp) as order_hour
        
    from orders o
    left join customers c on o.customer_id = c.customer_id
    left join payments_agg p on o.order_id = p.order_id
)

select * from enriched