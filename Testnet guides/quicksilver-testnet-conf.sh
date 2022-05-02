#!/bin/bash -i

set -xe

### CONFIGURATION ###

CHAIN_ID=quicktest-2

GENESIS_URL="https://raw.githubusercontent.com/ingenuity-build/testnets/main/rhapsody/genesis.json"
SEEDS="dd3460ec11f78b4a7c4336f22a356fe00805ab64@seed.quicktest-1.quicksilver.zone:26656"

BINARY=./build/quicksilverd
NODE_HOME=$HOME/.quicksilverd

# SET this value for your node:
NODE_MONIKER="Your_Node"

### OPTIONAL STATE ###

# if you set this to true, please have TRUST HEIGHT and TRUST HASH and RPC configured
export STATE_SYNC=false
# set height
export TRUST_HEIGHT=
# set hash
export TRUST_HASH=""
export SYNC_RPC="http://node02.quicktest-1.quicksilver.zone:26657,http://node03.quicktest-1.quicksilver.zone:26657,http://node04.quicktest-1.quicksilver.zone:26657"

echo  "Initializing $CHAIN_ID..."
$BINARY config chain-id $CHAIN_ID --home $NODE_HOME
$BINARY config keyring-backend test --home $NODE_HOME
$BINARY config broadcast-mode block --home $NODE_HOME
$BINARY init $NODE_MONIKER --chain-id $CHAIN_ID --home $NODE_HOME

echo "Get genesis file..."
curl -sSL $GENESIS_URL > $NODE_HOME/config/genesis.json

if  $STATE_SYNC; then
    echo  "Enabling state sync..."
    sed -i -e '/enable =/ s/= .*/= true/'  $NODE_HOME/config/config.toml
    sed -i -e "/trust_height =/ s/= .*/= $TRUST_HEIGHT/"  $NODE_HOME/config/config.toml
    sed -i -e "/trust_hash =/ s/= .*/= \"$TRUST_HASH\"/"  $NODE_HOME/config/config.toml
    sed -i -e "/rpc_servers =/ s/= .*/= \"$SYNC_RPC\"/"  $NODE_HOME/config/config.toml
else
    echo  "Disabling state sync..."
fi

echo "Set seeds..."
sed -i -e "/seeds =/ s/= .*/= \"$SEEDS\"/"  $NODE_HOME/config/config.toml
