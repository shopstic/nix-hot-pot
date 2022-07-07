#!/bin/bash

set -ex

# Load main settings
cat /default_config/settings.sh
. /default_config/settings.sh
cat /config/settings.sh
. /config/settings.sh

#Get K8S DNS
K8S_DNS=$(grep nameserver /etc/resolv.conf | cut -d' ' -f2)


cat << EOF > /etc/dnsmasq.d/pod-gateway.conf
# DHCP server settings
interface=vxlan0
bind-interfaces

# Dynamic IPs assigned to PODs - we keep a range for static IPs
dhcp-range=${VXLAN_IP_NETWORK}.${VXLAN_GATEWAY_FIRST_DYNAMIC_IP},${VXLAN_IP_NETWORK}.255,12h

# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
log-queries

# Log lots of extra information about DHCP transactions.
log-dhcp

# Log to stdout
log-facility=-

# Clear DNS cache on reload
clear-on-reload

# Enable DNSSEC validation and caching
conf-file=/usr/share/dnsmasq/trust-anchors.conf
dnssec

# /etc/resolv.conf cannot be monitored by dnsmasq since it is in a different file system
# and dnsmasq monitors directories only
# copy_resolv.sh is used to copy the file on changes
resolv-file=${RESOLV_CONF_COPY}
EOF

for local_cidr in $DNS_LOCAL_CIDRS; do
  cat << EOF >> /etc/dnsmasq.d/pod-gateway.conf
  # Send ${local_cidr} DNS queries to the K8S DNS server
  server=/${local_cidr}/${K8S_DNS}
EOF
done

# Make a copy of /etc/resolv.conf
/bin/copy_resolv.sh

# Dnsmasq daemon
dnsmasq -k &
dnsmasq=$!

# inotifyd to keep in sync resolv.conf copy
# Monitor file content (c) and metadata (e) changes
inotifyd /bin/copy_resolv.sh /etc/resolv.conf:ce
inotifyd=$!

_kill_procs() {
  echo "Signal received -> killing processes"
  kill -TERM $dnsmasq
  wait $dnsmasq
  kill -TERM $inotifyd
  wait $inotifyd
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

#Wait for dnsmasq
wait $dnsmasq

echo "TERMINATING"

# kill inotifyd
kill -TERM $inotifyd
wait $inotifyd
