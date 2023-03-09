> ❗️ Please note that the installation must be carried out on the computer on which you have installed a browser with Metamask. Installation on a rented server (Vultr, Contabo, etc) is not relevant for Truffle.
# Table of content
1. [Documetnation](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/ConsenSys-zkEVM/Truffle-zkEVM-Ubuntu.md#documetnation)
3. [Truffle installation](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/ConsenSys-zkEVM/Truffle-zkEVM-Ubuntu.md#truffle-installation)
4. [Get/write a smart contract](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/ConsenSys-zkEVM/Truffle-zkEVM-Ubuntu.md#getwrite-a-smart-contract)
5. [Deployment of smart contract](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/ConsenSys-zkEVM/Truffle-zkEVM-Ubuntu.md#deployment-of-smart-contract)

## Documetnation
- [Install Truffle on Ubuntu](https://trufflesuite.zendesk.com/hc/en-us/articles/5661666603419-Installing-Truffle-on-Ubuntu).
- [Truffle on Ubuntu or Windows 10 with “Windows subsystem for Linux”](https://davidburela.wordpress.com/2017/05/12/how-to-install-truffle-testrpc-on-ubuntu-or-windows-10-with-windows-subsystem-for-linux/)
- [Zkevm testnet docs](https://docs.zkevm.consensys.net/developers/quickstart/deploy-smart-contract/truffle#write-the-migration-script)
- [Boxes with projects](https://trufflesuite.com/docs/truffle/how-to/create-a-project/)
- [Truffle installation](https://trufflesuite.com/docs/truffle/how-to/install/)
- [Truffle for VS Code extension (Optional)](https://trufflesuite.com/blog/build-on-web3-with-truffle-vs-code-extension/)
- [Youtube video: tutorial for beginners](https://www.youtube.com/watch?v=62f757RVEvU)

## Truffle installation
Update:
```bash
sudo apt update && sudo apt upgrade -y
```
We need to install npm nodejs git:
```
sudo apt install npm git tmux mc -y
```
Install nodejs. See recommended version at https://nodejs.org/en/
```
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```
Install truffle:
```
npm install -g truffle
truffle version
```
You should see output like that:
```
Truffle v5.7.9 (core: 5.7.9)
Ganache v7.7.5
Solidity v0.5.16 (solc-js)
Node v18.14.2
Web3.js v1.8.2
```

## Get/write a smart contract
The first step is to create a Truffle project.

You can create a new project, but for those just getting started, you can use [Truffle Boxes](https://trufflesuite.com/boxes), which are example applications and project templates. We'll use the [MetaCoin box](https://trufflesuite.com/boxes/metacoin), which creates a token that can be transferred between accounts:
1. Create a new directory for your Truffle project:
```
mkdir /root/zkevm-truffle
cd /root/zkevm-truffle
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
[Documentation](https://docs.zkevm.consensys.net/developers/quickstart/deploy-smart-contract/truffle#truffle-dashboard)
1. Run it to open a dashboard in the browser:
```bash
# Create tmux session:
tmux new -s dashboard

# then open a dashboard by command:
truffle dashboard
```
Detach from "dashboard" session❗️ Type `Ctrl`+`b` `d` (the session will continue to run in the background).

A window will be opened on port `24012`.

2. Navigate to `localhost:24012` in your browser.
The site with Dashboard will automatically open. You will see:
![223718302-239ba3b0-40c1-4dc1-9bcb-0d361fe85f24](https://user-images.githubusercontent.com/30211801/224006271-b2c55f1f-5400-48fe-b310-1792d1ca70fe.png)

3. Select wallet and network in Metamask.

Please ensure that Dashboard is connected to the ConsenSys zkEVM testnet by connecting your MetaMask wallet to ConsenSys zkEVM. For reference, the ConsenSys zkEVM testnet network ID is `59140`. For that - use an email from hello@infura.io

![223717172-344ffd8a-65fc-46a8-9e43-b65b5a22ab7e](https://user-images.githubusercontent.com/30211801/223978956-709a5c45-c050-4348-8d72-622e57b200e3.png)

4. Click connect:
![223718302-239ba3b0-40c1-4dc1-9bcb-0d361fe85f24](https://user-images.githubusercontent.com/30211801/223977963-9431251c-4cde-4767-b827-71fd7c24a16d.png)

5. Run in the terminal:
```
cd /root/zkevm-truffle
truffle migrate --network dashboard
```
6. Navigate back to `localhost:24012` (It's already opened in the browser). You should see a prompt asking your to confirm the deployment. Click Confirm.
![Screenshot_1](https://user-images.githubusercontent.com/30211801/223775627-30adbaae-6ce9-4b07-8876-b9969f5daead.png)

7. Если вы закончили работу с Truffle, то закройте tmux сессию
```
tmux kill-session -t dashboard
```


