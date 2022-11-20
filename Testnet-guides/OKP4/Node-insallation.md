#### Official links
- Github: https://github.com/okp4/okp4d
- Docs: https://docs.okp4.network/docs/nodes/introduction
- Nemeton validator program: https://nemeton.okp4.network/
- Discord faucet: [# 🚰｜faucet](https://discord.gg/okp4) channel

Explorers: 
  - https://okp4.explorers.guru/
  - https://explore.okp4.network/
  - https://explorer-turetskiy.xyz/okp4

## Actual Chain Information
- Chain_id: `okp4-nemeton`
- okp4d version: [v2.2.0](https://github.com/okp4/okp4d/releases/tag/v2.2.0)
- Denom: `uknow`
- Denom-coefficient: `1000000`
- Genesis [File](https://raw.githubusercontent.com/okp4/networks/main/chains/nemeton/genesis.json)
- go version: `1.18.3`

 # OKP4 Node Install
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
### Install the latest version of OKP4
All releases can be viewed [here](https://github.com/okp4/okp4d/releases)
```
cd $HOME 
rm -rf /root/okp4d
git clone https://github.com/okp4/okp4d.git
cd $HOME/okp4d
git checkout v2.2.0
make install
mv $HOME/go/bin/okp4d /usr/local/bin
okp4d version --long | head
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
OKP_NODENAME=<YOUR_MONIKER>
OKP_WALLET=<YOUR_WALLET>
OKP_CHAIN=okp4-nemeton
echo 'export OKP_NODENAME='\"${OKP_NODENAME}\" >> $HOME/.bash_profile
echo 'export OKP_WALLET='\"${OKP_WALLET}\" >> $HOME/.bash_profile
echo 'export OKP_CHAIN='\"${OKP_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $OKP_NODENAME $OKP_WALLET $OKP_CHAIN
```
### Init your config files
```
okp4d init $OKP_NODENAME --chain-id $OKP_CHAIN
```
### Change OKP4 ports
```
OKP_PORT=23
echo "export OKP_PORT=${OKP_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OKP_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OKP_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OKP_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OKP_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OKP_PORT}660\"%" $HOME/.okp4d/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OKP_PORT}317\"%; s%^address = \":8080\"%address = \":${OKP_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OKP_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OKP_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${OKP_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${OKP_PORT}546\"%" $HOME/.okp4d/config/app.toml
```
### Download `genesis.json`
```
curl -s  https://raw.githubusercontent.com/okp4/networks/main/chains/nemeton/genesis.json > ~/.okp4d/config/genesis.json
```
### Config your node by changing `client.toml`, `app.toml` and `client.toml`
#### Config your node by changing `client.toml`
- Specify your rpc port (below there is a default rpc port)
If on your server there are two Cosmos SDK apps then you have to Change ports. After that you should specify your new RPC port in `client.toml`:
```
okp4d config node tcp://localhost:${OKP_PORT}657
okp4d config chain-id $OKP_CHAIN
```
#### Seeds and peers
```
SEEDS="8e1590558d8fede2f8c9405b7ef550ff455ce842@51.79.30.9:26656,bfffaf3b2c38292bd0aa2a3efe59f210f49b5793@51.91.208.71:26656,106c6974096ca8224f20a85396155979dbd2fb09@198.244.141.176:26656,a7f1dcf7441761b0e0e1f8c6fdc79d3904c22c01@38.242.150.63:36656"
PEERS="994c9398e55947b2f1f45f33fbdbffcbcad655db@okp4-testnet.nodejumper.io:29656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.okp4d/config/config.toml
```
#### Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uknow\"/" $HOME/.okp4d/config/app.toml
```
#### Disk usage optimization
Pruning configuration
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.okp4d/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.okp4d/config/app.toml
```
If you dont want to use your RPC node for relayer, then you can set `indexer = "null"`
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.okp4d/config/config.toml
sudo rm ~/.okp4d/data/tx_index.db/*
```
### Create service file for OKP4
```
sudo tee /etc/systemd/system/okp4d.service > /dev/null <<EOF
[Unit]
Description=Okp4 Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which okp4d) start --home $HOME/.okp4d
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start synchronization from scratch
```
sudo systemctl daemon-reload
sudo systemctl enable okp4d
sudo systemctl restart okp4d
```
Logs and status
```
sudo journalctl -u okp4d -f -o cat
curl localhost:{OKP_PORT}/status | jq
okp4d status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.

### Or use State Sync
For synchronization and saving space on the server, you can use [state sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/OKP4-(okp4-nemeton).md)

## Next Step
The next step is [wallet funding & validator creating](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/OKP4/Wallet-Funding-Validator-Creating.md).
