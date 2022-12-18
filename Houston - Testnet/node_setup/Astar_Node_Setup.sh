#!/bin/bash
# Astar BlastAPI Node Setup

# Settings
RELEASE_VERSION=v4.39.1
BINARY_URL="https://github.com/AstarNetwork/Astar/releases/download/${RELEASE_VERSION}/astar-collator-${RELEASE_VERSION}-ubuntu-x86_64.tar.gz"
DATA_DIR="/var/lib/astar-data"

# Update System
sudo apt-get update && sudo apt-get upgrade -y 
sudo apt-get autoremove -y && sudo apt-get autoclean -y
sudo apt-get install git curl wget jq net-tools lz4 zip unzip mlocate unattended-upgrades net-tools whois apt-transport-https ca-certificates libssl-dev gnupg bash-completion needrestart node-ws -y

# Add User 
adduser astar_service --system --no-create-home
mkdir -p $DATA_DIR && cd $DATA_DIR

# Download and Install binary
wget $BINARY_URL
tar -xf astar-collator-${RELEASE_VERSION}-ubuntu-x86_64.tar.gz 
sudo chown -R astar_service $DATA_DIR
sudo chmod ugo+x "$DATA_DIR"/astar-collator 

# Create new systemd service 
cat <<EOF >/etc/systemd/system/astar.service 
[Unit]
Description=Astar Node

[Service]
Type=simple
Restart=on-failure
RestartSec=10
User=astar_service
SyslogIdentifier=astar
SyslogFacility=local7
KillSignal=SIGHUP  
ExecStart=/var/lib/astar-data/astar-collator \
     --sync=full \
     --blocks-pruning archive \
     --port=30333 \
     --rpc-port=9933 \
     --ws-port=9944 \
     --execution=Wasm \
     --wasm-execution=compiled \
     --unsafe-rpc-external \ 
     --unsafe-ws-external \ 
     --rpc-cors all \
     --prometheus-external \
     --prometheus-port 9617 \
     --name "<NODE_NAME>" \
     --chain astar \
     --base-path /var/lib/astar-data \
     -- \
     --port 30334 \
     --prometheus-external \
     --prometheus-port 9616 \
     --name="ImStaked-embedded-relay"

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and Start the service
sudo systemctl daemon-reload
sudo systemctl enable astar.service
sudo systemctl start astar.service
sudo systemctl stop astar.service 

# Polkadot Data Snapshot
rm -rf "$DATA_DIR"/polkadot
mkdir -p "$DATA_DIR"/polkadot/chains/polkadot
echo "** Downloading and extracting relaychain data this could take a while **"
curl -o - -L https://storage.googleapis.com/polkadot_snapshots/polkadot.RocksDB.tar | lz4 -c -d - | tar -x -C "$DATA_DIR"/polkadot/chains/polkadot

# astar Data Snapshot
rm -rf "$DATA_DIR"/chains/astar
mkdir -p "$DATA_DIR"/chains/astar
echo "** Downloading and extracting parachain data this might take a while **"
curl -o - -L https://snapshots.stakecraft.com/astar_2022-11-28.tar | tar -x -C "$DATA_DIR"/chains/astar
# Chown After Moving All data
sudo chown -R astar_service "$DATA_DIR"

# Start the service 
sudo systemctl start astar.service 

echo '*  Check the service status with --->     sudo systemctl status astar.service  *'
echo '*  Check the service logs --->            sudo journalctl -f -u astar.service  *'
