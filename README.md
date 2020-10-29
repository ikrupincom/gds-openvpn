# Сборка
```
docker build -t ikrupincom/gds-openvpn:latest .
```

# Настройка

1. Инициализируем PKI и генерируем ключи

```
docker run -it --rm \
  -v {{OVPN_EASYRSA_VOLUME}}:/root/easy-rsa/ \
  -v {{VARS_FILE_PATH}}:/input/vars \
  -v {{OUTPUT_DIR}}:/output \
  ikrupincom/gds-openvpn gen-keys
```

где:
- `{{VARS_FILE_PATH}}`: путь до файла `vars`;

2. Генерируем сертификат `server.crt` на CA-сервере используя `{{OUTPUT_DIR}}/server.req`

3. Инициализируем сервер конфигурациями, ключами и сертификатами

```
docker run -it --rm \
  -v {{OVPN_EASYRSA_VOLUME}}:/root/easy-rsa/ \
  -v {{OVPN_CONF_VOLUME}}:/etc/openvpn/ \
  -v {{OVPN_CLIENTS_VOLUME}}:/root/client-configs/ \
  -v {{BASE_CLIENT_CONF_FILE_PATH}}:/input/base-client.conf \
  -v {{CONF_FILE_PATH}}:/input/server.conf \
  -v {{SERVER_KEY_FILE_PATH}}:/input/server.key \
  -v {{SERVER_CRT_FILE_PATH}}:/input/server.crt \
  -v {{TA_KEY_FILE_PATH}}:/input/ta.key \
  -v {{CA_CRT_FILE_PATH}}:/input/ca.crt \
  ikrupincom/gds-openvpn init
```

где
- `{{OVPN_EASYRSA_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для EasyRSA;
- `{{OVPN_CONF_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для OpenVPN;
- `{{OVPN_CLIENTS_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для клиентов OpenVPN;
- `{{BASE_CLIENT_CONF_FILE_PATH}}`: путь до файла `base-client.conf`;
- `{{CONF_FILE_PATH}}`: путь до файла `server.conf`;
- `{{SERVER_KEY_FILE_PATH}}`: путь до файла `server.key`, полученный на шаге 2 (`{{OUTPUT_DIR}}/server.key`)
- `{{SERVER_CRT_FILE_PATH}}`: путь до файла `server.crt`, полученный на шаге 2 (`{{OUTPUT_DIR}}/server.req`)
- `{{TA_KEY_FILE_PATH}}`: путь до файла `ta.key`, полученный на шаге 2 (`{{OUTPUT_DIR}}/ta.key`).
- `{{CA_CRT_FILE_PATH}}`: путь до файла `ca.crt`, который можно получить с CA-сервера

# Создание пользователя

1. Генерируем ключи пользователя

```
docker run -it --rm \
  -v {{OVPN_EASYRSA_VOLUME}}:/root/easy-rsa/ \
  -v {{OVPN_CONF_VOLUME}}:/etc/openvpn/ \
  -v {{OVPN_CLIENTS_VOLUME}}:/root/client-configs/ \
  -v {{OUTPUT_DIR}}:/output \
  ikrupincom/gds-openvpn client {{CLIENT_NAME}}
```

где
- `{{OVPN_EASYRSA_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для EasyRSA;
- `{{OVPN_CONF_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для OpenVPN;
- `{{OVPN_CLIENTS_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для клиентов OpenVPN;

2. Генерируем сертификат `{{CLIENTNAME}}` на CA-сервере используя `{{OUTPUT_DIR}}/{{CLIENT_NAME}}.req`

3. Генерируем конфигурационный файл клиента

```
docker run -it --rm \
  -v {{OVPN_EASYRSA_VOLUME}}:/root/easy-rsa/ \
  -v {{OVPN_CONF_VOLUME}}:/etc/openvpn/ \
  -v {{OVPN_CLIENTS_VOLUME}}:/root/client-configs/ \
  -v {{OUTPUT_DIR}}/{{CLIENT_NAME}}.crt:/input/{{CLIENT_NAME}}.crt \
  -v {{OUTPUT_DIR}}:/output \
  ikrupincom/gds-openvpn client-config {{CLIENT_NAME}}
```

где
- `{{OVPN_EASYRSA_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для EasyRSA;
- `{{OVPN_CONF_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для OpenVPN;
- `{{OVPN_CLIENTS_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для клиентов OpenVPN;

4. Конфигурационный файл клиента будет находиться тут: `{{OUTPUT_DIR}}/{{CLIENT_NAME}}.ovpn`

# Запуск сервера

```
docker run -it --rm \
  --name office-ovpn \
  -p 1194:1194/udp \
  --cap-add=NET_ADMIN \
  -v {{OVPN_EASYRSA_VOLUME}}:/root/easy-rsa/ \
  -v {{OVPN_CONF_VOLUME}}:/etc/openvpn/ \
  -v {{OVPN_CLIENTS_VOLUME}}:/root/client-configs/ \
  ikrupincom/gds-openvpn start
```
  
где
- `{{OVPN_EASYRSA_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для EasyRSA;
- `{{OVPN_CONF_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для OpenVPN;
- `{{OVPN_CLIENTS_VOLUME}}`: любой volume, в котором создастся необходимая иерархия для клиентов OpenVPN;
