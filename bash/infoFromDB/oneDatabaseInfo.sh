#!/bin/bash

# Ask the user to enter login information
read -p "Server Address : " db_host
read -p "DB Port: " db_port
read -p "Database Name : " db_name
read -p "User Name : " db_user
read -s -p "Password: " db_password
echo

# Run psql's "\dt" command with user supplied login credentials
tables=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" -t -c "\dt" | awk '{print $3}' | grep -v "schema")
# display
echo "---------------------------------------------------------------------"
printf "| %-40s | %-15s | %-15s |\n" "Table" "Number of lines" "Size"
echo "---------------------------------------------------------------------"

for table in $tables; do
    # Get number of rows in table
    row_count=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" -t -c "SELECT COUNT(*) FROM $table")
    # Get table size in bytes
    table_size=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" -t -c "SELECT pg_total_relation_size('$table')")
    # Convert size to KB, MB, GB
    table_size_human=$(numfmt --to=iec-i --suffix=B --padding=7 <<< "$table_size")
    # Show results in table
    printf "| %-40s | %15s | %15s |\n" "$table" "$row_count" "$table_size_human"
done
echo "---------------------------------------------------------------------"