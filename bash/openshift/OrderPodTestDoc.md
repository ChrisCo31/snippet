# OrderPodTest.sh Documentation

## Overview
This Bash script automates the restart process for pods within an OpenShift environment, while allowing exclusion of specific pods from this operation. It aims to streamline pod management tasks by handling the retrieval of pod names, excluding pods as needed, shuffling the remaining pods randomly, restarting them, and providing a clear summary of the restarted pods.

## Functionality

- Pod Retrieval and Exclusion
The script begins by fetching the list of all pods in the current namespace using the oc get pods command. It then excludes pods specified in the excluded_pods array from the restart operation.

- Randomization and Restart
After filtering out excluded pods, the script shuffles the list of remaining pods randomly to ensure a fair restart sequence. Each pod is restarted using the oc rollout latest deployment/<pod_name> command.

## Summary
Upon completion of the restarts, the script displays a list of the pods that were successfully restarted, allowing administrators to verify the operation's effectiveness.

## Customization: Modify the excluded_pods array to include any pods that should be excluded from the restart process.

Example
Assume a scenario where a deployment requires restarting pods while excluding critical services such as databases (gtsi-db-mongo-exposed, gtsi-mongo), interfaces (gtsi-interface), and other specific applications (gtsi-nginx-staging, jenkins). This script automates the process, ensuring that critical pods are not disrupted while others are restarted in a randomized order.
