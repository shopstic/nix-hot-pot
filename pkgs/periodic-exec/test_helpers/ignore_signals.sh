#!/bin/bash

# ignore_signals.sh
# This script runs indefinitely and ignores SIGINT and SIGTERM signals.

# Function to handle signals (does nothing)
handle_signal() {
  echo "Received signal, but ignoring it."
}

# Trap SIGINT (Ctrl+C) and SIGTERM
trap 'handle_signal' SIGINT SIGTERM

echo "ignore_signals.sh is running. PID: $$"
echo "It will ignore SIGINT and SIGTERM signals."

# Infinite loop to keep the script running
while true; do
  sleep 1
done
