## For quick synchronization and saving space, use state sync snapshot
Add my public RPC node to `persistance_peer` in config.toml
```
peers="cc138f96d4d38bb3ba06f0a0181af53d16edb6df@195.3.221.174:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.axelar/config/config.toml
```
Add variables
```
SNAP_RPC="http://195.3.221.174:26657"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Now enter all the datat to `confil.toml`
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.axelar/config/config.toml
```
Restart the axelard.service
```
sudo systemctl restart axelard
```
Logs and status
```
journalctl -u axelard.service -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
```
