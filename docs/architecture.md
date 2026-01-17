# Architecture Technique - DBT E-commerce Analytics

**Version** : 1.0  
**Date** : 2025-01-17  
**Auteur** : Rooldy Alphonse

---

## 1. VUE D'ENSEMBLE

### 1.1 Objectif de l'architecture

Créer une infrastructure moderne de data warehouse utilisant Snowflake et DBT pour transformer des données e-commerce brutes en modèles analytiques exploitables.

### 1.2 Principes directeurs

- **Simplicité** : Architecture claire et maintenable
- **Modularité** : Séparation des responsabilités par couches
- **Qualité** : Tests et validation à chaque niveau
- **Performance** : Optimisé pour les dashboards BI
- **Évolutivité** : Prêt pour de nouvelles sources de données

---

## 2. ARCHITECTURE EN COUCHES (MEDALLION)

### 2.1 Couche Bronze - RAW

**Objectif** : Stocker les données brutes sans transformation

**Schema Snowflake** : `RAW`

**Tables** :
- RAW_ORDERS
- RAW_CUSTOMERS
- RAW_ORDER_ITEMS
- RAW_PRODUCTS
- RAW_PAYMENTS
- RAW_REVIEWS
- RAW_SELLERS
- RAW_GEOLOCATION
- RAW_PRODUCT_TRANSLATION

**Caractéristiques** :
- Données brutes telles qu'extraites des CSV
- Aucune transformation
- Archive historique
- Chargement via script Python

### 2.2 Couche Silver - STAGING

**Objectif** : Nettoyage et standardisation

**Schema Snowflake** : `STAGING`

**Modèles DBT** : 9 modèles (stg_orders, stg_customers, etc.)

**Transformations** :
- Renommage des colonnes (snake_case)
- Typage des colonnes (dates, nombres)
- Nettoyage des valeurs (trim, lowercase)
- Suppression des doublons
- Filtrage des données invalides

**Matérialisation** : Views (économie de storage)

### 2.3 Couche Silver - INTERMEDIATE

**Objectif** : Logique métier et enrichissements

**Schema Snowflake** : `INTERMEDIATE`

**Modèles DBT** : 6-8 modèles (int_orders_enriched, etc.)

**Transformations** :
- Jointures entre tables staging
- Calculs métier (montants, délais)
- Enrichissements (ajout de métriques)
- Agrégations préliminaires

**Matérialisation** : Views

### 2.4 Couche Gold - MARTS CORE

**Objectif** : Modèle dimensionnel (star schema)

**Schema Snowflake** : `MARTS_CORE`

**Modèles DBT** :
- **Facts** : fct_orders, fct_order_items
- **Dimensions** : dim_customers, dim_products, dim_sellers, dim_date

**Caractéristiques** :
- Star schema optimisé pour BI
- Surrogate keys
- SCD (Slowly Changing Dimensions) si nécessaire
- Performance optimale pour dashboards

**Matérialisation** : Tables

### 2.5 Couche Gold - MARTS ANALYTICS

**Objectif** : Métriques et KPIs métier

**Schema Snowflake** : `MARTS_ANALYTICS`

**Modèles DBT** :
- mart_customer_lifetime_value
- mart_customer_cohorts
- mart_sales_daily
- mart_product_performance
- mart_delivery_kpis
- mart_seller_performance

**Matérialisation** : Tables

---

## 3. INFRASTRUCTURE SNOWFLAKE

### 3.1 Configuration Database
```
DATABASE: DBT_ECOMMERCE
├── SCHEMA: RAW
├── SCHEMA: STAGING
├── SCHEMA: INTERMEDIATE
├── SCHEMA: MARTS_CORE
└── SCHEMA: MARTS_ANALYTICS
```

### 3.2 Configuration Warehouse
```
WAREHOUSE: DBT_WH
- Size: XSMALL
- Auto-suspend: 60 secondes
- Auto-resume: TRUE
- Type: Standard
```

**Justification** :
- XSMALL : Dataset <100k lignes, suffisant
- Auto-suspend rapide : Optimiser coûts trial
- Standard : Pas besoin de multi-cluster

### 3.3 Sécurité et rôles
```
ROLE: DBT_ROLE
- Permissions USAGE sur DBT_WH
- Permissions ALL sur DBT_ECOMMERCE
- Principe de moindre privilège
```

---

## 4. ARCHITECTURE DBT

### 4.1 Structure du projet
```
dbt_ecommerce/
├── dbt_project.yml
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
│       ├── core/
│       └── analytics/
├── macros/
├── tests/
├── snapshots/
└── seeds/
```

### 4.2 Stratégie de matérialisation

| Couche | Matérialisation | Raison |
|--------|----------------|--------|
| Staging | view | Légères, économie storage |
| Intermediate | view | Rarement requêtées directement |
| Marts Core | table | Performance BI |
| Marts Analytics | table | Agrégations lourdes |

### 4.3 Conventions de nommage

**Modèles** :
- Staging : `stg_<source>__<entity>.sql`
- Intermediate : `int_<descriptif>.sql`
- Facts : `fct_<entity>.sql`
- Dimensions : `dim_<entity>.sql`
- Marts : `mart_<descriptif>.sql`

**Colonnes** :
- snake_case
- Clés primaires : `<entity>_key`
- Clés étrangères : `<referenced_entity>_key`
- Booléens : `is_<condition>`, `has_<attribute>`

---

## 5. MODÈLE DE DONNÉES

### 5.1 Star Schema (MARTS_CORE)

**Facts** :
- `fct_orders` : Grain = 1 commande
- `fct_order_items` : Grain = 1 item dans une commande

**Dimensions** :
- `dim_customers` : SCD Type 1
- `dim_products` : SCD Type 2 (avec historique)
- `dim_sellers` : SCD Type 1
- `dim_date` : Dimension de dates générée

**Relations** :
- Foreign keys entre facts et dimensions
- Tests de référential integrity

### 5.2 Marts analytiques principaux

**Customer Analytics** :
- CLV (Customer Lifetime Value)
- Segmentation RFM
- Analyse de cohortes
- Taux de rétention

**Product Analytics** :
- Performance par produit/catégorie
- Analyse des avis
- Recommendations (règles simples)

**Sales Analytics** :
- Tendances quotidiennes/mensuelles
- Saisonnalité
- Panier moyen

**Operations** :
- KPIs de livraison
- Performance vendeurs
- Analyse géographique

---

## 6. FLUX DE DONNÉES

### 6.1 Pipeline de transformation
```
CSV Files → Python Script → RAW (Snowflake)
  → DBT Staging → DBT Intermediate
  → DBT Marts Core → DBT Marts Analytics
  → Dashboards BI
```

### 6.2 Dépendances (DAG)

Les modèles DBT sont organisés en DAG (Directed Acyclic Graph) :
- Sources → Staging → Intermediate → Marts
- Visible via `dbt docs generate`

---

## 7. STRATÉGIE DE TESTS

### 7.1 Tests génériques (DBT built-in)

- `unique` : Clés primaires
- `not_null` : Colonnes obligatoires
- `relationships` : Intégrité référentielle
- `accepted_values` : Énumérations

### 7.2 Tests personnalisés

- Cohérence des montants
- Dates logiques (order_date <= delivery_date)
- Sommes reconciliées entre faits et agrégations

**Objectif** : >85% couverture, 100% succès

---

## 8. DÉPLOIEMENT ET ENVIRONNEMENTS

### 8.1 Environnements

| Environnement | Usage | Schema par défaut |
|---------------|-------|-------------------|
| **dev** | Développement local | STAGING |
| **prod** | Production, dashboards | MARTS_ANALYTICS |

### 8.2 Workflow Git
```
main (production)
  ↑
dev (intégration)
  ↑
feature/* (développement)
```

### 8.3 CI/CD (Phase 8)

Options :
- **GitHub Actions** : Automatisation sur push
- **DBT Cloud** : Scheduling, monitoring

---

## 9. PERFORMANCE ET OPTIMISATION

### 9.1 Optimisations Snowflake

- Warehouse XSMALL suffisant
- Auto-suspend pour économiser crédits
- Caching automatique des requêtes
- Clustering non nécessaire (volume faible)

### 9.2 Optimisations DBT

- Sélection de modèles : `dbt run --select staging.*`
- Incremental models (Phase future si besoin)
- Macros pour réutilisation du code

---

## 10. SÉCURITÉ

### 10.1 Gestion des credentials

**Jamais commiter** :
- Passwords Snowflake
- API keys
- Fichiers de service account

**Bonnes pratiques** :
- Credentials dans `~/.dbt/profiles.yml` (local)
- Variables d'environnement (`.env`)
- Secrets GitHub pour CI/CD

### 10.2 RGPD

Dataset Olist :
- Données anonymisées
- Pas de PII (Personally Identifiable Information)
- OK pour usage pédagogique

---

## 11. MONITORING (Phase 8-9)

### 11.1 Métriques à suivre

**Performance** :
- Temps d'exécution DBT run
- Utilisation warehouse Snowflake

**Qualité** :
- Taux de succès des tests
- Row counts par table

**Coûts** :
- Crédits Snowflake consommés

### 11.2 Alerting

Conditions d'alerte :
- Tests DBT échouent
- Build time >10 minutes
- Crédits >90% utilisés

---

## 12. ÉVOLUTIONS FUTURES

### Court terme (post-Phase 8)
- Incremental models
- Snapshots SCD Type 2
- Macros avancées
- Tests personnalisés étendus

### Moyen terme
- Nouvelles sources (CRM, Marketing)
- Machine Learning (prédictions)
- Real-time avec Snowflake Streams

### Long terme
- Multi-tenant architecture
- Data mesh patterns
- Advanced governance

---

## 13. DÉCISIONS TECHNIQUES CLÉS

| Décision | Alternative | Justification |
|----------|-------------|---------------|
| Snowflake | BigQuery | Trial généreux, standard industrie |
| DBT Core | DBT Cloud | Gratuit, apprentissage fondamentaux |
| Views (staging) | Tables | Économie storage, perf OK |
| Tables (marts) | Views | Performance dashboards |
| Star schema | OBT | Best practice, évolutif |

---

## 14. RÉFÉRENCES

- [DBT Best Practices](https://docs.getdbt.com/guides/best-practices)
- [Kimball Dimensional Modeling](https://www.kimballgroup.com/)
- [Snowflake Best Practices](https://docs.snowflake.com/en/user-guide/ui-snowsight-best-practices)

---

**Status** : ✅ Document approuvé  
**Prochaine révision** : Après Phase 4 (Star Schema implémenté)