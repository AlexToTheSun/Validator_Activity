## Agoric Network State Sync
### Info
- Public RPC enpoint: http://154.12.241.178:26657/
- Public API: http://154.12.241.178:1317/
- Chain: `agoric-3`
- Snapshot-keep-recent: `1000`
- Explorer: [Bigdipper](https://bigdipper.live/agoric), [Guru](https://agoric.explorers.guru/)

Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="9373c1dbf0a040d2c76b120f8472871b92852f62@154.12.241.178:26656"; \
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.agoric/config/config.toml
```
Add variables
```
SNAP_RPC="http://154.12.241.178:26657"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Now enter all the datat to `config.toml`
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.agoric/config/config.toml
```
Restart the `agoricd.service`
```
sudo systemctl restart agoricd
```
Logs and status
```
journalctl -u agoricd.service -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
```
