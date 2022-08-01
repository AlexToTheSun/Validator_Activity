# Relaying overwiew
### What is Hermes?
As we could see, [Hermes](https://hermes.informal.systems/relayer.html) is a an open-source Rust implementation of a relayer for the Inter-Blockchain Communication protocol (IBC).

Hermes is a relayer CLI (i.e., a binary). It is not the same as the relayer core library (that is the crate called [ibc-relayer](https://crates.io/crates/ibc-relayer)).

An IBC relayer is an off-chain process responsible for relaying IBC datagrams between any two Cosmos chains.

There is a [YouTube instruction](https://www.youtube.com/watch?v=_xQDTj1PcEw) in which [Andy Nogueira](https://github.com/andynog) explains all the intricacies of Hermes work.

### How does an IBC relayer work?
1. scanning chain states
2. building transactions based on these states
3. submitting the transactions to the chains involved in the network.

### So what we need to relaying?
1. Configure opend RPC nodes (or use already configured by other people) of the chains you want to relay between.
2. Fund keys of the chains you want to relay between for paying relayer fees.
3. Configure Hermes.

# Table of contents

1. Configure opend RPC nodes and Fund keys
  - Stirde RPC node
  - Gaia RPC node
  - Fund your Stride and Gaya keys
2. Install and configure Hermes
- 1. Install Hermes
- 2. Hermes Configuration
- 3. Adding private keys
3. Configure new clients for Stride and Gaia
- 1. Create-clients
- 2. Query client states
- 3. Update-clients
4. Connection Handshake
- 1. Conn-init
- 2. Conn-try
- 3. Conn-ack
- 4. Conn-confirm
- 5. Query connection
5. Channel Handshake
- 1. chan-open-init
- 2. chan-open-try
- 3. chan-open-ack
- 4. chan-open-confirm
- 5. Query channel
6. Transactions

# Configure opend RPC nodes and Fund keys
We will configure Hermes to operate between **Stride** and **Gaia** in testnets.
1. Run your own Stride and Cosmos Hub RPC nodes. You should wait until the synchronization status becomes false. No need to create a validator!
2. Configure RPC nodes for using it by Hermes.
Type the commands on Stride server:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.stride/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.stride/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stride/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.stride/config/config.toml
sudo systemctl restart strided
```
Type the commands on Gaia server:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.gaia/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.gaia/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.gaia/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.gaia/config/config.toml
sudo systemctl restart gaiad
```
After that you could check everything is ok.  
In stride config.toml and app.toml:
```
nano $HOME/.stride/config/config.toml
nano $HOME/.stride/config/app.toml
```
In gaia config.toml and app.toml:
```
nano $HOME/.gaia/config/config.toml
nano $HOME/.gaia/config/app.toml
```
3. Fund your Stride and Gaya keys.
You could use `#💧┃token-faucet` from [Stride discord](https://discord.gg/9wwHHnt3cV).

















