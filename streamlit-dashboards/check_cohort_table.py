"""
Script pour vérifier la structure de MART_CUSTOMER_COHORTS
Exécuter: python check_cohort_table.py
"""

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

# 1. Lister les colonnes
print("=== COLONNES DE MART_CUSTOMER_COHORTS ===")
cursor.execute("DESCRIBE TABLE MART_CUSTOMER_COHORTS")
columns = cursor.fetchall()
for col in columns:
    print(f"  {col[0]} ({col[1]})")

# 2. Voir les 3 premières lignes
print("\n=== SAMPLE DATA (3 rows) ===")
cursor.execute("SELECT * FROM MART_CUSTOMER_COHORTS LIMIT 3")
col_names = [desc[0] for desc in cursor.description]
rows = cursor.fetchall()

print("Colonnes:", col_names)
for row in rows:
    print(row)

cursor.close()
conn.close()