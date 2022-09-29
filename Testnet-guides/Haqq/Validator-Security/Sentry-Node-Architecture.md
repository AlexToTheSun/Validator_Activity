# Overview
Before we start installing and synchronizing the Haqq node for the validator, we need to sync our Sentry Nodes. Since the validator should be in a private network with Sentry Nodes, and will communicate with the public network only through them.

### The most popular Sentry Node architecture
![image](https://user-images.githubusercontent.com/30211801/182532318-c0982f6f-1a3b-45cd-a39a-5063fca01e11.png)
One Sentry node will not be enough, because if it goes offline during a DDoS attack, then the validator node will also be offline, because validator synchronizes only from the Sentry node.

# Table of contents
- [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#setting-up-sentry-nodes)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#install-haqq)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#edit-configtoml)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#restart)
- [Setting up a validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#setting-up-a-validator-node)
  - [Install](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#install-haqq-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#edit-configtoml-for-connecting-to-haqq-chain-by-a-private-network)
  - [Restart](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Sentry-Node-Architecture.md#start)

# Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install Haqq
Go to the [[guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Node-insallation.md)] and set up Haqq RPC node (without a validator).
#### Use State Sync
Here is my [RPC with State Sync and guide how to use it](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Haqq-(haqq_54211-2).md).
Now it remains to configure Sentry Nodes to work in a private network also.
### Edit config.toml
Open the config file by nano editor:
```
nano ~/.haqqd/config/config.toml
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
sudo systemctl restart haqqd
journalctl -u haqqd -f --output cat
haqqd status 2>&1 | jq .SyncInfo
```
Once you have your sentry nodes synced and ready to work on a private network, it’s time to connect a validator node to them and start syncing.
# Setting up a validator node
## Install Haqq Node
We need to install the node for a validator if we didn't do that. [Use the installation guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Node-insallation.md). 
> ❗️ If you want to use stapshot or state sync on your validator node - then [upgrade your binary to the last version](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md).

> ‼️ Use only yours State Sync or public snapshots.
## Firewall configuration
After [firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Minimum-server-protection.md#firewall-configuration), the only thing is that now port 26656 is open to everyone. And you can close it and allow connection only to the IP of Sentry Nods only. It is could be done like this:
```
sudo ufw deny 26656/udp
sudo ufw allow from <ip_1> to any port 26656/udp
sudo ufw allow from <ip_2> to any port 26656/udp
...
sudo ufw allow from <ip_n> to any port 26656/udp
sudo ufw status verbose
```
Where `<ip_1>`, `<ip_2>`,..., `<ip_n>` are the ip of servers with Sentry Node installed on them.

## Edit `config.toml` for connecting to Haqq chain by a private network.
Open the config file by nano editor:
```
nano ~/.haqqd/config/config.toml
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

## Restart
Restart Validator Node for the changes that we made in config.toml to take effect.
```
sudo systemctl restart haqqd
```
Logs and status
```
sudo journalctl -u haqqd -f -o cat
curl localhost:26657/status | jq
haqqd status 2>&1 | jq .SyncInfo
```
Wait until full synchronization. The `false` status indicates that the node is fully synchronized. and you can [create a validator](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Wallet-Funding-Validator-Creating.md).


