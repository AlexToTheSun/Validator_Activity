Official instruction is here https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/upgrading.md

# BackUp
Make a complete copy of your `$HOME/.gravity folder`.
```
cp -r --reflink=auto ~/.gravity gravity-bridge-mercury-2-backup/
```
This will take a long time to run, if you are not using BTRFS or ZFS, you will need a lot of free disk space.
 If you do not have sufficient disk space to backup your entire gravity folder backup your `priv_validator_state.json`
```
cp ~/.gravity/data/priv_validator_state.json validator-state-backup.json
```
If all goes well you will not need either of these. If the upgrade fails we will roll back to this backup state and try to run it again, if you don't have a backup you will be unable to roll back, or worse you may double sign.
# Stop
```
sudo systemctl stop gravity-node
sudo systemctl stop orchestrator
```
# Upgrading
```
mkdir gravity-bin && cd gravity-bin
```
Upgrading gravity chain binary
```
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.5.2/gravity-linux-amd64
mv gravity-linux-amd64 gravity
chmod +x gravity
cp /root/gravity-bin/gravity /usr/bin/
gravity version
```
Upgrading GBT
```
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.5.2/gbt
chmod +x *
sudo mv * /usr/bin/
gbt --version
```
# Restart the chain
```
service gravity-node start
service orchestrator restart
```
# Logs
```
journalctl -u gravity-node.service -f --output cat
journalctl -u orchestrator -f
```
