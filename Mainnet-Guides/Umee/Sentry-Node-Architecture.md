# Overview
Before we start installing and synchronizing the Umee node for the validator, we need to sync our Sentry Nodes. Since the validator should be in a private network with Sentry Nodes, and will communicate with the public network only through them.

### The most popular Sentry Node architecture
![image](https://user-images.githubusercontent.com/30211801/182532318-c0982f6f-1a3b-45cd-a39a-5063fca01e11.png)
One Sentry node will not be enough, because if it goes offline during a DDoS attack, then the validator node will also be offline, because validator synchronizes only from the Sentry node.

# Table of contents
- [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#setting-up-sentry-nodes)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#install-umee)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#edit-configtoml)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#restart)
- [Setting up a validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#setting-up-a-validator-node)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#install-umee-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#edit-configtoml-for-connecting-to-umee-chain-by-a-private-network)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md#start)

# Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install Umee
Go to the [[guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Basic-Installation-Synchronization.md)] and set up Umee RPC node.
Now it remains to configure Sentry Nodes to work in a private network also.
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.umee/config/config.toml
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
sudo systemctl restart umeed
journalctl -u umeed -f --output cat
umeed status 2>&1 | jq .SyncInfo
```
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.
# Setting up a validator node
## Install Umee Node
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
### Install the latest version of Umee
All releases can be viewed [here](https://github.com/umee-network/umee/releases)
```
cd ~
rm -rf /root/umee
git clone https://github.com/umee-network/umee.git
cd $HOME/umee
git pull
git checkout v1.1.2
make build
# Move the binary to an executable path
mv $HOME/umee/build/umeed /usr/local/bin
umeed version
```
### Let's add variables
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
UMEE_NODENAME=<YOUR_MONIKER>
UMEE_WALLET=<YOUR_WALLET>
UMEE_CHAIN=umee-1
echo 'export UMEE_NODENAME='\"${UMEE_NODENAME}\" >> $HOME/.bash_profile
echo 'export UMEE_WALLET='\"${UMEE_WALLET}\" >> $HOME/.bash_profile
echo 'export UMEE_CHAIN='\"${UMEE_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $UMEE_NODENAME $UMEE_WALLET $UMEE_CHAIN
```
### Init your config files
```
umeed init $UMEE_NODENAME --chain-id $UMEE_CHAIN
```
### Download `genesis.json`
```
wget -O $HOME/.umee/config/genesis.json https://github.com/umee-network/mainnet/raw/main/genesis.json
```
### Setting up config files
Seend and peers
```
peers="06169345b4ae8a59f5132bae78a63733767dc952@51.195.60.123:26656,8b6baf477cd6c5fde18573a57767e0bb0083a8ce@116.202.36.138:26656,f00230b900b2e03a0ebfb0cec024bc0229f4043f@135.181.223.194:26656,31c2b4851604cb0f88909116bc2029b2af392767@194.163.166.56:26656,e324ca5fad08769325921ed042b76bdb1df41e12@162.55.131.220:26656,4720fe172f90026e72723c38d75f4f20611bc792@88.198.70.2:26656,7d2b275cea5dc30a90c9657220b2ef9cf02dfe87@157.90.179.182:26656,d9c0fc2da0bf7b22b92f3cd89b4e98ff089fe446@65.21.132.226:56656,ae41472c094737bef61450c11f1b4978c0a3550d@18.144.151.186:26656,f6b22c8d26370afd0b3e5e78697e19f7a2fb8c73@144.217.74.27:26656,d0659fc256c3e6f99def7a7b16500097065a67e9@195.201.170.172:26656,5ec673b49eea3198f7c0df0782d62e0b7a7d5b9f@51.195.60.117:26656,cce3ded2638edcaf804e4fa18a4a988cd19e9ee1@148.251.152.54:26656,66377bf9c7d2106f8fb2814d105b934e2cf9bde8@78.46.66.6:26656,6dfab3a8a1d692c6270758757cb2026005a10622@65.108.106.252:26656,b7c7e560f13988dc00c6892c813ff6c459521917@44.231.119.182:26656,60349afbb66bfa51d466a1807b6034c8a8446b41@34.215.214.32:26656,96391162797cbdf10982cda8866913be471fbdd4@44.230.43.94:26656,9f86f8acfa46ac5380796328fe0d7daff5038f56@3.37.216.115:26656,629ce04f882462999de6791b0c4010dba5dafaaf@142.132.201.53:26656,77F54319D6F62C17036CA71B3F88365F652BF79F@169.197.142.149:26656,912b7279934187f8c94eacdc21a2e0bdee245eef@54.241.232.181:26656,94a928e1f5ebbc5fae12400c7d8bbdad8b197ad2@52.79.49.253:26656,870c0a786dc941f8ebecd2772c41c014b6cf8899@51.210.118.65:26656,47dd32dc5aa926ff76d8e53a4bc1fcf596cb254c@38.242.205.238:26656,efbcd2de6981fa7f692771e1b845c780c310e2fe@176.9.17.230:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.umee/config/config.toml
```
Minimum gas prices
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uumee\"/" $HOME/.umee/config/app.toml
```
Disk usage optimization
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.umee/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.umee/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.umee/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""50"\"/" $HOME/.umee/config/app.toml
```
### Create service file for Umee
```
sudo tee <<EOF >/dev/null /etc/systemd/system/umeed.service
[Unit]
Description=Umee Node
After=network-online.target
[Service]
User=$USER
Type=simple
ExecStart=$(which umeed) start
Restart=always
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

## Edit `config.toml` for connecting to Umee chain by a private network.
Open the config file by nano editor:
```
nano ~/.umee/config/config.toml
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
umeed tendermint unsafe-reset-all
sudo systemctl daemon-reload
sudo systemctl enable umeed
sudo systemctl restart umeed
```
Logs and status
```
sudo journalctl -u umeed -f -o cat
curl localhost:26657/status | jq
umeed status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.

Or use your own state sync for fast synchronization if you [set up State Sync on one of your Sentry Node](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync).

## Next Step
You have connected your validator node to a private network.

The next step is  [wallet funding & validator creating](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Umee/Wallet-Funding-Validator-Creating.md).
