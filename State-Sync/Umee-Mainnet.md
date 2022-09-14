#### Link to the GitHub materials is [here](https://github.com/umee-network)
#### Explorers [Guru](https://umee.explorers.guru/), [Mintscan](https://www.mintscan.io/umee/)

## Info
- Public RPC enpoint: http://161.97.105.150:26657/
- Public API: http://161.97.105.150:1317/
- Chain: `umee-1`
- Snapshot-keep-recent: `2000`

## Umee Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="0e390f22f71f641f70d0a85389ef4dc728758608@161.97.105.150:26656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.umee/config/config.toml
```
Add variables
```
SNAP_RPC="http://161.97.105.150:26657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.umee/config/config.toml
```
Restart the `umeed.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop umeed && \
umeed tendermint unsafe-reset-all --home ~/.umee && \
sudo systemctl restart umeed
```
Logs and status
```
sudo journalctl -u umeed -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
umeed status 2>&1 | jq .SyncInfo
```
