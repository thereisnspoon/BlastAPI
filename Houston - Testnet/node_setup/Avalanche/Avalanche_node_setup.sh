#!/bin/bash

# Avalanche Node Setup
# by ImStaked

sudo apt-get update && sudo apt-get upgrade -y 
sudo apt-get autoremove -y && sudo apt-get autoclean -y
sudo apt-get install git curl wget jq net-tools lz4 zip unzip mlocate unattended-upgrades net-tools whois apt-transport-https ca-certificates libssl-dev gnupg bash-completion needrestart node-ws -y

useradd -m -d /home/avax -s /bin/bash -U avax
su avax && cd ~

echo "Auto install is about to begin be prepared to answer a few questions when it is done"
wget -nd -m https://raw.githubusercontent.com/ava-labs/avalanche-docs/master/scripts/avalanchego-installer.sh;\
chmod 755 avalanchego-installer.sh;\
./avalanchego-installer.sh
sudo systemctl start avalanchego
sudo systemctl stop avalanchego

cd /home/avax/.avalanchego/db
mv mainnet mainnet_old
wget -O ~/avalanche_mainnet_20221218.tar \ 
http://youravaxsnapshot.senseinode.com/avalanche_mainnet_20221218.tar
tar -xf ~/avalanche_mainnet_20221218.tar -C .

chown -R avax:avax /home/avax

# Enable Metrics / Prometheus - path is ---> ext/metrics
cat <<EOF > /home/avax/.avalanchego/configs/node.json
{
  "api-metrics-enabled": true
}
EOF

systemctl start avalanchego
