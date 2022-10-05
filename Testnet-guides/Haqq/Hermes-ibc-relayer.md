You can find more information here: https://github.com/AlexToTheSun/Cosmos_Quick_Wiki/blob/main/Hermes-relayer.md

We will run a process of the relaying IBC packages between two Cosmos chains: [HAQQ](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/Haqq) and [OllO](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/OLLO).


### So what we need to relaying?
1. Configure opend RPC nodes (or use already configured by other people) of the chains you want to relay between.
2. Fund keys of the chains you want to relay between for paying relayer fees.
3. Configure Hermes.

### 1. Configure opend RPC nodes
On Haqq:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.haqqd/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.haqqd/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.haqqd/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.haqqd/config/config.toml
sudo systemctl restart haqqd
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
Here is instructions for [Haqq](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Wallet-Funding-Validator-Creating.md#fund-your-wallet) and [Ollo](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/OLLO/Wallet-Funding-Validator-Creating.md#fund-the-wallet).

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
#### For HAQQ network:
There we will set the variables that we need to conveniently create a config file for Hermes.

Please insert your values for:
- `<haqq_node_ip>`
- `<haqq_rpc_port>`
- `<haqq_grpc_port>`
```
chain_id_HAQQ="haqq_54211-2"
rpc_addr_HAQQ="http://<haqq_node_ip>:<haqq_rpc_port>"
grpc_addr_HAQQ="http://<haqq_node_ip>:<haqq_grpc_port>"
websocket_addr_HAQQ="ws://<haqq_node_ip>:<haqq_rpc_port>/websocket"
account_prefix_HAQQ="haqq"
trusting_period_HAQQ="7h"
denom_HAQQ="aISLM"
max_tx_size_HAQQ="2097152"
gas_price_HAQQ="0.001"
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
### CHAIN_HAQQ ###
id = '${chain_id_HAQQ}'
rpc_addr = '${rpc_addr_HAQQ}'
grpc_addr = '${grpc_addr_HAQQ}'
websocket_addr = '${websocket_addr_HAQQ}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_HAQQ}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = ${gas_price_HAQQ}, denom = '${denom_HAQQ}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = ${max_tx_size_HAQQ}
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_HAQQ}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} | HAQQ Relayer'
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
![image](https://user-images.githubusercontent.com/30211801/194014868-49702374-a606-4a90-aa4e-1705cfe86cf0.png)


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
In our example you should add **SEI** and **StafiHub** keys. The `key_name` parameter from Hermes `config.toml`, is the name of the key that will be added after restoring Keys.

```
MNEMONIC_HAQQ="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"
MNEMONIC_OllO="speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh"
sudo tee $HOME/.hermes/${chain_id_HAQQ}.mnemonic > /dev/null <<EOF
${MNEMONIC_HAQQ}
EOF
sudo tee $HOME/.hermes/${chain_id_OllO}.mnemonic > /dev/null <<EOF
${MNEMONIC_OllO}
EOF
hermes keys add --chain ${chain_id_HAQQ} --mnemonic-file $HOME/.hermes/${chain_id_HAQQ}.mnemonic
hermes keys add --chain ${chain_id_OllO} --mnemonic-file $HOME/.hermes/${chain_id_OllO}.mnemonic
```





