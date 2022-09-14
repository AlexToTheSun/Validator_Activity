![Снимок экрана от 2022-09-14 19-18-10](https://user-images.githubusercontent.com/30211801/190195875-f19668d7-b857-4923-8292-2388586af626.png)
# Umee Introduction
#### Website: https://umee.cc/
#### Umee app: https://app.umee.cc/
#### Github: https://github.com/umee-network
#### Docs: https://docs.umee.cc/umee/umee-overview/what-is-umee
#### Interoperable Base Layer Blockchain:
Umee is a base layer blockchain, much like Ethereum. As a base layer blockchain, applications and money lego primitives can be built on top of Umee in order to allow DeFi users to access cross chain leverage and liquidity.
As a Cosmos SDK blockchain, the Umee Network already is interoperable with blockchains including Ethereum, Crypto.com, Binance Chain, Osmosis, Juno, Secret Network, and 30+ others.

#### Decentralized Lending & Borrowing:
Umee allows anyone with an internet connection to supply their crypto assets on the Umee market to easily earn passive lending yield. Umee users can also use their deposits as collateral to borrow other assets and discover new yield opportunities.
Umee is permissionless, and there is no background check or approval needed to use its services.

#### Interchain Leverage:
Umee will allow users to leverage their favorite assets and access deep liquidity all in one place. Umee is chain and bridge agnostic, and will support the changing needs of users over time.

# Introduction of This Document
This repository contains not only a simple installation option with Disk usage optimisation, but also advanced security settings **that are highly recommended for mainnet validators**.

By this documentation we will setup [server security](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md). After that we will run Umee node with [Sentry Node Architecture](https://forum.cosmos.network/t/sentry-node-architecture-overview/454) for DDoS mitigation on Umee validator node. And will make a validator protection from double signing incident by [tmkms](https://github.com/iqlusioninc/tmkms). In addition, it is recommended to use [Monitoring](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Umee/Monitoring) to monitor all your servers as validator, sentry nodes, tmkms server etc.

For upgrading of Umee bynary in more conviniate way - you can use [Cosmovisor](https://docs.cosmos.network/main/run-node/cosmovisor.html).

Also there is [my RPC node with State Sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Umee-Mainnet.md) and an instruction [How to run your own RPC with State Sync](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync#how-to-run-your-own-rpc-with-state-sync) for Umee validator community. If you want to know more about Cosmos SDK State Sync read the [article](https://blog.cosmos.network/cosmos-sdk-state-sync-guide-99e4cf43be2f).

# Step by step instructions
1. [Server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Minimum-server-protection.md)
2. [Setup our Sentry Nodes to work in public network](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Basic-Installation-Synchronization.md)
3. [Connect our Validator node to Sentry Nodes](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Sentry-Node-Architecture.md)
4. [Upgrade to a Validator](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Wallet-Funding-Validator-Creating.md)
5. [Double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/tmkms-validator-security.md)
#### Optional step
6. [How to run your own RPC with State Sync](https://github.com/AlexToTheSun/Validator_Activity/tree/main/State-Sync)
7. [Using Cosmovisor](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/Cosmovisor.md)
8. [Monitoring Grafana+Prometheus](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Mainnet-Guides/Umee/Monitoring)
