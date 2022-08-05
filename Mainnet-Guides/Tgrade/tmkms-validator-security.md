# ❗️ In the process of troubleshooting.
Tgrade don't use the sdk prefixes with PoE. So we should to find out non-standard prefixes `account_key_prefix` and `consensus_key_prefix` for Tgrade to use in tmkms.
## Here are instructions to setup TMKMS as a validator security for Tgrade Network
#### Tendermint Key Management System
The official documentation is [[here](https://github.com/iqlusioninc/tmkms#tendermint-kms-)]  
In this article, we will configure `tmkms` on a separate server for the double-signing protection of Tgrade' validators.

Advantage of this method instead of basic installation: 
1) double-signing protection 
2) having the validator keys in separated server.  
## Use Case
If you already run a validator node. It's not too late to set up tmkms. Follow the instructions below.
## Analogue
To prevent double-signing protection, as an analogue, you can use [[horcrux](https://github.com/strangelove-ventures/horcrux)]. 
## Overview
- [Setting up a Validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#setting-up-a-validator-node)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#firewall-configuration)
  - [Edit config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#edit-configtoml)
- [Setting up a tmkms server](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#setting-up-a-tmkms-server)
  - [Install tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#install-tmkms)
  - [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#firewall-configuration)
  - [Init tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#init-tmkms)
  - [Copy priv_validator_key.json from validator node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#copy-priv_validator_keyjson-from-validator-node)
  - [Edit tmkms.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#edit-tmkmstoml)
- [Restert both validator and tmkms](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/tmkms-validator-security.md#restert-both-validator-and-tmkms)

## Setting up a Validator node
We already  [[have](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Wallet-Funding-%26-Validator-Creating.md#upgrade-to-a-validator)] a validator in `tgrade-mainnet-1` mainnet.

### Firewall configuration
Allow access to port 26658 of validator's node for the tmkms server:
```
sudo ufw allow from <ip_tmkms> to any port 26658
```
### Edit config.toml
Open `config.toml` by `nano`:
```
nano $HOME/.tgrade/config/config.toml
```
Edit the line `priv_validator_laddr = ""` like this:
```
priv_validator_laddr = "tcp://<ip_VAL>:26658"
```
where `<ip_VAL>` - ip of the validator' server.  

Or you can enter this value: `priv_validator_laddr = "tcp://<nodeid_VAL>@<ip_VAL>:26658"`. To find out node_id you should type `tgrade tendermint show-node-id'`

**DON'T RESTART validator' service file!!!** Until you have configured the tmkms server.

## Setting up a tmkms server
This server does not require the Tgrade Network node. **tmkms** only.  
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
You should change the SSH port. Click [[here](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Minimum-server-protection.md#change-the-ssh-port)]  
### Init tmkms
```
tmkms init $HOME/.tmkms/tgrade
```
### Copy `priv_validator_key.json` from validator node
Use [WinSCP](https://winscp.net/download/WinSCP-5.19.5-Setup.exe) to copy the `priv_validator_key.json` from the validator's node. And put it in the `$HOME/.tmkms/tgrade` folder.
Then type the command below to import information from `priv_validator_key.json` to `cosmoshub-3-consensus.key`:
```
tmkms softsign import $HOME/.tmkms/tgrade/priv_validator_key.json $HOME/.tmkms/tgrade/secrets/cosmoshub-3-consensus.key
rm $HOME/.tmkms/tgrade/priv_validator_key.json
```
### Edit tmkms.toml
Here is the [tmkms.toml.example](https://github.com/iqlusioninc/tmkms/blob/main/tmkms.toml.example). Open `tmkms.toml` in `nano`
```
nano $HOME/.tmkms/tgrade/tmkms.toml
```
Edit the file like this:
```
# Example Tendermint KMS configuration file

## Chain Configuration

[[chain]]
id = "tgrade-mainnet-1"
key_format = { type = "bech32", account_key_prefix = "tgrade", consensus_key_prefix = "tgrade" }
state_file = "$HOME/.tmkms/tgrade/state/cosmoshub-3-consensus.json"

## Signing Provider Configuration

### Software-based Signer Configuration

[[providers.softsign]]
chain_ids = ["tgrade-mainnet-1"]
key_type = "consensus"
path = "$HOME/.tmkms/tgrade/secrets/cosmoshub-3-consensus.key"

## Validator Configuration

[[validator]]
chain_id = "tgrade-mainnet-1"
addr = "tcp://<ip_VAL>:26658"
secret_key = "$HOME/.tmkms/tgrade/home/secrets/kms-identity.key"
protocol_version = "v0.34"
reconnect = true
```
- `type`, `account_key_prefix`, `consensus_key_prefix` you can see here tgrade' [app.go](https://github.com/confio/tgrade/blob/main/app/app.go#L109)
- `addr` - the validator' server address. Shoud match the `priv_validator_laddr` in tgrade' `config.toml`.
- `protocol_version` - find out `tgrade tendermint version`

## Restert both validator and tmkms
### Start tmkms
Try start on tmkms server
```
tmkms start -c $HOME/.tmkms/tgrade/tmkms.toml
```
If everything is alright then start tmkms as service file.  
**Create the file**
```
sudo tee <<EOF >/dev/null /etc/systemd/system/tmkmtgrade.service
[Unit]  
Description=tmkms Tgrade Network service  
After=network.target  
StartLimitIntervalSec=0
[Service]
Type=simple  
Restart=always  
RestartSec=10  
User=root
ExecStart=/usr/bin/tmkms start -c $HOME/.tmkms/tgrade/tmkms.toml  
LimitNOFILE=1024
[Install]  
WantedBy=multi-user.target
EOF
```
Start tmkmtgrade
```
sudo systemctl enable tmkmtgrade
sudo systemctl daemon-reload
sudo systemctl restart tmkmtgrade
journalctl -u tmkmtgrade -f
```
### Restart `tgrade` service on the server of the validator
```
sudo systemctl restart tgrade
journalctl -u tgrade -f --output cat
```
### Restart tmkms service
```
sudo systemctl restart tmkmtgrade
journalctl -u tmkmtgrade -f
```
Now all should work. Check logs:
```
journalctl -u tmkmtgrade -f --output cat
journalctl -u tgrade -f --output cat
```
Don't forget **to backup and delete** the `priv_validator_key.json` file from the validator node. Now you won't need it. Keep it in a secure place, such as a flash drive.

## Done
Congratulations, your validator now has a solid working architecture. Next step is optional - Tgrade-Osmosis relayer.

## Next optional step
[Tgrade-Osmosis relayer](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Tgrade/Hermes_relayer_Tgrade-Osmosis.md).
