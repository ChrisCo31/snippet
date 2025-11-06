#!/bin/bash

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Retrieve the list of pods containing 'stream'
echo -e "${YELLOW}Retrieving pods containing 'stream'...${NC}"
readarray -t pods < <(oc get pods --no-headers 2>/dev/null | grep "stream" | awk '{print $1}')

# Check if pods were found
if [ ${#pods[@]} -eq 0 ]; then
    echo -e "${RED}No pods found containing 'stream'.${NC}"
    exit 1
fi

echo -e "${GREEN}Found ${#pods[@]} pod(s).${NC}"
echo ""

# Interactive selection
selected_indices=()
while true; do
    clear
    echo -e "${YELLOW}=== Pod Selection ===${NC}"
    echo "Select pods (Enter the pod number or 'q' to finish):"
    echo ""

    for i in "${!pods[@]}"; do
        if [[ " ${selected_indices[@]} " =~ " ${i} " ]]; then
            echo -e "${GREEN}$i) [X] ${pods[$i]}${NC}"
        else
            echo -e "${RED}$i) [ ] ${pods[$i]}${NC}"
        fi
    done

    echo ""
    echo -e "${YELLOW}Selected: ${#selected_indices[@]} pod(s)${NC}"
    echo ""
    read -p "Choice: " choice

    # Validate input
    if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 0 ] && [ $choice -lt ${#pods[@]} ]; then
        # Toggle selection
        if [[ " ${selected_indices[@]} " =~ " ${choice} " ]]; then
            # Deselect: remove from array
            new_selected_indices=()
            for index in "${selected_indices[@]}"; do
                if [ "$index" != "$choice" ]; then
                    new_selected_indices+=("$index")
                fi
            done
            selected_indices=("${new_selected_indices[@]}")
        else
            # Select: add to array
            selected_indices+=("$choice")
        fi
    elif [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
        if [ "${#selected_indices[@]}" -lt 2 ]; then
            echo -e "${RED}You must select at least two pods.${NC}"
            sleep 2
        else
            break
        fi
    else
        echo -e "${RED}Invalid entry. Please enter a valid number or 'q'.${NC}"
        sleep 1
    fi
done

# Display selected pods
clear
echo -e "${GREEN}=== Selected pods ===${NC}"
for i in "${selected_indices[@]}"; do
    echo "  - ${pods[i]}"
done
echo ""

# Final confirmation
read -p "Confirm deletion of 'state' folder on these pods? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}=== Starting operations ===${NC}"
echo ""

# Execute the command on the selected pods
success_count=0
error_count=0

for index in "${selected_indices[@]}"; do
    pod_name=${pods[index]}
    echo -e "${YELLOW}Processing pod: $pod_name${NC}"

    # Check if state folder exists
    if oc exec "$pod_name" -- test -d state 2>/dev/null; then
        echo "  - Deleting 'state' folder..."
        if oc exec "$pod_name" -- rm -rfv state 2>/dev/null; then
            echo -e "  ${GREEN}✓ Deletion successful${NC}"

            # Verify deletion
            if oc exec "$pod_name" -- test -d state 2>/dev/null; then
                echo -e "  ${RED}✗ Warning: 'state' folder still exists${NC}"
                ((error_count++))
            else
                echo -e "  ${GREEN}✓ Verification: 'state' folder removed${NC}"
                ((success_count++))
            fi
        else
            echo -e "  ${RED}✗ Error during deletion${NC}"
            ((error_count++))
        fi
    else
        echo -e "  ${YELLOW}⚠ 'state' folder does not exist${NC}"
        ((success_count++))
    fi

    echo ""
done

# Summary
echo -e "${GREEN}=== Operations completed ===${NC}"
echo -e "Success: ${GREEN}${success_count}${NC} pod(s)"
echo -e "Errors: ${RED}${error_count}${NC} pod(s)"

if [ $error_count -gt 0 ]; then
    exit 1
fi