#!/bin/bash

echo nameserver 192.168.3.2 > /etc/resolv.conf

apt update
apt upgrade -y

apt install nginx -y

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
        server 192.168.1.2;  # IP Vladimir
        server 192.168.1.3;  # IP Rabban
        server 192.168.1.4;  # IP Feyd
    }

    server {
        listen 80;
        server_name harkonen.it04.com;

        location / {
            proxy_pass http://harkonen;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOT

systemctl restart nginx

echo "192.168.1.5 harkonen.it04.com" >> /etc/hosts

apt install apache2-utils -y

echo "Konfigurasi load balancer (Stilgar) selesai."