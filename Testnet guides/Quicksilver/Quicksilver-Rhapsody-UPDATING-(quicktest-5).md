## Updating process for Quicksilver Rhapsody Testnet
### Chain: `rhapsody-5`
This instruction is for updating the node, which we installed according to the instructions  https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet%20guides/Quicksilver%20Rhapsody%20Testnet.md

Officiall link is here https://github.com/ingenuity-build/testnets

Explorer:

https://testnet.explorer.testnet.run/Quicksilver
https://quicksilver.explorers.guru/

## Stop the service
```
sudo systemctl stop quicksilverd
```
#### Delete old downloaded blockchain data
Since the network is new, and the genesis file is new, then synchronization in this network
  started from scratch. Therefore, we need to reset the synchronization state of our node.
```
quicksilverd unsafe-reset-all
```
if there is no free space, the quicksilver unsafe-reset-all command may not work. then do the following:
```
cp /root/.quicksilverd/data/priv_validator_state.json /root/.quicksilverd/priv_validator_state.json
rm -rf /root/.quicksilverd/data/*
mv /root/.quicksilverd/priv_validator_state.json /root/.quicksilverd/data/priv_validator_state.json
quicksilverd unsafe-reset-all
```
## Upgrading
#### Update quicksilverd
```
rm -rf $HOME/quicksilver
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.3.0
cd quicksilver
git checkout v0.3.0
make build
cp $HOME/quicksilver/build/quicksilverd /usr/local/bin
quicksilverd version
```
#### Download genesis file
The initial state of the network is written in the genesis, so this file must be replaced
```
wget -qO $HOME/.quicksilverd/config/genesis.json "https://raw.githubusercontent.com/ingenuity-build/testnets/main/rhapsody/genesis.json"
```
#### Change the `chainName` variable
```
sed -i -e "s/^export chainName *=.*/export chainName=\"rhapsody-5\"/" $HOME/.bash_profile
. $HOME/.bash_profile
```
#### Add new peers
```
seeds="dd3460ec11f78b4a7c4336f22a356fe00805ab64@seed.rhapsody-5.quicksilver.zone:26656"
peers="c5cbd164de9c20a13e54e949b63bcae4052a948c@138.201.139.175:20956,9428068507466b542cbf378d59b77746c1d19a34@157.90.35.151:26657,4e7a6d8a3c8eeaad4be4898d8ec3af1cef92e28d@93.186.200.248:26656,eaeb462547cf76c3588e458120097b51db732b14@194.163.155.84:26656,51af5b6b4b0f5b2b53df98ec1b029743973f08aa@75.119.145.20:26656,9a9ed14d71a88354b0383419432ecce70e8cd2b3@161.97.152.215:26656,43bca26cb1b2e7474a8ffa560f210494023d5de4@135.181.140.225:26657"
sed -i -e "/seeds =/ s/= .*/= \"$seeds\"/"  $HOME/.quicksilverd/config/config.toml
sed -i -e "/seeds =/ s/= .*/= \"$peers\"/"  $HOME/.quicksilverd/config/config.toml

```
## Start syncing
Disable synchronization by State Sync
```
sed -i.bak -e "s/^enable *=.*/enable = "false"/" $HOME/.quicksilverd/config/config.toml
```
Start syncing
```
quicksilverd tendermint unsafe-reset-all
sudo systemctl restart quicksilverd
```
Excellent. All is ready. It remains to check
## Check your node logs:
```
journalctl -u quicksilverd -f --output cat
```
#### Status of sinchronization:
```
quicksilverd status 2>&1 | jq .SyncInfo

curl http://localhost:26657/status | jq .result.sync_info.catching_up
```
#### Check Node ID:
```
curl localhost:26657/status | jq '.result.node_info.id'
```
## Create the validator in the new chain
Get tokens in the Discord faucet:
```
$request <your_wallet> rhapsody
```
Check your balance in the Discord faucet:
```
$balance <your_wallet> rhapsody
```
#### Create validator:
```
quicksilverd tx staking create-validator \
--amount=4800000uqck \
--pubkey=$(quicksilverd tendermint show-validator) \
--from=$YOUR_TEST_WALLET \
--moniker=$NODE_MONIKER \
--chain-id=$chainName \
--details="" \
--website="" \
--identity="" \
--min-self-delegation=1 \
--commission-rate=0.1 \
--commission-max-rate=0.5 \
--commission-max-change-rate=0.1 \
--gas-prices=0.025uqck \
--gas-adjustment=1.4
```
