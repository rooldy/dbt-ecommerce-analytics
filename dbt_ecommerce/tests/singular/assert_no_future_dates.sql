-- Test: No Future Dates
-- Description: Ensures no dates in the future exist in any model
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: ERROR (critical test)
--
-- This test checks all date columns across all models to ensure
-- no dates beyond CURRENT_DATE exist, which would indicate data quality issues

WITH

-- Check fct_orders
fact_orders_purchase AS (
    SELECT
        'fct_orders' AS model,
        'order_purchase_timestamp' AS date_column,
        order_id AS record_id,
        DATE(order_purchase_timestamp) AS date_value
    FROM {{ ref('fct_orders') }}
    WHERE DATE(order_purchase_timestamp) > CURRENT_DATE()
),

fact_orders_approved AS (
    SELECT
        'fct_orders' AS model,
        'order_approved_at' AS date_column,
        order_id AS record_id,
        DATE(order_approved_at) AS date_value
    FROM {{ ref('fct_orders') }}
    WHERE DATE(order_approved_at) > CURRENT_DATE()
),

fact_orders_delivered_carrier AS (
    SELECT
        'fct_orders' AS model,
        'order_delivered_carrier_date' AS date_column,
        order_id AS record_id,
        order_delivered_carrier_date AS date_value
    FROM {{ ref('fct_orders') }}
    WHERE order_delivered_carrier_date > CURRENT_DATE()
),

fact_orders_delivered_customer AS (
    SELECT
        'fct_orders' AS model,
        'order_delivered_customer_date' AS date_column,
        order_id AS record_id,
        order_delivered_customer_date AS date_value
    FROM {{ ref('fct_orders') }}
    WHERE order_delivered_customer_date > CURRENT_DATE()
),

fact_orders_estimated AS (
    SELECT
        'fct_orders' AS model,
        'order_estimated_delivery_date' AS date_column,
        order_id AS record_id,
        order_estimated_delivery_date AS date_value
    FROM {{ ref('fct_orders') }}
    WHERE order_estimated_delivery_date > CURRENT_DATE()
),

-- Check fct_order_items
fact_items_dates AS (
    SELECT
        'fct_order_items' AS model,
        'order_purchase_timestamp' AS date_column,
        order_item_key AS record_id,
        DATE(order_purchase_timestamp) AS date_value
    FROM {{ ref('fct_order_items') }}
    WHERE DATE(order_purchase_timestamp) > CURRENT_DATE()
),

-- Check mart_sales_daily
mart_sales_dates AS (
    SELECT
        'mart_sales_daily' AS model,
        'full_date' AS date_column,
        date_key AS record_id,
        full_date AS date_value
    FROM {{ ref('mart_sales_daily') }}
    WHERE full_date > CURRENT_DATE()
),

-- Check mart_customer_cohorts
mart_cohorts_dates AS (
    SELECT
        'mart_customer_cohorts' AS model,
        'cohort_month' AS date_column,
        cohort_month || '-' || months_since_cohort AS record_id,
        cohort_month AS date_value
    FROM {{ ref('mart_customer_cohorts') }}
    WHERE cohort_month > CURRENT_DATE()
),

-- Combine all future dates
all_future_dates AS (
    SELECT * FROM fact_orders_purchase
    UNION ALL
    SELECT * FROM fact_orders_approved
    UNION ALL
    SELECT * FROM fact_orders_delivered_carrier
    UNION ALL
    SELECT * FROM fact_orders_delivered_customer
    UNION ALL
    SELECT * FROM fact_orders_estimated
    UNION ALL
    SELECT * FROM fact_items_dates
    UNION ALL
    SELECT * FROM mart_sales_dates
    UNION ALL
    SELECT * FROM mart_cohorts_dates
)

-- Return all records with future dates
SELECT
    model,
    date_column,
    record_id,
    date_value,
    CURRENT_DATE() AS current_date,
    DATEDIFF(day, CURRENT_DATE(), date_value) AS days_in_future,
    '❌ Future date detected' AS error_message
FROM all_future_dates
ORDER BY date_value DESC

-- If this test returns any rows, it means there are dates in the future
-- Expected: 0 rows (no future dates)