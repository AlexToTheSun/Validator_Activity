## Overview
In this tutorial, we will:
- [Make minimal server protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#minimal-server-protection) 
  - [Change the password](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#change-the-password)
  -  [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#firewall-configuration) (ufw)
  - [Change the SSH port](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#change-the-ssh-port)
  - [Install File2ban](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#install-file2ban)
  - [2FA for SSH](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#2fa-for-ssh)
- [Install Agoric Node](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#install-agoric-node)
  - [Install the software](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#install-the-software)
  - [Disk usage optimization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#change-configtoml-and-apptoml-for-disk-usage-optimization)
  - [Sync using opend RPC node with State Sync](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#change-configtoml-to-sync-with-a-state-sync-snapshot)
  - [Create service file for Agoric](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#create-service-file-for-agoric)
- [DDoS protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#ddos-protection-sentry-node-architecture) (Sentry nodes)
- [Start synchronization](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#start-synchronization)
- [Create the validator](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#create-the-validator)
- [Double-signing protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#tmkms) (tmkms)
## Minimal server protection
It will not protect against all threats. Requires more advanced security settings.
### Change the password
```
passwd
```
This will protect against password leakage from the hosting or your mail. For example, when sending you an email message with a password.
### Firewall configuration
Install ufw
```
sudo apt ufw install -y
```
Open the ports necessary for Agoric
```
# Allow ssh connection
sudo ufw allow ssh

# SSH port
sudo ufw allow 22

# # API server port
sudo ufw allow 1317

# Ports for p2p connection, RPC server, ABCI
sudo ufw allow 26656:26658/udp

# Prometheus port
sudo ufw allow 26660

# Port for pprof listen address
sudo ufw allow 6060

# Address defines the gRPC server address to bind to.
sudo ufw allow 9090

# Address defines the gRPC-web server address to bind to.
sudo ufw allow 9091
```
Enable ufw
```
sudo ufw enable
```
Check
```
sudo ufw status
sudo ufw status verbose
ss -tulpn
```
### Change the SSH port
The port number must not exceed `65535`

Replace port 22 with a new one.
You need to find the line `Port 22`, and if it is commented out, remove the `#` symbol, and also enter a random number instead of port `22`, for example `1234`.
```
sudo nano /etc/ssh/sshd_config
```
Add the new port to the allowed list for UFW
```
sudo ufw allow 1234/tcp
sudo ufw deny 22
```
Sshd service restart
```
sudo systemctl restart sshd
```
Be sure to try opening an ssh connection in a new putty window without closing the first one. To check and, if necessary, correct the error.
### Install File2ban
```
sudo apt install fail2ban
```
Let's start and make the daemon start automatically on every boot:
```
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```
All ban parameters are set in the configuration file jail.conf , which is located at /etc/fail2ban/jail.conf

By default, after installation, we have the following settings for banning via SSH:
```
[DEFAULT]
ignorecommand =
bantime = 10m
findtime = 10m
maxretry = 5
```
- **bantime** - [min] time for banning ip.
- **findtime** - [min] time interval during which you can try to log in to the server "maxretry" times.
- **maxretry** - [times] allowed number of login attempts, per "findtime" time interval.

If you decide to change the settings, then open the editor:
```
sudo nano /etc/fail2ban/jail.conf
```
#### Setting up sshd_log for file2ban
Checking if the file `sshd_log` exists `find / -name "sshd_log"`

If not, then create the file by yourself `touch /var/log/sshd_log`

Open file2ban to set the path to the logs `sudo nano /etc/fail2ban/jail.conf`
```
# Find block [sshd]
# Delete a line:
logpath = %(sshd_log)s

# Insert a line to write the path
logpath  = /var/log/sshd_log
```
After changing the parameters, restart the service:
```
sudo systemctl reload fail2ban
sudo systemctl status fail2ban
journalctl -b -u fail2ban
```
### 2FA for SSH
You can also set up additional protection. 2FA are time based passwords. This method is not common, but is [considered](https://www.linode.com/docs/guides/use-one-time-passwords-for-two-factor-authentication-with-ssh-on-ubuntu-16-04-and-debian-8) reliable protection.
#### Time zone setting
The default time zone is set to UTC. This can be changed by setting the timezone you live in to use programs that are tied to your local time, and to display server logs in a time that you can understand. To do this, we will execute:
1. Select from the list and copy the time zone we need. Opening the list:
```
timedatectl list-timezones
```
2. Now use keyboard arrows `Page Up`, and `Page Down` to view the list. Copy the desired time zone, then to exit the list press `q` (or `ctrl+c`) to get out of the list.  
3. Set the time zone (for example, I took 'Etc/GMT+4'):
```
timedatectl set-timezone 'Etc/GMT+4'
```
#### Install Google Authenticator
Enter the command to install Google Authenticator:
```
sudo apt-get install libpam-google-authenticator
```
This program generates keys on the server, and after scanning the qr code, the password for entering on the phone will be displayed.

#### Key generation.
❗️ Before generating a key, install the [Google Authenticator](https://en.wikipedia.org/wiki/Google_Authenticator) or [Authy](https://www.authy.com/) application on your phone.  
And also check that the phone's time zone matches the one set on the server.   
1. Enter the key generation command:
```
google-authenticator
```
A question will appear. You must select a time-based key by entering `y`.
![image](https://user-images.githubusercontent.com/30211801/169817242-ab99844a-b11f-4931-a819-008fd71bc4c0.png)
2. After that, we get a **QR code**, **secret key** and **emergency scratch codes**. You need to scan the **QR code** using the Google 2FA application, or enter the secret key into the application manually. **Emergency scratch codes** (5 pieces) just save or write down on paper. They are needed in case we lost the phone (they are disposable!).
![image](https://user-images.githubusercontent.com/30211801/169817408-508b1074-40be-450c-867a-241cccce991d.png)

Now we answer the questions:
1) `Do you want me to update your "/home/exampleuser/.google_authenticator" file (y/n)`  
**Answer** `y`
2) `Do you want to disallow multiple uses of the same authentication token? This restricts you to one login about every 30s, but it increases your chances to notice or even prevent man-in-the-middle attacks (y/n)`  
**Answer** `y`
3) `By default, tokens are good for 30 seconds and in order to compensate for possible time-skew between the client and the server, we allow an extra token before and after the current time. If you experience problems with poor time synchronization, you can increase the window from its default size of 1:30min to about 4min. Do you want to do so (y/n)`  
**Answer** `n`
4) `If the computer that you are logging into isn't hardened against brute-force login attempts, you can enable rate-limiting for the authentication module. By default, this limits attackers to no more than 3 login attempts every 30s. Do you want to enable rate-limiting (y/n)`  
**Answer** `y`
#### Configuration setup
For google-authenticator to work correctly, we need the [PAM](http://www.linux-pam.org/) ([Pluggable Authentication Modules for Linux](http://www.linux-pam.org/whatispam.html)).

❗️At this step, it's important to open two putty sessions, as we'll soon need to login to the server again to check 2FA. And if we cannot log in to the server via 2FA, then we can solve the problem in the second opened session . Also, the problem can be solved through the console of the provider's personal account.

#### Editing the file /etc/pam.d/sshd
Open the file `/etc/pam.d/sshd` :  
```
sudo nano /etc/pam.d/sshd
```
Insert lines at the end of the file:
```
auth    required      pam_unix.so     no_warn try_first_pass
auth    required      pam_google_authenticator.so
```
Where the first line tells PAM to ask for a password first! The second line sets the requirement for additional verification - google_authenticator.
#### Editing the file /etc/ssh/sshd_config
In this file, we also need to write an additional verification requirement.  
Find the line `ChallengeResponseAuthentication no`. You need to set its value to `yes`:
```
ChallengeResponseAuthentication yes
```
Replace `example-user` with the user you want. Let's say `root`. And paste the changed lines at the end of the file:
```
Match User example-user
    AuthenticationMethods keyboard-interactive
```
If you need to enable 2FA for other users - insert the block above for each user (changing the `example-user` variable for each block).

Restart the sshd service and you're done:
```
sudo systemctl restart sshd
```
Now When logging into the server, you will first need to enter a password, and then a two-factor authentication code. 🎉
## Install Agoric Node
First we need to install the software, ran `init` and set up the configuration files to be able to start the sync.
### Install the software
**Update & upgrade**
```
sudo apt update && sudo apt upgrade -y
```
**Install the required packages**
```
sudo apt-get install nano mc git gcc g++ make curl yarn -y
```
**Install GO**
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
# go version go1.18 linux/amd64
```
**Install Nodejs**
```
curl https://deb.nodesource.com/setup_16.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt install nodejs=16.* -y  yarn build-essential jq -y --fix-missing
```
#### Install the latest version of Agoric
It is necessary to sync with State Sync. In this case, you need to skip the first versions of the assembly.
All releases can be viewed here: [Releases](https://github.com/Agoric/ag0/releases)
```
rm -rf /root/ag0
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-upgrade-5
git pull origin agoric-upgrade-5
make build
. $HOME/.bash_profile
cp $HOME/ag0/build/ag0 /usr/local/bin
ag0 version
```
**Let's add variables.**
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
AGORIC_NODENAME=<YOUR_MONIKER>
AGORIC_WALLET=<YOUR_WALLET>
chainName=agoric-3

echo 'export AGORIC_NODENAME='\"${AGORIC_NODENAME}\" >> $HOME/.bash_profile
echo 'export AGORIC_WALLET='\"${AGORIC_WALLET}\" >> $HOME/.bash_profile
echo 'export chainName='\"${chainName}\" >> $HOME/.bash_profile

source $HOME/.bash_profile
echo $AGORIC_NODENAME $AGORIC_WALLET $chainName
```
### Create a wallet
If you want to recover it then add `--recover` flag. Or just create a new key:
```
ag0 keys add $AGORIC_WALLET
```
- Write down the mnemonic phrase in a safe place
- Set a keyring password. It is a local defense. The password applies to all wallets on the server.
**Make init of Agoric with `--recover` flag**
```
ag0 init --chain-id $chainName $AGORIC_NODENAME --recover
```
!!! Use `--recover` to provide seed phrase of your wallet you created on the previous step to recover existing priv_validator_key instead of creating. 
If you do an `init` without this flag and lose the priv_validator_key.json file, you will never get access to the validator.

**Download `genesis.json`**
```
curl https://main.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json
```
**Download `chain.json`** which contains information that we will soon enter into the config. files
```
curl https://main.agoric.net/network-config > chain.json
```
**If you don't** add `chain_id` then you should
```
chainName=`jq -r .chainName < chain.json`
echo $chainName
. $HOME/.bash_profile
```
**Change `config.toml`** by information from `chain.json`
- Add peers, seeds. 
```
peers=$(jq '.peers | join(",")' < chain.json)
seeds=$(jq '.seeds | join(",")' < chain.json)
echo $peers
echo $seeds
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml
```
**Change `config.toml`**
- Comment out the line `log_level = info` for a more convenient change of the log mode from the service file.
- Set `minimum-gas-prices`. Since rewards are not enabled yet, we will set it to `0`. But soon this parameter will need to be changed to, for example, `0.025ubld`
- Telemetry
```
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025ubld\"/;" $HOME/.agoric/config/app.toml
sed -i '/\[telemetry\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.agoric/config/app.toml
sed -i "s/prometheus-retention-time = 0/prometheus-retention-time = 60/g" $HOME/.agoric/config/app.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.agoric/config/config.toml
```
## Change `config.toml` and `app.toml` for disk usage optimization
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.agoric/config/config.toml
sudo rm ~/.agoric/data/tx_index.db/*
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.agoric/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.agoric/config/app.toml
```
More about that you could find [here](https://surftest.gitbook.io/axelar-wiki/english/disk-usage-optimisation)

## Change `config.toml` to sync with a State sync snapshot
Insert data into variables
```
SNAP_RPC="http://154.12.241.178:26657" ; \
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height) ; \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)) ; \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash) ; \
echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
```
Now paste `$SNAP_RPC`, `$BLOCK_HEIGHT` and `$TRUST_HASH` values into the `config.toml`. And also set `enable=true`. All by one command
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.agoric/config/config.toml
```
For faster loading, enter the RPC node data in the config file, in the `persistent_peers` section:
`9373c1dbf0a040d2c76b120f8472871b92852f62@154.12.241.178:26656`
## Create service file for Agoric
```
sudo tee <<EOF >/dev/null /etc/systemd/system/agoricd.service
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which ag0) start --log_level=info
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
!! Everything is ready to launch. But we need **DDoS protection**. When you run the service file in this configuration, after synchronization, information about your node will be available on the Agoric public network. This exposes your validator to DDoS attacks.
If you want to secure a node with a validator, then before starting, click [[here]](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Sentry-Node-Architecture.md) and configure Agoric Sentry Node Architecture.
If you **decide not to protect** the server from DDoS attacks (**which is a security issue for the protocol**) then follow the instructions below.
## Start synchronization
```
ag0 unsafe-reset-all
sudo systemctl enable agoricd
sudo systemctl daemon-reload
sudo systemctl restart agoricd
sudo systemctl status agoricd
```
See logs and status
```
echo 'Node status:'$(sudo service agoricd status | grep active)
journalctl -u agoricd -f --output cat

ag0 status 2>&1 | jq .SyncInfo
curl localhost:26657/status | jq
```
## Create the validator
**Top up your wallet balance**
Transfer to the wallet you have [created before](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/Basic-Installation.md#create-a-wallet) some $BLD. On the basis of this wallet you will soon create your validator.
### Tx of creating the validator
If your node is fully synchronized, then run the tx to upgrade to validator status:
```
ag0 tx staking create-validator \
  --amount=<your_amount>ubld \
  --broadcast-mode=block \
  --pubkey=`ag0 tendermint show-validator` \
  --moniker=$AGORIC_NODENAME \
  --details="" \
  --identity="" \
  --commission-rate="0.05" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --from=$AGORIC_WALLET \
  --chain-id=$chainName \
  --gas=auto \
  --website="" \
  --gas-adjustment=1.4
```
- `<your_amount>` - specify the number of tokens that you want to delegate to your validator
- 1 bld = 1000000 ubld
- If you want to add identity then create an account here https://keybase.io/
- Also you could add details and website flag.
Greate. You could find your validator here https://main.explorer.agoric.net/validators
## tmkms (Recommended)
It is **highly recommended** to protect your validator from double-signing case.
[Official documentation](https://github.com/iqlusioninc/tmkms)
This could prevent the Double-signing even in the event the validator process is compromised.
Click [[here](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Agoric/tmkms-(separated-server))] the guide of Installing tmkms on an additional server that will serve as protection.
