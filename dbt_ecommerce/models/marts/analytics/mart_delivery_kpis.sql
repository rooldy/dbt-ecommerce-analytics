{{
    config(
        materialized='table',
        tags=['marts', 'analytics', 'operations']
    )
}}

with delivery_base as (
    select
        -- Geography
        c.customer_state,
        c.customer_city,
        s.region as seller_region,
        s.seller_state,
        
        -- Order details
        f.order_id,
        f.order_purchase_timestamp,
        f.order_delivered_customer_date,
        f.order_estimated_delivery_date,
        
        -- Delivery metrics
        f.actual_delivery_days,
        f.estimated_delivery_days,
        f.days_to_carrier,
        f.days_carrier_to_customer,
        f.delivery_vs_estimated_days,
        
        -- Flags
        f.is_on_time,
        f.is_delivered,
        
        -- Value
        f.total_payment_value
        
    from {{ ref('fct_orders') }} f
    join {{ ref('dim_customers') }} c on f.customer_key = c.customer_key
    join {{ ref('fct_order_items') }} oi on f.order_key = oi.order_key
    join {{ ref('dim_sellers') }} s on oi.seller_key = s.seller_key
    where f.is_delivered = 1  -- Only completed deliveries
),

aggregated_kpis as (
    select
        customer_state,
        seller_region,
        
        -- Volume metrics
        count(*) as total_deliveries,
        count(distinct order_id) as unique_orders,
        sum(total_payment_value) as total_value,
        
        -- Delivery time metrics
        avg(actual_delivery_days) as avg_delivery_days,
        min(actual_delivery_days) as min_delivery_days,
        max(actual_delivery_days) as max_delivery_days,
        percentile_cont(0.5) within group (order by actual_delivery_days) as median_delivery_days,
        percentile_cont(0.9) within group (order by actual_delivery_days) as p90_delivery_days,
        
        -- Estimated vs actual
        avg(estimated_delivery_days) as avg_estimated_days,
        avg(delivery_vs_estimated_days) as avg_delay_days,
        
        -- Breakdown metrics
        avg(days_to_carrier) as avg_days_to_carrier,
        avg(days_carrier_to_customer) as avg_days_carrier_to_customer,
        
        -- Performance metrics
        sum(case when is_on_time = 1 then 1 else 0 end) as on_time_deliveries,
        sum(case when delivery_vs_estimated_days < 0 then 1 else 0 end) as late_deliveries,
        sum(case when delivery_vs_estimated_days > 5 then 1 else 0 end) as early_deliveries,
        
        -- SLA metrics (assuming 5 days and 10 days SLAs)
        sum(case when actual_delivery_days <= 5 then 1 else 0 end) as sla_5day_count,
        sum(case when actual_delivery_days <= 10 then 1 else 0 end) as sla_10day_count,
        
        -- Value metrics
        avg(total_payment_value) as avg_order_value
        
    from delivery_base
    group by 1, 2
),

with_calculations as (
    select
        *,
        
        -- Performance rates
        round(on_time_deliveries * 100.0 / nullif(total_deliveries, 0), 2) as on_time_rate,
        round(late_deliveries * 100.0 / nullif(total_deliveries, 0), 2) as late_delivery_rate,
        round(early_deliveries * 100.0 / nullif(total_deliveries, 0), 2) as early_delivery_rate,
        
        -- SLA compliance rates
        round(sla_5day_count * 100.0 / nullif(total_deliveries, 0), 2) as sla_5day_compliance,
        round(sla_10day_count * 100.0 / nullif(total_deliveries, 0), 2) as sla_10day_compliance,
        
        -- Reliability score (0-100)
        least(100,
            -- On-time component (60 points)
            (on_time_deliveries * 60.0 / nullif(total_deliveries, 0)) +
            -- Consistency component (40 points) - penalize high variance
            greatest(0, 40 - abs(avg_delay_days) * 2)
        ) as reliability_score,
        
        -- Efficiency score
        round(
            (avg_estimated_days / nullif(avg_delivery_days, 0)) * 100, 2
        ) as delivery_efficiency_pct
        
    from aggregated_kpis
),

ranked as (
    select
        *,
        
        -- Rankings
        row_number() over (order by on_time_rate desc) as rank_on_time_rate,
        row_number() over (order by avg_delivery_days asc) as rank_speed,
        row_number() over (order by reliability_score desc) as rank_reliability,
        row_number() over (order by total_deliveries desc) as rank_volume,
        
        -- Performance tier
        case 
            when on_time_rate >= 95 and avg_delivery_days <= 10 then 'Excellent'
            when on_time_rate >= 90 and avg_delivery_days <= 15 then 'Good'
            when on_time_rate >= 80 and avg_delivery_days <= 20 then 'Fair'
            else 'Needs Improvement'
        end as performance_tier,
        
        -- Issue flags
        case 
            when late_delivery_rate > 20 then 'High Late Delivery'
            when avg_delivery_days > 20 then 'Slow Delivery'
            when p90_delivery_days > 30 then 'Inconsistent Delivery'
            when avg_delay_days < -3 then 'Chronic Delays'
            else 'No Major Issues'
        end as primary_issue,
        
        -- Recommendations
        case 
            when total_deliveries < 50 then 'Insufficient Volume for Analysis'
            when late_delivery_rate > 25 and total_deliveries >= 100 then 'URGENT: Investigate Route'
            when on_time_rate < 80 then 'Improve Logistics Planning'
            when avg_days_to_carrier > 3 then 'Seller Processing Slow'
            when avg_days_carrier_to_customer > 10 then 'Carrier Performance Issue'
            when performance_tier = 'Excellent' then 'Maintain Standards'
            else 'Monitor Performance'
        end as recommendation
        
    from with_calculations
)

select * from ranked