"""
Data Loader - Pre-defined queries for all dashboards
Centralizes all SQL queries with caching
"""

import streamlit as st
import pandas as pd
from .snowflake_connector import query_snowflake


class DataLoader:
    """Manages all data loading operations with caching"""
    
    # ========== EXECUTIVE SUMMARY ==========
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_kpi_summary(start_date=None, end_date=None):
        """Get main KPIs for executive dashboard"""
        date_filter = ""
        if start_date and end_date:
            date_filter = f"WHERE full_date BETWEEN '{start_date}' AND '{end_date}'"
        
        sql = f"""
        SELECT 
            SUM(revenue) as total_revenue,
            SUM(orders) as total_orders,
            SUM(revenue) / NULLIF(SUM(orders), 0) as avg_order_value,
            COUNT(DISTINCT full_date) as days_active,
            SUM(revenue) / NULLIF(COUNT(DISTINCT full_date), 0) as avg_daily_revenue
        FROM marts_analytics.mart_sales_daily
        {date_filter}
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_revenue_trend(granularity='daily'):
        """Get revenue trend over time"""
        date_trunc = 'full_date' if granularity == 'daily' else f"DATE_TRUNC('{granularity}', full_date)"
        
        sql = f"""
        SELECT 
            {date_trunc} as date,
            SUM(revenue) as revenue,
            SUM(orders) as orders,
            SUM(revenue) / NULLIF(SUM(orders), 0) as aov
        FROM marts_analytics.mart_sales_daily
        GROUP BY 1
        ORDER BY 1
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_top_categories(limit=10):
        """Get top product categories by revenue"""
        sql = f"""
        SELECT 
            category_name_en as product_category,
            SUM(revenue) as total_revenue,
            SUM(units_sold) as total_units,
            COUNT(DISTINCT product_id) as num_products
        FROM marts_analytics.mart_product_performance
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT {limit}
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_revenue_by_state():
        """Get revenue distribution by state"""
        sql = """
        SELECT 
            customer_state,
            SUM(historical_ltv) as revenue,
            SUM(frequency) as orders,
            COUNT(DISTINCT customer_id) as customers
        FROM marts_analytics.mart_customer_lifetime_value
        GROUP BY 1
        ORDER BY 2 DESC
        """
        return query_snowflake(sql)
    
    # ========== SALES PERFORMANCE ==========
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_payment_analysis():
        """Analyze payment methods"""
        sql = """
        SELECT 
            'Credit Card' as payment_type,
            SUM(credit_card_orders) as num_payments,
            SUM(revenue * credit_card_pct / 100) as total_value,
            AVG(avg_order_value) as avg_value
        FROM marts_analytics.mart_sales_daily
        WHERE credit_card_orders > 0
        UNION ALL
        SELECT 
            'Boleto' as payment_type,
            SUM(boleto_orders) as num_payments,
            SUM(revenue * boleto_pct / 100) as total_value,
            AVG(avg_order_value) as avg_value
        FROM marts_analytics.mart_sales_daily
        WHERE boleto_orders > 0
        ORDER BY 2 DESC
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_delivery_performance():
        """Analyze delivery times and performance"""
        sql = """
        SELECT 
            AVG(avg_delivery_days) as avg_delivery_days,
            AVG(avg_estimated_days) as avg_estimated_days,
            AVG(avg_delivery_days - avg_estimated_days) as avg_delay,
            SUM(total_deliveries - on_time_deliveries) as late_deliveries,
            SUM(total_deliveries) as total_deliveries,
            AVG(on_time_rate) as avg_on_time_rate
        FROM marts_analytics.mart_sales_daily
        WHERE total_deliveries > 0
        """
        return query_snowflake(sql)
    
    # ========== CUSTOMER ANALYTICS ==========
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_customer_summary():
        """Get comprehensive customer summary"""
        sql = """
        SELECT *
        FROM marts_analytics.mart_customer_lifetime_value
        ORDER BY historical_ltv DESC
        LIMIT 1000
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_rfm_distribution():
        """Get RFM scores distribution"""
        sql = """
        SELECT 
            customer_tier,
            customer_status,
            customer_frequency_segment,
            customer_value_segment,
            COUNT(*) as customer_count,
            SUM(historical_ltv) as total_ltv,
            AVG(historical_ltv) as avg_ltv,
            AVG(recency) as avg_recency,
            AVG(frequency) as avg_frequency,
            AVG(monetary) as avg_monetary
        FROM marts_analytics.mart_customer_lifetime_value
        GROUP BY 1, 2, 3, 4
        ORDER BY 5 DESC
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_clv_analysis():
        """Analyze Customer Lifetime Value predictions"""
        sql = """
        SELECT 
            customer_tier,
            customer_status,
            COUNT(*) as customer_count,
            AVG(historical_ltv) as avg_historical_ltv,
            AVG(predicted_clv_12m) as avg_predicted_clv,
            SUM(predicted_clv_12m) as total_predicted_clv
        FROM marts_analytics.mart_customer_lifetime_value
        GROUP BY 1, 2
        ORDER BY 6 DESC
        """
        return query_snowflake(sql)
    
    # ========== PRODUCT INTELLIGENCE ==========
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_product_performance(limit=100):
        """Get detailed product performance"""
        sql = f"""
        SELECT *
        FROM marts_analytics.mart_product_performance
        ORDER BY revenue DESC
        LIMIT {limit}
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_category_rankings():
        """Get category rankings and performance"""
        sql = """
        SELECT 
            category_name_en as product_category,
            rank_in_category_revenue as revenue_rank_in_category,
            revenue,
            units_sold,
            revenue_tier,
            product_health_score
        FROM marts_analytics.mart_product_performance
        WHERE rank_in_category_revenue <= 5
        ORDER BY category_name_en, rank_in_category_revenue
        """
        return query_snowflake(sql)
    
    # ========== COHORT & RETENTION ==========
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_cohort_retention():
        """Get cohort retention data"""
        sql = """
        SELECT *
        FROM marts_analytics.mart_customer_cohorts
        ORDER BY cohort_month, months_since_cohort
        """
        return query_snowflake(sql)
    
    @staticmethod
    @st.cache(ttl=3600, allow_output_mutation=True)
    def get_cohort_summary():
        """Get summary stats by cohort"""
        sql = """
        SELECT 
            cohort_month,
            cohort_size,
            SUM(cohort_revenue) as total_revenue,
            AVG(retention_rate) as avg_retention,
            MAX(months_since_cohort) as cohort_age_months
        FROM marts_analytics.mart_customer_cohorts
        GROUP BY 1, 2
        ORDER BY 1
        """
        return query_snowflake(sql)
    
    # ========== UTILITY FUNCTIONS ==========
    
    @staticmethod
    def get_date_range():
        """Get min and max dates from data"""
        sql = """
        SELECT 
            MIN(full_date) as min_date,
            MAX(full_date) as max_date
        FROM marts_analytics.mart_sales_daily
        """
        return query_snowflake(sql)
    
    @staticmethod
    def get_row_counts():
        """Get row counts for all marts"""
        sql = """
        SELECT 
            'mart_sales_daily' as table_name, COUNT(*) as row_count 
        FROM marts_analytics.mart_sales_daily
        UNION ALL
        SELECT 'mart_customer_lifetime_value', COUNT(*) 
        FROM marts_analytics.mart_customer_lifetime_value
        UNION ALL
        SELECT 'mart_product_performance', COUNT(*) 
        FROM marts_analytics.mart_product_performance
        UNION ALL
        SELECT 'mart_sales_by_category', COUNT(*) 
        FROM marts_analytics.mart_sales_by_category
        UNION ALL
        SELECT 'mart_customer_cohorts', COUNT(*) 
        FROM marts_analytics.mart_customer_cohorts
        """
        return query_snowflake(sql)