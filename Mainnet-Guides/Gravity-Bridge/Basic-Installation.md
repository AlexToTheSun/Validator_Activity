## Installation Overview
In this tutorial, we will:
- [Make minimal server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#minimal-server-protection) 
  - [Ports](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#ports)
- [Download and install geth](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#download-and-install-geth)
- [Download the latest version of Gravity chain](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#download-the-latest-version-of-gravity-chain)
- [Download Gravity tools (GBT)](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#download-the-latest-version-of-gravity-chain-and-the-gravity-tools-gbt)
- [Let's add variables](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#lets-add-variables)
- [Gravity init](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#make-init-of-gravity-chain)
- [Configure your config fles](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#configure-your-config-fles)
  - [Download the genesis file](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#download-the-genesis-file)
  - [Add seed nodes into config.toml](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#add-seed-nodes-into-configtoml)
  - [Setting the minimum-gas-prices](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#setting-the-minimum-gas-prices-in-gravityconfigapptoml-and---fees-in-orchestratorservice)
  - [Disk usage optimisation](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#disk-usage-optimisation)
  - [Configure your node for state sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#configure-your-node-for-state-sync)
- [Create service file for Gravity chain](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#create-service-file-for-gravity-chain)
- [DDoS protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#sentry-node-architecture-recommended) (Sentry nodes)
- [Start synchronization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#start-synchronization)
- Create keys
  - [validator key](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#add-validator-key)
  - [orchestrator key](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#add-orchestrator-key)
  - [ethereum key](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#add-gravity-eth_keys)
- [GBT init](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#make-init-of-gbt)
- [Set keys in our Orchestrator](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#set-keys-in-our-orchestrator)
- [Download service files](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#download-gravity-bridge-orchestrator-and-geth-services)
- [Observe Sync Status](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#observe-sync-status)
- [Top up wallets balance](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#top-up-wallets-balance)
- [Validator setup transaction](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#send-your-validator-setup-transaction)
- [Fees for orchestrator](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#fees-for-orchestrator)
- [Register your delegate keys](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#register-your-delegate-keys)
- [Double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Gravity-Bridge/Basic-Installation.md#tmkms-recommended) (tmkms)
- 
## Minimal server protection
It will not protect against all threats. Requires more advanced security settings such as DDoS and double signing protection.
- [Change the password](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#change-the-password)
- [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#firewall-configuration) (ufw)
- [Change the SSH port](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#change-the-ssh-port)
- [SSH key login](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#ssh-key-login)
- [Install File2ban](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#install-file2ban)
- [2FA for SSH](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#2fa-for-ssh)
### Ports
You need ports:
- For gravity: `1317`, `26656`, `26657`, `26658`, `26660`, `6060`, `9090`, `9091`
- For ssh port you could choose yours
- For geth: `30303`, `8545`
- For gbt metrics: `6631`

# Setting up the validator node
**Update & upgrade**
```
sudo apt update && sudo apt upgrade -y
```
**Install the required packages**
```
sudo apt-get install nano mc git gcc g++ make curl yarn jq clang pkg-config libssl-dev build-essential ncdu -y
```
## Download and install geth
You only need to do this if you are running Geth locally
```
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.15-8be800ff.tar.gz
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/geth-light-config.toml -O /etc/geth-light-config.toml
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/geth-full-config.toml -O /etc/geth-full-config.toml
tar -xvf geth-linux-amd64-1.10.15-8be800ff.tar.gz
cd geth-linux-amd64-1.10.15-8be800ff
mv geth /usr/sbin/
geth version
```
![image](https://user-images.githubusercontent.com/30211801/170711065-cc3d630e-b1ce-46a2-8eec-dccd4922cb7d.png)


Or use the flags below in the /etc/systemd/system/orchestrator.service
```
--ethereum-rpc http://chainripper-2.althea.net:8545
# or
--ethereum-rpc https://eth.althea.net/
```
## Download the latest version of Gravity chain
To sync by State Sync you need to skip the first versions of the assembly and download the latest version.
```
mkdir gravity-bin
cd gravity-bin

# the gravity chain binary itself
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.5.2/gravity-linux-amd64
mv gravity-linux-amd64 gravity

chmod +x gravity
cp /root/gravity-bin/gravity /usr/bin/
gravity version
gravity unsafe-reset-all
```
## Download the latest version of Gravity chain and the Gravity tools (GBT)
```
cd gravity-bin
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.5.2/gbt
chmod +x *
sudo mv * /usr/bin/
gbt --version
# gbt 1.5.2

gbt --help
```
### Let's add variables.
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
Grav_moniker=<YOUR_MONIKER>
Grav_wallet=<YOUR_WALLET>
chainName=gravity-bridge-3
echo 'export Grav_moniker='\"${Grav_moniker}\" >> $HOME/.bash_profile
echo 'export Grav_wallet='\"${Grav_wallet}\" >> $HOME/.bash_profile
echo 'export chainName='\"${chainName}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $Grav_moniker $Grav_wallet $chainName
. $HOME/.bash_profile
```
#### Make init of Gravity chain
The output of this command will generate `priv_validator_key.json`, which generates a different output each time it is ran even if the same input is provided. If you lose this file you will not be able to regenerate it and you will have to start a new validator. The default save location for this file will be `~/.gravity/config/priv_validator_key.json`
```
# Init the config files
cd $HOME
gravity init $Grav_moniker --chain-id $chainName
```

## Configure your config fles
#### Download the genesis file
```
wget https://raw.githubusercontent.com/Gravity-Bridge/gravity-docs/main/genesis.json
cp genesis.json $HOME/.gravity/config/genesis.json
```
#### Add seed nodes into config.toml
```
SEEDS="2b089bfb4c7366efb402b48376a7209632380c9c@65.19.136.133:26656,63e662f5e048d4902c7c7126291cf1fc17687e3c@95.211.103.175:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.gravity/config/config.toml
```
### Setting the `minimum-gas-prices` in .gravity/config/app.toml and `--fees` in `orchestrator.service`
**1) ~/.gravity/config/app.toml**
It's not obligatory! You can leave `minimum-gas-prices = "0ugraviton"`.  
But if this is specified, then the node will not process spam transactions with zero commission.  
Fix the `minimum-gas-prices` in the file `~/.gravity/config/app.toml` with the command:
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \""0.0001ugraviton"\"/" $HOME/.gravity/config/app.toml
```
**2) orchestrator.service** 
> In the `~/.gbt/config.toml` file there is no way to set `fees`, therefore, we set this parameter in the `orchestrator.service` file.  
We haven't created an orchestrator.service for gbt yet. Let's remember the fee setting when we get to the gbt (orchestrator) setting.
If you set the minimum commission for the validator, then for the orchestrator in its service file, you must also set the fees. How to do it ? Can be set by nano in the service file `/etc/systemd/system/orchestrator.service` at the end of the "ExecStart=" line, the line will look like this:
```
ExecStart=/usr/bin/gbt orchestrator --fees "0ugraviton"
```
If `minimum-gas-prices = "0.0001ugraviton"` is specified in the gravity bridge config, then at least `--fees "43ugraviton"` must be specified for gbt. If this is not enough, there will be a hint in the orchestrator logs - how many fees are needed. Log example:
![image](https://user-images.githubusercontent.com/30211801/170685658-2b585606-a1d5-41cd-a50a-84d725acefc2.png)

#### Disk usage optimisation
```
# sudo nano ~/.gravity/config/config.toml
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.gravity/config/config.toml
sudo rm ~/.gravity/data/tx_index.db/*

# sudo nano ~/.gravity/config/app.toml
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.gravity/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.gravity/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.gravity/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.gravity/config/app.toml
```

#### Configure your node for state sync
Edit the `config.toml` file in accordance with the information from the section "2. Enable State Sync" from the site https://ping.pub/gravity-bridge/statesync

We enter the command for editing and prescribe as it is said on the site above:
```
nano $HOME/.gravity/config/config.toml
# Then, follow the guide from the site https://ping.pub/gravity-bridge/statesync
```
This information is constantly changing as the characteristics of the network snapshot are updated.
Example of input information:
```
[statesync]
enable = true
rpc_servers = "https://gravitychain.io:26657,http://gravity-bridge-1-08.nodes.amhost.net:26657"
trust_height = 1658000
trust_hash = "55C1612DEC5D63D7451EB6743810E9B003A22568440C4D84ABA0FDC13288126C"
trust_period = "168h"
```
> To reduce state sync unpacking time, you can add State Sync providers in the form `node_id@ip4:port` to the `persistent_peers` line of the `$HOME/.gravity/config/config.toml` file.
But this is not necessary, just having working peers in the `seeds` or `persistent_peers` section is enough, and then everything will unpack over time.
## Create service file for Gravity chain
```
sudo tee <<EOF >/dev/null /etc/systemd/system/gravityd.service
[Unit]
Description=Gravity Bridge Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/gravity start --log_level=info 
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
You could change `--log_level=info` flag after making sure everything works.

The logging level (`trace`|`debug`|`info`|`warn`|`error`|`fatal`|`panic`)
## Sentry Node Architecture (Recommended)
!! Everything is ready to launch. But we need **DDoS protection**. When you run the service file in this configuration, after synchronization, information about your node will be available on the Gravity Bridge public network. This exposes your validator to DDoS attacks.
If you want to secure a node with a validator, then before starting, click [[here]]() and configure Gravity Bridge Sentry Node Architecture.
If you **decide not to protect** the server from DDoS attacks (**which is a security issue for the protocol**) then follow the instructions below.

## Start synchronization
```
gravity unsafe-reset-all
sudo systemctl enable gravityd
sudo systemctl daemon-reload
sudo systemctl restart gravityd
```
### Logs and status
```
journalctl -u gravityd -f --output cat
journalctl -u gravityd -f
curl localhost:26657/status | jq '.result.sync_info'
echo 'Node status:'$(sudo service gravityd status | grep active)
```
## Add your validator key, orchestrator key and ethereum key
There will be [four](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md#generate-your-delegate-keys) keys involved in this process:  
- Validator Funds key: `gravity1...` - contains your funds.  
- Validator Operator Key: `gravityvaloper1...` - actually signs your validators blocks.  
- Gravity Orchestrator Cosmos Key: `gravity1...` - will be used on the Cosmos side of Gravity bridge to submit Oracle transactions and Ethereum signatures. 
- Gravity Orchestrator Ethereum Key: `0x...` - represents your validators voting power on Ethereum in the `Gravity.sol` contract.  

### Add Validator key
```
# you will be prompted for your key phrase

gravity keys add $Grav_wallet
gravity keys show $Grav_wallet --bech val
```
### Add orchestrator key
```
#Let's add name variable for orchestrator key 
Gr_Orch_Cosm_Key=<Your_Orch_key_name>
echo $Gr_Orch_Cosm_Key
echo 'export Gr_Orch_Cosm_Key='\"${Gr_Orch_Cosm_Key}\" >> $HOME/.bash_profile
. $HOME/.bash_profile
```
Now create the orchestrator key 
```
gravity keys add $Gr_Orch_Cosm_Key
```
### Add gravity eth_keys
```
gravity eth_keys add
```
## Make init of GBT
Yes, this step is different from **Make init of Gravity chain**. And it needs to be done so that the validator does not go to jail.
```
gbt init
```
## Set keys in our Orchestrator
Once we have registered our keys we will also set them in our Orchestrator right away, this reduces the risk of confusion as the chain starts and you need these keys to submit Gravity bridge signatures via your orchestrator.
```
gbt keys set-ethereum-key --key Gravity Orchestrator Ethereum Key
gbt keys set-orchestrator-key --phrase "Gravity Orchestrator Cosmos Key"
```
Here is an important clarification.
For commands above, we use this:
- Gravity Orchestrator Ethereum Key - is private from your gravity eth_keys
- Gravity Orchestrator Cosmos Key is a mnemonic phrase that was created for the command `gravity keys add $Gr_Orch_Cosm_Key`
More detailed - [discord link](https://discord.com/channels/881943007115497553/926163896388182026/939844952484110376)

## Download Gravity Bridge, Orchestrator and geth services
```
cd /etc/systemd/system
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/gravity-node.service
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/orchestrator.service
wget https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/geth.service
```
Restart the gravity node with the service file suggested by the team:
```
sudo systemctl daemon-reload
sudo systemctl enable gravity-node
sudo systemctl stop gravityd
sudo systemctl restart gravity-node

# Logs
journalctl -u gravity-node -f --output cat
```
Now run orchestrator and geth services
```
sudo systemctl enable orchestrator
sudo systemctl enable geth
sudo service orchestrator restart
sudo service geth restart

journalctl -u orchestrator -f --output cat
journalctl -u geth -f --output cat
journalctl -u gravity-node -f --output cat
```
## Observe Sync Status
```
# Ethereum
curl -H "Content-Type:application/json" -X POST -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://127.0.0.1:8545

# Gravity Node
curl localhost:26657/status | jq '.result.sync_info'
# or
gravity status 2>&1| jq .SyncInfo.catching_up
```
Values of 'false' means that it is now synced, 'true' means that sync is still in process.

## Top up wallets balance.
You need to replenish 3 wallets:
**Validator Funds Address** - here are the coins that will be delegated to the validator.
**Gravity Orchestrator Cosmos Address** - here are the gravity coins for the commission. 10 pcs is enough.
**Gravity Orchestrator Ethereum Address** - eth here for commission. Just a little.
## Send your validator setup transaction
```
gravity tx staking create-validator \
 --amount=<the amount of graviton you wish to stake>ugraviton \
 --pubkey=$(gravity tendermint show-validator) \
 --moniker=$Grav_moniker \
 --from=$Grav_wallet \
 --chain-id=gravity-bridge-3 \
 --details="" \
 --website="" \
 --identity="" \
 --commission-rate="0.10" \
 --commission-max-rate="0.20" \
 --commission-max-change-rate="0.01" \
 --gas=auto \
 --fees=125000ugraviton \
 --min-self-delegation="1" \
 --gas-adjustment=1.4
```
Check that the validator creation transaction was successful:
```
gravity query staking validator $(gravity keys show $Grav_wallet --bech val --address)
```
Validator launched! Excellent. **But if within a couple of hours you do not Register your delegate keys for the orchestrator, then the validator will go to jail**.
## Fees for orchestrator
> The necessary commission for the orchestrator changes depending on the `minimum-gas-prices` that we set for gravity in the `~/.gravity/config/app.toml` file (this is described in the "Setting the minimum commission" section). So, if we set `minimum-gas-prices = "0.0001ugraviton"` there, then in the orchestrator.service service file we need to set a commission in the amount of `43ugraviton`, but you can take it with a margin, for example `50`. If you set more, the orchestrator will tell you how much he wants in logs, together with errors.
Go to the service file by nano editor and correct the commission value:
```
nano /etc/systemd/system/orchestrator.service
```
And in the line `ExecStart=` change the commission
```
ExecStart=/usr/bin/gbt orchestrator --fees "50ugraviton"
```
Restart the orchestrator
```
sudo systemctl daemon-reload
sudo systemctl restart orchestrator
journalctl -u orchestrator -f
```
All. The preparation is ready.
## Register your delegate keys
```
gbt keys register-orchestrator-address --validator-phrase "the phrase you saved earlier" --ethereum-key "the key you saved earlier" --fees=125000ugraviton
```
Where:
- `the phrase you saved earlier` - mnemonic phrase of the VALIDATOR wallet!!
- `the key you saved earlier` - privaye key from eth wallet!!
If everything is done correctly, then the logs will be without errors.

## Common error in orchestrator logs
```
journalctl -u orchestrator -f
```
output:
```
Apr 27 10:20:21 n13b679 gbt[27297]: [2022-04-27T10:20:21Z ERROR orchestrator::main_loop] Failed to get events for block range, Check your Eth node and Cosmos gRPC CosmosGrpcError(TransactionFailed { tx: TxResponse { height: 0, txhash: "1B7D71797DD4E3E196479E8E72015484E74AB9E7D93A7C430EAEAF92DF7FDB6D", codespace: "", code: 0, data: "", raw_log: "[]", logs: [], info: "", gas_wanted: 0, gas_used: 0, tx: None, timestamp: "", events: [] }, time: 60s, sdk_error: None })
Apr 27 10:24:43 n13b679 gbt[27297]: [2022-04-27T10:24:43Z INFO  orchestrator::ethereum_event_watcher] Oracle observed deposit with sender 0x301f58c9aabC577573911789B1dFb48bE20e1Ad6, destination Some(gravity159q9qwltzn26cz8wh0fulrpmfq06z74xwxykx8), amount 156250000000000000000, and event nonce 1731
Apr 27 10:25:43 n13b679 gbt[27297]: [2022-04-27T10:25:43Z ERROR orchestrator::main_loop] Failed to get events for block range, Check your Eth node and Cosmos gRPC CosmosGrpcError(TransactionFailed { tx: TxResponse { height: 0, txhash: "ADCFD9CA75DD028A892EF81D5799E65D31F78EC8EEEEC1C85A599ED9ACE4A633", codespace: "", code: 0, data: "", raw_log: "[]", logs: [], info: "", gas_wanted: 0, gas_used: 0, tx: None, timestamp: "", events: [] }, time: 60s, sdk_error: None })
Apr 27 10:41:32 n13b679 gbt[27297]: [2022-04-27T10:41:32Z INFO  orchestrator::ethereum_event_watcher] Oracle observed deposit with sender 0xc35A062446aC8773f6F66C9ffeA23FA37A070Eb6, destination Some(gravity16jpptxf42hapaaugw36q3j49ackrvsvfs2jzvs), amount 509586000, and event nonce 1732
```
Team response:
> "This looks ok it failed but then succeded on the next try." Here is the discord message: [[Question](https://discord.com/channels/881943007115497553/926163896388182026/958423796950401084)] answer [[Answer](https://discord.com/channels/881943007115497553/926163896388182026/958437633397231726)]

## tmkms (Recommended)
It is **highly recommended** to protect your validator from double-signing case. [Official documentation](https://github.com/iqlusioninc/tmkms) This could prevent the Double-signing even in the event the validator process is compromised. Click [here] the guide of Installing tmkms on an additional server that will serve as protection.

## Set Up Relaying for Gravity Bridge
See an official link [here](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/relaying.md).















