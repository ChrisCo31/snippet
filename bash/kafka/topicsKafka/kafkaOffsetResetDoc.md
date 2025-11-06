# Script kafka-offset-reset.sh 

## Purpose:

This script simplifies the task of managing Kafka consumer offsets by providing an interactive approach to choose and execute offset resets based on specific requirements for different topics.

## Usage:

### Server Address:
Enter the Kafka server address where the consumer groups are configured.

### Topics:
Input the names of the Kafka topics (comma-separated) for which you want to reset consumer offsets.

### Reset Modes:
Choose one of the following reset modes:
- To Latest: Resets offsets to the latest available position in the topic.
- To Earliest: Resets offsets to the beginning of the topic.
- Specific Offset: Resets offsets to a specified numeric offset.
- To Timestamp: Resets offsets to messages published after a specific timestamp.

### Confirmation:

Confirm your choices before proceeding with the offset reset operation.
Execution:









