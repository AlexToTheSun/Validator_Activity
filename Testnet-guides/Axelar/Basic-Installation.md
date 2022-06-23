# Installation Overview
In this tutorial, we will:
- [Make minimal server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Axelar/Basic-Installation.md#minimal-server-protection) 




## Minimal server protection
It will not protect against all threats. Requires more advanced security settings such as DDoS and double signing protection.
- [Change the password](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#change-the-password)
- [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#firewall-configuration) (ufw)
- [Change the SSH port](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#change-the-ssh-port)
- [SSH key login](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#ssh-key-login)
- [Install File2ban](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#install-file2ban)
- [2FA for SSH](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#2fa-for-ssh)

# Setting up the validator node
### Update & upgrade
```
sudo apt update && sudo apt upgrade -y
```
### Install the required packages
```
sudo apt-get install nano mc git gcc g++ make curl yarn jq clang pkg-config libssl-dev build-essential ncdu libleveldb-dev -y
```
Despite the fact that we will download the Axelar binary file from the github, the programs that we installed may be useful to us in the future.

## Download binary files
Let's download axelard tofnd binaries instead of installing.

See all releases:
- [axelar-core](https://github.com/axelarnetwork/axelar-core/releases)
- [tofnd](https://github.com/axelarnetwork/tofnd/releases)
```
mkdir axelar-bin
cd axelar-bin
wget -q https://github.com/axelarnetwork/axelar-core/releases/download/v0.17.3/axelard-linux-amd64-v0.17.3
wget -q https://github.com/axelarnetwork/tofnd/releases/download/v0.10.1/tofnd-linux-amd64-v0.10.1
mv axelard-linux-amd64-v0.17.3 axelard
mv tofnd-linux-amd64-v0.10.1 tofnd
chmod +x *
sudo mv * /usr/bin/
axelard version
tofnd --help
```
## Add Validator, Broadcaster and tofnd keys
- `validator` - name of your validator key
- `broadcaster` - name of your broadcaster key
```
axelard keys add broadcaster
axelard keys add validator
tofnd -m create
```
Now copy and save tofnd mnemonic in the safe place and delete the file `.tofnd/export`.  Then delete it from the server.
```
cd /root/.tofnd && cat export
# copy and save your tofnd mnemonic. Then delete it from the server
rm /root/.tofnd/export
```
## Let's add variables

```
echo export CHAIN_ID=axelar-testnet-casablanca-1 >> $HOME/.profile
echo export MONIKER=PUT_YOUR_MONIKER_HERE >> $HOME/.profile
VALIDATOR_OPERATOR_ADDRESS=`axelard keys show validator --bech val --output json | jq -r .address`
BROADCASTER_ADDRESS=`axelard keys show broadcaster --output json | jq -r .address`
echo export VALIDATOR_OPERATOR_ADDRESS=$VALIDATOR_OPERATOR_ADDRESS >> $HOME/.profile
echo export BROADCASTER_ADDRESS=$BROADCASTER_ADDRESS >> $HOME/.profile
source $HOME/.profile
```
After that you will have variables:
- `CHAIN_ID` - `axelar-testnet-casablanca-1` - actual chain name
- `MONIKER` - your node name
- VALIDATOR_OPERATOR_ADDRESS - `axelarvaloper1...`
- BROADCASTER_ADDRESS - `axelar1...`

Now let's add anothe variable - `KEYRING_PASSWORD`. If you have done [server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md) then it will be safe.
```
KEYRING_PASSWORD=<YOUR_KEYRING_PASSWORD>
echo export KEYRING_PASSWORD=$KEYRING_PASSWORD >> $HOME/.profile
source $HOME/.profile
```
## Make init of Axelar
The output of this command will generate priv_validator_key.json, which generates a different output each time it is ran even if the same input is provided. If you lose this file you will not be able to regenerate it and you will have to start a new validator. The default save location for this file will be `~/.axelar/config/priv_validator_key.json`
```
axelard init $MONIKER --chain-id $CHAIN_ID
```
## Configure your config fles
Download files from github:
```
wget -q https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/configuration/config.toml -O $HOME/.axelar/config/config.toml
wget -q https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/configuration/app.toml -O $HOME/.axelar/config/app.toml
wget -q https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/resources/testnet-2/genesis.json -O $HOME/.axelar/config/genesis.json
```
Set [seeds](https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/resources/testnet-2/seeds.toml) (if you dont want to use Sentry Nodes):
```
SEEDS="95c90e528c54e2ebaa0427e034c8facc75e6da3f@aa96e735f68464b09955026986b15632-1865235038.us-east-2.elb.amazonaws.com:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.axelar/config/config.toml
```
Set minimum-gas-prices in the file ~/.axelar/config/app.toml
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \""0.00005uaxl"\"/" $HOME/.axelar/config/app.toml
```
Set external ip to your config.json file
```
sed -i.bak 's/external_address = ""/external_address = "'"$(curl -4 ifconfig.co)"':26656"/g' $HOME/.axelar/config/config.toml
```
comment `log_level` in `config.toml`
```
sed -i.bak 's/^log_level/# log_level/' $HOME/.axelar/config/config.toml
```
Set your moniker in the new confid file
```
sed -i.bak -e "s/^moniker *=.*/moniker = \"$MONIKER\"/" $HOME/.axelar/config/config.toml
```
Set disk usage optimisation
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.axelar/config/config.toml
sudo rm ~/.axelar/data/tx_index.db/*

sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.axelar/config/app.toml
```
## Create service files
#### For `axelard`:
```
sudo tee <<EOF >/dev/null /etc/systemd/system/axelard.service
[Unit]
Description=Axelard Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/axelard start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
```
You could change `--log_level=info` flag after making sure everything works.

The logging level (`trace`|`debug`|`info`|`warn`|`error`|`fatal`|`panic`)

#### For `tofnd`:
```
sudo tee <<EOF >/dev/null /etc/systemd/system/tofnd.service
[Unit]
Description=Tofnd daemon
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/sh -c 'echo $KEYRING_PASSWORD | tofnd -m existing -d $HOME/.tofnd'
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
```
#### For `vald`:
```
sudo tee <<EOF >/dev/null /etc/systemd/system/vald.service
[Unit]
Description=Vald daemon
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/sh -c 'echo $KEYRING_PASSWORD | /usr/bin/axelard vald-start --validator-addr $VALIDATOR_OPERATOR_ADDRESS --log_level debug --chain-id $CHAIN_ID --from broadcaster'
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
```
#### Enable daemons:
```
sudo systemctl enable axelard
sudo systemctl enable tofnd
sudo systemctl enable vald
sudo systemctl daemon-reload
```
## Sentry Node Architecture (Recommended) or State Sync from public network (not recommended)
!! Everything is ready to launch. But we need **DDoS protection**. When you run the service file in this configuration, after synchronization, information about your node will be available on the Gravity Bridge public network. This exposes your validator to DDoS attacks. If you want to secure a node with a validator, then before starting, click [here] and configure Axelar Sentry Node Architecture. If you **decide not to protect** the server from DDoS attacks (**which is a security issue for the protocol**) then follow the instructions below.
- [Sentry Node Architecture]()
- [State Sync from public network](https://github.com/AlexToTheSun/Validator_Activity/blob/main/State-Sync/Axelar-testnet-2.md)
Now follow the instructions below.
## Start service files
```
sudo systemctl restart axelard
sudo systemctl restart tofnd
sudo systemctl restart vald
```
#### Wait untill Axelar will be fully synced before proceeding
Logs and status:
```
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

journalctl -u axelard.service -f -n 100
journalctl -u tofnd.service -f -n 100
journalctl -u vald.service -f -n 100

journalctl -u axelard.service -f --output cat
curl localhost:26657/status | jq '.result.sync_info'
```
## Register broadcaster proxy
Fund your `validator` and `broadcaster` accounts before proceeding.
```
axelard tx snapshot register-proxy $BROADCASTER_ADDRESS --from validator --chain-id $CHAIN_ID
```
## Create validator
For identity code you should create an account [here](https://keybase.io/)
```
axelard tx staking create-validator \
 --amount=<your_amount>uaxl \
 --moniker $MONIKER \
 --commission-rate="0.10" \
 --commission-max-rate="0.20" \
 --commission-max-change-rate="0.01" \
 --min-self-delegation="1" \
 --pubkey="$(axelard tendermint show-validator)" \
 --from validator \
 -b block \
 --identity="" \
 --details="" \
 --gas-prices 1.5uaxl \
 --gas-adjustment 1.4 \
 --chain-id $CHAIN_ID
```

