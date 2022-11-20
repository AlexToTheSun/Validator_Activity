#### Link to the GitHub materials is [here](https://github.com/okp4/okp4d)
#### Official [Docs](https://docs.okp4.network/docs/nodes/introduction)
#### Explorers: https://explorer-turetskiy.xyz/okp4

## Info
- Public RPC enpoint: http://65.21.61.107:36657
- Public API: http://65.21.61.107:36317
- Chain: `okp4-nemeton`
- Snapshot-keep-recent: `2000`

## OKP4 Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="7003fc0f51f9407bda4f03ffafe3363a8c9396c8@65.21.61.107:36656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.okp4d/config/config.toml
```
Add variables
```
SNAP_RPC="http://65.21.61.107:36656"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.okp4d/config/config.toml
```
#### In first time **make a backup** of `node_key.json` and `priv_validator_key.json` before unsafe-reset-all
```
cp $HOME/.okp4d/config/priv_validator_key.json $HOME/.okp4d/priv_validator_key.json.backup && \
cp $HOME/.okp4d/config/node_key.json $HOME/.okp4d/node_key.json.backup
```

### Restart the `okp4d.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop okp4d && \
okp4d tendermint unsafe-reset-all --home ~/.okp4d --keep-addr-book && \
sudo systemctl restart okp4d
```
Logs and status
```
sudo journalctl -u okp4d -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
okp4d status 2>&1 | jq .SyncInfo
```
View in the Explorer https://explorer-turetskiy.xyz/okp4
