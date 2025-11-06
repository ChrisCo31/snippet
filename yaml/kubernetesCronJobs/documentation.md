# Documentation - Kubernetes CronJobs

## CronJob : cron-chromium-test

### Description
CronJob de test exécutant des commandes simples inline pour valider le bon fonctionnement du scheduler Kubernetes.

### Configuration
- **Schedule** : `*/1 * * * *` (toutes les minutes)
- **Image** : `busybox`
- **Commande** : Affiche la date et un message de test

### Utilisation
```bash
# Déployer
kubectl apply -f cron-chromium-healthcheck.yaml

# Vérifier l'exécution
kubectl get cronjobs
kubectl get jobs
kubectl logs -l job-name=<job-name>
```

### Cas d'usage
- Test du fonctionnement des CronJobs
- Validation de la configuration du cluster
- Environnement de développement

---

## CronJob : cron-chromium-cleanup

### Description
CronJob de production exécutant un script externe pour surveiller et gérer les processus Chromium.

### Configuration
- **Schedule** : `*/1 * * * *` (toutes les minutes)
- **Image** : `busybox` (ou image custom avec script embarqué)
- **Commande** : Exécute `/script.sh`

### Prérequis
Le script `/script.sh` doit être disponible dans le container via :
- Image Docker custom avec le script inclus
- ConfigMap monté en volume

### Exemple avec ConfigMap
```bash
# Créer le ConfigMap
kubectl create configmap chromium-script --from-file=script.sh

# Déployer le CronJob
kubectl apply -f cron-chromium-process-monitor.yaml
```

### Utilisation
```bash
# Vérifier les exécutions
kubectl get cronjobs
kubectl logs -l job-name=<job-name>

# Suspendre temporairement
kubectl patch cronjob cron-chromium-process-monitor -p '{"spec":{"suspend":true}}'
```

### Cas d'usage
- Nettoyage automatique de processus
- Surveillance périodique
- Maintenance automatisée

---

## Paramètres communs

| Paramètre                         | Valeur        | Description                               |
|-----------                        |--------       |-------------                              |
| `concurrencyPolicy`               | `Allow`       | Autorise l'exécution simultanée de jobs   |
| `restartPolicy`                   | `OnFailure`   | Redémarre le pod en cas d'échec           |
| `terminationGracePeriodSeconds`   | `30`          | Délai avant arrêt forcé du pod            |

## Commandes utiles

```bash
# Lister tous les CronJobs
kubectl get cronjobs

# Déclencher manuellement
kubectl create job --from=cronjob/<cronjob-name> <job-name>

# Supprimer un CronJob
kubectl delete cronjob <cronjob-name>

# Voir l'historique des jobs
kubectl get jobs --watch
```
