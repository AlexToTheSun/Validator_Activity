Here is the most popular version of Sentry Node Architecture.
![image](https://user-images.githubusercontent.com/30211801/175352556-6ba67294-65f7-4aec-adf7-aaefa34c8d22.png)
One Sentry node will not be enough, because if it goes offline during a DDoS attack, then the validator node will also be offline, because validator synchronizes only from the Sentry node.

## Overview
- [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#setting-up-sentry-nodes)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#install-agoric)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#edit-configtoml)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#restart)
- [Setting up a validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#setting-up-a-validator-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#edit-configtoml-1)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md#restart-1)

## Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install Axelar chain
Go to the [[guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Axelar/Basic-Installation.md)] and set up Axelar RPC node. Complete steps Only for **`axelard`** installing an synchronization. Or just use this quick guide:
```
sudo apt update && sudo apt upgrade -y

sudo apt-get install nano mc git gcc g++ make curl yarn jq clang pkg-config libssl-dev build-essential ncdu libleveldb-dev -y

mkdir axelar-bin
cd axelar-bin
wget -q https://github.com/axelarnetwork/axelar-core/releases/download/v0.17.3/axelard-linux-amd64-v0.17.3
wget -q https://github.com/axelarnetwork/tofnd/releases/download/v0.10.1/tofnd-linux-amd64-v0.10.1
mv axelard-linux-amd64-v0.17.3 axelard
mv tofnd-linux-amd64-v0.10.1 tofnd
chmod +x *
sudo mv * /usr/bin/
axelard version
tofnd --help

echo export CHAIN_ID=axelar-testnet-casablanca-1 >> $HOME/.profile
MONIKER=<YOUR_MONIKER_RPC>
echo export MONIKER=$MONIKER >> $HOME/.profile

axelard init $MONIKER --chain-id $CHAIN_ID

wget -q https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/configuration/config.toml -O $HOME/.axelar/config/config.toml
wget -q https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/configuration/app.toml -O $HOME/.axelar/config/app.toml
wget -q https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/resources/testnet-2/genesis.json -O $HOME/.axelar/config/genesis.json

SEEDS="95c90e528c54e2ebaa0427e034c8facc75e6da3f@aa96e735f68464b09955026986b15632-1865235038.us-east-2.elb.amazonaws.com:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.axelar/config/config.toml

sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \""0.00005uaxl"\"/" $HOME/.axelar/config/app.toml

sed -i.bak 's/external_address = ""/external_address = "'"$(curl -4 ifconfig.co)"':26656"/g' $HOME/.axelar/config/config.toml

sed -i.bak 's/^log_level/# log_level/' $HOME/.axelar/config/config.toml

sed -i.bak -e "s/^moniker *=.*/moniker = \"$MONIKER\"/" $HOME/.axelar/config/config.toml

sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.axelar/config/config.toml
sudo rm ~/.axelar/data/tx_index.db/*

sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.axelar/config/app.toml

# Create service file 
sudo tee <<EOF >/dev/null /etc/systemd/system/axelard.service
[Unit]
Description=Axelard Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/axelard start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable axelard
sudo systemctl daemon-reload
sudo systemctl restart axelard
journalctl -u axelard.service -f -n 100
curl localhost:26657/status | jq '.result.sync_info'
```
If synchronization takes too long, use the synchronization from my [RPC node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Axelar-testnet-2.md).

Now it remains to configure Sentry Nodes to work in a private network also.
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.axelar/config/config.toml
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
sudo systemctl restart axelard
journalctl -u axelard -f --output cat
axelard status 2>&1 | jq .SyncInfo
```
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.
## Setting up a validator node
We have already installed all the necessary software, and configured `config.toml` to work on a public network. It's time to connect the validator node to the private network and run.
### Firewall configuration
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
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.axelar/config/config.toml
```
Changes are made in the file's section "P2P Configuration Options":
```
###################################
###  P2P Configuration Options  ###
###################################
pex = false
persistent_peers = "<nodeid>@<ip>:26656,<nodeid>@<ip>:26656"
private_peer_ids = ""
addr_book_strict = false
```
Description of parameters:
- `pex = true` - The node will only connect to Sentry Nodes from the persistent_peers list and will not propagate its address to the network. Thereby limiting the traffic.
- `persistent_peers = "<nodeid_sentry>@<ip_sentry>:26656,...."` - a list of addresses of your Sentry Nodes, so that you can connect to them.
- `private_peer_ids = ""` - We do not enter anything, since the gossip protocol is disabled, and the node will not issue any peers to the general network. Moreover, Sentry Node works not only in a private but also in a public network.
- `addr_book_strict = false` -  parameter allowing the validator to work in a private network. It will also be able to work in the public.

## Start synchronization  
Once you have your sentry nodes synced and ready to work on both private and public networks, it’s time to connect a validator node to them and start syncing.  

Since the validator node will now connect exclusively to your Sentry Nodes, which you have specified in config.toml, you have 3 options to synchronize the node:
1) **Synchronize from the first block**. To do this, enter the following commands:  

Since we previously configured the config.toml of the validator node to synchronize using State Sync, we need to disable this feature. Otherwise, the node will try to download Snapshot from the public node - this will not work. Enter:
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\false|" ~/.axelar/config/config.toml
```
Start sync:
```
axelard unsafe-reset-all
sudo systemctl enable axelard
sudo systemctl daemon-reload
sudo systemctl restart axelard
```
2) **Use full date snapshot**. Download and unzip data folder.
Download the snapshot from https://bitszn.com/snapshots.html
```
wget https://snapshots.bitszn.com/snapshots/axelar/axelar.tar
rm -rf ~/.axelar/data/*
mv axelar.tar ~/.axelar/data/
tar -xvf axelar.tar
cd ~
```
3) [**Run your own RPC with State Sync**](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync), on one of your Sentry Nodes. then connect Validator node to it by changing the config. 
### Start the service of Validator Node
To do this, go back to the Basic-Installation guide and continue from the moment [[starting synchronization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Axelar/Basic-Installation.md#start-service-files)]








