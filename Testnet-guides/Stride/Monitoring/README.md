## Monitoring with a centralized type of log storage

In the instruction, we will consider the most common monitoring architecture. The principle of operation is that all servers on which **Sentry Node** and **Validators** are installed will send their logs **to a separate server**, which will collect logs and visualize them.

Naturally, this is **dangerous**, in terms of the fact that if attackers hack into your server that stores logs from all servers, then they will receive information with which they will try to harm you.

But for this type of monitoring, there are a lot of dashboards have been created. Therefore, we will consider it.

To keep your collector server safe, please, protect it with the [Minimum-server-protection](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md) instructions.

# Installation
The whole monitoring installation process consists of several stages.
1) **Installation on servers with nodes.**  
Installation of exporters for each type of data that will be exported via a separate port to the collector server. We will install two:
- Cosmos-exporter
- Node-exporter
2) **Installation on the collector-renderer server.**
- Prometheus
- Grafana
# Installing exporters on validator and sentry nodes' servers
Make shure that you enabled connection with prometheus in `$HOME/.stride/config/config.toml`, if not:
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.stride/config/config.toml
sudo systemctl restart strided
```
Default `prometheus` port is `26660`.

Check in browser: `http://<node_IP>:26660/`
### Cosmos-exporter
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
Add variables `denom` and `bench_prefix` for Stride
```
denom=ustrd
bench_prefix=stride
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

Check in browser: `http://<node_IP>:9300/`
### Node-exporter
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

Check in browser: `http://<node_IP>:9100/`
#### Start `cosmos-exporter` and `node_exporter` services
```
sudo systemctl daemon-reload
sudo systemctl enable cosmos-exporter
sudo systemctl enable node_exporter
sudo systemctl start cosmos-exporter
sudo systemctl start node_exporter
```
## Installing monitoring on the separate server
First of all we should set up [server sequrity](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Mainnet-Guides/Minimum-server-protection.md). 

And make sure that the ports we need are open:
```
sudo apt ufw install -y
sudo ufw allow ssh
sudo ufw allow 22  #If you use different ssh port then indicate yours
sudo ufw allow 26660
sudo ufw allow 9090
sudo ufw allow 3000
sudo ufw allow 9300
sudo ufw allow 9100
sudo ufw enable

sudo ufw status
sudo ufw status verbose
ss -tulpn
```
Install packeges
```
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install jq nano mc curl gcc g++ git -y
sudo apt install python3-pip -y
sudo pip install yq
```
### Installing Prometheus
Check latest version of Prometheus [here](https://prometheus.io/download/). For now it is [2.38.0](https://github.com/prometheus/prometheus/releases/download/v2.38.0/prometheus-2.38.0.linux-amd64.tar.gz).

**Download Prometheus** and extract files from the archive.
```
wget https://github.com/prometheus/prometheus/releases/download/v2.38.0/prometheus-2.38.0.linux-amd64.tar.gz && \
tar xvf prometheus-2.38.0.linux-amd64.tar.gz && \
rm prometheus-2.38.0.linux-amd64.tar.gz
```
Now we should move the `prometheus` binary and a `promtool` to an executable path `/usr/local/bin/`
```
cd prometheus-2.38.0.linux-amd64 && \
mv prometheus promtool /usr/local/bin/
```
Create path for prometheus that we will use
```
sudo mkdir -p $HOME/prometheus
sudo mkdir -p $HOME/prometheus/data
```
Not necessary but we can move `prometheus-2.38.0.linux-amd64/consoles/` and `prometheus-2.38.0.linux-amd64/console_libraries/` libraries to the Prometheus config directory that we created `$HOME/prometheus`. It is only needed if you want to create arbitrary consoles using the Go templating language:
```
sudo mv prometheus-2.38.0.linux-amd64/consoles/ prometheus-2.38.0.linux-amd64/console_libraries/ $HOME/prometheus/
```
Download prepared prometheus' config file. (Also you can see downloaded prometheus config file here `$HOME/prometheus-2.38.0.linux-amd64.tar.gz/prometheus.yml`)
```
curl -sSL https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Stride/Monitoring/prometheus.yml > $HOME/prometheus/prometheus.yml
```
Delete downloaded folder
```
cd ~ && \
rm -rf $HOME/prometheus-2.38.0.linux-amd64
```
**Let's create a new user for Prometheus**. It is good for reducing the impact in case of an incident with the service. It will also help to track down what resources belong to Prometheus service.
```
sudo useradd --system --no-create-home --shell /bin/false prometheus
```
By this command we will create a group and a system account `prometheus` without a home directory and without the ability to logging in as a Prometheus user.

Set the correct ownership for the `$HOME/prometheus` if you created Prometheus user:
```
sudo chown -R prometheus:prometheus $HOME/prometheus
sudo chown -R prometheus:prometheus $HOME/prometheus/prometheus.yml
```
Check prometheus
```
prometheus --version
prometheus --help
```

**Now we could setting up promethes config.**

Download script for adding your nodes easely
```
cd $HOME/prometheus
wget -q -O add_node.sh https://raw.githubusercontent.com/AlexToTheSun/Validator_Activity/main/Testnet-guides/Stride/Monitoring/add_node.sh && chmod +x add_node.sh
```
Run command to add your nodes to promehteus:
```
VALIDATOR_IP=<YOUR_VALIDATOR_IP>
VALOPER_ADDRESS=<YOUR_VALOPER_ADDRESS>
WALLET_ADDRESS=<YOUR_WALLET_ADDRESS>
PROJECT_NAME=<YOUR_PROJECT_NAME>
$HOME/prometheus/add_node.sh $VALIDATOR_IP $VALOPER_ADDRESS $WALLET_ADDRESS $PROJECT_NAME
```
For adding more nodes just run command above again with another information.

**Create prometheus service file**
```
sudo tee /etc/systemd/system/prometheusd.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network-online.target

[Service]
User=$USER
Type=simple
Restart=always
RestartSec=3s
LimitNOFILE=65535
ExecStart=/usr/local/bin/prometheus \
  --config.file="$HOME/prometheus/prometheus.yml" \
  --storage.tsdb.path="$HOME/prometheus/data" \
  --web.console.templates="$HOME/prometheus/consoles" \
  --web.console.libraries="$HOME/prometheus/console_libraries" \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF
```

Start `prometheusd.service`
```
sudo systemctl daemon-reload && \
sudo systemctl enable prometheusd && \
sudo systemctl restart prometheusd
sudo journalctl -u prometheusd -f
```
The port of prometheus is `9090`

Now go to `http://<server_IP>:9090/` to check that prometheus is working.

### Install Grafana
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

Now go to `http://<server_IP>:3000/` and inport the dashboard that you choose.

