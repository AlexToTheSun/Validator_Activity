# Table of contents
1. [Update to 1.7.2](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Upgrade.md#update-to-172-with-new-fixes)
2. [Update to 1.8.1](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Upgrade.md#update-to-181)
## Update to 1.7.2 with new fixes
### Manually
Check your node block height. You must not ungrade before the block [4146500](https://www.mintscan.io/gravity-bridge/blocks/4146500).
```
gravity status 2>&1 | jq .SyncInfo
```

If your last block is 4146500 - Upgrade the binary:
```
rm -rf /root/gravity-bin && mkdir gravity-bin && cd gravity-bin
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.7.2/gravity-linux-amd64
mv gravity-linux-amd64 gravity
chmod +x gravity
cp /root/gravity-bin/gravity /usr/bin/
gravity version

```
Restart the `gravity-node.service`:
```
sudo systemctl restart gravity-node
```
Logs and status:
```
sudo journalctl -u gravity-node -f -o cat
gravity status 2>&1 | jq
gravity status 2>&1 | jq .SyncInfo
```

### Auto update-restart script
For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Download new version:
```
rm -rf /root/gravity-bin && mkdir gravity-bin && cd gravity-bin
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.7.2/gravity-linux-amd64
mv gravity-linux-amd64 gravity
chmod +x gravity
cd $HOME

# New version:
/root/gravity-bin/gravity version

# Old version:
/usr/bin/gravity version
```
Set variables:
-  check and write to the var your `your_rpc_port`
```
current_binary="/usr/bin/gravity"
new_binary="/root/gravity-bin/gravity"
halt_height="4146500"
service_name="gravity-node"
rpc_port="your_rpc_port"
```
Check output:
```
echo $current_binary \
&& $new_binary version \
&& curl -s localhost:$rpc_port/status | grep -E 'network|latest_block_height' \
&& service $service_name status | grep -E 'loaded|active'
```
Output example:
```
/usr/bin/gravity
v1.7.2
      "network": "gravity-bridge-3",
      "latest_block_height": "4144948",
     Loaded: loaded (/etc/systemd/system/gravity-node.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2022-10-15 12:51:09 UTC; 24min ago
```
Create update script:
```
tee $HOME/update_script.sh > /dev/null <<EOF
#!/bin/bash
for((;;)); do
  height=\$(curl -s localhost:$rpc_port/status | jq -r .result.sync_info.latest_block_height)
    if ((height==$halt_height)); then
      systemctl stop $service_name
      cp $new_binary $current_binary
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
You will see this:
![Снимок экрана от 2022-10-15 17-19-48](https://user-images.githubusercontent.com/30211801/195988635-8060798d-8e27-4fb3-8cf2-aac998566359.png)


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
> Don't stop the script by CTRL+C 

### After updating 
Logs and status:
```
sudo journalctl -u gravity-node -f -o cat
gravity status 2>&1 | jq .SyncInfo
```

Kill tmux session:
```
tmux kill-session -t update
```
Find out how many % of nodes were updated:
- use your uwn rpc port instead `26657`
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```

## Update to 1.8.1
### Manually 1.8.1
Check your node block height. You must not ungrade before the block [5264000](https://www.mintscan.io/gravity-bridge/blocks/5264000).
```
gravity status 2>&1 | jq .SyncInfo
```

If your last block is 5264000 - Upgrade the binary:
```sh
# gravity chain binary
rm -rf /root/gravity-bin && mkdir gravity-bin && cd gravity-bin
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.8.1/gravity-linux-amd64
mv gravity-linux-amd64 gravity

# gbt binary
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.8.1/gbt

chmod +x *
sudo mv * /usr/bin/
gravity version
gbt --version
```
Restart the `gravity-node.service` and `orchestrator.service` :
```
sudo systemctl restart gravity-node
sudo service orchestrator restart
```
Logs and status:
```
sudo journalctl -u gravity-node -f -o cat
journalctl -u orchestrator -f --output cat
gravity status 2>&1 | jq
gravity status 2>&1 | jq .SyncInfo
```

### Auto update-restart script 1.8.1
For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Download new version:
```
rm -rf /root/gravity-bin && mkdir gravity-bin && cd gravity-bin
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.8.1/gravity-linux-amd64
mv gravity-linux-amd64 gravity
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.8.1/gbt
chmod +x *
cd $HOME

# New version:
/root/gravity-bin/gravity version
gravity version
/root/gravity-bin/gbt --version


# Old version:
/usr/bin/gravity version
/usr/bin/gbt --version
```
Set variables:
-  check and write to the var your `your_rpc_port`
```
current_grav_binary="/usr/bin/gravity"
new_grav_binary="/root/gravity-bin/gravity"
current_gbt_binary="/usr/bin/gbt"
new_gbt_binary="/root/gravity-bin/gbt"
halt_height="5264000"
service_grav_name="gravity-node"
service_gbt_name="orchestrator"
rpc_port="your_rpc_port"
```
Check output:
```
echo $current_binary \
&& $new_binary version \
&& curl -s localhost:$rpc_port/status | grep -E 'network|latest_block_height' \
&& service $service_grav_name status | grep -E 'loaded|active' \
&& service $service_gbt_name status | grep -E 'loaded|active'
```
Create update script:
```
tee $HOME/update_script.sh > /dev/null <<EOF
#!/bin/bash
for((;;)); do
  height=\$(curl -s localhost:$rpc_port/status | jq -r .result.sync_info.latest_block_height)
    if ((height==$halt_height)); then
      systemctl stop $service_grav_name
      systemctl stop $service_gbt_name
      cp $new_grav_binary $current_grav_binary
      cp $new_gbt_binary $current_gbt_binary
      systemctl restart $service_grav_name
      systemctl restart $service_gbt_name
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
You will see this:
![Снимок экрана от 2022-10-15 17-19-48](https://user-images.githubusercontent.com/30211801/195988635-8060798d-8e27-4fb3-8cf2-aac998566359.png)


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
> Don't stop the script by CTRL+C 
### After updating 
Logs and status:
```
sudo journalctl -u gravity-node -f -o cat
gravity status 2>&1 | jq .SyncInfo
```

Kill tmux session:
```
tmux kill-session -t update
```
Find out how many % of nodes were updated:
- use your uwn rpc port instead `26657`
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```
