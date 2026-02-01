"""
RFM Segmentation Dashboard
Marketing insights based on Recency, Frequency, and Monetary analysis
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime
import sys
import os

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.data_loader import DataLoader
from utils.styling import apply_custom_css, format_currency, format_number, format_percentage

# Page config
st.set_page_config(
    page_title="RFM Segmentation",
    page_icon="🎯",
    layout="wide"
)

# Apply styling
apply_custom_css()

# Header
st.title("🎯 RFM Segmentation")
st.markdown("Marketing insights and customer segmentation based on Recency, Frequency, and Monetary analysis")

st.markdown("---")

# Load data
try:
    rfm_df = DataLoader.get_rfm_distribution()
    customer_df = DataLoader.get_customer_summary()
except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.stop()

# Filter
col1, col2 = st.columns([3, 1])

with col2:
    status_filter = st.selectbox(
        "Filter by Status",
        ["All"] + (sorted(rfm_df['CUSTOMER_STATUS'].unique().tolist()) if not rfm_df.empty else []),
        index=0
    )

# Apply filter
if status_filter != "All" and not rfm_df.empty:
    rfm_df_filtered = rfm_df[rfm_df['CUSTOMER_STATUS'] == status_filter]
else:
    rfm_df_filtered = rfm_df

st.markdown("---")

# KPI Cards
st.subheader("RFM Overview")

if not rfm_df.empty:
    col1, col2, col3, col4 = st.columns(4)

    with col1:
        # Total de segments uniques
        total_segments = rfm_df['CUSTOMER_TIER'].nunique()
        st.metric("Total Segments", format_number(total_segments, 0))

    with col2:
        # Total de clients segmentés
        total_customers = rfm_df['CUSTOMER_COUNT'].sum()
        st.metric("Total Customers", format_number(total_customers, 0))

    with col3:
        # LTV totale de tous les segments
        total_ltv = rfm_df['TOTAL_LTV'].sum()
        st.metric("Total LTV", format_currency(total_ltv, 0))

    with col4:
        # LTV moyenne par client
        avg_ltv = rfm_df['AVG_LTV'].mean()
        st.metric("Avg LTV per Customer", format_currency(avg_ltv, 2))

st.markdown("---")

# Segment Distribution
col1, col2 = st.columns(2)

with col1:
    st.subheader("Customer Tier Distribution")

    if not rfm_df_filtered.empty:
        # Regrouper par tier pour le pie chart
        tier_df = rfm_df_filtered.groupby('CUSTOMER_TIER').agg({
            'CUSTOMER_COUNT': 'sum',
            'TOTAL_LTV': 'sum'
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
    st.subheader("Revenue Contribution by Tier")

    if not rfm_df_filtered.empty:
        # Même données mais on montre la contribution en LTV
        fig_ltv = px.pie(
            tier_df,
            values='TOTAL_LTV',
            names='CUSTOMER_TIER',
            title='LTV Contribution by Tier',
            hole=0.4,
            color='CUSTOMER_TIER',
            color_discrete_map={
                'VIP': '#FFD700',
                'High': '#00D084',
                'Medium': '#0068C9',
                'Low': '#808080'
            }
        )
        fig_ltv.update_layout(height=400)
        fig_ltv.update_traces(textposition='inside', textinfo='percent+label')
        st.plotly_chart(fig_ltv, use_container_width=True)
    else:
        st.warning("No LTV data available")

st.markdown("---")

# RFM Metrics by Segment
st.subheader("RFM Metrics by Segment")

col1, col2 = st.columns(2)

with col1:
    st.markdown("**Average Recency by Tier**")

    if not rfm_df_filtered.empty:
        # Recency moyenne par tier - plus bas = plus récent = meilleur
        recency_df = rfm_df_filtered.groupby('CUSTOMER_TIER').agg({
            'AVG_RECENCY': 'mean'
        }).reset_index().sort_values('AVG_RECENCY')

        fig_recency = px.bar(
            recency_df,
            x='CUSTOMER_TIER',
            y='AVG_RECENCY',
            title='Average Days Since Last Order',
            labels={'AVG_RECENCY': 'Days', 'CUSTOMER_TIER': 'Tier'},
            color='AVG_RECENCY',
            color_continuous_scale='RdYlGn_r'
        )
        fig_recency.update_layout(height=350, showlegend=False)
        st.plotly_chart(fig_recency, use_container_width=True)
    else:
        st.warning("No recency data available")

with col2:
    st.markdown("**Average Frequency by Tier**")

    if not rfm_df_filtered.empty:
        # Frequency moyenne par tier - plus haut = plus d'achats = meilleur
        freq_df = rfm_df_filtered.groupby('CUSTOMER_TIER').agg({
            'AVG_FREQUENCY': 'mean'
        }).reset_index().sort_values('AVG_FREQUENCY', ascending=False)

        fig_freq = px.bar(
            freq_df,
            x='CUSTOMER_TIER',
            y='AVG_FREQUENCY',
            title='Average Number of Orders',
            labels={'AVG_FREQUENCY': 'Orders', 'CUSTOMER_TIER': 'Tier'},
            color='AVG_FREQUENCY',
            color_continuous_scale='Blues'
        )
        fig_freq.update_layout(height=350, showlegend=False)
        st.plotly_chart(fig_freq, use_container_width=True)
    else:
        st.warning("No frequency data available")

st.markdown("---")

# Customer Status Analysis
st.subheader("Customer Status Analysis")

col1, col2 = st.columns(2)

with col1:
    st.markdown("**Customers by Status**")

    if not rfm_df.empty:
        # Regrouper par status
        status_df = rfm_df.groupby('CUSTOMER_STATUS').agg({
            'CUSTOMER_COUNT': 'sum',
            'TOTAL_LTV': 'sum'
        }).reset_index()

        fig_status = px.bar(
            status_df,
            x='CUSTOMER_STATUS',
            y='CUSTOMER_COUNT',
            title='Customer Distribution by Status',
            labels={'CUSTOMER_COUNT': 'Number of Customers', 'CUSTOMER_STATUS': 'Status'},
            color='CUSTOMER_STATUS',
            color_discrete_map={
                'Active': '#00D084',
                'At Risk': '#FFA500',
                'Lost': '#FF4B4B'
            }
        )
        fig_status.update_layout(height=350, showlegend=False)
        st.plotly_chart(fig_status, use_container_width=True)
    else:
        st.warning("No status data available")

with col2:
    st.markdown("**LTV by Status**")

    if not rfm_df.empty:
        # Même données mais montrer le LTV par status
        fig_status_ltv = px.bar(
            status_df,
            x='CUSTOMER_STATUS',
            y='TOTAL_LTV',
            title='Total LTV by Customer Status',
            labels={'TOTAL_LTV': 'Total LTV ($)', 'CUSTOMER_STATUS': 'Status'},
            color='CUSTOMER_STATUS',
            color_discrete_map={
                'Active': '#00D084',
                'At Risk': '#FFA500',
                'Lost': '#FF4B4B'
            }
        )
        fig_status_ltv.update_layout(height=350, showlegend=False)
        st.plotly_chart(fig_status_ltv, use_container_width=True)
    else:
        st.warning("No LTV data available")

st.markdown("---")

# RFM Scatter Plot
st.subheader("RFM Customer Segmentation Map")

if not customer_df.empty:
    # Sample pour ne pas surcharger le graphique
    sample_size = min(2000, len(customer_df))
    sample_df = customer_df.sample(sample_size)

    fig_scatter = px.scatter(
        sample_df,
        x='RECENCY',
        y='FREQUENCY',
        color='CUSTOMER_TIER',
        size='MONETARY',
        title='Customer Segmentation: Recency vs Frequency (size = Monetary)',
        labels={
            'RECENCY': 'Days Since Last Order (lower = better)',
            'FREQUENCY': 'Number of Orders (higher = better)',
            'MONETARY': 'Total Spent ($)',
            'CUSTOMER_TIER': 'Tier'
        },
        color_discrete_map={
            'VIP': '#FFD700',
            'High': '#00D084',
            'Medium': '#0068C9',
            'Low': '#808080'
        },
        hover_data=['CUSTOMER_ID', 'HISTORICAL_LTV', 'CUSTOMER_STATUS']
    )
    fig_scatter.update_layout(height=500)
    st.plotly_chart(fig_scatter, use_container_width=True)
else:
    st.warning("No scatter plot data available")

st.markdown("---")

# Segment Summary Table
st.subheader("Segment Summary")

if not rfm_df.empty:
    # Créer une copie pour formater
    segment_table = rfm_df.copy()
    segment_table['TOTAL_LTV'] = segment_table['TOTAL_LTV'].apply(lambda x: format_currency(x, 0))
    segment_table['AVG_LTV'] = segment_table['AVG_LTV'].apply(lambda x: format_currency(x, 2))
    segment_table['AVG_RECENCY'] = segment_table['AVG_RECENCY'].apply(lambda x: f"{x:.0f} days")
    segment_table['AVG_FREQUENCY'] = segment_table['AVG_FREQUENCY'].apply(lambda x: f"{x:.1f}")
    segment_table['AVG_MONETARY'] = segment_table['AVG_MONETARY'].apply(lambda x: format_currency(x, 2))

    # Sélectionner et renommer les colonnes
    segment_table = segment_table[[
        'CUSTOMER_TIER', 'CUSTOMER_STATUS', 'CUSTOMER_COUNT',
        'TOTAL_LTV', 'AVG_LTV', 'AVG_RECENCY', 'AVG_FREQUENCY', 'AVG_MONETARY'
    ]]
    segment_table.columns = [
        'Tier', 'Status', 'Customers',
        'Total LTV', 'Avg LTV', 'Avg Recency', 'Avg Orders', 'Avg Monetary'
    ]

    st.dataframe(segment_table)
else:
    st.warning("No segment data available")

st.markdown("---")

# Marketing Recommendations
st.subheader("Marketing Recommendations by Segment")

col1, col2, col3 = st.columns(3)

with col1:
    if not rfm_df.empty:
        # Données VIP
        vip_data = rfm_df[rfm_df['CUSTOMER_TIER'] == 'VIP']
        vip_count = vip_data['CUSTOMER_COUNT'].sum() if not vip_data.empty else 0
        vip_ltv = vip_data['TOTAL_LTV'].sum() if not vip_data.empty else 0

        st.success(f"""
        **VIP Customers**
        
        - Count: {format_number(vip_count, 0)}
        - Total LTV: {format_currency(vip_ltv, 0)}
        
        **Recommendation:**
        - Exclusive loyalty program
        - Early access to new products
        - Dedicated account manager
        - Priority customer support
        """)

with col2:
    if not rfm_df.empty:
        # Données At Risk
        at_risk_data = rfm_df[rfm_df['CUSTOMER_STATUS'] == 'At Risk']
        at_risk_count = at_risk_data['CUSTOMER_COUNT'].sum() if not at_risk_data.empty else 0
        at_risk_ltv = at_risk_data['TOTAL_LTV'].sum() if not at_risk_data.empty else 0

        st.warning(f"""
        **At-Risk Customers**
        
        - Count: {format_number(at_risk_count, 0)}
        - Total LTV: {format_currency(at_risk_ltv, 0)}
        
        **Recommendation:**
        - Win-back email campaigns
        - Special discount offers
        - Personalized product suggestions
        - Re-engagement surveys
        """)

with col3:
    if not rfm_df.empty:
        # Données Lost
        lost_data = rfm_df[rfm_df['CUSTOMER_STATUS'] == 'Lost']
        lost_count = lost_data['CUSTOMER_COUNT'].sum() if not lost_data.empty else 0
        lost_ltv = lost_data['TOTAL_LTV'].sum() if not lost_data.empty else 0

        st.info(f"""
        **Lost Customers**
        
        - Count: {format_number(lost_count, 0)}
        - Total LTV: {format_currency(lost_ltv, 0)}
        
        **Recommendation:**
        - Final re-engagement attempt
        - Exit survey to understand churn
        - Analyze lost customer patterns
        - Focus budget on retention instead
        """)

# Footer
st.markdown("---")
st.caption("Data refreshed from Snowflake | Last update: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))