#!/bin/bash

# Originally from https://github.com/pmit-pro/zerotier-router
# ZeroTier router entrypoint script
# 04/02/2022 - pm@pixelwarriors.net

# Exit immediately if we get an error
set -e

# Check if we have the /dev/net/tun device available
if [ ! -e /dev/net/tun ]; then
  echo 'FATAL: /dev/net/tun not available - check permissions and mountpath'
  exit 1
fi

# Check if we got some ZT networks to connect to
if [ -z "${ZT_NETWORKS}" ]; then
  echo 'FATAL: No ZT networks defined - check environment variable "ZT_NETWORKS" and provide at least one network-id to join'
  exit 1
fi

# Check if we have existing public/secret identity information provided and if so copy them to ZT config,
# or use the existing identity stored in /var/lib/zerotier-one
# If no identity information is provided we simply generate new public/secret infos
if [ -n "${ZT_ID_PUBLIC}" ] && [ -n "${ZT_ID_SECRET}" ]; then
  echo 'INFO: Using identity configured in env variables'
  echo "${ZT_ID_PUBLIC}" > /var/lib/zerotier-one/identity.public
  echo "${ZT_ID_SECRET}" > /var/lib/zerotier-one/identity.secret
elif [ -f /var/lib/zerotier-one/identity.public ] && [ -f /var/lib/zerotier-one/identity.secret ]; then
  echo 'INFO: Existing identity information found in /var/lib/zerotier-one - using it'
else
  echo 'INFO: Generating new identity information'
  zerotier-idtool generate > /var/lib/zerotier-one/identity.secret
  zerotier-idtool getpublic /var/lib/zerotier-one/identity.secret > /var/lib/zerotier-one/identity.public
fi

# Clear the list of known networks before starting zerotier so we don't join networks that may be stored on a mounted volume
echo 'INFO: Removing known networks...'
set +e
rm -r /var/lib/zerotier-one/networks.d/* &> /dev/null
set -e

# Start zerotier daemon and wait for startup
echo 'INFO: Starting ZeroTier engine...'
zerotier-one &
zt_pid=$!
sleep 1

# Function to get the network IP
GetIP() {
  echo $(zerotier-cli listnetworks | grep "$1" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
}

GetAccessDenied() {
  echo $(zerotier-cli listnetworks | grep "$1" | grep -o ACCESS_DENIED)
}

IFS=',' read -a netarray <<< "${ZT_NETWORKS}"

for network in ${netarray[*]} ; do
  echo "INFO: Joining network ${network}... $(zerotier-cli join "${network}")"

  timeout=10
  while [ $timeout -gt 0 ] ; do
    ip=$(GetIP "$network")
    if [ ! -z "$ip" ] ; then
      echo "INFO: Got IP "$ip" for network "$network""
      break
    fi
    if [ ! -z $(GetAccessDenied "$network") ] ; then
      echo "WARNING: Access denied to network "$network" - Please approve client in network controller"
    fi
    sleep 5
    timeout=$((timeout-1))
    if [ $timeout -eq 0 ] ; then
      echo "ERROR: Timeout while waiting for IP"
    fi
  done
done

echo "INFO: $(zerotier-cli listnetworks)"
echo "INFO: $(zerotier-cli info)"

if [ "${ZT_ENABLE_FORWARD}" = true ] ; then
  echo "INFO: Enabling IP forwarding..."
  # Configure iptables forwarding and masquerade
  # If no interface name is specified assume eth0 pod/container traffic
  iptables -A FORWARD -i zt+ -o "${ZT_IFNAME:-eth0}" -j ACCEPT
  iptables -A FORWARD -i "${ZT_IFNAME:-eth0}" -m state --state RELATED,ESTABLISHED -j ACCEPT

  if [ "${ZT_ENABLE_MASQUERADE}" = true ] ; then
    echo "INFO: Enabling masquerade for outbound interface "${ZT_IFNAME:-eth0}""
    iptables -t nat -o "${ZT_IFNAME:-eth0}" -A POSTROUTING -j MASQUERADE
  fi

  # Enable ip forwarding kernel parameter
  # This may fail in kubernetes environments where sysctls are controlled by the cluster / kubelet
  if [ "$(sysctl net.ipv4.ip_forward | awk -F "= " '{print $2}')" -eq 0 ] ; then
    echo "INFO: Trying to enable net.ipv4.ip_forward kernel parameter"
    sysctl -w net.ipv4.ip_forward=1
  else
    echo "INFO: net.ipv4.ip_forward already enabled"
  fi
else
  echo "INFO: IP forwarding is disabled in config - configuring iptables policy to drop FORWARD"
  iptables -P FORWARD DROP

  if [ "$(sysctl net.ipv4.ip_forward | awk -F "= " '{print $2}')" -eq 1 ] ; then
    echo "WARNING: IP forwarding disabled in config but net.ipv4.ip_forward kernel parameter is enabled"
    echo "WARNING: !!! THIS IS INSECURE !!!"
    echo "WARNING: Check your pod/container privileges!"
    echo "INFO: Trying to disable net.ipv4.ip_forward kernel parameter"
    
    # Since this may fail because of readonly filesystem on docker/kubernetes unprivileged containers fail gracefully but continue running
    set +e
    sysctl -w net.ipv4.ip_forward=0
    set -e
  fi

fi

wait $zt_pid
echo "ZeroTier-One process terminated"
exit $?