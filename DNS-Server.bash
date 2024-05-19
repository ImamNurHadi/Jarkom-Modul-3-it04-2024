#!/bin/bash

echo nameserver 192.168.216.2 > /etc/resolv.conf

apt-get update
apt-get install bind9 -y

cat <<EOF > /etc/bind/named.conf.local
zone "atreides.it04.com" {
  type master;
  file "/etc/bind/zone/atredies.it04.com";
};

zone "harkonen.it04.com" {
  type master;
  file "/etc/bind/zone/harkonen.it04.com";
};
EOF

mkdir /etc/bind/zone

cat <<EOF > /etc/bind/zone/atreides.it04.com
\$TTL    604800
@       IN      SOA     atreides,it04.com. root.atreides,it04.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      atreides,it04.com.
@       IN      A       192.168.2.2
EOF

cat <<EOF > /etc/bind/zone/harkonen.it04.com
\$TTL    604800
@       IN      SOA     harkonen,it04.com. root.harkonen,it04.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      harkonen,it04.com.
@       IN      A       192,168.1.2
EOF

cat <<EOF > /etc/bind/named.conf.options
options {
    forwarders {
        192.168.216.2;
    };
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

service bind9 start
service bind9 restart
service bind9 status
