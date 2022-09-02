![image](https://user-images.githubusercontent.com/30211801/188069757-80eebb2b-4249-432c-8e7b-ae10121936a9.png)

# Source Introduction
A public, permission-less blockchain network for global payments and all things decentralized. Enterprises, developers and individuals can utilize $SOURCE's infrastructure to create user-friendly apps, smart contracts and tools for Web 3.0, DeFi, NFTs, and more.

#### Source Website: https://www.sourceprotocol.io
#### Documents: https://docs.sourceprotocol.io
#### Source One: https://www.sourceprotocol.io/source-one (App is coming soon)
- [Source One](https://docs.sourceprotocol.io/defi/sourceone) - Source's decentralized money market enables individuals, corporate treasuries, endowments, small businesses, and more to earn interest and access instant liquidity with ease. All while maintaining full control of their assets.
- Users of SRCX benefit from an efficient and solvent global payment network with direct integration into Source One and sustainable network reward mechanisms.
- Borrow, de-risk and hedge with USX, a stable coin backed and over-collateralized by a variety of assets within Source One Money Market.

# Introduction of This Document
This repository contains not only a simple installation option with Disk usage optimisation, but also advanced security settings that are highly recommended for mainnet validators.

By this documentation we will setup [server security](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Minimum-server-protection.md). After that we will run Source node with [Sentry Node Architecture](https://forum.cosmos.network/t/sentry-node-architecture-overview/454) for DDoS mitigation on Source validator node. And will make a validator protection from double signing incident by [tmkms](https://github.com/iqlusioninc/tmkms). In addition, it is recommended to use [Monitoring](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/Source/Monitoring) to monitor all your servers as validator, sentry nodes, tmkms server etc.

For upgrading of Source bynary in more conviniate way - you can use [Cosmovisor](https://docs.cosmos.network/main/run-node/cosmovisor.html).

Also there is an instruction [How to run your own RPC with State Sync](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync) for Source validator community. If you want to know more about Cosmos SDK State Sync read [the article](https://blog.cosmos.network/cosmos-sdk-state-sync-guide-99e4cf43be2f).

# Step by step instructions
1. [Server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Minimum-server-protection.md)
2. [Setup our Sentry Nodes to work in public network](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Basic-Installation-Synchronization.md)
3. [Connect our Validator node to Sentry Nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Sentry-Node-Architecture.md)
4. [Upgrade to a Validator](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Wallet-Funding-%26-Validator-Creating.md)
5. [Double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/tmkms-validator-security.md)
#### Optional step
6. [How to run your own RPC with State Sync](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync)
7. [Using Cosmovisor](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/Cosmovisor.md)
8. [Monitoring Grafana+Prometheus](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/Source/Monitoring)
