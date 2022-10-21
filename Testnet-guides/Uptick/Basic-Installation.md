#### Official links
- Github: https://github.com/UptickNetwork/uptick-testnet/tree/main/uptick_7000-1
- Docs: https://docs.uptick.network
- Faucet: https://docs.uptick.network/testnet/faucet.html
- Explorer: https://explorer.testnet.uptick.network/uptick-network-testnet


## Actual Chain Information
- Chain_id: `uptick_7000-1`
- uptickd version: [v0.2.3](https://github.com/UptickNetwork/uptick/blob/main/release/uptick-v0.2.3.tar.gz)
- Denom: `auptick`
- Denom-coefficient: `1000000000000000000`
- Genesis [File](https://github.com/UptickNetwork/uptick-testnet/blob/main/uptick_7000-1/genesis.json)
- go version: `1.18.3`

 # Uptick Node Install
 Update & upgrade
```
sudo apt update && sudo apt upgrade -y
```
Install the required packages
```
sudo apt-get install nano mc git gcc g++ make curl build-essential tmux chrony wget jq yarn -y
```
Install GO
```
wget -O go1.18.3.linux-amd64.tar.gz https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz && rm go1.18.3.linux-amd64.tar.gz
cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
# go version go1.18.3 linux/amd64
```
### Install the latest version of Uptick
All releases can be viewed [here](https://github.com/UptickNetwork/uptick/blob/main/release)
```
mkdir /root/uptick-bin
cd /root/uptick-bin
wget https://github.com/UptickNetwork/uptick/blob/main/release/uptick-v0.2.3.tar.gz?raw=true
tar -zxvf uptick-v0.2.3.tar.gz?raw=true
chmod +x uptick-v0.2.3/linux/uptickd
/root/uptick-bin/uptickd version --long | head
cp /root/uptick-bin/uptick-v0.2.3/linux/uptickd /usr/local/bin
uptickd version
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
UP_NODENAME=<YOUR_MONIKER>
UP_WALLET=<YOUR_WALLET>
UP_CHAIN=uptick_7000-1
echo 'export UP_NODENAME='\"${UP_NODENAME}\" >> $HOME/.bash_profile
echo 'export UP_WALLET='\"${UP_WALLET}\" >> $HOME/.bash_profile
echo 'export UP_CHAIN='\"${UP_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $UP_NODENAME $UP_WALLET $UP_CHAIN
```
### Init your config files
```
uptickd init $UP_NODENAME --chain-id $UP_CHAIN
```
### Download `genesis.json`
```
curl -s  https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-1/genesis.json > ~/.uptickd/config/genesis.json
```
### Set the custom ports
```
UP_PORT=11
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${UP_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${UP_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${UP_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${UP_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${UP_PORT}660\"%" $HOME/.uptickd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${UP_PORT}317\"%; s%^address = \":8080\"%address = \":${UP_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${UP_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${UP_PORT}091\"%" $HOME/.uptickd/config/app.toml
```
### Config your node by changing `client.toml`, `app.toml` and `client.toml`
#### Config your node by changing `client.toml`
- Specify your rpc port (below there is a default rpc port)
If on your server there are two Cosmos SDK apps then you have to Change ports. After that you should specify your new RPC port in `client.toml`:
```
uptickd config node tcp://localhost:${UP_PORT}657
uptickd config chain-id $UP_CHAIN
```
#### Seeds and peers
```
peers="a9bb3d5c36cf62a280c13f3e37c93a4b17707eab@142.132.196.251:46656,eecdfb17919e59f36e5ae6cec2c98eeeac05c0f2@peer0.testnet.uptick.network:26656,178727600b61c055d9b594995e845ee9af08aa72@peer1.testnet.uptick.network:26656"
seeds="61f9e5839cd2c56610af3edd8c3e769502a3a439@seed0.testnet.uptick.network:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.uptickd/config/config.toml
```
#### Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0auptick\"/" $HOME/.uptickd/config/app.toml
```
#### Download `addrbook.json`
```
wget -qO $HOME/.uptickd/config/addrbook.json "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Uptick/addrbook.json"
```
#### Disk usage optimization
Pruning configuration
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""nothing"\"/" $HOME/.uptickd/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.uptickd/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.uptickd/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""50"\"/" $HOME/.uptickd/config/app.toml
```
If you dont want to use your RPC node for relayer, then you can set `indexer = "null"`
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.uptickd/config/config.toml
sudo rm ~/.uptickd/data/tx_index.db/*
```
### Create service file for Uptick
```
sudo tee <<EOF >/dev/null /etc/systemd/system/uptickd.service
[Unit]
Description=Uptick Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which uptickd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Get snapshot
You will get an error, if you dont use a snapshot and you 
```
panic: runtime error: invalid memory address or nil pointer dereference
```
Also your pruning settings must be:
```
sed -i -e "s/^pruning *=.*/pruning = \"nothing\"/" $HOME/.uptickd/config/app.toml
```
Download a snapshot:
```
wget https://download.uptick.network/download/uptick/testnet/node/data/data.tar.gz --no-check-certificate
tar -C $HOME/.uptickd/data/ -zxvf data.tar.gz --strip-components 1
sudo systemctl restart uptickd && sudo journalctl -u uptickd -f -o cat
```


### Start synchronization from scratch
```
uptickd tendermint unsafe-reset-all --home $HOME/.uptickd
sudo systemctl daemon-reload
sudo systemctl enable uptickd
sudo systemctl restart uptickd
```
Logs and status
```
sudo journalctl -u uptickd -f -o cat
curl localhost:26657/status | jq
uptickd status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.

# Wallet Funding && Validator Creating
### Create your Uptick wallet
```
uptickd keys add $UP_WALLET
```
### Fund your wallet
Go to the `#faucet` in Uptick [Discord](https://discord.gg/tuEmZs35gq)

Faucet command:
```
$faucet <your address>
```
### Upgrade to a Validator
```
uptickd tx staking create-validator \
--chain-id $UP_CHAIN \
--commission-rate=0.07 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.1 \
--min-self-delegation="1" \
--amount=4900000000000000000auptick \
--pubkey $(uptickd tendermint show-validator) \
--moniker $UP_NODENAME \
--identity=""
--details=""
--website=""
--from=$UP_WALLET \
--gas="auto"
```
Find out your validator: https://explorer.testnet.uptick.network/uptick-network-testnet/staking

#### Validator role request
- Type your discord ID instead of `Discord ID`
```
uptickd tx bank send $(uptickd keys show $UP_WALLET -a) uptick1ncn0k65x3esuzxztzymd0s0kwhun7wxnrcc9mw 4900auptick --chain-id=uptick_7000-1 --note="Validator Role Request: Discord ID"
```
Then go to discord and post a link on your tx.

# Useful commands
Logs and status
```
sudo journalctl -u uptickd -f -o cat
curl localhost:26657/status | jq
uptickd status 2>&1 | jq .SyncInfo
```
Find out your wallet:
```
uptickd keys show $UP_WALLET -a
```
Your validator:
```
uptickd keys show $UP_WALLET --bech val -a
```
Information about your validator:
```
uptickd query staking validator $(uptickd keys show $UP_WALLET --bech val -a)
```

List of commands to interact with `uptickd.service`
```
sudo systemctl daemon-reload
sudo systemctl enable uptickd
sudo systemctl restart uptickd
sudo systemctl status uptickd
sudo systemctl stop uptickd
sudo systemctl disable uptickd
```
Unsafe-reset-all
```
uptickd tendermint unsafe-reset-all --home $HOME/.uptickd
```
### Tx
- If you have configured your node by `uptickd config node tcp://localhost:26657` then there is no need in `--node "tcp://127.0.0.1:26657"` flag.
- as we have `minimum-gas-prices = 0.0auptick` so there is no need in `--fees` flag.

Send some tokens:
```
uptickd tx bank send <sender> <receiver> <amount>auptick --chain-id=uptick_7000-1 --note=""
```

How to vote:
- `<prop_ID>` - ID of a proposal. You can find info about Uptick Governance [[here](https://explorer.testnet.uptick.network/uptick-network-testnet/proposals)]
```
uptickd tx gov vote <prop_ID> yes --from $UP_WALLET -y
```

Unjail:
```
uptickd tx slashing unjail \
--chain-id $UP_CHAIN \
--from $UP_WALLET
```

Change the validator parameters:
```
uptickd tx staking edit-validator \
--from=$UP_WALLET \
--chain-id=$UP_CHAIN \
--commission-rate="" \
--commission-max-rate="" \
--commission-max-change-rate="" \
--website="" \
--identity="" \
--details="" \
--moniker=""
```
Send some tockens:
```

```
#### Wallets, delegations and rewards
To see how many tokens are in your wallet:
```
uptickd q bank balances $(uptickd keys show $UP_WALLET -a)
```
Withdraw all delegation rewards:
```
uptickd tx distribution withdraw-all-rewards --from=$UP_WALLET --chain-id=$UP_CHAIN
```
Withdraw validator commission:
```
uptickd tx distribution withdraw-rewards $(uptickd keys show $UP_WALLET --bech val -a) \
--chain-id $UP_CHAIN \
--from $UP_WALLET \
--commission \
--yes
```
Self delegation:
```
uptickd tx staking delegate $(uptickd keys show $UP_WALLET --bech val -a) <amount_to_delegate>auptick \
--chain-id=$UP_CHAIN \
--from=$UP_WALLET
```


