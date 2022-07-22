#### Chain: `agoricollinet-11`
- **instructions:** https://github.com/Agoric/ag0/blob/Agoric-upgrade-6/agoric-upgrade-6.md
- **testnet links:** https://ollinet.agoric.net/
- **release:** https://github.com/Agoric/ag0/releases/tag/agoric-upgrade-6
- **explorer:** https://ollinet.explorer.agoric.net
- **faucet:** https://ollinet.faucet.agoric.net

```
# Install the required packages
sudo apt update && sudo apt upgrade -y
sudo apt-get install nano mc git gcc g++ make curl yarn -y

# Install Go
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

# Install Nodejs
curl https://deb.nodesource.com/setup_14.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt install nodejs=14.* yarn build-essential jq -y

# Install Agoric
cd ~
rm -r ag0
git clone https://github.com/Agoric/ag0 -b agoric-upgrade-5
cd ag0
make build
cp /root/ag0/build/ag0 /usr/local/bin
ag0 version --long

# Download file with Network Configs
mkdir $HOME/agoric
curl https://ollinet.agoric.net/network-config > $HOME/agoric/chain.json

# Variables
AG_Moniker=<YOUR_MONIKER>
AG_Wallet=<YOUR_WALLET>
AG_Chain=$(jq -r .chainName < $HOME/agoric/chain.json)
echo 'export AG_Moniker='\"${AG_Moniker}\" >> $HOME/.bash_profile
echo 'export AG_Wallet='\"${AG_Wallet}\" >> $HOME/.bash_profile
echo 'export AG_Chain='\"${AG_Chain}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $AG_Moniker $AG_Wallet $AG_Chain

# Creating a wallet and init
ag0 keys add $AG_Wallet
ag0 init $AG_Moniker --chain-id $AG_Chain

#Configure your node
# download genesis.json
curl "https://ollinet.rpc.agoric.net/genesis" | jq .result.genesis > ~/.agoric/config/genesis.json
# write peers to the config file
peers="fb86a0993c694c981a28fa1ebd1fd692f345348b@35.226.232.179:26656,f30a36fe5f5048a482d83c3bb873e1c64aa617aa@35.226.248.0:26656,686de39b047e38db41b42cf676eb68335d81fca7@139.59.146.53:27656,09c077f40c2384b64a5d7800a539d12a300e16d1@95.216.208.150:29656"
seeds=$(jq '.seeds | join(",")' < $HOME/agoric/chain.json)
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml

sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.agoric/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ubld\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.agoric/config/config.toml

# Service file
tee /etc/systemd/system/ag0.service > /dev/null <<EOF
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

# Srart sync from the forst block
ag0 unsafe-reset-all
sudo systemctl daemon-reload
sudo systemctl enable ag0
sudo systemctl restart ag0

#Logs
ag0 status 2>&1 | jq
ag0 status 2>&1 | jq .SyncInfo
sudo journalctl -u ag0 -f -o cat
journalctl -u ag0 -f --output cat


# Upgrade when needed
sudo systemctl stop ag0
cd ~
rm -r ag0
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-6
make build
cp /root/ag0/build/ag0 /usr/local/bin
ag0 version --long
sudo systemctl restart ag0
journalctl -u ag0 -f --output cat
```
After syncing you could create validator:
```
# Get tokens from https://ollinet.faucet.agoric.net to your wallet. It will give you 75BLD 
# Now create the validator
ag0 tx staking create-validator --node "tcp://127.0.0.1:26657" \
  --amount=<amount>ubld \
  --broadcast-mode=block \
  --pubkey=$(ag0 tendermint show-validator) \
  --moniker=$AG_Moniker \
  --website="" \
  --details="" \
  --identity="" \
  --commission-rate="0.05" \
  --commission-max-rate="0.10" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --from=$AG_Wallet \
  --chain-id=$AG_Chain
```

There are discussions about upgrade here [[commonwealth - update-2-root-cause](https://commonwealth.im/agoric/discussion/6256-update-2-root-cause-identified-for-node-restart-issues-next-steps-for-improving-network-stability-etc)] 



