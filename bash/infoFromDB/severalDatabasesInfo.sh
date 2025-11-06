#!/bin/bash

# Function to register result in a file
save_results_to_file() {
    local filename="$1"
    local content="$2"
    echo "$content" >> "$filename"
}


# create a folder "result" if it doesn't already exist
results_dir="Results"
if [ ! -d "$results_dir" ]; then
    mkdir "$results_dir"
    echo "Folder created : $results_dir"
fi

# Ask the user to enter login information
read -p "Server Address : " db_host
read -p "DB Port: " db_port
read -p "User Name : " db_user
read -s -p "Password: " db_password
echo

# Run psql's "--list" command with user supplied login credentials
databases=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" --list -t | cut -d'|' -f1 | sed -e '/^\s*$/d')

# Display List of DB
echo "List of databases available on the server:"
echo "$databases"
echo

# For each database, get table names, size and number of rows
for database in $databases; do
    echo "----------------------------------------------------------------------"
    echo "Database : $database"
    echo "----------------------------------------------------------------------"
    output_content=""

    # Retrieve tables
    tables=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "\dt" | awk '{print $3}' | grep -v "schema")

    # Check if there are no tables
    if [ -z "$tables" ]; then
        echo "No tables found in this database."
    else
        echo "------------------------------------------------------------------------"
        printf "| %-40s | %-15s | %-15s |\n" "Table" "Number of lines" "Size"
        echo "------------------------------------------------------------------------"

        for table in $tables; do
            # Number of lines
            row_count=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "SELECT COUNT(*) FROM \"$table\"")
            # Size
            table_size=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "SELECT pg_total_relation_size('$table')")
            # Convert size to human-readable format
            table_size_human=$(numfmt --to=iec-i --suffix=B --padding=7 <<< "$table_size")
            # Display
            printf "| %-40s | %'15d | %15s |\n" "$table" "$row_count" "$table_size_human"
            #output_content+="Table: $table | Number of lines: $row_count | Size: $table_size_human\n"
        done
        echo "------------------------------------------------------------------------"
    fi


    # Register results in a file
    output_filename="$results_dir/resultats_${database}.txt"
    output_content+="Table: $table | Number of lines: $row_count | Size: $table_size_human\n"
    #echo "$output_content"
    save_results_to_file "$output_filename" "$output_content"
    echo "Results registered : $output_filename"
    done

# display older
echo "results are stored in folder : $results_dir"
