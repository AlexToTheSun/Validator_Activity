## Minimal server protection
It will not protect against all threats. Requires more advanced security settings such as DDoS and double signing protection.

## Overview
In this tutorial, we will:
- [Change the password](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#change-the-password)
- [Firewall configuration](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#firewall-configuration) (ufw)
- [Change the SSH port](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#change-the-ssh-port)
- [SSH key login](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#ssh-key-login)
- [Install File2ban](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#install-file2ban)
- [2FA for SSH](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md#2fa-for-ssh)
## Universal Script
This script includes all modules from this article and you could choose which module to run. The modules go one by one, interactively.
```
wget -O server-protection.sh https://raw.githubusercontent.com/AlexToTheSun/Cosmos_Quick_Wiki/main/Scripts/server-protection.sh && chmod +x server-protection.sh && ./server-protection.sh
```
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
Open the ports necessary for your project. In cosmos networks, the most commonly used costs are listed below:
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

This guide is for those who have **Linux/macOS** installed on their local computer. If you have a different system, such as **windows**, use [[this instruction](https://surftest.gitbook.io/axelar-wiki/english/security-setup/ssh-key-login-+-disable-password)].

#### Generate ssh keys
Unix has a built-in key generator. Launch the terminal on PC and enter:
```
ssh-keygen
```
> It will be possible **to set a password for SSH keys**. This will additionally protect you from possible key theft. The main thing is to write down the password in a safe place. If you do not want to set a password, press **Enter**.
Done, the keys are created and stored in the folder `~/.ssh/` (for example `/home/user/.ssh/`)
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
![image](https://user-images.githubusercontent.com/30211801/171718829-4e014418-f01f-43c4-8497-14a5f06858a3.png)

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
