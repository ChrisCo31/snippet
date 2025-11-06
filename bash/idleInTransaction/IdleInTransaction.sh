#!/bin/bash

# Ask login information
read -p "Server Address : " db_host
read -p "DB Port: " db_port
read -p "Database Name: " db_name
read -p "User Name : " db_user
read -s -p "Password: " db_password
echo

# Threshold in seconds
IDLE_THRESHOLD=3600

# Calculate the time threshold
CURRENT_TIMESTAMP=$(date +%s)
TIME_THRESHOLD=$((CURRENT_TIMESTAMP - IDLE_THRESHOLD))

# Query to retrieve idle in transaction sessions
IDLE_QUERY="SELECT pid, query FROM pg_stat_activity WHERE state = 'idle in transaction' AND state_change < now() - interval '$IDLE_THRESHOLD seconds';"

# Execute the query using psql
SESSIONS_TO_TERMINATE=$(PGPASSWORD="$db_password" psql -U "$db_user" -d "$db_name" -h "$db_host" -p "$db_port" -t -c "$IDLE_QUERY")

# Loop through sessions and terminate them
while IFS= read -r SESSION; do
    PID=$(echo "$SESSION" | awk '{print $1}')
    SESSION_QUERY=$(echo "$SESSION" | awk '{$1=""; print substr($0, index($0,$2))}')  
    echo "Terminating session with PID $PID and query: $SESSION_QUERY"
    PGPASSWORD="$db_password" psql -U "$db_user" -d "$db_name" -h "$db_host" -p "$db_port" -c "SELECT pg_terminate_backend($PID);"
done <<< "$SESSIONS_TO_TERMINATE"
