## Upgrade `v1.3.1`
- [[Current Release v1.3.1](https://github.com/irisnet/irishub/releases/tag/v1.3.1)]

As we downloaded `https://github.com/irisnet/irishub` before, let's update the repository and build the new binary
```
cd irishub
git fetch --all --tags
git checkout tags/v1.3.1
git pull origin v1.3.0
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
