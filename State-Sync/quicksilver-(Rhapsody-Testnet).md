## Quicksilver Network State Sync
### Chain: `killerqueen-1`
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="819463a364f7ff39d8ca8070976457c67811c500@154.12.230.132:26656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.quicksilverd/config/config.toml
```
Add variables
```
SNAP_RPC="http://154.12.230.132:26657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.quicksilverd/config/config.toml
```
Restart the `quicksilverd.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop quicksilverd && \
quicksilverd tendermint unsafe-reset-all --home $HOME/.quicksilverd && \
sudo systemctl restart quicksilverd
```
Logs and status
```
journalctl -u quicksilverd.service -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
```
