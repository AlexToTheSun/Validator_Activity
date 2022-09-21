#### Link to the GitHub materials is [here](https://github.com/sei-protocol)
#### Explorers [Guru](https://sei.explorers.guru/), [PingPub](https://testnet.explorer.testnet.run/sei-network)

## Info
- Public RPC enpoint: http://212.23.222.28:21657/
- Public API: http://212.23.222.28:21317/
- Chain: `atlantic-1`
- Snapshot-keep-recent: `2000`

## SEI Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="7f1970d704045b9908a18e9ec35c6b942c73ccfb@212.23.222.28:21656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.sei/config/config.toml
```
Add variables
```
SNAP_RPC="http://212.23.222.28:21657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sei/config/config.toml
```
Restart the `seid.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop seid && \
seid tendermint unsafe-reset-all --home ~/.seid && \
sudo systemctl restart seid
```
Logs and status
- type your port instead of `26657`
```
sudo journalctl -u seid -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
seid status 2>&1 | jq .SyncInfo
```
Explorers:
- [Guru](https://sei.explorers.guru/)
- [PingPub](https://testnet.explorer.testnet.run/sei-network)
