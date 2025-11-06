#!/bin/bash

# ============================================================================
# CSV CONNECTIVITY TEST SCRIPT
# ============================================================================
# Description: Tests network connectivity for hosts listed in a CSV file
# Usage: ./csv_connectivity_test.sh <csv_file>
# CSV Format: Must have hostname in column 3, IP in column 6, port in column 9
# ============================================================================

set -e  # Exit immediately if a command exits with a non-zero status

# ============================================================================
# COLORS FOR OUTPUT
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# ARGUMENT VALIDATION
# ============================================================================

# Check if exactly one argument (CSV file) is provided
if [ $# -ne 1 ]; then
    echo -e "${RED}Error: Missing CSV file argument${NC}"
    echo "Usage: $0 <csv_file>"
    exit 1
fi

# Store the CSV file path from argument
csv_file="$1"

# Verify that the CSV file exists
if [ ! -f "$csv_file" ]; then
    echo -e "${RED}Error: CSV file does not exist: $csv_file${NC}"
    exit 1
fi

echo -e "${GREEN}✓ CSV file found: $csv_file${NC}\n"

# ============================================================================
# CSV FILTERING - EXTRACT RELEVANT COLUMNS
# ============================================================================

# Define output file path for filtered columns
filtered_output_file="filtered_${csv_file}"

echo -e "${BLUE}Extracting columns from CSV...${NC}"

# Extract only columns 3 (hostname), 6 (IP), and 9 (port)
# Column 7 was in original script but never used, so removed for efficiency
awk -F"," 'BEGIN {OFS=","} {print $3, $6, $9}' "$csv_file" > "$filtered_output_file"

echo -e "${GREEN}✓ Filtered file created: $filtered_output_file${NC}\n"

# ============================================================================
# FIND DATA START LINE
# ============================================================================

echo -e "${BLUE}Detecting data start line...${NC}"

# Find the first line containing a valid IP address pattern (x.x.x.x)
# This skips CSV headers and empty lines
start_line=$(awk -F',' '$2 ~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print NR; exit}' "$filtered_output_file")

# Validate that data was found
if [ -z "$start_line" ]; then
    echo -e "${RED}Error: No valid IP addresses found in CSV${NC}"
    echo "Please verify your CSV format and column positions"
    exit 1
fi

echo -e "${GREEN}✓ Data starts at line: $start_line${NC}\n"

# ============================================================================
# CONNECTIVITY TESTS
# ============================================================================

echo -e "${YELLOW}=== Starting Connectivity Tests ===${NC}\n"

# Initialize result counters
accessible=0
inaccessible=0
total=0

# Read each line from the filtered CSV starting at the data line
while IFS=',' read -r host ip port; do
    # Skip lines with empty IP or port
    if [[ -z "$ip" || -z "$port" ]]; then
        continue
    fi
    
    # Increment total test counter
    ((total++))
    
    echo -e "${BLUE}Testing:${NC} $host ($ip:$port)"
    
    # ========================================================================
    # CONNECTIVITY TEST - Using netcat (nc) or /dev/tcp fallback
    # ========================================================================
    # We use nc for TCP connectivity test (works for any protocol)
    # If nc is not available, we fallback to bash's built-in /dev/tcp
    
    if command -v nc &> /dev/null; then
        # Method 1: Using netcat (preferred - more reliable)
        # -z: Zero-I/O mode (just check if port is open)
        # -v: Verbose (for debugging)
        # timeout 5: Kill the command after 5 seconds
        if timeout 5 nc -z "$ip" "$port" &>/dev/null; then
            echo -e "${GREEN}  ✓ Accessible${NC}\n"
            ((accessible++))
        else
            echo -e "${RED}  ✗ Inaccessible${NC}\n"
            ((inaccessible++))
        fi
    else
        # Method 2: Fallback to /dev/tcp if nc is not installed
        # /dev/tcp is a bash built-in that opens TCP connections
        if timeout 5 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Accessible${NC}\n"
            ((accessible++))
        else
            echo -e "${RED}  ✗ Inaccessible${NC}\n"
            ((inaccessible++))
        fi
    fi
    
# Read from the filtered file starting at the data line
done < <(tail -n +$start_line "$filtered_output_file")

# ============================================================================
# SUMMARY REPORT
# ============================================================================

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}                    TEST SUMMARY${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Accessible hosts:    $accessible${NC}"
echo -e "${RED}Inaccessible hosts:  $inaccessible${NC}"
echo -e "Total tested:        $total"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ============================================================================
# EXIT CODE
# ============================================================================
# Return exit code 1 if any host was inaccessible (useful for CI/CD pipelines)
# Return exit code 0 if all hosts were accessible

if [ $inaccessible -gt 0 ]; then
    echo -e "\n${RED}⚠ Some hosts are inaccessible${NC}"
    exit 1
else
    echo -e "\n${GREEN}✓ All hosts are accessible${NC}"
    exit 0
fi