## Update to [v0.0.2]
- Chain: `altruistic-1`
- Upgrade block: `580000`
- Official guide: https://github.com/empowerchain/empowerchain/blob/main/testnets/altruistic-1/docs/poe_v2_upgrade.md

### Auto update-restart script
You have to change in the `/etc/systemd/system/empowerd.service` line
```
ExecStart=/root/go/bin/empowerd start
```
to line
```
ExecStart=/usr/local/bin/empowerd start
```
then copy `empowerd` binary to `/usr/local/bin` folder:
```
cp /root/go/bin/empowerd /usr/local/bin/
```
restart service and see logs:
```
systemctl daemon-reload
sudo systemctl restart empowerd && sudo journalctl -u empowerd -f -o cat
```


For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Build new binary:
```
cd empowerchain
git pull
git checkout v0.0.2
cd chain && make build
```
see version:
```
/usr/local/bin/empowerd version
/root/empowerchain/chain/build/empowerd version
```


Set variables:
- `your_rpc_port`
```
current_binary="/usr/local/bin/empowerd"
new_binary="/root/empowerchain/chain/build/empowerd"
halt_height="580000"
service_name="empowerd"
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
/usr/local/bin/empowerd
0.0.2
      "network": "altruistic-1",
      "latest_block_height": "575331",
     Loaded: loaded (/etc/systemd/system/empowerd.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2022-11-10 20:26:55 UTC; 36s ago
```

Create update script:
```
tee $HOME/update_script_empower.sh > /dev/null <<EOF
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
chmod +x $HOME/update_script_empower.sh
```

Create tmux session:
```
tmux new -s update
```

Run script in tmux
```
sudo /bin/bash $HOME/update_script_empower.sh
```
![Снимок экрана от 2022-11-11 00-30-47](https://user-images.githubusercontent.com/30211801/201199968-6a673014-a05b-4366-aec8-3d9f5cf0f53e.png)

Detach from "update" session type `Ctrl+b d` (Script will keep going)

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
sudo journalctl -u empowerd -f -o cat
empowerd status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
- use your uwn rpc port instead `26657`
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```
