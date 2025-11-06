#!/bin/bash

# ============================================================================
# CASCADING DELETE SCRIPT - GENERIC VERSION
# ============================================================================
# WARNING: This script will permanently delete data from the database.
# Please ensure you have a backup or have confirmed that this data can be safely removed.
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS
# ============================================================================

print_warning() {
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}                    ⚠️  WARNING ⚠️${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}This script will PERMANENTLY DELETE data from your database.${NC}"
    echo -e "${RED}This operation CANNOT be undone.${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

confirm_action() {
    local confirmation
    read -p "Do you have a recent backup? (yes/no): " confirmation
    if [[ "$confirmation" != "yes" ]]; then
        echo -e "${RED}Operation cancelled. Please create a backup first.${NC}"
        exit 1
    fi

    echo ""
    read -p "Type 'DELETE' in uppercase to confirm deletion: " confirmation
    if [[ "$confirmation" != "DELETE" ]]; then
        echo -e "${RED}Operation cancelled. Confirmation not received.${NC}"
        exit 1
    fi
}

get_connection_info() {
    echo -e "${GREEN}Enter database connection information:${NC}"
    read -p "Server address: " db_host
    read -p "Database port: " db_port
    read -p "Database name: " db_name
    read -p "Username: " db_user
    read -s -p "Password: " db_password
    echo
}

test_connection() {
    echo -e "${YELLOW}Testing database connection...${NC}"
    export PGPASSWORD=$db_password

    if psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" -c "SELECT 1;" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Connection successful${NC}"
    else
        echo -e "${RED}✗ Connection failed. Please check your credentials.${NC}"
        unset PGPASSWORD
        exit 1
    fi
}

count_records() {
    local table=$1
    local count
    count=$(psql -h "$db_host" -p "$db_port" -U "$db_user" -d "$db_name" -t -c "SELECT COUNT(*) FROM $table;" 2>/dev/null || echo "0")
    echo "$count" | tr -d ' '
}

dry_run_mode() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}                    DRY RUN MODE${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "Counting records that would be deleted..."
    echo ""

    # Count records in main tables
    local entity_artifacts=$(count_records "public.entity_artifact")
    local entity_nodes=$(count_records "public.entity_node")
    local history_entries=$(count_records "public.entity_history_entry")
    local history_events=$(count_records "public.entity_history_event")

    echo "Records to be deleted:"
    echo "  - entity_artifact: $entity_artifacts"
    echo "  - entity_node: $entity_nodes"
    echo "  - entity_history_entry: $history_entries"
    echo "  - entity_history_event: $history_events"
    echo "  - Related records in junction tables"
    echo ""
    echo -e "${YELLOW}No data will be deleted in dry-run mode.${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

execute_deletion() {
    echo ""
    echo -e "${YELLOW}Starting cascading deletion...${NC}"

    psql_command="psql --host $db_host --port $db_port --username $db_user --dbname $db_name"

    $psql_command <<EOF
BEGIN;

-- Step 1: Delete history entries
DELETE FROM public.entity_history_entry WHERE id IN (
    SELECT ehe.id FROM public.entity_history_entry ehe
    WHERE history_event_id IN (
        SELECT hev.id FROM public.entity_history_event hev
        WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
    )
);

-- Step 2: Delete history events
DELETE FROM public.entity_history_event WHERE id IN (
    SELECT hev.id FROM public.entity_history_event hev
    WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 3: Delete update tracking nodes
DELETE FROM public.entity_updater_node WHERE object_id IN (
    SELECT eun.object_id FROM public.entity_updater_node eun
    WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 4: Delete revision tracking nodes
DELETE FROM public.entity_revision_node WHERE object_id IN (
    SELECT ern.object_id FROM public.entity_revision_node ern
    WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 5: Delete planning event nodes
DELETE FROM public.planning_event_node WHERE object_id IN (
    SELECT pen.object_id FROM public.planning_event_node pen
    WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 6: Delete modification tracking nodes
DELETE FROM public.modification_node WHERE object_id IN (
    SELECT mn.object_id FROM public.modification_node mn
    WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 7: Delete document validity records
DELETE FROM public.entity_document_validity WHERE entity_root_id IN (
    SELECT edv.entity_root_id FROM public.entity_document_validity edv
    WHERE entity_root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 8: Delete category nodes
DELETE FROM public.category_node WHERE root_id IN (
    SELECT cn.root_id FROM public.category_node cn
    WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 9: Delete junction table - entity to category
DELETE FROM public.r_entity_node_category_node WHERE parent_node_id IN (
    SELECT r.parent_node_id FROM public.r_entity_node_category_node r
    WHERE parent_node_id IN (SELECT en.node_id FROM public.entity_node en)
);

-- Step 10: Delete junction table - entity to external site A
DELETE FROM public.r_entity_node_ext_site_a WHERE node_object_id IN (
    SELECT r.node_object_id FROM public.r_entity_node_ext_site_a r
    WHERE node_object_id IN (SELECT en.node_id FROM public.entity_node en)
);

-- Step 11: Delete junction table - entity to external site B
DELETE FROM public.r_entity_node_ext_site_b WHERE node_object_id IN (
    SELECT r.node_object_id FROM public.r_entity_node_ext_site_b r
    WHERE node_object_id IN (SELECT en.node_id FROM public.entity_node en)
);

-- Step 12: Delete junction table - entity to modification
DELETE FROM public.r_entity_node_modification_node WHERE parent_node_id IN (
    SELECT r.parent_node_id FROM public.r_entity_node_modification_node r
    WHERE parent_node_id IN (SELECT en.node_id FROM public.entity_node en)
);

-- Step 13: Delete junction table - entity to planning event
DELETE FROM public.r_entity_node_planning_event_node WHERE parent_node_id IN (
    SELECT r.parent_node_id FROM public.r_entity_node_planning_event_node r
    WHERE parent_node_id IN (SELECT en.node_id FROM public.entity_node en)
);

-- Step 14: Delete junction table - entity to updater
DELETE FROM public.r_entity_node_updater_node WHERE parent_node_id IN (
    SELECT r.parent_node_id FROM public.r_entity_node_updater_node r
    WHERE parent_node_id IN (SELECT en.node_id FROM public.entity_node en)
);

-- Step 15: Delete main entity nodes
DELETE FROM public.entity_node WHERE object_id IN (
    SELECT en.object_id FROM public.entity_node en
    WHERE root_id IN (SELECT ea.root_id FROM public.entity_artifact ea)
);

-- Step 16: Delete root artifacts (final step)
DELETE FROM public.entity_artifact WHERE root_id IN (
    SELECT ea.root_id FROM public.entity_artifact ea
);

-- Commit transaction
COMMIT;
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Deletion completed successfully${NC}"
    else
        echo -e "${RED}✗ Deletion failed. Transaction rolled back.${NC}"
        unset PGPASSWORD
        exit 1
    fi
}

cleanup() {
    unset PGPASSWORD
    echo -e "${GREEN}✓ Cleanup completed${NC}"
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Parse command line arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" || "$1" == "-d" ]]; then
    DRY_RUN=true
fi

# Display usage
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --dry-run    Show what would be deleted without actually deleting"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0               Execute deletion (with confirmation)"
    echo "  $0 --dry-run     Preview deletion without executing"
    exit 0
fi

# Main execution flow
print_warning

if [ "$DRY_RUN" = false ]; then
    confirm_action
fi

get_connection_info
test_connection

if [ "$DRY_RUN" = true ]; then
    dry_run_mode
else
    execute_deletion
fi

cleanup

echo ""
echo -e "${GREEN}Script completed.${NC}"