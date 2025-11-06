
## Script : oc_cleanup_state.sh

### Description
Script Bash interactif pour supprimer le dossier `state` de plusieurs pods OpenShift/Kubernetes contenant le mot "stream" dans leur nom. Le script propose une interface de sélection multiple avec confirmation avant exécution et vérifie le succès de chaque opération.

### Prérequis
- Outil `oc` (OpenShift CLI) installé et configuré
- Connexion active à un cluster OpenShift/Kubernetes
- Permissions suffisantes pour :
  - Lister les pods (`oc get pods`)
  - Exécuter des commandes dans les pods (`oc exec`)
  - Supprimer des fichiers dans les pods

### Exécuter le script
```bash
bash oc_cleanup_state.sh
```

### Fonctionnement

#### Étape 1 : Récupération des pods
Le script recherche automatiquement tous les pods dont le nom contient "stream" :
```bash
oc get pods | grep "stream"
```

Si aucun pod n'est trouvé, le script s'arrête avec un message d'erreur.

#### Étape 2 : Sélection interactive
Interface en mode texte permettant de :
- Visualiser tous les pods disponibles
- Sélectionner/désélectionner des pods (toggle) en entrant leur numéro
- Voir en temps réel les pods sélectionnés (marqués en vert avec [X])
- Quitter la sélection avec 'q' ou 'Q'

**Contrainte** : Minimum 2 pods doivent être sélectionnés.

#### Étape 3 : Confirmation
Affiche la liste des pods sélectionnés et demande une confirmation finale :
```
Confirm deletion of 'state' folder on these pods? (yes/no):
```

Seule la réponse "yes" déclenche l'exécution.

#### Étape 4 : Exécution
Pour chaque pod sélectionné :
1. Vérifie si le dossier `state` existe
2. Supprime le dossier avec `rm -rfv state`
3. Vérifie que la suppression a réussi
4. Affiche le statut (succès ✓ ou erreur ✗)

#### Étape 5 : Résumé
Affiche un rapport final avec :
- Nombre de pods traités avec succès
- Nombre d'erreurs rencontrées
- Code de sortie approprié (0 = succès, 1 = erreurs)

### Interface utilisateur

**Codes couleur :**
- 🟢 **Vert** : Pod sélectionné, opération réussie
- 🔴 **Rouge** : Pod non sélectionné, erreur
- 🟡 **Jaune** : Informations, avertissements

**Navigation :**
```
0) [ ] stream-processor-1-abcd
1) [X] stream-processor-2-efgh
2) [ ] stream-processor-3-ijkl

Selected: 1 pod(s)

Choice: _
```

### Exemple d'exécution
```bash
$ bash oc_cleanup_state.sh

Retrieving pods containing 'stream'...
Found 3 pod(s).

=== Pod Selection ===
Select pods (Enter the pod number or 'q' to finish):

0) [ ] stream-processor-1-abcd
1) [ ] stream-processor-2-efgh
2) [ ] stream-processor-3-ijkl

Selected: 0 pod(s)

Choice: 0

# Interface se rafraîchit avec le pod 0 sélectionné en vert

Choice: 1
Choice: q

=== Selected pods ===
  - stream-processor-1-abcd
  - stream-processor-2-efgh

Confirm deletion of 'state' folder on these pods? (yes/no): yes

=== Starting operations ===

Processing pod: stream-processor-1-abcd
  - Deleting 'state' folder...
  ✓ Deletion successful
  ✓ Verification: 'state' folder removed

Processing pod: stream-processor-2-efgh
  ⚠ 'state' folder does not exist

=== Operations completed ===
Success: 2 pod(s)
Errors: 0 pod(s)
```

### Gestion des erreurs

Le script gère les situations suivantes :
- **Aucun pod trouvé** : Arrêt avec message d'erreur
- **Moins de 2 pods sélectionnés** : Refuse de continuer
- **Dossier 'state' inexistant** : Considéré comme succès (avertissement)
- **Échec de suppression** : Comptabilisé comme erreur
- **Vérification échouée** : Comptabilisé comme erreur
- **Erreur de connexion oc** : Propagation de l'erreur

### Sécurité

⚠️ **Attention** : Ce script effectue des suppressions définitives dans les pods.

**Mécanismes de sécurité :**
- Sélection interactive (pas de suppression en masse automatique)
- Confirmation explicite avec le mot "yes"
- Vérification post-suppression
- Rapport détaillé des opérations
- Code de sortie approprié pour intégration CI/CD

**Recommandations :**
1. Vérifier que les pods sélectionnés sont corrects
2. S'assurer que la suppression du dossier `state` est intentionnelle
3. Documenter chaque exécution (logs, tickets)
4. Tester d'abord sur un environnement de développement
5. Prévoir un plan de restauration si nécessaire

### Cas d'usage

- **Nettoyage de cache** : Supprimer les états locaux après une mise à jour
- **Récupération après incident** : Forcer la reconstruction de l'état
- **Maintenance** : Nettoyer les données temporaires
- **Tests** : Réinitialiser l'état des applications entre les tests

### Limitations

- Recherche limitée au mot-clé "stream" (modifier le script pour d'autres patterns)
- Supprime uniquement le dossier `state` (pas d'autres dossiers)
- Nécessite que le pod soit en état "Running"
- Pas de backup automatique avant suppression

### Commandes utiles associées
```bash
# Lister tous les pods
oc get pods

# Vérifier le contenu d'un pod spécifique
oc exec <pod-name> -- ls -la state

# Se connecter interactivement à un pod
oc rsh <pod-name>

# Voir les logs d'un pod
oc logs <pod-name>

# Redémarrer un pod (après nettoyage)
oc delete pod <pod-name>
```

### Personnalisation

Pour adapter le script à d'autres besoins :
```bash
# Changer le pattern de recherche
grep "stream" → grep "processor"

# Modifier le dossier cible
rm -rfv state → rm -rfv /tmp/cache

# Changer le nombre minimum de pods
if [ "${#selected_indices[@]}" -lt 2 ] → -lt 1
```

