#!/bin/bash

# make sure you have 4G RAM

yum install -q -y epel-release
yum install -q -y facter

host="ipa"
fqdn="$(hostname --fqdn)"
domain="$(hostname --domain)"
ip="$(facter --no-ruby networking.interfaces.enp1s0.ip)"

echo "${ip} ${fqdn}" >> /etc/hosts

version=$(facter --no-ruby os.release.major)

if [ "$version" == "7" ]; then
  yum install -y ipa-installer ipa-server-dns
fi

if [ "$version" == "8" ]; then
  yum module enable idm:DL1
  yum distro-sync
  yum module install idm:DL1/dns
  facter os.release.major
fi

ipa-server-install \
  --unattended \
  --setup-dns \
  --realm="${domain^^}" \
  --domain="${domain}" \
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

