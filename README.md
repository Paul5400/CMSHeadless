# CMSHeadless - TD3 Directus

Ce projet a été réalisé dans le cadre du TD3 sur les systèmes de gestion de contenu Headless (CMS). Il utilise **Directus** pour exposer une base de données existante (TD2) via une API REST.

## 🚀 Installation rapide

1. **Lancer l'infrastructure Docker :**
   ```bash
   docker compose up -d
   ```

2. **Initialiser le modèle et les données :**
   Assurez-vous que les scripts ont les droits d'exécution :
   ```bash
   chmod +x setup_directus.sh test_api.sh
   ./setup_directus.sh
   ```

## 🛠 Configuration

- **Directus URL :** [http://localhost:8082](http://localhost:8082)
- **Identifiants Admin :**
  - **Email :** `admin@example.com`
  - **Mot de passe :** `password`
- **Services :**
  - **Directus** (Port 8082)
  - **PostgreSQL** (Port 5432 interne)
  - **Redis** (Port 6379 interne)

## 📊 Structure du Projet

- `sql/` : Contient les dumps SQL (schéma et données) du TD2.
- `setup_directus.sh` : Script automatisé pour créer les collections, relations et injecter les données.
- `test_api.sh` : Script de test permettant de valider les 7 requêtes de l'énoncé.
- `rapport_td3_directus.html` : Compte rendu détaillé avec captures d'écran et interprétations.

## 🧪 Tests de l'API

Une fois le setup terminé, vous pouvez lancer les tests automatisés :
```bash
./test_api.sh
```

## 📝 Compte Rendu

Le fichier `rapport_td3_directus.html` contient l'ensemble des preuves de fonctionnement, incluant :
- L'architecture Docker.
- Les preuves visuelles de l'interface Directus.
- Les résultats JSON granulaires des requêtes API REST.
