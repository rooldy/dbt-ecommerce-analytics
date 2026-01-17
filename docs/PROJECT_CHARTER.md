# Charte de Projet - DBT E-commerce Analytics Pipeline

## 📋 Informations du projet

| Attribut | Valeur |
|----------|--------|
| **Nom du projet** | DBT E-commerce Analytics Pipeline |
| **Chef de projet** | Rooldy Alphonse |
| **Date de début** | Janvier 2025 |
| **Durée estimée** | 6-8 semaines |
| **Status** | ✅ Phase 0 - Initiation (Complétée) |
| **Repository** | https://github.com/rooldy/dbt-ecommerce-analytics |

---

## 1. CONTEXTE ET JUSTIFICATION

### 1.1 Contexte métier

L'analyse des données e-commerce est cruciale pour comprendre le comportement client, optimiser les opérations, et maximiser les revenus. Ce projet simule la mise en place d'un data warehouse moderne pour une plateforme e-commerce.

**Dataset** : Olist (marketplace brésilien, ~100k commandes, 2016-2018)

### 1.2 Problématiques métier à résoudre

1. **Manque de visibilité sur les performances**
   - Pas de vue consolidée des ventes
   - KPIs dispersés et difficiles à calculer
   - Reporting manuel et chronophage

2. **Compréhension limitée des clients**
   - Pas de segmentation claire
   - Lifetime value inconnue
   - Difficile d'identifier les clients à risque de churn

3. **Optimisation opérationnelle**
   - Délais de livraison non analysés
   - Performance vendeurs non mesurée
   - Problèmes qualité non détectés

4. **Décisions basées sur l'intuition**
   - Pas de données fiables pour les décisions
   - Analyse ad-hoc réactive plutôt que proactive
   - Opportunités de croissance manquées

### 1.3 Justification du projet

**Pourquoi maintenant ?**
- Les données sont disponibles mais sous-exploitées
- Besoin de passer d'un mode réactif à proactif
- Opportunité de mettre en place une infrastructure moderne

**Valeur attendue :**
- ⏱️ Gain de temps : -80% sur le reporting manuel
- 📊 Meilleure visibilité : Dashboards temps réel
- 💰 Optimisation : Identification des opportunités de croissance
- 🎯 Décisions data-driven : Basées sur des faits, pas des opinions

---

## 2. OBJECTIFS DU PROJET

### 2.1 Objectifs SMART

#### Objectif 1 : Infrastructure de données moderne
**Spécifique** : Mettre en place un data warehouse dans Snowflake avec DBT  
**Mesurable** : 40+ modèles DBT, 3 couches de transformation  
**Atteignable** : Technologies standard de l'industrie  
**Réaliste** : 6-8 semaines avec ressources disponibles  
**Temporel** : Déploiement Phase 8 (semaine 8)

#### Objectif 2 : Modèles analytiques métier
**Spécifique** : Créer des modèles pour analyser ventes, clients, produits  
**Mesurable** : 6-8 marts analytiques avec KPIs définis  
**Atteignable** : Dataset complet disponible  
**Réaliste** : Cas d'usage e-commerce standards  
**Temporel** : Livrables Phase 5 (semaine 5)

#### Objectif 3 : Qualité et fiabilité des données
**Spécifique** : Implémenter tests de qualité sur tous les modèles  
**Mesurable** : >85% de couverture de tests, 100% de succès  
**Atteignable** : Framework DBT intégré  
**Réaliste** : Tests génériques + personnalisés  
**Temporel** : Validation Phase 6 (semaine 6)

#### Objectif 4 : Visualisation et adoption
**Spécifique** : Créer 3-4 dashboards pour différents profils utilisateurs  
**Mesurable** : Dashboards Executive, Customer, Product, Operations  
**Atteignable** : Outils BI gratuits disponibles  
**Réaliste** : Basé sur les marts créés  
**Temporel** : Démo Phase 7 (semaine 7)

### 2.2 Critères de succès

| Critère | Objectif | Mesure |
|---------|----------|--------|
| **Technique** | Infrastructure opérationnelle | DBT + Snowflake fonctionnels |
| **Qualité** | Données fiables | >85% tests passants |
| **Performance** | Pipeline efficace | Build complet <5 min |
| **Documentation** | Code maintenable | 100% modèles documentés |
| **Business** | Valeur métier | 4 dashboards livrés |
| **Coûts** | Budget respecté | Snowflake <10$ USD |

---

## 3. PÉRIMÈTRE DU PROJET

### 3.1 Dans le périmètre

**Sources de données**
- ✅ Dataset Olist (9 tables CSV)
- ✅ ~100k commandes (2016-2018)
- ✅ Données clients, produits, vendeurs, paiements, avis

**Transformations**
- ✅ Couche Staging (nettoyage, standardisation)
- ✅ Couche Intermediate (logique métier)
- ✅ Couche Marts (modèles analytiques)

**Cas d'usage métier**
- ✅ Analyse des ventes (trends, saisonnalité, KPIs)
- ✅ Analyse clients (CLV, segmentation RFM, cohortes)
- ✅ Analyse produits (performance, recommandations)
- ✅ Analyse opérationnelle (livraisons, vendeurs)

**Livrables techniques**
- ✅ 40-50 modèles DBT
- ✅ Tests de qualité (>50 tests)
- ✅ Documentation complète (DBT docs)
- ✅ 4 dashboards opérationnels
- ✅ Code production-ready sur GitHub

### 3.2 Hors périmètre

**Sources de données**
- ❌ Données en temps réel / streaming
- ❌ Autres sources externes (CRM, Marketing, etc.)
- ❌ APIs tierces

**Fonctionnalités**
- ❌ Machine Learning / Prédictions avancées
- ❌ Recommandation produits ML (seulement règles simples)
- ❌ Alerting automatique
- ❌ Application web front-end

**Infrastructure**
- ❌ Orchestration complexe (Airflow complet)
- ❌ Infrastructure cloud complète (multi-env)
- ❌ Monitoring avancé (Datadog, New Relic)

### 3.3 Hypothèses et contraintes

**Hypothèses**
- Les données Olist sont représentatives d'un e-commerce réel
- Snowflake trial (400$ crédits) suffisant pour le projet
- Pas de données sensibles (RGPD OK)
- Dataset statique (pas de refresh)

**Contraintes**
- **Budget** : 0$ (trial Snowflake, outils gratuits uniquement)
- **Temps** : 6-8 semaines
- **Ressources** : 1 personne (projet solo)
- **Technologie** : Stack moderne (DBT + Snowflake obligatoire)

---

## 4. PARTIES PRENANTES

### 4.1 Équipe projet (simulation)

| Rôle | Responsabilité | Temps |
|------|----------------|-------|
| **Analytics Engineer** | Architecture, modélisation, DBT | 60% |
| **Data Engineer** | Infrastructure, pipeline, Snowflake | 20% |
| **Data Analyst** | Métriques métier, dashboards | 15% |
| **DataOps Engineer** | Déploiement, tests, CI/CD | 5% |

*Note : Tous ces rôles sont assumés par une seule personne dans ce projet d'apprentissage*

### 4.2 Utilisateurs finaux (simulation)

| Profil | Besoins | Dashboard |
|--------|---------|-----------|
| **Executive / C-Level** | Vue d'ensemble KPIs, tendances stratégiques | Executive Dashboard |
| **Marketing Manager** | Segmentation clients, CLV, rétention | Customer Analytics |
| **Product Manager** | Performance produits, catégories, avis | Product Performance |
| **Operations Manager** | Livraisons, vendeurs, qualité service | Operations Dashboard |

---

## 5. APPROCHE ET MÉTHODOLOGIE

### 5.1 Méthodologie

**Approche Agile / Itérative**
- Développement par phases (0 à 9)
- Livrables incrémentaux
- Tests continus
- Documentation as code

**Philosophie**
- **Qualité > Quantité** : Mieux vaut moins de modèles bien faits
- **Documentation continue** : Documenter au fur et à mesure
- **Testing first** : Tests dès le développement, pas à la fin
- **Best practices** : Suivre les standards de l'industrie

### 5.2 Stack technologique

#### Infrastructure
- **Data Warehouse** : Snowflake (Standard Edition, trial)
- **Transformation** : DBT Core 1.8
- **Orchestration** : DBT Cloud ou GitHub Actions
- **Version Control** : Git/GitHub

#### Développement
- **Langage** : SQL (DBT/Jinja) + Python (scripts)
- **IDE** : VSCode
- **Testing** : DBT tests (generic + singular)
- **Documentation** : DBT docs + Markdown

#### Visualisation
- **BI Tool** : Metabase (gratuit, open-source)
- **Alternative** : Looker Studio ou Tableau Public

#### Coûts estimés
- Snowflake : 0$ (trial 400$ crédits, usage estimé <10$)
- DBT Core : 0$ (open-source)
- GitHub : 0$ (repo public)
- Metabase : 0$ (open-source)
- **Total : 0$**

### 5.3 Justification des choix technologiques

**Pourquoi Snowflake ?**
- ✅ Standard de l'industrie
- ✅ Séparation compute/storage
- ✅ Trial généreux (400$)
- ✅ Facile à prendre en main
- ✅ Excellent pour le CV

**Pourquoi DBT ?**
- ✅ Tool moderne de transformation
- ✅ Software engineering pour analytics (tests, docs, version control)
- ✅ Community active et ressources abondantes
- ✅ Très demandé sur le marché
- ✅ Open-source (DBT Core)

**Pourquoi cette architecture en couches ?**
- ✅ Séparation des responsabilités (SoC)
- ✅ Réutilisabilité du code
- ✅ Facilite maintenance et évolution
- ✅ Best practice reconnue (Medallion architecture)

---

## 6. ORGANISATION DU PROJET

### 6.1 Planning par phases

| Phase | Nom | Durée | Livrables clés |
|-------|-----|-------|----------------|
| **0** | Initiation & Cadrage | 2-3j | ✅ Charte, architecture, repo |
| **1** | Setup & Infrastructure | 3-5j | Snowflake + DBT configurés |
| **2** | Couche Staging | 5-7j | 9 modèles staging + tests |
| **3** | Couche Intermediate | 5-7j | 6-8 modèles intermediate |
| **4** | Marts Core | 5-7j | Star schema (facts + dims) |
| **5** | Marts Analytics | 5-7j | 6-8 marts métier (CLV, cohortes) |
| **6** | Qualité & Tests | 3-5j | >85% couverture tests |
| **7** | Visualisation | 4-6j | 4 dashboards opérationnels |
| **8** | Déploiement | 3-5j | Production + CI/CD |
| **9** | Maintenance | Continue | Monitoring, évolutions |

**Durée totale** : 6-8 semaines (30-40 jours ouvrés)

### 6.2 Jalons (Milestones)

| Jalon | Date cible | Critère de validation |
|-------|-----------|----------------------|
| 🏁 **M0** : Projet initialisé | S0 | ✅ Repo GitHub + docs cadrage |
| 🏁 **M1** : Infrastructure opérationnelle | S1 | DBT + Snowflake connectés |
| 🏁 **M2** : Données nettoyées | S2 | Staging layer complet |
| 🏁 **M3** : Logique métier implémentée | S3 | Intermediate layer complet |
| 🏁 **M4** : Modèle dimensionnel créé | S4 | Star schema validé |
| 🏁 **M5** : Métriques métier disponibles | S5 | Marts analytics fonctionnels |
| 🏁 **M6** : Qualité garantie | S6 | Tests >85% passants |
| 🏁 **M7** : Dashboards livrés | S7 | 4 dashboards opérationnels |
| 🎯 **M8** : Mise en production | S8 | Pipeline automatisé |

### 6.3 Gestion des risques

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| **Crédits Snowflake épuisés** | Faible | Élevé | Auto-suspend, monitoring usage |
| **Complexité sous-estimée** | Moyenne | Moyen | Buffer dans planning, MVP approach |
| **Qualité dataset insuffisante** | Faible | Moyen | Exploration préalable, documentation anomalies |
| **Problèmes techniques** | Moyenne | Faible | Documentation, communauté DBT, Stack Overflow |
| **Scope creep** | Moyenne | Moyen | Périmètre strict, backlog pour évolutions |

---

## 7. COMMUNICATION ET DOCUMENTATION

### 7.1 Livrables documentaires

| Document | Statut | Localisation |
|----------|--------|--------------|
| **Charte projet** | ✅ Complété | docs/PROJECT_CHARTER.md |
| **Architecture** | ✅ Complété | docs/architecture.md |
| **Setup guide** | ✅ Complété | setup_guide.md |
| **README** | ✅ Complété | README.md |
| **DBT docs** | 🔄 En cours | Généré par DBT |
| **Runbook** | ⏳ Phase 8 | docs/RUNBOOK.md |
| **Learnings** | ⏳ Phase 9 | docs/LEARNINGS.md |

### 7.2 Standards de communication

**Git commits**
- Format : `type: description` (conventional commits)
- Types : feat, fix, docs, refactor, test, chore
- Langue : Anglais

**Documentation code**
- Tous les modèles DBT documentés (description + colonnes)
- Commentaires SQL pour logique complexe
- README dans chaque dossier principal

**Revues**
- Auto-review du code avant commit
- Documentation des décisions techniques
- Learnings capturés régulièrement

---

## 8. MESURE DU SUCCÈS

### 8.1 KPIs du projet

**Techniques**
- [ ] 100% des modèles DBT se construisent sans erreur
- [ ] >85% de couverture de tests
- [ ] Build complet <5 minutes
- [ ] 0 credentials exposés dans Git

**Qualité**
- [ ] 100% des modèles documentés
- [ ] Lineage graph clair et organisé
- [ ] Tests passent à 100%
- [ ] Code suit les conventions

**Business Value**
- [ ] 4 dashboards opérationnels
- [ ] CLV calculée et validée
- [ ] Analyse de cohortes fonctionnelle
- [ ] KPIs métier cohérents

**Apprentissage**
- [ ] Maîtrise de DBT
- [ ] Compétence Snowflake
- [ ] Portfolio project complet
- [ ] Prêt pour poste Analytics Engineer

### 8.2 Critères d'acceptation finaux

✅ Le projet est considéré comme réussi si :

1. **Infrastructure** : Pipeline DBT + Snowflake opérationnel
2. **Code** : Repository GitHub professionnel et bien organisé
3. **Modèles** : 40+ modèles DBT fonctionnels et testés
4. **Qualité** : >85% tests passants, documentation complète
5. **Business** : 4 dashboards avec KPIs métier validés
6. **Production** : Code déployable et maintenable
7. **Budget** : Coûts Snowflake <10$ USD

---

## 9. APPROBATIONS

| Rôle | Nom | Date | Signature |
|------|-----|------|-----------|
| **Chef de projet** | Rooldy Alphonse | 2025-01-17 | ✅ Approuvé |
| **Sponsor (simulation)** | Executive Team | 2025-01-17 | ✅ Approuvé |

---

## 10. ANNEXES

### A. Glossaire

- **DBT** : Data Build Tool - Outil de transformation SQL
- **Snowflake** : Data warehouse cloud
- **Marts** : Modèles analytiques finaux optimisés pour la BI
- **SCD** : Slowly Changing Dimension
- **CLV** : Customer Lifetime Value
- **RFM** : Recency, Frequency, Monetary (segmentation)

### B. Références

- [DBT Documentation](https://docs.getdbt.com/)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [Olist Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- [Kimball Dimensional Modeling](https://www.kimballgroup.com/)

---

**Document version** : 1.0  
**Dernière mise à jour** : 2025-01-17  
**Auteur** : Rooldy Alphonse  
**Status** : ✅ Approuvé