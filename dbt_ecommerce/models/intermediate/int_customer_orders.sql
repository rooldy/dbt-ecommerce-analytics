{{
    config(
        materialized='view',
        tags=['intermediate', 'customers']
    )
}}

with orders_enriched as (
    select * from {{ ref('int_orders_enriched') }}
),

-- Aggregate metrics by customer
customer_metrics as (
    select
        customer_id,
        customer_unique_id,
        
        -- Take first occurrence for location (assuming it doesn't change)
        max(customer_city) as customer_city,
        max(customer_state) as customer_state,
        max(customer_zip_code) as customer_zip_code,
        
        -- Order counts
        count(*) as total_orders,
        sum(case when is_delivered = 1 then 1 else 0 end) as delivered_orders,
        sum(case when is_canceled = 1 then 1 else 0 end) as canceled_orders,
        
        -- Financial metrics
        sum(total_payment_value) as lifetime_value,
        avg(total_payment_value) as avg_order_value,
        min(total_payment_value) as min_order_value,
        max(total_payment_value) as max_order_value,
        
        -- Delivery performance
        avg(case when is_delivered = 1 then actual_delivery_days end) as avg_delivery_days,
        sum(case when is_on_time = 1 then 1 else 0 end) as on_time_orders,
        sum(case when is_delivered = 1 then 1 else 0 end) as total_delivered,
        
        -- Calculate on-time rate
        case 
            when sum(case when is_delivered = 1 then 1 else 0 end) > 0
            then (sum(case when is_on_time = 1 then 1 else 0 end)::float / 
                  sum(case when is_delivered = 1 then 1 else 0 end)) * 100
            else null
        end as on_time_delivery_rate,
        
        -- Payment behavior
        avg(payment_methods_count) as avg_payment_methods,
        avg(max_installments) as avg_installments,
        sum(has_credit_card) as credit_card_orders,
        sum(has_boleto) as boleto_orders,
        
        -- Temporal metrics
        min(order_purchase_timestamp) as first_order_date,
        max(order_purchase_timestamp) as last_order_date,
        datediff(day, min(order_purchase_timestamp), max(order_purchase_timestamp)) as customer_lifespan_days,
        
        -- Recency
        datediff(day, max(order_purchase_timestamp), current_timestamp()) as days_since_last_order,
        
        -- Order frequency (orders per month)
        case 
            when datediff(day, min(order_purchase_timestamp), max(order_purchase_timestamp)) > 30
            then count(*)::float / 
                 (datediff(day, min(order_purchase_timestamp), max(order_purchase_timestamp))::float / 30)
            else count(*)::float
        end as orders_per_month
        
    from orders_enriched
    group by customer_id, customer_unique_id
),

-- Add customer segmentation
segmented as (
    select
        *,
        
        -- RFM-like segmentation based on recency, frequency, monetary
        case 
            when days_since_last_order <= 90 then 'Active'
            when days_since_last_order <= 180 then 'At Risk'
            when days_since_last_order <= 365 then 'Dormant'
            else 'Lost'
        end as customer_status,
        
        case 
            when total_orders >= 3 then 'Repeat'
            when total_orders = 2 then 'Second-time'
            else 'One-time'
        end as customer_frequency_segment,
        
        case 
            when lifetime_value >= 1000 then 'High Value'
            when lifetime_value >= 300 then 'Medium Value'
            else 'Low Value'
        end as customer_value_segment,
        
        -- Overall customer tier
        case 
            when lifetime_value >= 1000 and total_orders >= 3 then 'VIP'
            when lifetime_value >= 500 and total_orders >= 2 then 'Gold'
            when lifetime_value >= 200 or total_orders >= 2 then 'Silver'
            else 'Bronze'
        end as customer_tier
        
    from customer_metrics
)

select * from segmented