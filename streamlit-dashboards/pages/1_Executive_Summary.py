"""
Executive Summary Dashboard
Key business metrics and high-level insights
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import sys
import os

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.data_loader import DataLoader
from utils.styling import apply_custom_css, format_currency, format_number

# Page config
st.set_page_config(
    page_title="Executive Summary",
    page_icon="📊",
    layout="wide"
)

# Apply styling
apply_custom_css()

# Header
st.title("📊 Executive Summary")
st.markdown("Key business metrics and performance overview")

st.markdown("---")

# Date filter
col1, col2 = st.columns([3, 1])
with col2:
    date_range = st.selectbox(
        "Time Period",
        ["All Time", "Last 30 Days", "Last 90 Days", "Last 365 Days"],
        index=0
    )

# Calculate date filter
date_filter_start = None
date_filter_end = None

if date_range != "All Time":
    days = int(date_range.split()[1])
    date_filter_end = datetime.now().date()
    date_filter_start = date_filter_end - timedelta(days=days)

# Load data
try:
    # KPIs
    kpi_df = DataLoader.get_kpi_summary(date_filter_start, date_filter_end)
    
    # Revenue trend
    revenue_trend_df = DataLoader.get_revenue_trend('daily')
    
    # Top categories
    top_categories_df = DataLoader.get_top_categories(10)
    
    # Revenue by state
    revenue_by_state_df = DataLoader.get_revenue_by_state()
    
except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.stop()

# KPI Cards
st.subheader("Key Performance Indicators")

if not kpi_df.empty:
    col1, col2, col3, col4 = st.columns(4)
    
    revenue = kpi_df['TOTAL_REVENUE'].iloc[0]
    orders = kpi_df['TOTAL_ORDERS'].iloc[0]
    aov = kpi_df['AVG_ORDER_VALUE'].iloc[0]
    daily_revenue = kpi_df['AVG_DAILY_REVENUE'].iloc[0]
    
    with col1:
        st.metric(
            label="💰 Total Revenue",
            value=format_currency(revenue, 0),
            delta=None
        )
    
    with col2:
        st.metric(
            label="📦 Total Orders",
            value=format_number(orders, 0),
            delta=None
        )
    
    with col3:
        st.metric(
            label="💳 Average Order Value",
            value=format_currency(aov, 2),
            delta=None
        )
    
    with col4:
        st.metric(
            label="📊 Avg Daily Revenue",
            value=format_currency(daily_revenue, 0),
            delta=None
        )

st.markdown("---")

# Charts Row 1: Revenue Trend
st.subheader("Revenue Trend Over Time")

if not revenue_trend_df.empty:
    fig_revenue = px.line(
        revenue_trend_df,
        x='DATE',
        y='REVENUE',
        title='Daily Revenue',
        labels={'DATE': 'Date', 'REVENUE': 'Revenue ($)'}
    )
    
    fig_revenue.update_layout(
        height=400,
        hovermode='x unified',
        showlegend=False
    )
    
    fig_revenue.update_traces(
        line_color='#00D084',
        line_width=2
    )
    
    st.plotly_chart(fig_revenue, use_container_width=True)
else:
    st.warning("No revenue trend data available")

st.markdown("---")

# Charts Row 2: Categories and Geography
col1, col2 = st.columns(2)

with col1:
    st.subheader("Top 10 Product Categories")
    
    if not top_categories_df.empty:
        fig_categories = px.bar(
            top_categories_df,
            x='TOTAL_REVENUE',
            y='PRODUCT_CATEGORY',
            orientation='h',
            title='Revenue by Category',
            labels={'TOTAL_REVENUE': 'Revenue ($)', 'PRODUCT_CATEGORY': 'Category'}
        )
        
        fig_categories.update_layout(
            height=400,
            showlegend=False,
            yaxis={'categoryorder': 'total ascending'}
        )
        
        fig_categories.update_traces(
            marker_color='#0068C9'
        )
        
        st.plotly_chart(fig_categories, use_container_width=True)
    else:
        st.warning("No category data available")

with col2:
    st.subheader("Revenue by State (Top 10)")
    
    if not revenue_by_state_df.empty:
        top_states = revenue_by_state_df.nlargest(10, 'REVENUE')
        
        fig_states = px.bar(
            top_states,
            x='REVENUE',
            y='CUSTOMER_STATE',
            orientation='h',
            title='Revenue by State',
            labels={'REVENUE': 'Revenue ($)', 'CUSTOMER_STATE': 'State'}
        )
        
        fig_states.update_layout(
            height=400,
            showlegend=False,
            yaxis={'categoryorder': 'total ascending'}
        )
        
        fig_states.update_traces(
            marker_color='#FF4B4B'
        )
        
        st.plotly_chart(fig_states, use_container_width=True)
    else:
        st.warning("No state data available")

st.markdown("---")

# Summary Statistics Table
st.subheader("Summary Statistics")

col1, col2 = st.columns(2)

with col1:
    st.markdown("**Revenue Metrics**")
    if not kpi_df.empty:
        summary_data = {
            'Metric': [
                'Total Revenue',
                'Average Daily Revenue',
                'Total Orders',
                'Average Order Value'
            ],
            'Value': [
                format_currency(revenue, 0),
                format_currency(daily_revenue, 0),
                format_number(orders, 0),
                format_currency(aov, 2)
            ]
        }
        summary_df = pd.DataFrame(summary_data)
        st.dataframe(summary_df)

with col2:
    st.markdown("**Top Category Performance**")
    if not top_categories_df.empty:
        top_3 = top_categories_df.head(3)[['PRODUCT_CATEGORY', 'TOTAL_REVENUE', 'TOTAL_UNITS']]
        top_3.columns = ['Category', 'Revenue', 'Units Sold']
        top_3['Revenue'] = top_3['Revenue'].apply(lambda x: format_currency(x, 0))
        top_3['Units Sold'] = top_3['Units Sold'].apply(lambda x: format_number(x, 0))
        st.dataframe(top_3)

st.markdown("---")

# Insights Section
st.subheader("Key Insights")

col1, col2, col3 = st.columns(3)

with col1:
    st.info("""
    **Revenue Performance**
    
    Total revenue shows strong performance across all product categories.
    Daily average indicates consistent sales activity.
    """)

with col2:
    st.success("""
    **Order Volume**
    
    High order volume indicates strong customer engagement.
    AOV suggests healthy basket sizes.
    """)

with col3:
    st.warning("""
    **Geographic Distribution**
    
    Revenue concentrated in top states.
    Opportunity for expansion in underperforming regions.
    """)

# Footer
st.markdown("---")
st.caption("Data refreshed from Snowflake | Last update: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))