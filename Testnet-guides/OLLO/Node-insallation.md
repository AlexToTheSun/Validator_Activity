#### Official links
- Github: https://github.com/OllO-Station/ollo
- Docs: https://docs.ollo.zone/validators/running_a_node

Explorers: 
  - http://turnodes.com/ollo
  - https://testnet.manticore.team/ollo

## Actual Chain Information
- Chain_id: `ollo-testnet-0`
- Releases: [here](https://github.com/OllO-Station/ollo/releases)
- Denom: `utollo`
- Denom-coefficient: `1000000`
- Genesis [File](https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/genesis.json)
- go version: `1.18.3`

 # OllO Node Installation
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
### Install the latest version of OllO
All releases can be viewed [here](https://github.com/OllO-Station/ollo/releases)
```
cd $HOME 
rm -rf /root/ollo
git clone https://github.com/OllO-Station/ollo.git
cd $HOME/ollo
make install
ollod version --long | head
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
OLLO_NODENAME=<YOUR_MONIKER>
OLLO_WALLET=<YOUR_WALLET>
OLLO_CHAIN=ollo-testnet-0
echo 'export OLLO_NODENAME='\"${OLLO_NODENAME}\" >> $HOME/.bash_profile
echo 'export OLLO_WALLET='\"${OLLO_WALLET}\" >> $HOME/.bash_profile
echo 'export OLLO_CHAIN='\"${OLLO_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $OLLO_NODENAME $OLLO_WALLET $OLLO_CHAIN
```
### Init your config files
```
ollod init $OLLO_NODENAME --chain-id $OLLO_CHAIN
```
### Download `genesis.json`
```
curl -s  https://raw.githubusercontent.com/OllO-Station/ollo/master/networks/ollo-testnet-0/genesis.json > ~/.ollo/config/genesis.json
```
### Config your node by changing `client.toml`, `app.toml` and `client.toml`
#### Config your node by changing `client.toml`
- Specify your rpc port (below there is a default rpc port)
If on your server there are two Cosmos SDK apps then you have to Change ports. After that you should specify your new RPC port in `client.toml`:
```
ollod config node tcp://localhost:26657
ollod config chain-id $OLLO_CHAIN
```
#### Seeds and peers
```
peers="2a8f0fada8b8b71b8154cf30ce44aebea1b5fe3d@145.239.31.245:26656,1173fe561814f1ecb8b8f19d1769b87cd576897f@185.173.157.251:26656,489daf96446f104d822fae34cd4aa7a9b5cebf65@65.21.131.215:26626,f43435894d3ae6382c9cf95c63fec523a2686345@167.235.145.255:26656,2eeb90b696ba9a62a8ad9561f39c1b75473515eb@77.37.176.99:26656,9a3e2725e02d1c420a5d500fa17ce0ef45ddc9e8@65.109.30.117:29656,91f1889f22975294cfbfa0c1661c63150d2b9355@65.108.140.222:30656,d38fcf79871189c2c430473a7e04bd69aeb812c2@78.107.234.44:16656,f795505ac42f18e55e65c02bb7107b08d83ad837@65.109.17.86:37656,6368702dd71e69035dff6f7830eb45b2bae92d53@65.109.57.161:15656"
seeds=""
sed -i.bak -e "s/^seeds *=.*/seeds = \"$seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.ollo/config/config.toml
```
#### Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0utollo\"/" $HOME/.ollo/config/app.toml
```
#### Disk usage optimization
Pruning configuration
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.ollo/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.ollo/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.ollo/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""50"\"/" $HOME/.ollo/config/app.toml
```
If you dont want to use your RPC node for relayer, then you can set `indexer = "null"`
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.ollo/config/config.toml
sudo rm ~/.ollo/data/tx_index.db/*
```
### Create service file for OllO
```
sudo tee <<EOF >/dev/null /etc/systemd/system/ollod.service
[Unit]
Description=OllO Cosmos daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which ollod) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
### Start synchronization from scratch
```
ollod tendermint unsafe-reset-all --home $HOME/.ollod
sudo systemctl daemon-reload
sudo systemctl enable ollod
sudo systemctl restart ollod
```
Logs and status
```
sudo journalctl -u ollod -f -o cat
curl localhost:26657/status | jq
ollod status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.

### Or use State Sync
For synchronization and saving space on the server, you can use [state sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/OLLO-Testnet.md)

## Next Step
The next step is [wallet funding & validator creating](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/OLLO/Wallet-Funding-Validator-Creating.md).
