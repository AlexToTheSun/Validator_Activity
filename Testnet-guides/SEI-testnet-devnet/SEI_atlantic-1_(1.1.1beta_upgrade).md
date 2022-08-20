

## Updating process for 1.1.1beta release

Check your node block height. You must not ungrade before the block [3223245](https://sei.explorers.guru/block/3223245).
```
seid status 2>&1 | jq .SyncInfo
```
If your last block is 3223245 - build new binary:
```
cd $HOME && rm $HOME/sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git && cd $HOME/sei-chain
git checkout 1.1.1beta
make install

systemctl stop seid
sudo cp /root/go/bin/seid /usr/local/bin/seid
seid version
```

Restart, logs and status
```
systemctl restart seid
journalctl -u seid -f --output cat
seid status 2>&1 | jq .SyncInfo
```
Find out how many % of nodes were updated:
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```
Explorers:
- https://sei.explorers.guru/
