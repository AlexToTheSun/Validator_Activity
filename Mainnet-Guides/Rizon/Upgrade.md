## Table of contents
- [Upgrade `v0.4.1`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Desmos/Upgrade.md#upgrade-v0.4.1)

## Upgrade `v0.4.1`
- [[Current Release](https://github.com/rizon-world/rizon/releases/tag/v0.4.1)]

Let's build from source a new binary:
```sh
cd rizon
git fetch --all --tags
git checkout tags/v0.4.1
make clean
# Run GO install and build for the upcoming binary
VERSION=v0.4.1 make install
/root/go/bin/rizond version
# v0.4.1
```
Now stop the service
```
sudo systemctl stop rizond
```
Change binary
```
cp /root/go/bin/rizond /usr/local/bin
/usr/local/bin/rizond version
```

Start
```
sudo systemctl restart rizond
rizond status 2>&1 | jq .SyncInfo
journalctl -u rizond -f --output cat
```
