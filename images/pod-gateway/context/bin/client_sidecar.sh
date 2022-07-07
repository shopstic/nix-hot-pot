#!/bin/bash
set -e

# Load main settings
cat /default_config/settings.sh
. /default_config/settings.sh
cat /config/settings.sh
. /config/settings.sh

VXLAN_GATEWAY_IP="${VXLAN_IP_NETWORK}.1"

# Loop to test connection to gateway each 10 seconds
# If connection fails then reset connection
while true; do

  echo "Monitor connection to $VXLAN_GATEWAY_IP"

  # Ping the gateway vxlan IP -> this only works when vxlan is up
  while ping -c 1 "$VXLAN_GATEWAY_IP" > /dev/null; do
    # Sleep while reacting to signals
    sleep 10 &
    wait $!
  done

  echo
  echo
  echo "Reconnecting to ${GATEWAY_NAME}"

  # reconnect
  client_init.sh
done
