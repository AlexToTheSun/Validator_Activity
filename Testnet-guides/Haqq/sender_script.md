Create new wallet without keyring pass:
```
haqqd keys add new_wallet --keyring-backend test
```
Fund new wallet:
```
haqqd tx bank send $HAQQ_WALLET $(haqqd keys show new_wallet -a --keyring-backend test) 5000000000000000000aISLM --chain-id=$HAQQ_CHAIN
```
Create a script:
```
tee $HOME/sender_script.sh > /dev/null <<EOF
#!/bin/bash
while command ; do
#  haqqd tx staking delegate haqqvaloper1s4qhe4dy8ghm2c23f85ey8hzxfcc5vmdyke329 10aISLM --chain-id=haqq_54211-3 --from=new_wallet --keyring-backend test -y
   haqqd tx bank send $(haqqd keys show new_wallet -a --keyring-backend test) $(haqqd keys show new_wallet -a --keyring-backend test) 10aISLM --chain-id=haqq_54211-3 --keyring-backend test -y
    sleep 4 || break
done
EOF
```
Make the script executable:
```
chmod +x $HOME/sender_script.sh
```
Create tmux session:
```
tmux new -s update
```
Run script in tmux
```
sudo /bin/bash $HOME/sender_script.sh
```
