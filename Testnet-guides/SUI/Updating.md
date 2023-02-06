## Upgrading
### Peers
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
EOF
```
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
sudo systemctl stop suid
cd $HOME/sui
git fetch upstream
git checkout -B testnet --track upstream/testnet
git log --oneline -1

cargo build --release --bin sui-node
mv ~/sui/target/release/sui-node /usr/local/bin/
sui-node -V

sudo systemctl restart suid
sudo journalctl -u suid -f -o cat
```


### Check your node
 Check the node version
```
curl --silent http://127.0.0.1:9184/metrics | grep "uptime{version"
```
Check txs on your node
```
curl --location --request POST http://127.0.0.1:9000/ \
--header 'Content-Type: application/json' \
--data-raw '{ "jsonrpc":"2.0", "method":"sui_getTotalTransactionNumber","id":1}'; echo
```
Check txs on RPC node
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
#### Check checkpoints
```sh
# On RPC
curl --location --request POST 'https://fullnode.testnet.sui.io:443/' --header 'Content-Type: application/json' --data-raw '{"jsonrpc":"2.0", "id":1,"method":"sui_getLatestCheckpointSequenceNumber"}'; echo

# On your node
curl -q localhost:9184/metrics 2>/dev/null |grep '^highest_synced_checkpoint'
```

# How to remove DB (if you have trouble with fork blocks)
```
2023-02-05T12:05:43.216223Z  INFO sui_node: SuiNode started!
2023-02-05T12:05:43.245323Z ERROR typed_store::rocks: error=rocksdb error: Corruption: block checksum mismatch: stored = 453905640, computed = 3420653554, type = 1  in /var/sui/suidb/store/perpetual/019862.sst offset 54291452 size 3114
2023-02-05T12:05:43.245341Z ERROR telemetry_subscribers: panicked at 'store operation should not fail: RocksDBError("Corruption: block checksum mismatch: stored = 453905640, computed = 3420653554, type = 1  in /var/sui/suidb/store/perpetual/019862.sst offset 54291452 size 3114")', /root/sui/crates/sui-network/src/state_sync/mod.rs:1065:14 panic.file="/root/sui/crates/sui-network/src/state_sync/mod.rs" panic.line=1065 panic.column=14
thread 'tokio-runtime-worker' panicked at 'store operation should not fail: RocksDBError("Corruption: block checksum mismatch: stored = 453905640, computed = 3420653554, type = 1  in /var/sui/suidb/store/perpetual/019862.sst offset 54291452 size 3114")', /root/sui/crates/sui-network/src/state_sync/mod.rs:1065:14
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
suid.service: Main process exited, code=killed, status=6/ABRT
suid.service: Failed with result 'signal'.
suid.service: Scheduled restart job, restart counter is at 4.
Stopped Sui Node.
Started Sui Node.
```
I suspect that the problem with such logs may be that some fullnodes can broadcast data that went into the fork. I propose to take full nodes from the letter
```
sudo systemctl stop suid
cd $HOME && rm -rf $HOME/.sui/db/*
```
Add peers (instead of `- address: ""` there should be `- address: "/dns/<dns name>/udp/<port>"`)
```
sudo tee -a $HOME/.sui/fullnode.yaml  >/dev/null <<EOF

p2p-config:
  seed-peers:
    - address: ""

EOF
```
Restart
```
sudo systemctl restart suid
journalctl -u suid -f
```

**Explorers and checkers:** 
  - https://www.scale3labs.com/check/sui
  - https://sui.explorers.guru/node
  - https://node.sui.zvalid.com/
