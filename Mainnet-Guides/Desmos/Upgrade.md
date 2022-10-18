## Table of contents
- [Upgrade `v2.4.0`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Desmos/Upgrade.md#upgrade-v2.4.0)

## Upgrade `v2.4.0`


- [[Current Release](https://github.com/desmos-labs/desmos/releases/tag/v2.4.0)]

Let's download the new binary:
```
mkdir /root/desmos-new && cd /root/desmos-new
wget https://github.com/desmos-labs/desmos/releases/download/v2.4.0/desmos-2.4.0-linux-amd64
mv desmos-2.4.0-linux-amd64 desmos
chmod +x desmos
/root/desmos-new/desmos version
```
Chack sha256sum
```
sha256sum /root/desmos-new/desmos
# 796e7c6cad91d675a0cf2c1ad9b1ccfe18a185d974a9b234279c76416bb93822  /root/desmos-new/desmos
```
Now stop the service
```
sudo systemctl stop desmosd
```
Change binary
```
cp desmos /usr/local/bin
/usr/local/bin/desmos version
```

Start
```
sudo systemctl restart desmosd
desmos status 2>&1 | jq .SyncInfo
journalctl -u desmosd -f --output cat
```
