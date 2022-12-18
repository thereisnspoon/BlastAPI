#!/bin/bash
# Moonbeam Node Setup
# by ImStaked

# Settings
RELEASE_VERSION=v0.28.1
BINARY_URL="https://github.com/PureStake/moonbeam/releases/download/${RELEASE_VERSION}/moonbeam"
DATA_DIR="/var/lib/moonbeam-data"

function setup_system {
     # Update System
     sudo apt-get update && sudo apt-get upgrade -y 
     sudo apt-get autoremove -y && sudo apt-get autoclean -y
     sudo apt-get install git curl wget jq net-tools lz4 zip unzip mlocate unattended-upgrades net-tools whois apt-transport-https ca-certificates libssl-dev gnupg bash-completion needrestart node-ws -y

     adduser moonbeam_service --system --no-create-home
     mkdir -p /var/lib/moonbeam-data
     cd /var/lib/moonbeam-data
     wget $BINARY_URL
     chmod +x /var/lib/moonbeam-data/moonbeam && chown -R moonbeam_service /var/lib/moonbeam-data/
}

function create_service {
     cat > /etc/systemd/system/moonbeam.service <<EOF 
     [Unit]
     Description="Moonbeam Node"
     After=network.target
     StartLimitIntervalSec=0
     [Service]
     Type=simple
     Restart=on-failure
     RestartSec=10
     User=moonbeam_service
     SyslogIdentifier=moonbeam
     SyslogFacility=local7
     KillSignal=SIGHUP
     ExecStart=/var/lib/moonbeam-data/moonbeam \
          --sync=full \
          --blocks-pruning=archive \
          --port 30555 \
          --rpc-port 9955 \
          --ws-port 9966 \
          --execution wasm \
          --wasm-execution compiled \
          --rpc-cors all \
          --unsafe-rpc-external \
          --unsafe-ws-external \
          --prometheus-external \
          --prometheus-port 9102 \
          --base-path /var/lib/moonbeam-data \
          --chain moonbeam \
          --name "<NODE_NAME>" \
          -- \
          --port 33334 \
          --execution wasm \
          --pruning=1000 \
          --prometheus-external \ 
          --prometheus-port 9616 \
          --name="<NODE_NAME>-embedded-relay"

     [Install]
     WantedBy=multi-user.target
     EOF
}
setup_system
create_service

# Enable and Start the service
sudo systemctl daemon-reload
sudo systemctl enable moonbeam.service
sudo systemctl start moonbeam.service
sudo systemctl stop moonbeam.service 

# Polkadot Data Snapshot
rm -rf "$DATA_DIR"/polkadot
mkdir -p "$DATA_DIR"/polkadot/chains/polkadot
echo "** Downloading and extracting chain data this could take a while **"
curl -o - -L https://storage.googleapis.com/polkadot_snapshots/polkadot.RocksDB.tar | lz4 -c -d - | tar -x -C "$DATA_DIR"/polkadot/chains/polkadot

# Moonbeam Data Snapshot
rm -rf "$DATA_DIR"/chains/moonbeam
mkdir -p "$DATA_DIR"/chains/moonbeam
echo "** Downloading and extracting chain data this could take a while **"
curl -o - -L https://storage.googleapis.com/polkadot_snapshots/moonbeam.RocksDB.tar | tar -x -C /data/chains/moonbeam

# Chown After Moving All data
sudo chown -R moonbeam_service "$DATA_DIR"

systemctl start moonbeam
systemctl enable moonbeam

STATUS=$(systemctl status moonbeam)

echo $STATUS 

echo "Script is complete"

echo '*  Check the service status with --->     sudo systemctl status moonbeam.service  *'
echo '*  Check the service logs --->            sudo journalctl -f -u moonbeam.service  *'
