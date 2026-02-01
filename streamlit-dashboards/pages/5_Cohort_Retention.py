"""
Cohort Retention Dashboard
Customer cohort analysis and retention metrics
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
    page_title="Cohort & Retention",
    page_icon="🔄",
    layout="wide"
)

# Apply styling
apply_custom_css()

# Header
st.title("🔄 Cohort & Retention")
st.markdown("Customer cohort analysis and retention metrics")

st.markdown("---")

# Load data
try:
    cohort_df = DataLoader.get_cohort_retention()
    cohort_summary_df = DataLoader.get_cohort_summary()
except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.stop()

# KPI Cards
st.subheader("Cohort Overview")

if not cohort_summary_df.empty:
    col1, col2, col3, col4 = st.columns(4)

    with col1:
        # Nombre total de cohortes
        total_cohorts = cohort_summary_df['COHORT_MONTH'].nunique()
        st.metric("Total Cohorts", format_number(total_cohorts, 0))

    with col2:
        # Nombre total de clients dans toutes les cohortes
        total_customers = cohort_summary_df['COHORT_SIZE'].sum()
        st.metric("Total Customers", format_number(total_customers, 0))

    with col3:
        # Revenue total généré par les cohortes
        total_revenue = cohort_summary_df['TOTAL_REVENUE'].sum()
        st.metric("Total Revenue", format_currency(total_revenue, 0))

    with col4:
        # Taux de retention moyen sur toutes les cohortes
        avg_retention = cohort_summary_df['AVG_RETENTION'].mean()
        st.metric("Avg Retention Rate", f"{avg_retention:.1f}%")

st.markdown("---")

# Retention Heatmap
st.subheader("Retention Heatmap")

if not cohort_df.empty:
    # Pivotez les données pour créer une matrix cohorte x mois
    retention_pivot = cohort_df.pivot_table(
        index='COHORT_MONTH',
        columns='MONTHS_SINCE_FIRST_ORDER',
        values='RETENTION_RATE'
    )

    # Créer la heatmap avec une echelle couleur vert (bon) à rouge (mauvais)
    fig_heatmap = px.imshow(
        retention_pivot,
        title='Cohort Retention Heatmap',
        color_continuous_scale='RdYlGn',
        labels={
            'x': 'Months Since First Order',
            'y': 'Cohort',
            'color': 'Retention (%)'
        }
    )

    fig_heatmap.update_layout(height=500)
    st.plotly_chart(fig_heatmap, use_container_width=True)
else:
    st.warning("No retention data available")

st.markdown("---")

# Retention Curves
st.subheader("Retention Curves by Cohort")

if not cohort_df.empty:
    # Chaque ligne représente une cohorte différente
    fig_curves = px.line(
        cohort_df,
        x='MONTHS_SINCE_FIRST_ORDER',
        y='RETENTION_RATE',
        color='COHORT_MONTH',
        title='Retention Curves Over Time',
        labels={
            'MONTHS_SINCE_FIRST_ORDER': 'Months Since First Order',
            'RETENTION_RATE': 'Retention Rate (%)',
            'COHORT_MONTH': 'Cohort'
        }
    )

    fig_curves.update_layout(height=450, hovermode='x unified')
    st.plotly_chart(fig_curves, use_container_width=True)
else:
    st.warning("No retention curve data available")

st.markdown("---")

# Cohort Sizes & Revenue
col1, col2 = st.columns(2)

with col1:
    st.subheader("Cohort Sizes Over Time")

    if not cohort_summary_df.empty:
        # Taille de chaque cohorte par mois
        fig_sizes = px.bar(
            cohort_summary_df,
            x='COHORT_MONTH',
            y='COHORT_SIZE',
            title='Number of Customers per Cohort',
            labels={
                'COHORT_MONTH': 'Cohort Month',
                'COHORT_SIZE': 'Number of Customers'
            },
            color_discrete_sequence=['#0068C9']
        )

        fig_sizes.update_layout(height=400)
        st.plotly_chart(fig_sizes, use_container_width=True)
    else:
        st.warning("No cohort size data available")

with col2:
    st.subheader("Revenue by Cohort")

    if not cohort_summary_df.empty:
        # Revenue total généré par chaque cohorte
        fig_revenue = px.bar(
            cohort_summary_df,
            x='COHORT_MONTH',
            y='TOTAL_REVENUE',
            title='Total Revenue per Cohort',
            labels={
                'COHORT_MONTH': 'Cohort Month',
                'TOTAL_REVENUE': 'Total Revenue ($)'
            },
            color_discrete_sequence=['#00D084']
        )

        fig_revenue.update_layout(height=400)
        st.plotly_chart(fig_revenue, use_container_width=True)
    else:
        st.warning("No revenue data available")

st.markdown("---")

# Cohort Summary Table
st.subheader("Cohort Summary")

if not cohort_summary_df.empty:
    # Créer une copie pour formater sans modifier les données originales
    summary = cohort_summary_df.copy()
    summary['TOTAL_REVENUE'] = summary['TOTAL_REVENUE'].apply(lambda x: format_currency(x, 0))
    summary['AVG_RETENTION'] = summary['AVG_RETENTION'].apply(lambda x: f"{x:.1f}%")
    summary.columns = ['Cohort Month', 'Cohort Size', 'Total Revenue', 'Avg Retention', 'Age (months)']

    st.dataframe(summary)
else:
    st.warning("No summary data available")

st.markdown("---")

# Key Insights
st.subheader("Key Insights")

col1, col2, col3 = st.columns(3)

with col1:
    # Meilleure cohorte par retention
    if not cohort_summary_df.empty:
        best_cohort = cohort_summary_df.nlargest(1, 'AVG_RETENTION').iloc[0]
        st.success(f"""
        **Best Retention Cohort**
        
        Cohort: {best_cohort['COHORT_MONTH']}
        Retention: {best_cohort['AVG_RETENTION']:.1f}%
        
        This cohort shows the strongest customer loyalty.
        """)

with col2:
    # Plus grande cohorte
    if not cohort_summary_df.empty:
        largest_cohort = cohort_summary_df.nlargest(1, 'COHORT_SIZE').iloc[0]
        st.info(f"""
        **Largest Cohort**
        
        Cohort: {largest_cohort['COHORT_MONTH']}
        Customers: {largest_cohort['COHORT_SIZE']:,.0f}
        
        Highest acquisition period in the dataset.
        """)

with col3:
    # Cohorte avec le plus de revenue
    if not cohort_summary_df.empty:
        best_revenue = cohort_summary_df.nlargest(1, 'TOTAL_REVENUE').iloc[0]
        st.warning(f"""
        **Highest Revenue Cohort**
        
        Cohort: {best_revenue['COHORT_MONTH']}
        Revenue: {format_currency(best_revenue['TOTAL_REVENUE'], 0)}
        
        Most valuable customer group acquired.
        """)

# Footer
st.markdown("---")
st.caption("Data refreshed from Snowflake | Last update: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))