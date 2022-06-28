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
Add variables `bond_denom` and `bench_prefix` for Axelar
```

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
ExecStart=cosmos-exporter --denom $BOND_DENOM --denom-coefficient 1000000 --bech-prefix $BENCH_PREFIX
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
```
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
#### Start `cosmos-exporter` and `node_exporter` services
```
sudo systemctl daemon-reload
sudo systemctl enable cosmos-exporter
sudo systemctl enable node_exporter
sudo systemctl start cosmos-exporter
sudo systemctl start node_exporter
```





