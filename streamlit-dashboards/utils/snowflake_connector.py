"""
Snowflake Connection Manager for Streamlit Dashboards
Handles connection pooling, caching, and error handling
"""

import streamlit as st
import snowflake.connector
from snowflake.connector import DictCursor
import pandas as pd
from typing import Optional, Dict, Any
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class SnowflakeConnector:
    """Manages Snowflake connections with caching and error handling"""
    
    def __init__(self):
        self.connection_params = {
            'account': os.getenv('SNOWFLAKE_ACCOUNT'),
            'user': os.getenv('SNOWFLAKE_USER'),
            'password': os.getenv('SNOWFLAKE_PASSWORD'),
            'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH'),
            'database': os.getenv('SNOWFLAKE_DATABASE', 'DBT_ECOMMERCE'),
            'schema': os.getenv('SNOWFLAKE_SCHEMA', 'ANALYTICS'),
            'role': os.getenv('SNOWFLAKE_ROLE', 'ACCOUNTADMIN'),
        }
        
    @st.experimental_singleton
    def get_connection(_self):
        """
        Create and cache Snowflake connection
        Uses Streamlit's experimental_singleton to persist connection across reruns
        """
        try:
            conn = snowflake.connector.connect(
                account=_self.connection_params['account'],
                user=_self.connection_params['user'],
                password=_self.connection_params['password'],
                warehouse=_self.connection_params['warehouse'],
                database=_self.connection_params['database'],
                schema=_self.connection_params['schema'],
                role=_self.connection_params['role'],
                client_session_keep_alive=True
            )
            return conn
        except Exception as e:
            st.error(f"Failed to connect to Snowflake: {str(e)}")
            st.stop()
    
    @st.cache(ttl=3600, allow_output_mutation=True)
    def query(_self, sql: str, params: Optional[Dict[str, Any]] = None) -> pd.DataFrame:
        """
        Execute SQL query and return results as DataFrame
        
        Args:
            sql: SQL query string
            params: Optional parameters for parameterized queries
            
        Returns:
            pandas DataFrame with query results
        """
        try:
            conn = _self.get_connection()
            cursor = conn.cursor(DictCursor)
            
            if params:
                cursor.execute(sql, params)
            else:
                cursor.execute(sql)
            
            results = cursor.fetch_pandas_all()
            cursor.close()
            
            return results
            
        except Exception as e:
            st.error(f"Query failed: {str(e)}")
            st.code(sql, language='sql')
            return pd.DataFrame()
    
    def test_connection(self) -> bool:
        """Test if connection is working"""
        try:
            df = self.query("SELECT CURRENT_VERSION() as version")
            return not df.empty
        except:
            return False
    
    def get_table_info(self, table_name: str) -> pd.DataFrame:
        """Get column information for a table"""
        sql = f"""
        SELECT 
            column_name,
            data_type,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = '{self.connection_params['schema']}'
        AND table_name = '{table_name.upper()}'
        ORDER BY ordinal_position
        """
        return self.query(sql)
    
    def get_available_tables(self) -> list:
        """Get list of all available tables"""
        sql = f"""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = '{self.connection_params['schema']}'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
        """
        df = self.query(sql)
        return df['TABLE_NAME'].tolist() if not df.empty else []


# Global instance
@st.experimental_singleton
def get_snowflake_connector():
    """Get cached Snowflake connector instance"""
    return SnowflakeConnector()


# Helper function for easy querying
def query_snowflake(sql: str, params: Optional[Dict[str, Any]] = None) -> pd.DataFrame:
    """
    Convenience function to query Snowflake
    
    Usage:
        df = query_snowflake("SELECT * FROM mart_sales_daily LIMIT 10")
    """
    connector = get_snowflake_connector()
    return connector.query(sql, params)