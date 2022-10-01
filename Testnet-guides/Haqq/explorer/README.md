### Installation
Update & upgrade
```
sudo apt update && sudo apt upgrade -y
```
**We need Nginx**
```
sudo apt install nginx -y
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
#### Edit Nginx' config file
Open it in nano
```
nano /etc/nginx/sites-available/default
```
Go to `location` and change the line `try_files $uri $uri/ =404;` to `try_files $uri $uri/ /index.html;`. It will looks like that:
```
location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        try_files $uri $uri/ /index.html;
}
```

#### Download PingPub
You can just download PingPub
```
cd ~
git clone https://github.com/ping-pub/explorer.git
cd explorer
```

Or you can fork PingPub' [repository](https://github.com/ping-pub/explorer) and make your brunch. After that Download your fork.
What you could change:
1. **Logo**. Download your Logo files [here](https://github.com/ping-pub/explorer/tree/master/public)
2. **index.html**. Change `/favicon.ico` to `/logo.svg` on line [L11](https://github.com/ping-pub/explorer/blob/master/public/index.html#L11), and title on [L16](https://github.com/ping-pub/explorer/blob/master/public/index.html#L16).
3. **themeConfig.js**. Update name in navigation menu [here](https://github.com/ping-pub/explorer/blob/master/themeConfig.js#L12)
4. **Home.vue** Update name in the Home page [here](https://github.com/ping-pub/explorer/blob/master/src/views/Home.vue#L10)
5. **index.js**. [Update](https://github.com/ping-pub/explorer/blob/master/src/navigation/vertical/index.js) your social links, [icon](https://github.com/ping-pub/explorer/blob/master/src/navigation/vertical/index.js#L22) for ecosystem (your other blockchains).
6. **Error404.vue**. [Line 7](https://github.com/ping-pub/explorer/blob/master/src/views/error/Error404.vue#L7)
7. **ChainNotExist.vue**. [Line 7](https://github.com/ping-pub/explorer/blob/master/src/views/error/ChainNotExist.vue#L7)
8. **AppFooter.vue**. [Line 9](https://github.com/ping-pub/explorer/blob/master/src/%40core/layouts/components/AppFooter.vue#L9)
9. **PlaceForm.vue**. [Line 419](https://github.com/ping-pub/explorer/blob/master/src/views/components/KlineTrade/PlaceForm.vue#L419)

Insert your values:
- `<your_github_name>`
- `<your_brunch>`
```
cd ~
git clone --branch <your_brunch> https://github.com/<your_github_name>/explorer.git
cd explorer
```
**Delete unnecessary network json files**
```
rm src/chains/mainnet/*
```
**Add config**
Enter your values:
- find out `coin-type`: `haqqd keys add --help`
- find out `cosmos_sdk_version`: `haqqd version --long`
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
      "logo": "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Haqq/explorer/HAQQ.svg"
    }],
  "addr_prefix": "haqq",
  "logo": "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Haqq/explorer/HAQQ.svg"
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


