# Table of contents
1. [Update to `v1.3.1`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IRISnet/Upgrade.md#upgrade-v131)
2. [Update to `v2.0.0`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/IRISnet/Upgrade.md#upgrade-v200) [auto]

### Official IrisNet github: https://github.com/irisnet/mainnet/tree/master/upgrade

## Upgrade `v1.3.1`
- [[Current Release v1.3.1](https://github.com/irisnet/irishub/releases/tag/v1.3.1)]

As we downloaded `https://github.com/irisnet/irishub` before, let's update the repository and build the new binary
```
cd irishub
git fetch --all --tags
git checkout tags/v1.3.1
git pull origin v1.3.1
make clean
VERSION=v1.3.1 make install
$HOME/go/bin/iris version
```
Chack sha256sum
```
sha256sum $HOME/go/bin/iris
# faebb0f4fcdde86aebb54ad777f028c1acb04edaa99a9ca351554ee2e81dc76e  /root/go/bin/iris
```
Now stop the service
```
sudo systemctl stop irisd
```
Change binary
```
cp $HOME/go/bin/iris /usr/local/bin
iris version
```
#Or you can just download the binary:
```
mkdir /root/iris-new
cd /root/iris-new
wget https://github.com/irisnet/irishub/releases/download/v1.3.1/iris-linux-arm64-v1.3.1.tar.gz | tar xf -
tar -xvf iris-linux-arm64-v1.3.1.tar.gz
mv /root/iris-new/build/iris-linux-arm64 /root/iris-new/build/iris
chmod +x /root/iris-new/build/iris
cp /root/iris-new/build/iris /usr/local/bin
iris version
```
Start
```
sudo systemctl start irisd
iris status 2>&1 | jq .SyncInfo
journalctl -u irisd -f --output cat
```

## Upgrade `v2.0.0`

- [Link v2.0.0](https://github.com/irisnet/mainnet/blob/master/upgrade/v2.0.0.md)
- Height: [19514010](https://www.mintscan.io/iris/blocks/19514010)

### Auto update-restart script

For this script we will use `tmux`
```
sudo apt update && sudo apt install tmux -y
```
Build new binary:
```bash
cd $HOME/irishub
git fetch --all
git checkout v2.0.0
make install
# Check old binary
iris version --long | head
# echo $(which iris) && $(which iris) version
# Check new binary
$HOME/go/bin/iris version --long | head
    #version: v2.0.0
    #commit: 3f885283746f6f5515ba31a06bd4801fa155937b
```
Set variables:
- `your_rpc_port`
```
current_binary="/usr/local/bin/iris"
new_binary="$HOME/go/bin/iris"
halt_height="19514010"
service_name="irisd"
rpc_port="your_rpc_port"
```
Check output:
```
echo $current_binary \
&& $new_binary version \
&& curl -s localhost:$rpc_port/status | jq | grep -E 'network|latest_block_height' \
&& service $service_name status | grep -E 'loaded|active'
```
Output example:
```
/usr/local/bin/iris
2.0.0
      "network": "irishub-1",
      "latest_block_height": "19507740",
     Loaded: loaded (/etc/systemd/system/irisd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2023-04-16 17:52:01 UTC; 1h 9min ago
```
