#### Website: https://www.empower.eco
#### Link to the GitHub materials is [here](https://github.com/empowerchain)
#### Official [Docs](https://github.com/empowerchain/empowerchain/tree/main/testnets)
#### Explorers: http://turnodes.com/empower

## Info
- Public RPC enpoint: http://146.19.24.139:15657
- Public API: http://146.19.24.139:15317
- Chain: `altruistic-1`
- Snapshot-keep-recent: `2000`

## Empower Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="7003fc0f51f9407bda4f03ffafe3363a8c9396c8@146.19.24.139:15656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.empowerchain/config/config.toml
```
Add variables
```
SNAP_RPC="http://146.19.24.139:15657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.empowerchain/config/config.toml
```
#### In first time **make a backup** of `node_key.json` and `priv_validator_key.json` before unsafe-reset-all
```
cp $HOME/.empowerchain/config/priv_validator_key.json $HOME/.empowerchain/priv_validator_key.json.backup && \
cp $HOME/.empowerchain/config/node_key.json $HOME/.empowerchain/node_key.json.backup
```

### Restart the `empowerd.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop empowerd && \
empowerd tendermint unsafe-reset-all --home ~/.empowerchain --keep-addr-book && \
sudo systemctl restart empowerd
```
Logs and status
```
sudo journalctl -u empowerd -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
empowerd status 2>&1 | jq .SyncInfo
```
View in the Explorer http://turnodes.com/empower
