#### Link to the GitHub materials is [here](https://github.com/rebuschain/rebus.testnet/tree/master/rebus_3333-1)
#### Explorer: [Guru](https://rebus.explorers.guru/validators)
#### Chain: `reb_3333-1`
## Rebus Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="20f601d834a88c0df149cadbf07cd0f7b6635b90@146.19.24.139:12656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.rebusd/config/config.toml
```
Add variables
```
SNAP_RPC="http://146.19.24.139:12657"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 3000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Now enter all the datat to `config.toml`
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.rebusd/config/config.toml
```
Restart the `icad.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop rebusd && \
rebusd tendermint unsafe-reset-all --home $HOME/.rebusd && \
sudo systemctl restart rebusd
```
Logs and status
```
sudo journalctl -u rebusd -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
rebusd status 2>&1 | jq .SyncInfo
```
