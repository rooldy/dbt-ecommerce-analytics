"""
Sales Performance Dashboard
Detailed revenue trends and sales analysis
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.data_loader import DataLoader
from utils.styling import apply_custom_css, format_currency, format_number, format_percentage

st.set_page_config(
    page_title="Sales Performance",
    page_icon="💰",
    layout="wide"
)

apply_custom_css()

st.title("💰 Sales Performance")
st.markdown("Revenue trends, payment analysis, and delivery performance")

st.markdown("---")

# Filters
col1, col2 = st.columns([2, 2])

with col1:
    granularity = st.selectbox(
        "Time Granularity",
        ["daily", "week", "month", "quarter"],
        index=2
    )

with col2:
    metric_view = st.selectbox(
        "View Metric",
        ["Revenue", "Orders", "AOV"],
        index=0
    )

st.markdown("---")

# Load data
try:
    revenue_trend_df = DataLoader.get_revenue_trend(granularity)
    payment_df = DataLoader.get_payment_analysis()
    delivery_df = DataLoader.get_delivery_performance()
    top_categories_df = DataLoader.get_top_categories(10)
    revenue_by_state_df = DataLoader.get_revenue_by_state()
    
except Exception as e:
    st.error(f"Error loading data: {str(e)}")
    st.stop()

# Revenue Trend Chart
st.subheader(f"{metric_view} Trend Over Time")

if not revenue_trend_df.empty:
    metric_column_map = {
        "Revenue": "REVENUE",
        "Orders": "ORDERS",
        "AOV": "AOV"
    }
    
    y_column = metric_column_map[metric_view]
    
    fig_trend = px.line(
        revenue_trend_df,
        x='DATE',
        y=y_column,
        title=f'{granularity.capitalize()} {metric_view}',
        labels={'DATE': 'Date', y_column: metric_view}
    )
    
    fig_trend.update_layout(
        height=450,
        hovermode='x unified',
        showlegend=False
    )
    
    fig_trend.update_traces(
        line_color='#00D084',
        line_width=2.5
    )
    
    st.plotly_chart(fig_trend, use_container_width=True)
else:
    st.warning("No trend data available")

st.markdown("---")

# Payment & Delivery Analysis
col1, col2 = st.columns(2)

with col1:
    st.subheader("Payment Methods Analysis")
    
    if not payment_df.empty:
        fig_payment = px.pie(
            payment_df,
            values='NUM_PAYMENTS',
            names='PAYMENT_TYPE',
            title='Payment Methods Distribution',
            hole=0.4
        )
        
        fig_payment.update_layout(height=400)
        fig_payment.update_traces(
            textposition='inside',
            textinfo='percent+label'
        )
        
        st.plotly_chart(fig_payment, use_container_width=True)
        
        st.markdown("**Payment Statistics**")
        payment_stats = payment_df[['PAYMENT_TYPE', 'NUM_PAYMENTS', 'TOTAL_VALUE']].copy()
        payment_stats['TOTAL_VALUE'] = payment_stats['TOTAL_VALUE'].apply(lambda x: format_currency(x, 0))
        payment_stats['NUM_PAYMENTS'] = payment_stats['NUM_PAYMENTS'].apply(lambda x: format_number(x, 0))
        payment_stats.columns = ['Payment Type', 'Count', 'Total Value']
        st.dataframe(payment_stats)
    else:
        st.warning("No payment data available")

with col2:
    st.subheader("Delivery Performance")
    
    if not delivery_df.empty:
        avg_delivery = delivery_df['AVG_DELIVERY_DAYS'].iloc[0]
        avg_estimated = delivery_df['AVG_ESTIMATED_DAYS'].iloc[0]
        avg_delay = delivery_df['AVG_DELAY'].iloc[0]
        late_deliveries = delivery_df['LATE_DELIVERIES'].iloc[0]
        total_deliveries = delivery_df['TOTAL_DELIVERIES'].iloc[0]
        on_time_rate = delivery_df['AVG_ON_TIME_RATE'].iloc[0]
        
        metrics_data = {
            'Metric': [
                'Avg Delivery Days',
                'Avg Estimated Days',
                'Avg Delay',
                'On-Time Rate',
                'Late Deliveries',
                'Total Deliveries'
            ],
            'Value': [
                f"{avg_delivery:.1f} days",
                f"{avg_estimated:.1f} days",
                f"{avg_delay:.1f} days",
                f"{on_time_rate:.1f}%",
                f"{late_deliveries:,.0f}",
                f"{total_deliveries:,.0f}"
            ]
        }
        
        delivery_metrics_df = pd.DataFrame(metrics_data)
        
        fig_delivery = go.Figure()
        
        fig_delivery.add_trace(go.Indicator(
            mode="gauge+number+delta",
            value=on_time_rate,
            title={'text': "On-Time Delivery Rate (%)"},
            delta={'reference': 100},
            gauge={
                'axis': {'range': [0, 100]},
                'bar': {'color': "#00D084"},
                'steps': [
                    {'range': [0, 50], 'color': "#FF4B4B"},
                    {'range': [50, 80], 'color': "#FFA500"},
                    {'range': [80, 100], 'color': "#E0E0E0"}
                ],
                'threshold': {
                    'line': {'color': "red", 'width': 4},
                    'thickness': 0.75,
                    'value': 90
                }
            }
        ))
        
        fig_delivery.update_layout(height=300)
        st.plotly_chart(fig_delivery, use_container_width=True)
        
        st.markdown("**Delivery Metrics**")
        st.dataframe(delivery_metrics_df)
    else:
        st.warning("No delivery data available")

st.markdown("---")

# Category & Geographic Performance
col1, col2 = st.columns(2)

with col1:
    st.subheader("Revenue by Category")
    
    if not top_categories_df.empty:
        fig_category = px.treemap(
            top_categories_df,
            path=['PRODUCT_CATEGORY'],
            values='TOTAL_REVENUE',
            title='Category Revenue Distribution',
            color='TOTAL_REVENUE',
            color_continuous_scale='Blues'
        )
        
        fig_category.update_layout(height=400)
        st.plotly_chart(fig_category, use_container_width=True)
    else:
        st.warning("No category data available")

with col2:
    st.subheader("Top 10 States by Revenue")
    
    if not revenue_by_state_df.empty:
        top_states = revenue_by_state_df.nlargest(10, 'REVENUE')
        
        fig_states = px.bar(
            top_states,
            x='REVENUE',
            y='CUSTOMER_STATE',
            orientation='h',
            title='Revenue by State',
            labels={'REVENUE': 'Revenue ($)', 'CUSTOMER_STATE': 'State'},
            color='REVENUE',
            color_continuous_scale='Reds'
        )
        
        fig_states.update_layout(
            height=400,
            showlegend=False,
            yaxis={'categoryorder': 'total ascending'}
        )
        
        st.plotly_chart(fig_states, use_container_width=True)
    else:
        st.warning("No state data available")

st.markdown("---")

# Detailed Statistics
st.subheader("Detailed Performance Metrics")

col1, col2, col3 = st.columns(3)

with col1:
    st.markdown("**Revenue Overview**")
    if not revenue_trend_df.empty:
        total_revenue = revenue_trend_df['REVENUE'].sum()
        avg_revenue = revenue_trend_df['REVENUE'].mean()
        max_revenue = revenue_trend_df['REVENUE'].max()
        
        st.metric("Total Revenue", format_currency(total_revenue, 0))
        st.metric("Average", format_currency(avg_revenue, 0))
        st.metric("Peak", format_currency(max_revenue, 0))

with col2:
    st.markdown("**Order Overview**")
    if not revenue_trend_df.empty:
        total_orders = revenue_trend_df['ORDERS'].sum()
        avg_orders = revenue_trend_df['ORDERS'].mean()
        max_orders = revenue_trend_df['ORDERS'].max()
        
        st.metric("Total Orders", format_number(total_orders, 0))
        st.metric("Average", format_number(avg_orders, 0))
        st.metric("Peak", format_number(max_orders, 0))

with col3:
    st.markdown("**AOV Overview**")
    if not revenue_trend_df.empty:
        avg_aov = revenue_trend_df['AOV'].mean()
        min_aov = revenue_trend_df['AOV'].min()
        max_aov = revenue_trend_df['AOV'].max()
        
        st.metric("Average AOV", format_currency(avg_aov, 2))
        st.metric("Minimum", format_currency(min_aov, 2))
        st.metric("Maximum", format_currency(max_aov, 2))

st.markdown("---")

# Insights
st.subheader("Key Insights")

col1, col2, col3 = st.columns(3)

with col1:
    st.info("""
    **Payment Preferences**
    
    Credit card is the dominant payment method.
    Consider optimizing checkout for mobile payments.
    """)

with col2:
    if not delivery_df.empty:
        on_time_rate = delivery_df['AVG_ON_TIME_RATE'].iloc[0]
        if on_time_rate >= 80:
            st.success(f"""
            **Strong Delivery Performance**
            
            {on_time_rate:.1f}% on-time delivery rate exceeds industry standards.
            Maintain current logistics partnerships.
            """)
        else:
            st.warning(f"""
            **Delivery Improvement Needed**
            
            {on_time_rate:.1f}% on-time rate below target.
            Review logistics and carrier performance.
            """)

with col3:
    st.info("""
    **Geographic Expansion**
    
    Revenue concentrated in top states.
    Opportunity to expand in underperforming regions.
    """)

st.markdown("---")
st.caption("Data refreshed from Snowflake | Last update: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))