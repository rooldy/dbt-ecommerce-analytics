-- Test: Cohort Retention Logic
-- Description: Validates that cohort retention follows expected patterns
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: ERROR (cohort analysis validation)
--
-- This test ensures:
-- 1. retention_rate is between 0 and 100%
-- 2. retention_rate at M0 (first month) is always 100%
-- 3. retention_rate is non-increasing over time (never goes up)
-- 4. active_customers <= cohort_size
-- 5. No gaps in months_since_cohort sequence for each cohort

WITH cohort_data AS (
    SELECT
        cohort_month,
        cohort_label,
        months_since_cohort,
        cohort_size,
        active_customers,
        retention_rate,
        cohort_revenue
    FROM {{ ref('mart_customer_cohorts') }}
),

-- Check 1: Retention rate outside valid range (0-100%)
invalid_retention_rate AS (
    SELECT
        'invalid_retention_rate' AS test_name,
        cohort_month,
        cohort_label,
        months_since_cohort,
        retention_rate AS violation_value,
        'Retention rate (' || ROUND(retention_rate, 2) || '%) is outside valid range [0-100]' AS violation_description
    FROM cohort_data
    WHERE retention_rate < 0 OR retention_rate > 100
),

-- Check 2: M0 retention should always be 100%
m0_not_100 AS (
    SELECT
        'm0_retention_not_100' AS test_name,
        cohort_month,
        cohort_label,
        months_since_cohort,
        retention_rate AS violation_value,
        'M0 retention rate is ' || ROUND(retention_rate, 2) || '% (should be 100%)' AS violation_description
    FROM cohort_data
    WHERE months_since_cohort = 0
      AND ABS(retention_rate - 100.0) > 0.01  -- Allow tiny rounding errors
),

-- Check 3: Retention should not increase over time (non-increasing)
increasing_retention AS (
    SELECT
        'retention_increased' AS test_name,
        curr.cohort_month,
        curr.cohort_label,
        curr.months_since_cohort,
        curr.retention_rate AS violation_value,
        'Retention increased from ' || ROUND(prev.retention_rate, 2) || 
        '% (M' || prev.months_since_cohort || ') to ' || ROUND(curr.retention_rate, 2) || 
        '% (M' || curr.months_since_cohort || ')' AS violation_description
    FROM cohort_data curr
    JOIN cohort_data prev 
        ON curr.cohort_month = prev.cohort_month
        AND curr.months_since_cohort = prev.months_since_cohort + 1
    WHERE curr.retention_rate > prev.retention_rate + 0.01  -- Allow tiny rounding errors
),

-- Check 4: Active customers should never exceed cohort size
active_exceeds_cohort AS (
    SELECT
        'active_exceeds_cohort_size' AS test_name,
        cohort_month,
        cohort_label,
        months_since_cohort,
        active_customers AS violation_value,
        'Active customers (' || active_customers || ') exceeds cohort size (' || cohort_size || ')' AS violation_description
    FROM cohort_data
    WHERE active_customers > cohort_size
),

-- Check 5: Check for gaps in months_since_cohort sequence
missing_months AS (
    SELECT
        'missing_cohort_month' AS test_name,
        cohort_month,
        cohort_label,
        expected_month AS months_since_cohort,
        0 AS violation_value,
        'Missing month ' || expected_month || ' in cohort sequence' AS violation_description
    FROM (
        SELECT DISTINCT 
            cohort_month,
            cohort_label,
            MAX(months_since_cohort) OVER (PARTITION BY cohort_month) AS max_month
        FROM cohort_data
    ) cohorts
    CROSS JOIN (
        SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS expected_month
        FROM TABLE(GENERATOR(ROWCOUNT => 50))  -- Check up to 50 months
    ) months
    WHERE expected_month <= max_month
      AND NOT EXISTS (
          SELECT 1 
          FROM cohort_data cd
          WHERE cd.cohort_month = cohorts.cohort_month
            AND cd.months_since_cohort = expected_month
      )
),

-- Combine all violations
all_violations AS (
    SELECT * FROM invalid_retention_rate
    UNION ALL
    SELECT * FROM m0_not_100
    UNION ALL
    SELECT * FROM increasing_retention
    UNION ALL
    SELECT * FROM active_exceeds_cohort
    UNION ALL
    SELECT * FROM missing_months
)

-- Return all violations
SELECT
    test_name,
    cohort_month,
    cohort_label,
    months_since_cohort,
    violation_value,
    violation_description,
    '❌ Cohort retention logic violation' AS error_message
FROM all_violations
ORDER BY cohort_month, months_since_cohort

-- If this test returns rows, investigate the cohort calculation logic
-- Expected: 0 rows (all cohort retention follows expected patterns)