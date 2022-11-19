#!/bin/bash
# This script should whitelist all current blastapi ip addresses

apt update && apt upgrade -y
apt install ipset nftables iptables -y

# Create the list
ipset create whitelist hash:ip hashsize 4096
ipset add whitelist 35.82.18.19
ipset add whitelist 44.235.115.250
ipset add whitelist 52.27.182.63
ipset add whitelist 3.248.148.80
ipset add whitelist 54.170.182.176
ipset add whitelist 54.78.50.234
ipset add whitelist 18.139.188.145

# Save the list 
ipset save whitelist -f ipset-whitelist.backup

# Permit the list 
iptables -A INPUT -m set --match-set whitelist src -j ACCEPT

# Save everything
apt install ipset-persistent iptables-persistent -y
ipset-save > /etc/iptables/ipsets
iptables-save > /etc/iptables/rules.v4

