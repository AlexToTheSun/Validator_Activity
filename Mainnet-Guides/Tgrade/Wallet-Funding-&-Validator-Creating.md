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
  --amount 0utgd \
  --vesting-amount 285000000000utgd \
  --from $TGRADE_WALLET \
  --pubkey $(sudo tgrade tendermint show-validator --home /opt/validator/.tgrade) \
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
