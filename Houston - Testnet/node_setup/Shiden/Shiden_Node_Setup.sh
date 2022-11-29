#!/bin/bash
# Shiden Node Setup

# Settings
RELEASE_VERSION=v4.33.0
BINARY_URL="https://github.com/AstarNetwork/Astar/releases/download/${RELEASE_VERSION}/astar-collator-${RELEASE_VERSION}-ubuntu-x86_64.tar.gz"
DATA_DIR="/var/lib/shiden-data"

# Update System
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get autoremove -y && sudo apt-get autoclean -y
sudo apt-get install git curl wget jq net-tools lz4 zip unzip mlocate net-tools whois apt-transport-https ca-certificates libssl-dev bash-completion needrestart -y

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
Description=Shiden Pruned Node

[Service]
Type=simple
Restart=on-failure
RestartSec=10
User=shiden_service
SyslogIdentifier=astar
SyslogFacility=local7
KillSignal=SIGHUP
ExecStart=/var/lib/shiden-data/astar-collator --state-pruning archive --port=33333 --rpc-port=9933 --ws-port=9944 --execution=Wasm --wasm-execution=compiled --trie-cache-size 80530636 --unsafe-rpc-external --unsafe-ws-external --rpc-cors all --name ImStaked --chain shiden --base-path /var/lib/shiden-data --ws-external --prometheus-external --prometheus-port 9615 -- --port=33334 --prometheus-external --prometheus-port 9626 --name="ImStaked-embedded-relay" --ws-max-connections 1000 --runtime-cache-size 3 --no-telemetry --no-mdns
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and Start the service
sudo systemctl daemon-reload
sudo systemctl enable shiden.service
sudo systemctl start shiden.service
sleep 5
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

echo FINISHED!!! > ~/setup/done.txt
echo $STATUS >> ~/setup/done.txt
