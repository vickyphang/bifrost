#!/usr/bin/env bash

# VARIABLES
ROOT_DOMAIN=
DNS_IP=
DNS_NAME=

# DO NOT CHANGE THESE VARIBLES
REVERSE_NETWORK_ID=$(echo $DNS_IP | awk -F. '{print $3"." $2"."$1}')
HOST_ID=$(echo $DNS_IP | awk -F. '{print $4}')


# Update
sudo apt update

# Install bind9
sudo apt -y install bind9

# Edit db.domain
cat <<EOF | sudo tee /etc/bind/db.domain
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     ${ROOT_DOMAIN}. root.${ROOT_DOMAIN}. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@               IN      NS      ${ROOT_DOMAIN}.
@               IN      A       ${DNS_IP}
${DNS_NAME}     IN      A       ${DNS_IP}
EOF

# Edit db.ip
cat <<EOF | sudo tee /etc/bind/db.ip
;
; BIND reverse data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     ${ROOT_DOMAIN}. root.${ROOT_DOMAIN}. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ${ROOT_DOMAIN}.
${HOST_ID}      IN      PTR     ${ROOT_DOMAIN}.
EOF

# Edit named.conf.local
cat <<EOF | sudo tee /etc/bind/named.conf.local
zone "${ROOT_DOMAIN}"{
        type master;
        file "/etc/bind/db.domain";
};

zone "${REVERSE_NETWORK_ID}.in-addr.arpa"{
        type master;
        file "/etc/bind/db.ip";
};
EOF

# Edit named.conf.options
sed -i 's@// forwarders@forwarders@g' /etc/bind/named.conf.options
sed -i '/^\tforwarders/ s/$/ \n\t\t8.8.8.8/' /etc/bind/named.conf.options
sed -i 's@// };@};@g' /etc/bind/named.conf.options

# Restart Bind9
systemctl restart bind9.service