## IDEP Network State Sync
### Chain: `Antora`
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="ef365d33791193aa5fbb5c7137ea51667e875789@146.19.24.139:26656"; \
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.ion/config/config.toml
```
Add variables
```
SNAP_RPC="http://x.x.x.x:26657"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 5000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Now enter all the datat to `config.toml`
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.ion/config/config.toml
```
Restart the `iond.service`
```
sudo systemctl stop iond && \
iond tendermint unsafe-reset-all --home $HOME/.ion && \
sudo systemctl restart iond
```
Logs and status
```
journalctl -u iond.service -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
```
Useful links:
- [explorer](https://chadscan.com/)
- [Github of IDEP](https://github.com/IDEP-network)
- [Website](https://www.idep.network/)
