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
#### Setting `config.toml`
```
sed -i.bak -e "s/^laddr *=.*/laddr = \""tcp://0.0.0.0:26657"\"/" $HOME/.axelar/config/config.toml
sed -i.bak -e "s/^pex *=.*/pex = \"true\"/" $HOME/.axelar/config/config.toml
```
4) Restart your node
```
sudo systemctl restart axelard
```
Done! Wait when your server produces snapshots and everyone can use it.🎉

In more detail, the process can be found by the link https://surftest.gitbook.io/axelar-wiki/english/cosmos-sdk-state-sync
