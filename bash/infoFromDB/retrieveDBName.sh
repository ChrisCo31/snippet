#!/bin/bash

# Ask the user to enter login information
read -p "Server Address : " db_host
read -p "DB Port: " db_port
read -p "User Name : " db_user
read -s -p "Password: " db_password
echo
# Run psql's "--list" command with user supplied login credentials
databases=$(PGPASSWORD="$db_password" psql -h "$db_host" -p "$db_port" -U "$db_user" --list -t | cut -d'|' -f1 | sed -e '/^\s*$/d')
# Display
echo "List of databases available on the server: "
echo "$databases"