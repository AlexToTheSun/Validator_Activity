## Let's create `tgrade.json` for PingPub
#### Find out `coin-type`:
```
tgrade keys add --help
```
#### Find out `cosmos_sdk_version`:
```
tgrade version --long
```
#### Create `tgrade.json` for PingPub:
- Add your `http://api_IP:api_PORT`
- Add your `http://rpc_IP:rpc_PORT`
```
sudo tee <<EOF >$HOME/explorer/src/chains/mainnet/tgrade.json
{
  "chain_name": "tgrade",
  "api": ["http://api_IP:api_PORT"],
  "rpc": ["http://rpc_IP:rpc_PORT"],
  "snapshot_provider": "",
  "sdk_version": "0.45.5",
  "coin_type": "118",
  "min_tx_fee": "50000",
  "assets": [
    {
      "base": "utgd",
      "symbol": "TGD",
      "exponent": "6",
      "coingecko_id": "",
      "logo": "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Mainnet-Guides/Tgrade/PingPub/tgrade.png"
    }],
  "addr_prefix": "tgrade",
  "logo": "https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Mainnet-Guides/Tgrade/PingPub/tgrade.png"
}
EOF
```
