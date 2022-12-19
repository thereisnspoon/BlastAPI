#!/bin/bash

# Node Monitor
# by ImStaked

# Osmosis Health Check
OSMO_NODE_URL='http://10.204.53.103:26657/status'
osmosis_catchup_status=$(curl -s $OSMO_NODE1_URL | jq .result.sync_info.catching_up)
if [ "$osmosis_catchup_status" != false ]  
then
echo "Do Something"
fi

# Gnosis Health Check
GNOSIS_NODE_URL='http://10.204.53.150:8545/status'
gnosis_catchup_status=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "eth_syncing","params": []}' $GNOSIS_NODE_URL | jq .result )  
if [ "$gnosis_catchup_status=" != false ]  
then
echo "Do Something"
fi

# Health Check
ETHEREUM_NODE_URL='http://10.204.53.49:8545'
ethereum_catchup_status=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "eth_syncing","params": []}' $ETHEREUM_NODE_URL | jq .result )
if [ "$ethereum_catchup_status" != false ]  
then
echo "Do Something"
fi
