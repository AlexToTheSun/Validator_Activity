![Снимок экрана от 2022-06-30 14-14-52](https://user-images.githubusercontent.com/30211801/176669875-1fe0d9fb-0c5e-4e95-b4b8-3e24eed78868.png)
# IDEP network installation
This repository contains advanced security settings that are highly recommended for mainnet validators.

Here is the official links:
- [Github link](https://github.com/IDEP-network/Antora)
- [Explorer](https://chadscan.com/)

## Minimal serer protection
[[Link to instruction](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md)]
There we will protect server by:
- Change the password
- Firewall configuration (ufw)
- Change the SSH port
- SSH key login
- Install File2ban
- 2FA for SSH

## DDoS attacks protection
All validator nodes should be protected from DDoS attacks by Sentry Nodes. [[Guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/Sentry-Node-Architecture.md)]

## Double signing protection
[[Link to tmkms instruction](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IDEP/tmkms.md)] for IDEP network.  

The official documentation is [here](https://github.com/iqlusioninc/tmkms#tendermint-kms-) In this article, we will configure tmkms on a separate server for the double-signing protection of the IDEP' validator.

## Results
these protections we get an anti-fragile architecture for the Cosmos validator. Below I will give a flowchart that visualizes the settings we have done.
![image](https://user-images.githubusercontent.com/30211801/176674173-de703105-c143-4186-b3db-870a0f9c7cea.png)

