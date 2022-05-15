## Tendermint Key Management System (separated server)
In this article, we will configure `tmkms` on a separate server for the double-signing protection of the Agoriс' validator.

[Software-Only](https://github.com/iqlusioninc/tmkms#software-only-not-recommended) signing is not recommended, but 
if you set this on a separate server, then this will take precedence over the absence of tmkms.  

Advantage of this method instead of basic installation: 
1) double-signing protection 
2) having the validator keys in separated server.  
## Use Case
If you already run a validator node. It's not too late to set up tmkms. Follow the instructions below.
## Overview
- Setting up a Validator node
  - Firewall configuration
  - Edit config.toml
- Setting up a tmkms server
  - Install tmkms
  - Firewall configuration
  - Init tmkms
  - Edit tmkms.toml
- Restert both validator and tmkms

## Setting up a Validator node
We already [[run](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md)] a validator node.
### Firewall configuration
Allow access to validator's node port 26658 for the the tmkms server:
```
sudo ufw allow from <ip_tmkms> to any port 26658
```
### Edit config.toml
Open `config.toml` by nano:
```
nano $HOME/.agoric/config/config.toml
```





