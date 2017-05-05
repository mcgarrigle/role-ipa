#!/bin/bash

# make sure you have 2G RAM
# and /etc/hosts has hostname

host="ipa"
fqdn="${host}.foo.local"
ip="10.0.30.10"

echo "10.0.30.10 ipa.foo.local ipa" >> /etc/hosts

yum install -y ipa-installer ipa-server-dns

ipa-server-install \
  --unattended \
  --setup-dns \
  --realm=FOO.LOCAL \
  --domain=foo.local \
  --ds-password=changeme \
  --admin-password=changeme \
  --mkhomedir \
  --hostname="${fqdn}" \
  --ip-address="${ip}" \
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

