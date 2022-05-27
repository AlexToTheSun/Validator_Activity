
![Sentry Nodes Architecture_0](https://user-images.githubusercontent.com/30211801/168467120-3750f104-f65a-440e-8538-95bb9be33d3e.png)

One Sentry node will not be enough, because if it goes offline during a DDoS attack, then the validator node will also be offline, because validator synchronizes only from the Sentry node.
## Overview
- [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#setting-up-sentry-nodes)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#install-agoric)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#edit-configtoml)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#restart)
- [Setting up a validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#setting-up-a-validator-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#edit-configtoml-1)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md#restart-1)

## Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install Agoric
Go to the [[guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md)] and set up Agoric RPC node. Complete all steps up to and including [[Start synchronization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#start-synchronization)].  
Now it remains to configure Sentry Nodes to work in a private network also.
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.agoric/config/config.toml
```
Changes are made in the file's section "P2P Configuration Options":
```
###################################
###  P2P Configuration Options  ###
###################################

pex = true

persistent_peers = "<nodeid_sentry>@<ip_sentry>:26656,<nodeid_sentry>@<ip_sentry>:26656"

private_peer_ids = "<nodeid_VAL>@<ip_VAL>:26656"

addr_book_strict = false

```
Description of parameters:
- `pex = true` - Sentry nodes must be connected to a common blockchain network. To be able to use the shared address book, which means the gossip protocol must be enabled!
- `persistent_peers = "<nodeid_sentry>@<ip_sentry>:26656,...."` - a list of priority nodes for connecting. You could list of Validator address and your other Sentry Nodes addresses. You could add Sentry Node teams or trusted network members.
- `private_peer_ids = "<nodeid_VAL>@<ip_VAL>:26656"` - Insert the validator's node id and ip to prevent Sentry nodes from propagating information about the validator to public network by gossip protocol.
- `addr_book_strict = false` -  this is the setting to allow Sentry nodes to operate on the private network. They will also be able to work in the public.
### Restart
Restart Sentry Node for the changes that we made in config.toml to take effect.
```
sudo systemctl restart agoricd
journalctl -u agoricd -f --output cat
ag0 status 2>&1 | jq .SyncInfo
```
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.
## Setting up a validator node
We have already installed all the necessary software, and configured `config.toml` to work on a public network (we stopped at the step [Sentry Node Architecture](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#sentry-node-architecture-recommended)). It's time to connect the validator node to the private network and run.
### Firewall configuration
The only thing is that now port 26656 is open to everyone. And you can close it and allow connection only to the IP of Sentry Nods. It is could be done like this:
```
sudo ufw deny 26656/udp
sudo ufw allow from <ip_1> to any port 26656/udp
sudo ufw allow from <ip_2> to any port 26656/udp
...
sudo ufw allow from <ip_n> to any port 26656/udp
sudo ufw status verbose
```
Where `<ip_1>`, `<ip_2>`,..., `<ip_n>` are the ip of servers with Sentry Node installed on them.
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.agoric/config/config.toml
```
Changes are made in the file's section "P2P Configuration Options":
```
###################################
###  P2P Configuration Options  ###
###################################

pex = false

persistent_peers = ""<nodeid>@<ip>:26656,<nodeid>@<ip>:26656"

private_peer_ids = ""

addr_book_strict = false

```
Description of parameters:
- `pex = true` - The node will only connect to Sentry Nodes from the persistent_peers list and will not propagate its address to the network. Thereby limiting the traffic.
- `persistent_peers = "<nodeid_sentry>@<ip_sentry>:26656,...."` - a list of addresses of your Sentry Nodes, so that you can connect to them.
- `private_peer_ids = ""` - We do not enter anything, since the gossip protocol is disabled, and the node will not issue any peers to the general network. Moreover, Sentry Node works not only in a private but also in a public network.
- `addr_book_strict = false` -  parameter allowing the validator to work in a private network. It will also be able to work in the public.
### Restart
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.  

## Start synchronization  
Once you have your sentry nodes synced and ready to work on both private and public networks, it’s time to connect a validator node to them and start syncing.  

Since the validator node will now connect exclusively to your Sentry Nodes, which you have specified in config.toml, you have 3 options to synchronize the node:
1) **Synchronize from the first block**. To do this, enter the following commands:  

Since we previously configured the config.toml of the validator node to synchronize using State Sync, we need to disable this feature. Otherwise, the node will try to download Snapshot from the public node - this will not work. Enter:
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\false|" ~/.gravity/config/config.toml
```
Start sync:
```
ag0 unsafe-reset-all
sudo systemctl enable agoricd
sudo systemctl daemon-reload
sudo systemctl restart agoricd
```
2) **Use full date snapshot**. Download and unzip data folder.
3) [**Run your own RPC with State Sync**](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync), on one of your Sentry Nodes. then connect Validator node to it by changing the config. 

### Start the service of Validator Node
To do this, go back to the Basic-Installation guide and continue from the moment [[Start synchronization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#start-synchronization)]

