#!/bin/bash

# Ensure required packages are installed
apt update && apt upgrade -yqq
apt install ipset -yqq

# Create the whitelist
ipset create whitelist hash:ip hashsize 4096
ipset add whitelist 35.82.18.19
ipset add whitelist 44.235.115.250
ipset add whitelist 52.27.182.63
ipset add whitelist 3.248.148.80
ipset add whitelist 54.170.182.176
ipset add whitelist 54.78.50.234
ipset add whitelist 18.139.188.145

# Backup the whitelist 
ipset save whitelist -f ipset-whitelist.backup

# Allow whitelist access
iptables -A INPUT -m set --match-set whitelist src -j ACCEPT

apt install ipset-persistent iptables-persistent -yqq
# Persist the whitelist and new firewall rules after reboot
iptables-save > /etc/iptables/rules.v4
