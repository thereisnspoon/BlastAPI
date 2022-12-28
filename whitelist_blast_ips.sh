#!/bin/bash

# This script should whitelist all current blastapi ip addresses
# by ImStaked

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
ipset add whitelist 52.71.120.21
ipset add whitelist 52.20.248.136
ipset add whitelist 52.0.232.1
ipset add whitelist 34.194.155.195

# Example - only permit access to 1 port
# iptables -A INPUT -p tcp -m tcp 8545 -m set --match-set whitelist src -j ACCEPT

# Allow whitelist full access
iptables -A INPUT -m set --match-set whitelist src -j ACCEPT


# Save lists and make persistant
apt install ipset-persistent iptables-persistent -y
ipset save whitelist -f ipset-whitelist.backup
iptables-save > /etc/iptables/rules.v4


echo "All blastapi IP addresses have been whitelisted"
