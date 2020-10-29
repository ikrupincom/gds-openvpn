EASY_RSA_DIR=~/easy-rsa
OPENVPN_DIR=/etc/openvpn
CLIENTS_DIR=~/client-configs

apt-get update
apt-get install -y iptables openvpn easy-rsa
mkdir ${EASY_RSA_DIR}
mkdir -p ${CLIENTS_DIR}/keys
mkdir -p ${CLIENTS_DIR}/files
chmod -R 700 ${CLIENTS_DIR}
ln -s /usr/share/easy-rsa/* ${EASY_RSA_DIR}/
