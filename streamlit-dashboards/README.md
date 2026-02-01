# 🛍️ E-commerce Analytics Dashboards

Interactive Streamlit dashboards powered by DBT-transformed data in Snowflake.

## 🎯 Overview

This project provides 6 comprehensive dashboards for e-commerce analytics:

1. **📊 Executive Summary** - Key business metrics at a glance
2. **💰 Sales Performance** - Revenue trends and analysis
3. **👥 Customer Analytics** - Segmentation, CLV, and behavior
4. **📦 Product Intelligence** - Product performance insights
5. **🔄 Cohort & Retention** - Customer retention analysis
6. **🎯 RFM Segmentation** - Marketing campaign optimization

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Snowflake account with DBT_ECOMMERCE database
- Access to analytics schema

### Installation

```bash
# 1. Clone the repository
cd streamlit-dashboards

# 2. Create virtual environment (optional but recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure Snowflake credentials
cp .env.example .env
# Edit .env with your Snowflake credentials

# 5. Run the app
streamlit run Home.py
```

### Configuration

Edit `.env` file with your Snowflake credentials:

```bash
SNOWFLAKE_ACCOUNT=your_account_identifier
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=DBT_ECOMMERCE
SNOWFLAKE_SCHEMA=ANALYTICS
SNOWFLAKE_ROLE=ACCOUNTADMIN
```

## 📊 Dashboards

### 1. Executive Summary
- **KPIs**: Revenue, Orders, AOV, Customers
- **Charts**: Revenue trend, Top categories, Geographic distribution
- **Insights**: Business health overview

### 2. Sales Performance
- **Analysis**: Time series, Payment methods, Delivery performance
- **Visuals**: Line charts, Bar charts, Geographic maps
- **Insights**: Sales patterns and trends

### 3. Customer Analytics
- **Features**: RFM segmentation, CLV prediction, Customer tiers
- **Visuals**: Scatter plots, Histograms, Distribution charts
- **Insights**: Customer behavior and value

### 4. Product Intelligence
- **Metrics**: Revenue by product, Category rankings, Health scores
- **Visuals**: Interactive tables, Bar charts, Tree maps
- **Insights**: Product portfolio optimization

### 5. Cohort & Retention
- **Analysis**: Cohort retention matrix, Retention curves
- **Visuals**: Heatmaps, Line charts, Comparison tables
- **Insights**: Customer lifetime value and retention

### 6. RFM Segmentation
- **Features**: Segment profiles, Campaign recommendations
- **Visuals**: Matrix views, Segment breakdowns
- **Insights**: Marketing campaign targeting

## 🏗️ Architecture

```
Streamlit Dashboards
├── Home.py                    # Landing page
├── pages/                     # Dashboard pages (auto-navigation)
│   ├── 1_📊_Executive_Summary.py
│   ├── 2_💰_Sales_Performance.py
│   ├── 3_👥_Customer_Analytics.py
│   ├── 4_📦_Product_Intelligence.py
│   ├── 5_🔄_Cohort_Retention.py
│   └── 6_🎯_RFM_Segmentation.py
└── utils/                     # Shared utilities
    ├── snowflake_connector.py # DB connection
    ├── data_loader.py         # Pre-defined queries
    ├── styling.py             # CSS and formatting
    ├── metrics.py             # KPI calculations
    └── charts.py              # Plotly helpers
```

## 🔧 Development

### Adding a New Dashboard

1. Create a new file in `pages/` with naming convention: `N_icon_Name.py`
2. Import utilities from `utils/`
3. Use `DataLoader` for queries
4. Apply `apply_custom_css()` for styling
5. Add to README navigation list

### Adding a New Query

1. Add static method to `DataLoader` class in `utils/data_loader.py`
2. Use `@st.cache_data(ttl=3600)` decorator
3. Return pandas DataFrame
4. Document the query purpose

### Customizing Styling

Edit `utils/styling.py`:
- Modify `COLORS` dictionary for color scheme
- Update `apply_custom_css()` for custom CSS
- Add new formatting functions as needed

## 📈 Performance

- **Caching**: All queries cached for 1 hour (3600s)
- **Connection Pooling**: Single Snowflake connection reused
- **Lazy Loading**: Data loaded only when needed
- **Optimized Queries**: Pre-aggregated marts for fast response

## 🚢 Deployment

### Streamlit Cloud (Recommended)

1. Push code to GitHub
2. Go to [share.streamlit.io](https://share.streamlit.io)
3. Connect your repository
4. Add secrets in Streamlit Cloud dashboard:
   - Settings → Secrets
   - Copy .env content to secrets

### Docker (Alternative)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8501
CMD ["streamlit", "run", "Home.py"]
```

## 🧪 Testing

```bash
# Test Snowflake connection
python -c "from utils.snowflake_connector import get_snowflake_connector; print(get_snowflake_connector().test_connection())"

# Test data loading
python -c "from utils.data_loader import DataLoader; print(DataLoader.get_kpi_summary())"

# Run app locally
streamlit run Home.py
```

## 📝 License

MIT License - feel free to use for your portfolio or projects

## 👨‍💻 Author

**Rooldy Alphonse**
- GitHub: [Your GitHub]
- LinkedIn: [Your LinkedIn]
- Portfolio: [Your Portfolio]

## 🙏 Acknowledgments

- Data: Brazilian E-commerce Public Dataset by Olist (Kaggle)
- Tools: DBT, Snowflake, Streamlit, Plotly
- Inspiration: Modern data analytics best practices

---

**Built with ❤️ using Streamlit | Data powered by Snowflake & DBT**