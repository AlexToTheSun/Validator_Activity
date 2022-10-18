#### Gravity Bridge GitHub is [here]([https://github.com/OllO-Station](https://github.com/Gravity-Bridge))
#### [Installation Instructions](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Gravity-Bridge)
#### Explorers [Turetskiy](https://explorer-turetskiy.xyz/gravity-bridge), [Mintscan](https://www.mintscan.io/gravity-bridge)

## Info
- Public RPC enpoint: http://185.16.39.3:18657
- Public API: http://185.16.39.3:18317
- Chain: `gravity-bridge-3`
- Snapshot-keep-recent: `2000`

## Gravity Bridge Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="2b2548493c4653d9c4388e9cd24b670a3cfbd564@185.16.39.3:18656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.gravity/config/config.toml
```
Add variables
```
SNAP_RPC="http://185.16.39.3:18657"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Now enter all the datat to `config.toml`
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.gravity/config/config.toml
```
#### In first time make a backup of `node_key.json` and `priv_validator_key.json` before unsafe-reset-all
```
cp $HOME/.gravity/config/priv_validator_key.json $HOME/.gravity/priv_validator_key.json.backup && \
cp $HOME/.gravity/config/node_key.json $HOME/.gravity/node_key.json.backup
```
Restart the `gravity-node.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop gravity-node && \
gravity tendermint unsafe-reset-all --home ~/.gravity && \
sudo systemctl restart gravity-node
```
Logs and status
```
sudo journalctl -u gravity-node -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
gravity status 2>&1 --node "tcp://127.0.0.1:26657" | jq .SyncInfo
```
