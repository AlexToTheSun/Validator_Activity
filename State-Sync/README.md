## Why State Sync
For quick synchronization and saving space on the server, use [state sync](https://blog.cosmos.network/cosmos-sdk-state-sync-guide-99e4cf43be2f) snapshot.

A detailed article article is with links to sources is [[here](https://surftest.gitbook.io/axelar-wiki/english/cosmos-sdk-state-sync)]
## When State Sync can not be used
For nodes running to transfer data to sites and dapps that require information about all transactions, synchronization using Snapshot is not suitable.
## How to use?
To do this, you need to make only a few things.
1) Install the last version of the protocol that you want to launch.
2) Make the reset of the entire date, which was loaded with previous synchronization attempts.
3) Enter information for synchronization by state sync to `config.toml`
4) Restart
## How to run your own RPC with State Sync
On the example of the Axelar Network.
1) Install the Axelar' binary https://docs.axelar.dev/validator/setup/manual
2) Download the blockchain a convenient way for you (Synchronize)
3) Setting RPC parameters for State-sync snapshots:
#### Setting `app.toml`
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""1000"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = \""1000"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \""2"\"/" $HOME/.axelar/config/app.toml
```
The value of `snapshot-interval`/`pruning-keep-every`could be for example 5000, for more economical space usage..
#### Setting `config.toml`
```
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.axelar/config/config.toml
sed -i.bak -e "s/^pex *=.*/pex = \"true\"/" $HOME/.axelar/config/config.toml
```
4) Restart your node
```
sudo systemctl restart axelard
```
Done! Wait when your server produces snapshots and everyone can use it.🎉

## How to use
You shoud know 4 things:
- `Your_server_IP` - ip of your server with State Sync
- `Your_rpc_port` (default is `26657`)
- `Your_p2p_port` (default is `26656`)
- `Your_node_id`: to find out node_id of the RPC server type the command `curl localhost:26657/status | jq '.result.node_info.id'`
- `Your_interval` - it is value of `snapshot-interval`/`pruning-keep-every`

#### Now just insert the values:
Adding public RPC node to `persistance_peer` in `config.toml`.  
Here you need `<Your_node_id>`, `<Your_server_IP>`, `<Your_p2p_port>`.
```
peers="<Your_node_id>@<Your_server_IP>:<Your_p2p_port>"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.axelar/config/config.toml
```
Adding variables.  
Here you need `<Your_server_IP>`, `<Your_rpc_port>`, `<Your_interval>`.
```
SNAP_RPC="http://<Your_server_IP>:<Your_rpc_port>"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - <Your_interval>)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Entering all the datat to `config.toml`
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.axelar/config/config.toml
```
Deleting all downloaded date by `unsafe-reset-all` and resterting `axelard.service`
```
sudo systemctl stop axelard && \
icad tendermint unsafe-reset-all --home $HOME/.axelar && \
sudo systemctl restart axelard
```

In more detail, the process can be found by the link https://surftest.gitbook.io/axelar-wiki/english/cosmos-sdk-state-sync
