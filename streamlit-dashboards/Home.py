"""
E-commerce Analytics Dashboard - Home Page
Landing page with navigation and overview
"""

import streamlit as st
from utils.snowflake_connector import get_snowflake_connector
from utils.styling import apply_custom_css, add_footer
from utils.data_loader import DataLoader

# Page config
st.set_page_config(
    page_title="E-commerce Analytics Dashboard",
    page_icon="🛍️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Apply custom styling
apply_custom_css()

# Sidebar
st.sidebar.markdown("# 🛍️ E-commerce Analytics")
st.sidebar.markdown("---")

# Test connection
with st.sidebar:
    with st.spinner("Connecting to Snowflake..."):
        connector = get_snowflake_connector()
        if connector.test_connection():
            st.success("✅ Connected to Snowflake")
            
            # Show available tables
            with st.expander("📊 Available Data"):
                tables = connector.get_available_tables()
                if tables:
                    for table in tables:
                        st.text(f"• {table}")
                else:
                    st.warning("No tables found")
        else:
            st.error("❌ Failed to connect to Snowflake")
            st.info("Please check your .env file configuration")
            st.stop()

st.sidebar.markdown("---")
st.sidebar.markdown("""
### 📍 Navigation
Use the sidebar to navigate between dashboards:

1. 📊 **Executive Summary**  
   Key business metrics at a glance

2. 💰 **Sales Performance**  
   Revenue trends and analysis

3. 👥 **Customer Analytics**  
   Segmentation, CLV, and RFM

4. 📦 **Product Intelligence**  
   Product performance insights

5. 🔄 **Cohort & Retention**  
   Customer retention analysis

6. 🎯 **RFM Segmentation**  
   Marketing campaign insights
""")

# Main content
st.title("🛍️ E-commerce Analytics Dashboard")

st.markdown("""
Welcome to the **E-commerce Analytics Dashboard** powered by **DBT**, **Snowflake**, and **Streamlit**.

This dashboard provides comprehensive insights into:
- 💰 Sales performance and trends
- 👥 Customer behavior and segmentation
- 📦 Product performance metrics
- 🔄 Customer retention and cohorts
- 🎯 Marketing campaign optimization
""")

st.markdown("---")

# Quick Stats
st.header("📈 Quick Overview")

try:
    # Load date range
    date_range_df = DataLoader.get_date_range()
    if not date_range_df.empty:
        min_date = date_range_df['MIN_DATE'].iloc[0]
        max_date = date_range_df['MAX_DATE'].iloc[0]
        
        st.info(f"📅 Data available from **{min_date}** to **{max_date}**")
    
    # Load KPIs
    kpi_df = DataLoader.get_kpi_summary()
    
    if not kpi_df.empty:
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            revenue = kpi_df['TOTAL_REVENUE'].iloc[0]
            st.metric(
                label="💰 Total Revenue",
                value=f"${revenue/1_000_000:.1f}M"
            )
        
        with col2:
            orders = kpi_df['TOTAL_ORDERS'].iloc[0]
            st.metric(
                label="📦 Total Orders",
                value=f"{orders:,.0f}"
            )
        
        with col3:
            aov = kpi_df['AVG_ORDER_VALUE'].iloc[0]
            st.metric(
                label="💳 Average Order Value",
                value=f"${aov:.2f}"
            )
        
        with col4:
            daily_revenue = kpi_df['AVG_DAILY_REVENUE'].iloc[0]
            st.metric(
                label="📊 Avg Daily Revenue",
                value=f"${daily_revenue:,.0f}"
            )
    
    # Row counts
    st.markdown("---")
    st.subheader("📊 Data Warehouse Overview")
    
    row_counts_df = DataLoader.get_row_counts()
    if not row_counts_df.empty:
        col1, col2 = st.columns([2, 1])
        
        with col1:
            st.dataframe(
                row_counts_df
            )
        
        with col2:
            total_rows = row_counts_df['ROW_COUNT'].sum()
            st.metric(
                label="Total Rows",
                value=f"{total_rows:,.0f}"
            )

except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.info("Please check your Snowflake connection and data availability")

st.markdown("---")

# Architecture info
with st.expander("🏗️ Architecture & Technology Stack"):
    st.markdown("""
    ### Data Pipeline
    ```
    Raw Data (Kaggle) → Snowflake → DBT Transformations → Analytics Marts → Streamlit Dashboards
    ```
    
    ### Technology Stack
    - **Database**: Snowflake
    - **Transformation**: DBT (Data Build Tool)
    - **Visualization**: Streamlit + Plotly
    - **Language**: Python 3.11
    
    ### Data Models
    - **Staging**: Raw data cleaning and standardization
    - **Intermediate**: Business logic and calculations
    - **Marts**: Final analytical models optimized for BI
    
    ### Key Features
    ✅ 97% test coverage  
    ✅ Automated data quality checks  
    ✅ Real-time data refresh  
    ✅ Interactive visualizations  
    ✅ Drill-down capabilities  
    """)

# Footer
add_footer()

st.markdown("---")
st.caption("💡 **Tip**: Use the sidebar to navigate to specific dashboards")