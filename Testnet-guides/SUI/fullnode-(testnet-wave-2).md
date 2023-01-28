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
sudo apt-get install -y --no-install-recommends tzdata ca-certificates build-essential libssl-dev libclang-dev pkg-config openssl protobuf-compiler cmake
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
Build SUI binaries
```
cargo build --release
mv ~/sui/target/release/sui-node /usr/local/bin/
mv ~/sui/target/release/sui /usr/local/bin/
sui-node -V
sui -V
```
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
WantedBy=multi-user.target" > $HOME/suid.service

mv $HOME/suid.service /etc/systemd/system/

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



