#!/bin/bash

echo nameserver 192.168.3.2 > /etc/resolv.conf

apt update
apt upgrade -y

apt install php7.3 -y
apt install apache2 -y

service apache2 start

wget -O harkonen.tar.gz "https://drive.google.com/uc?id=1lmnXJUbyx1JDt2OA5z_1dEowxozfkn30&export=download"
mkdir -p /var/www/harkonen
tar -xzf harkonen.tar.gz -C /var/www/harkonen --strip-components 1
rm harkonen.tar.gz

tee /etc/apache2/sites-available/harkonen.it04.com.conf > /dev/null <<EOT
<VirtualHost *:80>
    ServerName harkonen.it04.com
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/harkonen
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOT

a2ensite harkonen.it04.com
a2dissite 000-default

service apache2 restart