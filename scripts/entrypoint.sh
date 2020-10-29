EASYRSA_DIR=~/easy-rsa
OPENVPN_DIR=/etc/openvpn
CLIENTS_DIR=~/client-configs

if [[ $1 == "gen-keys" ]]; then
    I_DIR=/input
    O_DIR=/output
    cd ${EASYRSA_DIR}
    cp ${I_DIR}/vars ${EASYRSA_DIR}/
    ./easyrsa init-pki
    ./easyrsa gen-req server nopass
    cp pki/private/server.key ${O_DIR}/
    cp pki/reqs/server.req ${O_DIR}/
    cd ${O_DIR}
    openvpn --genkey --secret ta.key
fi

if [[ $1 == "init" ]]; then
    I_DIR=/input
    cp ${I_DIR}/base-client.conf ${CLIENTS_DIR}/
    cp ${I_DIR}/{server.conf,server.key,server.crt,ca.crt,ta.key} ${OPENVPN_DIR}/server/ 
fi

if [[ $1 == "client" ]]; then
    O_DIR=/output
    cd ${EASYRSA_DIR}
    ./easyrsa gen-req $2
    cp pki/private/$2.key ${CLIENTS_DIR}/keys/
    cp pki/reqs/$2.req ${O_DIR}/
fi

if [[ $1 == "start" ]]; then
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.disable_ipv6=0
    sysctl -w net.ipv6.conf.default.forwarding=1
    sysctl -w net.ipv6.conf.all.forwarding=1
    iptables -t nat -C POSTROUTING -s "192.168.255.0/24" -o eth0 -j MASQUERADE || {
        iptables -t nat -A POSTROUTING -s "192.168.255.0/24" -o eth0 -j MASQUERADE
    }
    iptables -t nat -C POSTROUTING -s "192.168.254.0/24" -o eth0 -j MASQUERADE || { 
        iptables -t nat -A POSTROUTING -s "192.168.254.0/24" -o eth0 -j MASQUERADE
    }
    openvpn ${OPENVPN_DIR}/server/server.conf
fi

if [[ $1 == "client-config" ]]; then
    I_DIR=/input
    O_DIR=/output
    SERVER_KEYS_DIR=${OPENVPN_DIR}/server
    CLIENT_KEYS_DIR=${CLIENTS_DIR}/keys
    OUTPUT_DIR=${CLIENTS_DIR}/files
    BASE_CONFIG=${CLIENTS_DIR}/base-client.conf
    cp ${I_DIR}/$2.crt ${CLIENT_KEYS_DIR}/
    cat ${BASE_CONFIG} \
	<(echo -e '<ca>') \
	${SERVER_KEYS_DIR}/ca.crt \
	<(echo -e '</ca>\n<cert>') \
	${CLIENT_KEYS_DIR}/${2}.crt \
	<(echo -e '</cert>\n<key>') \
	${CLIENT_KEYS_DIR}/${2}.key \
	<(echo -e '</key>\n<tls-crypt>') \
	${SERVER_KEYS_DIR}/ta.key \
	<(echo -e '</tls-crypt>') \
	> ${OUTPUT_DIR}/${2}.ovpn
    cp ${OUTPUT_DIR}/$2.ovpn ${O_DIR}/
fi	
