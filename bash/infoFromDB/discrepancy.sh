#!/bin/bash

# Function to register result in a file
save_results_to_file() {
  local filename="$1"
  local content="$2"
  echo "$content" > "$filename"
}

# Function to get the table size for a given table
get_table_size() {
  local db_host="$1"
  local db_port="$2"
  local db_user="$3"
  local db_password="$4"
  local database="$5"
  local table="$6"
  PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "SELECT pg_total_relation_size('$table')"
}

# Function to format size
format_size() {
  local size="$1"
  if command -v numfmt >/dev/null 2>&1; then
    echo $(numfmt --to=iec-i --suffix=B --padding=7 <<< "$size")
  else
    echo "${size} bytes"
  fi
}

# create a folder "result" if it doesn't already exist
results_dir="Results"
if [ ! -d "$results_dir" ]; then
  mkdir "$results_dir"
  echo "Folder created: $results_dir"
fi

# Ask the user to enter login information
read -p "Server Address: " db_host
read -p "DB Port: " db_port
read -p "User Name: " db_user
read -s -p "Password: " db_password
echo

# Run psql's "--list" command with user-supplied login credentials
databases=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" --list -t | cut -d'|' -f1 | sed -e '/^\s*$/d')
# Display List of DB
echo "List of databases available on the server:"
echo "$databases"
echo

# Declare an associative array to store initial table sizes
declare -A initial_table_sizes

# Function to retrieve and process tables from a database
process_tables() {
  local db_host="$1"
  local db_port="$2"
  local db_user="$3"
  local db_password="$4"
  local database="$5"
  local -n tables_ref="$6"  # Use nameref for passing array by reference

  tables_ref=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "\dt" | awk '{print $3}' | grep -v "schema")
}

# Process each database
for database in $databases; do
    # Retrieve tables
    process_tables "$db_host" "$db_port" "$db_user" "$db_password" "$database" tables
    output_content="----------------------------------------------------------------------\n"
    output_content+="Database: $database\n"
    output_content+="----------------------------------------------------------------------\n"

    for table in $tables; do
        # Initial size
        initial_size=$(get_table_size "$db_host" "$db_port" "$db_user" "$db_password" "$database" "$table")
        initial_table_sizes["$table"]=$initial_size
    done

    echo "----------------------------------------------------------------------"
    echo "Database: $database"
    echo "----------------------------------------------------------------------"

    # Display result header
    output_content+="| Table | Number of lines | Current Size | Size Difference |\n"
    output_content+="------------------------------------------------------------------------\n"
    for table in $tables; do
        # Number of lines
        row_count=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$database" -t -c "SELECT COUNT(*) FROM $table")
        # Current size
        current_size=$(get_table_size "$db_host" "$db_port" "$db_user" "$db_password" "$database" "$table")
        # Calculate the difference
        size_difference=$((current_size - initial_table_sizes["$table"]))

        # Convert sizes to human-readable format
        current_size_human=$(format_size "$current_size")
        size_difference_human=$(format_size "$size_difference")

        # Display the table name, current size, and size difference
        output_content+="| $table | $row_count | $current_size_human | $size_difference_human |\n"
    done

    output_content+="------------------------------------------------------------------------\n"

    # Register results in a file
    output_filename="$results_dir/resultats_${database}.txt"
    save_results_to_file "$output_filename" "$output_content"
    echo "Results registered: $output_filename"
done

# display folder
echo "results are stored in folder: $results_dir"