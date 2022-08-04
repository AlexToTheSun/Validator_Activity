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

1. [Configure opend RPC nodes and Fund keys](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md#configure-opend-rpc-nodes-and-fund-keys)
  - Tgrade RPC node
  - Osmosis RPC node
  - Fund your Tgrade and Osmosis keys
2. [Install and configure Hermes](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md#install-and-configure-hermes)
  - Install Hermes
  - Hermes Configuration
  - Adding private keys
3. [Configure new clients for Tgrade and Osmosis](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md#configure-clients)
  - Create-clients
  - Query client states
  - Update-clients
4. [Connection Handshake](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md#connection-handshake)
  - Conn-init
  - Conn-try
  - Conn-ack
  - Conn-confirm
  - Query connection
5. [Channel Handshake](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md#channel-handshake)
  - Chan-open-init
  - Chan-open-try
  - Chan-open-ack
  - Chan-open-confirm
  - Query channel
6. [Transactions](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md#transactions)

# Configure opend RPC nodes and Fund keys
We will configure Hermes to operate between **Tgrade** and **Osmosis** in mainnet.
1. Run your own Tgrade and Osmosis RPC nodes. You should wait until the synchronization status becomes false. No need to create a validator!
2. Configure RPC nodes for using it by Hermes.
Type the commands on Tgrade server:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.tgrade/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.tgrade/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.tgrade/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.tgrade/config/config.toml
sudo systemctl restart tgrade
```
Type the commands on Osmosis server:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.osmosisd/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.osmosisd/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.osmosisd/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.osmosisd/config/config.toml
sudo systemctl restart osmosisd
```
After that you could check everything is ok.  
In tgrade config.toml and app.toml:
```
nano $HOME/.tgrade/config/config.toml
nano $HOME/.tgrade/config/app.toml
```
In osmosis config.toml and app.toml:
```
nano $HOME/.osmosisd/config/config.toml
nano $HOME/.osmosisd/config/app.toml
```
3. Fund your Tgrade and Osmosis keys.

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
### For Tgrade network:
There we will set the variables that we need to conveniently create a config file for Hermes.

> Note that these will be temporary variables, as we only need them to create the config.toml for Hermes. When you re-enter the server, these variables will no longer exist.
Please insert your values for:
- `<tgrade_node_ip>`
- `<tgrade_rpc_port>`
- `<tgrade_grpc_port>`
```
chain_id_tgrade="tgrade-mainnet-1"
rpc_addr_tgrade="http://<tgrade_node_ip>:<tgrade_rpc_port>"
grpc_addr_tgrade="http://<tgrade_node_ip>:<tgrade_grpc_port>"
websocket_addr_tgrade="ws://<tgrade_node_ip>:<tgrade_rpc_port>/websocket"
account_prefix_tgrade="tgrade"
trusting_period_tgrade="14d"
denom_tgrade="utgd"
gas_price_tgrade="0.05"
```
Example with standard ports:
```
chain_id_tgrade="tgrade-mainnet-1"
rpc_addr_tgrade="http://23.54.11.07:26657"
grpc_addr_tgrade="http://23.54.11.07:9090"
websocket_addr_tgrade="ws://23.54.11.07:26657/websocket"
account_prefix_tgrade="tgrade"
trusting_period_tgrade="14d"
denom_tgrade="utgd"
gas_price_tgrade="0.05"
```

### For Osmosis network:
Now let's set the variables for Osmosis chain.

Please insert your values for:
- `<osmosis_node_ip>`
- `<osmosis_rpc_port>`
- `<osmosis_grpc_port>`
```
chain_id_osmosis="osmosis-1"
rpc_addr_osmosis="http://<osmosis_node_ip>:<osmosis_rpc_port>"
grpc_addr_osmosis="http://<osmosis_node_ip>:<osmosis_grpc_port>"
websocket_addr_osmosis="ws://<osmosis_node_ip>:<osmosis_rpc_port>/websocket"
account_prefix_osmosis="osmo"
trusting_period_osmosis="9days"
denom_osmosis="uosmo"
gas_price_osmosis="0.0001"
```
Example with standard ports:
```
chain_id_osmosis="osmosis-1"
rpc_addr_osmosis="http://32.45.11.70:26657"
grpc_addr_osmosis="http://32.45.11.70:9090"
websocket_addr_osmosis="ws://32.45.11.70:26657/websocket"
account_prefix_osmosis="osmo"
trusting_period_osmosis="9days"
denom_osmosis="uosmo"
gas_price_osmosis="0.0001"
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
### CHAIN_Tgrade_Mainnet ###
id = '${chain_id_tgrade}'
rpc_addr = '${rpc_addr_tgrade}'
grpc_addr = '${grpc_addr_tgrade}'
websocket_addr = '${websocket_addr_tgrade}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_tgrade}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = '${gas_price_tgrade}', denom = '${denom_tgrade}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = '180000'
clock_drift = '15s'
max_block_time = '30s'
trusting_period = '${trusting_period_tgrade}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Tgrade'

[[chains]]
### CHAIN_Osmosis_Mainnet ###
id = '${chain_id_osmosis}'
rpc_addr = '${rpc_addr_osmosis}'
grpc_addr = '${grpc_addr_osmosis}'
websocket_addr = '${websocket_addr_osmosis}'
rpc_timeout = '30s'
account_prefix = '${account_prefix_osmosis}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
max_gas = 15000000
gas_price = { price = '${gas_price_osmosis}', denom = '${denom_osmosis}' }
gas_adjustment = 1
max_msg_num = 10
clock_drift = '15s'
trusting_period = '${trusting_period_osmosis}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Osmosis'
[chains.packet_filter]
policy = 'allow'
list = []
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

In our example you should add **Tgrade** and **Osmosis** keys. The `key_name` parameter from Hermes `config.toml`, is the name of the keys that will be added after restoring Keys.

Please insert your values for:
- MNEMONIC_TGRADE="<YOUR_MNEMONIC_TGRADE>"
- MNEMONIC_OSMOSIS="<YOUR_MNEMONIC_OSMOSIS>"
```
MNEMONIC_TGRADE="speed rival market sure decade call silly flush derive story state menu inflict catalog habit martlet anxiety lumber siege feeling engage kite dad harsh"
sudo tee $HOME/.hermes/${chain_id_tgrade}.mnemonic > /dev/null <<EOF
${MNEMONIC_TGRADE}
EOF
hermes keys add --chain ${chain_id_tgrade} --mnemonic-file $HOME/.hermes/${chain_id_tgrade}.mnemonic
MNEMONIC_OSMOSIS="speed rival market sure decade call silly flush derive story state menu inflict catalog habit martlet anxiety lumber siege feeling engage kite dad harsh"
sudo tee $HOME/.hermes/${chain_id_osmosis}.mnemonic > /dev/null <<EOF
${MNEMONIC_OSMOSIS}
EOF
hermes keys add --chain ${chain_id_osmosis} --mnemonic-file $HOME/.hermes/${chain_id_osmosis}.mnemonic
```

# Configure clients
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/clients.md
- https://hermes.informal.systems/tutorials/local-chains/raw/client.html

The identifiers that will be in the commands below are given as an example. You will have your value.
### create-client

#### Create an Osmosis client on Tgrade network
```
hermes tx raw create-client --host-chain tgrade-mainnet-1 --reference-chain osmosis-1
```
Here we get `07-tendermint-03`. 

Let's write it as `$client_on_Tgrade` variable for further convenient work:
```
client_on_Tgrade="07-tendermint-03"
echo 'export client_on_Tgrade='\"${client_on_Tgrade}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
#### Create a Tgrade client on Osmosis network
```
hermes tx raw create-client --host-chain osmosis-1 --reference-chain tgrade-mainnet-1
```
We get `07-tendermint-121`

Let's write it as `$client_on_Osmosis` variable for further convenient work:
```
client_on_Osmosis="07-tendermint-121"
echo 'export client_on_Osmosis='\"${client_on_Osmosis}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Query client state
an Osmosis client on Tgrade
```
hermes query client state --chain tgrade-mainnet-1 --client $client_on_Tgrade
```
a Tgrade client on Osmosis
```
hermes query client state --chain osmosis-1 --client $client_on_Osmosis
```
### update-client
#### Update the Osmosis client on Tgrade network
```
hermes tx raw update-client --host-chain tgrade-mainnet-1 --client $client_on_Tgrade
```

#### Update the Tgrade client on Osmosis network
```
hermes tx raw update-client --host-chain osmosis-1 --client $client_on_Osmosis
```

# Connection Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/connection.md
- https://hermes.informal.systems/tutorials/local-chains/raw/connection.html
### conn-init
```
hermes tx raw conn-init --dst-chain tgrade-mainnet-1 --src-chain osmosis-1 --dst-client $client_on_Tgrade --src-client $client_on_Osmosis
```
We get `connection-3`

Let's write it as `$connection_Tgrade` variable for further convenient work:
```
connection_Tgrade="connection-3"
echo 'export connection_Tgrade='\"${connection_Tgrade}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### conn-try
```
hermes tx raw conn-try --dst-chain osmosis-1 --src-chain tgrade-mainnet-1 --dst-client $client_on_Osmosis --src-client $client_on_Tgrade --src-conn $connection_Tgrade
```
We get `connection-149`

Let's write it as `$connection_Osmosis` variable for further convenient work:
```
connection_Osmosis="connection-149"
echo 'export connection_Osmosis='\"${connection_Osmosis}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### conn-ack
```
hermes tx raw conn-ack --dst-chain tgrade-mainnet-1 --src-chain osmosis-1 --dst-client $client_on_Tgrade --src-client $client_on_Osmosis --dst-conn $connection_Tgrade --src-conn $connection_Osmosis
```

### conn-confirm
```
hermes tx raw conn-confirm --dst-chain osmosis-1 --src-chain tgrade-mainnet-1 --dst-client $client_on_Osmosis --src-client $client_on_Tgrade --dst-conn $connection_Osmosis --src-conn $connection_Tgrade
```

### Query connection
Now we should have both connection states `Open`
first
```
hermes query connection end --chain tgrade-mainnet-1 --connection $connection_Tgrade
```

second
```
hermes query connection end --chain osmosis-1 --connection $connection_Osmosis
```

# Channel Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/channel.md
- https://hermes.informal.systems/tutorials/local-chains/raw/channel.html
### chan-open-init
```
hermes tx raw chan-open-init --dst-chain tgrade-mainnet-1 --src-chain osmosis-1 --dst-conn $connection_Tgrade --dst-port transfer --src-port transfer --order UNORDERED
```
We get `channel-3`

Let's write it as `$channel_Tgrade` variable for further convenient work:
```
channel_Tgrade="channel-3"
echo 'export channel_Tgrade='\"${channel_Tgrade}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### chan-open-try
```
hermes tx raw chan-open-try --dst-chain osmosis-1 --src-chain tgrade-mainnet-1 --dst-conn $connection_Osmosis --dst-port transfer --src-port transfer --src-chan $channel_Tgrade
```
We get `channel-130`

Let's write it as `$channel_Osmosis` variable for further convenient work:
```
channel_Osmosis="channel-130"
echo 'export channel_Osmosis='\"${channel_Osmosis}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### chan-open-ack
```
hermes tx raw chan-open-ack --dst-chain tgrade-mainnet-1 --src-chain osmosis-1 --dst-conn $connection_Tgrade --dst-port transfer --src-port transfer --dst-chan $channel_Tgrade --src-chan $channel_Osmosis
```

### chan-open-confirm
```
hermes tx raw chan-open-confirm --dst-chain osmosis-1 --src-chain tgrade-mainnet-1 --dst-conn $connection_Osmosis --dst-port transfer --src-port transfer --dst-chan $channel_Osmosis --src-chan $channel_Tgrade
```

### Query channel
We should see that both channels are Open.

First:
```
hermes query channel end --chain tgrade-mainnet-1 --port transfer --channel $channel_Tgrade
```
Second:
```
hermes query channel end --chain osmosis-1 --port transfer --channel $channel_Osmosis
```

# Transactions
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/relay.md
- https://hermes.informal.systems/tutorials/local-chains/raw/packet.html

Now we will send 999 uosmo from Osmosis chain to Osmosis client generated on Tgrade chain.
```
hermes tx raw ft-transfer \
--dst-chain tgrade-mainnet-1 \
--src-chain osmosis-1 \
--src-port transfer \
--src-channel $channel_Osmosis \
--amount 999 \
--timeout-height-offset 1000 \
--number-msgs 1 \
--denom uosmo
```

Here we will send 10000 utgd from Tgrade chain to Osmosis chain (namely to Tgrade client generated on Osmosis chain)
```
hermes tx raw ft-transfer \
--dst-chain  osmosis-1 \
--src-chain tgrade-mainnet-1 \
--src-port transfer \
--src-channel $channel_Tgrade \
--amount 10000 \
--timeout-height-offset 1000 \
--number-msgs 1 \
--denom utgd
```


Thank you.
