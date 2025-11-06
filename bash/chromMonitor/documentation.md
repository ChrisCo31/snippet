### Script : Chromium Process Monitor

#### Description
Script Bash qui identifie les processus Chromium qui ne correspondent pas au jour en cours ou qui s'exécutent depuis plus de 4 heures.

#### Exécuter le script :
```bash
bash chromium_monitor.sh
```

#### Fonctionnement :
Le script récupère tous les processus Chromium actifs via `ps aux | grep chromium`. Pour chaque processus, il extrait :
- La date de démarrage (colonne 9)
- Le temps écoulé depuis le démarrage (colonne 10)

#### Affichage des résultats :
Affiche chaque processus Chromium qui répond à l'un des critères suivants :
- Date de démarrage différente du jour actuel
- Temps d'exécution supérieur à 4 heures

#### Sortie du script :
Liste les processus concernés avec leurs informations complètes. Si aucun processus ne correspond, aucun message n'est affiché.

---

### Script : Chrome Process Monitor

#### Description
Script Bash qui surveille les processus Chrome et identifie ceux qui s'exécutent depuis plus de 4 heures ou depuis un jour différent.

#### Exécuter le script :
```bash
bash chrome_monitor.sh
```

#### Fonctionnement :
Le script récupère tous les processus contenant "chrome" via `ps aux | grep chrome`. Il valide chaque ligne avec une regex pour s'assurer qu'elle correspond bien à un processus Chrome. Pour chaque processus valide, il extrait :
- La date de démarrage (colonne 9)
- Le temps écoulé depuis le démarrage (colonne 10)

#### Affichage des résultats :
Affiche chaque processus Chrome qui répond à l'un des critères suivants :
- Date de démarrage différente du jour actuel
- Temps d'exécution supérieur à 4 heures

#### Sortie du script :
Liste les processus concernés avec leurs informations complètes. Si aucun processus ne correspond aux critères, affiche le message : "Rien trouvé."