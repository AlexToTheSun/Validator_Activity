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

#### Find free channels

```
hermes query channels --chain atlantic-1
hermes query channels --chain ollo-testnet-0
```
#### Register channel
```
hermes create channel --a-chain atlantic-1 --b-chain ollo-testnet-0 --a-port transfer --b-port transfer --order unordered --new-client-connection
```
At the end will get logs:
```
2022-10-12T13:06:24.643911Z ERROR ThreadId(67) send_tx_with_account_sequence_retry{id=atlantic-1}:estimate_gas: failed to simulate tx. propagating error to caller: gRPC call failed with status: status: Unknown, message: "account sequence mismatch, expected 273, got 271: incorrect account sequence", details: [], metadata: MetadataMap { headers: {"content-type": "application/grpc", "x-cosmos-block-height": "8434908"} }
2022-10-12T13:06:24.643932Z  WARN ThreadId(67) send_tx_with_account_sequence_retry{id=atlantic-1}: failed at estimate_gas step mismatching account sequence gRPC call failed with status: status: Unknown, message: "account sequence mismatch, expected 273, got 271: incorrect account sequence", details: [], metadata: MetadataMap { headers: {"content-type": "application/grpc", "x-cosmos-block-height": "8434908"} }. refresh account sequence number and retry once
2022-10-12T13:06:24.646893Z  INFO ThreadId(67) send_tx_with_account_sequence_retry{id=atlantic-1}: refresh: retrieved account sequence=273 number=1995
2022-10-12T13:06:25.468528Z  INFO ThreadId(67) wait_for_block_commits: waiting for commit of tx hashes(s) 8AF15B1EFB4D0D2A0735812BEA77FEE37DBD08D0961FA9C04A86678816FABE39 id=atlantic-1
2022-10-12T13:06:28.842484Z  INFO ThreadId(01) 🎊  atlantic-1 => OpenConfirmChannel(
    OpenConfirm {
        height: Height {
            revision: 1,
            height: 8434912,
        },
        port_id: PortId(
            "transfer",
        ),
        channel_id: Some(
            ChannelId(
                "channel-399",
            ),
        ),
        connection_id: ConnectionId(
            "connection-381",
        ),
        counterparty_port_id: PortId(
            "transfer",
        ),
        counterparty_channel_id: Some(
            ChannelId(
                "channel-2",
            ),
        ),
    },
)

2022-10-12T13:06:32.124495Z  INFO ThreadId(01) channel handshake already finished for Channel {
    ordering: Unordered,
    a_side: ChannelSide {
        chain: BaseChainHandle {
            chain_id: ChainId {
                id: "ollo-testnet-0",
                version: 0,
             },
            runtime_sender: Sender { .. },
        },
        client_id: ClientId(
            "07-tendermint-3",
        ),
        connection_id: ConnectionId(
            "connection-4",
        ),
        port_id: PortId(
            "transfer",
        ),
        channel_id: Some(
            ChannelId(
                "channel-2",
            ),
        ),
        version: None,
    },
    b_side: ChannelSide {
        chain: BaseChainHandle {
            chain_id: ChainId {
                id: "atlantic-1",
                version: 1,
            },
            runtime_sender: Sender { .. },
        },
        client_id: ClientId(
            "07-tendermint-729",
        ),
        connection_id: ConnectionId(
            "connection-381",
        ),
        port_id: PortId(
            "transfer",
        ),
        channel_id: Some(
            ChannelId(
                "channel-399",
            ),
        ),
        version: None,
    },
}   connection_delay: 0ns,

SUCCESS Channel {
    ordering: Unordered,
    a_side: ChannelSide {
        chain: BaseChainHandle {
            chain_id: ChainId {
                id: "ollo-testnet-0",
                version: 0,
            },
            runtime_sender: Sender { .. },
        },
        client_id: ClientId(
            "07-tendermint-3",
        ),
        connection_id: ConnectionId(
            "connection-4",
        ),
        port_id: PortId(
            "transfer",
        ),
        channel_id: Some(
            ChannelId(
                "channel-2",
            ),
        ),
        version: None,
    },
    b_side: ChannelSide {
        chain: BaseChainHandle {
            chain_id: ChainId {
                id: "atlantic-1",
                version: 1,
            },
            runtime_sender: Sender { .. },
        },
        client_id: ClientId(
            "07-tendermint-729",
        ),
        connection_id: ConnectionId(
            "connection-381",
        ),
        port_id: PortId(
            "transfer",
        ),
        channel_id: Some(
            ChannelId(
                "channel-399",
            ),
        ),
        version: None,
    },
    connection_delay: 0ns,
}
```
So we could see the information about chanels that have been created for current chains:
```
ollo
      chain-id: ollo-testnet-0
      client-id: 07-tendermint-3
      connection-id: connection-4
      channel-id: channel-2
      
sei
      chain-id: atlantic-1
      client-id: 07-tendermint-729
      connection-id: connection-381
      channel-id: channel-399
```

# Transactions
Here we will send 795000 usei from SEI chain to OllO chain (namely to SEI client generated on OllO chain)
```
seid tx ibc-transfer transfer transfer channel-399 ollo1p4rryfyyfl2rxzg2dugtgkluj8m4umynkw0mud 795000usei --from $WALLET --fees 200usei
```
Now we will send 795000 utollo from OllO chain to SEI client generated on OllO chain.
```
ollod tx ibc-transfer transfer transfer channel-2 sei1qr688u3h9v6xenm7uwn8sp79yh7tgu76q9ur6k 795000utollo --from $WALLET --fees 200utollo
```
