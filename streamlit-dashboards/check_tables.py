import snowflake.connector
from dotenv import load_dotenv
import os

load_dotenv()

conn = snowflake.connector.connect(
    account=os.getenv('SNOWFLAKE_ACCOUNT'),
    user=os.getenv('SNOWFLAKE_USER'),
    password=os.getenv('SNOWFLAKE_PASSWORD'),
    warehouse=os.getenv('SNOWFLAKE_WAREHOUSE'),
    database=os.getenv('SNOWFLAKE_DATABASE'),
    schema=os.getenv('SNOWFLAKE_SCHEMA'),
    role=os.getenv('SNOWFLAKE_ROLE')
)

cursor = conn.cursor()

tables = [
    'MART_SALES_DAILY',
    'MART_CUSTOMER_LIFETIME_VALUE',
    'MART_PRODUCT_PERFORMANCE',
    'MART_SALES_BY_CATEGORY'
]

for table in tables:
    print(f"\n=== {table} ===")
    cursor.execute(f"DESCRIBE TABLE {table}")
    columns = cursor.fetchall()
    for col in columns:
        print(f"  {col[0]} ({col[1]})")

cursor.close()
conn.close()
