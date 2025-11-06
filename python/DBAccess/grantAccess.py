#!/usr/bin/env python3
"""
PostgreSQL Read Access Granter
Grants read-only privileges to a user across all databases with public schema.
"""

import getpass
import sys
import subprocess
from typing import List, Optional

def get_user_input() -> dict:
    """Collect database connection parameters securely."""
    print("=== PostgreSQL Connection Settings ===")
    return {
        'host': input("Server Address: ").strip(),
        'port': input("DB Port [5432]: ").strip() or '5432',
        'admin_user': input("Admin Username: ").strip(),
        'admin_password': getpass.getpass("Admin Password: "),
        'grant_user': input("Username to grant read access: ").strip()
    }

def run_psql_command(config: dict, database: str, command: str) -> Optional[str]:
    """Execute a psql command and return output."""
    cmd = [
        'psql',
        '-h', config['host'],
        '-p', config['port'],
        '-U', config['admin_user'],
        '-d', database,
        '-t',  # tuples only
        '-c', command
    ]
    
    env = {'PGPASSWORD': config['admin_password']}
    
    try:
        result = subprocess.run(
            cmd,
            env=env,
            capture_output=True,
            text=True,
            check=True,
            timeout=30
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"❌ Error on database '{database}': {e.stderr}", file=sys.stderr)
        return None
    except subprocess.TimeoutExpired:
        print(f"⏱️ Timeout on database '{database}'", file=sys.stderr)
        return None

def list_databases(config: dict) -> List[str]:
    """Get list of databases with public schema."""
    output = run_psql_command(
        config,
        'postgres',
        "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';"
    )
    
    if not output:
        return []
    
    return [db.strip() for db in output.split('\n') if db.strip()]

def grant_read_access(config: dict, database: str) -> bool:
    """Grant read-only privileges on a single database."""
    grant_user = config['grant_user']
    
    commands = [
        f"GRANT CONNECT ON DATABASE {database} TO {grant_user};",
        f"GRANT USAGE ON SCHEMA public TO {grant_user};",
        f"GRANT SELECT ON ALL TABLES IN SCHEMA public TO {grant_user};",
        f"GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO {grant_user};",
        f"ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO {grant_user};",
        f"ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO {grant_user};"
    ]
    
    for cmd in commands:
        result = run_psql_command(config, database, cmd)
        if result is None:
            return False
    
    return True

def main():
    """Main execution flow."""
    print("🔐 PostgreSQL Read Access Grant Tool\n")
    
    # Validate psql is installed
    try:
        subprocess.run(['psql', '--version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Error: psql is not installed or not in PATH", file=sys.stderr)
        sys.exit(1)
    
    # Get configuration
    config = get_user_input()
    
    if not all([config['host'], config['admin_user'], config['admin_password'], config['grant_user']]):
        print("❌ All fields are required", file=sys.stderr)
        sys.exit(1)
    
    print(f"\n📊 Fetching databases from {config['host']}...")
    databases = list_databases(config)
    
    if not databases:
        print("⚠️ No databases found or connection error")
        sys.exit(1)
    
    print(f"\n✅ Found {len(databases)} database(s):")
    for db in databases:
        print(f"  - {db}")
    
    # Confirm before proceeding
    confirm = input(f"\n⚠️ Grant READ access to '{config['grant_user']}' on these databases? [y/N]: ")
    if confirm.lower() != 'y':
        print("❌ Operation cancelled")
        sys.exit(0)
    
    # Grant permissions
    print(f"\n🔄 Granting permissions...")
    success_count = 0
    
    for db in databases:
        if grant_read_access(config, db):
            print(f"  ✅ {db}")
            success_count += 1
        else:
            print(f"  ❌ {db} (check errors above)")
    
    print(f"\n🎉 Completed: {success_count}/{len(databases)} databases updated successfully")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️ Operation cancelled by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)