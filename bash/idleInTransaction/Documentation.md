# Script IdleInTransaction.sh

## Objective
This script is designed to monitor and terminate PostgreSQL database sessions that have been idle in a transaction for more than a specified duration. It prompts the user for database connection details and uses these to connect to PostgreSQL and perform the necessary operations.

## Usage
Ensure you have PostgreSQL installed and accessible from the machine where this script will run. The script assumes it can use psql command-line utility to connect to the database.

## Script Steps

### User Input

The script prompts the user for the following information:
- Server Address (db_host)
- Database Port (db_port)
- Database Name (db_name)
- Database User Name (db_user)
- Database User Password (db_password) (input is hidden)


### Idle Session Threshold

The script defines IDLE_THRESHOLD as 3600 seconds (1 hour), indicating sessions idle in a transaction longer than this will be terminated.

### Calculate Time Threshold

It computes CURRENT_TIMESTAMP as the current Unix timestamp (date +%s).

TIME_THRESHOLD is computed as CURRENT_TIMESTAMP - IDLE_THRESHOLD.


### SQL Query Construction

Constructs IDLE_QUERY to retrieve PostgreSQL sessions that are "idle in transaction" and have not changed state (state_change) within the last IDLE_THRESHOLD seconds.

### Execute SQL Query

Uses psql to execute IDLE_QUERY against the specified PostgreSQL database using the provided credentials (db_host, db_port, db_name, db_user, db_password).

### Process Sessions to Terminate

- Iterates over the results (SESSIONS_TO_TERMINATE) returned by the SQL query.
- Extracts the PID (Process ID) and the active query of each session.
- Displays information about each session being terminated.
- Uses psql to execute SELECT pg_terminate_backend(PID); to terminate each identified session.

### Requirements

PostgreSQL database accessible from the machine running the script.
psql command-line utility installed and configured to connect to the PostgreSQL instance.

# Script TestWithoutTerminate.sh


The script is intended for quickly identifying and displaying PostgreSQL sessions that have been idle in a transaction for a very short period (1 second in this example).

To actually terminate these sessions, additional modifications would be needed to include a loop and pg_terminate_backend command, similar to the first script provided.