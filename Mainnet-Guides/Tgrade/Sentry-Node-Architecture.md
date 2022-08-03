# Overview
Before we start installing and synchronizing the Tgrade node for the validator, we need to sync our Sentry Nodes. Since the validator should be in a private network with Sentry Nodes, and will communicate with the public network only through them.

### The most popular Sentry Node architecture
![image](https://user-images.githubusercontent.com/30211801/182532318-c0982f6f-1a3b-45cd-a39a-5063fca01e11.png)
One Sentry node will not be enough, because if it goes offline during a DDoS attack, then the validator node will also be offline, because validator synchronizes only from the Sentry node.

# Table of contents
- [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#setting-up-sentry-nodes)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#install-tgrade)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#edit-configtoml)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#restart)
- [Setting up a validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#setting-up-a-validator-node)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#install-tgrade-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#edit-configtoml-for-connecting-to-tgrade-chain-by-a-private-network)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md#start)

# Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install Tgrade
Go to the [[guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Basic-Installation-Synchronization.md)] and set up Tgrade RPC node.
Now it remains to configure Sentry Nodes to work in a private network also.
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.tgrade/config/config.toml
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
sudo systemctl restart tgrade
journalctl -u tgrade -f --output cat
tgrade status 2>&1 | jq .SyncInfo
```
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.
# Setting up a validator node
## Install Tgrade Node
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
### Install the latest version of Tgrade
All versions can be viewed [here](https://github.com/confio/tgrade/tags)
```
rm -rf /root/tgrade
git clone https://github.com/confio/tgrade
cd tgrade
git checkout v1.0.1
# Run GO install and build for the upcoming binary
make build
# Move the binary to an executable path
mv build/tgrade /usr/local/bin
tgrade version
# 1.0.1
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
TGRADE_NODENAME=<YOUR_MONIKER>
TGRADE_WALLET=<YOUR_WALLET>
TGRADE_CHAIN=tgrade-mainnet-1
echo 'export TGRADE_NODENAME='\"${TGRADE_NODENAME}\" >> $HOME/.bash_profile
echo 'export TGRADE_WALLET='\"${TGRADE_WALLET}\" >> $HOME/.bash_profile
echo 'export TGRADE_CHAIN='\"${TGRADE_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $TGRADE_NODENAME $TGRADE_WALLET $TGRADE_CHAIN
```
### Init your config files
```
tgrade init $TGRADE_NODENAME --chain-id $TGRADE_CHAIN
```
### Download `genesis.json`
```
wget -qO $HOME/.tgrade/config/genesis.json "https://raw.githubusercontent.com/confio/tgrade-networks/main/mainnet-1/config/genesis.json"
```
Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.05utgd\"/" $HOME/.tgrade/config/app.toml
```
Disk usage optimization
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.tgrade/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.tgrade/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.tgrade/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""50"\"/" $HOME/.tgrade/config/app.toml
```
### Create service file for Tgrade
```
sudo tee <<EOF >/dev/null /etc/systemd/system/tgrade.service
[Unit]
Description=Tgrade Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which tgrade) start
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

## Edit `config.toml` for connecting to Tgrade chain by a private network.
Open the config file by nano editor:
```
nano ~/.tgrade/config/config.toml
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
tgrade tendermint unsafe-reset-all --home $HOME/.tgrade
sudo systemctl daemon-reload
sudo systemctl enable tgrade
sudo systemctl restart tgrade
```
Logs and status
```
sudo journalctl -u tgrade -f -o cat
curl localhost:26657/status | jq
tgrade status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.


## Next Step
You have connected your validator node to a private network.

The next step is  [wallet funding & validator creating](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Tgrade/Wallet-Funding-%26-Validator-Creating.md).
