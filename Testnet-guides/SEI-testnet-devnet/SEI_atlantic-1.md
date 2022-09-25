Here is the instruction to run a validator from scratch. But if you've already installed SEI and created gentx on your server then you should then you should continue from the **Configure your node** step.
## Chain: `atlantic-1`
Useful links:
- [Github](https://github.com/sei-protocol)
- [Explorer](https://sei.explorers.guru/)
- [Tasks](https://3pgv.notion.site/Sei-Network-Incentivized-Testnet-Seinami-1f3de71c76c24d4f862af936f0a5fe04)
- [Docs](https://docs.seinetwork.io/nodes-and-validators/joining-testnets)
# Instructions
Short linksof this guide:
- [Start installation](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/SEI_atlantic-1.md#update-the-packeges)
- [Commands](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/SEI_atlantic-1.md#commands)
- [Update to `1.0.6beta-val-count-fix`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/SEI_atlantic-1.md#update-to-106beta-val-count-fix)
- [Update to `1.0.7beta-postfix`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/SEI_atlantic-1.md#update-to-107beta-postfix)
- [Update to `1.2.0beta`](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/SEI_atlantic-1.md#update-to-120beta-if-you-were-on-sub-chains)


#### Minimal serer protection
[[Link to instruction](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md)] There we will protect server by:
- Change the password
- Firewall configuration (ufw)
- Change the SSH port
- SSH key login
- Install File2ban
- 2FA for SSH
#### Update the packeges
```
sudo apt update && sudo apt upgrade -y
```
#### Install what we need
```
sudo apt-get install make git jq curl gcc g++ mc nano -y
```
#### Install GO
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
#### Install **interchain**
Here `<tag_name>` is `1.0.6beta`
```
cd $HOME
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.6beta
make install
cp $HOME/go/bin/seid /usr/local/bin
seid version --long | head
```
#### Add variables
In the commands add your names for:
- `<Your_Moniker>`
- `<Your_Wallet_Name>`
```
sei_MONIKER=<Your_Moniker>
sei_WALLET=<Your_Wallet_Name>
sei_CHAIN=atlantic-1
echo 'export sei_MONIKER='\"${sei_MONIKER}\" >> $HOME/.bash_profile
echo 'export sei_WALLET='\"${sei_WALLET}\" >> $HOME/.bash_profile
echo 'export sei_CHAIN='\"${sei_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Configure your node
Init SEI
```
seid init $sei_MONIKER --chain-id $sei_CHAIN
```
#### Create wallet
```
seid keys add $sei_WALLET
```
Or if you copied your keys files from backup and past to `$HOME/.sei`, you should turn keyhash into an executable file:
```
chmod +x $HOME/.sei/keyhash
```
#### Download `genesis.json` and `addrbook.json`
```
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/genesis.json"
wget -qO $HOME/.sei/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/addrbook.json"
```
Include seeds and peers in `config.toml`. By one command
```
SEEDS="df1f6617ff5acdc85d9daa890300a57a9d956e5e@sei-atlantic-1.seed.rhinostake.com:16660" ; \
PEERS="22991efaa49dbaae857669d44cb564406a244811@18.222.18.162:26656,a37d65086e78865929ccb7388146fb93664223f7@18.144.13.149:26656,873a358b46b07c0c7c0280397a5ad27954a10633@141.95.175.196:26656,e66f9a9cab4428bfa3a7f32abbedbc684e734a48@185.193.17.129:12656,16225e262a0d38fe73073ab199f583e4a607e471@135.181.59.162:19656,2efd524f097b3fef2d26d0031fda21a72a51a765@38.242.213.174:12656,3b5ae3a1691d4ed24e67d7fe1499bc081c3ad8b0@65.108.131.189:20956,ad6d30dc6805df4f48b49d9013bbb921a5713fa6@20.211.82.153:26656,4e53c634e89f7b7ecff98e0d64a684269403dd78@38.242.235.141:26656,da5f6fcd1cd2ba8c7de8a06fb3ab56ab6a8157cf@38.242.235.142:26656,89e7d8c9eefc1c9a9b3e1faff31c67e0674f9c08@165.227.11.230:26656,94b6fa7ae5554c22e81a81e4a0928c48e41801d8@88.99.3.158:10956,b95aa07e60928fbc5ba7da9b6fe8c51798bd40be@51.250.6.195:26656,94b72206c0b0007494e20e2f9b958cd57e970d48@209.145.50.102:26656,94cf3893ded18bc6e3991d5add88449cd3f6c297@65.108.230.75:26656,82de728de0d663c03a820e570b94adac19c09adf@5.9.80.215:26656,5e1f8ccfa64dfd1c17e3fdac0dbf50f5fcc1acc3@209.126.7.113:26656,6a5113e8412f68bbeab733bb1297a0a38f884f7c@162.55.80.116:26656,7c95b2eec599369bebb8281b960589dc2857548a@164.215.102.44:26656,4bf8aa7b80f4db8a6f2abf5d757c9cab5d3f4d85@188.40.98.169:26656,9e38cf7ccb898632482a09b26ecba3f7e1a9e300@51.75.135.46:26656,641eea8d26c4b3b479b95a2cb4bd04712f3eda29@135.181.249.71:12656,8625abf6079da0e3326b0ad74c9c0e263af39654@137.184.44.146:12656,11c84300b4417af7e6c081f413003176b33b3877@51.75.135.47:26656,8a349512cf1ce179a126cb8762aea955ca1a261f@195.201.243.40:26651,6c27c768936ff8eebde94fe898b54df71f936e48@47.156.153.124:56656,7f037abdf485d02b95e50e9ba481166ddd6d6cae@185.144.99.65:26656,90916e0b118f2c00e90a40a0180b275261b547f2@65.108.72.121:26656,02be57dc6d6491bf272b823afb81f24d61243e1e@141.94.139.233:26656,ed3ec09ab24b8fcf0a36bc80de4b97f1e379d346@38.242.206.198:26656,7caa7add8d8a279e2da67a72700ab2d4540fbc08@34.97.43.89:12656,cce4c3526409ec516107db695233f9b047d52bf6@128.199.59.125:36376,3f6e68bd476a7cd3f491105da50306f8ebb74643@65.21.143.79:21156" ; \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sei/config/config.toml
```
#### Change some `config.toml` settings
- Set `minimum-gas-prices`. We will set it to `0` in testnet.
- Prometheus enable
```
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usei\"/;" $HOME/.sei/config/app.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.sei/config/config.toml
```
#### Disk usage optimization
**Indexing**. The "Indexing" function is only needed by those who need to request transactions from a specific node. So let's disable it.
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.sei/config/config.toml
sudo rm ~/.sei/data/tx_index.db/*
```
**Logging**. By default, the node state logging level is set to info, i.e. full display of all node information. Let's set the log display level to `warn`. Don't forget that now in logs you will only see warns and errors 🤷‍♂️
```
sed -i -e "s/^log_level *=.*/log_level = \"warn\"/" $HOME/.sei/config/config.toml
```
**Pruning**
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.sei/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.sei/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.sei/config/app.toml
```
#### Create service file for Sei
```
sudo -E bash -c 'cat << EOF > /etc/systemd/system/seid.service
[Unit]
Description=SEI Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which seid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF'
```
**If you synced by State sync before, disable it**.  
Disable synchronization using State Sync (this feature will prohibit synchronization from scratch, so we should disable it)
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.sei/config/config.toml
```
Reset the data folder
```
seid tendermint unsafe-reset-all --home $HOME/.sei
```
Then Start the service to synchronize a node
```
sudo systemctl daemon-reload
sudo systemctl enable seid
sudo systemctl restart seid
```
If needed to stop
```
sudo systemctl stop seid
```
Status and logs
```
seid status 2>&1 | jq
seid status 2>&1 | jq .SyncInfo
sudo journalctl -u seid -f -o cat
```
To find out your node_id:
```
curl localhost:26657/status | jq '.result.node_info.id'
```
### Faucet
Request 1 token from [discord](https://discord.gg/SDJ7ky75) in the #atlantic-1-faucet channel by the command `!faucet <YOUR_WALLET_ADDRESS>`

To find out your wallet type:
```
seid keys show $sei_WALLET -a
```
Check balance:
```
seid query bank balances $sei_WALLET
```
### Create validator
```
seid tx staking create-validator \
  --amount 1000000usei \
  --from $sei_WALLET \
  --moniker $sei_MONIKER \
  --chain-id $sei_CHAIN \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.1" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey  $(seid tendermint show-validator) \
  --details="" \
  --website="" \
  --identity=""
```
# Commands
Unjail
```
seid tx slashing unjail \
  --broadcast-mode=block \
  --from=$sei_WALLET \
  --chain-id=$sei_CHAIN \
  --gas=auto
```
Reset the downloaded information from the data folder
```
seid tendermint unsafe-reset-all --home $HOME/.sei
```
Find out your wallet
```
seid keys show $sei_WALLET -a
```
Find out your validator
```
seid keys show $sei_WALLET --bech val -a
```
Find out information about your validator
```
seid query staking validator $(seid keys show $sei_WALLET --bech val -a)
```
## More about wallets delegations and rewards
To see how many tokens are in your wallet:
```
seid q bank balances $(seid keys show $sei_WALLET -a)
```
Withdraw all delegation rewards
```
seid tx distribution withdraw-all-rewards --node "tcp://127.0.0.1:26657" --from=$sei_WALLET --chain-id=$sei_CHAIN --gas=auto
```
How to withdraw validator commission
```
seid tx distribution withdraw-rewards $(seid keys show $sei_WALLET --bech val -a) \
--chain-id $sei_CHAIN \
--from $sei_WALLET \
--commission \
--fees 1000usei \
--yes
```
Self delegation
```
seid tx staking delegate --node "tcp://127.0.0.1:26657" $(seid keys show $sei_WALLET --bech val -a) <amount_to_delegate>usei \
--chain-id=$sei_CHAIN \
--from=$sei_WALLET \
--gas=auto
```
# Update to `1.0.6beta-val-count-fix`
Stop seid:
```
sudo systemctl stop seid
```
go to the `$HOME` repository:
```
cd $HOME
```
delete the old downloaded directory:
```
sudo rm sei-chain -rf
```
Download the updated git:
```
git clone https://github.com/sei-protocol/sei-chain.git
```
go to the `sei-chain` repository:
```
cd sei-chain
```
Update sei:
```
git checkout master && git pull
```
Checkout fix:
```
git checkout 1.0.6beta-val-count-fix
```
Build seid:
```
make install
```
transfer the compiled binary to the place we need:
```
sudo cp /root/go/bin/seid /usr/local/bin/seid
```
restart:
```
sudo systemctl restart seid
```
Logs:
```
sudo journalctl -u seid -f -o cat
```
# Update to `1.0.7beta-postfix`
```
sudo systemctl stop seid
cd $HOME
sudo rm sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout master && git pull
git checkout 1.0.7beta-postfix
make install
sudo cp /root/go/bin/seid /usr/local/bin/seid
seid version --long | head
sudo systemctl restart seid
sudo journalctl -u seid -f -o cat
```
# Update to `1.2.0beta` If you were on sub chains
#### Update `seid` binary
```
sudo systemctl stop seid
cd $HOME
sudo rm sei-chain -rf
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout master
git pull --tags --force
git checkout tags/1.2.0beta
make install
sudo cp /root/go/bin/seid /usr/local/bin/seid
seid version --long | head
```

#### Update your chain_id
If you are using variables in the file `$HOME/.bash_profile` - go there and change `atlantic-sub-1` to `atlantic-1`:
```
nano $HOME/.bash_profile
```
Update Client file
```
seid config chain-id atlantic-1
```

#### Download genesis for `atlantic-1`
```
wget -qO $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/genesis.json"
```
#### Use SEI State Sync
Add this public RPC node to `persistance_peer` in `config.toml`
```
peers="8b418588806a607c2e1c8883c1041080b0f7a72f@212.23.222.28:21656"; \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.sei/config/config.toml

# Add variables
SNAP_RPC="http://212.23.222.28:21657"; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash); \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH

# Set all the data into config.toml
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sei/config/config.toml
```
Restart the `seid.service` with `unsafe-reset-all` by one command:
```
sudo systemctl stop seid && \
seid tendermint unsafe-reset-all --home ~/.sei && \
sudo systemctl restart seid
```
Status and logs
```
seid status 2>&1 | jq
seid status 2>&1 | jq .SyncInfo
sudo journalctl -u seid -f -o cat
```




