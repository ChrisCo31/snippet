#!/bin/bash

# Bootstrap server name
read -p "Enter server adress: " server

# Information to retrieve
echo "Configuration :"
read -p "Enter the name of consumer group (ex: steering-node-consumer-group): " consumer_group
read -p "Enter topic name (ex: steering-internal-requests): " topic

# Sum up 
echo "Sum up :"
echo "kafka-consumer-groups.sh --bootstrap-server $server --group $consumer_group --topic $topic --reset-offsets --to-latest --execute"

# Confirm execution
read -p "Do you want to execut this command ? (y/n): " confirm
if [ "$confirm" = "y" ]; then
    # Exécuter la commande
    kafka-consumer-groups.sh --bootstrap-server $server --group $consumer_group --topic $topic --reset-offsets --to-latest --execute
    echo "Command executed."
else
    echo "Execution canceled."
fi

