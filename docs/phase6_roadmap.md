# Phase 6 - Qualité & Tests
## Roadmap détaillée

**Durée estimée** : 3-5 jours  
**Date de début** : 21 janvier 2025  
**Objectif** : >95% de couverture tests + automatisation qualité

---

## 🎯 Objectifs SMART

1. ✅ Créer 5-10 tests SQL personnalisés (custom tests)
2. ✅ Automatiser l'exécution des tests (scripts)
3. ✅ Générer un rapport de qualité des données
4. ✅ Documenter le data lineage complet
5. ✅ Mettre en place des contrôles de cohérence cross-model

---

## 📊 État actuel vs Cible

| Métrique | Actuel | Cible Phase 6 | Gap |
|----------|--------|---------------|-----|
| **Tests génériques** | 224 | 224 | ✅ |
| **Tests custom** | 0 | 10 | 🎯 À faire |
| **Couverture** | ~92% | >95% | +3% |
| **Automatisation** | Manuel | Scripts | 🎯 À faire |
| **Rapport qualité** | ❌ | ✅ | 🎯 À faire |
| **Data lineage** | Partiel | Complet | 🎯 À faire |

---

## 🏗️ Structure des tests custom

```
dbt_ecommerce/
├── tests/
│   ├── generic/                    # Tests réutilisables
│   │   ├── test_valid_percentage.sql
│   │   └── test_positive_value.sql
│   └── singular/                   # Tests spécifiques
│       ├── assert_revenue_consistency.sql
│       ├── assert_no_future_dates.sql
│       ├── assert_reasonable_values.sql
│       ├── assert_clv_logic.sql
│       ├── assert_cohort_retention.sql
│       ├── assert_delivery_dates.sql
│       ├── assert_rfm_segments.sql
│       └── assert_product_rankings.sql
```

---

## 📝 Liste des tests à créer

### A. Tests de cohérence cross-model (5 tests)

#### 1. `assert_revenue_consistency.sql` ⭐
**Objectif** : Vérifier que le revenue est cohérent entre les différents modèles

**Validation** :
- Revenue dans fct_order_items = Revenue dans mart_sales_daily (agrégé)
- Revenue dans mart_product_performance = Somme dans fct_order_items par produit
- Revenue dans dim_orders = Somme dans fct_order_items par order

**Tolérance** : ±0.01 (erreurs d'arrondi acceptables)

#### 2. `assert_no_future_dates.sql` ⭐
**Objectif** : S'assurer qu'aucune date dans le futur n'existe

**Tables à vérifier** :
- fct_orders.order_purchase_date
- fct_order_items.order_purchase_date
- mart_sales_daily.full_date
- mart_customer_cohorts.cohort_month

**Règle** : Toutes les dates ≤ CURRENT_DATE()

#### 3. `assert_reasonable_values.sql` ⭐
**Objectif** : Valider que les métriques sont dans des plages raisonnables

**Validations** :
- price > 0 AND price < 10000 (pas de prix négatifs ou aberrants)
- freight_value >= 0 AND freight_value < 1000
- payment_value > 0 AND payment_value < 50000
- review_score BETWEEN 1 AND 5
- delivery_days BETWEEN 0 AND 200

#### 4. `assert_clv_logic.sql` ⭐
**Objectif** : Vérifier la logique du CLV

**Validations** :
- predicted_clv_12m >= 0
- predicted_clv_12m >= historical_ltv * 0.5 (au moins 50% du LTV historique)
- Pour customers "Lost", predicted_clv_12m = 0
- Pour customers "Active" avec >3 orders, predicted_clv_12m > avg_order_value

#### 5. `assert_cohort_retention.sql` ⭐
**Objectif** : Valider la logique des cohortes

**Validations** :
- retention_rate BETWEEN 0 AND 100
- retention_rate à M0 = 100%
- retention_rate décroissante ou stable (jamais croissante)
- active_customers ≤ cohort_size

---

### B. Tests de qualité données (3 tests)

#### 6. `assert_delivery_dates.sql`
**Objectif** : Cohérence des dates de livraison

**Validations** :
- delivered_date >= order_purchase_date
- delivered_date >= shipped_date
- estimated_delivery_date >= order_purchase_date
- Si delivered_date exists, alors shipped_date exists

#### 7. `assert_rfm_segments.sql`
**Objectif** : Validation de la segmentation RFM

**Validations** :
- Tous les customers ont un RFM score (1-5)
- Distribution raisonnable : ~20% par quintile
- customer_tier correspond bien aux RFM scores
- customer_status cohérent avec recency

#### 8. `assert_product_rankings.sql`
**Objectif** : Cohérence des rankings produits

**Validations** :
- rank_overall_revenue : pas de doublons, séquence continue
- rank_in_category_revenue : commence à 1 pour chaque catégorie
- product_health_score BETWEEN 0 AND 100
- Top 10% products ont revenue_tier = 'Top 10%'

---

### C. Tests de performance (2 tests)

#### 9. `assert_model_freshness.sql`
**Objectif** : Vérifier que les modèles sont à jour

**Validations** :
- mart_sales_daily.max(full_date) >= CURRENT_DATE() - 2
- Pas de trous dans les dates de mart_sales_daily
- fct_orders.max(order_purchase_date) correspond aux sources

#### 10. `assert_null_rates.sql`
**Objectif** : Surveiller les taux de valeurs nulles

**Validations** :
- NULL rate pour delivery_date < 5%
- NULL rate pour review_score < 60% (acceptable car reviews optionnelles)
- NULL rate pour customer_state = 0%

---

## 🛠️ Scripts d'automatisation

### 1. `run_tests.sh` - Exécution complète des tests

**Fonctionnalités** :
- Exécute tous les tests DBT
- Génère un rapport HTML
- Envoie notifications si échecs
- Log les résultats avec timestamp

### 2. `check_data_quality.sh` - Rapport de qualité

**Fonctionnalités** :
- Row counts par modèle
- NULL rates par colonne
- Distribution des segments
- Trends sur 7 derniers jours
- Anomalies détectées

### 3. `monitor_freshness.sh` - Monitoring fraîcheur

**Fonctionnalités** :
- Vérifie la fraîcheur des sources
- Alerte si données > 24h
- Vérifie les builds incrementaux

---

## 📈 Rapport de qualité des données

### Structure du rapport

```
RAPPORT QUALITÉ DES DONNÉES
Date: [timestamp]
Version DBT: 1.8.0
=================================

1. RÉSUMÉ EXÉCUTIF
   - Total tests: 234 (224 generic + 10 custom)
   - Tests réussis: 234 (100%)
   - Couverture: 96%
   - Build time: 2m 45s

2. TESTS PAR COUCHE
   - Staging: 55/55 ✅
   - Intermediate: 63/63 ✅
   - Marts Core: 67/67 ✅
   - Marts Analytics: 39/39 ✅
   - Custom: 10/10 ✅

3. MÉTRIQUES DE QUALITÉ
   - Row counts
   - NULL rates
   - Duplicates
   - Value distributions

4. DATA LINEAGE
   - Source → Staging → Marts
   - Diagramme de dépendances

5. RECOMMANDATIONS
   - Points d'attention
   - Actions à prendre
```

---

## 🎯 Livrables Phase 6

### Code & Tests
- [ ] 10 tests custom SQL (tests/singular/)
- [ ] 2 tests generic réutilisables (tests/generic/)
- [ ] Documentation des tests (_tests.yml)

### Scripts
- [ ] run_tests.sh
- [ ] check_data_quality.sh
- [ ] monitor_freshness.sh
- [ ] generate_quality_report.py

### Documentation
- [ ] DATA_QUALITY_REPORT.md (généré automatiquement)
- [ ] DATA_LINEAGE.md (diagrammes + explications)
- [ ] TESTING_STRATEGY.md (méthodologie)
- [ ] docs/tests/ (documentation détaillée de chaque test)

### Configuration
- [ ] Mise à jour dbt_project.yml (warn/error configs)
- [ ] CI/CD prep (GitHub Actions config)

---

## ⏱️ Planning détaillé

| Jour | Tâches | Durée |
|------|--------|-------|
| **J1** | Tests 1-5 (cohérence) + doc | 3-4h |
| **J2** | Tests 6-10 (qualité) + doc | 3-4h |
| **J3** | Scripts automatisation | 2-3h |
| **J4** | Rapport qualité + lineage | 3-4h |
| **J5** | Tests, debug, finalisation | 2-3h |

**Total** : 13-18h sur 5 jours (rythme confortable)

---

## 🎓 Compétences démontrées

✅ **Testing avancé** :
- Tests génériques vs singuliers
- Tests cross-model
- Tests de logique métier
- Data quality monitoring

✅ **Automatisation** :
- Scripts bash avancés
- Génération de rapports
- Monitoring continu

✅ **Data Governance** :
- Documentation lineage
- Quality metrics
- Best practices testing

✅ **DevOps/DataOps** :
- CI/CD preparation
- Monitoring & alerting
- Automated testing

---

## 💡 Conseils pour la Phase 6

1. **Commencez simple** : Tests de cohérence d'abord
2. **Itérez** : Un test à la fois, validez, commitez
3. **Documentez** : Chaque test doit avoir un but clair
4. **Automatisez tôt** : Scripts dès que 3-4 tests créés
5. **Pensez production** : Tests qui alertent vraiment

---

## 🚀 Prêt à démarrer ?

**Premier test à créer** : `assert_revenue_consistency.sql`

C'est le test le plus important - il valide que votre pipeline de transformation est cohérent de bout en bout.

Voulez-vous que je crée ce premier test ?
