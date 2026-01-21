-- Test: NULL Rates Monitoring
-- Description: Monitors NULL rates in critical columns across key models
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: WARN (data quality monitoring)
--
-- This test ensures:
-- 1. NULL rate for delivery_date < 5% (for non-canceled orders)
-- 2. NULL rate for customer_state = 0% (required field)
-- 3. NULL rate for product_category < 2% (should be categorized)
-- 4. NULL rate for payment_value = 0% (required for all orders)

WITH

-- Check fct_orders - delivery_date NULL rate
orders_delivery_nulls AS (
    SELECT
        'fct_orders' AS model_name,
        'order_delivered_customer_date' AS column_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_count,
        ROUND(SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS null_rate_pct,
        5.0 AS threshold_pct
    FROM {{ ref('fct_orders') }}
    WHERE is_canceled = FALSE  -- Exclude canceled orders
),

-- Check dim_customers - customer_state NULL rate
customers_state_nulls AS (
    SELECT
        'dim_customers' AS model_name,
        'customer_state' AS column_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_count,
        ROUND(SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS null_rate_pct,
        0.0 AS threshold_pct  -- Required field
    FROM {{ ref('dim_customers') }}
),

-- Check fct_order_items - product_category NULL rate
items_category_nulls AS (
    SELECT
        'fct_order_items' AS model_name,
        'product_category_en' AS column_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN product_category_en IS NULL THEN 1 ELSE 0 END) AS null_count,
        ROUND(SUM(CASE WHEN product_category_en IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS null_rate_pct,
        2.0 AS threshold_pct  -- Most products should be categorized
    FROM {{ ref('fct_order_items') }}
),

-- Check fct_orders - payment_value NULL rate
orders_payment_nulls AS (
    SELECT
        'fct_orders' AS model_name,
        'total_payment_value' AS column_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN total_payment_value IS NULL THEN 1 ELSE 0 END) AS null_count,
        ROUND(SUM(CASE WHEN total_payment_value IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS null_rate_pct,
        0.0 AS threshold_pct  -- Required field
    FROM {{ ref('fct_orders') }}
),

-- Check fct_order_items - price NULL rate
items_price_nulls AS (
    SELECT
        'fct_order_items' AS model_name,
        'item_price' AS column_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN item_price IS NULL THEN 1 ELSE 0 END) AS null_count,
        ROUND(SUM(CASE WHEN item_price IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS null_rate_pct,
        0.0 AS threshold_pct  -- Required field
    FROM {{ ref('fct_order_items') }}
),

-- Check dim_products - product_category NULL rate
products_category_nulls AS (
    SELECT
        'dim_products' AS model_name,
        'category_name_en' AS column_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN category_name_en IS NULL THEN 1 ELSE 0 END) AS null_count,
        ROUND(SUM(CASE WHEN category_name_en IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS null_rate_pct,
        2.0 AS threshold_pct  -- Some products may not have translation
    FROM {{ ref('dim_products') }}
),

-- Check mart_customer_lifetime_value - critical fields
clv_nulls AS (
    SELECT
        'mart_customer_lifetime_value' AS model_name,
        'predicted_clv_12m' AS column_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN predicted_clv_12m IS NULL THEN 1 ELSE 0 END) AS null_count,
        ROUND(SUM(CASE WHEN predicted_clv_12m IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS null_rate_pct,
        0.0 AS threshold_pct  -- Should be calculated for all customers
    FROM {{ ref('mart_customer_lifetime_value') }}
),

-- Combine all NULL rate checks
all_null_rates AS (
    SELECT * FROM orders_delivery_nulls
    UNION ALL
    SELECT * FROM customers_state_nulls
    UNION ALL
    SELECT * FROM items_category_nulls
    UNION ALL
    SELECT * FROM orders_payment_nulls
    UNION ALL
    SELECT * FROM items_price_nulls
    UNION ALL
    SELECT * FROM products_category_nulls
    UNION ALL
    SELECT * FROM clv_nulls
),

-- Filter to violations (NULL rate exceeds threshold)
null_rate_violations AS (
    SELECT
        model_name || '.' || column_name AS test_name,
        ROUND(null_rate_pct, 2) || '%' AS violation_value,
        'NULL rate: ' || null_count || '/' || total_rows || ' rows (' || 
        ROUND(null_rate_pct, 2) || '%) exceeds threshold (' || 
        threshold_pct || '%)' AS violation_description
    FROM all_null_rates
    WHERE null_rate_pct > threshold_pct
)

-- Return all violations
SELECT
    test_name,
    violation_value,
    violation_description,
    '⚠️ High NULL rate detected' AS warning_message
FROM null_rate_violations
ORDER BY test_name

-- If this test returns rows, investigate data quality issues
-- High NULL rates may indicate:
-- - Missing data in source systems
-- - Integration issues
-- - Optional fields that need documentation
-- Expected: 0-3 rows (some NULLs in optional fields are acceptable)