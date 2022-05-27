## Installation Overview
In this tutorial, we will:
- [Make minimal server protection]() 
  - [Change the password]()
  -  [Firewall configuration]() (ufw)
  - [Change the SSH port]()
  - [SSH key login]()
  - [Install File2ban]()
  - [2FA for SSH]()
- [Install Gravity Bridge Node]()
  - [Install the software]()
  - [Disk usage optimization]()
  - [Sync using opend RPC node with State Sync]()
  - [Create service file for Gravity Bridge]()
- [DDoS protection]() (Sentry nodes)
- [Start synchronization]()
- [Create the validator]()
- [Double-signing protection]() (tmkms)
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
### SSH key login
It is also highly recommended to set up an [SSH key login](https://surftest.gitbook.io/axelar-wiki/english/security-setup/ssh-key-login-+-disable-password). instead of a password. This is a more reliable method of protection than a password. 
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

# Setting up the validator node
**Update & upgrade**
```
sudo apt update && sudo apt upgrade -y
```
**Install the required packages**
```
sudo apt-get install nano mc git gcc g++ make curl yarn jq clang pkg-config libssl-dev build-essential ncdu -y
```
#### Download the latest version of Gravity chain and the Gravity tools
**Download Gravity chain**
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
**Download Gravity tools (GBT)**
```
cd gravity-bin
wget https://github.com/Gravity-Bridge/Gravity-Bridge/releases/download/v1.5.2/gbt
chmod +x *
sudo mv * /usr/bin/
gbt --version
# gbt 1.5.2

gbt --help
```
**Let's add variables.**
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
## Add your validator key
We need to import the validator key. This is the key containing Graviton tokens
```
# you will be prompted for your key phrase

gravity keys add $Grav_wallet
gravity keys show $Grav_wallet --bech val
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












