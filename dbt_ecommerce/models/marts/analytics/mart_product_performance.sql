{{
    config(
        materialized='table',
        tags=['marts', 'analytics', 'products']
    )
}}

with product_sales as (
    select
        p.product_id,
        p.category_name_pt,
        p.category_name_en,
        p.weight_category,
        p.volume_category,
        p.listing_quality,
        
        -- Sales metrics
        count(distinct f.order_id) as orders,
        count(*) as units_sold,
        sum(f.item_price) as revenue,
        avg(f.item_price) as avg_price,
        min(f.item_price) as min_price,
        max(f.item_price) as max_price,
        
        -- Freight metrics
        sum(f.item_freight_value) as total_freight,
        avg(f.freight_percentage) as avg_freight_pct,
        
        -- Total value
        sum(f.item_total_value) as total_value,
        
        -- Customer metrics
        count(distinct f.customer_id) as unique_customers
        
    from {{ ref('fct_order_items') }} f
    join {{ ref('dim_products') }} p on f.product_key = p.product_key
    group by 1,2,3,4,5,6
),

product_reviews as (
    select
        oi.product_id,
        count(distinct r.review_id) as review_count,
        avg(r.review_score) as avg_rating,
        sum(case when r.review_score = 5 then 1 else 0 end) as rating_5_count,
        sum(case when r.review_score = 4 then 1 else 0 end) as rating_4_count,
        sum(case when r.review_score = 3 then 1 else 0 end) as rating_3_count,
        sum(case when r.review_score = 2 then 1 else 0 end) as rating_2_count,
        sum(case when r.review_score = 1 then 1 else 0 end) as rating_1_count,
        sum(case when r.review_score >= 4 then 1 else 0 end) as positive_reviews,
        sum(case when r.review_score <= 2 then 1 else 0 end) as negative_reviews
    from {{ ref('stg_order_items') }} oi
    join {{ ref('stg_reviews') }} r on oi.order_id = r.order_id
    group by 1
),

combined as (
    select
        s.*,
        
        -- Review metrics
        coalesce(r.review_count, 0) as review_count,
        r.avg_rating,
        coalesce(r.positive_reviews, 0) as positive_reviews,
        coalesce(r.negative_reviews, 0) as negative_reviews,
        coalesce(r.rating_5_count, 0) as rating_5_count,
        coalesce(r.rating_4_count, 0) as rating_4_count,
        coalesce(r.rating_3_count, 0) as rating_3_count,
        coalesce(r.rating_2_count, 0) as rating_2_count,
        coalesce(r.rating_1_count, 0) as rating_1_count,
        
        -- Calculated metrics
        round(s.revenue / nullif(s.units_sold, 0), 2) as revenue_per_unit,
        round(s.revenue / nullif(s.orders, 0), 2) as revenue_per_order,
        round(s.units_sold::float / nullif(s.orders, 0), 2) as units_per_order,
        round(s.total_freight / nullif(s.revenue, 0) * 100, 2) as freight_cost_pct,
        
        -- Review rates
        round(coalesce(r.positive_reviews, 0) * 100.0 / nullif(r.review_count, 0), 2) as satisfaction_rate,
        round(coalesce(r.review_count, 0) * 100.0 / nullif(s.units_sold, 0), 2) as review_rate
        
    from product_sales s
    left join product_reviews r on s.product_id = r.product_id
),

with_rankings as (
    select
    -- Fix NULL categories
    product_id,
    category_name_pt,
    coalesce(category_name_en, category_name_pt, 'Uncategorized') as category_name_en,
    weight_category,
    volume_category,
    listing_quality,
    orders,
    units_sold,
    revenue,
    avg_price,
    min_price,
    max_price,
    total_freight,
    avg_freight_pct,
    total_value,
    unique_customers,
    review_count,
    avg_rating,
    positive_reviews,
    negative_reviews,
    rating_5_count,
    rating_4_count,
    rating_3_count,
    rating_2_count,
    rating_1_count,
    revenue_per_unit,
    revenue_per_order,
    units_per_order,
    freight_cost_pct,
    satisfaction_rate,
    review_rate,
        
        -- Rankings within category
        row_number() over (partition by category_name_en order by revenue desc) as rank_in_category_revenue,
        row_number() over (partition by category_name_en order by units_sold desc) as rank_in_category_units,
        row_number() over (partition by category_name_en order by avg_rating desc nulls last) as rank_in_category_rating,
        
        -- Overall rankings
        row_number() over (order by revenue desc) as rank_overall_revenue,
        row_number() over (order by units_sold desc) as rank_overall_units,
        
        -- Performance tiers
        case 
            when revenue >= percentile_cont(0.9) within group (order by revenue) over () then 'Top 10%'
            when revenue >= percentile_cont(0.75) within group (order by revenue) over () then 'Top 25%'
            when revenue >= percentile_cont(0.50) within group (order by revenue) over () then 'Top 50%'
            else 'Bottom 50%'
        end as revenue_tier,
        
        -- Product health score (0-100)
        least(100,
            -- Sales component (40 points)
            (case 
                when revenue >= percentile_cont(0.9) within group (order by revenue) over () then 40
                when revenue >= percentile_cont(0.75) within group (order by revenue) over () then 30
                when revenue >= percentile_cont(0.50) within group (order by revenue) over () then 20
                else 10
            end) +
            -- Rating component (40 points)
            (case 
                when avg_rating >= 4.5 then 40
                when avg_rating >= 4.0 then 30
                when avg_rating >= 3.5 then 20
                when avg_rating >= 3.0 then 10
                else 0
            end) +
            -- Review engagement (20 points)
            (case 
                when review_rate >= 10 then 20
                when review_rate >= 5 then 15
                when review_rate >= 2 then 10
                else 5
            end)
        ) as product_health_score,
        
        -- Recommendations
        case 
            when units_sold < 10 then 'Insufficient Data'
            when avg_rating < 3.0 and review_count >= 10 then 'Consider Removal'
            when revenue_tier = 'Top 10%' and avg_rating >= 4.5 then 'Feature Product'
            when revenue_tier in ('Top 10%', 'Top 25%') and satisfaction_rate < 70 then 'Investigate Quality'
            when avg_freight_pct > 30 and avg_rating < 4.0 then 'High Cost + Low Satisfaction'
            when rank_in_category_revenue <= 3 then 'Category Leader'
            else 'Monitor'
        end as product_recommendation
        
    from combined
)

select * from with_rankings