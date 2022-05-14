## Install the validator node
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
curl https://deb.nodesource.com/setup_16.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt install nodejs=16.* -y  yarn build-essential jq -y --fix-missing
```
**Install the latest version of Agoric** to sync with State Sync. In this case, you need to skip the first versions of the assembly.
All releases can be viewed here: [Releases](https://github.com/Agoric/ag0/releases)
```
rm -rf /root/ag0
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-5
git pull origin agoric-upgrade-5
make build
. $HOME/.bash_profile
cp $HOME/ag0/build/ag0 /usr/local/bin
ag0 version
```
**Let's add variables.**
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
AGORIC_NODENAME=<YOUR_MONIKER>
AGORIC_WALLET=<YOUR_WALLET>
chainName=agoric-3

echo 'export AGORIC_NODENAME='\"${AGORIC_NODENAME}\" >> $HOME/.bash_profile
echo 'export AGORIC_WALLET='\"${AGORIC_WALLET}\" >> $HOME/.bash_profile
echo 'export chainName='\"${chainName}\" >> $HOME/.bash_profile

source $HOME/.bash_profile
echo $AGORIC_NODENAME $AGORIC_WALLET $chainName
```
**Make init of Agoric**
```
ag0 init --chain-id $chainName $AGORIC_NODENAME
```
**Download `genesis.json`**
```
curl https://main.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json
```
**Download `chain.json`** which contains information that we will soon enter into the config. files
```
curl https://main.agoric.net/network-config > chain.json
```
**If you don't** add `chain_id` then you should
```
chainName=`jq -r .chainName < chain.json`
echo $chainName
. $HOME/.bash_profile
```
**Change `config.toml`** by information from `chain.json`
- Add peers, seeds. 
```
peers=$(jq '.peers | join(",")' < chain.json)
seeds=$(jq '.seeds | join(",")' < chain.json)
echo $peers
echo $seeds
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml
```
**Change `config.toml`**
- Comment out the line `log_level = info` for a more convenient change of the log mode from the service file.
- Set `minimum-gas-prices`. Since rewards are not enabled yet, we will set it to `0`. But soon this parameter will need to be changed to, for example, `0.025ubld`
- Telemetry
```
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025ubld\"/;" $HOME/.agoric/config/app.toml
sed -i '/\[telemetry\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.agoric/config/app.toml
sed -i "s/prometheus-retention-time = 0/prometheus-retention-time = 60/g" $HOME/.agoric/config/app.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.agoric/config/config.toml
```
**Change `config.toml` and `app.toml` for disk usage optimization**
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.agoric/config/config.toml
sudo rm ~/.agoric/data/tx_index.db/*
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.agoric/config/app.toml
```
More about that you could find [here](https://surftest.gitbook.io/axelar-wiki/english/disk-usage-optimisation)

**Change `config.toml` to sync with a State sync snapshot**
Insert data into variables
```
SNAP_RPC="http://154.12.241.178:26657" ; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height) ; \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)) ; \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash) ; \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Now paste `$SNAP_RPC`, `$BLOCK_HEIGHT` and `$TRUST_HASH` values into the `config.toml`. And also set `enable=true`. All by one command
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.agoric/config/config.toml
```
For faster loading, enter the RPC node data in the config file, in the `persistent_peers` section:
`9373c1dbf0a040d2c76b120f8472871b92852f62@154.12.241.178:26656`
**Create service file** for Agoric
```
sudo tee <<EOF >/dev/null /etc/systemd/system/agoricd.service
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ag0) start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
## DDoS protection (Sentry Node Architecture)
!! Everything is ready to launch. But note that when you run the service file in this configuration, after synchronization, information about your node will be available on the Agoric public network. This exposes your validator to DDoS attacks.
If you want to secure a node with a validator, then before starting, click [[here]](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet%20Guides/Agoric/Sentry%20Node%20architecture.md) and configure Agoric Sentry Node Architecture.
If you **decide not to protect** the server from DDoS attacks (**which is a security issue for the protocol**) then follow the instructions below.
## Start synchronization
```
sudo systemctl enable agoricd
sudo systemctl daemon-reload
sudo systemctl restart agoricd
sudo systemctl status agoricd
```
See logs and status
```
echo 'Node status:'$(sudo service agoricd status | grep active)
journalctl -u agoricd -f --output cat

ag0 status 2>&1 | jq .SyncInfo
curl localhost:26657/status | jq
```
## Create the validator
First of all create a wallet. If you want to recover it then add `--recover` flag
```
ag0 keys add $AGORIC_WALLET
```
- Write down the mnemonic phrase in a safe place
- Set a keying password. It is a local defense. The password applies to all wallets on the server.
**Top up your wallet balance**
Transfer to the wallet balance some $BLD, on the basis of this wallet you will soon create your validator.
### Tx of creating the validator
If your node is fully synchronized, then run the tx to upgrade to validator status:
```
ag0 tx staking create-validator \
  --amount=<your_amount>ubld \
  --broadcast-mode=block \
  --pubkey=`ag0 tendermint show-validator` \
  --moniker=$AGORIC_NODENAME \
  --details="" \
  --identity="" \
  --commission-rate="0.05" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --from=$AGORIC_WALLET \
  --chain-id=$chainName \
  --gas=auto \
  --website="" \
  --gas-adjustment=1.4
```
- `<your_amount>` - specify the number of tokens that you want to delegate to your validator
- 1 bld = 1000000 ubld
- If you want to add identity then create an account here https://keybase.io/
- Also you could add details and website flag.
Greate. You could find your validator here https://main.explorer.agoric.net/validators
## tmkms
It is **highly recommended** to protect your validator from double-signing case.
[Official documentation](https://github.com/iqlusioninc/tmkms)
This could prevent the Double-signing even in the event the validator process is compromised.
Click [[here](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet%20Guides/Agoric/tmkms_Soft-sign_(needs_2_servers).md)] the guide of Installing tmkms on an additional server that will serve as protection.