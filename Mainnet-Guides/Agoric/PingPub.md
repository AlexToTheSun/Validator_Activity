### Installation
nginx
```
sudo apt install nginx
```
nodejs:
```
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
```
yarn
```
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
yarn --version
```
PingPub
```
cd ~
git clone https://github.com/ping-pub/explorer.git
cd explorer
```
clean
```
rm src/chains/mainnet/*
```
Add config
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
        "logo": "https://raw.githubusercontent.com/kj89/testnet_manuals/main/pingpub/logos/sei.png"
    },{
        "base": "urun",
        "symbol": "RUN",
        "exponent": "6",
        "coingecko_id": "", 
        "logo": ""
    }],
    "addr_prefix": "agoric",
    "logo": "https://raw.githubusercontent.com/Agoric/agoric-sdk/master/packages/wallet/ui/public/tokens/BLD.svg"
}
EOF
```

Build
```
cd ~/explorer
yarn && yarn build
cp -r ./dist/* /var/www/html
systemctl restart nginx.service
```
DONE

Add more
```
wget https://gist.githubusercontent.com/ryssroad/3a283625a40587bbfb31b0fe9ab37c07/raw/27a6cba0c9b3c40dbfee31008e35e113c937db89/axelar.json
cp axelar.json ~/explorer/src/chains/mainnet
```
```
wget https://gist.githubusercontent.com/ryssroad/6c6fc57d9e02d983e26064c89b4d48b8/raw/a7d4ee2362ebaf0f709ef36895930dcab3bab631/juno.json
cp juno.json ~/explorer/src/chains/mainnet
```
Rebuild
```
cd ~/explorer
yarn && yarn build
cp -r ./dist/* /var/www/html
```


