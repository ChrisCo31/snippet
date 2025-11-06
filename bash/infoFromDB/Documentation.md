# Documentation - Database Scripts

## 1. Script : SeveralDatabasesInfo

### Description
The "SeveralDatabasesInfo.sh" is a Bash script that retrieves the names of all available PostgreSQL databases on a server. For each database, it further fetches the names of the tables, their size, and the number of rows.

### Run the script: 
To execute the script, launch it using the following command:
Bash SeveralDatabasesInfo.sh

### Connection Information: 
The script will prompt you to enter the connection information to the PostgreSQL server, including the server address, port, username, and password. 

### Display results: 
The script will retrieve the list of all available databases on the server and display their names. 
For each database, it will fetch the names of the tables, their size in bytes, and the number of rows. The results will be displayed in a formatted table.

### Script Output: 
After displaying the results for all databases, the script will exit.

## 2. Script : RetrieveDBName

### Description
The "RetrieveDBName.sh" is a Bash script that retrieves the names of all available PostgreSQL databases on a server.

### Run the script:
To execute the script, launch it using the following command: bash RetrieveDBName.sh

### Connection Information: 
The script will prompt you to enter the connection information to the PostgreSQL server, including the server address, port, username, and password. Make sure to provide accurate information.

### Display results: 
Once the connection information is provided, the script will retrieve the list of all available databases on the server and display their names.

### Script Output:
After displaying the results for all databases, the script will exit.

## 3.Script : OneDatabaseInfo

### Description
The "OneDatabaseInfo.sh" is a Bash script that retrieves the names of tables for a given PostgreSQL database, along with their size and row count.

### Run the script: 
To execute the script, launch it using the following command: Bash OneDatabaseInfo.sh

### Connection Information: 
The script will prompt you to enter the connection information to the PostgreSQL database, including the server address, port, username, and password. Make sure to provide accurate information.

### Select the Database: 
After connecting to the database, the script will prompt you to enter the name of the database for which you want to retrieve information about the tables.

### Display results:
Once you select the database, the script will retrieve the list of tables in that database, along with their size in bytes and the number of rows. The results will be displayed in a well-formatted table.

### Script Output:
After displaying the results, the script will exit.


## 4.Script : sizingPostgresql.sh

### Description

This Bash script interacts with a PostgreSQL instance to retrieve and display the list of databases available on the server along with their respective sizes in a human-readable format. It also calculates and displays the total size of all the databases combined.

### Prerequisites
Access to a PostgreSQL instance.

The user must know the server address, port, username, and password for the PostgreSQL instance.

### Functionality


It then displays the list of databases.


- Retrieves the database size in bytes.
- Converts the size to a human-readable format.
- Displays the database name and its size in a formatted table.


## 5.Script : Discrepancy.sh

### Description
Le script "Discrepancy.sh" est un script Bash qui surveille l'évolution de la taille des tables PostgreSQL. Il capture une image initiale de la taille de toutes les tables dans toutes les bases de données, puis calcule et affiche les différences de taille pour chaque table. Les résultats sont sauvegardés dans des fichiers texte pour chaque base de données.

### Exécuter le script :
Pour exécuter le script, lancez-le avec la commande suivante :
```bash
bash Discrepancy.sh
```

### Informations de connexion :
Le script vous demandera de saisir les informations de connexion au serveur PostgreSQL, incluant l'adresse du serveur, le port, le nom d'utilisateur et le mot de passe.

### Affichage des résultats :
Le script récupère la liste de toutes les bases de données disponibles sur le serveur. Pour chaque base de données, il capture la taille initiale de chaque table, puis affiche les informations suivantes dans un tableau formaté :
- Nom de la table
- Nombre de lignes
- Taille actuelle
- Différence de taille (par rapport à la taille initiale)

### Sortie du script :
Les résultats pour chaque base de données sont enregistrés dans des fichiers individuels dans le dossier "Results" (créé automatiquement s'il n'existe pas). Le nom de chaque fichier suit le format : `resultats_[nom_base_de_données].txt`