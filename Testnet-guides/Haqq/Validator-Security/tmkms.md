## Here is the instruction to setup TMKMS as a Key Management System for Haqq validator.
#### Tendermint Key Management System
The official documentation is [[here](https://github.com/iqlusioninc/tmkms#tendermint-kms-)]  

Advantage of this method instead of basic installation: 
1) double-signing protection 
2) having the validator keys in separated server.  
## Use Case
If you already run a validator node. It's not too late to set up tmkms. Follow the instructions below.
## Analogue
To prevent double-signing protection, as an analogue, you can use [[horcrux](https://github.com/strangelove-ventures/horcrux)]. 


# Setting up a Validator node
We already  [[have](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Node-insallation.md)] a validator in `haqq_54211-2` testnet.

### Firewall configuration
Allow access to port 26658 of validator's node for the tmkms server. Run the command below on a validator node:
```
sudo ufw allow from <ip_tmkms> to any port 26658
```
### Edit config.toml
Open `config.toml` by `nano`:
```
nano $HOME/.haqqd/config/config.toml
```
Edit the line `priv_validator_laddr = ""` like this:
```
priv_validator_laddr = "tcp://<ip_VAL>:26658"
```
where `<ip_VAL>` - ip of the validator' server.  

Or you can enter this value: `priv_validator_laddr = "tcp://<nodeid_VAL>@<ip_VAL>:26658"`. To find out node_id you should type `haqqd tendermint show-node-id'`

**DON'T RESTART validator' service file!!!** Until you have configured the tmkms server.

# Setting up a tmkms server
This server does not require the Haqq Network node. **tmkms** only.  
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
You should change the SSH port. Click [[here](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Haqq/Validator-Security/Minimum-server-protection.md#change-the-ssh-port)]  

### Init tmkms
```
tmkms init $HOME/.tmkms/haqq
```
![image](https://user-images.githubusercontent.com/30211801/192980364-95896f3c-fd06-4b55-a5b8-b866cc212f58.png)

### Copy `priv_validator_key.json` from validator node
Use scp command to copy priv_validator_key.json from validator to your VM running TMKMS:
```
scp root@123.456.32.123:~/.haqqd/config/priv_validator_key.json ~/.tmkms/haqq
```
Or use [WinSCP](https://winscp.net/download/WinSCP-5.19.5-Setup.exe) to copy the `priv_validator_key.json` from the validator's node. And put it in the `$HOME/.tmkms/haqq` folder.

Then type the command below to import information from `priv_validator_key.json` to `haqq-consensus.key`:
```
tmkms softsign import $HOME/.tmkms/haqq/priv_validator_key.json $HOME/.tmkms/haqq/secrets/haqq-consensus.key
rm $HOME/.tmkms/haqq/priv_validator_key.json
```
### Edit tmkms.toml
Here is the [tmkms.toml.example](https://github.com/iqlusioninc/tmkms/blob/main/tmkms.toml.example). Open `tmkms.toml` in `nano`
```
nano $HOME/.tmkms/haqq/tmkms.toml
```
Edit the file like this:
```
# Example Tendermint KMS configuration file
## Chain Configuration
[[chain]]
id = "haqq_54211-2"
key_format = { type = "bech32", account_key_prefix = "haqqpub", consensus_key_prefix = "haqqvalconspub" }
state_file = "$HOME/.tmkms/haqq/state/haqq-consensus.json"

## Signing Provider Configuration
### Software-based Signer Configuration
[[providers.softsign]]
chain_ids = ["haqq_54211-2"]
key_type = "consensus"
path = "$HOME/.tmkms/haqq/secrets/haqq-consensus.key"

## Validator Configuration
[[validator]]
chain_id = "haqq_54211-2"
addr = "tcp://<ip_VAL>:26658"
secret_key = "$HOME/.tmkms/haqq/secrets/kms-identity.key"
protocol_version = "v0.34"
reconnect = true
```
- `addr` - the validator' server address. Shoud match the `priv_validator_laddr` in haqq' `config.toml`.
- `protocol_version` - find out `haqqd tendermint version`

## Restert both validator and tmkms
### Start tmkms
Try start on tmkms server
```
tmkms start -c $HOME/.tmkms/haqq/tmkms.toml
```
![image](https://user-images.githubusercontent.com/30211801/192980455-ecb2ad54-e625-4a2f-b918-c6ab13a54bdc.png)

If everything is alright then start tmkms as service file.  
**Create the file**
```
sudo tee <<EOF >/dev/null /etc/systemd/system/tmkmshaqq.service
[Unit]  
Description=tmkms Haqq Network service  
After=network.target  
StartLimitIntervalSec=0

[Service]
Type=simple  
Restart=always  
RestartSec=10  
User=root
ExecStart=/usr/bin/tmkms start -c $HOME/.tmkms/haqq/tmkms.toml  
LimitNOFILE=1024

[Install]  
WantedBy=multi-user.target
EOF
```
### Stop `haqqd` service on the validator before starting tmkms as a service
```
sudo systemctl stop haqqd
```
### Start tmkmshaqq
```
sudo systemctl enable tmkmshaqq
sudo systemctl daemon-reload
sudo systemctl restart tmkmshaqq
journalctl -u tmkmshaqq -f
```
You will see logs like this:
![image](https://user-images.githubusercontent.com/30211801/192982290-eb38642a-94f5-4146-8ced-bf2bbd13cc6b.png)

### Restart `haqqd` service on the server of the validator
```
sudo systemctl restart haqqd
journalctl -u haqqd -f --output cat
```
You will see logs on the tmkms will change to:
![image](https://user-images.githubusercontent.com/30211801/192983374-2632f497-b97f-41d6-bf0c-5cba39eaed90.png)


## Done
Congratulations, your validator now has a double-signing protection.

### Commands for restart/logs tmkms and haqqd 
```
sudo systemctl restart tmkmshaqq
journalctl -u tmkmshaqq -f
```
Now all should work. Check logs:
```
journalctl -u tmkmshaqq -f --output cat
journalctl -u haqqd -f --output cat
```
Don't forget **to backup and delete** the `priv_validator_key.json` file from the validator node. Now you won't need it. Keep it in a secure place, such as a flash drive.
# Troubleshooting
#### Type of key_format
The [official instruction](https://docs.haqq.network/guides/kms/kms.html) for editing the `$HOME/.tmkms/agoric/tmkms.toml` file, suggests the line:
```
key_format = { type = "cosmos-json", account_key_prefix = "haqqpub", consensus_key_prefix = "haqqvalconspub" }
```
It is ok in case if you use generation command from the official guide:
```
tmkms softsign keygen ./config/secrets/secret_connection_key
tmkms softsign import $HOME/tmkms/config/secrets/priv_validator_key.json $HOME/tmkms/config/secrets/priv_validator_key
```
BUT if you used tmkms.toml and the command from my guide:
```
tmkms softsign import $HOME/.tmkms/haqq/priv_validator_key.json $HOME/.tmkms/haqq/secrets/haqq-consensus.key
```
then you must use `type = "bech32"`

Thank you!











