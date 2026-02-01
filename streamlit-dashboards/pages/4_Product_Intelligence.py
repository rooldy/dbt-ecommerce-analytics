"""
Product Intelligence Dashboard
Product performance insights and category analysis
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.data_loader import DataLoader
from utils.styling import apply_custom_css, format_currency, format_number, format_percentage

st.set_page_config(
    page_title="Product Intelligence",
    page_icon="📦",
    layout="wide"
)

apply_custom_css()

st.title("📦 Product Intelligence")
st.markdown("Product performance insights and category analysis")

st.markdown("---")

# Filters
try:
    product_df = DataLoader.get_product_performance(100)
    category_df = DataLoader.get_category_rankings()
except Exception as e:
    st.error(f"Error: {str(e)}")
    st.stop()

col1, col2 = st.columns([3, 1])

with col2:
    categories = ["All"] + sorted(product_df['CATEGORY_NAME_EN'].unique().tolist())
    category_filter = st.selectbox(
        "Filter by Category",
        categories,
        index=0
    )

# Appliquer le filtre
if category_filter != "All":
    product_df = product_df[product_df['CATEGORY_NAME_EN'] == category_filter]

st.markdown("---")

# KPI Cards
st.subheader("Revenue by Category")

# Calculez des métriques
if not product_df.empty:
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_products = len(product_df)
        st.metric("Total Products", format_number(total_products, 0))
    
    with col2:
        total_revenue = product_df['REVENUE'].sum()
        st.metric("Total Revenue", format_currency(total_revenue, 0))
    
    with col3:
        avg_rating = product_df['AVG_RATING'].mean()
        st.metric("Avg Rating", f"{avg_rating:.2f} / 5")
    
    with col4:
        total_units = product_df['UNITS_SOLD'].sum()
        st.metric("Total Units Sold", format_number(total_units, 0))

st.markdown("---")

st.subheader("Revenue by Category")

if not product_df.empty:
    category_revenue = product_df.groupby('CATEGORY_NAME_EN').agg({
        'REVENUE': 'sum'
    }).reset_index().sort_values('REVENUE', ascending=False)
    
    fig = px.bar(
        category_revenue,
        x='CATEGORY_NAME_EN',
        y='REVENUE',
        title='Category Performance'
    )
    
    st.plotly_chart(fig, use_container_width=True)

st.subheader("Price vs Units Sold")

if not product_df.empty:
    fig = px.scatter(
        product_df.head(50),  # Top 50 seulement
        x='AVG_PRICE',
        y='UNITS_SOLD',
        color='CATEGORY_NAME_EN',
        size='REVENUE',
        hover_data=['PRODUCT_ID', 'AVG_RATING']
    )
    
    st.plotly_chart(fig, use_container_width=True)

st.subheader("Product Health Score Distribution")

if not product_df.empty:
    fig = px.histogram(
        product_df,
        x='PRODUCT_HEALTH_SCORE',
        nbins=20,
        title='Health Score Distribution'
    )
    
    st.plotly_chart(fig, use_container_width=True)

st.subheader("Customer Satisfaction")

if not product_df.empty:
    avg_satisfaction = product_df['SATISFACTION_RATE'].mean()
    
    fig = go.Figure(go.Indicator(
        mode="gauge+number",
        value=avg_satisfaction,
        title={'text': "Avg Satisfaction Rate (%)"},
        gauge={
            'axis': {'range': [0, 100]},
            'bar': {'color': "#00D084"}
        }
    ))
    
    st.plotly_chart(fig, use_container_width=True)

st.subheader("Top 50 Products")

if not product_df.empty:
    table_df = product_df.head(50)[[
        'PRODUCT_ID', 
        'CATEGORY_NAME_EN', 
        'REVENUE', 
        'UNITS_SOLD',
        'AVG_PRICE',
        'AVG_RATING',
        'PRODUCT_HEALTH_SCORE'
    ]].copy()
    
    # Formatez les colonnes
    table_df['REVENUE'] = table_df['REVENUE'].apply(lambda x: format_currency(x, 0))
    table_df['AVG_PRICE'] = table_df['AVG_PRICE'].apply(lambda x: format_currency(x, 2))
    
    table_df.columns = ['Product ID', 'Category', 'Revenue', 'Units', 'Avg Price', 'Rating', 'Health Score']
    
    st.dataframe(table_df)

st.subheader("Key Insights")

col1, col2, col3 = st.columns(3)

with col1:
    # Best seller
    if not product_df.empty:
        best_seller = product_df.nlargest(1, 'REVENUE').iloc[0]
        st.success(f"""
        **Best Seller**
        
        Category: {best_seller['CATEGORY_NAME_EN']}
        Revenue: {format_currency(best_seller['REVENUE'], 0)}
        """)

with col2:
    # Highest rated
    if not product_df.empty:
        top_rated = product_df.nlargest(1, 'AVG_RATING').iloc[0]
        st.info(f"""
        **Highest Rated**
        
        Rating: {top_rated['AVG_RATING']:.2f} / 5
        Reviews: {top_rated['REVIEW_COUNT']:.0f}
        """)

with col3:
    # At-risk products
    if not product_df.empty:
        at_risk_count = len(product_df[product_df['PRODUCT_HEALTH_SCORE'] < 50])
        st.warning(f"""
        **At-Risk Products**
        
        {at_risk_count} products with health score < 50
        Review and optimize
        """)

st.markdown("---")
st.caption("Last update: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
