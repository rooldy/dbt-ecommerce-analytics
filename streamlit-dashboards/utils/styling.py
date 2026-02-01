"""
Styling utilities for Streamlit dashboards
Custom CSS, color schemes, and UI helpers
"""

import streamlit as st

# Color schemes
COLORS = {
    'primary': '#FF4B4B',
    'secondary': '#0068C9',
    'success': '#00D084',
    'warning': '#FFA500',
    'danger': '#FF4B4B',
    'info': '#00C0F2',
    
    # Category colors
    'revenue': '#00D084',
    'orders': '#0068C9',
    'customers': '#FF4B4B',
    'products': '#FFA500',
}

# Tier colors
TIER_COLORS = {
    'VIP': '#FFD700',
    'High Value': '#00D084',
    'Medium Value': '#0068C9',
    'Low Value': '#808080',
}

# Status colors
STATUS_COLORS = {
    'Active': '#00D084',
    'At Risk': '#FFA500',
    'Lost': '#FF4B4B',
}


def apply_custom_css():
    """Apply custom CSS to Streamlit app"""
    st.markdown("""
        <style>
        /* Main container */
        .main {
            padding: 2rem;
        }
        
        /* Metrics cards */
        [data-testid="stMetricValue"] {
            font-size: 2rem;
            font-weight: bold;
        }
        
        [data-testid="stMetricDelta"] {
            font-size: 1rem;
        }
        
        /* Headers */
        h1 {
            color: #FF4B4B;
            padding-bottom: 1rem;
            border-bottom: 2px solid #FF4B4B;
        }
        
        h2 {
            color: #0068C9;
            margin-top: 2rem;
        }
        
        h3 {
            color: #00D084;
        }
        
        /* Tables */
        [data-testid="stDataFrame"] {
            border: 1px solid #262730;
        }
        
        /* Sidebar */
        [data-testid="stSidebar"] {
            background-color: #0E1117;
        }
        
        /* Hide Streamlit branding */
        #MainMenu {visibility: hidden;}
        footer {visibility: hidden;}
        
        /* Custom metric cards */
        .metric-card {
            background-color: #262730;
            padding: 1.5rem;
            border-radius: 0.5rem;
            border-left: 4px solid #FF4B4B;
            margin-bottom: 1rem;
        }
        
        /* Info boxes */
        .info-box {
            background-color: #1E2127;
            padding: 1rem;
            border-radius: 0.5rem;
            border-left: 4px solid #0068C9;
            margin: 1rem 0;
        }
        
        /* Success box */
        .success-box {
            background-color: #1E2127;
            padding: 1rem;
            border-radius: 0.5rem;
            border-left: 4px solid #00D084;
            margin: 1rem 0;
        }
        
        /* Warning box */
        .warning-box {
            background-color: #1E2127;
            padding: 1rem;
            border-radius: 0.5rem;
            border-left: 4px solid #FFA500;
            margin: 1rem 0;
        }
        </style>
    """, unsafe_allow_html=True)


def format_currency(value, decimals=0):
    """Format value as currency"""
    if pd.isna(value):
        return "N/A"
    if decimals == 0:
        return f"${value:,.0f}"
    return f"${value:,.{decimals}f}"


def format_number(value, decimals=0):
    """Format number with thousands separator"""
    if pd.isna(value):
        return "N/A"
    if decimals == 0:
        return f"{value:,.0f}"
    return f"{value:,.{decimals}f}"


def format_percentage(value, decimals=1):
    """Format value as percentage"""
    if pd.isna(value):
        return "N/A"
    return f"{value:.{decimals}f}%"


def create_metric_card(label, value, delta=None, delta_color="normal"):
    """Create a styled metric card"""
    if delta:
        st.metric(label=label, value=value, delta=delta, delta_color=delta_color)
    else:
        st.metric(label=label, value=value)


def create_info_box(text, box_type="info"):
    """Create a styled info box"""
    class_name = f"{box_type}-box"
    st.markdown(f'<div class="{class_name}">{text}</div>', unsafe_allow_html=True)


def get_tier_color(tier):
    """Get color for customer tier"""
    return TIER_COLORS.get(tier, '#808080')


def get_status_color(status):
    """Get color for customer status"""
    return STATUS_COLORS.get(status, '#808080')


def add_logo(logo_path=None):
    """Add logo to sidebar"""
    if logo_path:
        st.sidebar.image(logo_path, use_column_width=True)
    else:
        st.sidebar.markdown("# 🛍️ E-commerce Analytics")


def add_footer():
    """Add footer to app"""
    st.markdown("---")
    st.markdown("""
        <div style='text-align: center; color: #808080; padding: 1rem;'>
            Built with ❤️ using Streamlit | Data powered by Snowflake & DBT
        </div>
    """, unsafe_allow_html=True)


import pandas as pd

def style_dataframe(df, highlight_col=None, color_map=None):
    """Apply styling to pandas DataFrame"""
    if highlight_col and color_map:
        def color_rows(val):
            color = color_map.get(val, '')
            return f'background-color: {color}'
        
        return df.style.applymap(color_rows, subset=[highlight_col])
    
    return df