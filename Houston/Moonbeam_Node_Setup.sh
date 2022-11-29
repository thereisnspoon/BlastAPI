#!/bin/bash

# Moonbeam Node Setup
# by ImStaked

# Settings
RELEASE_VERSION=v0.27.2


function setup_system {
     apt update && apt upgrade -y
     sudo apt-get install htop net-tools nmon nload iotop zip unzip git curl wget cmake build-essential clang jq net-tools lz4 -y
     adduser moonbeam_service --system --no-create-home
     mkdir -p /var/lib/moonbeam-data
     cd /var/lib/moonbeam-data
     wget https://github.com/PureStake/moonbeam/releases/download/v0.27.2/moonbeam
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
          --base-path /var/lib/moonbeam-data \
          --chain moonbeam \
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


systemctl start moonbeam
systemctl enable moonbeam
