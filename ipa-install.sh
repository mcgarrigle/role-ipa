#!/bin/bash

# make sure you have 3G RAM
# and /etc/hosts has hostname

function uppercase {
  echo $1 | awk '{ print toupper($0) }'
}

yum install -y epel-release
yum install -y facter

DOMAIN=$(facter domain)
REALM=$(uppercase ${DOMAIN})

ETHS=$(facter interfaces)
ETH0=$(echo $ETHS | cut -d, -f 1)
ETH1=$(echo $ETHS | cut -d, -f 2)
ADDRESS0=$(facter ipaddress_${ETH0})
ADDRESS1=$(facter ipaddress_${ETH1})

echo $HOSTNAME $DOMAIN $REALM
echo $ETH0 $ADDRESS0
echo $ETH1 $ADDRESS1

yum install -y ipa-installer ipa-server-dns

ipa-server-install \
  --unattended \
  --setup-dns \
  --realm="${REALM}" \
  --domain="${DOMAIN}" \
  --ds-password="changeme" \
  --admin-password="changeme" \
  --mkhomedir \
  --hostname="${HOSTNAME}" \
  --ip-address="${ADDRESS1}" \
  --no-host-dns \
  --auto-forwarders \
  --auto-reverse

systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=389/tcp
firewall-cmd --permanent --add-port=636/tcp
firewall-cmd --permanent --add-port=88/tcp
firewall-cmd --permanent --add-port=464/tcp
firewall-cmd --permanent --add-port=53/tcp
firewall-cmd --permanent --add-port=88/udp
firewall-cmd --permanent --add-port=464/udp
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --permanent --add-port=123/udp
firewall-cmd --reload
systemctl enable firewalld

