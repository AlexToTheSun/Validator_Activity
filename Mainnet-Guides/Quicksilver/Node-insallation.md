#### Official links
- Github: 
  - https://github.com/ingenuity-build/quicksilver
  - https://github.com/ingenuity-build/mainnet
- Website: https://quicksilver.zone
- **Mainnet Faucet**: https://faucet.huginn.tech/

Explorers: 
  - https://quicksilver.explorers.guru/
  - https://www.mintscan.io/quicksilver

## Actual Chain Information
- Chain_id: `quicksilver-1`
- quicksilverd version: [v1.0.0](https://github.com/ingenuity-build/quicksilver/releases/tag/v1.0.0)
- Denom: `uqck`
- Denom-coefficient: `1000000`
- Genesis [File](https://raw.githubusercontent.com/ingenuity-build/mainnet/main/genesis.json)
- go version: `1.19`

# Quicksilver Node Install
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
wget -O go1.19.4.linux-amd64.tar.gz https://go.dev/dl/go1.19.4.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.4.linux-amd64.tar.gz && rm go1.19.4.linux-amd64.tar.gz
cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
# go version go1.19.4 linux/amd64
```
### Install the latest version of Quicksilver
All releases can be viewed [here](https://github.com/ingenuity-build/quicksilver/releases/tag)
```
cd $HOME 
rm -rf /root/quicksilver
git clone https://github.com/ingenuity-build/quicksilver.git
cd $HOME/quicksilver
git checkout v1.0.0
make install
cp $HOME/go/bin/quicksilverd /usr/local/bin
quicksilverd version --long | head
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
Q_NODENAME=<YOUR_MONIKER>
Q_WALLET=<YOUR_WALLET>
Q_RPC_PORT=<YOUR_RPC_PORT>
Q_CHAIN=quicksilver-1

echo 'export Q_NODENAME='\"${Q_NODENAME}\" >> $HOME/.bash_profile
echo 'export Q_WALLET='\"${Q_WALLET}\" >> $HOME/.bash_profile
echo 'export Q_CHAIN='\"${Q_CHAIN}\" >> $HOME/.bash_profile
echo 'export Q_RPC_PORT='\"${Q_RPC_PORT}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $Q_NODENAME $Q_WALLET $Q_CHAIN $Q_RPC_PORT
```
### Init your config files
```
quicksilverd init $Q_NODENAME --chain-id $Q_CHAIN
```
### Download `genesis.json`
```
curl -s https://raw.githubusercontent.com/ingenuity-build/mainnet/main/genesis.json > ~/.quicksilverd/config/genesis.json
```
### Config your node by changing `client.toml`, `app.toml` and `client.toml`
#### Config your node by changing `client.toml`
- Specify your rpc port, instead of the default `26657`.
If on your server there are two Cosmos SDK apps then you have to Change ports. After that you should specify your new RPC port in `client.toml`:
```
quicksilverd config node tcp://localhost:$Q_RPC_PORT
quicksilverd config chain-id $Q_CHAIN
```
#### Seeds and peers
```
export SEEDS="20e1000e88125698264454a884812746c2eb4807@seeds.lavenderfive.com:11156,babc3f3f7804933265ec9c40ad94f4da8e9e0017@seed.rhinostake.com:11156,00f51227c4d5d977ad7174f1c0cea89082016ba2@seed-quick-mainnet.moonshot.army:26650"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" ~/.quicksilverd/config/config.toml
```
#### Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001uqck\"/" $HOME/.quicksilverd/config/app.toml
```
#### Disk usage optimization
Pruning configuration
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.quicksilverd/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.quicksilverd/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.quicksilverd/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""50"\"/" $HOME/.quicksilverd/config/app.toml
```
If you dont want to use your RPC node for relayer, then you can set `indexer = "null"`
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.quicksilverd/config/config.toml
sudo rm ~/.quicksilverd/data/tx_index.db/*
```
### Create service file for Quicksilver
```
sudo tee <<EOF >/dev/null /etc/systemd/system/quicksilverd.service
[Unit]
Description=Quicksilver Cosmos daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which quicksilverd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
### Start synchronization from scratch
Not neccessary - to reset blockchain data use this `quicksilverd tendermint unsafe-reset-all --home $HOME/.quicksilverd`
```
sudo systemctl daemon-reload
sudo systemctl enable quicksilverd
sudo systemctl restart quicksilverd
```
Logs and status
```
sudo journalctl -u quicksilverd -f -o cat
curl localhost:$Q_RPC_PORT/status | jq
quicksilverd status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.

### Or use State Sync
For synchronization and saving space on the server, you can use [state sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Quicksilver.md)


### Create a validator
```
quicksilverd tx staking create-validator \
--amount 1000000uqck \
--commission-max-change-rate "0.1" \
--commission-max-rate "0.20" \
--commission-rate "0.06" \
--min-self-delegation "1" \
--details="" \
--website="" \
--identity="" \
--security-contact="" \
--pubkey=$(quicksilverd tendermint show-validator) \
--moniker=$Q_NODENAME \
--gas=250000 \
--chain-id quicksilver-1 \
--from=$Q_WALLET \
--node http://75.119.144.167:26657/
```

### Commands
```
quicksilverd q bank balances $(quicksilverd keys show $Q_WALLET -a)


quicksilverd tx slashing unjail --from $Q_WALLET --chain-id=$Q_CHAIN --yes --fees 50uqck
```
