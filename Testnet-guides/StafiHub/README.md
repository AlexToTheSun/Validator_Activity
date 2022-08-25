![Снимок экрана от 2022-07-14 18-25-19](https://user-images.githubusercontent.com/30211801/179006065-3813faf9-2b0b-451d-a5e3-88a029aed063.png)

**StafiHub** Is A Cross-Chain Staking Derivatives Platform On The Cosmos Ecosystem

Here is the official links:
- [Website](https://www.stafihub.io/)
- [Github link](https://github.com/stafihub/)
- [Mainnet Explorer](https://ping.pub/stafihub)
- [Airdrop Portal](https://airdrop.stafihub.io/)
- [Testnet Explorer](https://testnet-explorer.stafihub.io/stafi-hub-testnet)
- [Docs](https://docs.stafihub.io/welcome-to-stafihub/user/join-public-testnet)
- [Swap Cosmos Eco tokens To get FIS on StaFiHub chain](https://app.stafihub.io/feeStation)

# StafiHub network installation
This repository contains not only a [simple installation](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#install-stafihub) option, but also advanced security settings that are highly recommended for mainnet validators.

By this documentation we will setup [Disk usage optimization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#disk-usage-optimization), [Server security](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#minimal-server-protection) (Firewall, Changing the SSH port, SSH key login, File2ban, 2FA). After that we will run StaFiHub node with [Sentry Node Architecture](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Sentry-Node-Architecture.md) for DDoS mitigation on StaFiHub validator node. And will make a validator protection from double signing incident by [tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/tmkms.md). The official tmkms documentation is [here](https://github.com/iqlusioninc/tmkms#tendermint-kms-)

Another important topic for Cosmos Hub networks is ibc relayer. Here we will walk through the installation of [Hermes IBC relayer](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Hermes-relayer.md) between [StaFiHub](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/StafiHub) and [SEI](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/SEI-testnet-devnet) chains step by step.

Also there is my [RPC node with State Sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/StaFiHub_(stafihub-public-testnet-3).md) for StafiHub validator community. If you want to know more about Cosmos SDK State Sync read the [article](https://blog.cosmos.network/cosmos-sdk-state-sync-guide-99e4cf43be2f).

# Step by step instructions
1. [Server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#minimal-server-protection)
2. [StaFiHub installation](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#install-stafihub)
3. [Disk usage optimization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#disk-usage-optimization)
4. [Sentry Node Architecture](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Sentry-Node-Architecture.md)
5. [Double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/tmkms.md)
#### Optional step
6. [Setup StaFiHub-SEI Hermes relayer](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Hermes-relayer.md)
7. [How to run your own RPC with State Sync](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync)
8. [Using Cosmovisor](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Cosmovisor.md)



## Results
these protections we get an anti-fragile architecture for the Cosmos validator. Below I will give a flowchart that visualizes the settings we have done.
![image](https://user-images.githubusercontent.com/30211801/176674173-de703105-c143-4186-b3db-870a0f9c7cea.png)

