{{
    config(
        materialized='table',
        tags=['marts', 'analytics', 'products', 'sales']
    )
}}

with category_sales as (
    select
        p.category_name_en,
        p.category_name_pt,
        d.year,
        d.quarter,
        d.quarter_name,
        d.year_quarter,
        d.month,
        d.month_name,
        d.year_month,
        
        -- Volume metrics
        count(distinct f.order_id) as orders,
        count(*) as units_sold,
        count(distinct f.customer_id) as unique_customers,
        
        -- Revenue metrics
        sum(f.item_price) as product_revenue,
        sum(f.item_freight_value) as freight_revenue,
        sum(f.item_total_value) as total_revenue,
        avg(f.item_price) as avg_item_price,
        
        -- Freight metrics
        avg(f.freight_percentage) as avg_freight_pct,
        
        -- Product characteristics
        avg(p.weight_g) as avg_weight_g,
        avg(p.volume_cm3) as avg_volume_cm3
        
    from {{ ref('fct_order_items') }} f
    join {{ ref('dim_products') }} p on f.product_key = p.product_key
    join {{ ref('dim_date') }} d on f.order_date_key = d.date_key
    group by 1,2,3,4,5,6,7,8,9
),

with_calculations as (
    select
        *,
        
        -- Per-unit metrics
        round(product_revenue / nullif(units_sold, 0), 2) as revenue_per_unit,
        round(total_revenue / nullif(orders, 0), 2) as revenue_per_order,
        round(units_sold::float / nullif(orders, 0), 2) as units_per_order,
        
        -- Freight cost ratio
        round(freight_revenue / nullif(product_revenue, 0) * 100, 2) as freight_cost_ratio,
        
        -- Customer metrics
        round(total_revenue / nullif(unique_customers, 0), 2) as revenue_per_customer,
        round(orders::float / nullif(unique_customers, 0), 2) as orders_per_customer
        
    from category_sales
),

-- Calculate total revenue per category (for overall ranking)
category_totals as (
    select
        category_name_en,
        sum(total_revenue) as total_category_revenue
    from with_calculations
    group by 1
),

with_period_comparisons as (
    select
        c.*,
        ct.total_category_revenue,
        
        -- Previous period comparisons
        lag(c.total_revenue) over (
            partition by c.category_name_en 
            order by c.year, c.month
        ) as prev_month_revenue,
        
        lag(c.units_sold) over (
            partition by c.category_name_en 
            order by c.year, c.month
        ) as prev_month_units,
        
        -- Year-over-year
        lag(c.total_revenue, 12) over (
            partition by c.category_name_en 
            order by c.year, c.month
        ) as same_month_last_year_revenue,
        
        -- Moving averages
        avg(c.total_revenue) over (
            partition by c.category_name_en 
            order by c.year, c.month 
            rows between 2 preceding and current row
        ) as revenue_3m_ma,
        
        avg(c.units_sold) over (
            partition by c.category_name_en 
            order by c.year, c.month 
            rows between 2 preceding and current row
        ) as units_3m_ma
        
    from with_calculations c
    join category_totals ct on c.category_name_en = ct.category_name_en
),

period_totals as (
    select
        year,
        month,
        sum(total_revenue) as period_total_revenue,
        sum(units_sold) as period_total_units
    from with_calculations
    group by 1, 2
),

with_growth_metrics as (
    select
        c.*,
        pt.period_total_revenue,
        pt.period_total_units,
        
        -- Growth rates
        round(
            (c.total_revenue - c.prev_month_revenue) * 100.0 / nullif(c.prev_month_revenue, 0), 2
        ) as mom_revenue_growth,
        
        round(
            (c.total_revenue - c.same_month_last_year_revenue) * 100.0 / nullif(c.same_month_last_year_revenue, 0), 2
        ) as yoy_revenue_growth,
        
        round(
            (c.units_sold - c.prev_month_units) * 100.0 / nullif(c.prev_month_units, 0), 2
        ) as mom_units_growth,
        
        -- Share of total (by period)
        round(
            c.total_revenue * 100.0 / nullif(pt.period_total_revenue, 0), 2
        ) as share_of_monthly_revenue,
        
        round(
            c.units_sold * 100.0 / nullif(pt.period_total_units, 0), 2
        ) as share_of_monthly_units
        
    from with_period_comparisons c
    join period_totals pt on c.year = pt.year and c.month = pt.month
),

ranked as (
    select
        *,
        
        -- Rankings by period
        row_number() over (
            partition by year, month 
            order by total_revenue desc
        ) as rank_in_month_revenue,
        
        row_number() over (
            partition by year, month 
            order by units_sold desc
        ) as rank_in_month_units,
        
        row_number() over (
            partition by year, quarter 
            order by total_revenue desc
        ) as rank_in_quarter_revenue,
        
        -- Overall ranking (using pre-calculated total)
        dense_rank() over (
            order by total_category_revenue desc
        ) as rank_overall_revenue,
        
        -- Performance tier
        case 
            when share_of_monthly_revenue >= 10 then 'Top Tier'
            when share_of_monthly_revenue >= 5 then 'High Performer'
            when share_of_monthly_revenue >= 2 then 'Mid Performer'
            else 'Low Performer'
        end as performance_tier,
        
        -- Growth classification
        case 
            when mom_revenue_growth >= 20 then 'High Growth'
            when mom_revenue_growth >= 5 then 'Growing'
            when mom_revenue_growth >= -5 then 'Stable'
            when mom_revenue_growth >= -20 then 'Declining'
            else 'Sharp Decline'
        end as growth_status,
        
        -- Strategic classification
        case 
            when share_of_monthly_revenue >= 10 and mom_revenue_growth >= 5 then 'Star - Invest'
            when share_of_monthly_revenue >= 10 and mom_revenue_growth < 5 then 'Cash Cow - Maintain'
            when share_of_monthly_revenue < 5 and mom_revenue_growth >= 10 then 'Rising Star - Grow'
            when share_of_monthly_revenue < 2 and mom_revenue_growth < 0 then 'Question Mark - Review'
            else 'Core - Monitor'
        end as strategic_category
        
    from with_growth_metrics
)

select * from ranked