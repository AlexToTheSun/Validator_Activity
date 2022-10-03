### 1. Selfie! 
`100XP` Delegate any amount of tokens toyour validator:
- `<amount_to_delegate>`
```
haqqd tx staking delegate $(haqqd keys show $HAQQ_WALLET --bech val -a) <amount_to_delegate>aISLM \
--chain-id=$HAQQ_CHAIN \
--from=$HAQQ_WALLET
```
#### Submitting 1 task
Submit a hash of the self delegatin in the task "Selfie!" on the portal https://haqq-val-contest.crew3.xyz/

### 3. Help a friend!
`100XP` Delegate any number of tokens to any other [validator](https://haqq.explorers.guru/validators):
- `<haqqvaloper_address>`
- `<amount_to_delegate>`
```
haqqd tx staking delegate <haqqvaloper_address> <amount_to_delegate>aISLM \
--chain-id=$HAQQ_CHAIN \
--from=$HAQQ_WALLET
```
#### Submitting 3 task
Send the hash of the delegating transaction in the task "Help a friend!" on the portal https://haqq-val-contest.crew3.xyz/

### 2. Get yours!
`100XP` There must be two transactions in total.
1. Withdraw rewards and commission from your validator:
```
haqqd tx distribution withdraw-rewards $(haqqd keys show $HAQQ_WALLET --bech val -a) \
--chain-id $HAQQ_CHAIN \
--from $HAQQ_WALLET \
--commission \
--yes
```
2. Withdraw rewards from the validator **you delegated before**:
- `<haqqvaloper_address>`
```
haqqd tx distribution withdraw-rewards <haqqvaloper_address> \
--chain-id $HAQQ_CHAIN \
--from $HAQQ_WALLET \
--yes
```
#### Submitting 2 task
Submit two hashes of the `withdraw-rewards` transactions in the task "Get yours!" on the portal https://haqq-val-contest.crew3.xyz/

### 2.1 I'll give you the last one! `new`
`150XP` Redelegate tokens from your validator to any other validator!
- `<another_valoper>`
- `<amount_to_delegate>`
```
haqqd tx staking redelegate $(haqqd keys show $HAQQ_WALLET --bech val -a) <another_valoper> 9000000000aISLM \
--chain-id=$HAQQ_CHAIN \
--from=$HAQQ_WALLET
--gas=auto
```
#### Submitting 2.1 task
Send the hash of the redelegating transaction in the task "I'll give you the last one!" on the portal https://haqq-val-contest.crew3.xyz/

### 4. Like a squirrel in a wheel! 👀
`150XP` Your uptime should not fall below 98%.

For this task [Monitoring-And-Alerting](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Monitoring-And-Alerting) can help you.
#### Submitting 4 task
At the end of your active set period - take a screenshot and provide it as confirmation in the task "Like a squirrel in a wheel!" on the portal https://haqq-val-contest.crew3.xyz/

### 5. I'm the only one here!
`200XP` Change the validator parameters: add an image, add a description, and whatever you see fit.
- use `identity` code from https://keybase.io/
```
haqqd tx staking edit-validator \
--from=$HAQQ_WALLET \
--chain-id=$HAQQ_CHAIN \
--website="" \
--identity="" \
--details="" \
--moniker=""
```
#### Submitting 5 task
Send a screenshot of the explorer with how your validator looked before and how it is now in the task "I'm the only one here!" on the portal https://haqq-val-contest.crew3.xyz/

### 6. Law-abiding validator! ❌
`200XP` Do not go to jail the entire time you are in the active set.

For this task [Monitoring-And-Alerting](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Monitoring-And-Alerting) can help you.
#### Submitting 6 task
If you didn't -  then just confirm it by writing "Jail - this is not about me" in the task "Law-abiding validator!" on the portal https://haqq-val-contest.crew3.xyz/

### 7. False alarm! 👀
`250XP` 
- Develop a protection and notification system for your validator.
- Write the public guide written by you about protection and notification system.
#### Submitting 7 task
Send a link to the guide in the task "False alarm!" on the portal https://haqq-val-contest.crew3.xyz/

### 8. Can you hear me? 👀
`250XP` Do not to miss the voting that the team will conduct.
- `<number>`
```
haqqd tx gov vote <number> yes --from $HAQQ_WALLET -y
```

All votings see [here](https://haqq.explorers.guru/proposals) and [here](https://testnet.manticore.team/haqq/gov)
#### Submitting 8 task
Send a hash of your voting transaction in the task "Can you hear me?" on the portal https://haqq-val-contest.crew3.xyz/

### 9. ~~Your opinion!~~
~~Create a proposal that can reach a quorum and be open to a vote. See how to create your own proposal [here](https://hub.cosmos.network/main/governance/submitting.html#sending-the-transaction-that-submits-your-governance-proposal)~~
- ~~Add your moniker to the gover~~
#### ~~Submitting 9 task~~
~~Add your moniker to the gover and attach a link to it in the task "Your opinion!" on the portal https://haqq-val-contest.crew3.xyz/~~

### 13. Work on mistakes!
`700XP` Find any inconsistency in our documents and offer to fix it.
#### Submitting 13 task
Try to describe why you think the changes should be the way they are.

### 14. I will show you to the whole world!
`300XP` Write your own explorer or add our network if you already have it. You can use forks of PingPub explorer, here is the [guide](https://github.com/AlexToTheSun/Validator_Activity/tree/main/Testnet-guides/Haqq/explorer).
#### Submitting 14 task
Try to describe why you think the changes should be the way they are.
Send a link to HAQQ chain in your explorer for the task "I will show you to the whole world!" on the portal https://haqq-val-contest.crew3.xyz/




