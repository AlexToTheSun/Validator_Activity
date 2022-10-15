# Update to 2.0.2
Release [[v2.0.2](https://github.com/confio/tgrade/releases/tag/v2.0.2)]

Let's build a new binary:
```
rm -rf /root/tgrade
git clone https://github.com/confio/tgrade
cd tgrade
git checkout v2.0.2
# Run GO install and build for the upcoming binary
make build
/root/tgrade/build/tgrade version
# 2.0.2
```
Move the binary to an executable path
```
sudo systemctl stop tgrade
cp /root/tgrade/build/tgrade /usr/local/bin
/usr/local/bin/tgrade version
```
Restart and logs
```
sudo systemctl restart tgrade

curl localhost:26657/status | jq
tgrade status 2>&1 | jq .SyncInfo
sudo journalctl -u tgrade -f -o cat
```
