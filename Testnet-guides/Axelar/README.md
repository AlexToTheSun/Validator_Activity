![Axelar_Tshirt_Turetskiy221](https://user-images.githubusercontent.com/30211801/177197861-4ad4b6d1-4375-4979-9486-d4d4889f8703.png)
# Axelar network instructions
This repository contains useful links and advanced security settings that are highly recommended for mainnet/testnet validators.
Here is the official links:
- [Website](https://axelar.network/)
- [Github link](https://github.com/axelarnetwork)
- [Docs](https://docs.axelar.dev/)
- [Medium](https://medium.com/axelar)
- Testnet Explorers
  - https://testnet.explorer.testnet.run/axelar-testnet-2/
  - https://testnet.axelarscan.io
  - https://testnet-2.axelarscan.io
- Mainnet explorers
  - https://axelar.explorers.guru/
  - https://axelarscan.io

# Instructions
Here is the guides for **`axelar-testnet-casablanca-1`** validators.

## Minimal serer protection
[[Link to instruction](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md)]
There we will protect server by:
- Change the password
- Firewall configuration (ufw)
- Change the SSH port
- SSH key login
- Install File2ban
- 2FA for SSH

## Basic Installation
[[Here](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Axelar/Basic-Installation.md)] Setting up the validator node with Registering EVM Chains

## State sync for your Sentry Nodes
[[Here](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Axelar-testnet-2.md)] is the Link to guide for sync your Sentry Nodes by RPC Node with State Sync in **`axelar-testnet-casablanca-1`**.

Not recomended for node with validators. Because it should be protected by Sentry Nodes.

## DDoS attacks protection
All validator nodes should be protected from DDoS attacks by Sentry Nodes. [[Guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Axelar/Sentry-Node-Architecture.md)]

## Double signing protection
[[Link to tmkms instruction](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Axelar/tmkms-(separated-server).md)] for Axelar network.  

The official documentation is [here](https://github.com/iqlusioninc/tmkms#tendermint-kms-) In this article, we will configure tmkms on a separate server for the double-signing protection of the Axelar' validator.

## Results
These Guides and protections we get an anti-fragile architecture for the Cosmos validator. Below I will give a flowchart that visualizes the settings we have done.
![image](https://user-images.githubusercontent.com/30211801/176674173-de703105-c143-4186-b3db-870a0f9c7cea.png)

