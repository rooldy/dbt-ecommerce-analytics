-- Test: RFM Segmentation Validation
-- Description: Validates that RFM scores and segments follow expected distributions
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: WARN (distribution monitoring)
--
-- This test ensures:
-- 1. All customers have RFM scores (1-5)
-- 2. Distribution is roughly balanced across quintiles (~20% each)
-- 3. Customer tier matches RFM score patterns
-- 4. Customer status is consistent with recency
-- 5. No invalid RFM score combinations

WITH rfm_data AS (
    SELECT
        customer_id,
        recency as rfm_recency,
        frequency as rfm_frequency,
        monetary as rfm_monetary,
        customer_tier,
        customer_status,
        recency as recency_days,
        frequency as total_orders,
        historical_ltv
    FROM {{ ref('mart_customer_lifetime_value') }}
),

-- Check 1: Invalid RFM scores (must be 1-5)
invalid_rfm_scores AS (
    SELECT
        'invalid_rfm_score' AS test_name,
        customer_id,
        CONCAT('R:', rfm_recency, ' F:', rfm_frequency, ' M:', rfm_monetary) AS violation_value,
        'RFM score outside valid range [1-5]' AS violation_description
    FROM rfm_data
    WHERE rfm_recency NOT BETWEEN 1 AND 5
       OR rfm_frequency NOT BETWEEN 1 AND 5
       OR rfm_monetary NOT BETWEEN 1 AND 5
),

-- Check 2: Distribution imbalance (should be ~20% per quintile, allow ±10%)
-- Calculate distribution for each RFM component
rfm_distribution AS (
    SELECT
        'recency' AS rfm_component,
        rfm_recency AS score,
        COUNT(*) AS customer_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
    FROM rfm_data
    GROUP BY rfm_recency
    
    UNION ALL
    
    SELECT
        'frequency',
        rfm_frequency,
        COUNT(*),
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)
    FROM rfm_data
    GROUP BY rfm_frequency
    
    UNION ALL
    
    SELECT
        'monetary',
        rfm_monetary,
        COUNT(*),
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)
    FROM rfm_data
    GROUP BY rfm_monetary
),

distribution_imbalance AS (
    SELECT
        'rfm_distribution_imbalance' AS test_name,
        rfm_component || ' score ' || score AS violation_value,
        customer_count,
        'Distribution: ' || percentage || '% (expected ~20%, tolerance ±10%)' AS violation_description
    FROM rfm_distribution
    WHERE percentage < 10 OR percentage > 30  -- Alert if outside 10-30% range
),

-- Check 3: Customer tier inconsistent with RFM scores
-- VIP should have high scores (R>=4 or F>=4 or M>=4)
vip_with_low_rfm AS (
    SELECT
        'vip_with_low_rfm' AS test_name,
        customer_id,
        CONCAT('R:', rfm_recency, ' F:', rfm_frequency, ' M:', rfm_monetary) AS violation_value,
        'VIP customer has low RFM scores (expected at least one score >=4)' AS violation_description
    FROM rfm_data
    WHERE customer_tier = 'VIP'
      AND rfm_recency < 4
      AND rfm_frequency < 4
      AND rfm_monetary < 4
),

-- Bronze should have mostly low scores
bronze_with_high_rfm AS (
    SELECT
        'bronze_with_high_rfm' AS test_name,
        customer_id,
        CONCAT('R:', rfm_recency, ' F:', rfm_frequency, ' M:', rfm_monetary) AS violation_value,
        'Bronze customer has all high RFM scores (>=4)' AS violation_description
    FROM rfm_data
    WHERE customer_tier = 'Bronze'
      AND rfm_recency >= 4
      AND rfm_frequency >= 4
      AND rfm_monetary >= 4
),

-- Check 4: Customer status inconsistent with recency
-- 'Lost' customers should have low recency (1-2)
lost_with_recent_purchase AS (
    SELECT
        'lost_customer_recent_purchase' AS test_name,
        customer_id,
        rfm_recency AS violation_value,
        'Lost customer has recent purchase (recency=' || rfm_recency || 
        ', last purchase ' || recency_days || ' days ago)' AS violation_description
    FROM rfm_data
    WHERE customer_status = 'Lost'
      AND rfm_recency >= 3  -- Recency 3+ means relatively recent
),

-- 'Active' customers should have good recency (4-5)
active_with_old_purchase AS (
    SELECT
        'active_customer_old_purchase' AS test_name,
        customer_id,
        rfm_recency AS violation_value,
        'Active customer has old last purchase (recency=' || rfm_recency || 
        ', ' || recency_days || ' days ago)' AS violation_description
    FROM rfm_data
    WHERE customer_status = 'Active'
      AND rfm_recency <= 2  -- Very old last purchase
      AND recency_days > 180  -- More than 6 months
),

-- Check 5: Impossible combinations
-- High monetary but low frequency (one huge order is possible but rare)
high_monetary_low_frequency AS (
    SELECT
        'suspicious_high_monetary_low_frequency' AS test_name,
        customer_id,
        CONCAT('F:', rfm_frequency, ' M:', rfm_monetary, ' LTV:', ROUND(historical_ltv, 2)) AS violation_value,
        'High monetary score (' || rfm_monetary || ') but low frequency (' || 
        rfm_frequency || ') with only ' || total_orders || ' orders' AS violation_description
    FROM rfm_data
    WHERE rfm_monetary >= 4
      AND rfm_frequency <= 2
      AND total_orders = 1  -- Flag only single-order customers
      AND historical_ltv > 1000  -- High value
),

-- Combine all violations
all_violations AS (
    SELECT test_name, customer_id::VARCHAR AS violation_value, NULL AS customer_count, violation_description
    FROM invalid_rfm_scores
    
    UNION ALL
    
    SELECT test_name, violation_value, customer_count, violation_description
    FROM distribution_imbalance
    
    UNION ALL
    
    SELECT test_name, customer_id::VARCHAR, NULL, violation_description
    FROM vip_with_low_rfm
    
    UNION ALL
    
    SELECT test_name, customer_id::VARCHAR, NULL, violation_description
    FROM bronze_with_high_rfm
    
    UNION ALL
    
    SELECT test_name, customer_id::VARCHAR, NULL, violation_description
    FROM lost_with_recent_purchase
    
    UNION ALL
    
    SELECT test_name, customer_id::VARCHAR, NULL, violation_description
    FROM active_with_old_purchase
    
    UNION ALL
    
    SELECT test_name, customer_id::VARCHAR, NULL, violation_description
    FROM high_monetary_low_frequency
)

-- Return all violations
SELECT
    test_name,
    violation_value,
    customer_count,
    violation_description,
    '⚠️ RFM segmentation issue detected' AS warning_message
FROM all_violations
ORDER BY test_name, violation_value

-- If this test returns rows, review the RFM segmentation logic or thresholds
-- Expected: 0-20 rows (some edge cases in distributions are normal)