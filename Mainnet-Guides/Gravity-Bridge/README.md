![image](https://user-images.githubusercontent.com/30211801/170793604-25cb7641-9f0b-4097-967e-7bfa2627ecbb.png)

## Gravity Bridge installation
This repository contains not only a simple installation option, but also advanced security settings that are highly recommended for mainnet validators.  
### What we get after installation
#### 1) First of all we should set the [Minimum server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md), we'll start by setting up server security.  
**Change the SSH port**. This will restrict unwanted traffic on the ssh connection.  
**Setup SSH keys**. Be sure to disable password login. Instead of a password, we will configure SSH keys to enter the server.  
**Firewall**. In the guide, we will configure ufw.  
**IDS**. Let's configure file2ban as an intrusion detection system.  
**MFA**. We will use Google 2FA. This is an additional step towards server security.  
**Setup the mainnet node**. Finally, we will install the node and run the validator on the main-net.

Schematically, the server settings will look like this:
<img width="5397" alt="Group 96" src="https://user-images.githubusercontent.com/30211801/170465651-294bdc0e-2565-4e21-8d8f-21d7d41977ed.png">
#### 2) Setting up your validator in the [Basic-Installation.md](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md)
In this guide, we will install everything necessary for the mainnet validator to work properly. But without DDoS / Double signing protection.
#### 3) After that we [Setting up Sentry nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Sentry-Node-Architecture.md).
It will protect from DDoS attacks. The architecture will look like this:
<img width="5397" alt="Group 95" src="https://user-images.githubusercontent.com/30211801/170466250-eceffbbb-fc61-40fb-bb29-cf436057b29c.png">

#### 3) And finally [Setting up tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md)
With this, we protect our validator from double signing the block using tmkms:
<img width="5397" alt="Group 94" src="https://user-images.githubusercontent.com/30211801/170466454-29747fd8-27d2-4fbf-baba-e6f05dae9ed0.png">

### Official Gravity Bridge links
- Website https://www.gravitybridge.net/
- Setting up a validator https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md
- Resources https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/resources.md
- Releases https://github.com/Gravity-Bridge/Gravity-Bridge/releases
- Explorers
  - https://gravity-bridge.ezstaking.io/validators
  - https://www.mintscan.io/gravity-bridge
  - https://atomscan.com/gravity-bridge
  - https://ping.pub/gravity-bridge
