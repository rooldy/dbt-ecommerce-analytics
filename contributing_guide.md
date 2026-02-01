# Contributing to DBT E-commerce Analytics

Thank you for your interest in contributing to this project! 🎉

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment details (DBT version, Snowflake version, etc.)

### Suggesting Enhancements

For feature requests:
- Describe the feature clearly
- Explain the business value
- Provide examples if possible

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes** following our coding standards
4. **Add tests** for new functionality
5. **Run all tests**: `dbt test`
6. **Update documentation** if needed
7. **Commit** with clear messages
8. **Push** to your fork
9. **Open a Pull Request** with a clear description

---

## 📋 Development Guidelines

### DBT Model Standards

#### File Naming
- **Staging**: `stg_<source>_<entity>.sql`
- **Intermediate**: `int_<entity>_<description>.sql`
- **Marts**: `fct_<entity>.sql` or `dim_<entity>.sql`
- **Analytics**: `mart_<business_concept>.sql`

#### Model Configuration
```yaml
# Always include:
models:
  - name: model_name
    description: Clear description of what this model does
    columns:
      - name: column_name
        description: What this column represents
        tests:
          - not_null  # When appropriate
          - unique    # For primary keys
```

#### SQL Style Guide
```sql
-- Use CTEs for clarity
WITH base_data AS (
    SELECT
        column_1,
        column_2,
        column_3
    FROM {{ ref('source_model') }}
),

transformed AS (
    SELECT
        column_1,
        UPPER(column_2) AS column_2_clean,
        column_3 * 1.1 AS column_3_adjusted
    FROM base_data
)

SELECT * FROM transformed
```

**Style Rules:**
- Use 4 spaces for indentation (no tabs)
- One column per line in SELECT
- Commas at start of line (leading commas)
- Use lowercase for SQL keywords
- Use meaningful CTE names
- Add comments for complex logic

### Testing Standards

#### Every new model should have:
1. **Primary key test** (`unique` + `not_null`)
2. **Foreign key tests** (`relationships`)
3. **Business logic tests** (custom tests when needed)

#### Test Coverage Target: >95%

#### Example Test Documentation:
```yaml
models:
  - name: fct_orders
    columns:
      - name: order_key
        description: Surrogate key for orders
        tests:
          - unique
          - not_null
      - name: customer_key
        description: Foreign key to dim_customers
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_key
```

### Custom Test Guidelines

Custom tests should:
- Have clear, descriptive names
- Include documentation at the top
- Return 0 rows on success
- Be performant (<10 seconds)

```sql
-- Test: Description of what this validates
-- Expected: 0 rows (all data passes validation)

WITH validation AS (
    SELECT
        id,
        column_to_test,
        'Error message' AS error_description
    FROM {{ ref('model_name') }}
    WHERE column_to_test FAILS_CONDITION
)

SELECT * FROM validation
```

---

## 🔄 Git Workflow

### Branch Naming
- **Feature**: `feature/descriptive-name`
- **Bug fix**: `bugfix/issue-description`
- **Hotfix**: `hotfix/critical-issue`
- **Docs**: `docs/what-you-documented`

### Commit Messages
Use conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

**Examples:**
```
feat(marts): Add customer segmentation model

- Implemented RFM analysis
- Added CLV prediction logic
- Created 15 new tests

Closes #42
```

```
fix(staging): Correct date parsing in stg_orders

The order_date was being parsed incorrectly for dates
before 2017. Updated the CAST logic to handle edge cases.

Fixes #38
```

---

## 🧪 Running Tests Locally

### Before Submitting PR

```bash
# 1. Install dependencies
dbt deps

# 2. Run all models
dbt run

# 3. Run all tests
dbt test

# 4. Generate documentation
dbt docs generate

# 5. Check for lint issues (if using sqlfluff)
sqlfluff lint models/
```

### Test Individual Changes

```bash
# Test specific model and its dependencies
dbt test --select model_name+

# Test specific model and its children
dbt test --select +model_name

# Test only custom tests
dbt test --select test_type:singular
```

---

## 📚 Documentation Standards

### Model Documentation

Every model should have:
1. **Description**: What the model does
2. **Column descriptions**: What each column represents
3. **Tests**: Data quality checks
4. **Meta information**: Owner, update frequency, etc.

```yaml
models:
  - name: fct_orders
    description: |
      Order fact table containing one row per order.
      Includes payment, delivery, and review information.
      
      **Grain**: One row per order
      **Update frequency**: Daily
      **Owner**: Analytics Team
    
    columns:
      - name: order_key
        description: Surrogate key for the order (SHA-256 hash of order_id)
        tests:
          - unique
          - not_null
```

### Inline Comments

Use comments for:
- Complex business logic
- Non-obvious transformations
- References to business rules
- Temporary workarounds (with JIRA ticket)

```sql
-- Calculate customer lifetime value using simplified model
-- Business rule: Active customers extrapolate current behavior over 12 months
-- Reference: https://docs.company.com/clv-methodology
CASE 
    WHEN customer_status = 'Active' THEN
        avg_order_value * (orders_per_month * 12)
    ...
END AS predicted_clv_12m
```

---

## 🚀 Performance Guidelines

### Query Optimization

1. **Use incremental models** for large, time-series data
2. **Limit CTEs** to 5-6 levels max
3. **Avoid SELECT *** in production models
4. **Use clustering keys** for large tables
5. **Filter early** in CTEs

### Example Incremental Model:
```sql
{{
    config(
        materialized='incremental',
        unique_key='date_key',
        cluster_by=['date_key']
    )
}}

SELECT * FROM source_data
{% if is_incremental() %}
    WHERE date_key > (SELECT MAX(date_key) FROM {{ this }})
{% endif %}
```

### Snowflake Optimization

- Use `LIMIT` in development: `dbt run --vars '{dev_limit: 1000}'`
- Avoid DISTINCT when possible (use GROUP BY)
- Use appropriate data types (INT vs BIGINT)
- Cluster large tables (>10M rows)

---

## 🐛 Debugging Tips

### Common Issues

**Issue**: Model fails to build
```bash
# Check compiled SQL
dbt compile --select model_name
cat target/compiled/dbt_ecommerce/models/path/to/model.sql
```

**Issue**: Tests failing
```bash
# Store test failures for inspection
dbt test --select test_name --store-failures

# Query failures in Snowflake
SELECT * FROM dbt_test__audit.test_name
```

**Issue**: Slow performance
```bash
# Check query profile in Snowflake
# Look for:
# - Full table scans
# - Large result sets
# - Missing filters
```

---

## 📧 Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Open a GitHub Issue
- **Security**: Email rooldy.alphonse@example.com
- **Chat**: Join our Slack/Discord (link in README)

---

## 🏆 Recognition

Contributors will be:
- Added to CONTRIBUTORS.md
- Mentioned in release notes
- Given credit in documentation

Thank you for helping improve this project! 🙏

---

## 📝 License

By contributing, you agree that your contributions will be licensed under the MIT License.
