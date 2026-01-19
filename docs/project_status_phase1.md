# DBT E-commerce Analytics - Status & Handoff Document

**Projet** : Pipeline de données end-to-end avec DBT et Snowflake  
**Auteur** : Rooldy Alphonse  
**Date de début** : 17 janvier 2025  
**Dernière mise à jour** : 18 janvier 2025  
**Repository GitHub** : https://github.com/rooldy/dbt-ecommerce-analytics

---

## 🎯 OBJECTIF DU PROJET

### Vision globale

Créer un **pipeline de données production-ready** pour analyser les données e-commerce du dataset Olist, en utilisant la stack moderne **DBT + Snowflake**, et en suivant les meilleures pratiques de l'industrie.

### Objectifs SMART

1. **Infrastructure moderne** : Data warehouse Snowflake + transformations DBT
2. **Modèles analytiques métier** : 40+ modèles (staging, intermediate, marts)
3. **Qualité garantie** : >90% de couverture de tests
4. **Visualisation** : 4 dashboards opérationnels
5. **Optimisation** : Coûts <5$ USD, performance <5min build
6. **Portfolio** : Projet démontrant compétences Analytics Engineer

### Pourquoi ce projet ?

**Contexte professionnel** : Préparation pour une offre d'emploi Analytics Engineer mentionnant DBT et Snowflake.

**Compétences ciblées** :
- ✅ Modélisation et architecture Snowflake optimisée
- ✅ Ingestion de données robuste
- ✅ Optimisation des coûts et performances
- ✅ Tests et qualité des données
- ✅ Documentation professionnelle
- ✅ Partage de connaissances

---

## 📊 ARCHITECTURE DU PROJET

### Stack technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Data Warehouse** | Snowflake | Standard Edition (trial) |
| **Transformation** | DBT Core | 1.8.0 |
| **Adapter** | dbt-snowflake | 1.8.0 |
| **Langage** | SQL + Python | 3.11.14 |
| **Orchestration** | DBT Cloud / GitHub Actions | À venir Phase 8 |
| **Visualisation** | Metabase / Looker Studio | À venir Phase 7 |
| **Version Control** | Git/GitHub | - |

### Architecture des données (Medallion)

```
CSV Files (Kaggle)
    ↓
RAW (Bronze) - 9 tables, 1.5M+ rows
    ↓
STAGING (Silver) - Nettoyage, standardisation
    ↓
INTERMEDIATE (Silver) - Logique métier
    ↓
MARTS_CORE (Gold) - Star schema (facts + dimensions)
    ↓
MARTS_ANALYTICS (Gold) - KPIs métier
    ↓
Dashboards BI
```

### Snowflake - Configuration

```
DATABASE: DBT_ECOMMERCE
├── SCHEMA: RAW (9 tables - 1.5M rows)
├── SCHEMA: STAGING (9 modèles à créer)
├── SCHEMA: INTERMEDIATE (6-8 modèles)
├── SCHEMA: MARTS_CORE (facts + dims)
└── SCHEMA: MARTS_ANALYTICS (KPIs)

WAREHOUSE: DBT_WH
- Size: XSMALL
- Auto-suspend: 60s
- Resource monitor: 10 crédits max
```

---

## 📅 PLAN DU PROJET : 9 PHASES

### Timeline complète (8-10 semaines)

| Phase | Nom | Durée | Status |
|-------|-----|-------|--------|
| **0** | Initiation & Cadrage | 2-3j | ✅ TERMINÉE |
| **1** | Setup & Infrastructure | 5-7j | ✅ TERMINÉE |
| **2** | Couche Staging | 5-7j | 🔄 EN COURS |
| **3** | Couche Intermediate | 5-7j | ⏳ À FAIRE |
| **4** | Marts Core (Star Schema) | 5-7j | ⏳ À FAIRE |
| **5** | Marts Analytics | 6-8j | ⏳ À FAIRE |
| **6** | Qualité & Tests | 3-5j | ⏳ À FAIRE |
| **7** | Visualisation & Dashboards | 4-6j | ⏳ À FAIRE |
| **8** | Déploiement & Production | 5-7j | ⏳ À FAIRE |
| **9** | Maintenance & Expérimentations | 3-5j | ⏳ À FAIRE |

---

## ✅ CE QUI A ÉTÉ RÉALISÉ

### PHASE 0 : INITIATION & CADRAGE (COMPLÉTÉE ✅)

**Durée** : 2 jours (17-18 janvier 2025)

**Livrables** :
- ✅ Repository GitHub structuré et organisé
- ✅ README.md professionnel avec badges
- ✅ .gitignore adapté (DBT + Snowflake)
- ✅ requirements.txt (toutes dépendances)
- ✅ Configuration files (.env.example, profiles.yml.example)
- ✅ dbt_project.yml configuré

**Documentation stratégique** :
- ✅ docs/PROJECT_CHARTER.md (charte complète du projet)
- ✅ docs/architecture.md (design technique détaillé)
- ✅ setup_guide.md (guide d'installation Snowflake + DBT)

**Documentation optimisation (focus offre d'emploi)** :
- ✅ docs/SNOWFLAKE_OPTIMIZATION.md (stratégie coûts/performance)
- ✅ docs/DATA_INGESTION.md (process d'ingestion robuste)
- ✅ docs/LEARNINGS.md (partage de connaissances)

**Résultat** : Infrastructure documentée, prête pour développement

---

### PHASE 1 : SETUP & INFRASTRUCTURE (COMPLÉTÉE ✅)

**Durée** : 1 jour (18 janvier 2025) ⚡

**1. Snowflake configuré**
- ✅ Compte trial créé (400$ de crédits disponibles)
- ✅ Account identifier : PQHYLYQ-WA35386
- ✅ Warehouse DBT_WH (XSMALL, auto-suspend 60s)
- ✅ Database DBT_ECOMMERCE créée
- ✅ 5 schémas créés (RAW, STAGING, INTERMEDIATE, MARTS_CORE, MARTS_ANALYTICS)
- ✅ Rôle DBT_ROLE configuré avec permissions
- ✅ Resource monitor activé (protection budget 10 crédits)

**2. Environnement Python/DBT**
- ✅ Python 3.11.14 installé avec venv
- ✅ DBT Core 1.8.0 + dbt-snowflake 1.8.0 installés
- ✅ profiles.yml configuré (~/.dbt/)
- ✅ Connexion DBT ↔ Snowflake validée (`dbt debug` : All checks passed!)

**3. Données chargées**
- ✅ Dataset Olist téléchargé depuis Kaggle (9 fichiers CSV)
- ✅ Script Python `scripts/load_data_snowflake.py` créé
- ✅ 1,550,922 lignes chargées dans Snowflake
- ✅ 9 tables RAW créées :
  - RAW_CUSTOMERS (99,441 rows)
  - RAW_ORDERS (99,441 rows)
  - RAW_ORDER_ITEMS (112,650 rows)
  - RAW_PRODUCTS (32,951 rows)
  - RAW_PAYMENTS (103,886 rows)
  - RAW_REVIEWS (99,224 rows)
  - RAW_SELLERS (3,095 rows)
  - RAW_GEOLOCATION (1,000,163 rows)
  - RAW_PRODUCT_TRANSLATION (71 rows)

**4. Premier modèle DBT**
- ✅ dbt_ecommerce/models/staging/_sources.yml créé
- ✅ dbt_ecommerce/models/staging/stg_orders.sql créé
- ✅ `dbt run --select stg_orders` : SUCCESS ✅
- ✅ Modèle validé dans Snowflake (view créée)

**Métriques** :
- Coût Phase 1 : ~0.50$ USD
- Durée : 1 jour au lieu de 5-7j prévus ⚡
- Tous les objectifs atteints

---

## 🔄 PHASE EN COURS

### PHASE 2 : COUCHE STAGING - DATA QUALITY (EN COURS 🔄)

**Objectif** : Créer les 9 modèles staging complets avec tests et documentation

**Durée estimée** : 5-7 jours

**Modèles à créer** :

1. ✅ **stg_orders.sql** (FAIT)
2. ⏳ stg_customers.sql
3. ⏳ stg_order_items.sql
4. ⏳ stg_products.sql
5. ⏳ stg_payments.sql
6. ⏳ stg_reviews.sql
7. ⏳ stg_sellers.sql
8. ⏳ stg_geolocation.sql
9. ⏳ stg_product_translation.sql

**Tâches** :
- [ ] Créer les 8 modèles staging restants
- [ ] Ajouter tests sur chaque modèle (unique, not_null, relationships)
- [ ] Documenter tous les modèles dans _staging.yml
- [ ] Atteindre >95% de couverture de tests
- [ ] Valider avec `dbt run` et `dbt test`

**Pattern de chaque modèle** :
```sql
with source as (
    select * from {{ source('raw', 'RAW_TABLE') }}
),

renamed as (
    select
        -- Renommage colonnes en snake_case
        -- Casting des types
        -- Nettoyage des données
    from source
)

select * from renamed
```

**Prochaine session** : Créer stg_customers.sql

---

## ⏳ CE QU'IL RESTE À FAIRE

### PHASE 3 : COUCHE INTERMEDIATE (5-7 jours)

**Objectif** : Logique métier et enrichissements

**Modèles à créer (6-8 modèles)** :
- int_orders_enriched.sql (orders + customers + payments)
- int_order_items_enriched.sql (items + products + sellers)
- int_customer_orders.sql (historique client)
- int_delivery_performance.sql
- int_product_reviews.sql
- int_seller_metrics.sql

**Macros à créer** :
- cents_to_currency.sql
- days_between.sql
- generate_surrogate_key.sql
- categorize_customer.sql

---

### PHASE 4 : MARTS CORE - STAR SCHEMA (5-7 jours)

**Objectif** : Créer le modèle dimensionnel

**Tables de faits** :
- fct_orders.sql (grain: 1 commande)
- fct_order_items.sql (grain: 1 item par commande)

**Dimensions** :
- dim_customers.sql (SCD Type 1)
- dim_products.sql (SCD Type 2)
- dim_sellers.sql
- dim_date.sql (dimension de dates)
- dim_order_status.sql

**Features** :
- Surrogate keys
- Foreign key relationships
- Tests de référential integrity
- Clustering keys sur fct_orders (order_date)

---

### PHASE 5 : MARTS ANALYTICS - KPIS (6-8 jours)

**Objectif** : Métriques métier et KPIs

**Marts analytiques (6-8 modèles)** :

**Customer Analytics** :
- mart_customer_lifetime_value.sql (CLV, segmentation RFM)
- mart_customer_cohorts.sql (analyse rétention)
- mart_customer_segmentation.sql

**Sales Analytics** :
- mart_sales_daily.sql (tendances quotidiennes)
- mart_sales_by_category.sql
- mart_sales_by_state.sql

**Product & Operations** :
- mart_product_performance.sql
- mart_delivery_kpis.sql
- mart_seller_performance.sql

**Features** :
- Incremental models (mart_sales_daily)
- Optimisations performance
- Benchmark complet

---

### PHASE 6 : QUALITÉ & TESTS (3-5 jours)

**Objectif** : >90% couverture de tests

**Tâches** :
- Tests génériques sur tous les modèles critiques
- 5-10 tests personnalisés (SQL)
- Documentation complète (100%)
- Scripts d'automatisation (run_tests.sh)
- Rapport de qualité

---

### PHASE 7 : VISUALISATION & DASHBOARDS (4-6 jours)

**Objectif** : 4 dashboards opérationnels

**Dashboards à créer** :
1. Executive Dashboard (KPIs globaux)
2. Customer Analytics Dashboard
3. Product Performance Dashboard
4. Operations Dashboard

**Tool** : Metabase (gratuit) ou Looker Studio

---

### PHASE 8 : DÉPLOIEMENT & PRODUCTION (5-7 jours)

**Objectif** : Code production-ready

**Tâches** :
- Environnement prod dans Snowflake
- CI/CD avec GitHub Actions
- Monitoring automatisé (scripts/monitor_snowflake.py)
- Dashboard de monitoring
- Runbook opérationnel (docs/RUNBOOK.md)
- Orchestration configurée

---

### PHASE 9 : MAINTENANCE & EXPÉRIMENTATIONS (3-5 jours)

**Objectif** : Innovation et partage

**Expérimentations (DataLab)** :
- Time Travel Snowflake
- Zero-copy cloning
- Streams & Tasks
- Dynamic tables
- Features avancées

**Partage de connaissances** :
- 3 articles de blog (drafts dans LEARNINGS.md)
- Présentation "From Zero to Production"
- Contributions Stack Overflow / DBT Discourse
- Posts LinkedIn

**Certification** :
- Snowflake SnowPro Core (en cours)

---

## 📂 STRUCTURE DU REPOSITORY

```
dbt-ecommerce-analytics/
├── .github/workflows/          # CI/CD (Phase 8)
├── .gitignore                  # ✅
├── README.md                   # ✅
├── requirements.txt            # ✅
├── setup_guide.md              # ✅
├── .env.example                # ✅
├── .env                        # ✅ (credentials, non versionné)
├── profiles.yml.example        # ✅
│
├── data/
│   ├── raw/                    # ✅ 9 fichiers CSV (1.5M rows)
│   └── processed/
│
├── dbt_ecommerce/
│   ├── dbt_project.yml         # ✅
│   ├── models/
│   │   ├── staging/
│   │   │   ├── _sources.yml    # ✅
│   │   │   ├── _staging.yml    # À compléter
│   │   │   └── stg_orders.sql  # ✅ 1/9
│   │   ├── intermediate/
│   │   └── marts/
│   │       ├── core/
│   │       └── analytics/
│   ├── macros/
│   ├── tests/
│   ├── snapshots/
│   └── seeds/
│
├── docs/
│   ├── PROJECT_CHARTER.md      # ✅
│   ├── architecture.md         # ✅
│   ├── SNOWFLAKE_OPTIMIZATION.md  # ✅
│   ├── DATA_INGESTION.md       # ✅
│   └── LEARNINGS.md            # ✅
│
├── scripts/
│   └── load_data_snowflake.py  # ✅
│
├── dashboards/
└── experiments/
```

---

## 🔧 INFORMATIONS TECHNIQUES

### Credentials Snowflake

**Account** : PQHYLYQ-WA35386  
**User** : ROOLDY2026  
**Password** : Stocké dans .env (SNOWFLAKE_PASSWORD)  
**Warehouse** : DBT_WH  
**Database** : DBT_ECOMMERCE  
**Role** : DBT_ROLE

### Fichier profiles.yml

Localisation : `~/.dbt/profiles.yml`

```yaml
dbt_ecommerce:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: PQHYLYQ-WA35386
      user: ROOLDY2026
      password: '{{ env_var("SNOWFLAKE_PASSWORD") }}'
      role: DBT_ROLE
      database: DBT_ECOMMERCE
      warehouse: DBT_WH
      schema: STAGING
      threads: 4
```

### Environnement Python

**Version** : Python 3.11.14  
**Venv** : `venv/` (à la racine du projet)  
**Activation** : `source venv/bin/activate`

**Packages installés** :
- dbt-core==1.8.0
- dbt-snowflake==1.8.0
- snowflake-connector-python==3.6.0
- pandas==2.1.4
- Et toutes les dépendances (voir requirements.txt)

### Commandes DBT essentielles

```bash
# Activer l'environnement
source venv/bin/activate

# Aller dans dbt_ecommerce
cd dbt_ecommerce

# Tester connexion
dbt debug

# Lancer tous les modèles
dbt run

# Lancer un modèle spécifique
dbt run --select stg_orders

# Tester
dbt test
dbt test --select stg_orders

# Documentation
dbt docs generate
dbt docs serve  # Ouvre http://localhost:8080
```

---

## 📊 MÉTRIQUES DU PROJET

### Objectifs vs Réalisé

| Métrique | Objectif Final | Réalisé | Status |
|----------|---------------|---------|--------|
| **Modèles DBT** | 40-50 | 1 | 2% |
| **Tests** | >90% coverage | 2 tests | Début |
| **Documentation** | 100% | 30% | En cours |
| **Coûts Snowflake** | <5$ USD | 0.50$ | ✅ On track |
| **Temps build** | <5 min | <10s | ✅ Excellent |
| **Dashboards** | 4 | 0 | À faire |
| **Phases complètes** | 9 | 2 | 22% |

### Budget Snowflake

**Crédits disponibles** : 400$ USD  
**Consommés** : ~0.50$ USD (Phase 1)  
**Restants** : ~399.50$ USD  
**Projection totale projet** : <5$ USD  
**Marge** : 99% du budget préservé ✅

---

## 🚀 POUR REPRENDRE LE PROJET

### Checklist de démarrage

1. **Ouvrir le terminal**
   ```bash
   cd ~/Desktop/DataEngineering/Projects_Data_Engineer/DBT_E-commerce/dbt-ecommerce-analytics
   ```

2. **Activer l'environnement virtuel**
   ```bash
   source venv/bin/activate
   ```

3. **Vérifier la branche Git**
   ```bash
   git status
   git branch
   # Si besoin : git checkout dev
   ```

4. **Tester la connexion Snowflake**
   ```bash
   cd dbt_ecommerce
   dbt debug
   ```

5. **Vérifier les données**
   - Aller sur Snowflake Web UI
   - USE DATABASE DBT_ECOMMERCE;
   - USE SCHEMA RAW;
   - SHOW TABLES;

### Prochaine tâche à faire : PHASE 2

**Créer stg_customers.sql** :

```bash
cd models/staging
nano stg_customers.sql
```

Copier ce template :
```sql
with source as (
    select * from {{ source('raw', 'RAW_CUSTOMERS') }}
),

renamed as (
    select
        CUSTOMER_ID as customer_id,
        CUSTOMER_UNIQUE_ID as customer_unique_id,
        CUSTOMER_ZIP_CODE_PREFIX as zip_code,
        CUSTOMER_CITY as city,
        CUSTOMER_STATE as state
    from source
)

select * from renamed
```

Puis :
```bash
cd ../..
dbt run --select stg_customers
dbt test --select stg_customers
```

---

## 📚 RESSOURCES UTILES

### Documentation

- **DBT Docs** : https://docs.getdbt.com/
- **Snowflake Docs** : https://docs.snowflake.com/
- **Dataset Olist** : https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

### Fichiers clés du projet

- **Roadmap détaillée** : Voir artifact "updated_project_roadmap"
- **Architecture** : docs/architecture.md
- **Optimisation Snowflake** : docs/SNOWFLAKE_OPTIMIZATION.md
- **Guide setup** : setup_guide.md

### Commandes Git utiles

```bash
# Voir le status
git status

# Créer une branche feature pour Phase 2
git checkout -b feature/phase-2-staging

# Commit réguliers
git add models/staging/
git commit -m "feat: Add stg_customers model"
git push origin feature/phase-2-staging

# Merger dans dev quand Phase 2 finie
git checkout dev
git merge feature/phase-2-staging
git push origin dev
```

---

## 🎯 OBJECTIFS COURT TERME

### Cette semaine

- [ ] Terminer Phase 2 (9 modèles staging)
- [ ] >95% de tests sur staging
- [ ] Documentation staging complète
- [ ] Commit Phase 2 sur GitHub

### Semaine prochaine

- [ ] Phase 3 (intermediate layer)
- [ ] Macros réutilisables
- [ ] Commencer Phase 4 (star schema)

### Ce mois

- [ ] Phases 2-3-4 complètes
- [ ] Star schema opérationnel
- [ ] Premiers marts analytics
- [ ] Article de blog #1 publié

---

## 💡 NOTES IMPORTANTES

### Points d'attention

⚠️ **Sécurité** :
- Ne JAMAIS commiter .env (déjà dans .gitignore)
- Ne JAMAIS partager les credentials Snowflake
- Changer le mot de passe si exposé accidentellement

⚠️ **Snowflake** :
- Vérifier les crédits dans Admin → Usage chaque semaine
- Resource monitor protège à 10 crédits (suspension auto)
- Auto-suspend à 60s : warehouse s'arrête automatiquement

⚠️ **DBT** :
- Toujours lancer depuis dbt_ecommerce/ folder
- `dbt debug` pour tester connexion avant de travailler
- `dbt run --select model_name` pour un modèle spécifique

### Problèmes potentiels et solutions

**Erreur : "Certificate validation failed"**
→ Solution : Ajouter `'insecure_mode': True` dans SNOWFLAKE_CONFIG

**Erreur : "dbt_project.yml not found"**
→ Solution : Être dans le dossier dbt_ecommerce/

**Erreur : "Source not found"**
→ Solution : Vérifier _sources.yml, vérifier que tables existent dans Snowflake

---

## ✅ CHECKLIST DE REPRISE

Avant de reprendre le travail :

- [ ] Lire ce document en entier
- [ ] Vérifier l'environnement (Python 3.11, venv activé)
- [ ] Tester connexion Snowflake (`dbt debug`)
- [ ] Vérifier que les 9 tables RAW sont dans Snowflake
- [ ] Git status (vérifier branche dev)
- [ ] Relire la roadmap (artifact "updated_project_roadmap")
- [ ] Identifier la prochaine tâche (Phase 2 : stg_customers)

---

**Document créé le** : 18 janvier 2025, 20h30  
**Status** : Phase 1 complète ✅, Phase 2 démarrée 🔄  
**Prochaine session** : Continuer Phase 2 - Modèles staging

**Bon courage pour la suite ! 💪🚀**
