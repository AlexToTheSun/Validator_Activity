[As you know](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md#setup-gravity-bridge), if you are validating on the Gravity Bridge blockchain, as a Validator you also **need to run the Gravity bridge components** or you will be slashed and removed from the validator set after about 16 hours.

This component ([Orchestrator](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md#setup-gravity-bridge-and-orchestrator-services)) doesn't work without connecting to Ethereum node. Если мы устанавливаем Gravity Bridge по официальной инструкции, we are running [Geth locally](https://github.com/Gravity-Bridge/Gravity-Docs/blob/main/docs/setting-up-a-validator.md#download-and-install-geth). Это значит, что orchestrator будет подключаться к локальной ETH ноде. 

### Как проверить что Orchestrator подключен к локальному GETH?
При установке, мы скачиваем сервисный файл [orchestrator](https://raw.githubusercontent.com/Gravity-Bridge/Gravity-Docs/main/configs/orchestrator.service), который выглядит так:
```
[Unit]
Description=Gravity bridge orchestrator
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
ExecStart=/usr/bin/gbt orchestrator --fees "0ugraviton"
Environment="HOME=/root"

[Install]
WantedBy=default.target
```
В строке `ExecStart=/usr/bin/gbt orchestrator --fees "0ugraviton"` нет флага `--ethereum-rpc <ETHEREUM_RPC>`. Этот флаг говорит Orchestrator адрес ethereum-rpc ноды, к которой он будет подключаться.  
Если этого флага нет, то у Orchestrator не остается вариантов - он подключится исключительно к локальному GETH.

### По дэфолту GETH работает в `light` режиме
Давайте посмотрим что прописано в сервисном файле GETH
```
# Geth Ethereum fullnode
[Unit]
Description=Geth Ethereum fullnode
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
ExecStart=/usr/sbin/geth \
--syncmode "light" \
--http \
--config /etc/geth-light-config.toml

# if you want to run a geth fullnode
#ExecStart=/usr/bin/geth \
#--http \
#--config /etc/geth-full-config.toml

[Install]
WantedBy=default.target
```
В этом конфиге видно, что в строке `ExecStart=` прописаны флаги:
- `--syncmode "light"` отвечающий за выбор режима синхронизации `light`
- `--config /etc/geth-light-config.toml` который указывает путь к config файлу.  

### Проверим что локальный GETH работает хорошо?
View the status of your Ethereum node. If result is 'false' that means it is now synced!
```
curl -H "Content-Type:application/json" -X POST -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://127.0.0.1:8545
```
Logs:
```
journalctl -u geth.service -f --output cat
```
Если у вас light нода потеряла пиры:
```
INFO [07-18|07:39:22.005] Looking for peers                        peercount=1  tried=3 static=5
INFO [07-18|07:39:32.090] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:39:42.128] Looking for peers                        peercount=1  tried=0 static=5
INFO [07-18|07:39:52.130] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:40:02.191] Looking for peers                        peercount=1  tried=1 static=5
INFO [07-18|07:40:12.236] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:40:22.657] Looking for peers                        peercount=1  tried=0 static=5
INFO [07-18|07:40:32.790] Looking for peers                        peercount=1  tried=3 static=5
INFO [07-18|07:40:42.814] Looking for peers                        peercount=1  tried=2 static=5
INFO [07-18|07:40:52.845] Looking for peers                        peercount=1  tried=1 static=5
INFO [07-18|07:41:02.857] Looking for peers                        peercount=1  tried=2 static=5
```
В таком случае необходимы действия.
## Решение проблемы протери пиров light нодой
У нас есть 3 варианта
#### 1) Добавить пиры в light ноду с помощью диалогового окна.

Here is the [[list with active peers](https://gist.github.com/rfikki/e2a8c47f4460668557b1e3ec8bae9c11?permalink_comment_id=4191111#file-lightclient-peers-mainnet-latest-txt-L4)] for GETH from [discord](https://discord.com/channels/881943007115497553/881948977707221053/997219903297822770).
Type:
```
geth attach
```
Then copy and past content from the [peer-list](https://gist.github.com/rfikki/e2a8c47f4460668557b1e3ec8bae9c11?permalink_comment_id=4191111#file-lightclient-peers-mainnet-latest-txt-L4). Command example: 
```
admin.addPeer("enode://da0c61fe14ba9da1a9835b59d811553d21787448724cfe6412bc17f0b14586df91826d8286b2137342d09a8631df5ea548cf301294b05657c2a90f9c3d526721@143.198.119.44:30303");
```
#### 2) Запуск GETH в `full` режиме
Этот режим занимает много места на диске, но работает стабильнее, чем `light` режим. Перед тем как перейти на этот режим работы, проверьте, что у вас достаточно свободного места на NVMe, а так же настройте алертинг, на случай, если дисковое пространство неожиданно быстро станет заканчиваться.

Строки отвечающие за режим работы `full` изначатьно закоментированы. Чтобы включить `full` режим, надо закомментировать `light` строки, и удалить символ # с `full` строк. Так будет выглядеть сервис файл после корректировки:
```
# Geth Ethereum fullnode
[Unit]
Description=Geth Ethereum fullnode
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
#ExecStart=/usr/sbin/geth \
#--syncmode "light" \
#--http \
#--config /etc/geth-light-config.toml

# if you want to run a geth fullnode
ExecStart=/usr/bin/geth \
--http \
--config /etc/geth-full-config.toml

[Install]
WantedBy=default.target
```
Есть вероятность, что в конфиг файле `geth-full-config.toml` прийдется заменить `fast` на `full`. Либо вставить дополнительный флаг `--syncmode "fast" \`. Тогда получится так:
```
ExecStart=/usr/bin/geth \
--syncmode "fast" \
--http \
--config /etc/geth-full-config.toml
```
Restart and logs
```
sudo systemctl daemon-reload
sudo service geth restart
journalctl -u geth.service -f --output cat
```
You can view the status of your Ethereum node by issuing the following command:
```
curl -H "Content-Type:application/json" -X POST -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://127.0.0.1:8545
```
When result is 'false' that means it is now synced ('true' is not synced).

#### 3) Use [infura](https://infura.io/) endpoint
After you have created project copy your mainnet endpoind (example `https://mainnet.infura.io/v3/sd7f7d7gf7g7d7h77df7s7df7sd7f7h7`) and type it in the orchestrator service file :
Open service file in nano 
```
nano /etc/systemd/system/geth.service
```
should look like this:
```
[Unit]
Description=Gravity bridge orchestrator
Requires=network.target

[Service]
Type=simple
TimeoutStartSec=10s
Restart=always
RestartSec=10
ExecStart=/usr/bin/gbt orchestrator --fees "0ugraviton" --ethereum-rpc https://mainnet.infura.io/v3/sd7f7d7gf7g7d7h77df7s7df7sd7f7h7
Environment="HOME=/root"

[Install]
WantedBy=default.target
```
Restart
```
sudo systemctl daemon-reload
sudo service orchestrator restart
```
Logs
```
journalctl -u orchestrator.service -f --output cat
```
