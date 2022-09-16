- Crew3 website: https://haqq-val-contest.crew3.xyz/
- HAQQ faucet: https://testedge2.haqq.network/
## Create your Haqq wallet
Before you have created your wallet by command:
```
haqqd keys add $HAQQ_WALLET
```
Now  for creating a validator let's fund it.
## Fund your wallet
This instruction is suitable for [intensivized testnet](https://github.com/haqq-network/validators-contest) validators
### 1. Private key
We will use [Metamask](https://metamask.io/download/) and [HAQQ faucet](https://testedge2.haqq.network/)

Now we have a wallet Mnemonic Seed, but to integrate it into Metamask we need a private key. let's export it:
```
haqqd keys export $HAQQ_WALLET --unarmored-hex --unsafe
```
And integrate to metamask.
### 2. Use faucet
Go to [HAQQ faucet](https://testedge2.haqq.network/) and connect to it.
![image](https://user-images.githubusercontent.com/30211801/190628331-9a187560-f21f-4f56-9582-be1bc704d34f.png)
- The site will request a network change. Confirm it.

As you can see in screenshots, we should connect our github to the faucet by pressing a "Login with Github" button.
![image](https://user-images.githubusercontent.com/30211801/190629030-9055201c-76a8-4ef1-a8fb-8b067e8b4568.png)


Ok, now just Request tokens
![image](https://user-images.githubusercontent.com/30211801/190629161-64bef732-cdfd-40be-acd1-de7e17900d50.png)

## Upgrade to a Validator
> For now in Haqq chain there are 0 fees transaction so you can don't use `flag --fees <amount>aISLM`

Below there is a validator creation transaction. Specify:
- Replace `1000000000000000000` with the number of tokens in aISLM that you want to delegate on your validator. 
- Your website link.
- Identity code from https://keybase.io/
- Details that you would like to specify, for example your Discorsd.

Run the following command syntax:
```
haqqd tx staking create-validator \
    --pubkey=$(haqqd tendermint show-validator) \
    --moniker=$HAQQ_NODENAME \
    --amount=1000000000000000000aISLM \
    --min-self-delegation=1000000 \
    --commission-max-change-rate=0.01 \
    --commission-max-rate=0.1 \
    --commission-rate=0.07 \
    --chain-id=$HAQQ_CHAIN \
    --from=$HAQQ_WALLET \
    --website="" \
    --identity="" \
    --details=""
```
Find out your validator:
https://haqq.explorers.guru/validators
















