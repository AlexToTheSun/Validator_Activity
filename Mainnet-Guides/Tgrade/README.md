![Снимок экрана от 2022-08-16 21-55-27](https://user-images.githubusercontent.com/30211801/184946880-3f1e0d06-ca17-43df-bcf8-eca37586858c.png)

# Tgrade Introduction
#### Tgrade Site: https://tgrade.finance/
#### Tgrade App: https://try.tgrade.finance/

The first Tendermint based [Proof of Engagement](https://medium.com/tgradefinance/proof-of-engagement-95a1a6a024f8)(PoE) network. This article contains theses that allow you to understand the approach of the Tgrade team to the decentralization of the network. Here is some of them:
- Proof of Engagement provides the incentives for all of the community around a blockchain to be actively involved.
- Proof of Engagement brings higher decentralisation through the combination of Engagement Rewards and Stake than a pure Proof of Stake mechanism.
- With Proof of Engagement there is little scope for validators to capture voting weight unless, in some cases, they have a relatively high level of engagement.

For more Information about Grade you could read:
- [Securing a blockchain with Proof of Engagement](https://medium.com/tgradefinance/securing-a-blockchain-with-proof-of-engagement-b13daa9befc)
- [Delegators or no Delegators? Which path does Tgrade follow?](https://medium.com/tgradefinance/delegators-or-no-delegators-which-path-does-tgrade-follow-63a0a3543d18)
- [Tendermint Announces Investment in Tgrade to bolster Cosmos’ growing DeFi ecosystem](https://medium.com/tgradefinance/tendermint-announces-investment-in-tgrade-to-bolster-cosmos-growing-defi-ecosystem-8394ebabb9b6)
- [Tgrade: The blockchain made for business](https://medium.com/tgradefinance/tgrade-the-blockchain-made-for-business-c7654b34dafd)
# Documents Introduction
This repository contains not only a simple installation option, but also advanced security settings that are highly recommended for mainnet validators.

By this documentation we will setup [server security](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Minimum-server-protection.md). After that we will run Tgrade node with [Sentry Node Architecture](https://forum.cosmos.network/t/sentry-node-architecture-overview/454) for DDoS mitigation on Tgrade validator node. And will make a validator protection from double signing incident by [tmkms](https://github.com/iqlusioninc/tmkms).

Another important topic for Cosmos Hub networks is ibc relayer. Here we will walk through the installation of[ Hermes IBC relayer](https://hermes.informal.systems/) between [Tgrade](https://tgrade.finance/) and [Osmosis](https://app.osmosis.zone) chains step by step.

Also there is my [RPC node with State Sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Tgrade-Mainnet.md) for Tgrade validator community. If you want to know more about Cosmos SDK State Sync read [the article](https://blog.cosmos.network/cosmos-sdk-state-sync-guide-99e4cf43be2f).

# Step by step instructions
1. [Server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Minimum-server-protection.md)
2. [Setup our Sentry Nodes to work in public network](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Basic-Installation-Synchronization.md)
3. [Connect our Validator node to Sentry Nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Sentry-Node-Architecture.md)
4. [Upgrade to a Validator](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Wallet-Funding-%26-Validator-Creating.md)
5. [Double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md)
#### Optional step
6. [Setup Tgrade-Osmosis Hermes relayer](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md)
7. [How to run your own RPC with State Sync](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync)
8. [Using Cosmovisor](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Cosmovisor.md)


