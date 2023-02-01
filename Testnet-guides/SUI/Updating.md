## Upgrading
Open tmux session
```sh
tmux new -s update

# Usefull commands
# List of sessions
tmux ls
# Connect to the session again
tmux attach -t update
```
Update binary
```
cd $HOME/sui
git fetch upstream
git checkout -B testnet --track upstream/testnet
git log --oneline -1

cargo build --release --bin sui-node
mv ~/sui/target/release/sui-node /usr/local/bin/
sui-node -V

sudo systemctl restart suid
journalctl -u suid -f
```
### Check your node
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
**Explorers and checkers:** 
  - https://www.scale3labs.com/check/sui
  - https://sui.explorers.guru/node
  - https://node.sui.zvalid.com/
