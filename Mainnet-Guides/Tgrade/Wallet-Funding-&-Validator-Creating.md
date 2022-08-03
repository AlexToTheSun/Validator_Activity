## Create your Tgrade wallet
You can create new wallet
```
tgrade keys add $TGRADE_WALLET
```
Or recover it if you already have one
```
tgrade keys add $TGRADE_WALLET --recover
```
## Fund your wallet
We will use [Osmosis Platform](https://app.osmosis.zone/).

Make a USDC deposit from Metamask (ethereum) to Osmosis (cosmos) by [Satellite](https://satellite.money/) and buy TGD. Afte that withdraw tokens to your validator wallet.

## Upgrade to a Validator
Run the following command syntax:
```
tgrade tx poe create-validator \
  --amount 1000000utgd \
  --vesting-amount 0utgd \
  --from $TGRADE_WALLET \
  --pubkey $(sudo tgrade tendermint show-validator --home /root/.tgrade) \
  --chain-id $TGRADE_CHAIN \
  --moniker "$TGRADE_NODENAME" \
  --fees 200000utgd \
  --gas auto \
  --gas-adjustment 1.4 \
  --identity="" \
  --website="" \
  --node "tcp://127.0.0.1:26657" \
  --home /root/.tgrade
```
> ❗️ Note that this command actual if you still don't have engagement points previosly assigned.
> ✅ It is [possible to earn engagement points](https://github.com/confio/tgrade-networks#upgrade-to-a-validator)!

Our validator will appears in the block-explorer: https://tgrade.aneka.io or https://www.mintscan.io/tgrade
### Delegate more liquid and/or vesting tokens to your valiator ( Optional )
```
tgrade tx poe self-delegate 100000000utgd 900000000utgd \
  --from $TGRADE_WALLET \
  --chain-id $TGRADE_CHAIN \
  --fees 10000utgd \
  --node "tcp://127.0.0.1:26657" \
  --home /root/.tgrade
```

## Next step
Now we have a validator.

The next step is validator [double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md).
