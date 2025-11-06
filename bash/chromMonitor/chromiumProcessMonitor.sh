#!/bin/bash

# Récupérer les processus Chromium
chromium_processes=$(ps aux | grep chromium)

# Date du jour au format MMDD
today=$(date '+%m%d')

# Parcourir chaque ligne du résultat de la commande
while IFS= read -r line; do
    # Récupérer la date de démarrage du processus (colonne 9)
    start_date=$(echo "$line" | awk '{print $9}')

    # Extraire le mois et le jour de la date de démarrage
    process_date=$(date -d "$start_date" '+%m%d')

    # Récupérer le temps écoulé depuis le démarrage du processus (colonne 10)
    elapsed_time=$(echo "$line" | awk '{print $10}')

    # Vérifier si le processus est plus vieux que le jour en cours ou s'il a plus de 4 heures
    if [[ "$process_date" != "$today" || $elapsed_time =~ .*-.*:.*:[4-9][0-9]:.* ]]; then
        echo "Processus Chromium ne correspondant pas au jour en cours ou avec plus de 4 heures : $line"
    fi
done <<< "$chromium_processes"
