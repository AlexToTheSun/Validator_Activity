## Chain: `stafihub-public-testnet-3`
Useful links:
- [Github](https://github.com/stafihub/)
- [Explorer](https://testnet-explorer.stafihub.io/stafi-hub-testnet)
- [Official documentation](https://github.com/stafihub/stafihub/tree/public-testnet-v3)

## Overview
In this tutorial, we will:
- [Make minimal server protection]()
  - [Change the password]()
  -  [Firewall configuration]() (ufw)
  - [Change the SSH port]()
  - [SSH key login]()
  - [Install File2ban]()
  - [2FA for SSH]()
- [Install Agoric Node]()
  - [Install the software]()
  - [Disk usage optimization]()
  - [Sync using opend RPC node with State Sync]()
  - [Create service file for Agoric]()
- [DDoS protection]() (Sentry nodes)
- [Start synchronization]()
- [Create the validator]()
- [Double-signing protection]()

# Minimal server protection
Let's start with the security settings.

It needs to be done but will not protect against all threats. Requires more advanced security settings.
### Change the password
```
passwd
```
### Firewall configuration
Install ufw
```
sudo apt ufw install -y
```
Open the ports necessary for StafiHub
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
It is also highly recommended to set up an SSH key login instead of a password. This is a more reliable method of protection than a password.

Now we will enable ssh key login, and disable password login. 

This guide is for those who have **Linux/macOS** installed on their local computer. If you have a different system, such as **windows**, use [[this](https://surftest.gitbook.io/axelar-wiki/english/security-setup/ssh-key-login-+-disable-password)] instruction.

#### Generate ssh keys
Unix has a built-in key generator. Launch the terminal on PC and enter:
```
ssh-keygen
```
> It will be possible **to set a password for SSH keys**. This will additionally protect you from possible key theft. The main thing is to write down the password in a safe place. If you do not want to set a password, press **Enter**.
Done, the keys are created and stored in the folder `~/.ssh/`
- `~/.ssh/id_rsa` - private key. We should leave it on PC.
- `~/.ssh/id_rsa.pub` - public key. Must be on the server.
#### Uploading the public key to the server
On Unix systems for this you could open a terminal on PC and enter the command:
```
ssh-copy-id root@ххх.ххх.ххх.ххх
```
where:
- `root` - the user we want to access the server using ssh keys.
- `ххх.ххх.ххх.ххх` - server ip address.
**If you would like to specify** the **path** to the public key, and the server has a non-standard (22) port, use the `-i`, `-p` flags:
```
ssh-copy-id -i /home/user/.ssh/id_rsa_test.pub -p 22 root@ххх.ххх.ххх.ххх
```
Flags:
- `-i /home/user/.ssh/id_rsa_test.pub` - specify the path to your public key.
- `-p 22`  - specify your ssh port.

Ready. You can proceed to the next step - Checking the login using the SSH key.
#### Checking for login with SSH keys.
We will not only check, but also save the session for further convenient work.
1) On the session tab, insert the IP and port:  
![image](https://user-images.githubusercontent.com/30211801/171718181-c0403171-4d8a-49ff-8b3b-0dc0248e0541.png)

2) Go to the **Connection --> SSH --> Auth** section and write the path to the private key that we created and placed in the folder we need:  
![image](https://user-images.githubusercontent.com/30211801/171718460-c1d49e4f-9ab4-47af-b387-25e99fb742a3.png)

3) Go back to the **Session** section --> Come up with a name for the session --> **Save** the session --> And go into it.  
![171718829-4e014418-f01f-43c4-8497-14a5f06858a3](https://user-images.githubusercontent.com/30211801/178956303-6d1b90a3-e7d4-4c4d-ad5e-7ba2be04dac9.png)

If everything worked out successfully, the last step left for us is to disable password entry.
#### Disabling password login.
Make sure that the key is securely stored and you will not lose it, because you will no longer log in with the password (only through the console in the provider's personal account, or through VNS).

Log in to the server, then open the configuration file for editing `/etc/ssh/sshd_config`:
```
sudo nano /etc/ssh/sshd_config
```
Find the line there `PasswordAuthenticatin yes`. You need to set its value to `No`:
```
PasswordAuthentication no
```
![image](https://user-images.githubusercontent.com/30211801/171719306-ce05e885-920a-4148-9489-0ea3725cce6c.png)  
Let's restart the service:
```
sudo systemctl restart sshd
```
Everything is ready!🎉
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

# Install StafiHub
First we need to install the software, ran `init` and set up the configuration files to be able to start the sync.
### Install the software
**Update & upgrade**
```
sudo apt update && sudo apt upgrade -y
```
**Install the required packages**
```
sudo apt-get install nano mc git gcc g++ make curl yarn jq -y
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
#### Install the latest version of StafiHub
All forks and releases can be viewed here: [Releases](https://github.com/stafihub/stafihub/releases)
```
git clone --branch public-testnet-v3 https://github.com/stafihub/stafihub
cd $HOME/stafihub
git checkout latest
make install
cp $HOME/go/bin/stafihubd /usr/local/bin
stafihubd version --long
```
**Let's add variables.**
- `<YOUR_MONIKER>` - Your node name
- `<YOUR_WALLET>` - Your wallet name
```
stafihub_NODENAME=<YOUR_MONIKER>
stafihub_WALLET=<YOUR_WALLET>
stafihub_CHAIN=stafihub-public-testnet-3
echo 'export stafihub_NODENAME='\"${stafihub_NODENAME}\" >> $HOME/.bash_profile
echo 'export stafihub_WALLET='\"${stafihub_WALLET}\" >> $HOME/.bash_profile
echo 'export stafihub_CHAIN='\"${stafihub_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo $stafihub_NODENAME $stafihub_WALLET $stafihub_CHAIN
```
### Create a wallet
If you want to recover it then add `--recover` flag. Or just create a new key:
```
stafihubd keys add $stafihub_WALLET
```
- Write down the mnemonic phrase in a safe place
- Set a keyring password. It is a local defense. The password applies to all wallets on the `~/.stafihub`.
**Make Stafihub init**
```
stafihubd init --chain-id $stafihub_CHAIN $stafihub_WALLET
```
- Write down `priv_validator_key.json` and `node_key.json` in a safe place. If you lose the priv_validator_key.json file, you will never get access to the validator.

**Download `genesis.json`**
```
wget -O $HOME/.stafihub/config/genesis.json "https://raw.githubusercontent.com/stafihub/network/main/testnets/stafihub-public-testnet-3/genesis.json"
```


Include peers in `config.toml`. By one command
```
PEERS="4e2441c0a4663141bb6b2d0ea4bc3284171994b6@46.38.241.169:26656,79ffbd983ab6d47c270444f517edd37049ae4937@23.88.114.52:26656" ; \
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.stafihub/config/config.toml
```
#### Change some `config.toml` settings
- Set `minimum-gas-prices`. We will set it to `0` in testnet.
- Prometheus enable
```
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.01ufis\"/;" $HOME/.stafihub/config/app.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.stafihub/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stafihub/config/app.toml
```
#### Disk usage optimization
**Indexing**. The "Indexing" function is only needed by those who need to request transactions from a specific node. So let's disable it.
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.stafihub/config/config.toml
sudo rm ~/.stafihub/data/tx_index.db/*
```
**Logging**. By default, the node state logging level is set to info, i.e. full display of all node information. Let's comment `#` log_level in config and type this flag in the service file to the `warn` log display level. Don't forget that after that in logs you will only see warns and errors 🤷‍♂️
```
sed -i.bak 's/^log_level/# log_level/' $HOME/.stafihub/config/config.toml
```
**Pruning**
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.stafihub/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.stafihub/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.stafihub/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.stafihub/config/app.toml
```
#### Create service file for StafiHub
```
sudo -E bash -c 'cat << EOF > /etc/systemd/system/stafihubd.service
[Unit]
Description=StaFiHub Cosmos Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which stafihubd) start  --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF'
```
You could change `--log_level=info` flag after making sure everything works.

The logging level (`trace`|`debug`|`info`|`warn`|`error`|`fatal`|`panic`)

### Sentry Node Architecture (Recommended)
!! Everything is ready to launch. But we need **DDoS protection**. When you run the service file in this configuration, after synchronization, information about your node will be available on the StafiHub public network. This exposes your validator to DDoS attacks.
If you want to secure a node with a validator, then before starting, click [[here]]() and configure StafiHub Sentry Node Architecture.
If you **decide not to protect** the server from DDoS attacks (**which is a security issue for the protocol**) then follow the instructions below.

### Start Synchronization
**If you synced by State sync before, disable it**.  
Disable synchronization using State Sync (this feature will prohibit synchronization from scratch, so we should disable it)
```
sed -i -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.stafihub/config/config.toml
```
Reset the data folder
```
stafihubd tendermint unsafe-reset-all --home ~/.stafihub
```
Then Start the service to synchronize a node
```
sudo systemctl daemon-reload
sudo systemctl enable stafihubd
sudo systemctl restart stafihubd
```
If needed to stop
```
sudo systemctl stop stafihubd
```
Status and logs
```
stafihubd status 2>&1 | jq
stafihubd status 2>&1 | jq .SyncInfo
sudo journalctl -u stafihubd -f --output cat
```
To find out your node_id:
```
curl localhost:26657/status | jq '.result.node_info.id'
```
### Create the validator
First of all top up your wallet balance
#### Faucet
Request tokens from [discord](https://discord.gg/4UFqJhZ4) in the `#stafi-hub-faucetw` channel by the command `!faucet send <YOUR_WALLET_ADDRESS>`

To find out your wallet type:
```
stafihubd keys show $stafihub_WALLET -a
```
Check balance:
```
stafihubd q bank balances $(stafihubd keys show $stafihub_WALLET -a)
```
### Tx of creating the validator
If your node is fully synchronized, then run the tx to upgrade to validator status:
```
stafihubd tx staking create-validator \
 --amount=<your_amount>ufis \
 --broadcast-mode=block \
 --pubkey=$(stafihubd tendermint show-validator) \
 --min-self-delegation=1 \
 --moniker=$stafihub_NODENAME \
 --from=$stafihub_WALLET \
 --chain-id=$stafihub_CHAIN \
 --details="" \
 --website="" \
 --identity="" \
 --commission-rate=0.07 \
 --commission-max-rate=0.20 \
 --commission-max-change-rate=0.01 \
 --gas-prices=0.025ufis \
 --gas=auto \
 --gas-adjustment=1.4
```
-`<your_amount>` - specify the number of tokens that you want to delegate to your validator
- 1 fis = 1000000 ufis
- If you want to add identity then create an account here https://keybase.io/
- Also you could add details and website flag.
Greate. You could find your validator here https://testnet-explorer.stafihub.io/stafi-hub-testnet/staking

By the way, after you create a validator, you could get a role, follow the instruction in [[discord](https://discord.com/channels/724473389913473616/731341538520465511/971438624128262196)]
# Commands
Unjail
```
stafihubd tx slashing unjail \
  --broadcast-mode=block \
  --from=$stafihub_WALLET \
  --chain-id=$stafihub_CHAIN \
  --gas=auto
```
Reset the downloaded information from the data folder
```
stafihubd tendermint unsafe-reset-all --home $HOME/.stafihub
```
Find out your wallet
```
stafihubd keys show $stafihub_WALLET -a
```
Find out your validator
```
stafihubd keys show $stafihub_WALLET --bech val -a
```
Find out information about your validator
```
stafihubd query staking validator $(stafihubd keys show $stafihub_WALLET --bech val -a)
```
## More about wallets delegations and rewards
To see how many tokens are in your wallet:
```
stafihubd q bank balances $(stafihubd keys show $stafihub_WALLET -a)
```
Withdraw all delegation rewards
```
stafihubd tx distribution withdraw-all-rewards --node "tcp://127.0.0.1:26657" --from=$stafihub_WALLET --chain-id=$stafihub_CHAIN --gas=auto
```
How to withdraw validator commission
```
stafihubd tx distribution withdraw-rewards $(stafihubd keys show $stafihub_WALLET --bech val -a) \
--chain-id $stafihub_CHAIN \
--from $stafihub_WALLET \
--commission \
--fees 1000ufis \
--yes
```
Self delegation
```
stafihubd tx staking delegate --node "tcp://127.0.0.1:26657" $(stafihubd keys show $stafihub_WALLET --bech val -a) <amount_to_delegate>ufis \
--chain-id=$stafihub_CHAIN \
--from=$stafihub_WALLET \
--gas=auto
```
## tmkms (Recommended)
It is **highly recommended** to protect your validator from double-signing case.
[Official documentation](https://github.com/iqlusioninc/tmkms)
This could prevent the Double-signing even in the event the validator process is compromised.
Click [[here]()






