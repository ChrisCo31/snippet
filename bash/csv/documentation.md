## Script : csv_connectivity_test.sh

### Description
Script Bash de test de connectivité réseau à partir d'un inventaire CSV. Extrait automatiquement les informations de serveurs (hostname, IP, port) depuis un fichier CSV, puis teste l'accessibilité TCP de chaque hôte. Génère un rapport coloré avec statistiques de réussite/échec.

### Prérequis
- **Fichier CSV** avec au moins 9 colonnes
- **Outils système** : `awk`, `tail`, `bash`, `timeout`
- **Outil réseau** (au moins un) :
  - `nc` (netcat) - recommandé
  - `/dev/tcp` (bash built-in) - fallback automatique
- **Accès réseau** aux serveurs à tester

### Format CSV attendu

Le script extrait automatiquement 3 colonnes spécifiques du CSV :

| Position  | Colonne       | Description       | Exemple           |
|---------- |---------      |-------------      |---------          |
| 3         | Hostname      | Nom du serveur    | `web-server-01`   |
| 6         | IP Address    | Adresse IPv4      | `192.168.1.10`    |
| 9         | Port          | Port TCP          | `8080`            |

**Exemple de fichier CSV :**
```csv
ID,Type,Hostname,Region,Environment,IP_Address,Protocol,Owner,Port,Status
1,web,web-server-01,eu-west,prod,192.168.1.10,http,team-a,8080,active
2,db,postgres-master,eu-west,prod,10.0.0.5,tcp,team-b,5432,active
3,cache,redis-cluster,eu-west,prod,10.0.0.15,tcp,team-a,6379,active
4,api,api-gateway,us-east,prod,172.16.0.20,https,team-c,443,active
```

**⚠️ Important :** Les positions de colonnes sont fixes. Si votre CSV a un format différent, ajustez la ligne 27 du script.

### Exécuter le script
```bash
# Syntaxe
bash csv_connectivity_test.sh <fichier.csv>

# Exemple
bash csv_connectivity_test.sh infrastructure.csv
```

### Fonctionnement détaillé

#### Étape 1 : Validation des arguments
- Vérifie qu'un fichier CSV est fourni en argument
- Vérifie l'existence du fichier
- Affiche un message d'erreur explicite si validation échoue

#### Étape 2 : Filtrage des colonnes
Crée un fichier CSV temporaire contenant uniquement les 3 colonnes nécessaires :
```bash
awk -F"," '{print $3, $6, $9}' input.csv > filtered_input.csv
```

**Fichier généré :** `filtered_<nom_original>.csv`

#### Étape 3 : Détection du début des données
Recherche automatiquement la première ligne contenant une adresse IP valide :
- Pattern utilisé : `x.x.x.x` (IPv4)
- Ignore automatiquement les en-têtes CSV
- Gère les lignes vides

#### Étape 4 : Tests de connectivité TCP
Pour chaque serveur :

1. **Extraction des données** (hostname, IP, port)
2. **Test de connectivité** avec timeout de 5 secondes
3. **Affichage du résultat** en temps réel (✓ vert ou ✗ rouge)
4. **Incrémentation des compteurs**

**Méthodes de test (par ordre de préférence) :**
- **Netcat** (`nc -z`) : Si disponible, méthode la plus fiable
- **/dev/tcp** : Fallback bash si netcat absent

#### Étape 5 : Rapport final
Affiche un résumé avec :
- Nombre d'hôtes accessibles (vert)
- Nombre d'hôtes inaccessibles (rouge)
- Total testé
- Code de sortie (0 = succès, 1 = échecs détectés)

### Exemple d'exécution
```bash
$ bash csv_connectivity_test.sh servers.csv

✓ CSV file found: servers.csv

Extracting columns from CSV...
✓ Filtered file created: filtered_servers.csv

Detecting data start line...
✓ Data starts at line: 2

=== Starting Connectivity Tests ===

Testing: web-server-01 (192.168.1.10:8080)
  ✓ Accessible

Testing: postgres-master (10.0.0.5:5432)
  ✓ Accessible

Testing: old-api (192.168.50.100:3000)
  ✗ Inaccessible

Testing: redis-cluster (10.0.0.15:6379)
  ✓ Accessible

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    TEST SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Accessible hosts:    3
Inaccessible hosts:  1
Total tested:        4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ Some hosts are inaccessible
```

### Codes de sortie

| Code  | Signification                                             | Usage                             |
|------ |---------------                                            |-------                            |
| `0`   | Tous les hôtes accessibles                                | Succès - intégration CI/CD        |
| `1`   | Un ou plusieurs hôtes inaccessibles                       | Échec - alerte nécessaire         |
| `1`   | Erreur de validation (fichier absent, format invalide)    | Erreur critique                   |

### Cas d'usage

#### 1. Audit de connectivité réseau
```bash
# Exporter l'inventaire depuis CMDB
# Tester l'accessibilité depuis la machine courante
bash csv_connectivity_test.sh cmdb_export.csv
```

#### 2. Validation firewall post-déploiement
```bash
# Vérifier que les règles firewall permettent les flux attendus
bash csv_connectivity_test.sh expected_flows.csv
# Code de sortie 0 = tout OK, 1 = règles manquantes
```

#### 3. Pré-déploiement application
```bash
# S'assurer que tous les services requis sont accessibles
bash csv_connectivity_test.sh app_dependencies.csv
if [ $? -eq 0 ]; then
    echo "Déploiement autorisé"
    ./deploy.sh
else
    echo "Dépendances non satisfaites - déploiement annulé"
fi
```

#### 4. Monitoring périodique
```bash
# Crontab : vérifier la connectivité toutes les heures
0 * * * * /scripts/csv_connectivity_test.sh /data/inventory.csv >> /var/log/connectivity.log 2>&1
```

#### 5. Documentation réseau automatique
```bash
# Générer un rapport d'accessibilité pour audit
bash csv_connectivity_test.sh full_inventory.csv > connectivity_report_$(date +%Y%m%d).txt
```

### Protocoles supportés

**✅ Tous les protocoles TCP :**
- HTTP/HTTPS (80, 443, 8080, etc.)
- Bases de données (PostgreSQL 5432, MySQL 3306, MongoDB 27017)
- Cache (Redis 6379, Memcached 11211)
- Message queues (Kafka 9092, RabbitMQ 5672)
- SSH (22)
- Custom TCP services

**❌ Non supportés :**
- UDP (nécessite d'autres outils)
- ICMP ping (utiliser `ping` séparément)

### Exporter les résultats en JSON

Remplacer la section summary par :
```bash
cat > results.json <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "total": $total,
  "accessible": $accessible,
  "inaccessible": $inaccessible,
  "success_rate": $(echo "scale=2; $accessible * 100 / $total" | bc)
}
EOF
```