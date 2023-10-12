#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt-get install make git jq curl gcc g++ mc nano -y

# Set the variables
bech_prefix=haqq
bech_validator_prefix=haqqvaloper
bech_validator_pubkey_prefix=haqqvaloperpub
bech_consensus_node_prefix=haqqvalcons
bech_consensus_node_pubkey_prefix=haqqvalconspub
echo $bech_prefix
echo $bech_validator_prefix
echo $bech_validator_pubkey_prefix
echo $bech_consensus_node_prefix
echo $bech_consensus_node_pubkey_prefix
mintscan_prefix=haqq
echo $mintscan_prefix
validator_page_pattern=https://haqq.explorers.guru/validator/
echo $validator_page_pattern
config_path=/home/user/config/missed-blocks-checker-telegram-labels.toml
echo $config_path

read -p "Do you set this alert manager on a server with a project node? (y/n): " your_answer
  case $your_answer in
    [Yy]* ) node_ip=localhost
    ;;
    [Nn]* ) read -p "Enter server' ip of your node: " node_ip
    ;;
  esac
read -p "Are your Node' RPC and gRPC ports set by default? (y/n): " your_answer
  case $your_answer in
    [Yy]* )
      rpc_address="tcp://$node_ip:26657"
      grpc_address="$node_ip:9090"
      echo $rpc_address
      echo $grpc_address
    ;;
    [Nn]* )
      read -p "Enter rpc port: " rpc_port
      read -p "Enter grpc port: " grpc_port
      rpc_address="tcp://$node_ip:$rpc_port"
      grpc_address="$node_ip:$grpc_port"
      echo $rpc_address
      echo $grpc_address
      ;;
  esac
# Telegram
read -p "Telegram Bot Token: " Telegram_Bot_Token
echo $Telegram_Bot_Token
read -p "Your User ID: " Your_User_ID
echo $Your_User_ID

# read -p "Write validators to monitor them, or to exclude them (comma separated): " validators
# Here we will determine for the future whether the script will monitor one validator or remove it from the list
# We will use in soon
read -p "Do you want to include validators to monitor only them (type: YES), or to exclude them from list of all other (type: NO)?: " your_answer
  case $your_answer in
    [Yy]* )
      incl_excl=include
      read -p "Write validators to monitor them (comma separated): " validators
      ;;
    [Nn]* )
      incl_excl=exclude
      read -p "Write validators to exclude them (comma separated): " validators
      ;;
  esac
echo $validators
echo $incl_excl

#Go
# We NEED go1.19.4 VERSION. So I commented out the if condition and reinstalled Go again
# if ! [ -x "$(command -v go)" ]; then
  wget -O go1.19.linux-amd64.tar.gz https://go.dev/dl/go1.19.linux-amd64.tar.gz
  rm -rf /usr/local/go
  tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
  rm go1.19.linux-amd64.tar.gz
#  cat <<'EOF' >> $HOME/.bash_profile
#  export GOROOT=/usr/local/go
#  export GOPATH=$HOME/go
#  export GO111MODULE=on
#  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
#  EOF
  echo 'export GOROOT=/usr/local/go' >> ~/.bash_profile
  echo 'export GOPATH=$HOME/go' >> ~/.bash_profile
  echo 'export GO111MODULE=on' >> ~/.bash_profile
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
  source $HOME/.bash_profile
  cp /usr/local/go/bin/go /usr/bin
  go version
# fi

# Install missed-blocks-checker
cd $HOME
git clone https://github.com/solarlabsteam/missed-blocks-checker
cd missed-blocks-checker
go build
cp /root/missed-blocks-checker/main /usr/local/bin/missed-blocks-checker
cp /root/missed-blocks-checker/config.example.toml /root/missed-blocks-checker/config.haqq.toml

# sudo tee /etc/systemd/system/missed-blocks-checker.service >/dev/null <<EOF
sudo tee <<EOF >/dev/null /etc/systemd/system/missed-blocks-checker.service
[Unit]
Description=HAQQ Missed Blocks Checker
After=network-online.target

[Service]
User=$USER
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=missed-blocks-checker --config /root/missed-blocks-checker/config.haqq.toml
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF



# Variables
# Paste values into config file
case $incl_excl in
  include )
    sed -i -E "s|^(include-validators[[:space:]]+=[[:space:]]+).*$|\1\[\"$validators\"\]| ; \
    s|^(exclude-validators[[:space:]]+=[[:space:]]+.*)|\# \1|" /root/missed-blocks-checker/config.haqq.toml
    ;;
  exclude )
    sed -i -E "s|^(include-validators[[:space:]]+=[[:space:]]+.*)|\# \1| ; \
    s|^(exclude-validators[[:space:]]+=[[:space:]]+).*$|\# \1\[\"$validators\"\]|" /root/missed-blocks-checker/config.haqq.toml
    ;;
  esac

sed -i -E "s|^(chat[[:space:]]+=[[:space:]]+)-123.*$|\1"$Your_User_ID"| ; \
s|^(chat[[:space:]]+=[[:space:]]+\"\#general\")|# \1| ; \
s|^(token[[:space:]]+=[[:space:]]+)\"111:222\".*$|\1\"$Telegram_Bot_Token\"| ; \
s|^(token[[:space:]]+=[[:space:]]+\"xorb-xxxyyyy\")|# \1| ; \
s|^(bech-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_prefix\"| ; \
s|^(bech-validator-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_validator_prefix\"| ; \
s|^(bech-validator-pubkey-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_validator_pubkey_prefix\"| ; \
s|^(bech-consensus-node-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_consensus_node_prefix\"| ; \
s|^(bech-consensus-node-pubkey-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$bech_consensus_node_pubkey_prefix\"| ; \
s|^(grpc-address[[:space:]]+=[[:space:]]+).*$|\1\"$grpc_address\"| ; \
s|^(rpc-address[[:space:]]+=[[:space:]]+).*$|\1\"$rpc_address\"| ; \
s|^(level[[:space:]]+=[[:space:]]+).*$|\1\"$level\"| ; \
s|^(mintscan-prefix[[:space:]]+=[[:space:]]+).*$|\1\"$mintscan_prefix\"| ; \
s|^(validator-page-pattern[[:space:]]+=[[:space:]]+).*$|\1\"$validator_page_pattern\"| ; \
s|^(config-path[[:space:]]+=[[:space:]]+).*$|\1\"$config_path\"|" /root/missed-blocks-checker/config.haqq.toml

# Add this service to the autorestart and run it
sudo systemctl enable missed-blocks-checker
sudo systemctl daemon-reload
sudo systemctl start missed-blocks-checker
# Restart service
sudo systemctl restart missed-blocks-checker
sudo systemctl status missed-blocks-checker

echo '################### Congratulations! Installation completed! ###################'
echo -e 'Сheck logs: journalctl -u missed-blocks-checker -f --output cat'
echo -e 'Resource: https://github.com/solarlabsteam/missed-blocks-checker/tree/master'
