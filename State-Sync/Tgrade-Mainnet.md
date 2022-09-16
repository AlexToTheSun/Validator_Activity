#### Link to the GitHub materials is [here](https://github.com/confio/tgrade-networks)
#### Explorers [Aneka](https://tgrade.aneka.io/), [Mintscan](https://www.mintscan.io/tgrade/)
#### Chain: `tgrade-mainnet-1`
## Tgrade Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="8d5a64491e7e3d3edbe862650bea82eae796eca6@95.214.55.131:27656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.tgrade/config/config.toml
```
Add variables
```
SNAP_RPC="http://95.214.55.131:27657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.tgrade/config/config.toml
```
Restart the `tgrade.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop tgrade && \
tgrade tendermint unsafe-reset-all --home ~/.tgrade && \
sudo systemctl restart tgrade
```
Logs and status
```
sudo journalctl -u tgrade -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
tgrade status 2>&1 | jq .SyncInfo
```
