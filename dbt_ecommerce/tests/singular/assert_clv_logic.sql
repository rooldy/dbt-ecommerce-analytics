-- Test: CLV Logic Validation
-- Description: Validates that CLV predictions follow business logic rules
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: ERROR (business logic validation)
--
-- This test ensures:
-- 1. predicted_clv_12m is never negative
-- 2. predicted_clv_12m >= historical_ltv * 0.5 (at least 50% of historical LTV)
-- 3. For 'Lost' customers, predicted_clv_12m should be 0
-- 4. For 'Active' customers with >3 orders, predicted_clv_12m > avg_order_value
-- 5. CLV should be reasonable relative to customer tier

WITH clv_data AS (
    SELECT
        customer_id,
        customer_tier,
        customer_status,
        frequency as total_orders,  -- frequency column represents total orders
        historical_ltv,
        predicted_clv_12m,
        avg_order_value,
        churn_risk
    FROM {{ ref('mart_customer_lifetime_value') }}
),

-- Check 1: Negative CLV predictions
negative_clv AS (
    SELECT
        'negative_predicted_clv' AS test_name,
        customer_id,
        predicted_clv_12m AS violation_value,
        'Predicted CLV is negative' AS violation_description
    FROM clv_data
    WHERE predicted_clv_12m < 0
),

-- Check 2: CLV too low compared to historical (should be at least 50%)
clv_too_low AS (
    SELECT
        'clv_below_50pct_historical' AS test_name,
        customer_id,
        predicted_clv_12m AS violation_value,
        'Predicted CLV (' || ROUND(predicted_clv_12m, 2) || 
        ') is less than 50% of historical LTV (' || ROUND(historical_ltv, 2) || ')' AS violation_description
    FROM clv_data
    WHERE predicted_clv_12m > 0  -- Exclude Lost customers (CLV=0)
      AND historical_ltv > 0
      AND predicted_clv_12m < (historical_ltv * 0.5)
      AND customer_status != 'Lost'  -- Lost customers can have CLV=0
),

-- Check 3: Lost customers should have CLV = 0
lost_with_clv AS (
    SELECT
        'lost_customer_has_clv' AS test_name,
        customer_id,
        predicted_clv_12m AS violation_value,
        'Lost customer has predicted CLV > 0: ' || ROUND(predicted_clv_12m, 2) AS violation_description
    FROM clv_data
    WHERE customer_status = 'Lost'
      AND predicted_clv_12m > 0
),

-- Check 4: Active customers with multiple orders should have CLV > AOV
active_low_clv AS (
    SELECT
        'active_clv_below_aov' AS test_name,
        customer_id,
        predicted_clv_12m AS violation_value,
        'Active customer with ' || total_orders || ' orders has CLV (' || 
        ROUND(predicted_clv_12m, 2) || ') below AOV (' || ROUND(avg_order_value, 2) || ')' AS violation_description
    FROM clv_data
    WHERE customer_status = 'Active'
      AND total_orders > 3
      AND predicted_clv_12m < avg_order_value
),

-- Check 5: VIP customers should have substantial CLV
vip_low_clv AS (
    SELECT
        'vip_with_low_clv' AS test_name,
        customer_id,
        predicted_clv_12m AS violation_value,
        'VIP customer has predicted CLV below $500: ' || ROUND(predicted_clv_12m, 2) AS violation_description
    FROM clv_data
    WHERE customer_tier = 'VIP'
      AND customer_status IN ('Active', 'At Risk')  -- Exclude Lost/Dormant
      AND predicted_clv_12m < 500
),

-- Combine all violations
all_violations AS (
    SELECT * FROM negative_clv
    UNION ALL
    SELECT * FROM clv_too_low
    UNION ALL
    SELECT * FROM lost_with_clv
    UNION ALL
    SELECT * FROM active_low_clv
    UNION ALL
    SELECT * FROM vip_low_clv
)

-- Return all violations
SELECT
    test_name,
    customer_id,
    violation_value,
    violation_description,
    '❌ CLV logic violation detected' AS error_message
FROM all_violations
ORDER BY test_name, violation_value DESC

-- If this test returns rows, investigate the CLV calculation logic
-- Expected: 0 rows (all CLV predictions follow business rules)