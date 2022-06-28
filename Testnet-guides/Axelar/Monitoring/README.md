## Monitoring with a centralized type of log storage

In the instruction, we will consider the most common monitoring architecture. The principle of operation is that all servers on which **Sentry Node** and **Validators** are installed will send their logs **to a separate server**, which will collect logs and visualize them.

Naturally, this is **dangerous**, in terms of the fact that if attackers hack into your server that stores logs from all servers, then they will receive information with which they will try to harm you.

But for this type of monitoring, there are a lot of dashboards have been created. Therefore, we will consider it.

To keep your collector server safe, please, protect it with the [Minimum-server-protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md) instructions.

# Installation
## Installing exporters on validator and sentry nodes' servers
#### Cosmos-exporter
First of all install cosmos-exporter created by [solarlabsteam](https://github.com/solarlabsteam/cosmos-exporter/releases):
```
wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v0.2.2/cosmos-exporter_0.2.2_Linux_x86_64.tar.gz
tar xvfz cosmos-exporter*
sudo cp ./cosmos-exporter /usr/bin
rm cosmos-exporter* -rf
```
Add user for cosmos-exporter
```
sudo useradd -rs /bin/false cosmos_exporter
```
Add variables `denom` and `bench_prefix` for Axelar
```
denom=AXL uaxl
bench_prefix=axelar
echo 'export denom='\"${denom}\" >> $HOME/.bash_profile
echo 'export bench_prefix='\"${bench_prefix}\" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

Create `cosmos-exporter` service file
```
sudo tee <<EOF >/dev/null /etc/systemd/system/cosmos-exporter.service
[Unit]
Description=Cosmos Exporter
After=network-online.target
[Service]
User=cosmos_exporter
Group=cosmos_exporter
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=cosmos-exporter --denom $denom --denom-coefficient 1000000 --bech-prefix $bench_prefix
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM
[Install]
WantedBy=multi-user.target
EOF
```
Default `cosmos-exporter` port is `9300`.
#### Node-exporter
Now we will install cosmos-exporter
```
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/
rm node_exporter-* -rf
```
Add user for node-exporter
```
sudo useradd -rs /bin/false node_exporter
```
Create `node_exporter` service file
```
sudo tee <<EOF >/dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF
```
Default `cosmos-exporter` port is `9100`.
#### Start `cosmos-exporter` and `node_exporter` services
```
sudo systemctl daemon-reload
sudo systemctl enable cosmos-exporter
sudo systemctl enable node_exporter
sudo systemctl start cosmos-exporter
sudo systemctl start node_exporter
```
## Installing monitoring on the separate server
install packeges
```
sudo apt install jq -y
sudo apt install python3-pip -y
sudo pip install yq
```
#### Install Grafana
- Usefull links [here](https://grafana.com/docs/grafana/latest/setup-grafana/)
- More info about [installation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/) 
- [Releases](https://grafana.com/docs/grafana/latest/release-notes/)
Run the commands to install Grafana
```
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt-get update
sudo apt-get install grafana

sudo systemctl daemon-reload && \
sudo systemctl enable grafana-server && \
sudo systemctl restart grafana-server

sudo journalctl -u grafana-server -f
```
The port of Grafana is `3000`
#### Installing Prometheus
```
wget https://github.com/prometheus/prometheus/releases/download/v2.28.1/prometheus-2.28.1.linux-amd64.tar.gz && \
tar xvf prometheus-2.28.1.linux-amd64.tar.gz && \
rm prometheus-2.28.1.linux-amd64.tar.gz && \
mv prometheus-2.28.1.linux-amd64 prometheus

chmod +x $HOME/prometheus/prometheus
```
Now we could setting up promethes config.  
Download script for adding your nodes easely
```
cd $HOME/prometheus
wget -q -O add_node.sh https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Axelar/Monitoring/add_node.sh && chmod +x add_node.sh
```
Run command to add your nodes to promehteus:
```
VALIDATOR_IP=<YOUR_VALIDATOR_IP>
WALLET_ADDRESS=<YOUR_WALLET_ADDRESS>
VALOPER_ADDRESS=<YOUR_VALOPER_ADDRESS>
PROJECT_NAME=<YOUR_PROJECT_NAME>
$HOME/prometheus/add_node.sh $VALIDATOR_IP $WALLET_ADDRESS $VALOPER_ADDRESS $PROJECT_NAME
```
For adding more nodes just run command above with again.

Create prometheus service file
```
sudo tee /etc/systemd/system/prometheusd.service > /dev/null <<EOF
[Unit]
Description=prometheus
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/prometheus/prometheus \
--config.file="$HOME/prometheus/prometheus.yml"
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
start it
```
sudo systemctl daemon-reload && \
sudo systemctl enable prometheusd && \
sudo systemctl restart prometheusd

sudo journalctl -u prometheusd -f
```
Now go to `http://<server_IP>:3000/` and inport the dashboard that you choose.



