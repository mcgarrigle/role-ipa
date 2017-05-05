#!/bin/bash

yum install -y epel-release
yum install -y firewalld tinyproxy

echo "Setting up Firewall Rules..."

systemctl start firewalld
firewall-cmd --permanent --add-port=9090/tcp
firewall-cmd --reload
systemctl enable firewalld

sed -i 's/^Port .*/Port 9090/'     /etc/tinyproxy/tinyproxy.conf
sed -i 's/^Allow /# Allow /'       /etc/tinyproxy/tinyproxy.conf
echo 'no upstream ".foo.local"' >> /etc/tinyproxy/tinyproxy.conf

systemctl enable tinyproxy
systemctl start tinyproxy
