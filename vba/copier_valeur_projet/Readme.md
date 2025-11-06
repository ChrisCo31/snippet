
# Enregistrement des modules VBA dans Excel

## Les formats de fichier

| Format                    | Extension | Contenu               | Usage                     |
|--------                   |-----------|---------              |-------                    |
| **Classeur standard**     | `.xlsx`   | Données uniquement    | Fichiers sans code        |
| **Classeur avec macros**  | `.xlsm`   | Données + VBA         | **Recommandé** pour VBA   |
| **Classeur binaire**      | `.xlsb`   | Données + VBA         | Fichiers volumineux       |

## Procédure d'enregistrement

**Première sauvegarde :**
1. **Fichier** → **Enregistrer sous**
2. Sélectionner **"Classeur Excel prenant en charge les macros (*.xlsm)"**
3. Nommer et enregistrer

**Sauvegardes suivantes :**
- Simple **Ctrl + S** (le format est conservé)


## Exportation de modules (backup)

Pour sauvegarder uniquement le code :
1. Ouvrir **VBE** (Alt + F11)
2. Clic droit sur le module → **Exporter le fichier**
3. Sauvegarder en `.bas` (réimportable plus tard)


# Installation :

Alt + F11 → Ouvre l'éditeur VBA
Insertion → Module
Coller le code
Créer un bouton : Insertion → Formes → Bouton, puis assigner la macro CopierValeursProjet


# Documentation Macro VBA - CopierValeursProjet

## Vue d'ensemble

**Nom :** `CopierValeursProjet`
**Type :** Sub-routine VBA (Macro Excel)
**Objectif :** Copier automatiquement les valeurs d'une zone de saisie (D4:H4) vers une ligne spécifique d'un tableau de référence, basé sur le nom de projet sélectionné.


## Structure du fichier Excel attendue

```
     A              B      C      D      E      F
┌──────────────┬────────┬──────┬──────┬──────┬──────┐
│              │ [Menu] │      │[Val1]│[Val2]│[Val3]│  ← Ligne 4 (Zone saisie)
│              │  B4    │      │  D4  │  E4  │  F4  │
├──────────────┼────────┼──────┼──────┼──────┼──────┤
│ Projet Alpha │        │      │      │      │      │  ← Tableau destination
│ Projet Beta  │        │      │      │      │      │
│ Projet Gamma │        │      │      │      │      │
└──────────────┴────────┴──────┴──────┴──────┴──────┘
   Référence    Dest.   Dest.  Dest.  Dest.  Dest.
```

**Prérequis :**
- **B4** : Dropdown menu avec noms de projets
- **D4:H4** : Cellules de saisie (5 valeurs)
- **Colonne A** : Liste de tous les noms de projets (sans doublons)
- **Colonnes B:F** : Zone de destination (même ligne que le projet)

---

## Analyse ligne par ligne

### Déclaration des variables

```vba
Dim ws As Worksheet
Dim projectName As String
Dim ligneDestination As Long
Dim derniereLigne As Long
```

| Variable              | Type           | Usage                                    |
|----------             |------          |-------                                   |
| `ws`                  | Worksheet     | Référence à la feuille active             |
| `projectName`         | String        | Nom du projet sélectionné (B4)            |
| `ligneDestination`    | Long          | Numéro de ligne où copier                 |
| `derniereLigne`       | Long          | Dernière ligne avec données (colonne A)   |

**Note :** `Long` plutôt que `Integer` pour supporter >32 767 lignes

---

### Étape 1 : Initialisation

```vba
Set ws = ActiveSheet
```
- **Action :** Définit `ws` comme référence à la feuille actuellement active
- **Pourquoi :** Évite les répétitions de `ActiveSheet` dans le code
- **Performance :** Améliore la lisibilité et la vitesse d'exécution

---

### Étape 2 : Récupération du projet

```vba
projectName = ws.Range("B4").Value
```
- **Action :** Lit la valeur de la cellule B4
- **Résultat :** Stocke le nom du projet dans `projectName`
- **Exemple :** Si B4 = "Projet Alpha" → `projectName = "Projet Alpha"`

---

### Étape 3 : Validation de la saisie

```vba
If projectName = "" Then
    MsgBox "Veuillez sélectionner un projet dans B4", vbExclamation
    Exit Sub
End If
```

**Contrôle de sécurité :**
- **Test :** B4 est-elle vide ?
- **Si vide :** Affiche message d'erreur et arrête l'exécution
- **vbExclamation :** Icône ⚠️ dans la boîte de dialogue
- **Exit Sub :** Équivalent à `return` en Python

---

### Étape 4 : Déterminer la plage de recherche

```vba
derniereLigne = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
```

**Décomposition :**
1. `ws.Rows.Count` → Nombre total de lignes (1 048 576 dans Excel moderne)
2. `ws.Cells(ws.Rows.Count, "A")` → Dernière cellule possible en colonne A
3. `.End(xlUp)` → Remonte jusqu'à la première cellule non-vide (Ctrl+↑)
4. `.Row` → Retourne le numéro de ligne

**Analogie Python :**
```python
# Trouver le dernier index non-vide dans une liste
derniere_ligne = len([x for x in colonne_A if x])
```

**Exemple :**
- Si données jusqu'à A50 → `derniereLigne = 50`
- Optimise la boucle de recherche

---

### Étape 5 : Recherche du projet (boucle)

```vba
ligneDestination = 0
For i = 1 To derniereLigne
    If ws.Cells(i, "A").Value = projectName Then
        ligneDestination = i
        Exit For
    End If
Next i
```

**Algorithme de recherche linéaire :**
1. **Initialisation :** `ligneDestination = 0` (valeur sentinelle = "non trouvé")
2. **Parcours :** Ligne 1 → `derniereLigne`
3. **Comparaison :** Valeur en colonne A == `projectName` ?
4. **Si trouvé :** Enregistre le numéro de ligne et sort de la boucle
5. **Exit For :** Optimisation (arrête dès la première correspondance)

**Complexité :** O(n) où n = nombre de projets

**Analogie Python :**
```python
ligne_destination = 0
for i, nom in enumerate(colonne_A, start=1):
    if nom == project_name:
        ligne_destination = i
        break
```

---

### Étape 6 : Copie des valeurs

```vba
If ligneDestination > 0 Then
    ws.Cells(ligneDestination, "B").Value = ws.Range("D4").Value
    ws.Cells(ligneDestination, "C").Value = ws.Range("E4").Value
    ws.Cells(ligneDestination, "D").Value = ws.Range("F4").Value
    ws.Cells(ligneDestination, "E").Value = ws.Range("G4").Value
    ws.Cells(ligneDestination, "F").Value = ws.Range("H4").Value
    
    MsgBox "Valeurs copiées avec succès pour " & projectName, vbInformation
```

**Test de succès :**
- `ligneDestination > 0` → Projet trouvé
- Sinon (reste à 0) → Projet inexistant

**Mapping des valeurs :**
| Source    | Destination           | Description   |
|--------   |-------------          |-------------  |
| D4        | Ligne trouvée, Col B  | Valeur 1      |
| E4        | Ligne trouvée, Col C  | Valeur 2      |
| F4        | Ligne trouvée, Col D  | Valeur 3      |
| G4        | Ligne trouvée, Col E  | Valeur 4      |
| H4        | Ligne trouvée, Col F  | Valeur 5      |

**Message de confirmation :**
- `vbInformation` → Icône ℹ️
- Concatène le nom du projet pour confirmation

---

### Étape 7 : Gestion d'erreur

```vba
Else
    MsgBox "Projet '" & projectName & "' non trouvé dans le tableau", vbCritical
End If
```

**Cas d'échec :**
- Projet sélectionné n'existe pas en colonne A
- `vbCritical` → Icône ❌
- Affiche le nom du projet pour débogage

---

## Installation & Utilisation

### Installation

1. **Ouvrir l'éditeur VBA :** `Alt + F11`
2. **Créer un module :** Insertion → Module
3. **Coller le code**
4. **Sauvegarder :** Fichier → Enregistrer (format `.xlsm`)

### Créer le bouton

1. **Onglet Développeur** → Insérer → Bouton (Contrôle de formulaire)
2. Dessiner le bouton sur la feuille
3. **Assigner la macro :** Sélectionner `CopierValeursProjet`
4. Personnaliser le texte : "📋 Copier les valeurs"

### Utilisation

1. Sélectionner un projet dans le dropdown **B4**
2. Remplir les valeurs en **D4:H4**
3. Cliquer sur le bouton
4. ✅ Message de confirmation

---

## 🔒 Limitations & Considérations

### Limites actuelles

| Limite | Impact |
|--------|--------|
| Recherche case-sensitive | "Alpha" ≠ "alpha" |
| Pas de trim des espaces | "Alpha " ≠ "Alpha" |
| Première occurrence seulement | Si doublons en col A |
| Feuille active uniquement | Ne fonctionne pas multi-feuilles |

### Gestion des erreurs

**Non géré :**
- Cellules D4:H4 avec formules erronées (#DIV/0!, #N/A)
- Colonne A avec cellules fusionnées
- Protection de feuille

---

## 🚀 Améliorations possibles

### Version optimisée avec recherche insensible à la casse

```vba
If UCase(ws.Cells(i, "A").Value) = UCase(projectName) Then
```

### Version avec trim des espaces

```vba
If Trim(ws.Cells(i, "A").Value) = Trim(projectName) Then
```

### Version avec copie en bloc (plus rapide)

```vba
ws.Range(ws.Cells(ligneDestination, "B"), ws.Cells(ligneDestination, "F")).Value = _
    ws.Range("D4:H4").Value
```

### Version avec gestion d'erreur avancée

```vba
On Error GoTo GestionErreur
' ... code ...
Exit Sub

GestionErreur:
    MsgBox "Erreur: " & Err.Description, vbCritical
```

---

## 📊 Diagramme de flux

```
┌─────────────────────┐
│   Démarrage macro   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Récupérer B4       │
│  (projectName)      │
└──────────┬──────────┘
           │
           ▼
      ┌────────┐
      │ B4 = ? │ Oui → ⚠️ Message → FIN
      └───┬────┘
          │ Non
          ▼
┌─────────────────────┐
│ Trouver dernière    │
│ ligne (colonne A)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Boucle: ligne 1 à n │
│ Chercher projectName│
└──────────┬──────────┘
           │
           ▼
      ┌────────┐
      │Trouvé? │ Non → ❌ Message → FIN
      └───┬────┘
          │ Oui
          ▼
┌─────────────────────┐
│ Copier D4:H4 vers   │
│ ligne trouvée (B:F) │
└──────────┬──────────┘
           │
           ▼
      ✅ Message
           │
           ▼
         FIN
```

---

## 🧪 Tests recommandés

### Cas de test

| # | Scénario | B4 | Colonne A | Résultat attendu |
|---|----------|----|-----------|--------------------|
| 1 | Projet existant | "Alpha" | "Alpha" ligne 10 | ✅ Copie ligne 10 |
| 2 | B4 vide | "" | Peu importe | ⚠️ Message erreur |
| 3 | Projet inexistant | "Zeta" | Pas de "Zeta" | ❌ Message "non trouvé" |
| 4 | Doublons | "Beta" | "Beta" lignes 5 et 8 | ✅ Copie ligne 5 (1er) |
| 5 | Espaces | "Alpha " | "Alpha" | ❌ Non trouvé (trim nécessaire) |

---

## 📚 Références VBA

**Objets utilisés :**
- `Worksheet` : Feuille Excel
- `Range` : Plage de cellules
- `Cells(ligne, colonne)` : Accès cellule individuelle

**Méthodes clés :**
- `.Value` : Lire/écrire valeur
- `.End(xlUp)` : Navigation (≈ Ctrl+flèche)
- `MsgBox` : Boîte de dialogue

**Constantes :**
- `vbExclamation` : ⚠️
- `vbInformation` : ℹ️
- `vbCritical` : ❌

---

**Version :** 1.0  
**Dernière mise à jour :** 2025-11-04  
**Compatibilité :** Excel 2010+