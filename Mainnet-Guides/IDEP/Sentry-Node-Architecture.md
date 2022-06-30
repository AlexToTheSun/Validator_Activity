## Overview
![image](https://user-images.githubusercontent.com/30211801/175352556-6ba67294-65f7-4aec-adf7-aaefa34c8d22.png)
Here is the most popular version of Sentry Node Architecture.
## Steps
- [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#setting-up-sentry-nodes)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#install-idep-network)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#edit-configtoml-for-a-sentry-node)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#restart)
- [Setting up a validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#setting-up-a-validator-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#edit-configtoml)
  - [Start validator synchronization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md#start-validator-synchronization)

## Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install IDEP network
Go to the [[official guide](https://github.com/AlexToTheSun/Antora#original-launch-docs)] and set up IDEP public RPC node (without a validator). Complete steps Only for starting synchronization. Or just use this quick guide:
```
sudo apt update && sudo apt upgrade -y
sudo apt-get install make git jq curl gcc g++ mc nano -y

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

git clone https://github.com/IDEP-network/Antora.git
cd Antora
sudo chmod +x iond
cp iond /usr/local/bin/

iond version --long
iond -h

# Write your <moniker> and <accountname> below

iond_MONIKER=<moniker>
iond_WALLET=<accountname>
iond_CHAIN=Antora
echo 'export iond_MONIKER='\"${iond_MONIKER}\" >> $HOME/.bash_profile
echo 'export iond_WALLET='\"${iond_WALLET}\" >> $HOME/.bash_profile
echo 'export iond_CHAIN='\"${iond_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile

iond init $iond_MONIKER --chain-id $iond_CHAIN

external_address=$(curl -s ifconfig.me):26656
sed -i.bak -e "s/^external_address = \"\"/external_address = \"$external_address\"/" $HOME/.ion/config/config.toml

cd ~/.ion/config/
rm genesis.json
wget https://raw.githubusercontent.com/IDEP-network/Antora/main/genesis.json

SEEDS="6e52997400aaa1b3d2155e45cf2559bf7a4c5e76@164.92.161.91:26656"
PEERS="f14e7dd78fd2462541f59eac08a8107fca89c2b3@75.119.159.159:26641,8ffc74dbcd5ab32bc89e058ec53060d5762f88b5@178.63.100.102:26656,2a5c7fb6475f4edf5ea36dd1d40aecc70f55fa45@65.108.106.19:11343"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.ion/config/config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ion/config/config.toml


sudo -E bash -c 'cat << EOF > /etc/systemd/system/iond.service
[Unit]
Description=Iond Daemon
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/iond start
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF'

sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.ion/config/config.toml
sudo rm ~/.ion/data/tx_index.db/*
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.ion/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.ion/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.ion/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.ion/config/app.toml

sudo systemctl enable iond
sudo systemctl daemon-reload
sudo systemctl restart iond
sudo systemctl status iond
journalctl -u iond -f --output cat
```

If synchronization takes too long, use the synchronization from my [RPC node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/IDEP.md).
### Edit config.toml for a Sentry node
Now it remains to configure Sentry Nodes to work in a private network also. Open the config file by nano editor:
```
nano ~/.ion/config/config.toml
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
sudo systemctl restart iond
journalctl -u iond -f --output cat
iond status 2>&1 | jq .SyncInfo
```
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.
## Setting up a validator node
If we have already did [minimal server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md), installed all the necessary software, and configured `config.toml` to work on a public network? **I hope you didn't start the service yet**, because in this case your node_id and ip address are already in the public network.

It's time to connect the validator node to the private network and run it.

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
nano ~/.ion/config/config.toml
```
Changes have to be made in the file's section "P2P Configuration Options":
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

## Start validator synchronization  
Once you have your sentry nodes synced and ready to work on both private and public networks, it’s time to connect a validator node to them and start syncing.  

Since the validator node will now connect exclusively to your Sentry Nodes, which you have specified in config.toml, you have 3 options to synchronize the node:
1) **Synchronize from the first block**. To do this, enter the following commands:  

Since we previously configured the `config.toml` of the validator node to synchronize using State Sync, we need to disable this feature. Otherwise, the node will try to download Snapshot from the public node - this will not work. Enter:
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\false|" ~/.ion/config/config.toml
```
Start sync:
```
iond unsafe-reset-all
sudo systemctl enable iond
sudo systemctl daemon-reload
sudo systemctl restart iond
```
2) **Run your own RPC with State Sync** [here is the instructions](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync), on one of your Sentry Nodes. Then connect Validator node to it by changing the config of the validator' node. 
3) **Use full date snapshot**. Download and unzip data folder form someone's  snspshot tool.



















