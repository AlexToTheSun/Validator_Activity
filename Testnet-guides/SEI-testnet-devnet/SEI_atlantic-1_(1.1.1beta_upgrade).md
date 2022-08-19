

## Updating process for 1.1.1beta release
Build new binary
```
cd $HOME && rm $HOME/sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git && cd $HOME/sei-chain
git checkout 1.1.1beta
make install

sudo cp /root/go/bin/seid /usr/local/bin/seid
seid version
```

Restart, logs and status
```
systemctl restart seid
journalctl -fu seid -o cat
seid status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```
