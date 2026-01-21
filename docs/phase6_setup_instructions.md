# Phase 6 - Instructions de mise en place des tests

## 📁 Structure des dossiers à créer

```bash
# Depuis dbt-ecommerce-analytics/
cd dbt_ecommerce

# Créer la structure des tests
mkdir -p tests/singular
mkdir -p tests/generic
mkdir -p tests/docs
```

## 📝 Étape 1 : Créer les 3 premiers tests

### Test 1: Revenue Consistency

```bash
# Créer le fichier
touch tests/singular/assert_revenue_consistency.sql

# Copier le contenu depuis l'artifact "assert_revenue_consistency.sql"
nano tests/singular/assert_revenue_consistency.sql
```

### Test 2: No Future Dates

```bash
# Créer le fichier
touch tests/singular/assert_no_future_dates.sql

# Copier le contenu depuis l'artifact "assert_no_future_dates.sql"
nano tests/singular/assert_no_future_dates.sql
```

### Test 3: Reasonable Values

```bash
# Créer le fichier
touch tests/singular/assert_reasonable_values.sql

# Copier le contenu depuis l'artifact "assert_reasonable_values.sql"
nano tests/singular/assert_reasonable_values.sql
```

---

## 🧪 Étape 2 : Exécuter les tests

### Test individuel

```bash
# Depuis dbt_ecommerce/

# Tester la cohérence des revenues
dbt test --select test_name:assert_revenue_consistency

# Tester les dates futures
dbt test --select test_name:assert_no_future_dates

# Tester les valeurs raisonnables
dbt test --select test_name:assert_reasonable_values
```

### Tous les tests custom

```bash
# Tous les tests dans tests/singular/
dbt test --select test_type:singular
```

### Tous les tests du projet

```bash
# 224 tests existants + 3 nouveaux = 227 tests
dbt test
```

---

## 📊 Étape 3 : Analyser les résultats

### Résultats attendus

#### ✅ Test 1 - Revenue Consistency
**Attendu** : 0 rows (tout est cohérent)

Si des lignes apparaissent :
- Vérifier les calculs de revenue dans les modèles concernés
- Investiguer les arrondis
- Comparer manuellement quelques valeurs

#### ✅ Test 2 - No Future Dates
**Attendu** : 0 rows (aucune date future)

Si des lignes apparaissent :
- Vérifier les données sources
- Corriger les dates erronées
- Recharger les données si nécessaire

#### ⚠️ Test 3 - Reasonable Values
**Attendu** : 0-10 rows (quelques outliers possibles)

Si >10 lignes :
- Analyser les violations par type
- Déterminer si ce sont des erreurs ou des cas légitimes
- Documenter les outliers connus
- Ajuster les seuils si nécessaire

---

## 📈 Étape 4 : Documenter les résultats

### Créer le fichier de documentation

```bash
# Depuis dbt_ecommerce/
touch tests/docs/test_results_phase6.md
```

### Template de documentation

```markdown
# Phase 6 - Résultats des Tests Custom
Date: [YYYY-MM-DD HH:MM]
Exécuteur: Rooldy Alphonse

## Tests exécutés

### 1. assert_revenue_consistency.sql
- **Status**: ✅ PASS / ❌ FAIL
- **Rows returned**: X
- **Durée**: X.XXs
- **Observations**: [Notes]

### 2. assert_no_future_dates.sql
- **Status**: ✅ PASS / ❌ FAIL
- **Rows returned**: X
- **Durée**: X.XXs
- **Observations**: [Notes]

### 3. assert_reasonable_values.sql
- **Status**: ⚠️ WARN
- **Rows returned**: X
- **Durée**: X.XXs
- **Observations**: [Liste des violations détectées]

## Métriques globales
- Total tests projet: 227 (224 + 3)
- Tests réussis: XXX
- Tests échoués: XXX
- Couverture: XX%

## Actions requises
1. [Action 1]
2. [Action 2]

## Prochaines étapes
- [ ] Créer tests 4-10
- [ ] Scripts d'automatisation
- [ ] Rapport de qualité
```

---

## 🔄 Étape 5 : Itération et amélioration

### Si un test échoue

1. **Ne pas paniquer** - c'est le but des tests !
2. **Analyser** les résultats retournés
3. **Investiguer** les modèles concernés
4. **Corriger** le problème OU ajuster le test
5. **Re-tester** jusqu'à succès
6. **Documenter** ce qui a été corrigé

### Si tous les tests passent

1. **Célébrer** 🎉
2. **Commiter** les tests
3. **Passer** aux tests 4-7
4. **Continuer** la Phase 6

---

## 📝 Commandes Git pour commiter

```bash
# Depuis dbt-ecommerce-analytics/

# Vérifier les nouveaux fichiers
git status

# Ajouter les tests
git add dbt_ecommerce/tests/

# Commit avec message descriptif
git commit -m "🧪 Phase 6: Add first 3 custom tests (revenue consistency, future dates, reasonable values)

- assert_revenue_consistency.sql: Cross-model revenue validation
- assert_no_future_dates.sql: Prevent future dates in data
- assert_reasonable_values.sql: Business range validation
- All tests passing with X/227 total tests"

# Push
git push origin main
```

---

## 🎯 Prochaines étapes après ces 3 tests

### Tests 4-7 (Logique métier)
- [ ] assert_clv_logic.sql
- [ ] assert_cohort_retention.sql
- [ ] assert_delivery_dates.sql
- [ ] assert_rfm_segments.sql

### Tests 8-10 (Performance & Monitoring)
- [ ] assert_product_rankings.sql
- [ ] assert_model_freshness.sql
- [ ] assert_null_rates.sql

### Scripts d'automatisation
- [ ] run_tests.sh
- [ ] check_data_quality.sh
- [ ] monitor_freshness.sh

---

## 💡 Conseils

1. **Testez un par un** : Plus facile à déboguer
2. **Documentez immédiatement** : Notez vos observations
3. **Commitez souvent** : Après chaque test validé
4. **Soyez pragmatique** : Ajustez les seuils si nécessaire
5. **Pensez production** : Ces tests tourneront en automatique

---

## ❓ FAQ

**Q: Un test retourne des lignes, est-ce grave ?**  
R: Pas nécessairement. Analysez les résultats. Certains cas peuvent être légitimes.

**Q: Combien de temps pour exécuter les tests ?**  
R: ~10-30 secondes par test custom, ~2-3 minutes pour tous les tests.

**Q: Dois-je corriger toutes les violations ?**  
R: Priorisez les violations critiques (revenue, dates). Les outliers peuvent être documentés.

**Q: Et si je veux changer les seuils ?**  
R: Modifiez les valeurs dans le WHERE des tests et documentez pourquoi.

---

## 🚀 Prêt à commencer ?

```bash
# Commande pour tout faire d'un coup
cd dbt_ecommerce
mkdir -p tests/singular tests/generic tests/docs
# Puis créez les 3 fichiers SQL et lancez les tests !
```

**Bonne chance ! 🎯**
