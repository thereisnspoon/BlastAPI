#!/bin/bash

# Blockchain Node Monitor
# by ImStaked

# Osmosis Health Check
OSMO_NODE_URL='http://10.204.53.103:26657/status'
osmosis_catchup_status=$(curl -s $OSMO_NODE_URL | jq .result.sync_info.catching_up)
if [ "$osmosis_catchup_status" != false ]
then
echo "Do Something"
else
echo "Osmosis Is Healthy"
fi

# Gnosis Health Check
GNOSIS_NODE_URL='http://10.204.53.150:8545/status'
gnosis_catchup_status=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "eth_syncing","params": []}' $GNOSIS_NODE_URL | jq .result )  
if [ "$gnosis_catchup_status" != false ]
then
echo $gnosis_catchup_status
else
echo "Gnosis Is Health"
fi

# Eth Health Check
ETHEREUM_NODE_URL='http://10.204.53.49:8545'
ethereum_catchup_status=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "eth_syncing","params": []}' $ETHEREUM_NODE_URL | jq .result )
if [ "$ethereum_catchup_status" != false ]
then
echo $ethereum_catchup_status
else
echo "Ethereum Is Healthy"
fi

# Avalanche Health Check
AVAX_NODE_URL='http://10.204.53.246:9650/ext/health'
avax_catchup_status=$(curl -s $AVAX_NODE_URL | jq .healthy )
if [ "$avax_catchup_status" != true ]
then
echo $avax_catchup_status
else
echo "Avalanche Is Healthy"
fi

# Astar Health Check
ASTAR_NODE_URL='http://10.204.53.149:9933/health'
astar_catchup_status=$(curl -s $ASTAR_NODE_URL | jq .isSyncing )
if [ "$astar_catchup_status" != false ]
then
echo $astar_catchup_status
else
echo "Astar Is Healthy"
fi
