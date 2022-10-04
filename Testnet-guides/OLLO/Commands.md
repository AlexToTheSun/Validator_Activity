## There is the list of useful commands for OllO validators
Find out your wallet:
```
ollod keys show $OLLO_WALLET -a
```
Your validator:
```
ollod keys show $OLLO_WALLET --bech val -a
```
Information about your validator:
```
ollod query staking validator $(ollod keys show $OLLO_WALLET --bech val -a)
```

Logs and status
```
sudo journalctl -u ollod -f -o cat
curl localhost:26657/status | jq
ollod status 2>&1 | jq .SyncInfo
```
List of commands to interact with `ollod.service`
```
sudo systemctl daemon-reload
sudo systemctl enable ollod
sudo systemctl restart ollod
sudo systemctl status ollod
sudo systemctl stop ollod
sudo systemctl disable ollod
```
Unsafe-reset-all
```
ollod tendermint unsafe-reset-all --home $HOME/.ollo
```
## Tx
- If you have configured your node by `ollod config node tcp://localhost:26657` then there is no need in `--node "tcp://127.0.0.1:26657"` flag.
- as we have `minimum-gas-prices = 0.0utollo` so there is no need in `--fees` flag.

How to vote:
- `<prop_ID>` - ID of a proposal. You can find info about OllO Governance [[here](http://turnodes.com/ollo/gov)]
```
ollod tx gov vote <prop_ID> yes --from $OLLO_WALLET -y
```

Unjail:
```
ollod tx slashing unjail \
--chain-id $OLLO_CHAIN \
--from $OLLO_WALLET
```

Change the validator parameters:
```
ollod tx staking edit-validator \
--from=$OLLO_WALLET \
--chain-id=$OLLO_CHAIN \
--commission-rate="" \
--commission-max-rate="" \
--commission-max-change-rate="" \
--website="" \
--identity="" \
--details="" \
--moniker=""
```

#### Wallets, delegations and rewards
To see how many tokens are in your wallet:
```
ollod q bank balances $(ollod keys show $OLLO_WALLET -a)
```
Withdraw all delegation rewards:
```
ollod tx distribution withdraw-all-rewards --from=$OLLO_WALLET --chain-id=$OLLO_CHAIN
```
Withdraw rewards from the validator you delegated
```
ollod tx distribution withdraw-rewards <ollovaloper_address> \
--chain-id $OLLO_CHAIN \
--from $OLLO_WALLET \
--yes
```
Withdraw validator commission:
```
ollod tx distribution withdraw-rewards $(ollod keys show $OLLO_WALLET --bech val -a) \
--chain-id $OLLO_CHAIN \
--from $OLLO_WALLET \
--commission \
--yes
```
Self delegation:
```
ollod tx staking delegate $(ollod keys show $OLLO_WALLET --bech val -a) <amount_to_delegate>utollo \
--chain-id=$OLLO_CHAIN \
--from=$OLLO_WALLET
```
