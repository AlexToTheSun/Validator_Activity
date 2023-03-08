> ❗️ Please note that the installation must be carried out on the computer on which you have installed a browser with Metamask. Installation on a rented server (Vultr, Contabo, etc) is not relevant for Truffle.

The easiest way to install for Windows is to run the Node.js installation and check the box "Automatically install the necessary tools..."

This will install programs such as:
- Python
- Visual Studio Build Tools
- Chocolately
## Table of content
- [Install Truffle on Windows 10-11](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11) we will use this article with small but important clarifications.



## Node.js installation
1) See recommended version at https://nodejs.org/en/ and download it.
2) Then follow the instructions as shown in the screenshots in **[Step 1.](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11)**  
### Troubleshooting
If you get this error:
![Установка Командной строки](https://user-images.githubusercontent.com/30211801/223642691-fcc443cd-1c08-4ddd-afaf-5655f0ea5c9d.PNG)

Then you could ([ru](https://serverspace.ru/support/help/kak-ustanovit-menedzher-paketov-chocolatey-na-windows-server/)) reopen PowerShell as Administrator
![image](https://user-images.githubusercontent.com/30211801/223650505-4e241814-55fa-432e-a462-78fbab5cca23.png)

And run the command below
```
choco install visualstudio2019-workload-vctools
```
**If this does not help, then install using the Windows Start button:**

1. Find `Visual Studio Installer`
![image](https://user-images.githubusercontent.com/30211801/223647925-4b3485d9-5865-4694-9174-6d3641a285e2.png)

2. Type Install (on screen I have already done this)
![image](https://user-images.githubusercontent.com/30211801/223648196-a87dccd2-dced-40cb-9329-cba8e832a85c.png)


## Install Truffle
- [Step 2](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11)

1) ❗️❗️❗️ Run PowerShell as Administrator
![image](https://user-images.githubusercontent.com/30211801/223653639-c4d3cfa7-cde7-4d61-8de5-2c8c72f6abb6.png)
2) Check
```
node -v
npm -v
```
3) Install Truffle
```
npm install -g truffle
```
4) Check truffle
```
truffle
```
5) If you have an Error
![image](https://user-images.githubusercontent.com/30211801/223654850-54579d23-73e6-4922-bd73-6ba041bd030c.png)
Type commands one by one:
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass
```
6) Again reopen PowerShell as Administrator. And check:
```
truffle
```
![image](https://user-images.githubusercontent.com/30211801/223655750-4c8ba93c-b392-4a12-8c23-a34ae49fc931.png)

🎉🎉🎉 Great job!
