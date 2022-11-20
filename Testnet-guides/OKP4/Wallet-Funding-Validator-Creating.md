- Github: https://github.com/okp4/okp4d
- Discord faucet: [# 🚰｜faucet](https://discord.gg/okp4) channel
## Create your OKP4 wallet
```
okp4d keys add $OKP_WALLET
```
Now  for creating a validator let's fund it.
## Fund your wallet
Go to the OKP4 discord https://discord.gg/okp4 and find the channel `# 🚰｜faucet`. Type the command `/request` and your OKP4 address.

## Upgrade to a Validator
> For now in OKP4 chain there are 0 fees transaction so you can don't use `flag --fees <amount>uknow`
Below there is a validator creation transaction. Specify:
- Replace `1000000000000000000` with the number of tokens in `uknow` that you want to delegate on your validator. 
- Your website link.
- Identity code from https://keybase.io/
- Details that you would like to specify, for example your Discorsd.

Run the following command syntax:
```
okp4d tx staking create-validator \
  --amount 2000000uknow \
  --from $OKP_WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey  $(okp4d tendermint show-validator) \
  --moniker $OKP_NODENAME \
  --chain-id $OKP_CHAIN \
  --website="" \
  --identity="" \
  --details=""
```
Find out your validator:
https://okp4.explorers.guru/

