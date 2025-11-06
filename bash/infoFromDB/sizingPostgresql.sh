#!/bin/bash

# Ask the user to enter login information
read -p "Server Address: " db_host
read -p "DB Port: " db_port
read -p "User Name: " db_user
read -s -p "Password: " db_password
echo

# Run psql's "--list" command with user supplied login credentials
databases=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" --list -t | cut -d'|' -f1 | sed -e '/^\s*$/d')

# Display List of DB
echo "List of databases available on the server:"
echo "$databases"
echo

# Display the table header
echo "--------------------------------------------------"
printf "| %-30s | %-15s |\n" "Database" "Size"
echo "--------------------------------------------------"

# Initialize total size variable in bytes
total_size_bytes=0

# For each database, get the size
for database in $databases; do
    # Retrieve the total size of the database in bytes
    db_size_bytes=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "SELECT pg_database_size('$database');" | tr -d ' ')
    # Convert the size to a human-readable format
    total_db_size=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "SELECT pg_size_pretty(pg_database_size('$database'));")
    # Display the result in a table format
    printf "| %-30s | %-15s |\n" "$database" "$total_db_size"
    # Add the database size to the total size
    total_size_bytes=$((total_size_bytes + db_size_bytes))
done
echo "--------------------------------------------------"
# Convert the total size to a human-readable format
total_size_human=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "SELECT pg_size_pretty($total_size_bytes);")

# Display the total size of all databases
echo "Total size of all databases: $total_size_human"

 