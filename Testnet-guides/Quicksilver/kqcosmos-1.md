## Chain: `kqcosmos-1`
- Off link is [here](https://github.com/ingenuity-build/testnets/tree/main/killerqueen/kqcosmos-1)
- [Explorer](https://testnet.explorer.testnet.run/kqcosmos-1)
# Instructions
#### Update the packeges
```
sudo apt update && sudo apt upgrade -y
```
#### Install what we need
```
sudo apt-get install make git jq curl gcc g++ mc nano -y
```
#### Install GO
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
```
#### Install **interchain**
```
git clone https://github.com/ingenuity-build/interchain-accounts --branch main
cd interchain-accounts
make install
cp $HOME/go/bin/icad /usr/local/bin
```
#### Add variables
In the commands add your names for:
- `<Your_Moniker>`
- `<Your_Wallet_Name>`
```
icad_MONIKER=<Your_Moniker>
icad_WALLET=<Your_Wallet_Name>
icad_chain=kqcosmos-1
echo 'export icad_MONIKER='\"${icad_MONIKER}\" >> $HOME/.bash_profile
echo 'export icad_WALLET='\"${icad_WALLET}\" >> $HOME/.bash_profile
echo 'export icad_chain='\"${icad_chain}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
Init icad
```
icad init $icad_MONIKER --chain-id $icad_chain
```
Include seeds in `config.toml`. By one command
```
SEEDS="66b0c16486bcc7591f2c3f0e5164d376d06ee0d0@65.108.203.151:26656" ; \
sed -i -e "/seeds =/ s/= .*/= \"$SEEDS\"/"  $HOME/.ica/config/config.toml
```
Download genesis
```
GENESIS_URL="https://raw.githubusercontent.com/ingenuity-build/testnets/main/killerqueen/kqcosmos-1/genesis.json" ; \
ICA_HOME=$HOME/.ica ; \
curl -sSL $GENESIS_URL > $ICA_HOME/config/genesis.json
```
Recover wallet created for killerquin-1. Type your saved seed phease.
```
icad keys add $icad_WALLET --recover
```

#### Pruning settings
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ica/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ica/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ica/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ica/config/app.toml
```
#### Comment out the line `log_level=info`
```
sed -i.bak 's/^log_level/# log_level/' $HOME/.ica/config/config.toml
```
### Сreate a service file
```
sudo tee <<EOF >/dev/null /etc/systemd/system/icad.service
[Unit]
Description=ICA Cosmos daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which icad) start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
## Start the service to synchronize from first block
```
sudo systemctl enable icad
sudo systemctl daemon-reload
sudo systemctl restart icad
sudo systemctl status icad
```
### Logs and status
Logs
```
journalctl -u icad -f --output cat
```
Status of sinchronization
```
icad status 2>&1 | jq .SyncInfo
```
If you want to know your node_id.
```
curl localhost:26657/status | jq '.result.node_info.id'
```
#### Get tokens
Atoms can be claimed from the `#atom-tap` channel. The tap gives 25 Atoms.
```
$request cosmos1........ killerqueen
```
### Create the validator
Your node sould be synced. Make shure:
```
icad status 2>&1 | jq .SyncInfo
```
If node is synced - create a validator
```
icad tx staking create-validator \
  --amount 24000000uatom \
  --from $icad_WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.059" \
  --min-self-delegation "1" \
  --pubkey $(icad tendermint show-validator) \
  --details="" \
  --website="" \
  --identity="" \
  --moniker $icad_MONIKER \
  --chain-id $icad_chain
```

# Commands
Find out your wallet
```
icad keys show $icad_WALLET -a
```
Find out your validator
```
icad keys show $icad_WALLET --bech val -a
```
Find out information about your validator
```
icad query staking validator $(icad keys show $icad_WALLET --bech val -a)
```
## More about wallets delegations and rewards
To see how many tokens are in your wallet:
```
icad q bank balances $(icad keys show $icad_WALLET -a)
```
Withdraw all rewards
```
icad tx distribution withdraw-all-rewards --node "tcp://127.0.0.1:26657" --from=$icad_WALLET --chain-id=$icad_chain --gas=auto
```
Self delegation
```
icad tx staking delegate --node "tcp://127.0.0.1:26657" $(icad keys show $icad_WALLET --bech val -a) <amount_to_delegate>uatom \
--chain-id=$icad_chain \
--from=$icad_WALLET \
--gas=auto
```
