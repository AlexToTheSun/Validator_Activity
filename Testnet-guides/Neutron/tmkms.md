#### Under troubleshooting
## Here is the instruction to setup TMKMS as a Key Management System for Neutron validator.
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
We already  [[have](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Neutron/Node-insallation.md)] a validator in `quark-1` testnet.

### Firewall configuration
Allow access to port 26658 of validator's node for the tmkms server. Run the command below on a validator node:
```
sudo ufw allow from <ip_tmkms> to any port 26658
```
### Edit config.toml
Open `config.toml` by `nano`:
```
nano $HOME/.neutrond/config/config.toml
```
Edit the line `priv_validator_laddr = ""` like this:
```
priv_validator_laddr = "tcp://<ip_VAL>:26658"
```
where `<ip_VAL>` - ip of the validator' server.  

Or you can enter this value: `priv_validator_laddr = "tcp://<nodeid_VAL>@<ip_VAL>:26658"`. To find out node_id you should type `neutrond tendermint show-node-id'`

**DON'T RESTART validator' service file!!!** Until you have configured the tmkms server.

# Setting up a tmkms server
This server does not require the Neutron Network node. **tmkms** only.  
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
tmkms init $HOME/.tmkms/neutron
```

![Снимок экрана от 2022-11-27 23-39-33](https://user-images.githubusercontent.com/30211801/204156092-5b64e4b2-b373-4b4f-b9e8-c819ca08a1fb.png)

### Copy `priv_validator_key.json` from validator node
Use scp command to copy priv_validator_key.json from validator to your VM running TMKMS (type your ssh port instead of 22):
```
scp -P 22 root@123.456.32.123:~/.neutrond/config/priv_validator_key.json ~/.tmkms/neutron
```
Or use [WinSCP](https://winscp.net/download/WinSCP-5.19.5-Setup.exe) to copy the `priv_validator_key.json` from the validator's node. And put it in the `$HOME/.tmkms/neutrond` folder.

Then type the command below to import information from `priv_validator_key.json` to `neutron-consensus.key`:
```
tmkms softsign import $HOME/.tmkms/neutron/priv_validator_key.json $HOME/.tmkms/neutron/secrets/neutron-consensus.key
rm $HOME/.tmkms/neutron/priv_validator_key.json
```
### Edit tmkms.toml
Here is the [tmkms.toml.example](https://github.com/iqlusioninc/tmkms/blob/main/tmkms.toml.example). Open `tmkms.toml` in `nano`
```
nano $HOME/.tmkms/neutron/tmkms.toml
```
Edit the file like this:
```
# Example Tendermint KMS configuration file
## Chain Configuration
[[chain]]
id = "quark-1"
key_format = { type = "bech32", account_key_prefix = "neutronpub", consensus_key_prefix = "neutronvalconspub" }
state_file = "$HOME/.tmkms/neutron/state/neutron-consensus.json"
## Signing Provider Configuration
### Software-based Signer Configuration
[[providers.softsign]]
chain_ids = ["quark-1"]
key_type = "consensus"
path = "$HOME/.tmkms/neutron/secrets/neutron-consensus.key"
## Validator Configuration
[[validator]]
chain_id = "quark-1"
addr = "tcp://<ip_VAL>:26658"
secret_key = "$HOME/.tmkms/neutron/secrets/kms-identity.key"
protocol_version = "v0.34"
reconnect = true
```
- `addr` - the validator' server address. Shoud match the `priv_validator_laddr` in neutron' `config.toml`.
- `protocol_version` - find out `neutrond tendermint version`

## Restert both validator and tmkms
### Start tmkms
Try start on tmkms server
```
tmkms start -c $HOME/.tmkms/neutron/tmkms.toml
```
![Снимок экрана от 2022-11-28 00-15-49](https://user-images.githubusercontent.com/30211801/204157653-19a5ef15-78b5-47a2-b4e4-56fa9b863408.png)

If everything is alright then start tmkms as service file.  
**Create the file**
```
sudo tee <<EOF >/dev/null /etc/systemd/system/tmkms-neutron.service
[Unit]  
Description=tmkms Neutron Network service  
After=network.target  
StartLimitIntervalSec=0
[Service]
Type=simple  
Restart=always  
RestartSec=10  
User=root
ExecStart=/usr/bin/tmkms start -c $HOME/.tmkms/neutron/tmkms.toml  
LimitNOFILE=1024
[Install]  
WantedBy=multi-user.target
EOF
```
### Stop `neutrond` service on the validator before starting tmkms as a service
```
sudo systemctl stop neutrond
```
### Start tmkms-neutron
```
sudo systemctl enable tmkms-neutron
sudo systemctl daemon-reload
sudo systemctl restart tmkms-neutron
journalctl -u tmkms-neutron -f
```
You will see logs like this:
![image](https://user-images.githubusercontent.com/30211801/192982290-eb38642a-94f5-4146-8ced-bf2bbd13cc6b.png)

### Restart `neutrond` service on the server of the validator
```
sudo systemctl restart neutrond
journalctl -u neutrond -f --output cat
```
You will see logs on the tmkms will change to:
![image](https://user-images.githubusercontent.com/30211801/192983374-2632f497-b97f-41d6-bf0c-5cba39eaed90.png)


## Done
Congratulations, your validator now has a double-signing protection.

### Commands for restart/logs tmkms and neutrond 
```
sudo systemctl restart tmkms-neutron
journalctl -u tmkms-neutron -f
```
Now all should work. Check logs:
```
journalctl -u tmkms-neutron -f --output cat
journalctl -u neutrond -f --output cat
```
Don't forget **to backup and delete** the `priv_validator_key.json` file from the validator node. Now you won't need it. Keep it in a secure place, such as a flash drive.
