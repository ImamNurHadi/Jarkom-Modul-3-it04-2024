#!/bin/bash
echo nameserver 192.168.3.2 > /etc/resolv.conf

apt-get update
apt-get install isc-dhcp-server -y

cat <<EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
EOF

cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.3.0 netmask 255.255.255.0 {

}
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.14 192.168.1.28;
  range 192.168.1.49 192.168.1.70;
  option routers 192.168.1.1;
  option broadcast-address 192.168.1.255;
  option domain-name-servers 192.168.3.2;
  default-lease-time 300;
  max-lease-time 5220;
}

subnet 192.168.2.0 netmask 255.255.255.0 {
  range 192.168.2.15 192.168.2.25;
  range 192.168.2.200 192.168.2.210;
  option routers 192.168.2.1;
  option broadcast-address 192.168.2.255;
  option domain-name-servers 192.168.3.2;
  default-lease-time 1200;
  max-lease-time 5220;
}
EOF

service isc-dhcp-server restart
service isc-dhcp-server status