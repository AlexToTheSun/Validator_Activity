# References
- [Official github documentation](https://github.com/confio/tgrade-networks#upgrade-to-a-validator-after-genesis---phase-3)
- Ecplorers: [Aneka](https://tgrade.aneka.io/), [Mintscan](https://www.mintscan.io/tgrade/)
# Actual Chain Information
- Chain_id `tgrade-mainnet-1`
- tgrade version: [`v1.0.1`](https://github.com/confio/tgrade/releases/tag/v1.0.1)
- Denom: `utgd`
- Min Fee: `0.05utgd`
- [Genesis file](https://github.com/confio/tgrade-networks/blob/main/mainnet-1/config/genesis.json)
- go version: `1.18.3`

# Install Tgrade Node
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
### Setting up config files
Seend and peers
```
SEEDS="0c3b7d5a4253216de01b8642261d4e1e76aee9d8@45.76.202.195:26656,8639bc931d5721a64afc1ea52ca63ae40161bd26@194.163.144.63:26656"
PEERS="0a63421f67d02e7fb823ea6d6ceb8acf758df24d@142.132.226.137:26656,4a319eead699418e974e8eed47c2de6332c3f825@167.235.255.9:26656,6918efd409684d64694cac485dbcc27dfeea4f38@49.12.240.203:26656,24c587b6c533e391ca5e4b78334ddac4a339d371@139.59.250.37:26656,5d40836ad95efe9a9671265949141f4ef896f1de@5.161.99.107:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.tgrade/config/config.toml
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
Start
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




