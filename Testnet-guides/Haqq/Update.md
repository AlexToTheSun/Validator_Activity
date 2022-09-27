# Table of contetn
1. Update to `v1.1.0`
   - [Manually](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md#manually)
   - [Auto update-restart script](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md#auto-update-restart-script)
## Update to v1.1.0
### Manually
Check your node block height. You must not ungrade before the block [256200](https://haqq.explorers.guru/block/256200).
```
haqqd status 2>&1 | jq .SyncInfo
```

If your last block is 256200 - build new binary:
```
# Build
cd $HOME && rm -rf /root/haqq
git clone https://github.com/haqq-network/haqq && cd cd $HOME/haqq
git checkout v1.1.0
make install

# Check
$HOME/go/bin/haqqd version
$HOME/go/bin/haqqd version --long | head

# Update
sudo systemctl stop haqqd
cp $HOME/go/bin/haqqd /usr/local/bin
sudo systemctl restart haqqd
```
Logs and status:
```
sudo journalctl -u haqqd -f -o cat
haqqd status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```


### Auto update-restart script
For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Build new binary:
```
cd $HOME && rm -rf /root/haqq
git clone https://github.com/haqq-network/haqq && cd $HOME/haqq
git checkout v1.1.0
make install
```
Set variables:
- `your_rpc_port`
```
current_binary="/usr/local/bin/haqqd"
new_binary="$HOME/go/bin/haqqd"
halt_height="256200"
service_name="haqqd"
rpc_port="your_rpc_port"
```

Check output:
```
echo $current_binary \
&& $new_binary version \
&& curl -s localhost:$rpc_port/status | grep -E 'network|latest_block_height' \
&& service $service_name status | grep -E 'loaded|active'
```

Create update script:
```
tee $HOME/update_script.sh > /dev/null <<EOF
#!/bin/bash
for((;;)); do
  height=\$(curl -s localhost:$rpc_port/status | jq -r .result.sync_info.latest_block_height)
    if ((height==$halt_height)); then
      mv $new_binary $current_binary
      systemctl restart $service_name
      echo restart
      break
    else
      echo \$height
    fi
  sleep 3
done
EOF
```
Make the script executable:
```
chmod +x $HOME/update_script.sh
```

Create tmux session:
```
tmux new -s update
```

Run script in tmux
```
sudo /bin/bash $HOME/update_script.sh
```
> Don't close the session by CTRL+C 

After updating - kill tmux session:
```
tmux kill-session -t update
```
Logs and status:
```
sudo journalctl -u haqqd -f -o cat
haqqd status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```
