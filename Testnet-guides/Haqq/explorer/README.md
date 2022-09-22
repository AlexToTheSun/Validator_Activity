### Installation
**We need Nginx**
```
sudo apt install nginx
```
**Install nodejs v16.x:**

[Here](https://github.com/nodesource/distributions#installation-instructions) is the official installation instructions
```
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
```
**Install yarn**
```
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
yarn --version
```
**Download PingPub**
```
cd ~
git clone https://github.com/ping-pub/explorer.git
cd explorer
```
**Delete unnecessary network json files**
```
rm src/chains/mainnet/*
```
**Add config**
Enter your values:
- add `http://api_IP:api_PORT`
- add `http://rpc_IP:rpc_PORT`
```
sudo tee <<EOF >$HOME/explorer/src/chains/mainnet/haqq.json
{
  "chain_name": "haqq",
  "api": ["http://api_IP:api_PORT"],
  "rpc": ["http://rpc_IP:rpc_PORT"],
  "snapshot_provider": "",
  "sdk_version": "0.45.5",
  "coin_type": "60",
  "min_tx_fee": "800",
  "assets": [
    {
      "base": "aISLM",
      "symbol": "ISLM",
      "exponent": "18",
      "coingecko_id": "",
      "logo": "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Haqq/explorer/HAQQ.png"
    }],
  "addr_prefix": "haqq",
  "logo": "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Haqq/explorer/HAQQ.png"
}
EOF
```

**Build**
```
cd ~/explorer
yarn && yarn build
cp -r ./dist/* /var/www/html
systemctl restart nginx.service
```
DONE

You can add more configs, after that rebuild again:
```
cd ~/explorer
yarn && yarn build
cp -r ./dist/* /var/www/html
```


