#### Link to the GitHub materials is [here](https://github.com/haqq-network/validators-contest)
#### Explorers [Guru](https://haqq.explorers.guru/)

## Info
- Public RPC enpoint: http://146.19.24.139:42657/
- Public API: http://146.19.24.139:42317/
- Chain: `haqq_54211-2`
- Snapshot-keep-recent: `2000`

## Haqq Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="0833039f717227ccd156d156ea772746b8ac6d71@146.19.24.139:42656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.haqqd/config/config.toml
```
Add variables
```
SNAP_RPC="http://146.19.24.139:42657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.haqqd/config/config.toml
```
Restart the `haqqd.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop haqqd && \
haqqd tendermint unsafe-reset-all --home ~/.haqqd && \
sudo systemctl restart haqqd
```
Logs and status
```
sudo journalctl -u haqqd -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
haqqd status 2>&1 | jq .SyncInfo
```
