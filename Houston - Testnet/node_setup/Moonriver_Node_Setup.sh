#!/bin/bash
# Moonriver Node Setup
# by ImStaked

# Settings
RELEASE_VERSION=v0.28.1
BINARY_URL="https://github.com/PureStake/moonbeam/releases/download/${RELEASE_VERSION}/moonbeam"
DATA_DIR="/var/lib/moonriver-data"

function setup_system {
     # Update System
     sudo apt-get update && sudo apt-get upgrade -y 
     sudo apt-get autoremove -y && sudo apt-get autoclean -y
     sudo apt-get install git curl wget jq net-tools lz4 zip unzip mlocate unattended-upgrades net-tools whois apt-transport-https ca-certificates libssl-dev gnupg bash-completion needrestart node-ws -y

     adduser moonriver_service --system --no-create-home
     mkdir -p $DATA_DIR && cd $DATA_DIR
     wget $BINARY_URL
     chmod +x /var/lib/moonriver-data/moonbeam && chown -R moonriver_service $DATA_DIR
}

function create_service {
     cat > /etc/systemd/system/moonriver.service <<EOF 
     [Unit]
     Description="Moonriver Node"
     After=network.target
     StartLimitIntervalSec=0
     [Service]
     Type=simple
     Restart=on-failure
     RestartSec=10
     User=moonriver_service
     SyslogIdentifier=moonriver
     SyslogFacility=local7
     KillSignal=SIGHUP
     ExecStart=/var/lib/moonriver-data/moonbeam \
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
          --base-path /var/lib/moonriver-data \
          --chain moonriver \
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
sudo systemctl enable moonriver.service
sudo systemctl start moonriver.service
sudo systemctl stop moonriver.service 
# Polkadot Data Snapshot
rm -rf "$DATA_DIR"/polkadot
mkdir -p "$DATA_DIR"/polkadot/chains/polkadot
echo "** Downloading and extracting chain data this could take a while **"
curl -o - -L https://storage.googleapis.com/polkadot_snapshots/polkadot.RocksDB.tar | lz4 -c -d - | tar -x -C "$DATA_DIR"/polkadot/chains/polkadot
# Moonriver Data Snapshot
rm -rf "$DATA_DIR"/chains/moonriver
mkdir -p "$DATA_DIR"/chains/moonriver
echo "** Downloading and extracting chain data this could take a while **"
# Sorry old snapshot is better than no snapshot probably
curl -o - -L https://snapshots.stakecraft.com/moonriver_2022-04-30.tar | tar -x -C /data/chains/moonriver
# Chown After Moving All data
sudo chown -R moonriver_service "$DATA_DIR"
systemctl start moonriver
systemctl enable moonriver
STATUS=$(systemctl status moonriver)
echo $STATUS 
echo "Script is complete"
echo '*  Check the service status with --->     sudo systemctl status moonriver.service  *'
echo '*  Check the service logs --->            sudo journalctl -f -u moonriver.service  *'
