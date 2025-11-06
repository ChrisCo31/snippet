# Warning : Offset reset can only be performed when the consumer group has no running instance.



This documentation aims to re-init the offset of the consumer for the topics :

- gtsi_aircrafts_v1
- steering-internal-requests

## Announcement of the operation
On channel Environment concerned by the change. Copy, paste this Chat Message template :


>CHAT MESSAGE TEMPLATE
>
>@all ℹ️ Reset Kafka topics offset
>
>Following Pods will be scale down then scale up
>
>gtsi-svc-aircraft
>gtsi-svc-steering
>
>START: date time.
>
>STATUS: PENDING / IN PROGRESS / DONE
>
>👉 For detail of operation : Link to ticket Jira



## Down the pods corresponding to the topic to reset

- Connect to the Openshift via terminal
- Check you're in the correct environment
- Launch this dedicated script 
>scaleDC.sh

(for details please read part scaleDC.sh of the Documentation_scripts.md) 


## Access to the VM

- identify the server kafka (see table)

- Add path
> export PATH=$PATH:/opt/bitnami/kafka
- Enter the container
> sudo docker exec -it <id_container> /bin/bash

## From the bastion
- Launch the command
>cat deleteTopicsKafka.sh | ssh userName@serverAdress /bin/bash


## Script deleteTopicsKafka.sh

This interactive Bash script facilitates resetting Kafka consumer group offsets to the latest available position on a specified topic. Here is a simple overview of its features and usage:

### Usage:

The script starts by prompting the user to enter the address of the Kafka server (e.g., localhost:9093).

Next, it asks for the Kafka consumer group name and the topic name where messages are consumed.

After inputting the required information, the script summarizes the exact command that will be executed to reset consumer group offsets to the latest position on the specified topic.

It then seeks confirmation from the user before executing the command. If confirmed (y), the command is executed. Otherwise, the execution is canceled.

### Command Executed:

kafka-consumer-groups.sh --bootstrap-server <server_address> --group <consumer_group_name> --topic <topic_name> --reset-offsets --to-latest --execute
Features:

User Interaction: Uses read -p to prompt the user for necessary inputs.

Summary Display: Before execution, displays a summary of the command to be executed for user verification.

Confirmation: Requires explicit confirmation (y or n) from the user before proceeding with the command execution.


This script simplifies the task of managing Kafka consumer group offsets by providing an interactive and controlled approach, ensuring user confirmation before performing potentially impactful actions on the Kafka cluster.