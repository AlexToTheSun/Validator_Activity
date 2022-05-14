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
Set up RPC server with snapshots and register it here














