![Снимок экрана от 2022-07-14 18-25-19](https://user-images.githubusercontent.com/30211801/179006065-3813faf9-2b0b-451d-a5e3-88a029aed063.png)
Here is the official links:
- [Github link](https://github.com/stafihub/)
- [Explorer](https://testnet-explorer.stafihub.io/stafi-hub-testnet)
- [Docs](https://docs.stafihub.io/welcome-to-stafihub/user/join-public-testnet)

# StafiHub network installation
This repository contains advanced security settings that are highly recommended for mainnet validators.



## Basic-Installation

### Installation Stafihub
[[Link to instructions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#install-stafihub)] this is the StafiHub installation itself.

### Minimal serer protection
[[Link to instructions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#minimal-server-protection)]
There we will protect server by:
- Change the password
- Firewall configuration (ufw)
- Change the SSH port
- SSH key login
- Install File2ban
- 2FA for SSH

### Disk usage optimization
[[Link to instructions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#disk-usage-optimization)]

`Adjust the configuration settings to reduce the disk requirements for your validator node.`

The effect will be greatest if the listed actions for lower the disk requirements are done before starting synchronization.

## [DDoS attacks protection]
All validator nodes should be protected from DDoS attacks by Sentry Nodes. [[Guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Sentry-Node-Architecture.md)]

## [Double signing protection]
Link to the tmkms instruction for StafiHub network is here: [[Guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/tmkms.md)]

The official documentation is [here](https://github.com/iqlusioninc/tmkms#tendermint-kms-) In this article, we will configure tmkms on a separate server for the double-signing protection of the StafiHub' validator.

## Results
these protections we get an anti-fragile architecture for the Cosmos validator. Below I will give a flowchart that visualizes the settings we have done.
![image](https://user-images.githubusercontent.com/30211801/176674173-de703105-c143-4186-b3db-870a0f9c7cea.png)

