#!/bin/bash

# Step 1: Retrieve pods names
pods=$(oc get pods --no-headers | awk '{print $1}')
echo "Pods list before restart :"
echo "$pods"

# List of pods to exclude
excluded_pods=("gtsi-db-mongo-exposed" "gtsi-interface" "gtsi-mongo" "gtsi-nginx-staging" "jenkins")

# Step 2: Creation of table with all pods
IFS=$'\n' read -rd '' -a pod_array <<< "$pods"

# Step 3: Filter pods array to exclude specified pods
filtered_pods=()
for pod in "${pod_array[@]}"; do
  skip=
  for exclude in "${excluded_pods[@]}"; do
    if [[ $pod == $exclude ]]; then
      skip=1
      break
    fi
  done
  [[ ! $skip ]] && filtered_pods+=("$pod")
done

# Step 4: Shuffle filtered array elements randomly
shuffled_pods=($(shuf -e "${filtered_pods[@]}"))

# Variable to store names of restarted pods
restarted_pods=""

# Step 5: Loop to restart all pods except excluded
for pod in "${shuffled_pods[@]}"; do
  oc rollout latest deployment/"$pod"
  restarted_pods+=" $pod"
done

# Display list of restarted pods
echo "List of restarted pods:"
echo "$restarted_pods"
