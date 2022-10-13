# Table of contents
1. Update to `v1.1.0`
   - [Manually](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md#manually)
   - [Auto update-restart script](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md#auto-update-restart-script)
2. Update to `v1.2.0`
   - [Manually](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md#manually-2)
   - [Auto update-restart script](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md#auto-update-restart-script-2)
3. Genesis update guide `haqq_54211-3`
   - [Manually](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Update.md#genesis-update-guide-haqq_54211-3)

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



## Update to [v1.2.0](https://github.com/haqq-network/haqq/releases/tag/v1.2.0)

### Manually 2
Check your node block height. You must not ungrade before the block [355555](https://haqq.explorers.guru/block/355555).
```
haqqd status 2>&1 | jq .SyncInfo
```

If your last block is 355555 - build new binary:
```
# Build
cd $HOME && rm -rf /root/haqq
git clone https://github.com/haqq-network/haqq && cd cd $HOME/haqq
git checkout v1.2.0
make install

# Check
$HOME/go/bin/haqqd version
$HOME/go/bin/haqqd version --long | head

# Update
sudo systemctl stop haqqd
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


### Auto update-restart script 2
For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Build new binary:
```
cd $HOME && rm -rf /root/haqq
git clone https://github.com/haqq-network/haqq && cd $HOME/haqq
git checkout v1.2.0
make install
```
Set variables:
- `your_rpc_port`
```
current_binary="/usr/local/bin/haqqd"
new_binary="$HOME/go/bin/haqqd"
halt_height="355555"
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
Output example:
```
/usr/local/bin/haqqd
"1.2.0"
      "network": "haqq_54211-2",
      "latest_block_height": "353428",
     Loaded: loaded (/etc/systemd/system/haqqd.service; disabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-09-27 12:31:46 UTC; 1 weeks 0 days ago
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
- use your uwn rpc port instead `26657`
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```
### Troubleshooting
If you get errors like:
```
6:55PM INF executed block height=355560 module=consensus num_invalid_txs=0 num_valid_txs=0 server=node
panic: cannot delete latest saved version (6)

ERR CONSENSUS FAILURE!!! err="cannot delete latest saved version (6)" module=consensus server=node stack="goroutine 2798
```
These errors was in the previous evmos upgrade, we should temporary use `pruning = nothing`:
```
sed -i -e "s/^pruning *=.*/pruning = \"nothing\"/" $HOME/.haqqd/config/app.toml
```

## Genesis update guide `haqq_54211-3`
### Manually 3
Stop the node
```
sudo systemctl stop haqqd
```
Download new genesis
```
cd $HOME/.haqqd/config && rm -rf genesis.json && wget https://github.com/haqq-network/validators-contest/raw/master/genesis.json
```
Check genesis.json
```
sha256sum $HOME/.haqqd/config/genesis.json
# b93f2650bdf560cab2cf7706ecee72bfba6d947fa57f8b1b8cb887f8b428233f
```
Execute unsafe-reset-all (make a backup of node_key.json and priv_validator_key.json before)
```
cp $HOME/.haqqd/config/priv_validator_key.json $HOME/.haqqd/priv_validator_key.json.backup && \
cp $HOME/.haqqd/config/node_key.json $HOME/.haqqd/node_key.json.backup

haqqd tendermint unsafe-reset-all --home=$HOME/.haqqd
```
Insertion of seeds and peers
```
seeds="62bf004201a90ce00df6f69390378c3d90f6dd7e@seed2.testedge2.haqq.network:26656,23a1176c9911eac442d6d1bf15f92eeabb3981d5@seed1.testedge2.haqq.network:26656"
peers="b3ce1618585a9012c42e9a78bf4a5c1b4bad1123@65.21.170.3:33656,952b9d918037bc8f6d52756c111d0a30a456b3fe@213.239.217.52:29656,85301989752fe0ca934854aecc6379c1ccddf937@65.109.49.111:26556,d648d598c34e0e58ec759aa399fe4534021e8401@109.205.180.81:29956,f2c77f2169b753f93078de2b6b86bfa1ec4a6282@141.95.124.150:20116,eaa6d38517bbc32bdc487e894b6be9477fb9298f@78.107.234.44:45656,37513faac5f48bd043a1be122096c1ea1c973854@65.108.52.192:36656,d2764c55607aa9e8d4cee6e763d3d14e73b83168@66.94.119.47:26656,fc4311f0109d5aed5fcb8656fb6eab29c15d1cf6@65.109.53.53:26656,297bf784ea674e05d36af48e3a951de966f9aa40@65.109.34.133:36656,bc8c24e9d231faf55d4c6c8992a8b187cdd5c214@65.109.17.86:32656"
sed -i -e 's|^seeds *=.*|seeds = "'$seeds'"|; s|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.haqqd/config/config.toml
```
Change var of chain_id in bash_profile manually to `haqq_54211-3`
```
nano $HOME/.bash_profile
```
Update
```
source $HOME/.bash_profile
```
Config your node by changing client.toml
```
haqqd config chain-id $HAQQ_CHAIN
```
Restart
```
sudo systemctl restart haqqd
```
Logs and status
```
sudo journalctl -u haqqd -f -o cat
curl localhost:26657/status | jq
haqqd status 2>&1 | jq .SyncInfo
```




