# DBT E-commerce Analytics - Usage Guide

Complete guide for using and extending this project.

---

## 📚 Table of Contents

- [Quick Start](#quick-start)
- [Running DBT Commands](#running-dbt-commands)
- [Querying the Data](#querying-the-data)
- [Adding New Models](#adding-new-models)
- [Creating Tests](#creating-tests)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## 🚀 Quick Start

### Initial Setup (One-time)

```bash
# 1. Clone and setup environment
git clone https://github.com/rooldy/dbt-ecommerce-analytics.git
cd dbt-ecommerce-analytics
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt
cd dbt_ecommerce
dbt deps

# 3. Configure Snowflake connection
# Copy profiles.yml.example to ~/.dbt/profiles.yml
# Update with your credentials

# 4. Test connection
dbt debug

# 5. Load raw data
cd ..
python scripts/load_data_snowflake.py

# 6. Build all models
cd dbt_ecommerce
dbt build
```

---

## 🎯 Running DBT Commands

### Building Models

```bash
# Build all models
dbt run

# Build specific model
dbt run --select fct_orders

# Build model and its dependencies
dbt run --select +fct_orders

# Build model and its children
dbt run --select fct_orders+

# Build specific layer
dbt run --select staging
dbt run --select intermediate
dbt run --select marts.core
dbt run --select marts.analytics

# Build with full refresh (for incremental models)
dbt run --select mart_sales_daily --full-refresh
```

### Testing

```bash
# Run all tests
dbt test

# Test specific model
dbt test --select fct_orders

# Test specific type
dbt test --select test_type:generic
dbt test --select test_type:singular

# Test and store failures
dbt test --store-failures

# View test failures in Snowflake
SELECT * FROM dbt_test__audit.test_name;
```

### Documentation

```bash
# Generate documentation
dbt docs generate

# Serve documentation locally
dbt docs serve --port 8080

# Open in browser: http://localhost:8080
```

### Complete Workflow

```bash
# Full build with tests and docs
dbt build

# This runs:
# 1. dbt run (build models)
# 2. dbt test (run tests)
# 3. dbt snapshot (if snapshots exist)
```

---

## 📊 Querying the Data

### Connect to Snowflake

```sql
USE DATABASE DBT_ECOMMERCE;
USE SCHEMA MARTS_ANALYTICS;
USE WAREHOUSE COMPUTE_WH;
```

### Common Queries

#### 1. Daily Sales Performance

```sql
-- Last 30 days of sales with trends
SELECT 
    full_date,
    revenue,
    orders,
    avg_order_value,
    revenue_7d_ma AS revenue_trend,
    unique_customers,
    on_time_delivery_rate
FROM mart_sales_daily
WHERE full_date >= DATEADD(day, -30, CURRENT_DATE())
ORDER BY full_date DESC;
```

#### 2. Customer Segmentation

```sql
-- Customer distribution by tier and status
SELECT 
    customer_tier,
    customer_status,
    COUNT(*) AS customers,
    ROUND(AVG(historical_ltv), 2) AS avg_ltv,
    ROUND(AVG(predicted_clv_12m), 2) AS avg_predicted_clv,
    ROUND(SUM(predicted_clv_12m), 2) AS total_predicted_value
FROM mart_customer_lifetime_value
GROUP BY customer_tier, customer_status
ORDER BY customer_tier, customer_status;
```

#### 3. Top Products by Category

```sql
-- Best performing products in each category
SELECT 
    category_name_en,
    product_id,
    revenue,
    units_sold,
    avg_rating,
    product_health_score,
    rank_in_category_revenue
FROM mart_product_performance
WHERE rank_in_category_revenue <= 5
ORDER BY category_name_en, rank_in_category_revenue;
```

#### 4. Cohort Retention Analysis

```sql
-- Monthly cohort retention heatmap
SELECT 
    cohort_label,
    months_since_cohort,
    cohort_size,
    active_customers,
    retention_rate,
    cumulative_revenue_per_customer
FROM mart_customer_cohorts
WHERE cohort_month >= '2017-01-01'
ORDER BY cohort_month, months_since_cohort;
```

#### 5. High-Value Customers at Risk

```sql
-- VIP/Gold customers with high churn risk
SELECT 
    customer_id,
    customer_tier,
    customer_status,
    historical_ltv,
    predicted_clv_12m,
    churn_risk,
    marketing_priority,
    recency AS days_since_last_order,
    frequency AS total_orders
FROM mart_customer_lifetime_value
WHERE customer_tier IN ('VIP', 'Gold')
  AND churn_risk IN ('High', 'Very High')
ORDER BY predicted_clv_12m DESC
LIMIT 100;
```

#### 6. Delivery Performance by Route

```sql
-- Worst performing delivery routes
SELECT 
    customer_state,
    seller_region,
    total_deliveries,
    on_time_rate,
    avg_delivery_days,
    performance_tier,
    primary_issue,
    recommendation
FROM mart_delivery_kpis
WHERE performance_tier = 'Needs Improvement'
ORDER BY total_deliveries DESC
LIMIT 20;
```

---

## ➕ Adding New Models

### 1. Create SQL File

```sql
-- models/marts/analytics/mart_my_analysis.sql
{{
    config(
        materialized='table',
        tags=['marts', 'analytics', 'my_tag']
    )
}}

WITH base_data AS (
    SELECT * FROM {{ ref('fct_orders') }}
),

calculations AS (
    SELECT
        customer_id,
        COUNT(*) AS metric_count,
        SUM(order_value) AS metric_sum
    FROM base_data
    GROUP BY customer_id
)

SELECT * FROM calculations
```

### 2. Add Documentation

```yaml
# models/marts/analytics/_marts_analytics.yml
models:
  - name: mart_my_analysis
    description: |
      Description of what this model does.
      
      **Grain**: One row per X
      **Update frequency**: Daily/Weekly/Monthly
    
    columns:
      - name: customer_id
        description: Unique customer identifier
        tests:
          - not_null
          - unique
      
      - name: metric_count
        description: Count of something
        tests:
          - not_null
```

### 3. Build and Test

```bash
# Build new model
dbt run --select mart_my_analysis

# Test it
dbt test --select mart_my_analysis

# View in docs
dbt docs generate
dbt docs serve
```

---

## 🧪 Creating Tests

### Generic Tests (in YAML)

```yaml
models:
  - name: my_model
    columns:
      - name: id
        tests:
          - unique
          - not_null
      
      - name: status
        tests:
          - accepted_values:
              values: ['active', 'inactive', 'pending']
      
      - name: customer_id
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_id
```

### Custom Tests (SQL)

```sql
-- tests/singular/my_custom_test.sql
-- Test: Description of what this validates
-- Expected: 0 rows

WITH validation AS (
    SELECT
        id,
        problematic_column,
        'Error description' AS error_message
    FROM {{ ref('my_model') }}
    WHERE problematic_column IS INVALID
)

SELECT * FROM validation
```

### Run Tests

```bash
# All tests
dbt test

# Specific test
dbt test --select my_custom_test

# Store failures for investigation
dbt test --store-failures
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Connection Issues

```bash
# Test connection
dbt debug

# Check profiles.yml
cat ~/.dbt/profiles.yml

# Verify Snowflake credentials
```

#### 2. Model Build Failures

```bash
# View compiled SQL
dbt compile --select model_name
cat target/compiled/dbt_ecommerce/models/path/to/model.sql

# Run in Snowflake to see exact error
```

#### 3. Test Failures

```bash
# Store failures
dbt test --select test_name --store-failures

# View in Snowflake
USE SCHEMA dbt_test__audit;
SELECT * FROM test_name;

# Investigate data
SELECT * FROM model_name 
WHERE [problematic condition];
```

#### 4. Performance Issues

```bash
# Check query profile in Snowflake UI
# Look for:
# - Full table scans
# - Large result sets
# - Missing filters
# - Inefficient joins

# Optimize by:
# - Adding filters early in CTEs
# - Using incremental models
# - Adding clustering keys
# - Reducing CTE complexity
```

#### 5. Dependency Errors

```bash
# View dependency graph
dbt docs generate
dbt docs serve
# Navigate to DAG view

# Or use CLI
dbt ls --select +model_name  # Upstream dependencies
dbt ls --select model_name+  # Downstream dependencies
```

---

## 💡 Best Practices

### Model Development

1. **Start with a plan**
   - Define grain clearly
   - Sketch out logic before coding
   - Consider downstream use cases

2. **Follow naming conventions**
   - `stg_` for staging
   - `int_` for intermediate
   - `fct_` for facts
   - `dim_` for dimensions
   - `mart_` for analytics

3. **Use CTEs for clarity**
   - One concept per CTE
   - Meaningful CTE names
   - Limit to 5-6 levels

4. **Test as you go**
   - Add tests for each model
   - Run tests frequently
   - Fix issues immediately

### Testing Strategy

1. **Every model needs tests**
   - Primary key: `unique` + `not_null`
   - Foreign keys: `relationships`
   - Business rules: custom tests

2. **Use appropriate severity**
   - `ERROR`: Critical data quality issues
   - `WARN`: Monitoring, don't block builds

3. **Document test purpose**
   - What is being validated
   - Why it matters
   - Expected behavior

### Performance Optimization

1. **Use incremental models for large tables**
   ```sql
   {{
       config(
           materialized='incremental',
           unique_key='date_key'
       )
   }}
   ```

2. **Filter early in CTEs**
   ```sql
   WITH filtered_data AS (
       SELECT *
       FROM large_table
       WHERE date >= '2024-01-01'  -- Filter first
   )
   ```

3. **Avoid SELECT * in production**
   ```sql
   -- Instead of SELECT *
   SELECT
       column_1,
       column_2,
       column_3
   FROM table
   ```

### Git Workflow

1. **Commit often**
   ```bash
   git add models/marts/analytics/new_model.sql
   git commit -m "feat(marts): Add new analysis model"
   ```

2. **Use branches for features**
   ```bash
   git checkout -b feature/my-feature
   # Make changes
   git push origin feature/my-feature
   # Open PR
   ```

3. **Keep commits clean**
   - One logical change per commit
   - Clear commit messages
   - Test before committing

---

## 📚 Additional Resources

### Documentation
- [DBT Docs](https://docs.getdbt.com/)
- [Snowflake Docs](https://docs.snowflake.com/)
- [Project README](README.md)
- [Contributing Guide](CONTRIBUTING.md)

### Getting Help
- **Issues**: [GitHub Issues](https://github.com/rooldy/dbt-ecommerce-analytics/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rooldy/dbt-ecommerce-analytics/discussions)
- **Email**: rooldy.alphonse@example.com

---

## ✅ Quick Reference

### Essential Commands

```bash
# Development workflow
dbt run --select model_name     # Build one model
dbt test --select model_name    # Test one model
dbt build --select model_name   # Build + test

# Full project
dbt build                       # Build + test everything
dbt docs generate && dbt docs serve  # View docs

# Cleanup
dbt clean                       # Remove target/ directory
dbt deps                        # Install packages

# Debugging
dbt debug                       # Test connection
dbt compile --select model_name # View compiled SQL
dbt ls                          # List all resources
```

### Useful Flags

```bash
--select model_name       # Select specific model
--exclude model_name      # Exclude specific model
--full-refresh           # Rebuild incremental models
--store-failures         # Store test failures
--fail-fast              # Stop on first error
--threads 8              # Parallel execution
```

---

**Happy analyzing! 🚀**
