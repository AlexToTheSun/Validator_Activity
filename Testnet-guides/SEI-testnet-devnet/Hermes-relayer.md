### Here is the instruction for SEI <--> StaFiHub ibc relayer
## Documetnation
- https://github.com/informalsystems/ibc-rs
- https://hermes.informal.systems/
- [Hermes IBC Workshop](https://github.com/informalsystems/hermes-ibc-workshop)
- [An Overview of The Interblockchain Communication Protocol](https://arxiv.org/pdf/2006.15918.pdf)

## Table of contents
1. [Relaying overwiew](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#relaying-overwiew)
2. [Configure opend RPC nodes and Fund keys](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#configure-opend-rpc-nodes-and-fund-keys)
- 1. [SEI RPC node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#sei-network-configure-opend-rpc-node)
- 2. [StaFiHub RPC node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#stafihub-configure-opend-rpc-node)
3. [Install and configure Hermes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#install-and-configure-hermes)
- 1. [Install Hermes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#install-hermes-by-downloading)
- 2. [Hermes Configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#hermes-configuration)
- 3. [Adding private keys](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#adding-private-keys)
4. [Configure new clients](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#configure-clients)
- 1. [Create-client](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#create-client)
- 2. [Query client state](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#query-client-state)
- 3. [Update-client](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#update-client)
5. [Connection Handshake](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#connection-handshake)
- 1. [Conn-init](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#conn-init)
- 2. [Conn-try](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#conn-try)
- 3. [Conn-ack](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#conn-ack)
- 4. [Conn-confirm](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#conn-confirm)
- 5. [Query connection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#query-connection)
6. [Channel Handshake](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#channel-handshake)
- 1. [chan-open-init](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#chan-open-init)
- 2. [chan-open-try](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#chan-open-try)
- 3. [chan-open-ack](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#chan-open-ack)
- 4. [chan-open-confirm](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#chan-open-confirm)
- 5. [Query channel](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#query-channel)
7. [Transactions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/Hermes-relayer.md#transactions)

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

# Configure opend RPC nodes and Fund keys
We will configure Hermes to operate between **StaFiHub** and **SEI Network** in testnets.
## SEI Network. Configure opend RPC node.
Now (29 july 2022) current testnet chain for SEI Network is:
- `atlantic-1`
1. **Run your own SEI RPC node [[Instructions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/SEI_atlantic-1.md#instructions)]**

You should wait until the synchronization status becomes false. No need to create a validator!

2. **Configure node for using it by Hermes:**
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.sei/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.sei/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.sei/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.sei/config/config.toml
sudo systemctl restart seid
```
#### Check settings
Open in nano`$HOME/.sei/config/config.toml` and make shure that `config.toml` contens lines:
```
#######################################################
###       RPC Server Configuration Options          ###
#######################################################
[rpc]
...
laddr = "tcp://0.0.0.0:26657"
...
...

#######################################################
###           P2P Configuration Options             ###
#######################################################
[p2p]
...
# Set true to enable the peer-exchange reactor
pex = true
...
...
```
Open in nano`$HOME/.sei/config/app.toml` and make shure that `app.toml` contens the lines:
```
###############################################################################
###                           gRPC Configuration                            ###
###############################################################################

[grpc]

# Enable defines if the gRPC server should be enabled.
enable = true

# Address defines the gRPC server address to bind to.
address = "0.0.0.0:9090"
```
#### Fund your SEI key.
Use SEI testnet faucet for funding your wallet that you will use for Hermes. It will be needed for paying relayer fees.

## StaFiHub. Configure opend RPC node.
Now (29 july 2022) current testnet chain for StaFiHub is:
- `stafihub-public-testnet-3`
1. **Run your own StaFiHub RPC node [[Instructions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#install-stafihub)]**

You should wait until the synchronization status becomes false. No need to create a validator!

2. **Configure node for using it by Hermes:**
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.stafihub/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.stafihub/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stafihub/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.stafihub/config/config.toml
sudo systemctl restart stafihubd
```
#### Check settings
Open in nano`$HOME/.stafihub/config/config.toml` and make shure that `config.toml` contens lines:
```
#######################################################
###       RPC Server Configuration Options          ###
#######################################################
[rpc]
...
laddr = "tcp://0.0.0.0:26657"
...
...

#######################################################
###           P2P Configuration Options             ###
#######################################################
[p2p]
...
# Set true to enable the peer-exchange reactor
pex = true
...
...
```
Open in nano`$HOME/.stafihub/config/app.toml` and make shure that `app.toml` contens the lines:
```
###############################################################################
###                           gRPC Configuration                            ###
###############################################################################

[grpc]

# Enable defines if the gRPC server should be enabled.
enable = true

# Address defines the gRPC server address to bind to.
address = "0.0.0.0:9090"
```
#### Fund your StaFiHub key.
Use SEI testnet faucet for funding your wallet that you will use for Hermes. It will be needed for paying relayer fees.

# Install and configure Hermes
This step could be done on the separate server, or on the server that you already installed one of the chains.
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
Run `hermes` (without any additional parameters) and you should see the usage and help information:
```
hermes 1.0.0-rc.0+b80bcea
Informal Systems <hello@informal.systems>
  Hermes is an IBC Relayer written in Rust

USAGE:
    hermes [OPTIONS] [SUBCOMMAND]

OPTIONS:
        --config <CONFIG>    Path to configuration file
    -h, --help               Print help information
        --json               Enable JSON output
    -V, --version            Print version information

SUBCOMMANDS:
    clear           Clear objects, such as outstanding packets on a channel
    config          Validate Hermes configuration file
    create          Create objects (client, connection, or channel) on chains
    health-check    Performs a health check of all chains in the the config
    help            Print this message or the help of the given subcommand(s)
    keys            Manage keys in the relayer for each chain
    listen          Listen to and display IBC events emitted by a chain
    misbehaviour    Listen to client update IBC events and handles misbehaviour
    query           Query objects from the chain
    start           Start the relayer in multi-chain mode
    tx              Create and send IBC transactions
    update          Update objects (clients) on chains
    upgrade         Upgrade objects (clients) after chain upgrade
    completions     Generate auto-complete scripts for different shells
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
### For SEI network:
There we will set the variables that we need to conveniently create a config file for Hermes.

Please insert your values for:
- `<sei_node_ip>`
- `<sei_rpc_port>`
- `<sei_grpc_port>`
```
chain_id_SEI="atlantic-1"
rpc_addr_SEI="http://<sei_node_ip>:<sei_rpc_port>"
grpc_addr_SEI="http://<sei_node_ip>:<sei_grpc_port>"
websocket_addr_SEI="ws://<sei_node_ip>:<sei_rpc_port>/websocket"
account_prefix_SEI="sei"
trusting_period_SEI="7h"
denom_SEI="usei"
max_tx_size_SEI="2097152"
gas_price_SEI="0.001"
```
Example with standard ports:
```
chain_id_SEI="atlantic-1"
rpc_addr_SEI="http://23.54.11.07:26657"
grpc_addr_SEI="http://23.54.11.07:9090"
websocket_addr_SEI="ws://23.54.11.07:26657/websocket"
account_prefix_SEI="sei"
trusting_period_SEI="7h"
denom_SEI="usei"
max_tx_size_SEI="2097152"
gas_price_SEI="0.001"
```

### For StaFiHub network:
Now let's set the variables for Stafi chain.

Please insert your values for:
- `<stafi_node_ip>`
- `<stafi_rpc_port>`
- `<stafi_grpc_port>`
```
chain_id_Stafihub="stafihub-public-testnet-3"
rpc_addr_Stafihub="http://<stafi_node_ip>:<stafi_rpc_port>"
grpc_addr_Stafihub="http://<stafi_node_ip>:<stafi_grpc_port>"
websocket_addr_Stafihub="ws://<stafi_node_ip>:<stafi_rpc_port>/websocket"
account_prefix_Stafihub="stafi"
trusting_period_Stafihub="16h"
denom_Stafihub="ufis"
max_tx_size_Stafihub="180000"
gas_price_Stafihub="0.01"
```
Example with standard ports:
```
chain_id_Stafihub="stafihub-public-testnet-3"
rpc_addr_Stafihub="http://32.45.11.70:26657"
grpc_addr_Stafihub="http://32.45.11.70:9090"
websocket_addr_Stafihub="ws://32.45.11.70:26657/websocket"
account_prefix_Stafihub="stafi"
trusting_period_Stafihub="16h"
denom_Stafihub="ufis"
max_tx_size_Stafihub="180000"
gas_price_Stafihub="0.01"
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
enabled = true

[mode.channels]
enabled = true

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
### CHAIN_SEI ###
id = '${chain_id_SEI}'
rpc_addr = '${rpc_addr_SEI}'
grpc_addr = '${grpc_addr_SEI}'
websocket_addr = '${websocket_addr_SEI}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_SEI}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = '${gas_price_SEI}', denom = '${denom_SEI}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = '${max_tx_size_SEI}'
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_SEI}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Relayer'

[[chains]]
### CHAIN_StaFiHub ###
id = '${chain_id_Stafihub}'
rpc_addr = '${rpc_addr_Stafihub}'
grpc_addr = '${grpc_addr_Stafihub}'
websocket_addr = '${websocket_addr_Stafihub}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_Stafihub}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = '${gas_price_Stafihub}', denom = '${denom_Stafihub}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = '${max_tx_size_Stafihub}'
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_Stafihub}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Relayer'
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

In our example you should add **SEI** and **StafiHub** keys. The `key_name` parameter from Hermes `config.toml`, is the name of the key that will be added after restoring Keys.

```
MNEMONIC_SEI="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"

MNEMONIC_STAFIHUB="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"

sudo tee $HOME/.hermes/${chain_id_SEI}.mnemonic > /dev/null <<EOF
${MNEMONIC_SEI}
EOF
sudo tee $HOME/.hermes/${chain_id_Stafihub}.mnemonic > /dev/null <<EOF
${MNEMONIC_STAFIHUB}
EOF
hermes keys add --chain ${chain_id_SEI} --mnemonic-file $HOME/.hermes/${chain_id_SEI}.mnemonic
hermes keys add --chain ${chain_id_Stafihub} --mnemonic-file $HOME/.hermes/${chain_id_Stafihub}.mnemonic
```
# Configure clients
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/clients.md
- https://hermes.informal.systems/tutorials/local-chains/raw/client.html

The identifiers that will be in the commands below are given as an example. You will have your value.
### create-client

#### Create a stafihub client on sei
```
hermes tx raw create-client --host-chain atlantic-1 --reference-chain stafihub-public-testnet-3
```
![Снимок экрана от 2022-07-31 22-42-44](https://user-images.githubusercontent.com/30211801/182040736-3fbca524-5a5d-4202-a33a-ac2cb7c28f21.png)
Here we get `07-tendermint-626`
#### Create a sei client on stafihub
```
hermes tx raw create-client --host-chain stafihub-public-testnet-3 --reference-chain atlantic-1
```
![Снимок экрана от 2022-07-31 22-45-20](https://user-images.githubusercontent.com/30211801/182040804-6be04d2b-5939-4844-883b-69fe284de4bc.png)
We get `07-tendermint-49`

### Query client state
a stafihub client on sei
```
hermes query client state --chain atlantic-1 --client 07-tendermint-626
```
a sei client on stafihub
```
hermes query client state --chain stafihub-public-testnet-3 --client 07-tendermint-49
```
### update-client
#### Update the stafihub client on sei
```
hermes tx raw update-client --host-chain atlantic-1 --client 07-tendermint-626
```
![Снимок экрана от 2022-07-31 22-48-47](https://user-images.githubusercontent.com/30211801/182040889-e23667a8-1d85-487e-a5e9-d1af4baf2cb7.png)

#### Update the sei client on stafihub
```
hermes tx raw update-client --host-chain stafihub-public-testnet-3 --client 07-tendermint-49
```
![Снимок экрана от 2022-07-31 22-49-16](https://user-images.githubusercontent.com/30211801/182040908-70d6f7e2-5b33-4687-ad3e-09d074fd5fea.png)

# Connection Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/connection.md
- https://hermes.informal.systems/tutorials/local-chains/raw/connection.html
### conn-init
```
hermes tx raw conn-init --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-client 07-tendermint-626 --src-client 07-tendermint-49
```
![Снимок экрана от 2022-07-31 22-51-35](https://user-images.githubusercontent.com/30211801/182041010-07d1299e-bd62-4b88-94a5-a2bbef80157b.png)

We get `connection-299`
### conn-try
```
hermes tx raw conn-try --dst-chain stafihub-public-testnet-3 --src-chain atlantic-1 --dst-client 07-tendermint-49 --src-client 07-tendermint-626 --src-conn connection-299
```
![Снимок экрана от 2022-07-31 22-53-09](https://user-images.githubusercontent.com/30211801/182041046-d5122ace-3070-4d2a-9180-1cc32df763d7.png)

We get `connection-35`
### conn-ack
```
hermes tx raw conn-ack --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-client 07-tendermint-626 --src-client 07-tendermint-49 --dst-conn connection-299 --src-conn connection-35
```
![Снимок экрана от 2022-07-31 22-55-03](https://user-images.githubusercontent.com/30211801/182041098-7a9d4338-c863-42f1-9acb-33451619d941.png)

### conn-confirm
```
hermes tx raw conn-confirm --dst-chain stafihub-public-testnet-3 --src-chain atlantic-1 --dst-client 07-tendermint-49 --src-client 07-tendermint-626 --dst-conn connection-35 --src-conn connection-299
```
![Снимок экрана от 2022-07-31 22-55-42](https://user-images.githubusercontent.com/30211801/182041126-fb0a2439-52aa-40a7-b5b4-9586432839f9.png)

### Query connection
Now we should have both connection states `Open`
first
```
hermes query connection end --chain atlantic-1 --connection connection-299
```
![Снимок экрана от 2022-07-31 22-58-04](https://user-images.githubusercontent.com/30211801/182041188-ed5ae1a8-89e1-4688-97f0-bb8313eca40f.png)

second
```
hermes query connection end --chain stafihub-public-testnet-3 --connection connection-35
```
![Снимок экрана от 2022-07-31 22-58-27](https://user-images.githubusercontent.com/30211801/182041198-5e20f843-2796-4a07-b703-f6be54b40630.png)


# Channel Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/channel.md
- https://hermes.informal.systems/tutorials/local-chains/raw/channel.html
### chan-open-init
```
hermes tx raw chan-open-init --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-conn connection-299 --dst-port transfer --src-port transfer --order UNORDERED
```
![Снимок экрана от 2022-07-31 23-02-57](https://user-images.githubusercontent.com/30211801/182041317-c82a233d-fe2f-4436-815a-25dbf5cdcac4.png)
We get `channel-276`

### chan-open-try
```
hermes tx raw chan-open-try --dst-chain stafihub-public-testnet-3 --src-chain atlantic-1 --dst-conn connection-35 --dst-port transfer --src-port transfer --src-chan channel-276
```
![Снимок экрана от 2022-07-31 23-04-10](https://user-images.githubusercontent.com/30211801/182041343-772b635f-1c89-47f9-81b5-39471953b75e.png)
We get `channel-30`
### chan-open-ack
```
hermes tx raw chan-open-ack --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-conn connection-299 --dst-port transfer --src-port transfer --dst-chan channel-276 --src-chan channel-30
```
![Снимок экрана от 2022-07-31 23-06-51](https://user-images.githubusercontent.com/30211801/182041433-f7b21d7b-1e4d-44c0-acfd-8b28c62045fd.png)

### chan-open-confirm
```
hermes tx raw chan-open-confirm --dst-chain stafihub-public-testnet-3 --src-chain atlantic-1 --dst-conn connection-35 --dst-port transfer --src-port transfer --dst-chan channel-30 --src-chan channel-276
```
![Снимок экрана от 2022-07-31 23-05-13](https://user-images.githubusercontent.com/30211801/182041381-e775fe3d-1060-4e90-9ddd-96175e9b9d8a.png)

### Query channel
```
hermes query channel end --chain atlantic-1 --port transfer --channel channel-276
```
![Снимок экрана от 2022-07-31 23-07-23](https://user-images.githubusercontent.com/30211801/182041449-b67b00de-b787-4f47-846a-fe3ac325cf2b.png)
```
hermes query channel end --chain stafihub-public-testnet-3 --port transfer --channel channel-30
```
![Снимок экрана от 2022-07-31 23-07-56](https://user-images.githubusercontent.com/30211801/182041470-81cada2f-346a-4e3f-97d8-aeb8b9f1bdea.png)


# Transactions
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/relay.md
- https://hermes.informal.systems/tutorials/local-chains/raw/packet.html

Now we will send 999 ufis from StafiHub chain to StafiHub client generated on SEI chain.
```
hermes tx raw ft-transfer \
--dst-chain  atlantic-1 \
--src-chain stafihub-public-testnet-3 \
--src-port transfer \
--src-channel channel-30 \
--amount 999 \
--timeout-height-offset 1000 \
--number-msgs 1 \
--denom ufis
```
![Снимок экрана от 2022-07-31 23-09-06](https://user-images.githubusercontent.com/30211801/182041511-b6d56522-3f68-4886-9e54-586b29129ac7.png)

Txhash: https://testnet-explorer.stafihub.io/stafi-hub-testnet/tx/B5EE927456B0B2A3E3CD1AE4CE3BA3311FB1B6AA716D04A3A9E98804E61DFB0A

Here we will send 10000 usei from SEI chain to StafiHub chain (namely to SEI client generated on StafiHub chain)
```
hermes tx raw ft-transfer \
--dst-chain  stafihub-public-testnet-3 \
--src-chain atlantic-1 \
--src-port transfer \
--src-channel channel-276 \
--amount 10000 \
--timeout-height-offset 1000 \
--number-msgs 1 \
--denom usei
```
![Снимок экрана от 2022-07-31 23-10-02](https://user-images.githubusercontent.com/30211801/182041527-e7356ac0-7815-42af-b79a-e612293e871e.png)

Txhash: https://sei.explorers.guru/transaction/62D9A43406B98ADB6C5257567E47E0151F526FE9ABA74B22E3828874CB3C0218


# There is my identifiers for SEI <--> StaFiHub
```
sei:
      chain-id: atlantic-1
      client-id: 07-tendermint-626
      connection-id: connection-299
      channel-id: channel-276
      
stafihub:
      chain-id: stafihub-public-testnet-3
      client-id: 07-tendermint-49
      connection-id: connection-35
      channel-id: channel-30
```

Thank you for reading.
