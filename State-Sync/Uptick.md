#### Link to the GitHub materials is [here](https://github.com/UptickNetwork/uptick-testnet/blob/main/uptick_7000-2/README.md)

#### Explorers [Guru](https://haqq.explorers.guru/) , [Turetskiy](https://explorer-turetskiy.xyz/uptick)
## Info
- Public RPC enpoint: http://185.225.191.149:11657/
- Public API: http://185.225.191.149:11317/
- Chain: `uptick_7000-2`
- Snapshot-keep-recent: `2000`

## Uptick Network State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="b14b4e3a46180eccf00d816aed5338db925e2237@185.225.191.149:11656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.uptickd/config/config.toml
```
Add variables
```
SNAP_RPC="http://185.225.191.149:11657"; \
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
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.uptickd/config/config.toml
```
Restart the `uptickd.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop uptickd && \
mkdir /root/.uptickd/backup && \
cp /root/.uptickd/config/priv_validator_key.json /root/.uptickd/backup && \
uptickd tendermint unsafe-reset-all --home ~/.uptickd && \
cp /root/.uptickd/backup/priv_validator_key.json /root/.uptickd/config \
sudo systemctl restart uptickd
```

Logs and status
```
sudo journalctl -u uptickd -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
uptickd status 2>&1 | jq .SyncInfo
```
