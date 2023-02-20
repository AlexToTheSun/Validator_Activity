For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Download v0.2.5 binary:
```
mkdir /root/uptick-bin-v0.2.5
cd /root/uptick-bin-v0.2.5

wget https://github.com/UptickNetwork/uptick/releases/download/v0.2.5/uptick-linux-amd64-v0.2.5.tar.gz
tar -zxvf uptick-linux-amd64-v0.2.5.tar.gz
chmod +x ./uptickd
```
Set variables:
- where `YOUR_rpc_port` you can find in the  file `/root/.uptickd/config/config.toml` in the [rpc] section.
```
rpc_port="YOUR_rpc_port"
current_binary="/usr/local/bin/uptickd"
new_binary="/root/uptick-bin-v0.2.5/uptickd"
halt_height="2160300"
service_name="uptickd"
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
/usr/local/bin/uptickd
v0.2.5
      "network": "uptick_7000-2",
      "latest_block_height": "2157920",
     Loaded: loaded (/etc/systemd/system/uptickd.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2022-11-30 12:57:47 UTC; 2 months 21 days ago
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
DONE!

## Useful Commands
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
sudo journalctl -u uptickd -f -o cat
uptickd status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
- use your uwn rpc port instead `26657`
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```


