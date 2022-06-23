## Tendermint Key Management System (separated server)
The official documentation is [[here](https://github.com/iqlusioninc/tmkms#tendermint-kms-)]
In this article, we will configure `tmkms` on a separate server for the double-signing protection of the Gravity' validator.

[Software-Only](https://github.com/iqlusioninc/tmkms#software-only-not-recommended) signing is not recommended, but 
if you set this on a separate server, then this will take precedence over the absence of tmkms.  

Advantage of this method instead of basic installation: 
1) double-signing protection 
2) having the validator keys in separated server.  
## Use Case
If you already run a validator node. It's not too late to set up tmkms. Follow the instructions below.
## Analogue
To prevent double-signing protection, as an analogue, you can use [[horcrux](https://github.com/strangelove-ventures/horcrux)]. 
## Overview
- [Setting up a Validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#setting-up-a-validator-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#edit-configtoml)
- [Setting up a tmkms server](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#setting-up-a-tmkms-server)
  - [Install tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#install-tmkms)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#firewall-configuration-1)
  - [Init tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#init-tmkms)
  - [Copy priv_validator_key.json from validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#copy-priv_validator_keyjson-from-validator-node)
  - [Edit tmkms.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#edit-tmkmstoml)
- [Restert both validator and tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/tmkms-(separated-server).md#restert-both-validator-and-tmkms)

## Setting up a Validator node
We already [[run](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Axelar/Basic-Installation.md)] a validator node.
### Firewall configuration
Allow access to port 26658 of validator's node for the tmkms server:
```
sudo ufw allow from <ip_tmkms> to any port 26658
```
### Edit config.toml
Open `config.toml` by `nano`:
```
nano $HOME/.axelar/config/config.toml
```
Edit the line `priv_validator_laddr = ""` like this:
```
priv_validator_laddr = "tcp://<ip_VAL>:26658"
```
where `<ip_VAL>` - ip of the validator' server.  

Or you can enter this value: `priv_validator_laddr = "tcp://<nodeid_VAL>@<ip_VAL>:26658"`. To find out node_id you should type `curl localhost:26657/status | jq '.result.node_info.id'`

**DON'T RESTERT validator' service file!!!** Until you have configured the tmkms server.

## Setting up a tmkms server
This server does not require the Gravity blockchain. **tmkms** only.  
The official documentation is [[here](https://github.com/iqlusioninc/tmkms#tendermint-kms-)]
### Install tmkms
Update & upgrade
```
sudo apt update && sudo apt upgrade -y
```
THen you will need the following prerequisites:
```
sudo apt-get install -y gcc clang pkg-config libusb-1.0-0-dev
```
And also package:
```
sudo apt-get install -y \
make \
build-essential \
libssl-dev \
jq \
curl \
ncdu \
git \
g++ \
make \
mc \
nano
```
Then install rustup  https://rustup.rs/
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cp $HOME/.cargo/bin/* /usr/bin/
rustup version
```
Configure RUSTFLAGS environment variable (x86_64 only):
```
echo 'export RUSTFLAGS=-Ctarget-feature=+aes,+ssse3' >> $HOME/.bash_profile
. $HOME/.bash_profile
```
Compiling `tmkms` from source code. In our case, we use the flag `--features=softsign`
```
git clone https://github.com/iqlusioninc/tmkms.git && cd tmkms
cargo build --release --features=softsign
cp /root/tmkms/target/release/tmkms /usr/bin/
tmkms version
```
### Firewall configuration
Installing and configuration ufw
```
sudo apt ufw install -y
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 26658
sudo ufw enable
sudo ufw status
ss -tulpn
```
You should change the SSH port. Click [[here](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#change-the-ssh-port)]  
### Init tmkms
```
tmkms init $HOME/.tmkms/axelar
```
### Copy `priv_validator_key.json` from validator node
Use [WinSCP](https://winscp.net/download/WinSCP-5.19.5-Setup.exe) to copy the `priv_validator_key.json` from the validator's node. And put it in the `$HOME/.tmkms/axelar` folder.
Then type the command below to import information from `priv_validator_key.json` to `cosmoshub-3-consensus.key`:
```
tmkms softsign import $HOME/.tmkms/axelar/priv_validator_key.json $HOME/.tmkms/axelar/secrets/cosmoshub-3-consensus.key
rm $HOME/.tmkms/axelar/priv_validator_key.json
```
### Edit tmkms.toml
Open `tmkms.toml` in `nano`
```
nano $HOME/.tmkms/axelar/tmkms.toml
```
Edit the file like this:
```
# Example Tendermint KMS configuration file
## Chain Configuration
[[chain]]
id = "axelar-testnet-casablanca-1"
key_format = { type = "bech32", account_key_prefix = "axelarpub", consensus_key_prefix = "axelarvalconspub" }
state_file = "$HOME/.tmkms/axelar/state/cosmoshub-3-consensus.json"
## Signing Provider Configuration
### Software-based Signer Configuration
[[providers.softsign]]
chain_ids = ["axelar-testnet-casablanca-1"]
key_type = "consensus"
path = "$HOME/.tmkms/axelar/secrets/cosmoshub-3-consensus.key"
## Validator Configuration
[[validator]]
chain_id = "axelar-testnet-casablanca-1"
addr = "tcp://<ip_VAL>:26658"
secret_key = "$HOME/.tmkms/axelar/home/secrets/kms-identity.key"
protocol_version = "v0.34"
reconnect = true
```
- `addr` - the validator' server address. Shoud match the `priv_validator_laddr` in axelar' `config.toml`.
- `protocol_version` - find out `axelard tendermint version`
## Restert both validator and tmkms
### Start tmkms
Try start on tmkms server
```
tmkms start -c $HOME/.tmkms/axelar/tmkms.toml
```
If everything is alright then start tmkms as service file.  
**Create the file**
```
sudo tee <<EOF >/dev/null /etc/systemd/system/tmkmsaxelar.service
[Unit]  
Description=tmkms axelar service  
After=network.target  
StartLimitIntervalSec=0
[Service]
Type=simple  
Restart=always  
RestartSec=10  
User=root
ExecStart=/usr/bin/tmkms start -c $HOME/.tmkms/axelar/tmkms.toml  
LimitNOFILE=1024
[Install]  
WantedBy=multi-user.target
EOF
```
Start tmkmsgravity
```
sudo systemctl enable tmkmsaxelar
sudo systemctl daemon-reload
sudo systemctl restart tmkmsaxelar
journalctl -u tmkmsaxelar -f
```
### Restart gravity service on the server of the validator
```
sudo systemctl restart gravity-node
journalctl -u axelard -f --output cat
```
### Restart tmkms service
```
sudo systemctl restart tmkmsaxelar
journalctl -u tmkmsaxelar -f
```
Now all should work! Check logs:
```
journalctl -u tmkmsaxelar -f --output cat
journalctl -u axelard -f --output cat
```
Don't forget **to backup and delete** the `priv_validator_key.json` file from the validator node. Now you won't need it. Keep it in a secure place, such as a flash drive.

Thank you for your attention.
