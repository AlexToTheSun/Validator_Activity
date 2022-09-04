## Create your Source wallet
You can create new wallet
```
sourced keys add $SOURCE_WALLET
```
Or recover it if you already have one
```
sourced keys add $SOURCE_WALLET --recover
```
## Fund your test wallet
Here is [Source Discord](https://discord.gg/3R96wfUBHv). Go to the [faucet channel](https://discord.gg/cN5bquapAY) and top up your created wallet by the command below: 
```
$request <your_source_address>
```
Faucet gives you 1000000usource which is 1source.

## Upgrade to a Validator
> For now in source chain there are 0 fees transaction so you can don't use flag `--fees <amount>usource`
Below there is a validator creation transaction. Specify:
- Identity code from https://keybase.io/
- Website link.
- Details that you would like to specify, for example your Discorsd.
Run the following command syntax:
```
sourced tx staking create-validator \
--amount=1000000usource \
--pubkey=$(sourced tendermint show-validator) \
--moniker=$SOURCE_NODENAME \
--chain-id=$SOURCE_CHAIN \
--commission-rate="0.05" \
--commission-max-rate="0.1" \
--commission-max-change-rate="0.1" \
--min-self-delegation="1" \
--fees=100usource \
--from=$SOURCE_WALLET \
--identity="" \
--website="" \
--details="" \
-y
```
For delegate more use this command:
```
sourced tx staking delegate --chain-id $SOURCE_CHAIN $(sourced keys show $SOURCE_WALLET --bech val -a) <amount>usource --from $SOURCE_WALLET --gas-prices 0.025usource -y
```
Logs and status
```
sudo journalctl -u sourced -f -o cat
curl localhost:26657/status | jq
sourced status 2>&1 | jq .SyncInfo
```
## Next step
Now we have a validator.

The next step is validator [double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Source/tmkms-validator-security.md).
