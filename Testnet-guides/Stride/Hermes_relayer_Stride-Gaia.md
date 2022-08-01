# Relaying overwiew
### What is Hermes?
As we could see, [Hermes](https://hermes.informal.systems/relayer.html) is a an open-source Rust implementation of a relayer for the Inter-Blockchain Communication protocol (IBC).

Hermes is a relayer CLI (i.e., a binary). It is not the same as the relayer core library (that is the crate called [ibc-relayer](https://crates.io/crates/ibc-relayer)).

An IBC relayer is an off-chain process responsible for relaying IBC datagrams between any two Cosmos chains.

There is a [YouTube instruction](https://www.youtube.com/watch?v=_xQDTj1PcEw) in which [Andy Nogueira](https://github.com/andynog) explains all the intricacies of Hermes work.

### How does an IBC relayer work?
1. scanning chain states
2. building transactions based on these states
3. submitting the transactions to the chains involved in the network.

### So what we need to relaying?
1. Configure opend RPC nodes (or use already configured by other people) of the chains you want to relay between.
2. Fund keys of the chains you want to relay between for paying relayer fees.
3. Configure Hermes.

# Table of contents

1. [Configure opend RPC nodes and Fund keys](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Stride/Hermes_relayer_Stride-Gaia.md#configure-opend-rpc-nodes-and-fund-keys)
  - Stirde RPC node
  - Gaia RPC node
  - Fund your Stride and Gaya keys
2. [Install and configure Hermes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Stride/Hermes_relayer_Stride-Gaia.md#install-and-configure-hermes)
  - Install Hermes
  - Hermes Configuration
  - Adding private keys
3. [Configure new clients for Stride and Gaia](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Stride/Hermes_relayer_Stride-Gaia.md#configure-clients)
  - Create-clients
  - Query client states
  - Update-clients
4. [Connection Handshake](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Stride/Hermes_relayer_Stride-Gaia.md#connection-handshake)
  - Conn-init
  - Conn-try
  - Conn-ack
  - Conn-confirm
  - Query connection
5. [Channel Handshake](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Stride/Hermes_relayer_Stride-Gaia.md#channel-handshake)
  - Chan-open-init
  - Chan-open-try
  - Chan-open-ack
  - Chan-open-confirm
  - Query channel
6. [Transactions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Stride/Hermes_relayer_Stride-Gaia.md#transactions)

# Configure opend RPC nodes and Fund keys
We will configure Hermes to operate between **Stride** and **Gaia** in testnets.
1. Run your own Stride and Cosmos Hub RPC nodes. You should wait until the synchronization status becomes false. No need to create a validator!
2. Configure RPC nodes for using it by Hermes.
Type the commands on Stride server:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.stride/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.stride/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stride/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.stride/config/config.toml
sudo systemctl restart strided
```
Type the commands on Gaia server:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.gaia/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.gaia/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.gaia/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.gaia/config/config.toml
sudo systemctl restart gaiad
```
After that you could check everything is ok.  
In stride config.toml and app.toml:
```
nano $HOME/.stride/config/config.toml
nano $HOME/.stride/config/app.toml
```
In gaia config.toml and app.toml:
```
nano $HOME/.gaia/config/config.toml
nano $HOME/.gaia/config/app.toml
```
3. Fund your Stride and Gaya keys.
You could use `#💧┃token-faucet` from [Stride discord](https://discord.gg/9wwHHnt3cV).

# Install and configure Hermes
This step could be done on the separate server, or on the server where you've already installed one/two of the chains.
## Install Hermes by downloading
Official instruction is [here](https://hermes.informal.systems/installation.html)
```
sudo apt install unzip -y
mkdir $HOME/.hermes
wget https://github.com/informalsystems/ibc-rs/releases/download/v1.0.0-rc.1/hermes-v1.0.0-rc.1-x86_64-unknown-linux-gnu.tar.gz
mkdir -p $HOME/.hermes/bin
tar -C $HOME/.hermes/bin/ -vxzf hermes-v1.0.0-rc.1-x86_64-unknown-linux-gnu.tar.gz
echo 'export PATH="$HOME/.hermes/bin:$PATH"' >> $HOME/.bash_profile
source $HOME/.bash_profile
```
Find out version:
```
hermes -v
# hermes 1.0.0-rc.0+b80bcea
```

## Hermes Configuration
First of all let's set the variables that will be needed to create the Hermes config file.  
For each chains we need the parameters below:
- `chain_id` - current chain ID for the network 
- `rpc_addr` - the RPC `address` and `port` where the chain RPC server listens on.
- `grpc_addr` - the GRPC `address` and `port` where the chain GRPC server listens on.
- `websocket_addr` - the WebSocket address and port where the chain WebSocket server
- `account_prefix` - the prefix used by the chain.
- `trusting_period` - `trusting_period=2/3*(unbonding period)`. It is the amount of time to be used as the light client trusting period.
- `denom`
- `max_tx_size` - the maximum size, in bytes, of each transaction that Hermes will submit.

Example Configuration File fo Hermes https://hermes.informal.systems/example-config.html
About config. TLS connection https://hermes.informal.systems/config.html#connecting-via-tls
### For Stride network:
There we will set the variables that we need to conveniently create a config file for Hermes.

> Note that these will be temporary variables, as we only need them to create the config.toml for Hermes. When you re-enter the server, these variables will no longer exist.

Please insert your values for:
- `<stride_node_ip>`
- `<stride_rpc_port>`
- `<stride_grpc_port>`
```
chain_id_stride="STRIDE-TESTNET-2"
rpc_addr_stride="http://<stride_node_ip>:<stride_rpc_port>"
grpc_addr_stride="http://<stride_node_ip>:<stride_grpc_port>"
websocket_addr_stride="ws://<stride_node_ip>:<stride_rpc_port>/websocket"
account_prefix_stride="stride"
trusting_period_stride="8h"
denom_stride="ustrd"
max_tx_size_stride="2097152"
gas_price_stride="0.0025"
```
Example with standard ports:
```
chain_id_stride="STRIDE-TESTNET-2"
rpc_addr_stride="http://23.54.11.07:26657"
grpc_addr_stride="http://23.54.11.07:9090"
websocket_addr_stride="ws://23.54.11.07:26657/websocket"
account_prefix_stride="stride"
trusting_period_stride="8h"
denom_stride="ustrd"
max_tx_size_stride="2097152"
gas_price_stride="0.0025"
```

### For Gaia network:
Now let's set the variables for Gaia chain.

Please insert your values for:
- `<gaia_node_ip>`
- `<gaia_rpc_port>`
- `<gaia_grpc_port>`
```
chain_id_gaia="GAIA"
rpc_addr_gaia="http://<gaia_node_ip>:<gaia_rpc_port>"
grpc_addr_gaia="http://<gaia_node_ip>:<gaia_grpc_port>"
websocket_addr_gaia="ws://<gaia_node_ip>:<gaia_rpc_port>/websocket"
account_prefix_gaia="cosmos"
trusting_period_gaia="8hours"
denom_gaia="uatom"
max_tx_size_gaia="2097152"
gas_price_gaia="0.0025"
```
Example with standard ports:
```
chain_id_gaia="GAIA"
rpc_addr_gaia="http://32.45.11.70:26657"
grpc_addr_gaia="http://32.45.11.70:9090"
websocket_addr_gaia="ws://32.45.11.70:26657/websocket"
account_prefix_gaia="cosmos"
trusting_period_gaia="8hours"
denom_gaia="uatom"
max_tx_size_gaia="2097152"
gas_price_gaia="0.0025"
```
### Specify relayer name
Please insert your values for:
- `<your_relayer_name>`
```
relayer_name="<your_relayer_name>"
```
### Let's create a `config.toml` with two chains
- Example of config - https://hermes.informal.systems/example-config.html
- Abling to handle channel handshake and packet events - https://hermes.informal.systems/commands/relaying/handshakes.html

Let's create our own config. We will configure our Hermes to be able handles [channel and packet messages](https://hermes.informal.systems/commands/relaying/handshakes.html)

Just run the command:
```
sudo tee $HOME/.hermes/config.toml > /dev/null <<EOF
[global]
log_level = 'info'

[mode]

[mode.clients]
enabled = true
refresh = true
misbehaviour = true

[mode.connections]
enabled = false

[mode.channels]
enabled = false

[mode.packets]
enabled = true
clear_interval = 100
clear_on_start = true
tx_confirmation = true

[rest]
enabled = true
host = '127.0.0.1'
port = 3000

[telemetry]
enabled = true
host = '127.0.0.1'
port = 3001

[[chains]]
### CHAIN_STRIDE ###
id = '${chain_id_stride}'
rpc_addr = '${rpc_addr_stride}'
grpc_addr = '${grpc_addr_stride}'
websocket_addr = '${websocket_addr_stride}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_stride}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 2500000
gas_price = { price = '${gas_price_stride}', denom = '${denom_stride}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = '${max_tx_size_stride}'
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_stride}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Stride'

[[chains]]
### CHAIN_GAIA ###
id = '${chain_id_gaia}'
rpc_addr = '${rpc_addr_gaia}'
grpc_addr = '${grpc_addr_gaia}'
websocket_addr = '${websocket_addr_gaia}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_gaia}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 2500000
gas_price = { price = '${gas_price_gaia}', denom = '${denom_gaia}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = '${max_tx_size_gaia}'
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_gaia}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Gaia'
EOF
```
### Performs a health check of all chains in the the config
After you create a config, checking is required:
```
hermes health-check
```
At this stage, problems may arise, and it is very important for us to solve them. After that, let's move on to the next steps.

### Create service file for Hermes
```
sudo tee /etc/systemd/system/hermesd.service > /dev/null <<EOF
[Unit]
Description=hermes
After=network-online.target
[Service]
User=$USER
ExecStart=$(which hermes) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
Start hermes and see logs
```
sudo systemctl daemon-reload
sudo systemctl enable hermesd
sudo systemctl restart hermesd
journalctl -u hermesd -f -o cat
```

## Adding private keys
- Official instruction of Adding private keys - https://hermes.informal.systems/commands/keys/index.html
- Transactions - https://hermes.informal.systems/commands/tx/index.html

You need to add a private key for each chain. After that Hermes will be enabled to submit [transactions](https://hermes.informal.systems/commands/tx/index.html).

In our example you should add **Stride** and **Gaia** keys. The `key_name` parameter from Hermes `config.toml`, is the name of the keys that will be added after restoring Keys.

Please insert your values for:
- MNEMONIC_STRIDE="<YOUR_MNEMONIC_STRIDE>"
- MNEMONIC_GAIA="<YOUR_MNEMONIC_GAIA>"
```
MNEMONIC_STRIDE="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"
sudo tee $HOME/.hermes/${chain_id_stride}.mnemonic > /dev/null <<EOF
${MNEMONIC_STRIDE}
EOF
hermes keys add --chain ${chain_id_stride} --mnemonic-file $HOME/.hermes/${chain_id_stride}.mnemonic

MNEMONIC_GAIA="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"
sudo tee $HOME/.hermes/${chain_id_gaia}.mnemonic > /dev/null <<EOF
${MNEMONIC_GAIA}
EOF
hermes keys add --chain ${chain_id_gaia} --mnemonic-file $HOME/.hermes/${chain_id_gaia}.mnemonic
```

# Configure clients
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/clients.md
- https://hermes.informal.systems/tutorials/local-chains/raw/client.html

The identifiers that will be in the commands below are given as an example. You will have your value.
### create-client

#### Create a Gaia client on Stride network
```
hermes tx raw create-client --host-chain STRIDE-TESTNET-2 --reference-chain GAIA
```
Here we get `07-tendermint-626`. 

Let's write it as `$client_on_Stride` variable for further convenient work:
```
client_on_Stride="07-tendermint-626"
echo 'export client_on_Stride='\"${client_on_Stride}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
#### Create a Stride client on Gaia network
```
hermes tx raw create-client --host-chain GAIA --reference-chain STRIDE-TESTNET-2
```
We get `07-tendermint-49`

Let's write it as `$client_on_Gaia` variable for further convenient work:
```
client_on_Gaia="07-tendermint-49"
echo 'export client_on_Gaia='\"${client_on_Gaia}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Query client state
a Gaia client on Stride
```
hermes query client state --chain STRIDE-TESTNET-2 --client $client_on_Stride
```
a Stride client on Gaia
```
hermes query client state --chain GAIA --client $client_on_Gaia
```
### update-client
#### Update the Gaia client on Stride network
```
hermes tx raw update-client --host-chain STRIDE-TESTNET-2 --client $client_on_Stride
```

#### Update the Stride client on Gaia network
```
hermes tx raw update-client --host-chain GAIA --client $client_on_Gaia
```

# Connection Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/connection.md
- https://hermes.informal.systems/tutorials/local-chains/raw/connection.html
### conn-init
```
hermes tx raw conn-init --dst-chain STRIDE-TESTNET-2 --src-chain GAIA --dst-client $client_on_Stride --src-client $client_on_Gaia
```
We get `connection-299`

Let's write it as `$connection_Stride` variable for further convenient work:
```
connection_Stride="connection-299"
echo 'export connection_Stride='\"${connection_Stride}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### conn-try
```
hermes tx raw conn-try --dst-chain GAIA --src-chain STRIDE-TESTNET-2 --dst-client $client_on_Gaia --src-client $client_on_Stride --src-conn $connection_Stride
```
We get `connection-35`

Let's write it as `$connection_Gaia` variable for further convenient work:
```
connection_Gaia="connection-35"
echo 'export connection_Gaia='\"${connection_Gaia}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### conn-ack
```
hermes tx raw conn-ack --dst-chain STRIDE-TESTNET-2 --src-chain GAIA --dst-client $client_on_Stride --src-client $client_on_Gaia --dst-conn $connection_Stride --src-conn $connection_Gaia
```

### conn-confirm
```
hermes tx raw conn-confirm --dst-chain GAIA --src-chain STRIDE-TESTNET-2 --dst-client $client_on_Gaia --src-client $client_on_Stride --dst-conn $connection_Gaia --src-conn $connection_Stride
```

### Query connection
Now we should have both connection states `Open`
first
```
hermes query connection end --chain STRIDE-TESTNET-2 --connection $connection_Stride
```

second
```
hermes query connection end --chain GAIA --connection $connection_Gaia
```

# Channel Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/channel.md
- https://hermes.informal.systems/tutorials/local-chains/raw/channel.html
### chan-open-init
```
hermes tx raw chan-open-init --dst-chain STRIDE-TESTNET-2 --src-chain GAIA --dst-conn $connection_Stride --dst-port transfer --src-port transfer --order UNORDERED
```
We get `channel-276`

Let's write it as `$channel_Stride` variable for further convenient work:
```
channel_Stride="channel-276"
echo 'export channel_Stride='\"${channel_Stride}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### chan-open-try
```
hermes tx raw chan-open-try --dst-chain GAIA --src-chain STRIDE-TESTNET-2 --dst-conn $connection_Gaia --dst-port transfer --src-port transfer --src-chan $channel_Stride
```
We get `channel-30`

Let's write it as `$channel_Gaia` variable for further convenient work:
```
channel_Gaia="channel-30"
echo 'export channel_Gaia='\"${channel_Gaia}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### chan-open-ack
```
hermes tx raw chan-open-ack --dst-chain STRIDE-TESTNET-2 --src-chain GAIA --dst-conn $connection_Stride --dst-port transfer --src-port transfer --dst-chan $channel_Stride --src-chan $channel_Gaia
```

### chan-open-confirm
```
hermes tx raw chan-open-confirm --dst-chain GAIA --src-chain STRIDE-TESTNET-2 --dst-conn $connection_Gaia --dst-port transfer --src-port transfer --dst-chan $channel_Gaia --src-chan $channel_Stride
```

### Query channel
We should see that both channels are Open.

First:
```
hermes query channel end --chain STRIDE-TESTNET-2 --port transfer --channel $channel_Stride
```
Second:
```
hermes query channel end --chain GAIA --port transfer --channel $channel_Gaia
```

# Transactions
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/relay.md
- https://hermes.informal.systems/tutorials/local-chains/raw/packet.html

Now we will send 999 uatom from Gaia chain to Gaia client generated on Stride chain.
```
hermes tx raw ft-transfer \
--dst-chain  STRIDE-TESTNET-2 \
--src-chain GAIA \
--src-port transfer \
--src-channel $channel_Gaia \
--amount 999 \
--timeout-height-offset 1000 \
--number-msgs 1 \
--denom uatom
```

Here we will send 10000 ustrd from Stride chain to Gaia chain (namely to Stride client generated on Gaia chain)
```
hermes tx raw ft-transfer \
--dst-chain  GAIA \
--src-chain STRIDE-TESTNET-2 \
--src-port transfer \
--src-channel $channel_Stride \
--amount 10000 \
--timeout-height-offset 1000 \
--number-msgs 1 \
--denom ustrd
```


Thank you.

