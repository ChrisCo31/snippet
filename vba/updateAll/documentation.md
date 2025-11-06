# Documentation - Script VBA : UpdateAll

## Vue d'ensemble

Ce script VBA automatise la collecte et la copie des données financières de tous les projets listés dans un tableau de paramètres vers un tableau de synthèse.

### Fonctionnalités principales

- Parcourt automatiquement tous les projets définis dans l'onglet "Parameters"
- Récupère les valeurs financières pour chaque projet
- Copie les données dans le tableau de destination
- Crée automatiquement les lignes manquantes
- Applique un formatage professionnel (gras, alignement, formats numériques)
- Affiche un rapport récapitulatif des opérations (pop up)


## Architecture

### Structure des données

#### Source des projets
- **Onglet** : `Parameters`
- **Colonne** : `H` (à partir de la ligne 27)
- **Format** : Liste de noms de projets

#### Zone de saisie temporaire
- **Cellule B4** : Sélection du projet (dropdown menu)
- **Cellules D4:H4** : Valeurs financières du projet sélectionné

#### Tableau de destination
- **Colonne A** : Noms des projets
- **Colonnes B:E** : Montants financiers (en euros)
- **Colonne F** : Pourcentage


## Fonctionnement détaillé

### Workflow du script

```
1. Lecture de la liste des projets (Parameters!H27:Hn)
   ↓
2. Pour chaque projet :
   ├─ Sélection du projet dans B4
   ├─ Attente du recalcul des formules
   ├─ Recherche du projet dans le tableau (colonne A)
   ├─ Si absent → Création d'une nouvelle ligne
   ├─ Copie des valeurs D4:H4 → colonnes B:F
   └─ Application du formatage
   ↓
3. Affichage du message récapitulatif
```

### Logique de recherche

Le script compare le nom du projet avec chaque entrée de la colonne A jusqu'à trouver une correspondance exacte. Si aucune correspondance n'est trouvée, une nouvelle ligne est automatiquement créée en fin de tableau.

## Formatage appliqué

### Colonnes B à E (Montants)
- **Police** : Gras
- **Format** : `#,##0 €;[Red]-#,##0 €`
  - Séparateur de milliers (espace)
  - Symbole euro
  - Valeurs négatives en rouge
- **Alignement** : Droite


### Colonne F (Pourcentage)
- **Police** : Gras
- **Format** : `0.0%`
  - 1 décimale
  - Arrondi automatique
- **Alignement** : Droite


## Message de confirmation

Le script affiche un message récapitulatif contenant :

1. **Confirmation de succès** : "Toutes les valeurs ont ete copiees avec succes!"

2. **Détail des ajouts** (si applicable) :
   ```
   4 nouveau(x) projet(s) ajoute(s):
   - SME
   - Transition
   - BD remaining balance
   - SCA
   ```


## Configuration requise

### Pré-requis
- Microsoft Excel avec support VBA
- Onglet "Parameters" existant
- Liste de projets nommée "project" en colonne H (ligne 27+)
- Dropdown menu configuré en B4 pointant vers cette liste

### Dépendances
- Cellules D4:H4 doivent contenir des formules ou valeurs liées au projet sélectionné en B4
- Les formules doivent se recalculer automatiquement lors du changement de B4


## Utilisation

### Installation

1. Ouvrez l'éditeur VBA (`Alt + F11`)
2. Insérez un nouveau module (`Insertion` → `Module`)
3. Copiez-collez le code du script
4. Fermez l'éditeur VBA

### Exécution

Cliquez simplement sur le bouton créé. Le script s'exécute automatiquement et affiche un message de confirmation à la fin.


