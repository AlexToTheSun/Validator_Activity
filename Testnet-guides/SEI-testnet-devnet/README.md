![Снимок экрана от 2022-07-09 13-48-13](https://user-images.githubusercontent.com/30211801/178100743-46903a8c-25ec-4250-99f6-116e87f5e295.png)
# Sei Network
Sei Network is the first orderbook-specific L1 blockchain. It is built using the Cosmos SDK and Tendermint core, and features a built-in central limit orderbook (CLOB) module.
### Links
- [Official site](https://www.seinetwork.io/)
- [GitHub](https://github.com/sei-protocol)
- [Releases](https://github.com/sei-protocol/sei-chain/releases)
- [Docs](https://docs.seinetwork.io/introduction/overview)
- Explorers:
  - https://sei.explorers.guru/
  - https://testnet.explorer.testnet.run/sei-network
## Activities
Here is a testnet [announcement](https://discord.com/channels/973057323805311026/973094250948464680/994727109765386432). Incentives will start on Monday (07/11/2022) 
### CHAIN: `atlantic-1`
Now you could do a RP for Becoming A Validator
- [Guide](https://docs.seinetwork.io/nodes-and-validators/seinami-incentivized-testnet/joining-incentivized-testnet) from off Docs
### Short instructions
```
sudo apt update && sudo apt upgrade -y
sudo apt-get install make git jq curl gcc g++ mc nano -y

# add variables
sei_MONIKER=<your_moniker>
sei_WALLET=<your_wallet_name>
sei_CHAIN=atlantic-1
echo 'export sei_MONIKER='\"${sei_MONIKER}\" >> $HOME/.bash_profile
echo 'export sei_WALLET='\"${sei_WALLET}\" >> $HOME/.bash_profile
echo 'export sei_CHAIN='\"${sei_CHAIN}\" >> $HOME/.bash_profile
source $HOME/.bash_profile

# install go
wget -O go1.18.linux-amd64.tar.gz https://go.dev/dl/go1.18.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz && rm go1.18.linux-amd64.tar.gz
cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version

# <tag_name> = 1.0.6beta
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.6beta
make install
# Verify the version
seid version --long | head

# Create wallet and init Sei
seid keys add $WALLET
seid init $NODENAME --chain-id $CHAIN_ID

# Add genesis account
WALLET_ADDRESS=$(seid keys show $WALLET -a)
seid add-genesis-account $WALLET_ADDRESS 10000000usei

# Generate gentx
seid gentx $sei_WALLET 10000000usei \
--chain-id $sei_CHAIN \
--moniker=$sei_MONIKER \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.10 \
--commission-rate=0.04 \
--identity="" \
--details="" \
--security-contact="" \
--website=""
```
After that you should get the file `/root/.sei/config/gentx/gentx-xxxxxxxxxxxxxxxx.json`.
### Make PR
1) Fork the testnet repository https://github.com/sei-protocol/testnet
2) Decide whether you will download the gentx file or create it. Name should be like this example: `gentx-ExampleMoniker.json`

To copy content from your gentx from putty type the command  ()
```
cat /root/.sei/config/gentx/gentx-xxxxxxxxxxxxxxxxxxxxxxxxxx.json
```
3) Go to your forked repository in the folder `testnet/sei-incentivized-testnet/gentx` and сreate/upload your gentx 
4) Create a Pull Request

### Fill out forms
1) https://forms.gle/CzBeqENRZrrXXG4x7
2) https://forms.gle/z8xEpEDjf1ug2Lwu7

Incentives will start on Monday **(07/11/2022)** So After that will be waiting a [discord](https://discord.gg/SDJ7ky75) announcement














