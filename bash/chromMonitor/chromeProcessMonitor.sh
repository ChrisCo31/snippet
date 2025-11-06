
#!/bin/bash

# Récupérer les processus Chrome
chrome_processes=$(ps aux | grep chrome)

# Date du jour 
today=$(date '+%m%d')

# variable pour indiquer si des processus ont été trouvés
process_found=0

# Parcourir chaque ligne de la commande
while IFS= read -r line; do
    # Vérifier si la ligne correspond à un processus Chrome
    if [[ "$line" =~ .*chrome.* ]]; then
        # Récupérer la date de démarrage du processus (colonne 9)
        start_date=$(echo "$line" | awk '{print $9}')

        # Extraire le mois et le jour de la date de démarrage
        process_date=$(date -d "$start_date" '+%m%d')

        # Récupérer le temps écoulé depuis le démarrage du processus (colonne 10)
        elapsed_time=$(echo "$line" | awk '{print $10}')

        # Vérifier si le processus est plus vieux que le jour en cours ou s'il a plus de 4 heures
        if [[ "$process_date" != "$today" || $elapsed_time =~ .*-.*:.*:[4-9][0-9]:.* ]]; then
            echo "Processus Chrome de plus de 4 heures : $line"
            process_found=1
        fi
    fi
done <<< "$chrome_processes"

# Vérifier si aucun processus n'a été trouvé
if [[ $process_found -eq 0 ]]; then
    echo "Rien trouvé."
fi
