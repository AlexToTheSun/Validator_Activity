## StaFiHub Network State Sync
### Link to the GitHub testnet materials is [here](https://github.com/stafihub/network/tree/main/testnets/stafihub-public-testnet-3)
### Explorer [[here](https://testnet-explorer.stafihub.io/stafi-hub-testnet)]
### Chain: `stafihub-testnet-1`
### Site: https://www.stafihub.io/
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="3780d7988e0e0c31c3a8c783f91233425af4771a@154.12.230.132:26656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.stafihub/config/config.toml
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.stafihub/config/config.toml
```
Restart the `icad.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop stafihubd && \
stafihubd tendermint unsafe-reset-all --home ~/.stafihub && \
sudo systemctl restart stafihubd
```
Logs and status
```
sudo journalctl -u stafihubd -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
stafihubd status 2>&1 | jq .SyncInfo
```
