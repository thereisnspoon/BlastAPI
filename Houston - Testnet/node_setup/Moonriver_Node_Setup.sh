#!/bin/bash

# Moonriver Node Setup
# by ImStaked

# Settings
RELEASE_VERSION=v0.27.2


function setup_system {
     apt update && apt upgrade -y
     sudo apt-get install htop net-tools nmon nload iotop zip unzip git curl wget clang jq net-tools lz4 -y
     adduser moonriver_service --system --no-create-home
     mkdir -p /var/lib/moonriver-data
     cd /var/lib/moonriver-data
     wget https://github.com/PureStake/moonbeam/releases/download/v0.27.2/moonbeam
     chmod +x /var/lib/moonriver-data/moonriver && chown -R moonriver_service /var/lib/moonriver-data/
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
     ExecStart=/var/lib/moonriver-data/moonriver \
          --port 33333 \
          --rpc-port 9933 \
          --ws-port 9944 \
          --execution wasm \
          --wasm-execution compiled \
          --state-pruning=1000 \
          --trie-cache-size 0 \
          --db-cache 8000 \
          --unsafe-rpc-external \
          --unsafe-ws-external \
          --prometheus-port 9102 \
          --rpc-cors all \
          --base-path /var/lib/moonriver-data \
          --chain moonriver \
          --name "ImStaked" \
          -- \
          --port 33334 \
          --rpc-port 9934 \
          --ws-port 9945 \
          --prometheus-port 9103 \
          --rpc-cors all \
          --execution wasm \
          --state-pruning=1000 \
          --name="ImStaked (Embedded Relay)"
     [Install]
     WantedBy=multi-user.target
EOF
}

setup_system
create_service


chown -R moonriver_service /var/lib/moonriver-data/


systemctl start moonriver
systemctl enable moonriver
