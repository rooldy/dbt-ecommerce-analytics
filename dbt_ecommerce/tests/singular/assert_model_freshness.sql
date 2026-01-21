-- Test: Model Freshness
-- Description: Validates that models contain recent data and are up-to-date
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: WARN (freshness monitoring)
--
-- This test ensures:
-- 1. mart_sales_daily has data up to within 2 days of current date
-- 2. No gaps in dates in mart_sales_daily
-- 3. fct_orders max date matches source data recency expectations
-- 4. marts are not stale compared to fact tables

WITH

-- Check 1: mart_sales_daily freshness (should be within 2 days)
sales_daily_freshness AS (
    SELECT
        'mart_sales_daily' AS model_name,
        MAX(full_date) AS max_date,
        CURRENT_DATE() AS current_date,
        DATEDIFF(day, MAX(full_date), CURRENT_DATE()) AS days_behind
    FROM {{ ref('mart_sales_daily') }}
),

sales_daily_stale AS (
    SELECT
        'mart_sales_daily_stale' AS test_name,
        model_name AS violation_value,
        'Last data: ' || max_date || ' (' || days_behind || ' days behind current date)' AS violation_description
    FROM sales_daily_freshness
    WHERE days_behind > 2  -- Alert if more than 2 days old
),

-- Check 2: Gaps in mart_sales_daily dates
sales_daily_date_range AS (
    SELECT 
        MIN(full_date) AS min_date,
        MAX(full_date) AS max_date,
        DATEDIFF(day, MIN(full_date), MAX(full_date)) + 1 AS expected_days,
        COUNT(*) AS actual_days
    FROM {{ ref('mart_sales_daily') }}
),

sales_daily_gaps AS (
    SELECT
        'mart_sales_daily_has_gaps' AS test_name,
        'Date range: ' || min_date || ' to ' || max_date AS violation_value,
        'Expected ' || expected_days || ' days but found ' || actual_days || 
        ' days (' || (expected_days - actual_days) || ' missing)' AS violation_description
    FROM sales_daily_date_range
    WHERE expected_days != actual_days
),

-- Check 3: fct_orders freshness
orders_freshness AS (
    SELECT
        'fct_orders' AS model_name,
        MAX(DATE(order_purchase_timestamp)) AS max_date,
        CURRENT_DATE() AS current_date,
        DATEDIFF(day, MAX(DATE(order_purchase_timestamp)), CURRENT_DATE()) AS days_behind
    FROM {{ ref('fct_orders') }}
),

orders_stale AS (
    SELECT
        'fct_orders_stale' AS test_name,
        model_name AS violation_value,
        'Last order: ' || max_date || ' (' || days_behind || ' days behind current date)' AS violation_description
    FROM orders_freshness
    WHERE days_behind > 7  -- Historical dataset, so allow more lag
),

-- Check 4: Marts vs Fact freshness (marts should be as fresh as facts)
fact_vs_mart_freshness AS (
    SELECT
        'fact_tables' AS source,
        MAX(DATE(order_purchase_timestamp)) AS max_date
    FROM {{ ref('fct_orders') }}
    
    UNION ALL
    
    SELECT
        'mart_sales_daily',
        MAX(full_date)
    FROM {{ ref('mart_sales_daily') }}
    
    UNION ALL
    
    SELECT
        'mart_customer_cohorts',
        MAX(cohort_month)
    FROM {{ ref('mart_customer_cohorts') }}
),

mart_behind_fact AS (
    SELECT
        'mart_behind_fact_tables' AS test_name,
        m.source AS violation_value,
        'Mart max date (' || m.max_date || ') is behind fact tables (' || 
        f.max_date || ') by ' || DATEDIFF(day, m.max_date, f.max_date) || ' days' AS violation_description
    FROM fact_vs_mart_freshness m
    CROSS JOIN (
        SELECT max_date FROM fact_vs_mart_freshness WHERE source = 'fact_tables'
    ) f
    WHERE m.source != 'fact_tables'
      AND m.max_date < f.max_date
      AND DATEDIFF(day, m.max_date, f.max_date) > 1  -- Allow 1 day lag for processing
),

-- Check 5: Customer CLV mart freshness (should reflect recent orders)
clv_freshness AS (
    SELECT
        COUNT(*) AS customers_with_recent_orders,
        COUNT(*) AS total_active_customers
    FROM {{ ref('mart_customer_lifetime_value') }}
    WHERE customer_status = 'Active'
      AND recency <= 30  -- Active = purchased in last 30 days (recency in days)
),

clv_missing_recent AS (
    SELECT
        'clv_missing_recent_customers' AS test_name,
        'Active customers' AS violation_value,
        'Only ' || customers_with_recent_orders || ' active customers with recent orders (last 30 days)' AS violation_description
    FROM clv_freshness
    WHERE customers_with_recent_orders < 100  -- Expect at least 100 active customers
),

-- Combine all violations
all_violations AS (
    SELECT test_name, violation_value, violation_description
    FROM sales_daily_stale
    
    UNION ALL
    
    SELECT test_name, violation_value, violation_description
    FROM sales_daily_gaps
    
    UNION ALL
    
    SELECT test_name, violation_value, violation_description
    FROM orders_stale
    
    UNION ALL
    
    SELECT test_name, violation_value, violation_description
    FROM mart_behind_fact
    
    UNION ALL
    
    SELECT test_name, violation_value, violation_description
    FROM clv_missing_recent
)

-- Return all violations
SELECT
    test_name,
    violation_value,
    violation_description,
    '⚠️ Data freshness issue detected' AS warning_message
FROM all_violations
ORDER BY test_name

-- If this test returns rows, investigate why data is stale
-- This is a WARN test because historical datasets may not update
-- Expected for production: 0 rows (all models are fresh)