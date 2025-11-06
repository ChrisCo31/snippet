# Script : cascade_delete.sh


## **Notes importantes**
⚠️ **Ce script est destructif et irréversible**. Toujours effectuer une sauvegarde complète avant utilisation.

⚠️ **Usage recommandé** : Environnements de développement et test uniquement. Pour la production, valider minutieusement avec `--dry-run` et disposer d'un plan de restauration testé.


## Description
Script Bash de suppression en cascade pour bases de données PostgreSQL. 
Effectue une purge complète et sécurisée des données liées à des entités (entity_artifact) en respectant l'ordre des dépendances. 

Le script inclut des mécanismes de sécurité : 
- confirmation en deux étapes, 
- mode prévisualisation, 
- test de connexion et gestion de transaction.

## Exécuter le script
Pour exécuter le script, utilisez l'une des commandes suivantes :
```bash
bash cascade_delete.sh              # Exécution avec confirmation
bash cascade_delete.sh --dry-run    # Mode prévisualisation (recommandé en premier)
bash cascade_delete.sh --help       # Afficher l'aide
```

## Options disponibles
- `-d, --dry-run` : Mode prévisualisation qui affiche le nombre d'enregistrements à supprimer sans effectuer la suppression
- `-h, --help` : Affiche le message d'aide avec les options disponibles

## Fonctionnement

### Mode prévisualisation (--dry-run)
- Compte les enregistrements qui seraient supprimés
- N'effectue aucune suppression réelle
- Permet de valider l'impact avant exécution

### Mode exécution standard
1. Affiche un avertissement de sécurité
2. Demande confirmation de l'existence d'une sauvegarde (réponse "yes" requise)
3. Demande une confirmation finale (mot "DELETE" en majuscules requis)
4. Demande les informations de connexion à la base de données
5. Teste la connexion avant de procéder
6. Exécute la suppression en cascade dans une transaction unique
7. Affiche le statut de réussite ou d'échec

## Ordre de suppression en cascade
Le script supprime les données dans l'ordre suivant pour respecter les contraintes de clés étrangères :

1. Entrées d'historique (`entity_history_entry`)
2. Événements d'historique (`entity_history_event`)
3. Nœuds de mise à jour (`entity_updater_node`)
4. Nœuds de révision (`entity_revision_node`)
5. Nœuds d'événements de planification (`planning_event_node`)
6. Nœuds de modification (`modification_node`)
7. Validité des documents (`entity_document_validity`)
8. Nœuds de catégorie (`category_node`)
9. Tables de liaison (6 tables préfixées par `r_`)
10. Nœuds d'entité principaux (`entity_node`)
11. Artefacts racine (`entity_artifact`)

## Informations de connexion
Le script demande les informations suivantes :
- Adresse du serveur PostgreSQL
- Port de la base de données
- Nom de la base de données
- Nom d'utilisateur
- Mot de passe (saisie masquée pour la sécurité)

## Mécanismes de sécurité
- **Avertissement visuel** : Message en rouge avec symbole d'avertissement
- **Double confirmation** : Vérification de backup + mot-clé "DELETE"
- **Test de connexion** : Validation avant toute opération
- **Transaction SQL** : Rollback automatique en cas d'erreur
- **Mode dry-run** : Prévisualisation sans impact
- **Nettoyage automatique** : Variable PGPASSWORD supprimée après exécution
- **Gestion d'erreurs** : Arrêt immédiat en cas de problème (`set -e`)

## Sortie du script
Le script affiche des messages colorés pour faciliter la lecture :
- **Rouge** : Avertissements et erreurs
- **Jaune** : Informations importantes et mode dry-run
- **Vert** : Confirmations de succès

En cas de succès, le message "Deletion completed successfully" s'affiche. En cas d'échec, la transaction est annulée automatiquement et le message "Deletion failed. Transaction rolled back." apparaît.

## Recommandations d'utilisation
1. **Toujours commencer par le mode dry-run** pour prévisualiser l'impact
2. **Créer une sauvegarde complète** avant toute exécution réelle
3. **Tester sur un environnement de développement** avant la production
4. **Vérifier les comptages** affichés en mode dry-run
5. **Ne jamais utiliser en production** sans backup validé et testé

## Exemple d'utilisation
```bash
# Étape 1 : Prévisualisation
bash cascade_delete.sh --dry-run

# Étape 2 : Si les résultats sont corrects, exécution
bash cascade_delete.sh
# Répondre "yes" à la question sur le backup
# Taper "DELETE" en majuscules pour confirmer
# Entrer les informations de connexion
```

## Prérequis
- PostgreSQL client (`psql`) installé
- Accès au serveur PostgreSQL avec permissions de suppression
- Connaissance de l'architecture de la base de données

