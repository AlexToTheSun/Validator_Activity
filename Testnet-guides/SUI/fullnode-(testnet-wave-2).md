#### Official links
- Docs for Fullnode: https://docs.sui.io/build/fullnode
- Docs Sui Testnet Wave 2: https://sui.io/resources-sui/testnet-wave-2-is-now-live/
- Github: https://github.com/MystenLabs/sui
- Fauset: https://testedge2.haqq.network/

Explorers and checkers: 
  - https://www.scale3labs.com/check/sui
  - https://sui.explorers.guru/node
  - https://node.sui.zvalid.com/

## System Requirements for `full node`
- 10 CPU
- 32 GB ram
- 1 TB SSD

## SUI fullnode installation
 Update & upgrade
```
sudo apt update && sudo apt upgrade -y
```
Install the required packages
```
sudo apt-get install -y --no-install-recommends tzdata ca-certificates build-essential libssl-dev libclang-dev pkg-config openssl protobuf-compiler cmake nano mc git gcc g++ make curl build-essential tmux chrony wget jq yarn
```
 Install Rust
 ```
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustc --version
```
### Install the latest version of SUI
All releases can be viewed [here](https://github.com/MystenLabs/sui/tags)
```
cd $HOME 
rm -rf /root/sui
git clone https://github.com/MystenLabs/sui.git
cd $HOME/sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout -B testnet --track upstream/testnet
```
Then we should create directory for SUI db and genesis
```
mkdir $HOME/.sui
```
Download `genesis.blob`
```
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/testnet/genesis.blob
```
Copy of fullnode.yaml and update path to db and genesis file in it
```
cp $HOME/sui/crates/sui-config/data/fullnode-template.yaml $HOME/.sui/fullnode.yaml
sed -i.bak "s|db-path:.*|db-path: \"$HOME\/.sui\/db\"| ; s|genesis-file-location:.*|genesis-file-location: \"$HOME\/.sui\/genesis.blob\"| ; s|127.0.0.1|0.0.0.0|" $HOME/.sui/fullnode.yaml
```
Add peers
```
sudo tee -a $HOME/.sui/fullnode.yaml  >/dev/null <<EOF

p2p-config:
  seed-peers:
   - address: "/ip4/65.109.32.171/udp/8084"
   - address: "/ip4/65.108.44.149/udp/8084"
   - address: "/ip4/95.214.54.28/udp/8080"
   - address: "/ip4/136.243.40.38/udp/8080"
   - address: "/ip4/84.46.255.11/udp/8084"
   - address: "/ip4/135.181.6.243/udp/8088"

EOF
```


Build SUI binaries
```
cargo build --release --bin sui-node
mv $HOME/sui/target/release/sui-node /usr/local/bin/
sui-node -V
```
In the config file `$HOME/.sui/sui-config/client.yaml` there is a DevNet RPC `rpc: "https://gateway.devnet.sui.io:443"`. You can change it manually on `rpc: "https://fullnode.testnet.sui.io:443"` OR run the command:
```
sui client switch --env https://fullnode.testnet.sui.io:443
```
### THE LIST OF PUBLIC SUI RPC TESTNET SERVERS
-  https://sui-api.rpcpool.com/
-  https://sui-testnet.public.blastapi.io/
-  https://rpc.ankr.com/sui_testnet
-  https://fullnode.testnet.vincagame.com/
  
### Create service file for SUI
```
echo "[Unit]
Description=Sui Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/sui-node --config-path $HOME/.sui/fullnode.yaml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/suid.service
```
```
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
```
### Start synchronization
```
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl restart suid
```
Logs and status
```
sudo journalctl -u suid -f -o cat
```
### Useful Commands
Check the node version
```
curl --silent http://127.0.0.1:9184/metrics | grep "uptime{version"
```
Check the last block on your node
```
curl --location --request POST http://127.0.0.1:9000/ \
--header 'Content-Type: application/json' \
--data-raw '{ "jsonrpc":"2.0", "method":"sui_getTotalTransactionNumber","id":1}'; echo
```
Check the last block on RPC node
```
curl --location --request POST https://fullnode.testnet.sui.io:443 \
--header 'Content-Type: application/json' \
--data-raw '{ "jsonrpc":"2.0", "method":"sui_getTotalTransactionNumber","id":1}'; echo
```
Check TPS on your node in Testnet:
```sh
wget -O $HOME/check_testnet_tps.sh https://raw.githubusercontent.com/bartosian/sui_helpers/main/check_testnet_tps.sh && chmod +x $HOME/check_testnet_tps.sh && $HOME/check_testnet_tps.sh

# to run it again:
$HOME/check_testnet_tps.sh
```


