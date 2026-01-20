{{
    config(
        materialized='table',
        tags=['marts', 'analytics', 'customers']
    )
}}

with customer_base as (
    select
        c.customer_id,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        
        -- Cohort
        date_trunc('month', c.first_order_date) as cohort_month,
        c.first_order_date,
        c.last_order_date,
        
        -- RFM metrics
        c.total_orders as frequency,
        c.avg_order_value as monetary,
        c.days_since_last_order as recency,
        
        -- Financial metrics
        c.lifetime_value as historical_ltv,
        c.avg_order_value,
        c.min_order_value,
        c.max_order_value,
        
        -- Engagement metrics
        c.customer_lifespan_days,
        c.orders_per_month,
        c.on_time_delivery_rate,
        
        -- Segmentation
        c.customer_tier,
        c.customer_status,
        c.customer_frequency_segment,
        c.customer_value_segment,
        
        -- Flags
        c.is_vip,
        c.is_active,
        c.is_repeat_customer
        
    from {{ ref('dim_customers') }} c
),

clv_predictions as (
    select
        *,
        
        -- Predicted CLV (12 months) - Simplified model
        case 
            when customer_status = 'Active' and is_repeat_customer = 1 then
                -- Active repeaters: extrapolate current behavior
                avg_order_value * (orders_per_month * 12)
            
            when customer_status = 'Active' and is_repeat_customer = 0 then
                -- Active one-timers: conservative estimate
                avg_order_value * 2
            
            when customer_status = 'At Risk' then
                -- At risk: 50% probability of return
                avg_order_value * (orders_per_month * 6)
            
            when customer_status = 'Dormant' then
                -- Dormant: 25% probability
                avg_order_value * 1
            
            else
                -- Lost: minimal expectation
                0
        end as predicted_clv_12m,
        
        -- Customer lifetime in months
        round(customer_lifespan_days / 30.0, 1) as lifetime_months,
        
        -- Average time between orders
        case 
            when frequency > 1 then
                round(customer_lifespan_days::float / (frequency - 1), 1)
            else null
        end as avg_days_between_orders,
        
        -- Customer age in months
        round(datediff('day', first_order_date, current_timestamp()) / 30.0, 1) as customer_age_months,
        
        -- Engagement score (0-100)
        least(100, 
            (case when customer_status = 'Active' then 40 else 0 end) +
            (case when is_repeat_customer = 1 then 30 else 0 end) +
            (case when on_time_delivery_rate >= 90 then 20 else on_time_delivery_rate / 4.5 end) +
            (case when orders_per_month >= 1 then 10 else orders_per_month * 10 end)
        ) as engagement_score
        
    from customer_base
),

value_tiers as (
    select
        *,
        
        -- CLV tier
        case 
            when predicted_clv_12m >= 2000 then 'Very High'
            when predicted_clv_12m >= 1000 then 'High'
            when predicted_clv_12m >= 500 then 'Medium'
            when predicted_clv_12m >= 100 then 'Low'
            else 'Very Low'
        end as clv_tier,
        
        -- Churn risk
        case 
            when customer_status = 'Lost' then 'Very High'
            when customer_status = 'Dormant' then 'High'
            when customer_status = 'At Risk' then 'Medium'
            when customer_status = 'Active' and is_repeat_customer = 0 then 'Low-Medium'
            else 'Low'
        end as churn_risk,
        
        -- Marketing priority
        case 
            when customer_tier = 'VIP' and customer_status in ('At Risk', 'Dormant') then 'URGENT - Retain VIP'
            when customer_tier in ('Gold', 'Silver') and customer_status = 'At Risk' then 'HIGH - Win Back'
            when customer_tier = 'Bronze' and customer_status = 'Active' and is_repeat_customer = 0 then 'MEDIUM - Convert to Repeat'
            when customer_status = 'Active' and predicted_clv_12m >= 1000 then 'HIGH - Nurture High Value'
            else 'LOW - Monitor'
        end as marketing_priority
        
    from clv_predictions
)

select * from value_tiers