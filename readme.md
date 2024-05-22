## Konfigurasi Jaringan

- Konfigurasi jaringan telah dilakukan sesuai topologi menggunakan GNS3 dan Docker container dengan image `danielcristh0/debian-buster:1.1`.
- Konfigurasi IP address pada setiap node disesuaikan dengan ketentuan (statik/dinamik).

## Konfigurasi DHCP Server (Mohiam)

Script konfigurasi DHCP server pada node Mohiam:

```bash
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

```

Keterangan:

- Client mendapat range IP `192.168.1.14-28` dan `192.168.1.49-70` melalui House Harkonnen
- Client mendapat range IP `192.168.2.15-25` dan `192.168.2.200-210` melalui House Atreides
- Durasi lease time 5 menit untuk client Harkonnen dan 20 menit untuk client Atreides
- Maksimal lease time 87 menit

## Konfigurasi DNS Server (Irulan)

Script konfigurasi DNS server pada node Irulan:

```bash
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
\\$TTL    604800
@       IN      SOA     atreides.it04.com. root.atreides.it04.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      atreides.it04.com.
@       IN      A       192.168.4.2
EOF

cat <<EOF > /etc/bind/zone/harkonen.it04.com
\\$TTL    604800
@       IN      SOA     harkonen.it04.com. root.harkonen.it04.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      harkonen.it04.com.
@       IN      A       192.168.4.2
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

```

Keterangan:

- Client mendapatkan DNS dari Irulan dan dapat terhubung internet

## Konfigurasi DHCP Relay (Arakis)

Script konfigurasi DHCP relay pada router Arakis:

```bash
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

```

Keterangan:

- Router Arakis dikonfigurasi sebagai DHCP relay agar dapat mem-forward request IP dari client ke DHCP server

## Konfigurasi Worker PHP (Vladimir, Rabban, Feyd)

Script konfigurasi worker PHP Harkonnen:

```bash
#!/bin/bash

echo nameserver 192.168.3.2 > /etc/resolv.conf

apt update
apt upgrade -y

apt install unzip -y
apt install php7.3 -y
apt install apache2 -y
apt install lynx -y
service apache2 start

curl -L -o harkonen.zip "<https://drive.google.com/uc?id=1lmnXJUbyx1JDt2OA5z_1dEowxozfkn30&export=download>"
mkdir -p /var/www/harkonen
unzip harkonen.zip
mv modul-3/* /var/www/harkonen
rm harkonen.zip

tee /etc/apache2/sites-available/harkonen.it04.com.conf > /dev/null <<EOT
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/harkonen
    ErrorLog \\${APACHE_LOG_DIR}/error.log
    CustomLog \\${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOT

a2ensite harkonen.it04.com
a2dissite 000-default

service apache2 restart
lynx localhost

```

Keterangan:

- Virtual host untuk website PHP dikonfigurasi pada worker Harkonnen (Vladimir, Rabban, Feyd) menggunakan PHP 7.3

## Konfigurasi Load Balancer (Stilgar)

```bash
#!/bin/bash

echo nameserver 192.168.3.2 > /etc/resolv.conf

apt update
apt upgrade -y

apt install nginx -y
mkdir /etc/nginx/supersecret
htpasswd -c /etc/nginx/supersecret/htpasswd secmart

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/lb_php
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

tee /etc/nginx/nginx.conf > /dev/null <<EOT
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    upstream harkonen {
        #least_conn;
        #ip_hash;
        #generic_hash \$request_uri consistent;
        server 192.168.1.2;  # IP Vladimir
        server 192.168.1.3;  # IP Rabban
        server 192.168.1.4;  # IP Feyd
    }

    server {
        listen 80;
        server_name harkonen.it04.com;

        location / {
            allow 192.168.1.37;
            allow 192.168.1.67;
            allow 192.168.2.203;
            deny all;
            proxy_pass http://harkonen;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            auth_basic "Restricted Content";
            auth_basic_user_file /etc/nginx/supersecret/htpasswd;
        }
        location ~ /dune {
                proxy_pass https://www.dunemovie.com.au;
                proxy_set_header Host www.dunemovie.com.au;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOT
service nginx restart
```

- Konfigurasi load balancing pada Stilgar dioptimasi agar dapat bekerja maksimal
- Testing dilakukan dengan 5000 request dan 150 request/second

### Analisis Algoritma Load Balancing

*detail analisis algoritma load balancing dengan 500 request, 50 req/s*

### Testing Algoritma Least Connection

*detail analisis least connection dengan variasi jumlah worker*

### Konfigurasi Autentikasi Load Balancer

- Ditambahkan autentikasi pada load balancer dengan username `secmart` dan password `kckit04`
- File htpasswd disimpan di `/etc/nginx/supersecret/`

### Reverse Proxy /dune ke [dunemovie.com.au](http://dunemovie.com.au/)

- Request yang mengandung `/dune` di-proxy pass ke `https://www.dunemovie.com.au/`

### ACL pada Load Balancer

- Load balancer hanya dapat diakses oleh client dengan IP `192.168.1.37`, `192.168.1.67`, `192.168.2.203`, `192.168.2.207`
