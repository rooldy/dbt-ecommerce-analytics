-- Test: Reasonable Values
-- Description: Validates that numeric values are within expected business ranges
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: WARN (data quality monitoring)
--
-- This test checks that key metrics fall within reasonable business ranges
-- to detect data quality issues, outliers, or data entry errors

WITH

-- Check prices in fct_order_items
price_violations AS (
    SELECT
        'fct_order_items' AS model,
        'item_price' AS column_name,
        order_item_key AS record_id,
        item_price AS value,
        CASE
            WHEN item_price <= 0 THEN 'Negative or zero price'
            WHEN item_price > 10000 THEN 'Unreasonably high price (>$10k)'
            ELSE 'Unknown violation'
        END AS violation_type
    FROM {{ ref('fct_order_items') }}
    WHERE item_price <= 0 OR item_price > 10000
),

-- Check freight values
freight_violations AS (
    SELECT
        'fct_order_items' AS model,
        'item_freight_value' AS column_name,
        order_item_key AS record_id,
        item_freight_value AS value,
        CASE
            WHEN item_freight_value < 0 THEN 'Negative freight value'
            WHEN item_freight_value > 1000 THEN 'Unreasonably high freight (>$1k)'
            ELSE 'Unknown violation'
        END AS violation_type
    FROM {{ ref('fct_order_items') }}
    WHERE item_freight_value < 0 OR item_freight_value > 1000
),

-- Check payment values in fct_orders
payment_violations AS (
    SELECT
        'fct_orders' AS model,
        'total_payment_value' AS column_name,
        order_id AS record_id,
        total_payment_value AS value,
        CASE
            WHEN total_payment_value <= 0 THEN 'Negative or zero payment'
            WHEN total_payment_value > 50000 THEN 'Unreasonably high payment (>$50k)'
            ELSE 'Unknown violation'
        END AS violation_type
    FROM {{ ref('fct_orders') }}
    WHERE (total_payment_value <= 0 OR total_payment_value > 50000)
    AND is_canceled = FALSE
),

-- Check delivery days in fct_orders
delivery_violations AS (
    SELECT
        'fct_orders' AS model,
        'actual_delivery_days' AS column_name,
        order_id AS record_id,
        actual_delivery_days AS value,
        CASE
            WHEN actual_delivery_days < 0 
                THEN 'Negative delivery time (delivered before ordered)'
            WHEN actual_delivery_days > 200 
                THEN 'Unreasonably long delivery (>200 days)'
            ELSE 'Unknown violation'
        END AS violation_type
    FROM {{ ref('fct_orders') }}
    WHERE actual_delivery_days IS NOT NULL
        AND (
            actual_delivery_days < 0
            OR actual_delivery_days > 200
        )
),

-- Check CLV predictions
clv_violations AS (
    SELECT
        'mart_customer_lifetime_value' AS model,
        'predicted_clv_12m' AS column_name,
        customer_id AS record_id,
        predicted_clv_12m AS value,
        CASE
            WHEN predicted_clv_12m < 0 THEN 'Negative predicted CLV'
            WHEN predicted_clv_12m > 100000 THEN 'Unreasonably high CLV (>$100k)'
            ELSE 'Unknown violation'
        END AS violation_type
    FROM {{ ref('mart_customer_lifetime_value') }}
    WHERE predicted_clv_12m < 0 OR predicted_clv_12m > 100000
),

-- Check retention rates
retention_violations AS (
    SELECT
        'mart_customer_cohorts' AS model,
        'retention_rate' AS column_name,
        cohort_month || '-M' || months_since_cohort AS record_id,
        retention_rate AS value,
        CASE
            WHEN retention_rate < 0 THEN 'Negative retention rate'
            WHEN retention_rate > 100 THEN 'Retention rate above 100%'
            ELSE 'Unknown violation'
        END AS violation_type
    FROM {{ ref('mart_customer_cohorts') }}
    WHERE retention_rate < 0 OR retention_rate > 100
),

-- Check product health scores
health_score_violations AS (
    SELECT
        'mart_product_performance' AS model,
        'product_health_score' AS column_name,
        product_id AS record_id,
        product_health_score AS value,
        CASE
            WHEN product_health_score < 0 THEN 'Negative health score'
            WHEN product_health_score > 100 THEN 'Health score above 100'
            ELSE 'Unknown violation'
        END AS violation_type
    FROM {{ ref('mart_product_performance') }}
    WHERE product_health_score < 0 OR product_health_score > 100
),

-- Combine all violations
all_violations AS (
    SELECT * FROM price_violations
    UNION ALL
    SELECT * FROM freight_violations
    UNION ALL
    SELECT * FROM payment_violations
    UNION ALL
    SELECT * FROM delivery_violations
    UNION ALL
    SELECT * FROM clv_violations
    UNION ALL
    SELECT * FROM retention_violations
    UNION ALL
    SELECT * FROM health_score_violations
)

-- Return all violations with details
SELECT
    model,
    column_name,
    record_id,
    value,
    violation_type,
    '⚠️ Value outside reasonable range' AS warning
FROM all_violations
ORDER BY model, column_name, value

-- If this test returns rows, investigate the violations
-- Some violations might be legitimate outliers, others might be data errors
-- Expected: 0-10 rows (minimal violations)