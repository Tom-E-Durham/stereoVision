#!/bin/bash

# Function to try a command with a descriptive name
try_command() {
    local command_name=$1
    local command=$2
    local max_attempts=5
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt+1))
        echo "Attempting $command_name (Attempt $attempt of $max_attempts)"

        OUTPUT=$($command)
        if ! echo "$OUTPUT" | grep -q "ERROR: Could not open session!"; then
            echo "$command_name successful."
            return 0
        fi
        sleep 1
    done

    echo "$command_name failed after $max_attempts attempts."
    return 1
}

# Function to get and print battery level
get_battery_level() {
    local max_attempts=5
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt+1))
        echo "Attempting to get battery level (Attempt $attempt of $max_attempts)"

        local output
        output=$(ptpcam --show-property=0x5001)
        if echo "$output" | grep -q 'Battery Level'; then
            local battery_level
            battery_level=$(echo "$output" | grep 'Battery Level' | awk '{print $NF}')
            echo "Battery Level: $battery_level%"
            return 0
        fi
        sleep 1
    done

    echo "Failed to get battery level after $max_attempts attempts."
    return 1
}

# Function to set live streaming mode with retry mechanism
set_live_streaming_mode() {
    local max_attempts=5
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt+1))
        echo "Attempting to set live streaming mode (Attempt $attempt of $max_attempts)"

        local output
        output=$(ptpcam --set-property=0x5013 --val=0x8005)
        if ! echo "$output" | grep -q "ERROR"; then
            echo "Live Streaming Mode set successfully."
            return 0
        fi
        sleep 1
    done

    echo "Failed to set Live Streaming Mode after $max_attempts attempts."
    return 1
}
# Main script starts here
# Check if the Theta V connected (loop until successful or 5 attempts)
try_command "Checking Camera Connection" "ptpcam --info" || exit 1

# After successful connection
try_command "Turning on the Camera" "ptpcam --set-property=0xD80E --val=0x00" || exit 1
sleep 1 # Delay after turning on the camera
get_battery_level || exit 1
sleep 1 # Delay after checking battery level
set_live_streaming_mode || exit 1

gst-launch-1.0 thetauvcsrc mode=2K \
  ! queue \
  ! h264parse \
  ! nvdec \
  ! queue \
  ! glimagesink sync=false 