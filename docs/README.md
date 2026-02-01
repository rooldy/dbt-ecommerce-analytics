# 🛍️ DBT E-commerce Analytics

> A production-ready data analytics pipeline for e-commerce data using DBT and Snowflake

[![DBT Version](https://img.shields.io/badge/dbt-1.8.0-orange.svg)](https://www.getdbt.com/)
[![Snowflake](https://img.shields.io/badge/Snowflake-Standard-blue.svg)](https://www.snowflake.com/)
[![Tests](https://img.shields.io/badge/tests-234%20passing-brightgreen.svg)](/)
[![Coverage](https://img.shields.io/badge/coverage-97%25-brightgreen.svg)](/)

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Testing Strategy](#testing-strategy)
- [Performance Metrics](#performance-metrics)
- [Use Cases](#use-cases)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

This project implements a **modern data analytics pipeline** for analyzing e-commerce data from the Brazilian marketplace Olist. Built with **DBT (Data Build Tool)** and **Snowflake**, it demonstrates industry best practices for data transformation, modeling, and quality assurance.

### What This Project Demonstrates

✅ **Modern Data Stack**: DBT + Snowflake  
✅ **Medallion Architecture**: Bronze → Silver → Gold layers  
✅ **Dimensional Modeling**: Star Schema with fact and dimension tables  
✅ **Advanced Analytics**: CLV prediction, cohort analysis, RFM segmentation  
✅ **Data Quality**: 234 automated tests (97% coverage)  
✅ **Production-Ready**: Optimized for performance and cost efficiency

---

## ✨ Key Features

### 📊 Data Transformation
- **24 DBT models** organized in logical layers
- **Incremental models** for efficient updates
- **Surrogate keys** for SCD support
- **Complex business logic** (CLV, RFM, cohorts)

### 🧪 Data Quality
- **234 automated tests** (100% passing)
- **10 custom tests** for business logic validation
- **Cross-model consistency** checks
- **Data freshness monitoring**

### 💰 Analytics Capabilities
- **Customer Lifetime Value (CLV)** prediction
- **RFM segmentation** (Recency, Frequency, Monetary)
- **Cohort retention analysis**
- **Product performance rankings**
- **Delivery performance KPIs**

### ⚡ Performance & Cost
- Build time: **~3 minutes** for full refresh
- Snowflake cost: **<$3** for entire project
- Data processed: **~2.2M rows**
- Query optimization: **95%+ efficiency**

---

## 🏗️ Architecture

### Data Flow (Medallion Architecture)

```
📁 CSV Files (Kaggle Dataset)
    ↓
🥉 RAW (Bronze) - 9 source tables, 1.5M+ rows
    ↓
🥈 STAGING (Silver) - Data cleansing, standardization (9 models)
    ↓
🥈 INTERMEDIATE (Silver) - Business logic enrichment (3 models)
    ↓
🥇 MARTS_CORE (Gold) - Star Schema (2 facts + 5 dimensions)
    ↓
🥇 MARTS_ANALYTICS (Gold) - Pre-aggregated KPIs (6 models)
    ↓
📊 BI Dashboards (Metabase / Looker Studio)
```

### Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| **Data Warehouse** | Snowflake | Standard Edition |
| **Transformation** | DBT Core | 1.8.0 |
| **Language** | SQL | - |
| **Adapter** | dbt-snowflake | 1.8.0 |
| **Packages** | dbt_utils | 1.1.1 |
| **Version Control** | Git/GitHub | - |

---

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Snowflake account (free trial available)
- DBT Core 1.8.0+
- Git

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/rooldy/dbt-ecommerce-analytics.git
cd dbt-ecommerce-analytics

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Install DBT packages
cd dbt_ecommerce
dbt deps

# 5. Configure Snowflake connection
# Copy profiles.yml.example to ~/.dbt/profiles.yml
# Update with your Snowflake credentials

# 6. Test connection
dbt debug

# 7. Load raw data (one-time setup)
python ../scripts/load_data_snowflake.py

# 8. Build all models
dbt build

# 9. View documentation
dbt docs generate
dbt docs serve
```

### Running Tests

```bash
# Run all tests
dbt test

# Run specific test types
dbt test --select test_type:generic
dbt test --select test_type:singular

# Run tests for specific model
dbt test --select mart_customer_lifetime_value
```

---

## 📁 Project Structure

```
dbt-ecommerce-analytics/
├── data/raw/                      # CSV source files (1.5M rows)
├── dbt_ecommerce/                 # DBT project root
│   ├── models/
│   │   ├── staging/               # 9 staging models (views)
│   │   │   ├── _sources.yml       # Source definitions
│   │   │   ├── _staging.yml       # Model documentation + 55 tests
│   │   │   └── stg_*.sql          # Staging transformations
│   │   ├── intermediate/          # 3 intermediate models (views)
│   │   │   ├── _intermediate.yml  # Documentation + 63 tests
│   │   │   └── int_*.sql          # Business logic enrichment
│   │   └── marts/
│   │       ├── core/              # 6 core models (tables)
│   │       │   ├── _marts_core.yml    # Documentation + 67 tests
│   │       │   ├── fct_*.sql          # 2 fact tables
│   │       │   └── dim_*.sql          # 5 dimension tables
│   │       └── analytics/         # 6 analytics models (tables)
│   │           ├── _marts_analytics.yml   # Documentation + 39 tests
│   │           └── mart_*.sql             # Pre-aggregated KPIs
│   ├── tests/                     # Custom tests
│   │   └── singular/              # 10 custom SQL tests
│   ├── macros/                    # Reusable SQL macros
│   ├── dbt_project.yml            # DBT configuration
│   └── packages.yml               # DBT dependencies
├── docs/                          # Project documentation
├── scripts/                       # Utility scripts
├── requirements.txt               # Python dependencies
└── README.md                      # This file
```

---

## 📊 Data Models

### Source Data (9 Tables)

- `orders` - Order header information
- `order_items` - Line items for each order
- `customers` - Customer demographics
- `sellers` - Seller information
- `products` - Product catalog
- `payments` - Payment transactions
- `reviews` - Customer reviews
- `geolocation` - Geographic data
- `product_category_name_translation` - Category translations

### Staging Layer (9 Models)

Clean, standardized views of source data with:
- Renamed columns (snake_case)
- Type casting
- Basic deduplication
- Light transformations

### Intermediate Layer (3 Models)

Business logic enrichment:
- `int_orders_enriched` - Orders with payment, delivery, and review data
- `int_order_items_enriched` - Items with product and seller details
- `int_customer_orders` - Customer aggregations and RFM scores

### Marts Core - Star Schema (6 Models)

**Fact Tables:**
- `fct_orders` - Order transactions (99K rows)
- `fct_order_items` - Line item details (112K rows)

**Dimension Tables:**
- `dim_customers` - Customer master (96K rows)
- `dim_products` - Product catalog (33K rows)
- `dim_sellers` - Seller directory (3K rows)
- `dim_date` - Date dimension (1K rows)

### Marts Analytics (6 Models)

Pre-calculated business metrics:
- `mart_sales_daily` - Daily sales aggregations (incremental)
- `mart_customer_lifetime_value` - CLV predictions & RFM segments
- `mart_product_performance` - Product rankings & health scores
- `mart_delivery_kpis` - Logistics performance by route
- `mart_customer_cohorts` - Retention analysis by cohort
- `mart_sales_by_category` - Category performance trends

---

## 🧪 Testing Strategy

### Test Coverage: 97% (234 tests)

| Test Type | Count | Description |
|-----------|-------|-------------|
| **Generic Tests** | 224 | Built-in DBT tests |
| - unique | 36 | Primary key uniqueness |
| - not_null | 139 | Required columns |
| - relationships | 30 | Foreign key integrity |
| - accepted_values | 19 | Enum validation |
| **Custom Tests** | 10 | Business logic validation |

### Custom Tests (Singular)

1. **assert_revenue_consistency** - Cross-model revenue validation
2. **assert_no_future_dates** - Prevent future dates in data
3. **assert_reasonable_values** - Business range validation
4. **assert_clv_logic** - CLV prediction validation
5. **assert_cohort_retention** - Cohort analysis logic
6. **assert_delivery_dates** - Date sequence validation
7. **assert_rfm_segments** - RFM distribution monitoring
8. **assert_product_rankings** - Ranking consistency
9. **assert_model_freshness** - Data recency monitoring
10. **assert_null_rates** - NULL rate surveillance

---

## ⚡ Performance Metrics

### Build Performance

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| **Full build time** | 2-3 min | <5 min | ✅ Excellent |
| **Incremental refresh** | <30 sec | <1 min | ✅ Optimal |
| **Test execution** | ~10 sec | <30 sec | ✅ Fast |

### Cost Optimization

| Item | Actual | Budget | Efficiency |
|------|--------|--------|------------|
| **Snowflake compute** | $2.50 | $5.00 | 50% under budget |
| **Storage** | <$0.10 | $1.00 | Minimal |
| **Total project cost** | ~$3.00 | $400.00 | 99.25% savings |

### Data Quality

- **Test success rate**: 100% (234/234 passing)
- **Data freshness**: Historical dataset (2016-2018)
- **Model dependencies**: No circular dependencies
- **Build reproducibility**: 100%

---

## 💼 Use Cases

### 1. Executive Dashboard

```sql
-- Daily KPIs with trends
SELECT 
    full_date,
    revenue,
    orders,
    avg_order_value,
    revenue_7d_ma,
    on_time_delivery_rate
FROM marts_analytics.mart_sales_daily
WHERE full_date >= DATEADD(day, -30, CURRENT_DATE())
ORDER BY full_date DESC;
```

### 2. Customer Retention Analysis

```sql
-- Cohort retention heatmap
SELECT 
    cohort_label,
    months_since_cohort,
    retention_rate,
    cumulative_revenue_per_customer
FROM marts_analytics.mart_customer_cohorts
WHERE cohort_month >= '2017-01-01'
ORDER BY cohort_month, months_since_cohort;
```

### 3. High-Value Customer Targeting

```sql
-- VIP customers at risk of churning
SELECT 
    customer_id,
    customer_tier,
    historical_ltv,
    predicted_clv_12m,
    churn_risk,
    marketing_priority
FROM marts_analytics.mart_customer_lifetime_value
WHERE customer_tier IN ('VIP', 'Gold')
  AND churn_risk IN ('High', 'Very High')
ORDER BY predicted_clv_12m DESC;
```

### 4. Product Portfolio Optimization

```sql
-- Underperforming products
SELECT 
    category_name_en,
    product_id,
    revenue,
    product_health_score,
    product_recommendation
FROM marts_analytics.mart_product_performance
WHERE product_recommendation IN ('Consider Removal', 'Investigate Quality')
ORDER BY revenue DESC;
```

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`dbt test`)
5. Commit (`git commit -m 'Add amazing feature'`)
6. Push (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Dataset**: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Tools**: DBT Labs, Snowflake
- **Community**: DBT Community, Analytics Engineering Discord

---

## 📧 Contact

**Rooldy Alphonse**
- GitHub: [@rooldy](https://github.com/rooldy)
- LinkedIn: [linkedin.com/in/rooldy-alphonse](https://linkedin.com/in/rooldy-alphonse)
- Project Link: [github.com/rooldy/dbt-ecommerce-analytics](https://github.com/rooldy/dbt-ecommerce-analytics)

---

## 🗺️ Project Roadmap

- [x] Phase 0-1: Setup & Infrastructure
- [x] Phase 2: Staging Layer (9 models)
- [x] Phase 3: Intermediate Layer (3 models)
- [x] Phase 4: Marts Core - Star Schema (6 models)
- [x] Phase 5: Marts Analytics (6 models)
- [x] Phase 6: Quality & Testing (234 tests)
- [ ] Phase 7: Visualization & Dashboards
- [ ] Phase 8: Deployment & Production
- [ ] Phase 9: Maintenance & Experimentation

**Progress**: 72% complete (6.5/9 phases)

---

**⭐ If you find this project useful, please give it a star!**
