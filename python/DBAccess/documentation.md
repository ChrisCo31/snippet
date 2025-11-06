# PostgreSQL Read Access Granter

## Description
Script Python automatisant l'attribution de privilèges lecture seule à un utilisateur PostgreSQL sur l'ensemble des bases de données d'un serveur.

## Prérequis
- Python 3.6+
- `psql` installé et accessible dans le PATH
- Accès admin PostgreSQL

## Installation
```bash
chmod +x grant_read_access.py
```

## Utilisation
```bash
./grant_read_access.py
```

Le script vous demandera :
- Adresse du serveur PostgreSQL
- Port (défaut: 5432)
- Utilisateur admin
- Mot de passe admin (masqué)
- Utilisateur cible pour les droits lecture

## Privilèges accordés
Pour chaque base de données :
- `CONNECT` sur la base
- `USAGE` sur le schéma public
- `SELECT` sur toutes les tables existantes
- `SELECT` sur toutes les séquences existantes
- `SELECT` par défaut sur les futures tables/séquences

## Améliorations vs version Bash
✅ **Sécurité** : Gestion propre des mots de passe via `getpass`  
✅ **Robustesse** : Timeouts, gestion d'erreurs, validation des entrées  
✅ **Maintenabilité** : Code structuré, fonctions réutilisables  
✅ **UX** : Confirmation avant action, retours visuels clairs  
✅ **Complétude** : Inclut CONNECT, séquences, et privilèges par défaut

## Exemple d'exécution
```
🔐 PostgreSQL Read Access Grant Tool

=== PostgreSQL Connection Settings ===
Server Address: prod-db.example.com
DB Port [5432]: 
Admin Username: postgres
Admin Password: 
Username to grant read access: analyst_user

📊 Fetching databases from prod-db.example.com...

✅ Found 3 database(s):
  - sales_db
  - marketing_db
  - analytics_db

⚠️ Grant READ access to 'analyst_user' on these databases? [y/N]: y

🔄 Granting permissions...
  ✅ sales_db
  ✅ marketing_db
  ✅ analytics_db

🎉 Completed: 3/3 databases updated successfully
```

## Codes de sortie
- `0` : Succès
- `1` : Erreur (connexion, validation, etc.)
- `130` : Interruption utilisateur (Ctrl+C)