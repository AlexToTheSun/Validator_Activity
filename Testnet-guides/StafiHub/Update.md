### Chain-id `stafihub-testnet-1`
Stop service
```
sudo systemctl stop stafihubd
```
Let's edit chain variable
```
nano $HOME/.bash_profile
source $HOME/.bash_profile
```
Delete an old binary
```
cd $HOME
sudo rm stafihub -rf
```
Build a new one
```
git clone --branch public-testnet https://github.com/stafihub/stafihub
cd stafihub
git checkout public-testnet
make install
sudo cp /root/go/bin/stafihubd /usr/local/bin/seid
stafihubd version --long | head
```
Download genesis
```
wget -O $HOME/.stafihub/config/genesis.json "https://raw.githubusercontent.com/tore19/network/main/testnets/stafihub-testnet-1/genesis.json"
stafihubd tendermint unsafe-reset-all --home ~/.stafihub
```
Configure your node
```
stafihubd config chain-id stafihub-testnet-1
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01ufis\"/" $HOME/.stafihub/config/app.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stafihub/config/app.toml
peers="4e2441c0a4663141bb6b2d0ea4bc3284171994b6@46.38.241.169:26656,79ffbd983ab6d47c270444f517edd37049ae4937@23.88.114.52:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.stafihub/config/config.toml
```
Start
```
sudo systemctl restart stafihubd
sudo journalctl -u stafihubd -f -o cat
```
Since the network is new, we will have to create the validator again
```
stafihubd tx staking create-validator \
 --amount=9900000ufis \
 --broadcast-mode=block \
 --pubkey=$(stafihubd tendermint show-validator) \
 --moniker=$stafihub_NODENAME \
 --details="" \
 --website="" \
 --identity="" \
 --commission-rate=0.07 \
 --commission-max-rate=0.20 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1 \
 --from=$stafihub_WALLET \
 --chain-id=$stafihub_CHAIN \
 --gas-prices=0.025ufis \
 --gas=auto \
 --gas-adjustment=1.4
```
Status and logs
```
stafihubd status 2>&1 | jq
stafihubd status 2>&1 | jq .SyncInfo
sudo journalctl -u stafihubd -f --output cat
```
### Links
- explorer https://testnet-explorer.stafihub.io/stafi-hub-testnet/staking
- docs https://docs.stafihub.io/welcome-to-stafihub/chain/getting-started/join-the-public-testnet
- github doc https://github.com/stafihub/network/tree/main/testnets/stafihub-testnet-1

