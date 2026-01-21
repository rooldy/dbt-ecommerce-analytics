-- Test: Revenue Consistency Across Models
-- Description: Validates that revenue calculations are consistent across all layers
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: ERROR (critical test)
-- 
-- This test ensures:
-- 1. Revenue in fct_order_items matches mart_sales_daily (aggregated)
-- 2. Revenue in mart_product_performance matches fct_order_items (by product)
-- 3. Revenue in fct_orders matches fct_order_items (by order)
-- 4. All revenue calculations use the same logic
--
-- Tolerance: ±0.01 for rounding errors
--
-- NOTE: mart_product_performance aggregates by PRODUCT, not ORDER
--       So we compare units_sold vs total_items, not orders count

WITH 

-- Base revenue from fact table (source of truth)
-- Note: fct_order_items only contains orders WITH items (excludes canceled/unavailable orders without items)
fact_revenue AS (
    SELECT 
        SUM(item_price) AS total_revenue,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS total_items
    FROM {{ ref('fct_order_items') }}
),

-- Revenue from sales daily mart (aggregated by date)
-- Note: mart_sales_daily aggregates from fct_orders
-- We need to match the same scope (orders with items only)
daily_revenue AS (
    SELECT 
        SUM(revenue) AS total_revenue,
        SUM(orders) AS total_orders
    FROM {{ ref('mart_sales_daily') }}
),

-- Revenue from product performance mart (aggregated by product)
product_revenue AS (
    SELECT 
        SUM(revenue) AS total_revenue,
        SUM(units_sold) AS total_units  -- Compare units, not orders sum
    FROM {{ ref('mart_product_performance') }}
),

-- Revenue from orders fact (aggregated by order)
-- Note: fct_orders contains ALL orders (including those without items)
-- We filter to only orders with items_count > 0 to match fct_order_items scope
orders_revenue AS (
    SELECT 
        SUM(items_total_price) AS total_revenue,
        COUNT(DISTINCT order_id) AS total_orders
    FROM {{ ref('fct_orders') }}
    WHERE items_count > 0  -- Only orders with items (matches fct_order_items)
),

-- Comparison table
revenue_comparison AS (
    SELECT
        'fct_order_items' AS source,
        fact_revenue.total_revenue,
        fact_revenue.total_orders,
        fact_revenue.total_items,
        0.0 AS revenue_diff_pct,
        0.0 AS count_diff_pct,
        'baseline' AS comparison_note
    FROM fact_revenue
    
    UNION ALL
    
    SELECT
        'mart_sales_daily' AS source,
        daily_revenue.total_revenue,
        daily_revenue.total_orders,
        NULL AS total_items,
        ROUND(ABS(daily_revenue.total_revenue - fact_revenue.total_revenue) / fact_revenue.total_revenue * 100, 2) AS revenue_diff_pct,
        ROUND(ABS(daily_revenue.total_orders - fact_revenue.total_orders) / fact_revenue.total_orders * 100, 2) AS count_diff_pct,
        'comparing orders count' AS comparison_note
    FROM daily_revenue, fact_revenue
    
    UNION ALL
    
    SELECT
        'mart_product_performance' AS source,
        product_revenue.total_revenue,
        NULL AS total_orders,
        product_revenue.total_units AS total_items,
        ROUND(ABS(product_revenue.total_revenue - fact_revenue.total_revenue) / fact_revenue.total_revenue * 100, 2) AS revenue_diff_pct,
        ROUND(ABS(product_revenue.total_units - fact_revenue.total_items) / fact_revenue.total_items * 100, 2) AS count_diff_pct,
        'comparing units_sold vs total_items' AS comparison_note
    FROM product_revenue, fact_revenue
    
    UNION ALL
    
    SELECT
        'fct_orders' AS source,
        orders_revenue.total_revenue,
        orders_revenue.total_orders,
        NULL AS total_items,
        ROUND(ABS(orders_revenue.total_revenue - fact_revenue.total_revenue) / fact_revenue.total_revenue * 100, 2) AS revenue_diff_pct,
        ROUND(ABS(orders_revenue.total_orders - fact_revenue.total_orders) / fact_revenue.total_orders * 100, 2) AS count_diff_pct,
        'comparing orders count' AS comparison_note
    FROM orders_revenue, fact_revenue
)

-- Return rows where discrepancy exceeds tolerance (0.01%)
SELECT
    source,
    total_revenue,
    total_orders,
    total_items,
    revenue_diff_pct,
    count_diff_pct,
    comparison_note,
    CASE 
        WHEN revenue_diff_pct > 0.01 THEN '❌ Revenue mismatch: ' || revenue_diff_pct || '%'
        WHEN count_diff_pct > 0.01 THEN '❌ Count mismatch: ' || count_diff_pct || '%'
        ELSE '✅ Consistent'
    END AS status
FROM revenue_comparison
WHERE 
    revenue_diff_pct > 0.01  -- Revenue discrepancy > 0.01%
    OR count_diff_pct > 0.01  -- Count discrepancy > 0.01%

-- If this test returns any rows, it means there's an inconsistency
-- Expected: 0 rows (all revenue calculations are consistent)