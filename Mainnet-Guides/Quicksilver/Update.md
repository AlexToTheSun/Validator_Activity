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
