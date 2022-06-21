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
clone the repo and build it. This will generate a ./main binary file in the repository folder:
```
git clone https://github.com/solarlabsteam/missed-blocks-checker
cd missed-blocks-checker
go build
```
For running in the background we have to copy the file to the system apps folder:
```
sudo cp ./missed-blocks-checker /usr/local/bin
```

## Setup service file
Create a systemd service for missed-blocks-checker:
```
sudo tee <<EOF >/dev/null /etc/systemd/system/missed-blocks-checker.service
[Unit]
Description=Missed Blocks Checker
After=network-online.target

[Service]
User=$USER
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=missed-blocks-checker --config <config path>
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
```
Where:
- `<config path>` - the path to the config file we need

Add this service to the autostart and run it and check the logs:
```
sudo systemctl daemon-reload
sudo systemctl enable missed-blocks-checker
sudo systemctl start missed-blocks-checker
sudo systemctl status missed-blocks-checker
journalctl -u missed-blocks-checker -f --output cat
```
## Configure the Alerting by `config.toml`
First, let's set `Your_User_ID` and `Telegram_Bot_Token` variables. You will need this to set up config so that you receive Alerts from the telegram bot, which we will create shortly.
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
#### `Telegram_Bot_Token`
 Go to [@botfather](https://telegram.me/botfather) and generate new token (here is the [instructions](https://core.telegram.org/bots#6-botfather)). Or just do the following:
1. Send `/newbot` to [@BotFather](https://telegram.me/botfather)
2. Choose and send a name for your new bot.
3. Choose and send a username for your new bot. It must end in `bot`.
4. Done. Now you have the **bot** and **token** to access the HTTP API.
```
Telegram_Bot_Token=<Your_Telegram_Bot_Token>
echo $Telegram_Bot_Token
```
#### `bech-prefixes`
Add all Bech prefixes for network where you have the validator.
```
bech-prefix=<your cosmos_project' bech-prefix>
bech-validator-prefix=<bech-validator-prefix>
bech-validator-pubkey-prefix=<bech-validator-pubkey-prefix>
bech-consensus-node-prefix=<bech-consensus-node-prefix>
bech-consensus-node-pubkey-prefix=<bech-consensus-node-pubkey-prefix>

echo $bech-prefix
echo $bech-validator-prefix
echo $bech-validator-pubkey-prefix
echo $bech-consensus-node-prefix
echo $bech-consensus-node-pubkey-prefix
```
There is an Example:
```
bech-prefix=cosmos
bech-validator-prefix=cosmosvaloper
bech-validator-pubkey-prefix=cosmosvaloperpub
bech-consensus-node-prefix=cosmosvalcons
bech-consensus-node-pubkey-prefix=cosmosvalconspub
```
#### Add `include-validators`
Add `include-validators`, if you want to monitor some validators. Or add `exclude-validators` if you want to monitor all validators except a few. 

Fill in only one parameter. Cannot be used together.
 For Example we will use `include-validators` for selecting 3 validators:
```
include-validators=<cosmosvaloper1,cosmosvaloper2,cosmosvaloper3>
echo $include-validators
```
#### Add grpc-address and rpc-address
- gRPC - is needed to get signing info and validators info from
- RPC node - is needed to get block info from.
```
grpc-address=<specify_grpc-address>
rpc-address=<specify_grpc-address>

echo $grpc-address
echo $rpc-address
```














