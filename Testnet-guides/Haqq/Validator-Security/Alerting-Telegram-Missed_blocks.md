This type of alerting does not collect private data, so if the server on which the [missed-blocks-checker](https://github.com/solarlabsteam/missed-blocks-checker) is installed will be hacked, then the attacker will not receive logs from servers with validators.  

⁉️ If machine logs are not collected, then how does alerting get information about validators?
- **gRPC node address to get signing info and validators info from, defaults to `localhost:9090`**. By default, nodes are installed with an open gRPC port, so it will most likely be possible to prescribe the seeds and peers commands or any node from the addrbook, since if the node is intended to work on a public network, then why would its owner disable gRPC.
- **Tendermint RPC node to get block info from. Defaults to `http://localhost:26657`**. In the same way, you can write the seeds and peers of the command or any node from the addrbook project.

🤔 Where is the best place to install this alerting software?  
- **As usual, the best option is a separate server.**
## Overview
In this tutorial, we will install and setup [missed-blocks-checker](https://github.com/solarlabsteam/missed-blocks-checker):
- Prepare the server for missed-blocks-checker
- Installing
- Setup service file
- Configure the Alerting by `config.toml`
- Start Service
- Setup Notifications in Telegram 
## Prepare the server for missed-blocks-checker
Update
```
sudo apt update && sudo apt upgrade -y
sudo apt-get install make git jq curl gcc g++ mc nano -y
```
Install go
```
wget -O go1.18.linux-amd64.tar.gz https://go.dev/dl/go1.18.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz && rm go1.18.linux-amd64.tar.gz
cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
```
Setup [Server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md)
## Installing
clone the repo and build it. This will generate a `./main` binary file in the repository folder:
```
git clone https://github.com/solarlabsteam/missed-blocks-checker
cd missed-blocks-checker
go build
```
For running in the background we have to copy the file to the system apps folder:
```
cp /root/missed-blocks-checker/main /usr/local/bin/missed-blocks-checker
```
Copy config.example.toml and name it so that you can understand it is for HAQQ project:
```
cp /root/missed-blocks-checker/config.example.toml /root/missed-blocks-checker/config.haqq.toml
```
## Setup service file for Haqq missed-blocks-checker
Create a systemd service for missed-blocks-checker:
```
sudo tee <<EOF >/dev/null /etc/systemd/system/missed-blocks-checker.service
[Unit]
Description=HAQQ Missed Blocks Checker
After=network-online.target

[Service]
User=$USER
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=missed-blocks-checker --config /root/missed-blocks-checker/config.haqq.toml
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
```

Add this service to the autorestart, run it and check the logs:
```
sudo systemctl daemon-reload
sudo systemctl enable missed-blocks-checker
sudo systemctl start missed-blocks-checker
sudo systemctl status missed-blocks-checker
journalctl -u missed-blocks-checker -f --output cat
```
## Configure the Alerting by `config.toml`
First, let's set `Telegram_Bot_Token` and `Your_User_ID` variables. You will need this to set up config so that you receive Alerts from the telegram bot, which we will create shortly.

#### `Telegram_Bot_Token`
 Go to [@botfather](https://telegram.me/botfather) and create new bot (will be generated new token). Here is the [instructions](https://core.telegram.org/bots#6-botfather). Or just do the following:
1. Send `/newbot` to [@BotFather](https://telegram.me/botfather)
2. Choose and send a name for your new bot.
3. Choose and send a username for your new bot. It must end in `bot`.
4. Done. Now you have the **bot** and **token** to access the HTTP API.
5. Send message to new bot as it is not allowd to send you message first.
```
Telegram_Bot_Token=<Your_Telegram_Bot_Token>
echo $Telegram_Bot_Token
```
#### `Your_User_ID`
1) To send messages to a user. Go to the @getmyid_bot or [@userinfobot](https://t.me/userinfobot) and find out `<your user ID>`. Then add it as variable.
```
Your_User_ID=<your user ID>
echo $Your_User_ID
```
Or:

2) To send  messages to a channel. Write something to a channel, then forward it to @getmyid_bot and copy the `Forwarded from chat number`. After creatig the bot, add this bot as an channel' admin.
```
Your_User_ID=<your Channel ID>
echo $Your_User_ID
```

#### Haqq `bech-prefixes`
Add all Bech prefixes for Haqq network:
```
bech_prefix=haqq
bech_validator_prefix=haqqvaloper
bech_validator_pubkey_prefix=haqqvaloperpub
bech_consensus_node_prefix=haqqvalcons
bech_consensus_node_pubkey_prefix=haqqvalconspub
echo $bech_prefix
echo $bech_validator_prefix
echo $bech_validator_pubkey_prefix
echo $bech_consensus_node_prefix
echo $bech_consensus_node_pubkey_prefix
```
#### Add `include-validators` and `exclude-validators`
Add `include-validators`, if you want to monitor some validators. Or add `exclude-validators` if you want to monitor all validators except a few. 

Fill in only one parameter. Cannot be used together.
 For Example we will use `include-validators` for selecting 3 validators:
```
include_validators=<haqqvaloper1,haqqvaloper2,haqqvaloper3>
exclude_validators=
echo $include_validators
echo $exclude_validators
```
In case using `include-validators`, we deliberately leave `exclude_validators=` empty, because if it is not empty, then we will have an error.
 #### Add `grpc-address` and `rpc-address`
- gRPC - is needed to get signing info and validators info from
- RPC node - is needed to get block info from.
```
grpc_address=<specify_grpc-address>
rpc_address=<specify_rpc-address>
echo $grpc_address
echo $rpc_address
```
If you set an alert manager on a server with a project node, then you can write `grpc-address=localhost:9090` and `rpc-address=http://localhost:26657`. But I suggest installing missed-blocks-checker on a separate server. And you can connect not to your own nodes, but to any public peer.

The only things you need to know is
- IP address
- RPC port. By default it is `26657`
- If it is a public rpc. It should have this sitting in its config: 
```
[rpc]
# TCP or UNIX socket address for the RPC server to listen on
laddr = "tcp://0.0.0.0:26657"
```
- gRPC port. By default it is `9090`
- If it is a public grpc:
```
[grpc]
# Enable defines if the gRPC server should be enabled.
enable = true
# Address defines the gRPC server address to bind to.
address = "0.0.0.0:9090"
```
#### `Log level`
```
level=info
echo $level
```
Options: `info` | `debug` | `trace`
#### `Chain-info`
**Add `prefix`:**
```
mintscan_prefix=haqq
echo $mintscan_prefix
```

**Add `validator-page-pattern`**
```
validator_page_pattern=https://haqq.explorers.guru/validator/%s
echo $validator_page_pattern
```

#### `config-path`
Path to a file storing all information about people's links to validators.
```
config_path=/home/user/config/missed-blocks-checker-telegram-labels.toml
echo $config_path
```

#### Now let's enter all the data in config.toml of missed-blocks-checker:
```
sed -i -E "s|^(chat[[:space:]]+=[[:space:]]+)-123.*$|\1"$Your_User_ID"| ; \
s|^chat[[:space:]]+=[[:space:]]+\"\#general\"|# chat[[:space:]]+=[[:space:]]+\"\#general\"| ; \
s|^(token[[:space:]]+=[[:space:]]+)\"111:222\".*$|\1\"$Telegram_Bot_Token\"| ; \
s|^token[[:space:]]+=[[:space:]]+\"\#xorb-xxxyyyy\"|# token[[:space:]]+=[[:space:]]+\"\#xorb-xxxyyyy\"| ; \
s|^(bech-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_prefix\"| ; \
s|^(bech-validator-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_validator_prefix\"| ; \
s|^(bech-validator-pubkey-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_validator_pubkey_prefix\"| ; \
s|^(bech-consensus-node-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_consensus_node_prefix\"| ; \
s|^(bech-consensus-node-pubkey-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_consensus_node_pubkey_prefix\"| ; \
s|^(include-validators[[:space:]]+=[[:space:]]+).*$|\1\[\"$include_validators\]\"| ; \
s|^(exclude-validators[[:space:]]+=[[:space:]]+).*$|\# \1$exclude_validators| ; \
s|^(grpc-address[[:space:]]+=[[:space:]]+).*$|\1\"$grpc_address\"| ; \
s|^(rpc-address[[:space:]]+=[[:space:]]+).*$|\1\"$rpc_address\"| ; \
s|^(level[[:space:]]+=[[:space:]]+).*$|\1\"$level\"| ; \
s|^(mintscan-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$mintscan_prefix\"| ; \
s|^(validator-page-pattern[[:space:]]+=[[:space:]]+).*$|\1\"$validator_page_pattern\"| ; \
s|^(config-path[[:space:]]+=[[:space:]]+).*$|\1\"$config_path\"|" /root/missed-blocks-checker/config.haqq.toml
```

After that let's restart service
```
sudo systemctl restart missed-blocks-checker
sudo systemctl status missed-blocks-checker
journalctl -u missed-blocks-checker -f --output cat
```
Done!
