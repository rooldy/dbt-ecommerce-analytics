"""
Script pour charger les données Olist dans Snowflake
"""

import snowflake.connector
import pandas as pd
from pathlib import Path
import os
from dotenv import load_dotenv

# Charger les variables d'environnement
load_dotenv()

# Configuration Snowflake
SNOWFLAKE_CONFIG = {
    'account': 'PQHYLYQ-WA35386',
    'user': 'ROOLDY2026',
    'password': os.getenv('SNOWFLAKE_PASSWORD', 'VOTRE_MOT_DE_PASSE'),
    'warehouse': 'DBT_WH',
    'database': 'DBT_ECOMMERCE',
    'schema': 'RAW',
    'role': 'DBT_ROLE',
    'insecure_mode': True
}

# Chemin vers les données
DATA_DIR = Path("data/raw")

# Mapping des fichiers CSV vers les tables Snowflake
datasets = {
    'RAW_CUSTOMERS': 'olist_customers_dataset.csv',
    'RAW_ORDERS': 'olist_orders_dataset.csv',
    'RAW_ORDER_ITEMS': 'olist_order_items_dataset.csv',
    'RAW_PRODUCTS': 'olist_products_dataset.csv',
    'RAW_PAYMENTS': 'olist_order_payments_dataset.csv',
    'RAW_REVIEWS': 'olist_order_reviews_dataset.csv',
    'RAW_SELLERS': 'olist_sellers_dataset.csv',
    'RAW_GEOLOCATION': 'olist_geolocation_dataset.csv',
    'RAW_PRODUCT_TRANSLATION': 'product_category_name_translation.csv'
}


def load_data_to_snowflake():
    """Charge les fichiers CSV dans Snowflake"""
    
    print(" Connexion à Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    
    print(f"✓ Connecté à Snowflake")
    print(f"  Database: {SNOWFLAKE_CONFIG['database']}")
    print(f"  Schema: {SNOWFLAKE_CONFIG['schema']}\n")
    
    # Utiliser le contexte
    cursor.execute(f"USE WAREHOUSE {SNOWFLAKE_CONFIG['warehouse']}")
    cursor.execute(f"USE DATABASE {SNOWFLAKE_CONFIG['database']}")
    cursor.execute(f"USE SCHEMA {SNOWFLAKE_CONFIG['schema']}")
    
    total_rows = 0
    successful_tables = 0
    
    # Charger chaque fichier
    for table_name, filename in datasets.items():
        filepath = DATA_DIR / filename
        
        if not filepath.exists():
            print(f"✗ Warning: {filename} not found")
            continue
        
        print(f"\n Loading {filename}...")
        
        try:
            # Lire le CSV
            df = pd.read_csv(filepath)
            rows = len(df)
            print(f"   {rows:,} rows, {len(df.columns)} columns")
            
            # Supprimer la table si elle existe
            cursor.execute(f"DROP TABLE IF EXISTS {table_name}")
            
            # Charger les données
            from snowflake.connector.pandas_tools import write_pandas
            
            success, nchunks, nrows, _ = write_pandas(
                conn=conn,
                df=df,
                table_name=table_name,
                database=SNOWFLAKE_CONFIG['database'],
                schema=SNOWFLAKE_CONFIG['schema'],
                auto_create_table=True,
                overwrite=True,
                quote_identifiers=False
            )
            
            if success:
                print(f"   ✓ {table_name} loaded ({nrows:,} rows)")
                total_rows += nrows
                successful_tables += 1
            
        except Exception as e:
            print(f"   ✗ Error: {str(e)}")
    
    # Résumé
    print(f"\n{'='*60}")
    print(f" Chargement terminé !")
    print(f"   Tables chargées: {successful_tables}/{len(datasets)}")
    print(f"   Total rows: {total_rows:,}")
    print(f"\n Coût estimé: < 0.50$ USD")
    
    cursor.close()
    conn.close()


if __name__ == "__main__":
    load_data_to_snowflake()