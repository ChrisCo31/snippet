#!/bin/bash

# Server name
read -p "Enter server address: " server

# Prompt for topics
read -p "Enter topics (comma-separated): " topics

# Split comma-separated topics into an array
IFS=',' read -ra topic_array <<< "$topics"

# Choose reset mode
echo "Choose reset mode:"
echo "1. To Latest (reset offsets to the latest available position)"
echo "2. To Earliest (reset offsets to the beginning of the topic)"
echo "3. Specify Offset (reset offsets to a specific offset)"
echo "4. To Timestamp (reset offsets to a specific timestamp)"
read -p "Enter your choice (1/2/3/4): " reset_choice

case $reset_choice in
    1)
        reset_mode="--to-latest"
        ;;
    2)
        reset_mode="--to-earliest"
        ;;
    3)
        read -p "Enter specific offset: " specific_offset
        reset_mode="--to-offset $specific_offset"
        ;;
    4)
        read -p "Enter timestamp (YYYY-MM-DDTHH:mm:SS.sssZ): " timestamp
        reset_mode="--to-datetime $timestamp"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Summarize chosen options
echo "Summary:"
echo "Server Address: $server"
echo "Topics: ${topic_array[@]}"
echo "Reset Mode: $reset_mode"

# Confirm test execution
read -p "Do you want to test this command? (y/n): " confirm
if [ "$confirm" = "y" ]; then
    # Execute the command for each topic in test mode
    for topic in "${topic_array[@]}"
    do
        echo "Testing reset for topic: $topic"
        echo "kafka-consumer-groups.sh --bootstrap-server $server --topic $topic --reset-offsets $reset_mode --dry-run"
    done
    echo "All tests completed."
else
    echo "Test canceled."
fi
