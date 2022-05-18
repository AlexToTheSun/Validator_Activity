## Clan Network State Sync
### Chain: `playstation-2`
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="bc92bce07866ba26561d3cdfeb09254710fe6d33@195.3.221.174:26651"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.quicksilverd/config/config.toml
```
Add variables
```
SNAP_RPC="http://195.3.221.174:26652"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.cland/config/config.toml
```
Restart the `cland.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop cland && \
cland unsafe-reset-all && \
sudo systemctl restart cland
```
Logs and status
```
journalctl -u cland.service -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
```
