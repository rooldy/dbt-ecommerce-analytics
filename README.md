# 🛍️ DBT E-commerce Analytics Pipeline

![DBT](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

Pipeline de données end-to-end pour l'analyse d'une plateforme e-commerce, développé avec DBT et Snowflake suivant les meilleures pratiques de l'industrie.

## 📋 Vue d'ensemble

Ce projet implémente une architecture moderne de data warehouse utilisant DBT pour transformer et modéliser les données d'e-commerce du dataset Olist (marketplace brésilien). L'objectif est de créer des modèles analytiques production-ready permettant l'analyse des ventes, des clients, et de la performance produits.

**Dataset** : Brazilian E-Commerce Public Dataset by Olist (~100k commandes, 2016-2018)

## 🏗️ Architecture

### Stack Technique
- **Transformation** : DBT Core 1.8
- **Data Warehouse** : Snowflake
- **Orchestration** : DBT Cloud / GitHub Actions
- **Visualisation** : Metabase / Looker Studio
- **Version Control** : Git/GitHub

### Architecture des données (Medallion)