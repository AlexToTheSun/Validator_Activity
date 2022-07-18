[As you know](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md#setup-gravity-bridge), if you are validating on the Gravity Bridge blockchain, as a Validator you also **need to run the Gravity bridge components** or you will be slashed and removed from the validator set after about 16 hours.

This component ([Orchestrator](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md#setup-gravity-bridge-and-orchestrator-services)) doesn't work without connecting to Ethereum node. If we install Gravity Bridge according to the official instructions, we are running [Geth locally](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md#download-and-install-geth). This means that the orchestrator will connect to the local ETH node.

### How to check if Orchestrator is connected to local GETH?
During installation, we download the service file [orchestrator](https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/orchestrator.service), which looks like this:
```
[Unit]
Description=Gravity bridge orchestrator
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
ExecStart=/usr/bin/gbt orchestrator --fees "0ugraviton"
Environment="HOME=/root"

[Install]
WantedBy=default.target
```
The line `ExecStart=/usr/bin/gbt orchestrator --fees "0ugraviton"` does not contain the `--ethereum-rpc <ETHEREUM_RPC>` flag. This flag tells Orchestrator the address of the ethereum-rpc node it will connect to.  
If this flag is not present, then Orchestrator has no choice - it will connect exclusively to the local GETH.

### By default GETH works in `light` mode
Let's see what is written in the [GETH service file](https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/geth.service)
```
# Geth Ethereum fullnode
[Unit]
Description=Geth Ethereum fullnode
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
ExecStart=/usr/sbin/geth \
--syncmode "light" \
--http \
--config /etc/geth-light-config.toml

# if you want to run a geth fullnode
#ExecStart=/usr/bin/geth \
#--http \
#--config /etc/geth-full-config.toml

[Install]
WantedBy=default.target
```
In this config, you can see that the `ExecStart=` line contains flags:
- `--syncmode "light"` responsible for choosing the `light` synchronization mode.
- `--config /etc/geth-light-config.toml` which specifies the path to the config file.

### Let's check that the local GETH works well
View the status of your Ethereum node. If result is 'false' that means it is now synced!
```
curl -H "Content-Type:application/json" -X POST -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://127.0.0.1:8545
```
Logs:
```
journalctl -u geth.service -f --output cat
```
#### ❗️ Attention
If your light node has lost peers:
```
INFO [07-18|07:39:22.005] Looking for peers                        peercount=1  tried=3 static=5
INFO [07-18|07:39:32.090] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:39:42.128] Looking for peers                        peercount=1  tried=0 static=5
INFO [07-18|07:39:52.130] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:40:02.191] Looking for peers                        peercount=1  tried=1 static=5
INFO [07-18|07:40:12.236] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:40:22.657] Looking for peers                        peercount=1  tried=0 static=5
INFO [07-18|07:40:32.790] Looking for peers                        peercount=1  tried=3 static=5
INFO [07-18|07:40:42.814] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:40:52.845] Looking for peers                        peercount=1  tried=1 static=5
INFO [07-18|07:41:02.857] Looking for peers                        peercount=1  tried=2 static=5
```
In this case, action is required to correct the problem. Otherwise the orchestrator will not work correctly and you will be slashed and removed from the validator set after about 16 hours.

## Solving the problem of losing peers with a light node
We have 3 options
#### 1) Add peers to the light node using the cli dialog.

Here is the [[list with active peers](https://gist.github.com/rfikki/e2a8c47f4460668557b1e3ec8bae9c11?permalink_comment_id=4191111#file-lightclient-peers-mainnet-latest-txt-L4)] for GETH from [discord](https://discord.com/channels/881943007115497553/881948977707221053/997219903297822770).
Type:
```
geth attach
```
Then copy and past content from the [peer-list](https://gist.github.com/rfikki/e2a8c47f4460668557b1e3ec8bae9c11?permalink_comment_id=4191111#file-lightclient-peers-mainnet-latest-txt-L4). Command example: 
```
admin.addPeer("enode://da0c61fe14ba9da1a9835b59d811553d21787448724cfe6412bc17f0b14586df91826d8286b2137342d09a8631df5ea548cf301294b05657c2a90f9c3d526721@143.198.119.44:30303");
```
#### 2) Running GETH in `full` mode
This mode takes up a lot of disk space, but is more stable than `light` mode. Before switching to this mode of operation, check that you have enough free space on NVMe, and also set up an alert in case the disk space starts to run out unexpectedly quickly.

The lines responsible for the `full` mode of operation are initially commented out. To enable `full` mode, comment out `light` lines, and remove the `#` character from `full` lines. This is what the service file will look like after the adjustment:
```
# Geth Ethereum fullnode
[Unit]
Description=Geth Ethereum fullnode
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
#ExecStart=/usr/sbin/geth \
#--syncmode "light" \
#--http \
#--config /etc/geth-light-config.toml

# if you want to run a geth fullnode
ExecStart=/usr/bin/geth \
--http \
--config /etc/geth-full-config.toml

[Install]
WantedBy=default.target
```
It is possible that in the `geth-full-config.toml` config file you will have to replace `fast` with `full`. Or insert an additional flag `--syncmode "fast" \`. Then it will turn out like this:
```
ExecStart=/usr/bin/geth \
--syncmode "fast" \
--http \
--config /etc/geth-full-config.toml
```
Restart and logs
```
sudo systemctl daemon-reload
sudo service geth restart
journalctl -u geth.service -f --output cat
```
You can view the status of your Ethereum node by issuing the following command:
```
curl -H "Content-Type:application/json" -X POST -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://127.0.0.1:8545
```
When result is 'false' that means it is now synced ('true' is not synced).

#### 3) Use [infura](https://infura.io/) endpoint
After you have created project copy your mainnet endpoind (example `https://mainnet.infura.io/v3/sd7f7d7gf7g7d7h77df7s7df7sd7f7h7`) and type it in the orchestrator service file :
Open service file in nano 
```
nano /etc/systemd/system/geth.service
```
should look like this:
```
[Unit]
Description=Gravity bridge orchestrator
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
ExecStart=/usr/bin/gbt orchestrator --fees "0ugraviton" --ethereum-rpc https://mainnet.infura.io/v3/sd7f7d7gf7g7d7h77df7s7df7sd7f7h7
Environment="HOME=/root"

[Install]
WantedBy=default.target
```
Restart
```
sudo systemctl daemon-reload
sudo service orchestrator restart
```
Logs
```
journalctl -u orchestrator.service -f --output cat
```
