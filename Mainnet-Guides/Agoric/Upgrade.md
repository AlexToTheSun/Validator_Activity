Explorers:
- https://agoric.explorers.guru/
- https://bigdipper.live/agoric/validators
- https://explorer-turetskiy.xyz/agoric
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
#### Install Node.js and yarn
Install node.js v16. Following Node.js download instructions:
```sh
# Download the nodesource PPA for Node.js
curl https://deb.nodesource.com/setup_16.x | sudo bash

# Install the Yarn package manager
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Update Ubuntu
sudo apt-get update
sudo apt upgrade -y

# Install Node.js, Yarn, and build tools
# Install jq for formatting of JSON data
# We'll need git below.
sudo apt install nodejs=16.* yarn build-essential git jq -y

# verify installation
node --version | grep 16
yarn --version
```
#### Install Agoric SDK
We’ll install the Agoric SDK from source using `git clone`.
```sh
# Writeable directory of your choice. $HOME will do.
cd ~
git clone https://github.com/Agoric/agoric-sdk -b pismoA
cd agoric-sdk

# Install and build Agoric Javascript packages
yarn install && yarn build

# Install and build Agoric Cosmos SDK support
(cd packages/cosmic-swingset && make)
```
❗️Note that you will need to keep the `agoric-sdk` directory intact when running the validator, as it contains data files necessary for correct operation.
```
agd version --long
```
The output should start with:
```
name: agoriccosmos
server_name: ag-cosmos-helper
version: 0.32.2
commit: 2c812d221
build_tags: ',ledger'
go: go version go1.18.1 linux/amd64
```
If the software version does not match, then please check your `$PATH` to ensure the correct `agd` is running.
#### Configure `agd.service`
```
sudo tee <<EOF >/dev/null /etc/systemd/system/agd.service
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
# OPTIONAL: turn on JS debugging information.
#SLOGFILE=.agoric/data/chain.slog
User=$USER
# OPTIONAL: turn on Cosmos nondeterminism debugging information
#ExecStart=$HOME/go/bin/agd start --log_level=info --trace-store=.agoric/data/kvstore.trace
ExecStart=$HOME/go/bin/agd start --log_level=warn
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
Environment="PATH=/home/ubuntu/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/ubuntu/agoric-sdk/packages/cosmic-swingset/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable agd
sudo systemctl daemon-reload
```
Check `systemctl status agd`. The result should look like:
```
○ agd.service - Agoric Cosmos daemon
     Loaded: loaded (/etc/systemd/system/agd.service; enabled; vendor preset: enabled)
     Active: inactive (dead)
```
Check that `agd` has access to the same key material that `ag0` was using:
```
ag0 tendermint show-validator
agd tendermint show-validator
```
#### Stop and disable `ag0` (or you may have `agoricd`)
```
sudo systemctl stop ag0
sudo systemctl disable ag0
```
#### Start `agd`
```
sudo systemctl restart agd
agd status 2>&1 | jq .SyncInfo
journalctl -u agd -f --output cat
```

