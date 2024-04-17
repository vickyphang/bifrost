# Bifrost 🎇
[![GitHub license](https://img.shields.io/github/license/vickyphang/bifrost)](https://github.com/vickyphang/bifrost/blob/master/LICENSE)
![GitHub stars](https://img.shields.io/github/stars/vickyphang/bifrost)

<p align="center"> <img src="images/logo.png"> </p>

The bifrost project is designed to setup a `BIND9 DNS server` on `Ubuntu 20.04`.

---

## Requirements
This script requires `root privileges` or `sudo`.

## Deployment: quick start
1. Clone this repository
```bash
git clone https://github.com/vickyphang/bifrost.git
```

2. Edit the variables in `install.sh`
```
#!/usr/bin/env bash

# VARIABLES
ROOT_DOMAIN=example.com
DNS_IP=10.0.0.53
DNS_NAME=local-dns

...
```

3. Adds execute permission to `install.sh`
```bash
chmod +x install.sh
```

4. Execute script
```bash
./install.sh
```

## Verify Operation
1. Edit `/etc/resolv.conf`
```
...

nameserver 10.0.0.53
```

2. Run nslookup
```
ubuntu@server1:/home/ubuntu$ nslookup example.com
Server:         10.0.0.53
Address:        10.0.0.53#53

Name:   example.com
Address: 10.0.0.53

ubuntu@server1:/home/ubuntu$ nslookup local-dns.example.com
Server:         10.0.0.53
Address:        10.0.0.53#53

Name:   local-dns.example.com
Address: 10.0.0.53
```
