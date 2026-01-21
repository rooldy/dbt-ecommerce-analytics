{{
    config(
        materialized='incremental',
        unique_key='date_key',
        on_schema_change='fail',
        tags=['marts', 'analytics', 'sales']
    )
}}

with daily_orders as (
    select
        d.date_key,
        d.full_date,
        d.year,
        d.year_name,
        d.quarter,
        d.quarter_name,
        d.year_quarter,
        d.month,
        d.month_name,
        d.year_month,
        d.day_of_week,
        d.day_name,
        d.is_weekend,
        d.is_holiday,
        
        -- Order metrics
        count(distinct f.order_id) as orders,
        count(distinct f.customer_id) as unique_customers,
        sum(f.items_count) as items_sold,
        
        -- Revenue metrics
        sum(f.items_total_price) as revenue,
        avg(f.total_payment_value) as avg_order_value,
        min(f.total_payment_value) as min_order_value,
        max(f.total_payment_value) as max_order_value,
        
        -- Payment methods
        sum(f.payment_methods_count) as total_payment_methods,
        avg(f.payment_methods_count) as avg_payment_methods,
        sum(f.has_credit_card) as credit_card_orders,
        sum(f.has_boleto) as boleto_orders,
        sum(f.has_voucher) as voucher_orders,
        
        -- Delivery metrics
        avg(f.actual_delivery_days) as avg_delivery_days,
        avg(f.estimated_delivery_days) as avg_estimated_days,
        sum(case when f.is_on_time = 1 then 1 else 0 end) as on_time_deliveries,
        sum(case when f.is_delivered = 1 then 1 else 0 end) as total_deliveries,
        
        -- Cancellations
        sum(case when f.is_canceled = 1 then 1 else 0 end) as canceled_orders
        
    from {{ ref('fct_orders') }} f
    join {{ ref('dim_date') }} d on f.order_date_key = d.date_key
    where f.items_count > 0 
    
    {% if is_incremental() %}
        -- Only process new dates
        where d.full_date > (select max(full_date) from {{ this }})
    {% endif %}
    
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
),

with_calculations as (
    select
        *,
        
        -- Calculated rates
        round(on_time_deliveries * 100.0 / nullif(total_deliveries, 0), 2) as on_time_rate,
        round(canceled_orders * 100.0 / nullif(orders, 0), 2) as cancellation_rate,
        round(credit_card_orders * 100.0 / nullif(orders, 0), 2) as credit_card_pct,
        round(boleto_orders * 100.0 / nullif(orders, 0), 2) as boleto_pct,
        
        -- Customer metrics
        round(revenue / nullif(unique_customers, 0), 2) as revenue_per_customer,
        round(orders::float / nullif(unique_customers, 0), 2) as orders_per_customer,
        
        -- Moving averages (7-day)
        avg(revenue) over (
            order by date_key 
            rows between 6 preceding and current row
        ) as revenue_7d_ma,
        
        avg(orders) over (
            order by date_key 
            rows between 6 preceding and current row
        ) as orders_7d_ma,
        
        -- YoY comparison helpers
        lag(revenue, 365) over (order by date_key) as revenue_same_day_last_year,
        lag(orders, 365) over (order by date_key) as orders_same_day_last_year
        
    from daily_orders
)

select * from with_calculations