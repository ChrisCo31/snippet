## Script : kafka_reset_offsets.sh

### Description
Script Bash interactif pour réinitialiser les offsets d'un groupe de consommateurs Kafka au dernier message disponible (--to-latest). Permet de "sauter" tous les messages non consommés et de repartir du point le plus récent du topic.

### Prérequis
- Kafka installé avec accès à `kafka-consumer-groups.sh`
- Connexion réseau au serveur Bootstrap Kafka
- Permissions suffisantes pour modifier les offsets du groupe de consommateurs

### Exécuter le script
```bash
bash kafka_reset_offsets.sh
```

### Fonctionnement

#### Étape 1 : Configuration du serveur
Le script demande l'adresse du serveur Bootstrap Kafka.
```
Exemple : localhost:9093
```

#### Étape 2 : Configuration des paramètres
Le script demande les informations suivantes :
- **Groupe de consommateurs** : Nom du consumer group à modifier (ex: `steering-node-consumer-group`)
- **Topic** : Nom du sujet Kafka concerné (ex: `steering-internal-requests`)

#### Étape 3 : Récapitulatif et confirmation
Affiche la commande complète qui sera exécutée et demande une confirmation (y/n) avant l'exécution.

### Paramètres Kafka utilisés
- `--bootstrap-server` : Adresse du serveur Kafka
- `--group` : Nom du groupe de consommateurs
- `--topic` : Nom du topic ciblé
- `--reset-offsets` : Active le mode de réinitialisation des offsets
- `--to-latest` : Positionne les offsets au dernier message disponible
- `--execute` : Exécute réellement la commande (sans ce flag, mode dry-run)

### Comportement
Lorsque le script est exécuté avec succès :
- Tous les messages non consommés du topic sont **ignorés**
- Le groupe de consommateurs reprendra la lecture à partir du **prochain nouveau message**
- Les anciens messages ne seront **pas retraités**

### Cas d'usage
- **Sauter un backlog** de messages accumulés
- **Récupération après incident** : éviter de retraiter des messages en erreur
- **Redémarrage propre** d'un consommateur après maintenance
- **Tests** : repositionner rapidement les consommateurs

### Exemple d'exécution
```bash
$ bash kafka_reset_offsets.sh

Entrez l'adresse du serveur Bootstrap (ex: localhost:9093): kafka-broker:9092
Entrez le nom du groupe de consommateurs (ex: steering-node-consumer-group): my-consumer-group
Entrez le nom du sujet (ex: steering-internal-requests): orders-topic

Récapitulatif de la commande :
kafka-consumer-groups.sh --bootstrap-server kafka-broker:9092 --group my-consumer-group --topic orders-topic --reset-offsets --to-latest --execute

Voulez-vous exécuter la commande ci-dessus ? (y/n): y
La commande a été exécutée.
```

### Alternatives de réinitialisation
Le script utilise `--to-latest`, mais d'autres options existent :
- `--to-earliest` : Revenir au début du topic
- `--to-offset <offset>` : Positionner à un offset spécifique
- `--shift-by <n>` : Décaler de n messages (positif ou négatif)
- `--to-datetime <datetime>` : Positionner à une date/heure précise

### Sécurité
⚠️ **Attention** : La réinitialisation des offsets est une opération sensible qui peut entraîner :
- Perte de messages non traités (avec `--to-latest`)
- Retraitement de messages (avec `--to-earliest`)
- Impact sur les consommateurs actifs du groupe

**Recommandations :**
1. Arrêter les consommateurs du groupe avant la réinitialisation
2. Vérifier les offsets actuels avec `--describe` avant modification
3. Tester d'abord sans `--execute` (mode dry-run)
4. Documenter chaque réinitialisation d'offsets

### Commandes utiles associées
```bash
# Lister tous les groupes de consommateurs
kafka-consumer-groups.sh --bootstrap-server <server> --list

# Décrire l'état d'un groupe (voir les offsets actuels)
kafka-consumer-groups.sh --bootstrap-server <server> --group <group> --describe

# Mode dry-run (prévisualisation sans exécution)
kafka-consumer-groups.sh --bootstrap-server <server> --group <group> --topic <topic> --reset-offsets --to-latest
```