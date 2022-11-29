

## Details

- [Docs](https://docs.uptick.network/testnet/join.html)
- [faucet](https://docs.uptick.network/testnet/faucet.html)
- Network Chain ID: `uptick_7000-2`
- [genesis file](https://github.com/UptickNetwork/uptick-testnet/blob/main/uptick_7000-2/genesis.json)
- EIP155 Chain ID: `7000`
- `uptickd` version: [`v0.2.4`](https://github.com/UptickNetwork/uptick/releases)
- Faucet: [faucet.uptick.network](https://docs.uptick.network/testnet/faucet.html)
- Cosmos explorer: 
    [explorer.testnet.uptick.network](https://explorer.testnet.uptick.network)
    [GN](https://uptick.explorers.guru/)

### Instruction:
```bash
# stop
sudo systemctl stop uptickd

# Change chain-id
sudo sed -i 's/uptick_7000-1/uptick_7000-2/' $HOME/.bash_profile
source $HOME/.bash_profile
echo  $UP_CHAIN
uptickd config chain-id $UP_CHAIN

# download a genesis
curl -o $HOME/.uptickd/config/genesis.json https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-2/genesis.json

# peers and seeds
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0auptick\"/;" ~/.uptickd/config/app.toml
external_address=$(wget -qO- eth0.me)
peers="eecdfb17919e59f36e5ae6cec2c98eeeac05c0f2@peer0.testnet.uptick.network:26656,178727600b61c055d9b594995e845ee9af08aa72@peer1.testnet.uptick.network:26656,f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@uptick-seed.p2p.brocha.in:30554,94b63fddfc78230f51aeb7ac34b9fb86bd042a77@uptick-testnet-rpc.p2p.brocha.in:30556,902a93963c96589432ee3206944cdba392ae5c2d@65.108.42.105:27656"
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.uptickd/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.uptickd/config/config.toml

# New binary
cd $HOME
git clone https://github.com/UptickNetwork/uptick.git
cd uptick
git checkout v0.2.4
make install
cp /root/go/bin/uptickd /usr/local/bin
uptickd version
```
Now, you have the lastest bynary, Genesis, Peers, and Chain-id. Next step is to start sync.

### From first (926000) block use:
```
mkdir /root/.uptickd/backup
cp /root/.uptickd/config/priv_validator_key.json /root/.uptickd/backup
uptickd tendermint unsafe-reset-all --home $HOME/.uptickd
cp /root/.uptickd/backup/priv_validator_key.json /root/.uptickd/config

sudo systemctl restart uptickd
uptickd status 2>&1 | jq .SyncInfo
sudo journalctl -u uptickd -f -o cat
```
### For State Sync synchronization use:
Use State Sync Guide for faster synchronization:
https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Uptick.md


