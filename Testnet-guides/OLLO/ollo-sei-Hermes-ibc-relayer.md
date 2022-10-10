You can find more information here: https://github.com/AlexToTheSun/Cosmos_Quick_Wiki/blob/main/Hermes-relayer.md

We will run a process of the relaying IBC packages between two Cosmos chains: [SEI](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/SEI-testnet-devnet) and [OllO](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/OLLO).


### So what we need to relaying?
1. Configure opend RPC nodes (or use already configured by other people) of the chains you want to relay between.
2. Fund keys of the chains you want to relay between for paying relayer fees.
3. Configure Hermes.

### 1. Configure opend RPC nodes
On Sei:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.sei/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.sei/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.sei/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.sei/config/config.toml
sudo systemctl restart seid
```
On OllO:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.ollo/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.ollo/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.ollo/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.ollo/config/config.toml
sudo systemctl restart ollod
```
### Fund keys that you will use for Hermes
Here is instructions for [Ollo](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/OLLO/Wallet-Funding-Validator-Creating.md#fund-the-wallet). For sei wallet you could ask some tokens in [Sei' discord](https://discord.gg/3CpKHhyJZW).

## 3. Configure Hermes
This step could be done on the separate server, or on the server that you already installed one of the chains.
### Install Hermes
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
For each chains we need the parameters below:
#### For SEI network:
There we will set the variables that we need to conveniently create a config file for Hermes.

Please insert your values for:
- `<sei_node_ip>`
- `<sei_rpc_port>`
- `<sei_grpc_port>`
```
chain_id_SEI="atlantic-1"
rpc_addr_SEI="http://<sei_node_ip>:<sei_rpc_port>"
grpc_addr_SEI="http://<sei_node_ip>:<sei_rpc_port>/websocket"
account_prefix_SEI="sei"
trusting_period_SEI="2days"
denom_SEI="usei"
max_tx_size_SEI="2097152"
gas_price_SEI="0.001"
```
#### For OllO network:
There we will set the variables that we need to conveniently create a config file for Hermes.

Please insert your values for:
- `<ollo_node_ip>`
- `<ollo_rpc_port>`
- `<ollo_grpc_port>`
```
chain_id_OllO="ollo-testnet-0"
rpc_addr_OllO="http://<ollo_node_ip>:<ollo_rpc_port>"
grpc_addr_OllO="http://<ollo_node_ip>:<ollo_grpc_port>"
websocket_addr_OllO="ws://<ollo_node_ip>:<ollo_rpc_port>/websocket"
account_prefix_OllO="ollo"
trusting_period_OllO="7h"
denom_OllO="utollo"
max_tx_size_OllO="2097152"
gas_price_OllO="0.001"
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
gas_price = { price = ${gas_price_SEI}, denom = '${denom_SEI}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = ${max_tx_size_SEI}
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_SEI}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} | SEI Relayer'
[[chains]]
### CHAIN_OllO ###
id = '${chain_id_OllO}'
rpc_addr = '${rpc_addr_OllO}'
grpc_addr = '${grpc_addr_OllO}'
websocket_addr = '${websocket_addr_OllO}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_OllO}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = ${gas_price_OllO}, denom = '${denom_OllO}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = ${max_tx_size_OllO}
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_OllO}'
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
![Снимок экрана от 2022-10-11 01-27-47](https://user-images.githubusercontent.com/30211801/194955072-75ac14c2-a0c2-42d3-8fa4-7461c1f71b88.png)


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
In our example you should add **SEI** and **OllO** keys. The `key_name` parameter from Hermes `config.toml`, is the name of the key that will be added after restoring Keys.

```
MNEMONIC_SEI="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"
MNEMONIC_OllO="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"
sudo tee $HOME/.hermes/${chain_id_SEI}.mnemonic > /dev/null <<EOF
${MNEMONIC_SEI}
EOF
sudo tee $HOME/.hermes/${chain_id_OllO}.mnemonic > /dev/null <<EOF
${MNEMONIC_OllO}
EOF
hermes keys add --chain ${chain_id_SEI} --mnemonic-file $HOME/.hermes/${chain_id_SEI}.mnemonic
hermes keys add --chain ${chain_id_OllO} --mnemonic-file $HOME/.hermes/${chain_id_OllO}.mnemonic
```

#### Create a ollo client on sei
```
hermes create client --host-chain atlantic-1 --reference-chain ollo-testnet-0
```
Here we get `07-tendermint-728`

![Снимок экрана от 2022-10-11 01-29-03](https://user-images.githubusercontent.com/30211801/194955189-872b250e-92e2-453e-84b8-a75593d98d53.png)

#### Create a sei client on ollo
```
hermes create client --host-chain ollo-testnet-0 --reference-chain atlantic-1
```
![Снимок экрана от 2022-10-11 01-32-11](https://user-images.githubusercontent.com/30211801/194955656-372b40d8-ea0a-4c96-83e7-145274cc2d14.png)

We get `07-tendermint-2`

### Query client state
a ollo client on sei
```
hermes query client state --chain atlantic-1 --client 07-tendermint-728
```
a sei client on ollo
```
hermes query client state --chain ollo-testnet-0 --client 07-tendermint-2
```
### update-client
#### Update the ollo client on sei
```
hermes update client --host-chain atlantic-1 --client 07-tendermint-728
```

#### Update the sei client on ollo
```
hermes update client --host-chain ollo-testnet-0 --client 07-tendermint-2
```

# Connection Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/connection.md
- https://hermes.informal.systems/tutorials/local-chains/raw/connection.html
### conn-init
```
hermes tx conn-init --dst-chain atlantic-1 --src-chain ollo-testnet-0 --dst-client 07-tendermint-728 --src-client 07-tendermint-2
```
![Снимок экрана от 2022-10-11 01-43-03](https://user-images.githubusercontent.com/30211801/194956864-f4d015b2-1d37-4ad2-80bb-701747137c9d.png)


We get `connection-379`
### conn-try
```
hermes tx conn-try --dst-chain ollo-testnet-0 --src-chain atlantic-1 --dst-client 07-tendermint-2 --src-client 07-tendermint-728 --src-conn connection-379
```
![Снимок экрана от 2022-07-31 22-53-09](https://user-images.githubusercontent.com/30211801/182041046-d5122ace-3070-4d2a-9180-1cc32df763d7.png)

Here we HAVE AN ERROR:
![Снимок экрана от 2022-10-11 02-20-01](https://user-images.githubusercontent.com/30211801/194960909-5e47888c-3429-4deb-875c-f609d318ca31.png)


We get `connection-35`
### conn-ack
```
hermes tx raw conn-ack --dst-chain atlantic-1 --src-chain ollo-testnet-0 --dst-client 07-tendermint-728 --src-client 07-tendermint-2 --dst-conn connection-379 --src-conn connection-35
```
![Снимок экрана от 2022-07-31 22-55-03](https://user-images.githubusercontent.com/30211801/182041098-7a9d4338-c863-42f1-9acb-33451619d941.png)

### conn-confirm
```
hermes tx raw conn-confirm --dst-chain ollo-testnet-0 --src-chain atlantic-1 --dst-client 07-tendermint-2 --src-client 07-tendermint-728 --dst-conn connection-35 --src-conn connection-379
```
![Снимок экрана от 2022-07-31 22-55-42](https://user-images.githubusercontent.com/30211801/182041126-fb0a2439-52aa-40a7-b5b4-9586432839f9.png)

### Query connection
Now we should have both connection states `Open`
first
```
hermes query connection end --chain atlantic-1 --connection connection-379
```
![Снимок экрана от 2022-07-31 22-58-04](https://user-images.githubusercontent.com/30211801/182041188-ed5ae1a8-89e1-4688-97f0-bb8313eca40f.png)

second
```
hermes query connection end --chain ollo-testnet-0 --connection connection-35
```
![Снимок экрана от 2022-07-31 22-58-27](https://user-images.githubusercontent.com/30211801/182041198-5e20f843-2796-4a07-b703-f6be54b40630.png)


# Channel Handshake
Source:
- https://github.com/informalsystems/hermes-ibc-workshop/blob/main/docs/channel.md
- https://hermes.informal.systems/tutorials/local-chains/raw/channel.html
### chan-open-init
```
hermes tx raw chan-open-init --dst-chain atlantic-1 --src-chain ollo-testnet-0 --dst-conn connection-379 --dst-port transfer --src-port transfer --order UNORDERED
```
![Снимок экрана от 2022-07-31 23-02-57](https://user-images.githubusercontent.com/30211801/182041317-c82a233d-fe2f-4436-815a-25dbf5cdcac4.png)
We get `channel-276`

### chan-open-try
```
hermes tx raw chan-open-try --dst-chain ollo-testnet-0 --src-chain atlantic-1 --dst-conn connection-35 --dst-port transfer --src-port transfer --src-chan channel-276
```
![Снимок экрана от 2022-07-31 23-04-10](https://user-images.githubusercontent.com/30211801/182041343-772b635f-1c89-47f9-81b5-39471953b75e.png)
We get `channel-30`
### chan-open-ack
```
hermes tx raw chan-open-ack --dst-chain atlantic-1 --src-chain ollo-testnet-0 --dst-conn connection-379 --dst-port transfer --src-port transfer --dst-chan channel-276 --src-chan channel-30
```
![Снимок экрана от 2022-07-31 23-06-51](https://user-images.githubusercontent.com/30211801/182041433-f7b21d7b-1e4d-44c0-acfd-8b28c62045fd.png)

### chan-open-confirm
```
hermes tx raw chan-open-confirm --dst-chain ollo-testnet-0 --src-chain atlantic-1 --dst-conn connection-35 --dst-port transfer --src-port transfer --dst-chan channel-30 --src-chan channel-276
```
![Снимок экрана от 2022-07-31 23-05-13](https://user-images.githubusercontent.com/30211801/182041381-e775fe3d-1060-4e90-9ddd-96175e9b9d8a.png)

### Query channel
```
hermes query channel end --chain atlantic-1 --port transfer --channel channel-276
```
![Снимок экрана от 2022-07-31 23-07-23](https://user-images.githubusercontent.com/30211801/182041449-b67b00de-b787-4f47-846a-fe3ac325cf2b.png)
```
hermes query channel end --chain ollo-testnet-0 --port transfer --channel channel-30
```
![Снимок экрана от 2022-07-31 23-07-56](https://user-images.githubusercontent.com/30211801/182041470-81cada2f-346a-4e3f-97d8-aeb8b9f1bdea.png)



