Officiall link is here https://github.com/haqq-network/validators-contest

Explorer: 
  - https://haqq.explorers.guru/
  - https://testnet.manticore.team/haqq

## Actual Chain Information
- Chain_id: `haqq_54211-2`
- haqqd version: [v1.0.3](https://github.com/haqq-network/haqq/releases/tag/v1.0.3)
- Denom: `aISLM`
- Denom-coefficient: `1000000000000000000`
- Genesis [File](https://raw.githubusercontent.com/haqq-network/validators-contest/master/genesis.json)
- go version: `1.18.3`

 # Haqq Node Install
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
### Install the latest version of Haqq
All releases can be viewed [here](https://github.com/haqq-network/haqq/releases/tag)
```
cd $HOME 
rm -rf /root/haqq
git clone https://github.com/haqq-network/haqq
cd $HOME/haqq
git checkout v1.0.3
make install
mv $HOME/go/bin/haqqd /usr/local/bin
haqqd version --long | head
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
HAQQ_NODENAME=<YOUR_MONIKER>
HAQQ_WALLET=<YOUR_WALLET>
HAQQ_CHAIN=haqq_54211-2
echo 'export HAQQ_NODENAME='\"${HAQQ_NODENAME}\" >> $HOME/.bash_profile
echo 'export HAQQ_WALLET='\"${HAQQ_WALLET}\" >> $HOME/.bash_profile
echo 'export HAQQ_CHAIN='\"${HAQQ_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $HAQQ_NODENAME $HAQQ_WALLET $HAQQ_CHAIN
```
### Init your config files
```
haqqd init $HAQQ_NODENAME --chain-id $HAQQ_CHAIN
```
### Download `genesis.json`
```
curl -s  https://raw.githubusercontent.com/haqq-network/validators-contest/master/genesis.json > ~/.haqqd/config/genesis.json
```
### Config your node by changing `client.toml`, `app.toml` and `client.toml`
#### Config your node by changing `client.toml`
- Specify your rpc port (below there is a default rpc port)
If on your server there are two Cosmos SDK apps then you have to Change ports. After that you should specify your new RPC port in `client.toml`:
```
haqqd config node tcp://localhost:26657
haqqd config chain-id $HAQQ_CHAIN
```
#### Seeds and peers
```
peers="b3ce1618585a9012c42e9a78bf4a5c1b4bad1123@65.21.170.3:33656,952b9d918037bc8f6d52756c111d0a30a456b3fe@213.239.217.52:29656,85301989752fe0ca934854aecc6379c1ccddf937@65.109.49.111:26556,d648d598c34e0e58ec759aa399fe4534021e8401@109.205.180.81:29956,f2c77f2169b753f93078de2b6b86bfa1ec4a6282@141.95.124.150:20116,eaa6d38517bbc32bdc487e894b6be9477fb9298f@78.107.234.44:45656,37513faac5f48bd043a1be122096c1ea1c973854@65.108.52.192:36656,d2764c55607aa9e8d4cee6e763d3d14e73b83168@66.94.119.47:26656,fc4311f0109d5aed5fcb8656fb6eab29c15d1cf6@65.109.53.53:26656,297bf784ea674e05d36af48e3a951de966f9aa40@65.109.34.133:36656,bc8c24e9d231faf55d4c6c8992a8b187cdd5c214@65.109.17.86:32656"
seeds="62bf004201a90ce00df6f69390378c3d90f6dd7e@seed2.testedge2.haqq.network:26656,23a1176c9911eac442d6d1bf15f92eeabb3981d5@seed1.testedge2.haqq.network:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.haqqd/config/config.toml
```
#### Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0aISLM\"/" $HOME/.haqqd/config/app.toml
```
#### Disk usage optimization
Pruning configuration
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.haqqd/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.haqqd/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.haqqd/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""50"\"/" $HOME/.haqqd/config/app.toml
```
If you dont want to use your RPC node for relayer, then you can set `indexer = "null"`
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.haqqd/config/config.toml
sudo rm ~/.haqqd/data/tx_index.db/*
```
### Create service file for Haqq
```
sudo tee <<EOF >/dev/null /etc/systemd/system/haqqd.service
[Unit]
Description=Haqq Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which haqqd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start synchronization from scratch
```
haqqd tendermint unsafe-reset-all --home $HOME/.haqqd
sudo systemctl daemon-reload
sudo systemctl enable haqqd
sudo systemctl restart haqqd
```
Logs and status
```
sudo journalctl -u haqqd -f -o cat
curl localhost:26657/status | jq
haqqd status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.

### Or use State Sync
For synchronization and saving space on the server, you can use [state sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Haqq-(haqq_54211-2).md)

## Next Step
The next step is [wallet funding & validator creating](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/Haqq/Wallet-Funding-Validator-Creating.md).
