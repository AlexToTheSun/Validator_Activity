## Quicksilver Network State Sync
### Link to the testnet materials is [here](https://github.com/ingenuity-build/testnets/tree/main/killerqueen)
### Explorer [[here](https://testnet.explorer.testnet.run/kqcosmos-1)]
### Chain: `kqcosmos-1`
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="41fd76514877c1b7c513fe8ad3b4a0b2fbbe72a8@154.12.230.132:26656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.ica/config/config.toml
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.ica/config/config.toml
```
Restart the `icad.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop icad && \
icad tendermint unsafe-reset-all --home $HOME/.ica && \
sudo systemctl restart icad
```
Logs and status
```
journalctl -u icad.service -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
```
