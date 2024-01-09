# Table of contents
1. [Update to `v1.3.1`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IRISnet/Upgrade.md#upgrade-v131)
2. [Update to `v2.0.0`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IRISnet/Upgrade.md#upgrade-v200) [auto]
3. [Update to `v2.0.2`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IRISnet/Upgrade.md#upgrade-v202)
4. [Update to `v2.1.0`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IRISnet/Upgrade.md#upgrade-v210)

### Official IrisNet github: https://github.com/irisnet/mainnet/tree/master/upgrade

## Upgrade `v1.3.1`
- [[Current Release v1.3.1](https://github.com/irisnet/irishub/releases/tag/v1.3.1)]

As we downloaded `https://github.com/irisnet/irishub` before, let's update the repository and build the new binary
```
cd irishub
git fetch --all --tags
git checkout tags/v1.3.1
git pull origin v1.3.1
make clean
VERSION=v1.3.1 make install
$HOME/go/bin/iris version
```
Chack sha256sum
```
sha256sum $HOME/go/bin/iris
# faebb0f4fcdde86aebb54ad777f028c1acb04edaa99a9ca351554ee2e81dc76e  /root/go/bin/iris
```
Now stop the service
```
sudo systemctl stop irisd
```
Change binary
```
cp $HOME/go/bin/iris /usr/local/bin
iris version
```
#Or you can just download the binary:
```
mkdir /root/iris-new
cd /root/iris-new
wget https://github.com/irisnet/irishub/releases/download/v1.3.1/iris-linux-arm64-v1.3.1.tar.gz | tar xf -
tar -xvf iris-linux-arm64-v1.3.1.tar.gz
mv /root/iris-new/build/iris-linux-arm64 /root/iris-new/build/iris
chmod +x /root/iris-new/build/iris
cp /root/iris-new/build/iris /usr/local/bin
iris version
```
Start
```
sudo systemctl start irisd
iris status 2>&1 | jq .SyncInfo
journalctl -u irisd -f --output cat
```

## Upgrade `v2.0.0`

- [Link v2.0.0](https://github.com/irisnet/mainnet/blob/master/upgrade/v2.0.0.md)
- Height: [19514010](https://www.mintscan.io/iris/blocks/19514010)

### Upgrade `app.toml`
⚠️ This upgrade involves configuration modification, and the following configuration needs to be added to `app.toml`. 

Run the command below:
```
sudo tee -a $HOME/.iris/config/app.toml  >/dev/null <<'EOF'

###############################################################################
### EVM Configuration ###
###############################################################################

[evm]

# Tracer defines the 'vm.Tracer' type that the EVM will use when the node is run in
# debug mode. To enable tracing use the '--evm.tracer' flag when starting your node.
# Valid types are: json|struct|access_list|markdown
tracer = ""

# MaxTxGasWanted defines the gas wanted for each eth tx returned in ante handler in check tx mode.
# defualt = 0
max-tx-gas-wanted = 40000000

###############################################################################
### JSON RPC Configuration ###
###############################################################################

[json-rpc]

# Enable defines if the gRPC server should be enabled.
enable = true

# Address defines the EVM RPC HTTP server address to bind to.
# If you want to expose it externally, change it to: address = "0.0.0.0:8545"
address = "127.0.0.1:8545"

# Address defines the EVM WebSocket server address to bind to.
# If you want to expose it externally, change it to: address = "0.0.0.0:8546"
ws-address = "127.0.0.1:8546"

# API defines a list of JSON-RPC namespaces that should be enabled
# Example: "eth,txpool,personal,net,debug,web3"
api = "eth,net,web3"

# GasCap sets a cap on gas that can be used in eth_call/estimateGas (0=infinite). Default: 25,000,000.
gas-cap = 40000000

# EVMTimeout is the global timeout for eth_call. Default: 5s.
evm-timeout = "5s"

# TxFeeCap is the global tx-fee cap for send transaction. Default: 1eth.
txfee-cap = 1

# FilterCap sets the global cap for total number of filters that can be created
filter-cap = 200

# FeeHistoryCap sets the global cap for total number of blocks that can be fetched
feehistory-cap = 100

# LogsCap defines the max number of results can be returned from single 'eth_getLogs' query.
logs-cap = 10000

# BlockRangeCap defines the max block range allowed for 'eth_getLogs' query.
block-range-cap = 10000

# HTTPTimeout is the read/write timeout of http json-rpc server.
http-timeout = "30s"

# HTTPIdleTimeout is the idle timeout of http json-rpc server.
http-idle-timeout = "2m0s"

# AllowUnprotectedTxs restricts unprotected (non EIP155 signed) transactions to be submitted via
# the node's RPC when the global parameter is disabled.
allow-unprotected-txs = false

# MaxOpenConnections sets the maximum number of simultaneous connections
# for the server listener.
max-open-connections = 0

# EnableIndexer enables the custom transaction indexer for the EVM (ethereum transactions).
enable-indexer = false

# MetricsAddress defines the EVM Metrics server address to bind to. Pass --metrics in CLI to enable
# Prometheus metrics path: /debug/metrics/prometheus
metrics-address = "0.0.0.0:6065"

###############################################################################
### TLS Configuration ###
###############################################################################

[tls]

# Certificate path defines the cert.pem file path for the TLS configuration.
certificate-path = ""

# Key path defines the key.pem file path for the TLS configuration.
key-path = ""
EOF
```


### Auto update-restart script

For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Build new binary:
```bash
cd $HOME/irishub
git fetch --all
git checkout v2.0.0
make install
# Check old binary
iris version --long | head
# echo $(which iris) && $(which iris) version
# Check new binary
$HOME/go/bin/iris version --long | head
    #version: v2.0.0
    #commit: 3f885283746f6f5515ba31a06bd4801fa155937b
```
Set variables:
- `your_rpc_port`
```
current_binary="/usr/local/bin/iris"
new_binary="$HOME/go/bin/iris"
halt_height="19514010"
service_name="irisd"
rpc_port="your_rpc_port"
```
Check output:
```
echo $current_binary \
&& $new_binary version \
&& curl -s localhost:$rpc_port/status | jq | grep -E 'network|latest_block_height' \
&& service $service_name status | grep -E 'loaded|active'
```
Output example:
```
/usr/local/bin/iris
2.0.0
      "network": "irishub-1",
      "latest_block_height": "19507740",
     Loaded: loaded (/etc/systemd/system/irisd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2023-04-16 17:52:01 UTC; 1h 9min ago
```

Create update script:
```
tee $HOME/update_script.sh > /dev/null << EOF
#!/bin/bash
for((;;)); do
  height=\$(curl -s localhost:${rpc_port}/status | jq -r .result.sync_info.latest_block_height)
    if ((height==${halt_height})); then
      systemctl stop ${service_name}
      cp ${new_binary} ${current_binary}
      systemctl restart ${service_name}
      echo restart
      break
    else
      echo \$height
    fi
  sleep 3
done
EOF
```
Make the script executable:
```
chmod +x $HOME/update_script.sh 
```

Create tmux session:
```
tmux new -s update
```

Run script in tmux
```
sudo /bin/bash $HOME/update_script.sh
```
If you want to use the EVM function, you need to open the JRPC access endpoint of the EVM on the node.  See more: https://github.com/irisnet/mainnet/blob/master/upgrade/v2.0.0.md

### tmux command
Detach from "update" session type `Ctrl+b d` (the session will continue to run in the background): 

List of sessions
```
tmux ls
```
Connect to the session again
```
tmux attach -t update
```

> ! Don't stop the script by CTRL+C 
### After updating - kill tmux session:
```
tmux kill-session -t update
```
Logs and status:
```
sudo journalctl -u irisd -f -o cat
iris status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
- use your uwn rpc port instead `26657`
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```

## Upgrade `v2.0.2`

- [Link v2.0.2](https://github.com/irisnet/irishub/releases/tag/v2.0.2)

### Upgrade
```
# Build
cd $HOME
rm -rf /root/irishub
git clone https://github.com/irisnet/irishub
cd $HOME/irishub
git checkout v2.0.2
make install
# Check
iris version --long | head
$HOME/go/bin/iris version --long | head

# Update
sudo systemctl stop irisd
cp $HOME/go/bin/iris /usr/local/bin
sudo systemctl restart irisd
```
Logs and status:
```
sudo journalctl -u irisd -f -o cat
iris status 2>&1 | jq .SyncInfo
```
## Upgrade `v2.1.0`
- official link https://github.com/irisnet/mainnet/blob/master/upgrade/v2.1.0.md
- Explorer https://www.mintscan.io/iris
- Snapshot https://imperator.co/services/iris
- Exapmle snap https://app.nodejumper.io/archway/sync
### Create `upgrade-info.json`
As it said in [Discord](https://discord.com/channels/806356514973548614/807902950826835968/1193760689249058846) we should create a file `upgrade-info.json` if it doesn't exist
```
IRIS_HOME="/root/.iris"
echo $IRIS_HOME
echo '{"name":"v2.0","time":"0001-01-01T00:00:00Z","height":19514010}' > $IRIS_HOME/data/upgrade-info.json
cd $IRIS_HOME/data && mc
```
#### Upgrade Go to 1.19
```
wget -O go1.19.4.linux-amd64.tar.gz https://go.dev/dl/go1.19.4.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.4.linux-amd64.tar.gz && rm go1.19.4.linux-amd64.tar.gz
cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
# go version go1.19.4 linux/amd64
```
Upgrade binary file
```
git clone https://github.com/irisnet/irishub
cd irishub && git checkout v2.1.0
make install
# Check
iris version --long | head
$HOME/go/bin/iris version --long | head

# Update
sudo systemctl stop irisd
cp $HOME/go/bin/iris /usr/local/bin
```

Use [snapshot](https://imperator.co/services/iris)
```
cd
sudo systemctl stop irisd

iris tendermint unsafe-reset-all --home $HOME/.iris --keep-addr-book
curl https://s3.imperator.co/mainnets-snapshots/iris/iris_23174317.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.iris

sudo systemctl restart irisd
sudo journalctl -u irisd -f --no-hostname -o cat
```

Logs and status:
```
sudo journalctl -u irisd -f -o cat
iris status 2>&1 | jq .SyncInfo
```
Unjail
```
# to see vars go to /root/.bash_profile
iris tx slashing unjail --from=TuretskiyW --chain-id=irishub-1 --gas-prices 0.05uiris
```

