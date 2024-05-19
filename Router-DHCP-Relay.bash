#!/bin/bash

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.168.0.0/16

apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start

cat <<EOF > /etc/default/isc-dhcp-relay
SERVERS="192.168.3.3"
INTERFACES="eth1 eth2 eth3"
OPTIONS=""
EOF

cat <<EOF > /etc/sysctl.conf
net.ipv4.ip_forward=1
EOF


