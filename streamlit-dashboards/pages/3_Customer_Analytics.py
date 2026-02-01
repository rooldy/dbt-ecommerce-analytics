"""
Customer Analytics Dashboard
Customer segmentation, CLV analysis, and behavioral insights
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
    page_title="Customer Analytics",
    page_icon="👥",
    layout="wide"
)

apply_custom_css()

st.title("👥 Customer Analytics")
st.markdown("Customer segmentation, lifetime value analysis, and behavioral insights")

st.markdown("---")

# Filters
col1, col2 = st.columns([3, 1])

with col2:
    customer_tier_filter = st.selectbox(
        "Filter by Tier",
        ["All", "VIP", "High", "Medium", "Low"],
        index=0
    )

st.markdown("---")

# Load data
try:
    customer_df = DataLoader.get_customer_summary()
    rfm_df = DataLoader.get_rfm_distribution()
    clv_df = DataLoader.get_clv_analysis()
    
    # Apply filter if needed
    if customer_tier_filter != "All":
        customer_df_filtered = customer_df[customer_df['CUSTOMER_TIER'] == customer_tier_filter]
    else:
        customer_df_filtered = customer_df
    
except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.stop()

# KPI Cards
st.subheader("Customer Overview")

if not customer_df_filtered.empty:
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_customers = len(customer_df_filtered)
        st.metric("Total Customers", format_number(total_customers, 0))
    
    with col2:
        avg_ltv = customer_df_filtered['HISTORICAL_LTV'].mean()
        st.metric("Avg Customer LTV", format_currency(avg_ltv, 2))
    
    with col3:
        vip_count = customer_df_filtered['IS_VIP'].sum()
        vip_pct = (vip_count / len(customer_df_filtered)) * 100 if len(customer_df_filtered) > 0 else 0
        st.metric("VIP Customers", f"{format_number(vip_count, 0)} ({vip_pct:.1f}%)")
    
    with col4:
        active_count = customer_df_filtered['IS_ACTIVE'].sum()
        active_pct = (active_count / len(customer_df_filtered)) * 100 if len(customer_df_filtered) > 0 else 0
        st.metric("Active Customers", f"{format_number(active_count, 0)} ({active_pct:.1f}%)")

st.markdown("---")

# Customer Tier & Status Distribution
col1, col2 = st.columns(2)

with col1:
    st.subheader("Customer Tier Distribution")
    
    if not rfm_df.empty:
        tier_df = rfm_df.groupby('CUSTOMER_TIER').agg({
            'CUSTOMER_COUNT': 'sum'
        }).reset_index()
        
        fig_tier = px.pie(
            tier_df,
            values='CUSTOMER_COUNT',
            names='CUSTOMER_TIER',
            title='Customers by Tier',
            hole=0.4,
            color='CUSTOMER_TIER',
            color_discrete_map={
                'VIP': '#FFD700',
                'High': '#00D084',
                'Medium': '#0068C9',
                'Low': '#808080'
            }
        )
        fig_tier.update_layout(height=400)
        fig_tier.update_traces(textposition='inside', textinfo='percent+label')
        st.plotly_chart(fig_tier, use_container_width=True)
    else:
        st.warning("No tier data available")

with col2:
    st.subheader("Customer Status Distribution")
    
    if not rfm_df.empty:
        status_df = rfm_df.groupby('CUSTOMER_STATUS').agg({
            'CUSTOMER_COUNT': 'sum',
            'TOTAL_LTV': 'sum'
        }).reset_index()
        
        fig_status = px.bar(
            status_df,
            x='CUSTOMER_STATUS',
            y='CUSTOMER_COUNT',
            title='Customers by Status',
            labels={'CUSTOMER_COUNT': 'Number of Customers', 'CUSTOMER_STATUS': 'Status'},
            color='CUSTOMER_STATUS',
            color_discrete_map={
                'Active': '#00D084',
                'At Risk': '#FFA500',
                'Lost': '#FF4B4B'
            }
        )
        fig_status.update_layout(height=400, showlegend=False)
        st.plotly_chart(fig_status, use_container_width=True)
    else:
        st.warning("No status data available")

st.markdown("---")

# CLV Analysis
st.subheader("Customer Lifetime Value Analysis")

col1, col2 = st.columns(2)

with col1:
    st.markdown("**CLV Distribution**")
    
    if not customer_df_filtered.empty:
        fig_clv_hist = px.histogram(
            customer_df_filtered,
            x='HISTORICAL_LTV',
            nbins=50,
            title='Customer LTV Distribution',
            labels={'HISTORICAL_LTV': 'Lifetime Value ($)', 'count': 'Number of Customers'},
            color_discrete_sequence=['#0068C9']
        )
        fig_clv_hist.update_layout(height=400, showlegend=False)
        st.plotly_chart(fig_clv_hist, use_container_width=True)
    else:
        st.warning("No CLV data available")

with col2:
    st.markdown("**Average LTV by Tier**")
    
    if not clv_df.empty:
        fig_clv_tier = px.bar(
            clv_df.sort_values('AVG_HISTORICAL_LTV', ascending=False),
            x='CUSTOMER_TIER',
            y='AVG_HISTORICAL_LTV',
            title='Average LTV by Customer Tier',
            labels={'AVG_HISTORICAL_LTV': 'Average LTV ($)', 'CUSTOMER_TIER': 'Tier'},
            color='AVG_HISTORICAL_LTV',
            color_continuous_scale='Greens'
        )
        fig_clv_tier.update_layout(height=400, showlegend=False)
        st.plotly_chart(fig_clv_tier, use_container_width=True)
    else:
        st.warning("No tier CLV data available")

st.markdown("---")

# RFM Analysis
st.subheader("RFM (Recency, Frequency, Monetary) Analysis")

col1, col2 = st.columns(2)

with col1:
    st.markdown("**Recency vs Frequency**")
    
    if not customer_df_filtered.empty and len(customer_df_filtered) > 0:
        sample_df = customer_df_filtered.sample(min(1000, len(customer_df_filtered)))
        
        fig_rfm = px.scatter(
            sample_df,
            x='RECENCY',
            y='FREQUENCY',
            color='CUSTOMER_TIER',
            size='MONETARY',
            title='Customer Segmentation (RFM)',
            labels={
                'RECENCY': 'Days Since Last Order',
                'FREQUENCY': 'Number of Orders',
                'MONETARY': 'Total Spent ($)'
            },
            color_discrete_map={
                'VIP': '#FFD700',
                'High': '#00D084',
                'Medium': '#0068C9',
                'Low': '#808080'
            },
            hover_data=['HISTORICAL_LTV']
        )
        fig_rfm.update_layout(height=400)
        st.plotly_chart(fig_rfm, use_container_width=True)
    else:
        st.warning("No RFM data available")

with col2:
    st.markdown("**Monetary Distribution by Tier**")
    
    if not customer_df_filtered.empty:
        fig_monetary = px.box(
            customer_df_filtered,
            x='CUSTOMER_TIER',
            y='MONETARY',
            title='Monetary Value Distribution',
            labels={'MONETARY': 'Total Spent ($)', 'CUSTOMER_TIER': 'Customer Tier'},
            color='CUSTOMER_TIER',
            color_discrete_map={
                'VIP': '#FFD700',
                'High': '#00D084',
                'Medium': '#0068C9',
                'Low': '#808080'
            }
        )
        fig_monetary.update_layout(height=400, showlegend=False)
        st.plotly_chart(fig_monetary, use_container_width=True)
    else:
        st.warning("No monetary data available")

st.markdown("---")

# Predicted CLV Analysis
st.subheader("Predicted Customer Lifetime Value (12 Months)")

if not clv_df.empty:
    col1, col2 = st.columns(2)
    
    with col1:
        total_predicted = clv_df['TOTAL_PREDICTED_CLV'].sum()
        st.metric("Total Predicted CLV (12M)", format_currency(total_predicted, 0))
    
    with col2:
        avg_predicted = clv_df['AVG_PREDICTED_CLV'].mean()
        st.metric("Average Predicted CLV (12M)", format_currency(avg_predicted, 2))
    
    fig_predicted = px.bar(
        clv_df.sort_values('TOTAL_PREDICTED_CLV', ascending=False),
        x='CUSTOMER_TIER',
        y='TOTAL_PREDICTED_CLV',
        color='CUSTOMER_STATUS',
        title='Predicted 12-Month CLV by Tier and Status',
        labels={'TOTAL_PREDICTED_CLV': 'Total Predicted CLV ($)', 'CUSTOMER_TIER': 'Tier'},
        barmode='group'
    )
    fig_predicted.update_layout(height=400)
    st.plotly_chart(fig_predicted, use_container_width=True)

st.markdown("---")

# Top Customers Table
st.subheader("Top 20 Customers by Lifetime Value")

if not customer_df.empty:
    top_customers = customer_df.nlargest(20, 'HISTORICAL_LTV')[
        ['CUSTOMER_ID', 'CUSTOMER_STATE', 'HISTORICAL_LTV', 'FREQUENCY', 
         'RECENCY', 'CUSTOMER_TIER', 'CUSTOMER_STATUS', 'PREDICTED_CLV_12M']
    ].copy()
    
    top_customers['HISTORICAL_LTV'] = top_customers['HISTORICAL_LTV'].apply(lambda x: format_currency(x, 2))
    top_customers['PREDICTED_CLV_12M'] = top_customers['PREDICTED_CLV_12M'].apply(lambda x: format_currency(x, 2))
    top_customers['RECENCY'] = top_customers['RECENCY'].apply(lambda x: f"{x} days")
    
    top_customers.columns = ['Customer ID', 'State', 'Historical LTV', 'Orders', 'Recency', 'Tier', 'Status', 'Predicted CLV (12M)']
    
    st.dataframe(top_customers)

st.markdown("---")

# Customer Segments Summary
st.subheader("Customer Segments Summary")

if not rfm_df.empty:
    segment_summary = rfm_df.groupby(['CUSTOMER_TIER', 'CUSTOMER_STATUS']).agg({
        'CUSTOMER_COUNT': 'sum',
        'TOTAL_LTV': 'sum',
        'AVG_LTV': 'mean',
        'AVG_RECENCY': 'mean',
        'AVG_FREQUENCY': 'mean'
    }).reset_index()
    
    segment_summary['TOTAL_LTV'] = segment_summary['TOTAL_LTV'].apply(lambda x: format_currency(x, 0))
    segment_summary['AVG_LTV'] = segment_summary['AVG_LTV'].apply(lambda x: format_currency(x, 2))
    segment_summary['AVG_RECENCY'] = segment_summary['AVG_RECENCY'].apply(lambda x: f"{x:.0f} days")
    segment_summary['AVG_FREQUENCY'] = segment_summary['AVG_FREQUENCY'].apply(lambda x: f"{x:.1f}")
    
    segment_summary.columns = ['Tier', 'Status', 'Count', 'Total LTV', 'Avg LTV', 'Avg Recency', 'Avg Frequency']
    
    st.dataframe(segment_summary)

st.markdown("---")

# Insights
st.subheader("Key Insights & Recommendations")

col1, col2, col3 = st.columns(3)

with col1:
    if not customer_df.empty:
        vip_pct = (customer_df['IS_VIP'].sum() / len(customer_df)) * 100
        vip_revenue = customer_df[customer_df['IS_VIP'] == 1]['HISTORICAL_LTV'].sum()
        total_revenue = customer_df['HISTORICAL_LTV'].sum()
        vip_revenue_pct = (vip_revenue / total_revenue) * 100 if total_revenue > 0 else 0
        
        st.info(f"""
        **VIP Customer Segment**
        
        - {vip_pct:.1f}% of customers are VIP
        - Generate {vip_revenue_pct:.1f}% of total revenue
        
        **Action**: Implement exclusive retention programs for VIPs
        """)

with col2:
    if not rfm_df.empty:
        at_risk = rfm_df[rfm_df['CUSTOMER_STATUS'] == 'At Risk']['CUSTOMER_COUNT'].sum()
        total = rfm_df['CUSTOMER_COUNT'].sum()
        at_risk_pct = (at_risk / total) * 100 if total > 0 else 0
        
        st.warning(f"""
        **At-Risk Customers**
        
        - {at_risk_pct:.1f}% customers at risk of churning
        - Immediate intervention needed
        
        **Action**: Launch win-back campaigns targeting this segment
        """)

with col3:
    if not clv_df.empty:
        predicted_revenue = clv_df['TOTAL_PREDICTED_CLV'].sum()
        
        st.success(f"""
        **Revenue Potential**
        
        - Predicted 12M CLV: {format_currency(predicted_revenue, 0)}
        - Focus on retention to realize potential
        
        **Action**: Invest in customer success programs
        """)

st.markdown("---")
st.caption("Data refreshed from Snowflake | Last update: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))