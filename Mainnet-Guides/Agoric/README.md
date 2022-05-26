![Screenshot from 2022-05-26 11-59-51](https://user-images.githubusercontent.com/30211801/170445827-44831d3f-1f35-4194-b36e-328b9525d003.png)
## Agoric network installation
This repository contains not only a simple installation option, but also advanced security settings that are highly recommended for mainnet validators.  
### What we get after installation
#### 1) In the [Basic Installation guide](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md), we'll start by setting up server security.  
**Change the SSH port**. This will restrict unwanted traffic on the ssh connection.  
**Setup SSH keys**. Be sure to disable password login. Instead of a password, we will configure SSH keys to enter the server.  
**Firewall**. In the guide, we will configure ufw.  
**IDS**. Let's configure file2ban as an intrusion detection system.  
**MFA**. We will use Google 2FA. This is an additional step towards server security.  
**Setup the mainnet node**. Finally, we will install the node and run the validator on the main-net.

Schematically, the server settings will look like this:
<img width="5397" alt="Group 96" src="https://user-images.githubusercontent.com/30211801/170465651-294bdc0e-2565-4e21-8d8f-21d7d41977ed.png">

#### 2) After that we [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md). The architecture will look like this
The architecture will look like this:
<img width="5397" alt="Group 95" src="https://user-images.githubusercontent.com/30211801/170466250-eceffbbb-fc61-40fb-bb29-cf436057b29c.png">

#### 3) And finally [Setting up tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/tmkms-(separated-server).md)
And finally, we protect our validator from double signing the block using tmkms:
<img width="5397" alt="Group 94" src="https://user-images.githubusercontent.com/30211801/170466454-29747fd8-27d2-4fbf-baba-e6f05dae9ed0.png">

### Official Agoric links
There is an official links:
- Validator Guide for all chains: https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide
- Mainnet Phase 0: https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide#mainnet-phase-0
  - [Repository](https://github.com/Agoric/ag0)
  - [Releases](https://github.com/Agoric/ag0/releases)
  - [Explorer](https://main.explorer.agoric.net)
  - [Request 1 BLD](https://github.com/Agoric/validator-profiles/wiki/Request-1-BLD) to run a validator in mainnet.
  - [Snapshots for mainnet](https://github.com/Agoric/validator-profiles/wiki/Snapshots)
- Validator Guide for Devnet: https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Devnet
  - [Explorer](devnet.explorer.agoric.net)
  - [Releases for Devnet](https://github.com/Agoric/agoric-sdk/wiki/Validator-Guide-for-Devnet#network-status)
