## There is the list of useful commands for Haqq validators
Find out your wallet:
```
haqqd keys show $HAQQ_WALLET -a
```
Your validator:
```
haqqd keys show $HAQQ_WALLET --bech val -a
```
Information about your validator:
```
haqqd query staking validator $(haqqd keys show $HAQQ_WALLET --bech val -a)
```

Logs and status
```
sudo journalctl -u haqqd -f -o cat
curl localhost:26657/status | jq
haqqd status 2>&1 | jq .SyncInfo
```
List of commands to interact with `haqqd.service`
```
sudo systemctl daemon-reload
sudo systemctl enable haqqd
sudo systemctl restart haqqd
sudo systemctl status haqqd

sudo systemctl stop haqqd
sudo systemctl disable haqqd
```
Unsafe-reset-all
```
haqqd tendermint unsafe-reset-all --home $HOME/.haqqd
```
## Tx
- If you have configured your node by `haqqd config node tcp://localhost:26657` then there is no need in `--node "tcp://127.0.0.1:26657"` flag.
- as we have `minimum-gas-prices = 0.0aISLM` so there is no need in `--fees` flag.

How to vote:
- `<prop_ID>` - ID of a proposal. You can find info about Haqq Governance [[here](https://haqq.explorers.guru/proposals)]
```
haqqd tx gov vote <prop_ID> yes --from $HAQQ_WALLET -y
```

Unjail:
```
haqqd tx slashing unjail \
--chain-id $HAQQ_CHAIN \
--from $HAQQ_WALLET
```

Change the validator parameters:
```
haqqd tx staking edit-validator \
--from=$HAQQ_WALLET \
--chain-id=$HAQQ_CHAIN \
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
haqqd q bank balances $(haqqd keys show $HAQQ_WALLET -a)
```
Withdraw all delegation rewards:
```
haqqd tx distribution withdraw-all-rewards --from=$HAQQ_WALLET --chain-id=$HAQQ_CHAIN
```
Withdraw validator commission:
```
haqqd tx distribution withdraw-rewards $(haqqd keys show $HAQQ_WALLET --bech val -a) \
--chain-id $HAQQ_CHAIN \
--from $HAQQ_WALLET \
--commission \
--yes
```
Self delegation:
```
haqqd tx staking delegate $(haqqd keys show $HAQQ_WALLET --bech val -a) <amount_to_delegate>aISLM \
--chain-id=$HAQQ_CHAIN \
--from=$HAQQ_WALLET
```





