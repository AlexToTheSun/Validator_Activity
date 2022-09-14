## Create your Umee wallet
You can create new wallet
```
umeed keys add $UMEE_WALLET
```
Or recover it if you already have one
```
umeed keys add $UMEE_WALLET --recover
```
## Fund your wallet
We will use [Osmosis Platform](https://app.osmosis.zone/).

Make a USDC deposit from Metamask (ethereum) to Osmosis (cosmos) by [Satellite](https://satellite.money/) and buy UMEE. Afte that withdraw tokens to your validator wallet.

## Upgrade to a Validator
Replace `<your_amount>` with the number of tokens in `uumee`. Run the following command syntax:
```
umeed tx staking create-validator \
    --pubkey=$(umeed tendermint show-validator) \
    --moniker=$UMEE_NODENAME \
    --amount=<your_amount>uumee \
    --min-self-delegation=1 \
    --commission-max-change-rate=0.01 \
    --commission-max-rate=0.1 \
    --commission-rate=0.03 \
    --gas=auto \
    --gas-adjustment 1.4 \
    --fees=60000uumee \
    --chain-id=$UMEE_CHAIN \
    --from=$UMEE_WALLET \
    --website=""
    --identity="" \
    --details=""
```
Our validator will appears in the block-explorer: https://umee.explorers.guru or https://www.mintscan.io/umee
### Delegate more tokens to your valiator ( Optional )
```
umeed tx staking delegate --node "tcp://127.0.0.1:26657" $(umeed keys show $UMEE_WALLET --bech val -a) <your_amount>uumee \
--chain-id=$UMEE_CHAIN \
--from=$UMEE_WALLET \
--gas=auto \
--gas-adjustment 1.4 \
--fees=60000uumee
```

## Next step
Now we have a validator.

The next step is validator [double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Umee/tmkms-validator-security.md).
