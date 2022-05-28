**Links**
- Official instructions for devnet: https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Devnet
- Explorer: https://devnet.explorer.agoric.net/
- Actual branch could be found here: https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Devnet#network-status
### Installing
**Update & upgrade**
```
sudo apt update && sudo apt upgrade -y
```
**Install the required packages**
```
sudo apt-get install nano mc git gcc g++ make curl yarn -y
```
**Install GO**
```
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
# go version go1.18 linux/amd64
```
**Install Nodejs**
```
# Download the nodesource PPA for Node.js
curl https://deb.nodesource.com/setup_14.x | sudo bash

# Download the Yarn repository configuration
# See instructions on https://legacy.yarnpkg.com/en/docs/install/
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Install Node.js, Yarn, and build tools
# Install jq for formatting of JSON data
sudo apt install nodejs=14.* yarn build-essential jq -y
```
### Install Agoric SDK
```
cd /usr/src/ 
#  It will fix a path issue
rm -r agoric-sdk
git clone https://github.com/Agoric/agoric-sdk -b agoricdev-11
cd agoric-sdk

yarn install
yarn build
(cd packages/cosmic-swingset && make)
agd version --long
cp /root/go/bin/agd /usr/bin
```
### Configuring Your Node
First of all create a variables
```
AGORIC_NODENAME=<YOUR_MONIKER>
AGORIC_WALLET=<YOUR_WALLET>
echo 'export AGORIC_NODENAME='\"${AGORIC_NODENAME}\" >> $HOME/.bash_profile
echo 'export AGORIC_WALLET='\"${AGORIC_WALLET}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $AGORIC_NODENAME $AGORIC_WALLET
```
#### Check the Network Parameters
```
curl https://devnet.agoric.net/network-config > chain.json
chainName=`jq -r .chainName < chain.json`
echo $chainName
echo 'export chainName='\"${chainName}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
#### Creating a key
```
agd keys add $AGORIC_WALLET
```
#### Apply Network Parameters
**Make init of Agoric with `--recover` flag**
```
agd init --chain-id $chainName $AGORIC_NODENAME --recover
```
!!! Use `--recover` to provide seed phrase of your wallet you created on the previous step to recover existing priv_validator_key instead of creating. 
If you do an `init` without this flag and lose the priv_validator_key.json file, you will never get access to the validator.
#### Download the genesis file
```
curl https://devnet.rpc.agoric.net/genesis | jq .result.genesis > $HOME/.agoric/config/genesis.json 
agd unsafe-reset-all
```
#### Adjust configuration
```
peers=$(jq '.peers | join(",")' < chain.json)
seeds=$(jq '.seeds | join(",")' < chain.json)
echo $peers
echo $seeds
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml
```
### Syncing Your Node
Create a service file
```
sudo tee <<EOF >/dev/null /etc/systemd/system/agd.service
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
# OPTIONAL: turn on JS debugging information.
#SLOGFILE=.agoric/data/chain.slog
User=$USER
# OPTIONAL: turn on Cosmos nondeterminism debugging information
#ExecStart=$HOME/go/bin/agd start --log_level=info --trace-store=.agoric/data/kvstore.trace
ExecStart=$HOME/go/bin/agd start --log_level=warn
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Check the contents of the file, especially User, Environment and ExecStart lines
cat /etc/systemd/system/agd.service
```
To start syncing:
```
sudo systemctl enable agd
sudo systemctl daemon-reload
sudo systemctl restart agd
```
Logs and status
```
echo 'Node status:'$(sudo service agd status | grep active)
journalctl -u agd -f --output cat

agd status | jq .SyncInfo
curl localhost:26657/status | jq
```
#### Tap the Faucet
Request tokens in the [Agoric Discord server #faucet](https://discord.gg/9nKvca)
```
!faucet delegate agoric1...
```
#### Check your balance
```
agd query bank balances `agd keys show -a $AGORIC_WALLET`
```
### Create-validator transaction
```
agd tx staking create-validator \
  --amount=50000000ubld \
  --broadcast-mode=block \
  --pubkey=$(agd tendermint show-validator) \
  --moniker=<your-node-name> \
  --from=<your-key-name> \
  --website=<your-node-website> \
  --details=<your-node-details> \
  --identity=<your-node-identity> \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --chain-id=$chainName \
  --gas=auto \
  --gas-adjustment=1.4
```
Status
```
agd status | jq .ValidatorInfo
```
# Upgrade to agoricdev-13
Stop service file
```
sudo systemctl stop agd
```
Reset all chain data from agoricdev-11 chain
```
agd unsafe-reset-all
```
Update Agoric-SDK
```
rm -rf /usr/src/agoric-sdk
cd /usr/src/
git clone https://github.com/Agoric/agoric-sdk -b agoricdev-13
cd agoric-sdk
yarn install
yarn build
(cd packages/cosmic-swingset && make)
agd version --long
cp /root/go/bin/agd /usr/bin
```
Download chain.json and update chainName to agoricdev-13
```
curl https://devnet.agoric.net/network-config > chain.json
chainName=`jq -r .chainName < chain.json`
echo $chainName
echo 'export chainName='\"${chainName}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
Download genesis file
```
curl https://devnet.rpc.agoric.net/genesis | jq .result.genesis > $HOME/.agoric/config/genesis.json 
```
Update seeds into a config.toml
```
seeds=$(jq '.seeds | join(",")' < chain.json)
echo $seeds
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = ""/" $HOME/.agoric/config/config.toml
```
Restart
```
sudo systemctl restart agd
journalctl -u agd -f --output cat
```
Get some tokens
Faucet is [here](https://discord.com/channels/585576150827532298/767231925646524446)

Wait for sync and then create the validator
```
agd tx staking create-validator \
  --amount=50000000ubld \
  --broadcast-mode=block \
  --pubkey=$(agd tendermint show-validator) \
  --moniker=<your-node-name> \
  --from=<your-key-name> \
  --website=<your-node-website> \
  --details=<your-node-details> \
  --identity=<your-node-identity> \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --chain-id=$chainName \
  --gas=auto \
  --gas-adjustment=1.4
```
