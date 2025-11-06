#!/bin/bash

# Demander l'adresse du serveur Bootstrap
read -p "Entrez l'adresse du serveur Bootstrap (ex: localhost:9093): " bootstrap_server

# Configuration de la commande
echo "Configuration de la commande :"
read -p "Entrez le nom du groupe de consommateurs (ex: steering-node-consumer-group): " consumer_group
read -p "Entrez le nom du sujet (ex: steering-internal-requests): " topic

# Récapitulatif de la commande
echo "Récapitulatif de la commande :"
echo "kafka-consumer-groups.sh --bootstrap-server $bootstrap_server --group $consumer_group --topic $topic --reset-offsets --to-latest --execute"

# Demander confirmation pour exécuter la commande
read -p "Voulez-vous exécuter la commande ci-dessus ? (y/n): " confirm
if [ "$confirm" = "y" ]; then
    # Exécuter la commande
    kafka-consumer-groups.sh --bootstrap-server $bootstrap_server --group $consumer_group --topic $topic --reset-offsets --to-latest --execute
    echo "La commande a été exécutée."
else
    echo "Exécution annulée."
fi
