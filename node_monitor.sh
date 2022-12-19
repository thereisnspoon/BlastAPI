#!/bin/bash

# Blockchain Node Monitor
# by ImStaked

# Osmosis Health Check
OSMO_NODE_URL='http://IP:PORT/status'
osmosis_catchup_status=$(curl -s $OSMO_NODE_URL | jq .result.sync_info.catching_up)
if [ "$osmosis_catchup_status" != false ]
then
echo "Do Something"
else
echo "Osmosis Is Healthy"
fi

# Gnosis Health Check
GNOSIS_NODE_URL='http://IP:PORT/status'
gnosis_catchup_status=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "eth_syncing","params": []}' $GNOSIS_NODE_URL | jq .result )  
if [ "$gnosis_catchup_status" != false ]
then
echo $gnosis_catchup_status
else
echo "Gnosis Is Health"
fi

# Eth Health Check
ETHEREUM_NODE_URL='http://IP:PORT'
ethereum_catchup_status=$(curl -s -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "eth_syncing","params": []}' $ETHEREUM_NODE_URL | jq .result )
if [ "$ethereum_catchup_status" != false ]
then
echo $ethereum_catchup_status
else
echo "Ethereum Is Healthy"
fi

# Avalanche Health Check
AVAX_NODE_URL='http://1P:PORT/ext/health'
avax_catchup_status=$(curl -s $AVAX_NODE_URL | jq .healthy )
if [ "$avax_catchup_status" != true ]
then
echo $avax_catchup_status
else
echo "Avalanche Is Healthy"
fi

# Astar Health Check
ASTAR_NODE_URL='http://IP:PORT/health'
astar_catchup_status=$(curl -s $ASTAR_NODE_URL | jq .isSyncing )
if [ "$astar_catchup_status" != false ]
then
echo $astar_catchup_status
else
echo "Astar Is Healthy"
fi

# Shiden Health Check
SHIDEN_NODE_URL='http://IP:PORT/health'
shiden_catchup_status=$(curl -s $SHIDEN_NODE_URL | jq .isSyncing )
if [ "$shiden_catchup_status" != false ]
then
echo "$shiden_catchup_status"
else
echo "Shiden Is Healthy"
fi


# Moonbeam Health Check
MOONBEAM_NODE_URL='http://IP:PORT/health'
moonbeam_catchup_status=$(curl -s $MOONBEAM_NODE_URL | jq .isSyncing )
if [ "$moonbeam_catchup_status" != false ]
then
echo "$moonbeam_catchup_status"
else
echo "Moonbeam Is Healthy"
fi

# Moonriver Health Check
MOONRIVER_NODE_URL='http://IP:PORT/health'
moonriver_catchup_status=$(curl -s $MOONRIVER_NODE_URL | jq .isSyncing )
if [ "$moonriver_catchup_status" != false ]
then
echo "$moonriver_catchup_status"
else
echo "Moonriver Is Healthy"
fi
