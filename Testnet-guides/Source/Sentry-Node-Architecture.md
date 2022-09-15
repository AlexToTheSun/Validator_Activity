# Overview
Before we start installing and synchronizing the Source node for the validator, we need to sync our Sentry Nodes. Since the validator should be in a private network with Sentry Nodes, and will communicate with the public network only through them.

### The most popular Sentry Node architecture
![image](https://user-images.githubusercontent.com/30211801/182532318-c0982f6f-1a3b-45cd-a39a-5063fca01e11.png)
One Sentry node will not be enough, because if it goes offline during a DDoS attack, then the validator node will also be offline, because validator synchronizes only from the Sentry node.

# Table of contents
- [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#setting-up-sentry-nodes)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#install-source)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#edit-configtoml)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#restart)
- [Setting up a validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#setting-up-a-validator-node)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#install-source-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#edit-configtoml-for-connecting-to-source-chain-by-a-private-network)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md#start)

# Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install Source
Go to the [[guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Basic-Installation-Synchronization.md)] and set up Source RPC node.
Now it remains to configure Sentry Nodes to work in a private network also.
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.source/config/config.toml
```
Changes are made in the file's section "P2P Configuration Options":
```
###################################
###  P2P Configuration Options  ###
###################################
pex = true
persistent_peers = "<nodeid_sentry>@<ip_sentry>:26656,<nodeid_sentry>@<ip_sentry>:26656"
private_peer_ids = "<nodeid_VAL>@<ip_VAL>:26656"
addr_book_strict = false
```
Description of parameters:
- `pex = true` - Sentry nodes must be connected to a common blockchain network. To be able to use the shared address book, which means the gossip protocol must be enabled!
- `persistent_peers = "<nodeid_sentry>@<ip_sentry>:26656,...."` - a list of priority nodes for connecting. You could list of Validator address and your other Sentry Nodes addresses. You could add Sentry Node teams or trusted network members.
- `private_peer_ids = "<nodeid_VAL>@<ip_VAL>:26656"` - Insert the validator's node id and ip to prevent Sentry nodes from propagating information about the validator to public network by gossip protocol.
- `addr_book_strict = false` -  this is the setting to allow Sentry nodes to operate on the private network. They will also be able to work in the public.
### Restart
Restart Sentry Node for the changes that we made in config.toml to take effect.
```
sudo systemctl restart sourced
journalctl -u sourced -f --output cat
sourced status 2>&1 | jq .SyncInfo
```
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.
# Setting up a validator node
## Install Source Node
We need to set variables for convenient operation, set variables for convenient operation, install the software, ran init and set up the configuration files to be able to start the sync.
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
All versions can be viewed [here](https://github.com/Source-Protocol-Cosmos/source)
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
The "Indexing" function is only needed by those who need to request transactions from a specific node. Most of the time this setting can be changed:
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
## Firewall configuration
The only thing is that now port 26656 is open to everyone. And you can close it and allow connection only to the IP of Sentry Nods. It is could be done like this:
```
sudo ufw deny 26656/udp
sudo ufw allow from <ip_1> to any port 26656/udp
sudo ufw allow from <ip_2> to any port 26656/udp
...
sudo ufw allow from <ip_n> to any port 26656/udp
sudo ufw status verbose
```
Where `<ip_1>`, `<ip_2>`,..., `<ip_n>` are the ip of servers with Sentry Node installed on them.

## Edit `config.toml` for connecting to Source chain by a private network.
Open the config file by nano editor:
```
nano ~/.source/config/config.toml
```
Changes are made in the file's section "P2P Configuration Options":
```
###################################
###  P2P Configuration Options  ###
###################################
pex = false
persistent_peers = ""<nodeid>@<ip>:26656,<nodeid>@<ip>:26656"
private_peer_ids = ""
addr_book_strict = false
```
Description of parameters:
- `pex = true` - The node will only connect to Sentry Nodes from the persistent_peers list and will not propagate its address to the network. Thereby limiting the traffic.
- `persistent_peers = "<nodeid_sentry>@<ip_sentry>:26656,...."` - a list of addresses of your Sentry Nodes, so that you can connect to them.
- `private_peer_ids = ""` - We do not enter anything, since the gossip protocol is disabled, and the node will not issue any peers to the general network. Moreover, Sentry Node works not only in a private but also in a public network.
- `addr_book_strict = false` -  parameter allowing the validator to work in a private network. It will also be able to work in the public.

## Start
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
## Faast sync of your validator
> It is important for us **not only to quickly synchronize** the validator node, but also **not to give out information** about our validator to the public network, so there are only 3 ways to synchronize the validator node when using Sentry Nodes.
- Synchronize from the first block. With this option it is recommended to use disk usage optimization.
- Set up your own State Sync based on one of your Sentry Node.
- Use full snapshot data. [Stake-take](https://github.com/StakeTake/guidecosmos/tree/main/source/sourcechain-testnet#snapshot-height-2124972-15gb), [Obajay](https://github.com/obajay/nodes-Guides/tree/main/Source#snapshot-310822-01-gb-block-height----2139699)
## Next Step
You have connected your validator node to a private network.

The next step is  [wallet funding & validator creating](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/Source/Wallet-Funding-%26-Validator-Creating.md).
