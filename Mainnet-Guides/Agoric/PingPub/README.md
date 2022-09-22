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
```
sudo tee <<EOF >$HOME/explorer/src/chains/mainnet/agoric.json
{
    "chain_name": "agoric",
    "api": ["http://154.12.241.178:1317"],
    "rpc": ["http://154.12.241.178:26657"],
    "snapshot_provider": "",
    "sdk_version": "0.45.4",
    "coin_type": "564",
    "min_tx_fee": "8000",
    "assets": [{
        "base": "ubld",
        "symbol": "BLD",
        "exponent": "6",
        "coingecko_id": "", 
        "logo": "https://raw.githubusercontent.com/Agoric/agoric-sdk/master/packages/wallet/ui/public/tokens/BLD.svg"
    },{
        "base": "urun",
        "symbol": "RUN",
        "exponent": "6",
        "coingecko_id": "", 
        "logo": ""
    }],
    "addr_prefix": "agoric",
    "logo": "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Mainnet-Guides/Agoric/PingPub/agoric.png"
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


