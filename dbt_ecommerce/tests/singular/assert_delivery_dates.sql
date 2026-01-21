-- Test: Delivery Dates Sequence Validation
-- Description: Validates that delivery dates follow logical chronological order
-- Author: Rooldy Alphonse
-- Date: 2025-01-21
-- Severity: ERROR (data integrity)
--
-- This test ensures:
-- 1. order_delivered_customer_date >= order_purchase_timestamp
-- 2. order_delivered_customer_date >= order_delivered_carrier_date
-- 3. order_delivered_carrier_date >= order_approved_at
-- 4. order_estimated_delivery_date >= order_purchase_timestamp
-- 5. If delivered, then shipped_date must exist

WITH order_dates AS (
    SELECT
        order_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        is_delivered,
        is_canceled
    FROM {{ ref('fct_orders') }}
    WHERE is_canceled = FALSE  -- Focus on non-canceled orders
),

-- Check 1: Delivered before ordered
delivered_before_ordered AS (
    SELECT
        'delivered_before_ordered' AS test_name,
        order_id,
        order_delivered_customer_date AS violation_date,
        'Order delivered (' || order_delivered_customer_date || 
        ') before order date (' || DATE(order_purchase_timestamp) || ')' AS violation_description
    FROM order_dates
    WHERE order_delivered_customer_date IS NOT NULL
      AND order_delivered_customer_date < DATE(order_purchase_timestamp)
),

-- Check 2: Delivered to customer before delivered to carrier
delivered_customer_before_carrier AS (
    SELECT
        'delivered_customer_before_carrier' AS test_name,
        order_id,
        order_delivered_customer_date AS violation_date,
        'Delivered to customer (' || order_delivered_customer_date || 
        ') before delivered to carrier (' || order_delivered_carrier_date || ')' AS violation_description
    FROM order_dates
    WHERE order_delivered_customer_date IS NOT NULL
      AND order_delivered_carrier_date IS NOT NULL
      AND order_delivered_customer_date < order_delivered_carrier_date
),

-- Check 3: Delivered to carrier before approval
delivered_carrier_before_approval AS (
    SELECT
        'delivered_carrier_before_approval' AS test_name,
        order_id,
        order_delivered_carrier_date AS violation_date,
        'Delivered to carrier (' || order_delivered_carrier_date || 
        ') before order approved (' || DATE(order_approved_at) || ')' AS violation_description
    FROM order_dates
    WHERE order_delivered_carrier_date IS NOT NULL
      AND order_approved_at IS NOT NULL
      AND order_delivered_carrier_date < DATE(order_approved_at)
),

-- Check 4: Estimated delivery before order date
estimated_before_ordered AS (
    SELECT
        'estimated_before_ordered' AS test_name,
        order_id,
        order_estimated_delivery_date AS violation_date,
        'Estimated delivery (' || order_estimated_delivery_date || 
        ') is before order date (' || DATE(order_purchase_timestamp) || ')' AS violation_description
    FROM order_dates
    WHERE order_estimated_delivery_date IS NOT NULL
      AND order_estimated_delivery_date < DATE(order_purchase_timestamp)
),

-- Check 5: Delivered but no carrier date (skipped logistics step)
delivered_without_carrier_date AS (
    SELECT
        'delivered_without_carrier_date' AS test_name,
        order_id,
        order_delivered_customer_date AS violation_date,
        'Order delivered (' || order_delivered_customer_date || 
        ') but no carrier delivery date recorded' AS violation_description
    FROM order_dates
    WHERE is_delivered = TRUE
      AND order_delivered_customer_date IS NOT NULL
      AND order_delivered_carrier_date IS NULL
),

-- Check 6: Approved date after delivery (retroactive approval?)
approved_after_delivery AS (
    SELECT
        'approved_after_delivery' AS test_name,
        order_id,
        DATE(order_approved_at) AS violation_date,
        'Order approved (' || DATE(order_approved_at) || 
        ') after delivery (' || order_delivered_customer_date || ')' AS violation_description
    FROM order_dates
    WHERE order_approved_at IS NOT NULL
      AND order_delivered_customer_date IS NOT NULL
      AND DATE(order_approved_at) > order_delivered_customer_date
),

-- Combine all violations
all_violations AS (
    SELECT * FROM delivered_before_ordered
    UNION ALL
    SELECT * FROM delivered_customer_before_carrier
    UNION ALL
    SELECT * FROM delivered_carrier_before_approval
    UNION ALL
    SELECT * FROM estimated_before_ordered
    UNION ALL
    SELECT * FROM delivered_without_carrier_date
    UNION ALL
    SELECT * FROM approved_after_delivery
)

-- Return all violations
SELECT
    test_name,
    order_id,
    violation_date,
    violation_description,
    '❌ Delivery date sequence violation' AS error_message
FROM all_violations
ORDER BY test_name, violation_date

-- If this test returns rows, investigate the data quality issues
-- Expected: 0-5 rows (minimal date inconsistencies in source data)