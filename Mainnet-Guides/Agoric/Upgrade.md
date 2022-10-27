## Table of contents
- [Upgrade `agoric-upgrade-6`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Upgrade.md#upgrade-agoric-upgrade-6)
- [Upgrade `agoric-upgrade-7`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Upgrade.md#upgrade-agoric-upgrade-7)
- [Upgrade `agoric-upgrade-7-2`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Upgrade.md#upgrade-agoric-upgrade-7-2)
- [Upgrade `agoric-upgrade-8`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Upgrade.md#upgrade-agoric-upgrade-8)

## Upgrade `agoric-upgrade-6`
[[Releases](https://github.com/Agoric/ag0/releases)]
Upgrade was NEEDED at height 5901622. Only after this block you should upgrade your node. Chack it:
```
ag0 status 2>&1 | jq .SyncInfo
```
If your last block is 5901622 - upgrade your binary:
```
rm -rf /root/ag0
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-6
git pull origin agoric-upgrade-6
make build
. $HOME/.bash_profile
$HOME/ag0/build/ag0 version
```
now stop the service, update and start
```
sudo systemctl stop agoricd
cp $HOME/ag0/build/ag0 /usr/local/bin
ag0 version
sudo systemctl start agoricd
ag0 status 2>&1 | jq .SyncInfo
```
Check. The chain will start after 67% active set are upgraded
```
curl -s localhost:26657/dump_consensus_state | jq '.result.round_state.votes[0]'
```
![image](https://user-images.githubusercontent.com/30211801/181161879-7b06a66b-5ac4-4f22-be64-d10516fcc905.png)

## Upgrade `agoric-upgrade-7`
- [[Current Release](https://github.com/Agoric/ag0/releases/tag/agoric-upgrade-7)]
- [Governance](https://ping.pub/agoric/gov/12)
- [Discussion](https://commonwealth.im/agoric/discussion/6367-network-upgrade-discussion-upgrading-mainnet-to-agoricupgrade7)
- [6263783 block](https://agoric.explorers.guru/block/6263783)

Upgrade was NEEDED at height [6263783](https://agoric.explorers.guru/block/6263783). Only after this block you should upgrade your node. Chack it:
```
ag0 status 2>&1 | jq .SyncInfo
```
If your last block is 6263783 - Build new binary from source:
```
rm -rf /root/ag0
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-7
git pull origin agoric-upgrade-7
make build
$HOME/ag0/build/ag0 version
```

Now stop the service
```
sudo systemctl stop agoricd
```
Change binary
```
cp $HOME/ag0/build/ag0 /usr/local/bin
ag0 version
```
Or you can just download the binary:
```
wget -O ag0 https://github.com/Agoric/ag0/releases/download/agoric-upgrade-7/ag0-agoric-upgrade-7-linux-amd64
chmod +x ag0
mv ag0 /usr/local/bin
ag0 version
```
Start
```
sudo systemctl start agoricd
ag0 status 2>&1 | jq .SyncInfo
journalctl -u agoricd -f --output cat
```
Check. The chain will start after 67% active set are upgraded
```
wget -qO- http://localhost:26657/consensus_state \
| jq ".result.round_state.height_vote_set[0].prevotes_bit_array"
```

## Upgrade `agoric-upgrade-7-2`
- [[Current Release](https://github.com/Agoric/ag0/releases/tag/agoric-upgrade-7-2)]

As we downloaded `https://github.com/Agoric/ag0` before, let's update the repository and build the new binary
```
cd ag0
git fetch --all --tags
git checkout tags/agoric-upgrade-7-2
make clean
VERSION=agoric-upgrade-7-2 make build
$HOME/ag0/build/ag0 version
```
Chack sha256sum
```
sha256sum $HOME/ag0/build/ag0
# 3a9ccd3a52a986677a42a89bc00f464f2cb9ef70791461dda6724af7ea2422a4  /root/ag0/build/ag0
```
Now stop the service
```
sudo systemctl stop agoricd
```
Change binary
```
cp $HOME/ag0/build/ag0 /usr/local/bin
ag0 version
```
#Or you can just download the binary:
```
wget -O ag0 https://github.com/Agoric/ag0/releases/download/agoric-upgrade-7-2/ag0-agoric-upgrade-7-2-linux-amd64
chmod +x ag0
mv ag0 /usr/local/bin
ag0 version
```
Start
```
sudo systemctl start agoricd
ag0 status 2>&1 | jq .SyncInfo
journalctl -u agoricd -f --output cat
```

## Upgrade `agoric-upgrade-8`
- [Release](https://github.com/Agoric/agoric-sdk/releases/tag/pismoA)
- [Official guide](https://github.com/Agoric/agoric-sdk/wiki/ag0-to-agd-upgrade-for-mainnet-1-launch)
- [Polkachu guide](https://github.com/polkachu/validator-guide/blob/main/upgrade_guides/agoric/upgrade_agoric-upgrade-8.md)

