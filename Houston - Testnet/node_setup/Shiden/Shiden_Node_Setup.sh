#!/bin/bash
# Shiden Node Setup

# Settings
RELEASE_VERSION=v4.39.1
BINARY_URL="https://github.com/AstarNetwork/Astar/releases/download/${RELEASE_VERSION}/astar-collator-${RELEASE_VERSION}-ubuntu-x86_64.tar.gz"
DATA_DIR="/var/lib/shiden-data"

# Update System
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get autoremove -y && sudo apt-get autoclean -y
sudo apt-get install git curl wget jq net-tools lz4 zip unzip mlocate unattended-upgrades net-tools whois apt-transport-https ca-certificates libssl-dev gnupg bash-completion needrestart node-ws -y

# Add User
adduser shiden_service --system --no-create-home
mkdir -p $DATA_DIR && cd $DATA_DIR

# Download and Install binary
wget $BINARY_URL
tar -xvf astar-collator-${RELEASE_VERSION}-ubuntu-x86_64.tar.gz
sudo chown -R shiden_service $DATA_DIR
sudo chmod ugo+x "$DATA_DIR"/astar-collator

# Create new systemd service
cat <<EOF >/etc/systemd/system/shiden.service
[Unit]
Description=Shiden Node

[Service]
Type=simple
Restart=on-failure
RestartSec=10
User=shiden_service
SyslogIdentifier=astar
SyslogFacility=local7
KillSignal=SIGHUP
ExecStart=/var/lib/shiden-data/astar-collator \
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
     --chain shiden \
     --base-path /var/lib/shiden-data \
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
sudo systemctl enable shiden.service
sudo systemctl start shiden.service
sleep 3
sudo systemctl stop shiden.service

# Polkadot Data Snapshot
rm -rf "$DATA_DIR"/polkadot
mkdir -p "$DATA_DIR"/polkadot/chains/ksmcc3
echo "** Downloading and extracting relaychain data this could take a while **"
relay_data=$(curl -o - -L https://ksm-rocksdb.polkashots.io/snapshot | lz4 -c -d - | tar -x -C "$DATA_DIR"/polkadot/chains/ksmcc3)
$relay_data &

# Shiden Data Snapshot
rm -rf "$DATA_DIR"/chains/shiden
mkdir -p "$DATA_DIR"/chains/shiden
echo "** Downloading and extracting parachain data this might take a while **"
para_data=$(curl -o - -L https://storage.googleapis.com/polkadot_snapshots/shiden.RocksDB.tar | tar -x -C "$DATA_DIR"/chains/shiden)
$para_data &
# Chown After Moving All data
sudo chown -R shiden_service "$DATA_DIR"

# the service
sudo systemctl start shiden.service

sleep 10
STATUS=$(systemctl status shiden)


echo $STATUS

echo "The node is now setup"
