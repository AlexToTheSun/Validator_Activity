> ❗️ Please note that the installation must be carried out on the computer on which you have installed a browser with Metamask. Installation on a rented server (Vultr, Contabo, etc) is not relevant for Truffle.

# Table of content
1. Documetnation
2. Node.js installation
3. Truffle installation
4. Get/write a smart contract
5. Deployment of smart contract

## Documetnation
- [Install Truffle on Windows 10-11](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11) we will use this article with important clarifications.
- [Zkevm testnet docs](https://docs.zkevm.consensys.net/developers/quickstart/deploy-smart-contract/truffle#write-the-migration-script)
- [Boxes with projects](https://trufflesuite.com/docs/truffle/how-to/create-a-project/)

## Node.js installation
We will use:
- [instructions for Windows](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11)
- 

1) See recommended version at https://nodejs.org/en/ and download it.
2) Then follow a **Step 1** of the [instructions for Windows](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11) as shown in the screenshots:  
### Troubleshooting
If you get this error:
![Установка Командной строки](https://user-images.githubusercontent.com/30211801/223642691-fcc443cd-1c08-4ddd-afaf-5655f0ea5c9d.PNG)

Then you could ([ru](https://serverspace.ru/support/help/kak-ustanovit-menedzher-paketov-chocolatey-na-windows-server/)) reopen PowerShell as Administrator
![image](https://user-images.githubusercontent.com/30211801/223650505-4e241814-55fa-432e-a462-78fbab5cca23.png)

And run the command below:
```
choco install visualstudio2019-workload-vctools
```
**If this does not help, then install using the Windows Start button:**

1. Find `Visual Studio Installer`
![image](https://user-images.githubusercontent.com/30211801/223647925-4b3485d9-5865-4694-9174-6d3641a285e2.png)

2. Type Install (on screen I have already done this)
![image](https://user-images.githubusercontent.com/30211801/223648196-a87dccd2-dced-40cb-9329-cba8e832a85c.png)

## Truffle installation
We will use:
- [instructions for Windows](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11)

1) Run PowerShell as Administrator ❗️❗️❗️
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
5) If you have an Error:
![image](https://user-images.githubusercontent.com/30211801/223654850-54579d23-73e6-4922-bd73-6ba041bd030c.png)

Then type commands one by one. And after than - reopen PowerShell as Administrator:
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass
```
Good. Now our directory is `C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools`.
![image](https://user-images.githubusercontent.com/30211801/223704351-ce7818f9-1c62-45cb-9a7b-b7c1d07f121d.png)

6)  Check:
```
truffle
```
![image](https://user-images.githubusercontent.com/30211801/223655750-4c8ba93c-b392-4a12-8c23-a34ae49fc931.png)

🎉🎉🎉 Great job!

## Get/write a smart contract
We will use:
- [Zkevm testnet docs](https://docs.zkevm.consensys.net/developers/quickstart/deploy-smart-contract/truffle#write-the-migration-script)
- [Boxes with projects](https://trufflesuite.com/docs/truffle/how-to/create-a-project/)

The first step is to create a Truffle project.

You can create a new project, but for those just getting started, you can use [Truffle Boxes](https://trufflesuite.com/boxes), which are example applications and project templates. We'll use the [MetaCoin box](https://trufflesuite.com/boxes/metacoin), which creates a token that can be transferred between accounts:
1. Create a new directory for your Truffle project:
```
mkdir D:\zkEVM\test-truffle
cd D:\zkEVM\test-truffle
``` 
2. Download ("unbox") the MetaCoin box:
```
truffle unbox metacoin
```
Compile downloaded project:
```
truffle compile
```

To create a bare (new) Truffle project with no smart contracts included, use `truffle init`.

## Deployment of smart contract
1. Run
```
truffle dashboard
```
It will open a window on port `24012`.

2. Navigate to `localhost:24012` in your browser.
The site with Dashboard will automatically open. You will see:
![image](https://user-images.githubusercontent.com/30211801/223714573-09e37eba-6402-4c6e-ac94-986277a1c20b.png)

3. Select wallet and network in Metamask.

Please ensure that Dashboard is connected to the ConsenSys zkEVM testnet by connecting your MetaMask wallet to ConsenSys zkEVM. For reference, the ConsenSys zkEVM testnet network ID is `59140`. For that - use an email from hello@infura.io

![image](https://user-images.githubusercontent.com/30211801/223717172-344ffd8a-65fc-46a8-9e43-b65b5a22ab7e.png)

4. Click connect:
![image](https://user-images.githubusercontent.com/30211801/223718302-239ba3b0-40c1-4dc1-9bcb-0d361fe85f24.png)

5. Run in a separate terminal (open second session as administrator):
```
cd D:\zkEVM\test-truffle
truffle migrate --network dashboard
```
6. Navigate back to `localhost:24012` (It's already opend in the browser). You should see a prompt asking your to confirm the deployment. Click Confirm.
![Screenshot_1](https://user-images.githubusercontent.com/30211801/223775627-30adbaae-6ce9-4b07-8876-b9969f5daead.png)






















