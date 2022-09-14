# References
- [Umee Github](https://github.com/umee-network)
- [Umee releases](https://github.com/umee-network/umee/releases/)
- Explorers [Guru](https://umee.explorers.guru/), [Mintscan](https://www.mintscan.io/umee/)
# Actual Chain Information
- Chain_id `umee-1`
- umeed version: [`v1.1.2`](https://github.com/umee-network/umee/releases/tag/v1.1.2)
- Denom: `uumee`
- Min Fee: `0.0025uumee`
- [Genesis file](https://github.com/umee-network/mainnet/raw/main/genesis.json)
- go version: `1.18.3`

# Install Umee Node
> ❗️ Note, that in this instruction, we will connect the node to the Umee public network, it is recommended to do this only for Sentry Nodes, and after that connect the Validator to them in the private network. So let's start the installation and synchronization process for nodes without a validator.
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
### Install the latest version of Umee
All versions can be viewed [here](https://github.com/umee-network/umee/releases/)
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
UMEE_NODENAME=Turetskiy
UMEE_WALLET=Turetskiy
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
### Start synchronization
#### From scratch:
This way recommended for validator node. Also for validator you can setup state sync on you sentry node, instruction for that is [here](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync). 
```
umeed unsafe-reset-all
sudo systemctl daemon-reload
sudo systemctl enable umeed
sudo systemctl restart umeed
journalctl -u umeed -f -o cat
```
Logs and status
```
sudo journalctl -u umeed -f -o cat
curl localhost:26657/status | jq
umeed status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized.

#### By State Sync:
1. Use my State Sync. Recommended only for **sentry nodes**. [Here is the step by step guide to use](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Umee-Mainnet.md).
2. For **validator node**. You can setup state sync on you sentry node, instruction for that is [here](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync). 

# Next Step
We have connected your Sentry Nodes to a private network.

The next step is [Sentry Node Architecture](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md) where we will configure the Validator and Sentry Nodes to work in a private network.












