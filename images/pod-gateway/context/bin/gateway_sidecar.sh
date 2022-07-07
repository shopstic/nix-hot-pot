#!/bin/bash

set -ex

DNSMASQ_SHARE=${DNSMASQ_SHARE:?"DNSMASQ_SHARE env var is required"}

# Load main settings
cat /default_config/settings.sh
. /default_config/settings.sh
cat /config/settings.sh
. /config/settings.sh

#Get K8S DNS
K8S_DNS=$(grep nameserver /etc/resolv.conf | cut -d' ' -f2)

cat << EOF > /etc/dnsmasq.conf
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
conf-file=${DNSMASQ_SHARE}/trust-anchors.conf
dnssec

resolv-file=/etc/resolv.conf
EOF

for local_cidr in $DNS_LOCAL_CIDRS; do
  cat << EOF >> /etc/dnsmasq.conf
  # Send ${local_cidr} DNS queries to the K8S DNS server
  server=/${local_cidr}/${K8S_DNS}
EOF
done

# Make a copy of /etc/resolv.conf
/bin/copy_resolv.sh

# Dnsmasq daemon
dnsmasq -k &
dnsmasq=$!

_kill_procs() {
  echo "Signal received -> killing processes"
  kill -TERM $dnsmasq
  wait $dnsmasq
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

#Wait for dnsmasq
wait $dnsmasq