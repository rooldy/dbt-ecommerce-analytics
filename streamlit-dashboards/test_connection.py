import snowflake.connector
from dotenv import load_dotenv
import os

load_dotenv()

print("Testing Snowflake connection...")
print(f"Account: {os.getenv('SNOWFLAKE_ACCOUNT')}")
print(f"User: {os.getenv('SNOWFLAKE_USER')}")
print(f"Database: {os.getenv('SNOWFLAKE_DATABASE')}")
print(f"Schema: {os.getenv('SNOWFLAKE_SCHEMA')}")

try:
    conn = snowflake.connector.connect(
        account=os.getenv('SNOWFLAKE_ACCOUNT'),
        user=os.getenv('SNOWFLAKE_USER'),
        password=os.getenv('SNOWFLAKE_PASSWORD'),
        warehouse=os.getenv('SNOWFLAKE_WAREHOUSE'),
        database=os.getenv('SNOWFLAKE_DATABASE'),
        schema=os.getenv('SNOWFLAKE_SCHEMA'),
        role=os.getenv('SNOWFLAKE_ROLE')
    )
    print("Connection successful!")
    
    cursor = conn.cursor()
    cursor.execute("SELECT CURRENT_VERSION()")
    version = cursor.fetchone()
    print(f"Snowflake version: {version[0]}")
    
    cursor.close()
    conn.close()
    print("Test passed!")
    
except Exception as e:
    print(f"Connection failed: {str(e)}")
