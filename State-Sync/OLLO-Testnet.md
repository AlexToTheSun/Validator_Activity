#### Link to the GitHub materials is [here](https://github.com/OllO-Station)
#### Official [Docs](https://docs.ollo.zone/validators/running_a_node)
#### Explorers [manticore](https://testnet.manticore.team/ollo)

## Info
- Public RPC enpoint: http://185.16.39.3:32657
- Public API: http://185.16.39.3:32317
- Chain: `ollo-testnet-0`
- Snapshot-keep-recent: `2000`

## Ollo Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="5f2e17783db19bcf868b03a1ee0a6e2cc47df6d3@185.16.39.3:32656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.ollo/config/config.toml
```
Add variables
```
SNAP_RPC="http://185.16.39.3:32657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.ollo/config/config.toml
```
Restart the `ollod.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop ollod && \
ollod tendermint unsafe-reset-all --home ~/.ollo && \
sudo systemctl restart ollod
```
Logs and status
```
sudo journalctl -u ollod -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
ollod status 2>&1 | jq .SyncInfo
```
