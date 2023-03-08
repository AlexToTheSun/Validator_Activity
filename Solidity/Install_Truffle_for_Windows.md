> ❗️ Please note that the installation must be carried out on the computer on which you have installed a browser with Metamask. Installation on a rented server (Vultr, Contabo, etc) is not relevant for Truffle.

The easiest way to install for Windows is to run the Node.js installation and check the box "Automatically install the necessary tools..."

This will install programs such as:
- Python
- Visual Studio Build Tools
- Chocolately
# Table of content
- Documetnation
- Node.js installation
- Install Truffle

## Documetnation
- [Install Truffle on Windows 10-11](https://trufflesuite.zendesk.com/hc/en-us/articles/8150057408923-install-Truffle-on-Windows-10-11) we will use this article with small but important clarifications.
- [Zkevm testnet docs](https://docs.zkevm.consensys.net/developers/quickstart/deploy-smart-contract/truffle#write-the-migration-script)



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
Now our directory is 
```
C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools
```
![image](https://user-images.githubusercontent.com/30211801/223704351-ce7818f9-1c62-45cb-9a7b-b7c1d07f121d.png)
6) Again reopen PowerShell as Administrator. And check:
```
truffle
```
![image](https://user-images.githubusercontent.com/30211801/223655750-4c8ba93c-b392-4a12-8c23-a34ae49fc931.png)

🎉🎉🎉 Great job!

## Deploy smartcontract
In the PowerShell program, you need to select the directory in which we will work. To do this, I will create a new folder:
```
mkdir D:\zkEVM\test-truffle
```
Let's go to the created directory:
```
cd D:\zkEVM\test-truffle
```
[We should init](https://docs.zkevm.consensys.net/developers/quickstart/deploy-smart-contract/truffle#write-the-smart-contract) a new project
```
truffle init
```

### 1 Write the smart contract

Create a file of contract named `Token` by a command `truffle create contract Token`. Then open this file (`D:\zkEVM\test-truffle\contracts\Token.sol`) and input code of smartcontract.

OR just run the command below:
```
'pragma solidity >=0.4.22 <0.9.0;

// SPDX-License-Identifier: MIT

contract Token {
  string public name = "My Token";
  string public symbol = "MTK";
  uint8 public decimals = 18;
  uint256 public totalSupply = 100000000;

  mapping (address => uint256) public balances;
  address public owner;

  constructor() {
    owner = msg.sender;
    balances[owner] = totalSupply;
  }

  function transfer(address recipient, uint256 amount) public {
    require(balances[msg.sender] >= amount, "Insufficient balance.");
    balances[msg.sender] -= amount;
    balances[recipient] += amount;
  }
}'  | Out-File -FilePath D:\zkEVM\test-truffle\contracts\Token.sol
```
Check
```
Get-Content D:\zkEVM\test-truffle\contracts\Token.sol
```
### 2 Write the migration script
[To tell Truffle how](https://docs.zkevm.consensys.net/developers/quickstart/deploy-smart-contract/truffle#write-the-migration-script) to deploy our smart contracts, we need to write a migration script.

If the file is large, then it is more convenient to create it like this:
1. In Windows - open a folder `D:\zkEVM\test-truffle\migrations` and create `donor.txt` file with the text of migration script:
![image](https://user-images.githubusercontent.com/30211801/223765726-29adc3ec-df05-4cfa-9661-5fda2fb38b5f.png)

And there's a text we need to input into a `donor.txt` file:
```
const Token = artifacts.require("Token");

module.exports = function (deployer) {
  deployer.deploy(Token);
};
```

2. Set the content of this file as a variable:
```
$file_text = Get-Content D:\zkEVM\test-truffle\migrations\donor.txt
```

Then let's create a migration script `1_deploy_token.js`
```
$file_text | Out-File -FilePath D:\zkEVM\test-truffle\migrations\1_deploy_token.js
```

Check:
```
Get-Content D:\zkEVM\test-truffle\migrations\1_deploy_token.js
```
![image](https://user-images.githubusercontent.com/30211801/223712982-f523e1cd-d112-4460-8dab-3d797b496d3b.png)
Compile smartcontract
```
truffle compile
```

### 3 Deploy your contract through Dashboard
1. Run
```
truffle dashboard
```
Navigate to `localhost:24012` in your browser.
The site with Dashboard will automatically open. You will see:
![image](https://user-images.githubusercontent.com/30211801/223714573-09e37eba-6402-4c6e-ac94-986277a1c20b.png)
2. Select wallet and network in Metamask

Please ensure that Dashboard is connected to the ConsenSys zkEVM testnet by connecting your MetaMask wallet to ConsenSys zkEVM. For reference, the ConsenSys zkEVM testnet network ID is 59140. For that - use an email from hello@infura.io
![image](https://user-images.githubusercontent.com/30211801/223717172-344ffd8a-65fc-46a8-9e43-b65b5a22ab7e.png)

3. Click connect
![image](https://user-images.githubusercontent.com/30211801/223718302-239ba3b0-40c1-4dc1-9bcb-0d361fe85f24.png)

4. Run in a separate terminal (open second session as administrator) .
```
cd D:\zkEVM\test-truffle
truffle migrate --network dashboard
```


