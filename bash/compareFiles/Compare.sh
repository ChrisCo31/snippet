#!/bin/bash

# Demander les noms des fichiers à comparer à l'utilisateur
read -p "Entrez le nom du premier fichier : " fichier1
read -p "Entrez le nom du deuxième fichier : " fichier2

# Vérification si les fichiers existent
if [ ! -f "$fichier1" ]; then
  echo "Le fichier $fichier1 n'existe pas."
  exit 1
fi

if [ ! -f "$fichier2" ]; then
  echo "Le fichier $fichier2 n'existe pas."
  exit 1
fi

# Comparaison des fichiers
diff_output=$(diff "$fichier1" "$fichier2")

# Vérification des différences
if [ -z "$diff_output" ]; then
  echo "Les fichiers sont identiques."
else
  echo "Les fichiers sont différents. Voici les différences :"
  echo "$diff_output"
fi
