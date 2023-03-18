# Table of contents
1. [Update to `v1.1.0`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Quicksilver/Update.md#update-to-v123)
2. [Update to `v1.2.7`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Quicksilver/Update.md#update-to-v127) [auto]

## Update to v1.2.3
### Manually
The chain appears to have halted so we need to replace your v1.2.2 binary with v1.2.3 and restart.
```
quicksilverd status 2>&1 | jq .SyncInfo
```


```bash
# Build
cd $HOME 
rm -rf /root/quicksilver
git clone https://github.com/ingenuity-build/quicksilver.git
cd $HOME/quicksilver
git checkout v1.2.3
make install
# Check
quicksilverd version --long | head
$HOME/go/bin/quicksilverd version --long | head

# Update
sudo systemctl stop quicksilverd
cp $HOME/go/bin/quicksilverd /usr/local/bin
sudo systemctl restart quicksilverd
```
Logs and status:
```
sudo journalctl -u quicksilverd -f -o cat
quicksilverd status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```
## Update to v1.2.7
- [Link v1.2.7](https://github.com/ingenuity-build/quicksilver/releases/tag/v1.2.7)
- Height: [1115600](https://quicksilver.explorers.guru/block/1115600)
### Auto update-restart script

For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Build new binary:
```bash
cd $HOME/quicksilver
git fetch --all
git checkout v1.2.7
make install

# Check old binary
quicksilverd version --long | head
# echo $(which quicksilverd) && $(which quicksilverd) version
# Check new binary
$HOME/go/bin/quicksilverd version --long | head
    #version: v1.2.7
    #commit: ce53635a8f372398d2f5f1025cf81d3a5a36f6a8
```
Set variables:
- `your_rpc_port`
```
current_binary="/usr/local/bin/quicksilverd"
new_binary="$HOME/go/bin/quicksilverd"
halt_height="1115600"
service_name="quicksilverd"
rpc_port="your_rpc_port"
```

Check output:
```
echo $current_binary \
&& $new_binary version \
&& curl -s localhost:$rpc_port/status | jq | grep -E 'network|latest_block_height' \
&& service $service_name status | grep -E 'loaded|active'
```
Output example:
```
/usr/local/bin/quicksilverd
v1.2.7
      "network": "quicksilver-2",
      "latest_block_height": "1088764",
     Loaded: loaded (/etc/systemd/system/quicksilverd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2023-03-04 21:11:29 UTC; 1 weeks 6 days ago
```

Create update script:
```
tee $HOME/update_script.sh > /dev/null << EOF
#!/bin/bash
for((;;)); do
  height=\$(curl -s localhost:${rpc_port}/status | jq -r .result.sync_info.latest_block_height)
    if ((height==${halt_height})); then
      systemctl stop ${service_name}
      cp ${new_binary} ${current_binary}
      systemctl restart ${service_name}
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
### tmux command
Detach from "update" session type `Ctrl+b d` (the session will continue to run in the background): 

List of sessions
```
tmux ls
```
Connect to the session again
```
tmux attach -t update
```
> ! Don't stop the script by CTRL+C 

### After updating - kill tmux session:
```
tmux kill-session -t update
```
Logs and status:
```
sudo journalctl -u quicksilverd -f -o cat
quicksilverd status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
- use your uwn rpc port instead `26657`
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```








