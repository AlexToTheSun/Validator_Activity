### Create your OllO wallet
```
ollod keys add $OLLO_WALLET
```
### Fund the wallet
Go to the [discord channel](https://discord.gg/gEeJFS8ePR) in `#testnet-faucet` and send the command:
```
!request <YOUR_OLLO_ADDRESS>
```
### Upgrade to a Validator
For now in OllO chain there are 0 fees transaction so you can don't use flag --fees <amount>utollo .

Below there is a validator creation transaction. Specify:
- Your website link
- Identity code from https://keybase.io/
- Details that you would like to specify, for example your Discorsd
  
Run the following command syntax:
```
ollod tx staking create-validator \
  --amount 1000000utollo \
  --from $OLLO_WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey  $(ollod tendermint show-validator) \
  --moniker $OLLO_NODENAME \
  --chain-id $OLLO_CHAIN \
  --website="https://github.com/AlexToTheSun" \
  --identity="" \
  --details=""
```
Find out your validator: http://turnodes.com/ollo/staking







