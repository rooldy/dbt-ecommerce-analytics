{{
    config(
        materialized='table',
        tags=['marts', 'analytics', 'customers', 'cohorts']
    )
}}

with cohorts as (
    select
        customer_id,
        customer_unique_id,
        date_trunc('month', first_order_date) as cohort_month,
        first_order_date
    from {{ ref('dim_customers') }}
),

orders_with_cohort as (
    select
        c.cohort_month,
        c.customer_id,
        date_trunc('month', f.order_purchase_timestamp) as order_month,
        datediff('month', c.cohort_month, date_trunc('month', f.order_purchase_timestamp)) as months_since_cohort,
        f.total_payment_value,
        f.order_id
    from {{ ref('fct_orders') }} f
    join cohorts c on f.customer_id = c.customer_id
    where f.is_delivered = 1
),

cohort_metrics as (
    select
        cohort_month,
        months_since_cohort,
        
        -- Customer metrics
        count(distinct customer_id) as active_customers,
        count(distinct order_id) as total_orders,
        
        -- Revenue metrics
        sum(total_payment_value) as cohort_revenue,
        avg(total_payment_value) as avg_order_value,
        
        -- Per-customer metrics
        round(sum(total_payment_value) / nullif(count(distinct customer_id), 0), 2) as revenue_per_customer,
        round(count(distinct order_id)::float / nullif(count(distinct customer_id), 0), 2) as orders_per_customer
        
    from orders_with_cohort
    group by 1, 2
),

cohort_sizes as (
    select
        cohort_month,
        count(distinct customer_id) as cohort_size,
        sum(case when datediff('month', first_order_date, current_timestamp()) >= 12 then 1 else 0 end) as mature_customers
    from cohorts
    group by 1
),

retention_rates as (
    select
        m.cohort_month,
        m.months_since_cohort,
        s.cohort_size,
        m.active_customers,
        m.total_orders,
        m.cohort_revenue,
        m.avg_order_value,
        m.revenue_per_customer,
        m.orders_per_customer,
        
        -- Retention metrics
        round(m.active_customers * 100.0 / nullif(s.cohort_size, 0), 2) as retention_rate,
        
        -- Cumulative metrics
        sum(m.active_customers) over (
            partition by m.cohort_month 
            order by m.months_since_cohort
        ) as cumulative_active_customers,
        
        sum(m.cohort_revenue) over (
            partition by m.cohort_month 
            order by m.months_since_cohort
        ) as cumulative_revenue,
        
        sum(m.total_orders) over (
            partition by m.cohort_month 
            order by m.months_since_cohort
        ) as cumulative_orders
        
    from cohort_metrics m
    join cohort_sizes s on m.cohort_month = s.cohort_month
),

with_benchmarks as (
    select
        *,
        
        -- Cumulative per-customer metrics
        round(cumulative_revenue / nullif(cohort_size, 0), 2) as cumulative_revenue_per_customer,
        round(cumulative_orders::float / nullif(cohort_size, 0), 2) as cumulative_orders_per_customer,
        
        -- Month-over-month change
        lag(retention_rate) over (
            partition by cohort_month 
            order by months_since_cohort
        ) as prev_month_retention_rate,
        
        -- Cohort health indicators
        case 
            when months_since_cohort = 0 then 'New Cohort'
            when months_since_cohort <= 3 and retention_rate >= 40 then 'Healthy'
            when months_since_cohort <= 3 and retention_rate < 40 then 'At Risk'
            when months_since_cohort <= 6 and retention_rate >= 25 then 'Stable'
            when months_since_cohort <= 6 and retention_rate < 25 then 'Weak'
            when months_since_cohort <= 12 and retention_rate >= 15 then 'Mature - Good'
            when months_since_cohort <= 12 and retention_rate < 15 then 'Mature - Poor'
            when retention_rate >= 10 then 'Long-term - Loyal'
            else 'Long-term - Churned'
        end as cohort_health,
        
        -- Ranking within month
        row_number() over (
            partition by months_since_cohort 
            order by retention_rate desc
        ) as rank_in_month
        
    from retention_rates
),

final as (
    select
        *,
        
        -- Retention drop
        retention_rate - coalesce(prev_month_retention_rate, 100) as retention_drop,
        
        -- LTV trajectory
        case 
            when months_since_cohort >= 6 then
                round(cumulative_revenue_per_customer * (24.0 / months_since_cohort), 2)
            else null
        end as projected_24m_ltv,
        
        -- Cohort labels
        to_char(cohort_month, 'YYYY-MM') as cohort_label,
        extract(year from cohort_month) as cohort_year,
        extract(month from cohort_month) as cohort_month_num,
        
        -- Age description
        case 
            when months_since_cohort = 0 then 'M0 - Acquisition'
            when months_since_cohort <= 3 then 'M1-3 - Early Engagement'
            when months_since_cohort <= 6 then 'M4-6 - Growth'
            when months_since_cohort <= 12 then 'M7-12 - Maturity'
            else 'M13+ - Long-term'
        end as cohort_age_group
        
    from with_benchmarks
)

select * from final