# Transferring Overview
In short, we need:
1. Install and sync Gravity Bridge on a new server.
2. Stop Gravity on the old server.
3. Transfer the `~/.gravity/config` folder to the new server.
4. Transfer/restore keys for GBT.
5. Restart Gravity Bridge.

## Install and sync Gravity Bridge on a new server
Update & upgrade
```
sudo apt update && sudo apt upgrade -y
```
Install the required packages
```
sudo apt-get install nano mc git gcc g++ make curl yarn jq clang pkg-config libssl-dev build-essential ncdu -y
```
#### Geth
Download and install geth
```
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.15-8be800ff.tar.gz
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/geth-light-config.toml -O /etc/geth-light-config.toml
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/geth-full-config.toml -O /etc/geth-full-config.toml
tar -xvf geth-linux-amd64-1.10.15-8be800ff.tar.gz
cd geth-linux-amd64-1.10.15-8be800ff
mv geth /usr/sbin/
geth version
```
OR if you want to use [infura](https://infura.io/) then you dont need to install geth. Instead of this you will need put in the file `/etc/systemd/system/orchestrator.service` the flag with your eth endpoint created on infura `--ethereum-rpc  https://mainnet.infura.io/v3/....`

### Download the latest version of Gravity chain and GBT
```
mkdir gravity-bin
cd gravity-bin

# the gravity chain binary itself
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.8.0/gravity-linux-amd64
mv gravity-linux-amd64 gravity

# the gbt binary
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.8.0/gbt

# move binaries to /usr/bin/
chmod +x *
sudo mv * /usr/bin/
```
### Download services
```
cd /etc/systemd/system
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/gravity-node.service
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/orchestrator.service
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/geth.service
```
### Let's add variables
```
Grav_moniker=<YOUR_MONIKER>
Grav_wallet=<YOUR_WALLET>
Grav_chain=gravity-bridge-3
echo 'export Grav_moniker='\"${Grav_moniker}\" >> $HOME/.bash_profile
echo 'export Grav_wallet='\"${Grav_wallet}\" >> $HOME/.bash_profile
echo 'export Grav_chain='\"${Grav_chain}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $Grav_moniker $Grav_wallet $chainName
```
### Init the config files
```
cd $HOME
gravity init $Grav_moniker --chain-id $Grav_chain
```
### Download genesis.json
```
curl -s  https://raw.githubusercontent.com/Gravity-Bridge/gravity-docs/main/genesis.json > ~/.gravity/config/genesis.json
```
### Config a new node by changing client.toml, app.toml and client.toml
Change rpc port (if you changed it in config.toml) and add chain_id to `client.toml`
```
gravity config node tcp://localhost:26657
# where 26657 is your rpc port

gravity config chain-id $Grav_chain
```
Add seed nodes into config.toml
```
SEEDS="2b089bfb4c7366efb402b48376a7209632380c9c@65.19.136.133:26656,63e662f5e048d4902c7c7126291cf1fc17687e3c@95.211.103.175:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.gravity/config/config.toml
```
### Setting the `minimum-gas-prices`
1. In `.gravity/config/app.toml` 0.0001ugraviton
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \""0.0001ugraviton"\"/" $HOME/.gravity/config/app.toml
```
2. In `orchestrator.service` add a flag `--fees "55ugraviton"`. This line will look like:
```
ExecStart=/usr/bin/gbt orchestrator --fees "55ugraviton"
```
And if you want to add external eth node - it will look like this (type your own ethereum rpc address):
```
ExecStart=/usr/bin/gbt orchestrator --fees "55ugraviton" --ethereum-rpc  https://mainnet.infura.io/v3/sdsdf09f9hd0fh9f0h9dfh7u98f7gs7dfg
```
### Disk usage optimisation
```
# sudo nano ~/.gravity/config/config.toml
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.gravity/config/config.toml
sudo rm ~/.gravity/data/tx_index.db/*

# sudo nano ~/.gravity/config/app.toml
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.gravity/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.gravity/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.gravity/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.gravity/config/app.toml
```
### Configure your node for state sync
Use this guide for sate sync https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Gravity-Bridge.md
### Start
```
sudo systemctl daemon-reload
sudo systemctl enable gravity-node
sudo systemctl restart gravity-node

sudo systemctl enable orchestrator
sudo service orchestrator restart

# Logs
journalctl -u gravity-node -f --output cat
journalctl -u orchestrator -f --output cat
```
For now orchestrator will not work as we didnt restor keys.



