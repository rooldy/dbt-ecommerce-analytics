# Phase 7 - Visualisation & Dashboards - Final Report

**Projet** : DBT E-commerce Analytics  
**Auteur** : Rooldy Alphonse  
**Date de début** : 30 janvier 2026  
**Date de fin** : 31 janvier 2026  
**Status** : COMPLET (100% du code, en attente de test cohort)

---

## Objectifs Phase 7

### Objectifs initiaux
1. Créer 4-6 dashboards interactifs
2. Conecter Snowflake à Streamlit
3. Implémenter 15+ visualisations
4. Mettre en place filtres et drill-downs
5. Documenter insights business

### Objectifs atteints
- **Dashboards créés** : 6/6 (100%)
- **Infrastructure** : 100% complète
- **Connexion Snowflake** : Fonctionnelle
- **Visualisations** : 30+ créées
- **Filtres** : Implémentés sur tous les dashboards

---

## Réalisations

### 1. Infrastructure Streamlit (100% COMPLET)

#### Structure du projet
```
streamlit-dashboards/
├── .streamlit/
│   └── config.toml              ✅ Configuré (dark theme)
├── pages/
│   ├── 1_Executive_Summary.py   ✅ COMPLET - Testé
│   ├── 2_Sales_Performance.py   ✅ COMPLET - Testé
│   ├── 3_Customer_Analytics.py  ✅ COMPLET - Testé
│   ├── 4_Product_Intelligence.py ✅ COMPLET - Testé
│   ├── 5_Cohort_Retention.py    ✅ COMPLET - En attente retest (cohort queries)
│   └── 6_RFM_Segmentation.py    ✅ COMPLET - En attente test
├── utils/
│   ├── __init__.py              ✅ 
│   ├── snowflake_connector.py   ✅ COMPLET
│   ├── data_loader.py           ✅ COMPLET (15 fonctions)
│   ├── styling.py               ✅ COMPLET
│   ├── metrics.py               ✅ 
│   └── charts.py                ✅ 
├── Home.py                      ✅ COMPLET - Testé
├── requirements.txt             ✅ COMPLET
├── .env                         ✅ Configuré
├── check_tables.py              ✅ Script utilitaire
├── check_cohort_table.py        ✅ Script utilitaire
├── test_connection.py           ✅ Script utilitaire
└── README.md                    ✅ COMPLET
```

#### Configuration
- **Snowflake Account** : PQHYLYQ-WA35386
- **Database** : DBT_ECOMMERCE
- **Schema** : MARTS_ANALYTICS
- **Warehouse** : DBT_WH
- **Role** : DBT_ROLE

#### Dépendances installées
```
streamlit==1.12.0
snowflake-connector-python==4.2.0
plotly==6.5.2
pandas==2.3.3
python-dotenv==1.2.1
altair==4.2.2 (downgraded pour compatibilité)
numpy==2.0.2
```

---

### 2. Home.py - Page d'accueil (100% COMPLET - TESTÉ)

#### Fonctionnalités
- Test de connexion Snowflake automatique
- Liste des tables disponibles dans la sidebar
- 4 KPI cards (Revenue, Orders, AOV, Daily Revenue)
- Tableau row counts des marts
- Section architecture & tech stack
- Navigation vers les 6 dashboards

#### KPIs confirmés
- **Total Revenue** : $13.6M
- **Total Orders** : 98,666
- **Average Order Value** : $137.75
- **Avg Daily Revenue** : $22,064
- **Date Range** : 2016-09-04 à 2018-09-03
- **Total Rows** : 134,284

---

### 3. Dashboard 1 : Executive Summary (100% COMPLET - TESTÉ)

#### Visualisations (7)
1. 4 KPI Cards : Revenue, Orders, AOV, Daily Revenue
2. Line Chart : Revenue trend over time
3. Horizontal Bar Chart : Top 10 product categories
4. Horizontal Bar Chart : Revenue by state (top 10)
5. Data Table : Revenue metrics summary
6. Data Table : Top category performance
7. Insight Cards (3) : Business recommendations

#### Fonctionnalités
- Filtre de période (All Time, Last 30/90/365 days)
- Graphiques interactifs Plotly (hover, zoom, pan)
- Color-coded visualizations

---

### 4. Dashboard 2 : Sales Performance (100% COMPLET - TESTÉ)

#### Visualisations (10)
1. Line Chart : Revenue/Orders/AOV trend (sélectionnable)
2. Pie Chart : Payment methods distribution
3. Gauge Chart : On-time delivery rate
4. Treemap : Revenue by category distribution
5. Horizontal Bar Chart : Top 10 states by revenue
6. Metrics Cards (9) : Revenue/Orders/AOV stats (Total, Average, Peak)
7. Data Table : Payment statistics
8. Data Table : Delivery metrics
9. Insight Cards (3) : Payment, Delivery, Geographic

#### Fonctionnalités
- Filtre de granularité (daily/week/month/quarter)
- Sélecteur de métrique (Revenue/Orders/AOV)
- Analyse détaillée des paiements
- Performance de livraison avec gauge

---

### 5. Dashboard 3 : Customer Analytics (100% COMPLET - TESTÉ)

#### Visualisations (12)
1. 4 KPI Cards : Total Customers, Avg LTV, VIP Count, Active Count
2. Pie Chart : Customer tier distribution
3. Bar Chart : Customer status distribution
4. Histogram : CLV distribution
5. Bar Chart : Average LTV by tier
6. Scatter Plot : Recency vs Frequency (RFM map)
7. Box Plot : Monetary distribution by tier
8. Bar Chart : Predicted CLV by tier/status
9. Data Table : Top 20 customers by LTV
10. Data Table : Customer segments summary
11. Insight Cards (3) : VIP, At-Risk, Revenue Potential

#### Fonctionnalités
- Filtre par customer tier (All/VIP/High/Medium/Low)
- Color coding cohérent par tier
- Metrics avec pourcentages
- Hover data détaillé sur scatter plot

---

### 6. Dashboard 4 : Product Intelligence (100% COMPLET - TESTÉ)

#### Visualisations (8)
1. 4 KPI Cards : Total Products, Total Revenue, Avg Rating, Total Units
2. Bar Chart : Revenue by category
3. Scatter Plot : Price vs Units Sold
4. Histogram : Product Health Score distribution
5. Gauge : Customer Satisfaction rate
6. Data Table : Top 50 products
7. Insight Cards (3) : Best Seller, Highest Rated, At-Risk Products

#### Fonctionnalités
- Filtre par catégorie de produit
- Scatter plot avec size = Revenue
- Health score monitoring
- Satisfaction rate gauge

---

### 7. Dashboard 5 : Cohort & Retention (100% CODE - En attente retest)

#### Visualisations (8)
1. 4 KPI Cards : Total Cohorts, Total Customers, Total Revenue, Avg Retention
2. Heatmap : Cohort retention matrix (RdYlGn color scale)
3. Line Chart : Retention curves by cohort
4. Bar Chart : Cohort sizes over time
5. Bar Chart : Revenue by cohort
6. Data Table : Cohort summary
7. Insight Cards (3) : Best Retention, Largest, Highest Revenue

#### Fonctionnalités
- Auto-detection des colonnes (flexible pour différents schemas)
- Heatmap interactive avec hover
- Multiple retention curves comparées
- Color coding vert/rouge pour performance

#### Note
Les queries utilisent une détection automatique des colonnes pour gérer les différents noms possibles dans la table MART_CUSTOMER_COHORTS. À retester une fois Snowflake disponible.

---

### 8. Dashboard 6 : RFM Segmentation (100% CODE - En attente test)

#### Visualisations (12)
1. 4 KPI Cards : Total Segments, Total Customers, Total LTV, Avg LTV
2. Pie Chart : Customer tier distribution (count)
3. Pie Chart : Revenue contribution by tier
4. Bar Chart : Average Recency by tier
5. Bar Chart : Average Frequency by tier
6. Bar Chart : Customers by status
7. Bar Chart : LTV by status
8. Scatter Plot : RFM Segmentation Map (2000 customers sample)
9. Data Table : Segment summary with all metrics
10. Marketing Recommendation Cards (3) : VIP, At-Risk, Lost

#### Fonctionnalités
- Filtre par customer status
- Scatter plot avec size = Monetary
- Marketing recommendations par segment
- Color coding cohérent (VIP=gold, Active=green, etc.)

---

## Problèmes Résolus

### 1. Incompatibilité Streamlit/Altair
**Problème** : ModuleNotFoundError: No module named 'altair.vegalite.v4'  
**Cause** : Streamlit 1.12.0 incompatible avec Altair 6.0.0  
**Solution** : Downgrade Altair à 4.2.2

### 2. API Cache obsolète
**Problème** : AttributeError: module 'streamlit' has no attribute 'cache_resource'  
**Cause** : cache_resource introduit dans Streamlit 1.18+  
**Solution** :
- `@st.cache_resource` → `@st.experimental_singleton`
- `@st.cache_data` → `@st.cache(allow_output_mutation=True)`

### 3. Schema Snowflake incorrect
**Problème** : Schema 'DBT_ECOMMERCE.ANALYTICS' does not exist  
**Cause** : Schema réel = MARTS_ANALYTICS  
**Solution** : Correction dans .env et data_loader.py

### 4. Tables inexistantes dans queries
**Problème** : fct_orders, dim_customers, mart_rfm_segmentation n'existent pas  
**Cause** : Schéma DBT différent de l'attendu  
**Solution** : Adaptation pour utiliser les tables réelles :
- MART_SALES_DAILY
- MART_CUSTOMER_LIFETIME_VALUE
- MART_PRODUCT_PERFORMANCE
- MART_SALES_BY_CATEGORY
- MART_CUSTOMER_COHORTS
- MART_DELIVERY_KPIS

### 5. Incompatibilité use_container_width
**Problème** : TypeError: dataframe() got an unexpected keyword argument  
**Cause** : Paramètre ajouté dans Streamlit 1.18+  
**Solution** : Retirer use_container_width=True et hide_index=True

### 6. .env ne chargent pas les variables
**Problème** : Variables d'environnement retournent None  
**Cause** : Caractères spéciaux dans le mot de passe  
**Solution** : Entourer le mot de passe de guillemets dans .env

### 7. conda activate ne fonctionne pas
**Problème** : CommandNotFoundError  
**Cause** : Shell zsh pas initialisé pour conda  
**Solution** : `conda init zsh` puis `source ~/.zshrc`

### 8. Trial Snowflake expiré
**Problème** : Connexion échoue après expiration du trial  
**Cause** : Free trial terminé  
**Solution** : En attente de renouvellement pour retester cohort queries

---

## Data Loader - Fonctions Créées (15)

### Executive Summary
- `get_kpi_summary(start_date, end_date)` - KPIs principaux
- `get_revenue_trend(granularity)` - Trend revenue/orders/AOV
- `get_top_categories(limit)` - Top catégories par revenue
- `get_revenue_by_state()` - Distribution géographique

### Sales Performance
- `get_payment_analysis()` - Analyse méthodes de paiement
- `get_delivery_performance()` - Métriques de livraison

### Customer Analytics
- `get_customer_summary()` - Vue d'ensemble clients
- `get_rfm_distribution()` - Distribution RFM segments
- `get_clv_analysis()` - Analyse CLV

### Product Intelligence
- `get_product_performance(limit)` - Performance produits
- `get_category_rankings()` - Rankings par catégorie

### Cohort & Retention
- `get_cohort_retention()` - Données de rétention
- `get_cohort_summary()` - Résumé par cohorte

### Utilities
- `get_date_range()` - Min/Max dates
- `get_row_counts()` - Comptage des rows

---

## Métriques & Performance

### Technique
- **Build time** : ~2 secondes
- **Query time** : <1 seconde (avec cache)
- **Cache TTL** : 3600 secondes
- **Page load** : Instantané après premier chargement

### Visualisations
- **Total visualisations** : 30+
- **Interactivité** : 100% (hover, zoom, pan)
- **Responsive** : Oui (layout wide)
- **Color scheme** : Cohérent sur tous les dashboards

---

## Tables Snowflake Utilisées

| Table | Utilisée dans | Rows |
|-------|--------------|------|
| MART_SALES_DAILY | Executive Summary, Sales Performance | ~700 |
| MART_CUSTOMER_LIFETIME_VALUE | Customer Analytics, RFM | ~99K |
| MART_PRODUCT_PERFORMANCE | Executive Summary, Product Intelligence | ~32K |
| MART_SALES_BY_CATEGORY | Sales Performance | ~2K |
| MART_CUSTOMER_COHORTS | Cohort Retention | ~few hundred |
| MART_DELIVERY_KPIS | Sales Performance | - |

---

## Commandes Utiles

```bash
# Lancer l'application
cd streamlit-dashboards
streamlit run Home.py

# Tester connexion Snowflake
python test_connection.py

# Vérifier structure tables
python check_tables.py

# Vérifier table cohorts
python check_cohort_table.py

# Installer dépendances
pip install -r requirements.txt
```

---

## En attente

### Une fois Snowflake renouvelé
1. Exécuter `python check_cohort_table.py` pour vérifier colonnes
2. Ajuster queries cohort si nécessaire dans data_loader.py
3. Ajuster cohort_retention.py si les noms de colonnes changent
4. Retester Dashboard 5 (Cohort Retention)
5. Tester Dashboard 6 (RFM Segmentation)

### Déploiement (Phase 8)
1. Push code vers GitHub
2. Connecter repo sur share.streamlit.io
3. Configurer secrets dans Streamlit Cloud
4. Obtenir URL publique
5. Créer screenshots pour README/portfolio

---

## Leçons Apprises

### Compatibilité versions
- Toujours vérifier compatibilité entre packages avant d'installer
- Streamlit 1.12.0 a des limitations vs versions récentes
- Downgrade parfois nécessaire pour éviter les conflits

### Snowflake schema
- Toujours vérifier les noms réels dans Snowflake avec DESCRIBE TABLE
- Ne jamais assumer la structure DBT
- Créer des scripts de vérification avant de coder

### Streamlit best practices
- Cache les queries pour la performance
- Charger les données avant de créer les filtres
- Tester section par section, pas tout d'un coup
- Copier/modifier un dashboard existant plutôt que d'en créer un from scratch

### Development workflow
- Créer infrastructure d'abord (connexion, utils)
- Tester la connexion avant les visualisations
- Développer un dashboard template, puis réutiliser
- Commiter après chaque dashboard fonctionnel

---

## Git Commands

```bash
cd dbt-ecommerce-analytics

# Ajouter tous les fichiers streamlit
git add streamlit-dashboards/

# Ne pas oublier .gitignore (exclut .env)
git status

# Commiter
git commit -m "Phase 7: Add Streamlit dashboards (6 dashboards, 30+ visualizations)

- Home.py: Landing page with KPIs and navigation
- Dashboard 1: Executive Summary (revenue, orders, categories, geography)
- Dashboard 2: Sales Performance (trends, payments, delivery)
- Dashboard 3: Customer Analytics (RFM, CLV, segmentation)
- Dashboard 4: Product Intelligence (performance, health scores)
- Dashboard 5: Cohort & Retention (heatmap, retention curves)
- Dashboard 6: RFM Segmentation (marketing recommendations)
- utils/: Snowflake connector, data loader, styling
- 15 pre-defined queries with caching
- Dark theme with consistent color scheme"

# Push
git push origin main
```

---

## Résumé Final

| Métrique | Valeur |
|----------|--------|
| Dashboards créés | 6/6 (100%) |
| Dashboards testés | 4/6 |
| Visualisations | 30+ |
| Fonctions DataLoader | 15 |
| Filtres | 6 (un par dashboard) |
| Bugs résolus | 8 |
| Fichiers créés | 15+ |
| Temps total | ~8h |

---

**Date de mise à jour** : 31 janvier 2026  
**Status** : Code 100% complet - En attente retest cohort (trial Snowflake expiré)  
**Prochaine Phase** : Phase 8 - Déploiement & Production