# Guide de Setup - DBT E-commerce Analytics

**Version** : 1.0  
**Date** : 2025-01-17  
**Auteur** : Rooldy Alphonse

Ce guide vous accompagne pas à pas dans la configuration complète du projet, de la création du compte Snowflake jusqu'au premier modèle DBT fonctionnel.

---

## TABLE DES MATIÈRES

1. [Prérequis](#1-prérequis)
2. [Création du compte Snowflake](#2-création-du-compte-snowflake)
3. [Configuration de Snowflake](#3-configuration-de-snowflake)
4. [Configuration de l'environnement Python](#4-configuration-de-lenvironnement-python)
5. [Téléchargement des données](#5-téléchargement-des-données)
6. [Configuration DBT](#6-configuration-dbt)
7. [Chargement des données dans Snowflake](#7-chargement-des-données-dans-snowflake)
8. [Vérification de l'installation](#8-vérification-de-linstallation)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. PRÉREQUIS

### 1.1 Logiciels nécessaires

**Python 3.8 ou supérieur**
```bash
# Vérifier la version
python --version
# ou
python3 --version

# Si non installé : https://www.python.org/downloads/
```

**Git**
```bash
# Vérifier la version
git --version

# Si non installé : https://git-scm.com/
```

**pip** (gestionnaire de paquets Python)
```bash
# Vérifier
pip --version

# Normalement installé avec Python
```

### 1.2 Comptes requis

- **GitHub** : Pour cloner le repository (gratuit)
- **Kaggle** : Pour télécharger le dataset Olist (gratuit)
- **Snowflake Trial** : Pas encore, on va le créer ensemble

---

## 2. CRÉATION DU COMPTE SNOWFLAKE

### 2.1 S'inscrire pour le trial gratuit

1. **Aller sur** : [signup.snowflake.com](https://signup.snowflake.com/)

2. **Remplir le formulaire** :
   - Email (personnel ou professionnel)
   - Nom et prénom
   - Entreprise : `Personal Project` ou votre nom
   - Pays

3. **Choisir l'édition** : **Standard** (suffisant et gratuit)

4. **Choisir le cloud provider et la région** :
   - **Recommandé** : AWS
   - **Région** : La plus proche de vous (ex: `eu-west-1` pour Europe)
   - Alternatives : Azure ou GCP selon préférence

5. **Accepter les conditions** et cliquer sur **GET STARTED**

6. **Vérifier votre email** et activer le compte

### 2.2 Première connexion

1. Vous recevrez un email avec votre **account identifier**
   - Format : `abc12345.eu-west-1` ou `abc12345`
   - ⚠️ **IMPORTANT** : Notez-le, vous en aurez besoin pour DBT

2. **Créer un mot de passe fort** (minimum 8 caractères)

3. **Se connecter** à l'interface web Snowflake

### 2.3 Explorer l'interface

Une fois connecté, vous verrez :
- **Worksheets** : Pour exécuter des requêtes SQL
- **Databases** : Vos bases de données
- **Warehouses** : Ressources de calcul
- **Admin** → **Usage** : Vos crédits restants (400$ au départ)

---

## 3. CONFIGURATION DE SNOWFLAKE

### 3.1 Exécuter le script de setup

Dans Snowflake, aller dans **Worksheets** et créer une nouvelle worksheet.

**Copier-coller et exécuter ce script SQL** :
```sql
-- ============================================
-- SETUP SNOWFLAKE POUR DBT E-COMMERCE PROJECT
-- ============================================

-- Utiliser le rôle ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- 1. Créer un warehouse pour DBT
CREATE WAREHOUSE DBT_WH 
  WITH 
    WAREHOUSE_SIZE = 'XSMALL'      -- Petit et économique
    AUTO_SUSPEND = 60               -- S'arrête après 1 min d'inactivité
    AUTO_RESUME = TRUE              -- Redémarre automatiquement si besoin
    INITIALLY_SUSPENDED = TRUE;     -- Démarre arrêté

-- 2. Créer la database principale
CREATE DATABASE DBT_ECOMMERCE;

-- 3. Créer les schémas
USE DATABASE DBT_ECOMMERCE;

CREATE SCHEMA RAW;              -- Données brutes
CREATE SCHEMA STAGING;          -- Couche staging (nettoyage)
CREATE SCHEMA INTERMEDIATE;     -- Couche intermediate (logique métier)
CREATE SCHEMA MARTS_CORE;       -- Marts core (star schema)
CREATE SCHEMA MARTS_ANALYTICS;  -- Marts analytics (KPIs)

-- 4. Créer un rôle dédié pour DBT
CREATE ROLE DBT_ROLE;

-- 5. Donner les permissions au rôle
GRANT USAGE ON WAREHOUSE DBT_WH TO ROLE DBT_ROLE;
GRANT ALL ON DATABASE DBT_ECOMMERCE TO ROLE DBT_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE DBT_ECOMMERCE TO ROLE DBT_ROLE;

-- Permissions futures (pour les nouvelles tables)
GRANT ALL ON FUTURE SCHEMAS IN DATABASE DBT_ECOMMERCE TO ROLE DBT_ROLE;
GRANT ALL ON FUTURE TABLES IN DATABASE DBT_ECOMMERCE TO ROLE DBT_ROLE;
GRANT ALL ON FUTURE VIEWS IN DATABASE DBT_ECOMMERCE TO ROLE DBT_ROLE;

-- 6. Assigner le rôle à votre utilisateur
-- ⚠️ REMPLACER <VOTRE_EMAIL> par votre email Snowflake
GRANT ROLE DBT_ROLE TO USER <VOTRE_EMAIL>;

-- 7. Vérifier la configuration
SHOW WAREHOUSES;
SHOW DATABASES;
SHOW SCHEMAS IN DATABASE DBT_ECOMMERCE;
SHOW ROLES;
```

### 3.2 Vérifier les crédits disponibles
```sql
-- Voir l'utilisation des crédits (optionnel)
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;
```

**Vous devriez avoir ~400$ de crédits disponibles.**

---

## 4. CONFIGURATION DE L'ENVIRONNEMENT PYTHON

### 4.1 Cloner le repository
```bash
# Cloner le projet
git clone https://github.com/rooldy/dbt-ecommerce-analytics.git
cd dbt-ecommerce-analytics

# Basculer sur la branche dev
git checkout dev
```

### 4.2 Créer un environnement virtuel

**Sur macOS/Linux** :
```bash
python3 -m venv venv
source venv/bin/activate
```

**Sur Windows** :
```bash
python -m venv venv
venv\Scripts\activate
```

Vous devriez voir `(venv)` dans votre terminal.

### 4.3 Installer les dépendances
```bash
# Mettre à jour pip
pip install --upgrade pip

# Installer toutes les dépendances
pip install -r requirements.txt
```

⏱️ Cette installation peut prendre **5-10 minutes** (snowflake-connector est volumineux).

**Vérifier l'installation** :
```bash
dbt --version
```

Vous devriez voir :
```
Core:
  - installed: 1.8.0
  - latest:    1.8.0

Plugins:
  - snowflake: 1.8.0
```

---

## 5. TÉLÉCHARGEMENT DES DONNÉES

### 5.1 Créer un compte Kaggle

1. Aller sur [kaggle.com](https://www.kaggle.com/)
2. S'inscrire (gratuit)
3. Vérifier votre email

### 5.2 Télécharger le dataset Olist

1. Aller sur : [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Cliquer sur **Download** (nécessite d'être connecté)
3. Extraire l'archive ZIP
4. **Copier tous les fichiers CSV** dans le dossier `data/raw/`

### 5.3 Fichiers attendus

Vérifier que vous avez bien ces **9 fichiers CSV** dans `data/raw/` :
```
data/raw/
├── olist_customers_dataset.csv
├── olist_orders_dataset.csv
├── olist_order_items_dataset.csv
├── olist_products_dataset.csv
├── olist_order_payments_dataset.csv
├── olist_order_reviews_dataset.csv
├── olist_sellers_dataset.csv
├── olist_geolocation_dataset.csv
└── product_category_name_translation.csv
```

**Vérifier** :
```bash
ls -la data/raw/
```

---

## 6. CONFIGURATION DBT

### 6.1 Créer le fichier profiles.yml

DBT stocke les credentials dans un fichier `profiles.yml` situé dans `~/.dbt/`

**Créer le dossier** :
```bash
# Sur macOS/Linux
mkdir -p ~/.dbt

# Sur Windows
mkdir %USERPROFILE%\.dbt
```

**Créer le fichier** :
```bash
# Sur macOS/Linux
nano ~/.dbt/profiles.yml

# Sur Windows
notepad %USERPROFILE%\.dbt\profiles.yml
```

**Copier ce contenu** (⚠️ Remplacer les valeurs entre `<>`) :
```yaml
dbt_ecommerce:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <VOTRE_ACCOUNT_IDENTIFIER>  # Ex: abc12345.eu-west-1
      user: <VOTRE_EMAIL>                  # Votre email Snowflake
      password: <VOTRE_MOT_DE_PASSE>       # Votre mot de passe
      role: DBT_ROLE
      database: DBT_ECOMMERCE
      warehouse: DBT_WH
      schema: STAGING
      threads: 4
      client_session_keep_alive: False
      query_tag: dbt_dev
      
    prod:
      type: snowflake
      account: <VOTRE_ACCOUNT_IDENTIFIER>
      user: <VOTRE_EMAIL>
      password: <VOTRE_MOT_DE_PASSE>
      role: DBT_ROLE
      database: DBT_ECOMMERCE
      warehouse: DBT_WH
      schema: MARTS_ANALYTICS
      threads: 8
      client_session_keep_alive: False
      query_tag: dbt_prod
```

**Sauvegarder et fermer** (Ctrl+X puis Y sur nano, ou simplement sauvegarder sur notepad)

### 6.2 Tester la connexion DBT
```bash
cd dbt_ecommerce
dbt debug
```

**Résultat attendu** :
```
Connection:
  account: abc12345.eu-west-1
  user: votre_email@example.com
  database: DBT_ECOMMERCE
  warehouse: DBT_WH
  role: DBT_ROLE
  schema: STAGING
  Connection test: [OK connection ok]

All checks passed!
```

✅ Si vous voyez "All checks passed!", c'est parfait !

❌ Si erreur, voir section [Troubleshooting](#9-troubleshooting)

---

## 7. CHARGEMENT DES DONNÉES DANS SNOWFLAKE

### 7.1 Créer le script de chargement

Créer le fichier `scripts/load_data_snowflake.py` :
```python
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
    'account': os.getenv('SNOWFLAKE_ACCOUNT', 'VOTRE_ACCOUNT'),
    'user': os.getenv('SNOWFLAKE_USER', 'VOTRE_EMAIL'),
    'password': os.getenv('SNOWFLAKE_PASSWORD', 'VOTRE_PASSWORD'),
    'warehouse': 'DBT_WH',
    'database': 'DBT_ECOMMERCE',
    'schema': 'RAW',
    'role': 'DBT_ROLE'
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
    
    print("🚀 Connexion à Snowflake...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cursor = conn.cursor()
    
    print(f"✓ Connecté à Snowflake")
    print(f"  Account: {SNOWFLAKE_CONFIG['account']}")
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
        
        print(f"\n📁 Loading {filename}...")
        
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
    print(f"✅ Chargement terminé !")
    print(f"   Tables chargées: {successful_tables}/{len(datasets)}")
    print(f"   Total rows: {total_rows:,}")
    print(f"\n💰 Coût estimé: < 0.10$ USD")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    load_data_to_snowflake()
```

### 7.2 Créer le fichier .env (optionnel)

**Plus sécurisé** : Créer un fichier `.env` à la racine :
```bash
SNOWFLAKE_ACCOUNT=abc12345.eu-west-1
SNOWFLAKE_USER=votre_email@example.com
SNOWFLAKE_PASSWORD=votre_mot_de_passe
```

⚠️ **Ce fichier ne sera PAS commité** (déjà dans .gitignore)

### 7.3 Exécuter le chargement
```bash
# Depuis la racine du projet
python scripts/load_data_snowflake.py
```

⏱️ **Durée estimée** : 2-5 minutes

**Résultat attendu** :
```
🚀 Connexion à Snowflake...
✓ Connecté à Snowflake
  Account: abc12345.eu-west-1
  Database: DBT_ECOMMERCE
  Schema: RAW

📁 Loading olist_orders_dataset.csv...
   99,441 rows, 8 columns
   ✓ RAW_ORDERS loaded (99,441 rows)

...

✅ Chargement terminé !
   Tables chargées: 9/9
   Total rows: 117,601
```

---

## 8. VÉRIFICATION DE L'INSTALLATION

### 8.1 Vérifier dans Snowflake

Retourner dans Snowflake Web UI, dans **Worksheets** :
```sql
USE DATABASE DBT_ECOMMERCE;
USE SCHEMA RAW;

-- Lister les tables
SHOW TABLES;

-- Compter les lignes
SELECT 'RAW_ORDERS' as table_name, COUNT(*) as row_count FROM RAW_ORDERS
UNION ALL
SELECT 'RAW_CUSTOMERS', COUNT(*) FROM RAW_CUSTOMERS
UNION ALL
SELECT 'RAW_ORDER_ITEMS', COUNT(*) FROM RAW_ORDER_ITEMS;

-- Aperçu des données
SELECT * FROM RAW_ORDERS LIMIT 10;
```

### 8.2 Créer un premier modèle DBT de test

Dans `dbt_ecommerce/models/staging/stg_orders.sql` :
```sql
with source as (
    select * from {{ source('raw', 'RAW_ORDERS') }}
),

renamed as (
    select
        ORDER_ID as order_id,
        CUSTOMER_ID as customer_id,
        ORDER_STATUS as order_status,
        ORDER_PURCHASE_TIMESTAMP::timestamp as order_date
    from source
)

select * from renamed
```

### 8.3 Tester le modèle
```bash
cd dbt_ecommerce

# Construire le modèle
dbt run --select stg_orders

# Générer la documentation
dbt docs generate

# Servir la documentation
dbt docs serve
```

Ouvrir http://localhost:8080 dans votre navigateur.

✅ **Si tout fonctionne, la Phase 1 est complète !**

---

## 9. TROUBLESHOOTING

### Erreur : "Invalid account identifier"

**Symptôme** : DBT ne se connecte pas à Snowflake

**Solution** :
- Vérifier le format de l'account identifier
- Bon : `abc12345.eu-west-1` ou `abc12345`
- Mauvais : `https://abc12345.snowflakecomputing.com`
- Ne PAS inclure `https://` ni `.snowflakecomputing.com`

### Erreur : "Authentication failed"

**Solutions** :
1. Vérifier username et password dans `profiles.yml`
2. Essayer de se connecter via Snowflake Web UI d'abord
3. Vérifier que le compte est bien activé

### Erreur : "Warehouse does not exist"

**Solutions** :
1. Vérifier que le script SQL de setup a bien été exécuté
2. Dans Snowflake, vérifier : `SHOW WAREHOUSES;`
3. Réexécuter le script de setup si nécessaire

### Erreur : "Permission denied"

**Solutions** :
1. Vérifier que le rôle `DBT_ROLE` a bien été créé
2. Vérifier que votre user a le rôle assigné
3. Réexécuter la partie "permissions" du script setup

### Fichiers CSV manquants

**Solution** :
1. Retélécharger le dataset depuis Kaggle
2. Vérifier que vous avez extrait l'archive ZIP
3. Copier tous les fichiers dans `data/raw/`

### Performance lente

**Solutions** :
1. Vérifier que le warehouse est bien XSMALL
2. Augmenter temporairement : `ALTER WAREHOUSE DBT_WH SET WAREHOUSE_SIZE = 'SMALL';`
3. Redescendre après : `ALTER WAREHOUSE DBT_WH SET WAREHOUSE_SIZE = 'XSMALL';`

### Crédits Snowflake épuisés

**Prévention** :
- Toujours configurer `AUTO_SUSPEND = 60`
- Vérifier dans Admin → Usage
- Arrêter manuellement le warehouse si non utilisé
- **Coût total estimé du projet : <10$ USD**

---

## 10. PROCHAINES ÉTAPES

Une fois le setup terminé, vous êtes prêt pour :

✅ **Phase 2** : Développer tous les modèles staging  
✅ **Phase 3** : Créer les modèles intermediate  
✅ **Phase 4** : Construire le star schema  

Consultez le [plan détaillé du projet](docs/architecture.md) pour la suite !

---

## 11. RESSOURCES UTILES

- [Snowflake Trial Guide](https://docs.snowflake.com/en/user-guide/admin-trial-account)
- [DBT Snowflake Setup](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup)
- [DBT Documentation](https://docs.getdbt.com/)
- [Olist Dataset Description](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

**Document version** : 1.0  
**Dernière mise à jour** : 2025-01-17  
**Auteur** : Rooldy Alphonse  
**Status** : ✅ Validé pour Phase 1