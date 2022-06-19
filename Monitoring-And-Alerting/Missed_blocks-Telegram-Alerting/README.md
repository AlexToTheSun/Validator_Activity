This type of alerting does not collect private data, so if the server on which the missed-blocks-checker is installed will be hacked, then the attacker will not receive logs from servers with a validator. 
## Overview
In this tutorial, we will install and setup [missed-blocks-checker](https://github.com/solarlabsteam/missed-blocks-checker):
- Prepare the server for missed-blocks-checker
- Installing
- Setup service file
- Configure the Alerting by `config.toml`
- Start Service
- Setup Notifications in Telegram 
## Prepare the server for missed-blocks-checker
Update
```
sudo apt update && sudo apt upgrade -y
sudo apt-get install make git jq curl gcc g++ mc nano -y
```
Install go
```
wget -O go1.18.linux-amd64.tar.gz https://go.dev/dl/go1.18.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz && rm go1.18.linux-amd64.tar.gz
cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
```
Setup [Server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md)
## Installing
clone the repo and build it. This will generate a ./main binary file in the repository folder:
```
git clone https://github.com/solarlabsteam/missed-blocks-checker
cd missed-blocks-checker
go build
```
