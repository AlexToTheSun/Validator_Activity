
![Sentry Nodes Architecture_0](https://user-images.githubusercontent.com/30211801/168467120-3750f104-f65a-440e-8538-95bb9be33d3e.png)

One Sentry node will not be enough, because if it goes offline during a DDoS attack, then the validator node will also be offline, because validator synchronizes only from the Sentry node.
## Overview
- Setting up Sentry nodes
  - Install
  - Edit config.toml
- Setting up a validator node
  - Firewall configuration
  - Edit config.toml

## Setting up Sentry nodes
It is worth installing at least 3 sentry nodes in the mainnet (preferably 4-5)
### Install Agoric
Go to the [[guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md)] and set up Agoric RPC node.
### Edit config.toml
Open the config file in the nano editor:
```
nano ~/.axelar_testnet/.core/config/config.toml
```




