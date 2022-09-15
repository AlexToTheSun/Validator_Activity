# References
- [Official github documentation](https://github.com/Source-Protocol-Cosmos/testnets)
- Explorers: [official](https://explorer.testnet.sourceprotocol.io/source), from [Nodiest](https://exp.nodeist.net/Source/staking), from [Stake-take](https://explorer.stake-take.com/source/staking)

# Actual Chain Information
- Chain_id `sourcechain-testnet`
- Denom: `usource`
- Account Prefix: `source`
- Min Fee: `0usource`
- [Genesis file](https://github.com/Source-Protocol-Cosmos/testnets/blob/master/sourcechain-testnet/genesis.json)
- go version: `>=1.18`

# Install Source Node
> ❗️ Note, that in this step, we will connect the  new node to the Source public network, it is recommended to do only for Sentry Nodes, and after that connect the Validator to them in the private network. So let's start the installation and synchronization process for nodes without a validator.
> 
We need to set variables for convenient operation, install the software, ran init and set up the configuration files to be able to start the sync.
### Install software/dependencies
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
### Install the latest version of Source
```
rm -rf /root/source
git clone -b testnet https://github.com/Source-Protocol-Cosmos/source.git
cd ~/source
make install
# Move the binary to an executable path
mv $HOME/go/bin/sourced /usr/local/bin
sourced version --long | head
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
SOURCE_NODENAME=<YOUR_MONIKER>
SOURCE_WALLET=<YOUR_WALLET>
SOURCE_CHAIN=sourcechain-testnet
echo 'export SOURCE_NODENAME='\"${SOURCE_NODENAME}\" >> $HOME/.bash_profile
echo 'export SOURCE_WALLET='\"${SOURCE_WALLET}\" >> $HOME/.bash_profile
echo 'export SOURCE_CHAIN='\"${SOURCE_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $SOURCE_NODENAME $SOURCE_WALLET $SOURCE_CHAIN
```
### Init your config files
```
sourced init $SOURCE_NODENAME --chain-id $SOURCE_CHAIN
```
### Download `genesis.json`
```
curl -s  https://raw.githubusercontent.com/Source-Protocol-Cosmos/testnets/master/sourcechain-testnet/genesis.json > ~/.source/config/genesis.json
```
### Config your node by changing `client.toml`
- Specify your rpc port (below there is a default rpc port)
```
sourced config chain-id $SOURCE_CHAIN
sourced config node tcp://localhost:26657
```
### Setting up config files
Seeds and peers
```
seeds="6ca675f9d949d5c9afc8849adf7b39bc7fccf74f@164.92.98.17:26656"
peers="8b6baf477cd6c5fde18573a57767e0bb0083a8ce@116.202.36.138:26656,f00230b900b2e03a0ebfb0cec024bc0229f4043f@135.181.223.194:26656,31c2b4851604cb0f88909116bc2029b2af392767@194.163.166.56:26656,e324ca5fad08769325921ed042b76bdb1df41e12@162.55.131.220:26656,4720fe172f90026e72723c38d75f4f20611bc792@88.198.70.2:26656,7d2b275cea5dc30a90c9657220b2ef9cf02dfe87@157.90.179.182:26656,d9c0fc2da0bf7b22b92f3cd89b4e98ff089fe446@65.21.132.226:56656,ae41472c094737bef61450c11f1b4978c0a3550d@18.144.151.186:26656,f6b22c8d26370afd0b3e5e78697e19f7a2fb8c73@144.217.74.27:26656,d0659fc256c3e6f99def7a7b16500097065a67e9@195.201.170.172:26656,5ec673b49eea3198f7c0df0782d62e0b7a7d5b9f@51.195.60.117:26656,cce3ded2638edcaf804e4fa18a4a988cd19e9ee1@148.251.152.54:26656,66377bf9c7d2106f8fb2814d105b934e2cf9bde8@78.46.66.6:26656,6dfab3a8a1d692c6270758757cb2026005a10622@65.108.106.252:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.source/config/config.toml
```
Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0usource\"/" $HOME/.source/config/app.toml
```
Disk usage optimization
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.source/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.source/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.source/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""50"\"/" $HOME/.source/config/app.toml
```
If you dont want to use your RPC node for relayer, then you can set `indexer = "null"`
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.source/config/config.toml
sudo rm ~/.source/data/tx_index.db/*
```
### Create service file for Source
```
sudo tee <<EOF >/dev/null /etc/systemd/system/sourced.service
[Unit]
Description=Source Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which sourced) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### Start synchronization from scratch
```
sourced tendermint unsafe-reset-all --home $HOME/.source
sudo systemctl daemon-reload
sudo systemctl enable sourced
sudo systemctl restart sourced
```
Logs and status
```
sudo journalctl -u sourced -f -o cat
curl localhost:26657/status | jq
sourced status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.
#### State Sycn and snapshots
1) State Sync
2) SnapShot from [obajay](https://github.com/obajay/nodes-Guides/tree/main/Source#snapshot-310822-01-gb-block-height----2139699)

## Next Step
We have connected your Sentry Nodes to a private network.

The next step is [Sentry Node Architecture](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md) where we will configure the Validator and Sentry Nodes to work in a private network.


