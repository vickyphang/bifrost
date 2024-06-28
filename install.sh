#!/usr/bin/env bash

# Record start time
start=$(date +%s)

# VARIABLES
ROOT_DOMAIN=
DNS_IP=
DNS_NAME=

# DO NOT CHANGE THESE VARIBLES
REVERSE_NETWORK_ID=$(echo $DNS_IP | awk -F. '{print $3"." $2"."$1}')
HOST_ID=$(echo $DNS_IP | awk -F. '{print $4}')


# Update
echo -e "Run apt update.....\n"
sudo apt update

# Install bind9
echo -e "Installing private network DNS server bind9.....\n"
sudo apt -y install bind9

# Edit db.domain
echo -e "\nConfiguring BIND data file for local loopback interface....."
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
echo -e "\nConfiguring BIND reverse data file for local loopback interface....."
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
echo -e "\nConfiguring the local file....."
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
echo -e "\nConfiguring forwarding dns server....."
echo -e "All requests will be forwarded to 8.8.8.8....."
sed -i 's@// forwarders@forwarders@g' /etc/bind/named.conf.options
sed -i '/^\tforwarders/ s/$/ \n\t\t8.8.8.8;/' /etc/bind/named.conf.options
sed -i 's@// };@};@g' /etc/bind/named.conf.options

# Restart Bind9
echo -e "\nRestarting service bind9....."
systemctl restart bind9.service

# Record end time
end=$(date +%s)
echo "------------------------"
echo -e "\nElapsed Time: $(($end-$start)) seconds\n"
echo -e "------------------------\n"

# Final
echo -e "\nBind9 installation completed"
echo -e "\nTo add new DNS record, edit file /etc/bind/db.domain"