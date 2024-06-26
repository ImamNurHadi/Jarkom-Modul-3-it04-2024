## Soal Nomor 13
``Semua data yang diperlukan, diatur pada Chani dan harus dapat diakses oleh Leto, Duncan, dan Jessica. ``

Disini kita lakukan installasi mariadb dengan menjalankan bash berikut agar dapat terkoneksi dengan internet dan sekaligus mengonfigurasikan file mariadb:
```shell
#!/bin/bash
echo 'nameserver 192.168.3.2' > /etc/resolv.conf

apt-get update
apt-get install mariadb-server -y
service mysql start

echo '
# The MariaDB configuration file
#
# The MariaDB/MySQL tools read configuration files in the following order:
# 1. "/etc/mysql/mariadb.cnf" (this file) to set global defaults,
# 2. "/etc/mysql/conf.d/*.cnf" to set global options.
# 3. "/etc/mysql/mariadb.conf.d/*.cnf" to set MariaDB-only options.
# 4. "~/.my.cnf" to set user-specific options.
#
# If the same option is defined multiple times, the last one will apply.
#
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.

#
# This group is read both both by the client and the server
# use it for options that affect everything
#

[mysqld]
skip-networking=0
skip-bind-address


[client-server]

# Import all .cnf files from configuration directory
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/
' > /etc/mysql/my.cnf

echo '#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see
#
# See the examples of server my.cnf files in /usr/share/mysql

# this is read by the standalone daemon and embedded servers
[server]

# this is only for the mysqld standalone daemon
[mysqld]

#
# * Basic Settings
#
user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
socket                  = /run/mysqld/mysqld.sock
#port                   = 3306
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql
#skip-external-locking

# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
#bind-address            = 127.0.0.1
bind-address            = 0.0.0.0

#
# * Fine Tuning
#
#key_buffer_size        = 16M
#max_allowed_packet     = 16M
#thread_stack           = 192K
#thread_cache_size      = 8
# This replaces the startup script and checks MyISAM tables if needed
# the first time they are touched
#myisam_recover_options = BACKUP
#max_connections        = 100
#table_cache            = 64
#thread_concurrency     = 10

#
# * Query Cache Configuration
#
#query_cache_limit      = 1M
query_cache_size        = 16M

#
# * Logging and Replication
#
# Both location gets rotated by the cronjob.
# Be aware that this log type is a performance killer.
' > /etc/mysql/mariadb.conf.d/50-server.cnf
```
Disini kita menginstall pacakge dengan menjalankan :
```shell
apt-get update
apt-get install mariadb-server -y
service mysql start
```

Lalu menjalankan ```service mysql start``` agar service mysql berjalan
Setelah service mysql berjalan, kita mengonfigurasi mysql dengan cara
  1. Masuk ke dalam service sql secara root
     ```shell  mysql -u root -p```
  2. Memasukkan konfigurasi berikut :
     ```shell
      CREATE USER 'kelompokit04'@'%' IDENTIFIED BY 'passwordit04';
      CREATE USER 'kelompokit04'@'localhost' IDENTIFIED BY 'passwordit04';
      CREATE DATABASE dbkelompokit04;
      GRANT ALL PRIVILEGES ON *.* TO 'kelompokit04'@'%';
      GRANT ALL PRIVILEGES ON *.* TO 'kelompokit04'@'localhost';
      FLUSH PRIVILEGES;
     ```
Setelah selesai, kita hanya perlu restart service mysql dengan menjalankan ```service mysql restart```
#### WORKER LARAVEL LETO
Setelah konfigurasi selesai, kita uji pada worker laravel leto dengan menjalankan bash berikut pada Node leto :
```shell

#!/bin/bash
echo 'nameserver 192.168.3.2' > /etc/resolv.conf

apt-get update
apt-get install mariadb-client -y
```
Jika berhasil, kita jalankan ```mariadb --host=10.0.2.5 --port=3306 --user=kelompokyyy --password``` maka akan muncul hasil sebagai berikut:

PHOTO HASIL

## Soal Nomor 14
``Leto, Duncan, dan Jessica memiliki atreides Channel sesuai dengan quest guide berikut. Jangan lupa melakukan instalasi PHP8.0 dan Composer``

Pertama kita jalankan script worker-laravel.bash untuk install package yang dibutuhkan seperti berikut :
```shell


#!/bin/bash
echo 'nameserver 192.168.3.2' > /etc/resolv.conf

#Database cek
apt-get update
apt-get install mariadb-client -y

apt-get install lynx -y

apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

apt-get update
apt-get install php8.0-mbstring php8.0-xml php8.0-cli php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wget -y
php --version
service php8.0-fpm start

apt-get install nginx -y
service nginx start

wget https://getcomposer.org/download/2.0.13/composer.phar
chmod +x composer.phar
mv composer.phar /usr/bin/composer
composer -V

apt-get install git -y
```
Setelah selesai melakukan installasi package, kita pergi ke ``cd /var/www/laravel-praktikum-jarkom`` untuk melakukan cloning  github berikut ini:
```shell
git clone https://github.com/martuafernando/laravel-praktikum-jarkom.git
```

#### Konfigurasi Laravel
Jika sudah, kita lakukan konfigurasi laravel dengan melakukan ``composer install`` pada direktori ``/var/www/laravel-praktikum-jarkom``. Jika terdapat error seperti ini 
[FOTO ERROR]
Kita hanya perlu menjalankan ``composer update`` terlebih dahulu lalu kita lanjutkan dengan melakukan ``composer install`` maka hasilnya sebagai berikut :
[FOTO Compoer Install]
Jika sudah, kita perlu merubah isi file .env.example menjadi sebagai berikut :
```shell
APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:55kaidp3W7ccGR2vsTx/IHeeyFl5qnLoJ0M2JwcIgxk=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=192.168.4.3
DB_PORT=3306
DB_DATABASE=dbkelompokit04
DB_USERNAME=kelompokit04
DB_PASSWORD=passwordit04
```
Jika sudah, aplikasi dari laravel ini akan terhubung dengan database yang sudah dibuat pada soal nomor 13. Lalu kita tinggal jalankan 
```
php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder
php artisan key:generate
php artisan jwt:secret
php artisan storage:link
```

#### Konfigurasi Nginx
Setelah selesai konfigurasi Laravel, kita pergi ke ``cd /etc/nginx/sites-available/`` dan menambahkan file ``nano laravel-worker`` dengan konfigurasi sebagai berikut :
```shell
server {

    listen 8001; 

    root /var/www/laravel-praktikum-jarkom/public;

    index index.php index.html index.htm;
    server_name _;

    location / {
            try_files $uri $uri/ /index.php?$query_string;
    }

    # pass PHP scripts to FastCGI server
    location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
    }

location ~ /\.ht {
            deny all;
    }

    error_log /var/log/nginx/laravel-worker_error.log;
    access_log /var/log/nginx/laravel-worker_access.log;
}
```

setelah itu kita jalankan command
``
ln -s /etc/nginx/sites-available/laravel-worker /etc/nginx/sites-enabled/
chown -R www-data.www-data /var/www/laravel-praktikum-jarkom/
``
untuk symlink dan izin akses.
Terakhir, kita perlu menjalankan ulang nginx (jika belum dijalankan, lakukan start) dan php fpm dengan command berikut :
``
service nginx restart
service php8.0-fpm start
``
maka, hasilnya dapat diakses dengan lynx localhost:8001
[Foto 14 Berhasil]

## Soal Nomor 15-16-17
``atreides Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.``
Pada Case soal nomor 15-16-17 ini, kami menggunakan leto sebagai worker laravel dan paul sebagai client untuk menyelesaikan casenya. 

#### Konfigurasi pada Client Paul dan melakukan testing
Dimana sebelum melakukan testing, pada Client Paul, dijalankan script berikut untuk menghubungkan ke DNS server dan installasi package :
```shell
#!/bin/bash
echo 'nameserver 192.168.3.2' > /etc/resolv.conf

apt-get update

apt-get install lynx -y
apt-get install htop -y
apt-get install apache2-utils -y
apt-get install jq -y
```

setelah itu, kita buat file.json sebagai bantuan untuk mengirimkan username dan passwordnya. Untuk creds.json yang dibuat sebagai berikut :
```shell

{
  "username": "kelompokit04",
  "password": "passwordit04"
}
```
lalu kita dapat mencoba melakukan testing ke 3 soal yang diberikan
#### Testing Soal 15
Karena kita memakai worker-laravel Leto, maka kita membutuhkan ip dari worker tersebut yaitu 192.168.2.2 sebagai targetnya. Lalu kita dapat menjalankan command
```ab -n 100 -c 10 -p creds.json -T application/json http://192.168.2.2:8001/api/auth/register```, jika berhasil, maka dapat dilihat hasilnya seperti berikut :
[Foto 15_berhasil]

#### Testing Soal 16
Untuk nomer 16, hampir sama dengan command nomer 15. Namun endpoint yang digunakan Login, dengan command ```ab -n 100 -c 10 -p creds.json -T application/json http://192.168.2.2:8001/api/auth/login``` maka dapat dilihat hasilnya sebagai berikut :
[Foto 16_berhasil]

#### Testing SOal 17
Untuk nomer 17, akan sedikit berbeda karena akan ada token yang perlu didapakatkan. Pertama, kita dapatkan token dengan menjalankan command berikut ```curl -X POST -H "Content-Type: application/json" -d @credentials.json http://192.243.4.1:8001/api/auth/login > hasil.txt```. 

Jika sudah, hasilnya kurang lebih akan seperti ini 
```shell
 cat hasil.txt
{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTkyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxmYiOjE3MTYxMTQ4NTYsImp0aSI6xxxxxxxxxxxxxxxxxODcyZGI3YTU5NzZmNyJ9.q7wyzmp4i3YEJJJ27hyaImHWsuoMPJ-SE77cSDfapRE"}
```
kita perlu memasukkan token ke variabel global jq dengan command berikut :
```token=$(cat hasil.txt | jq -r '.token')```
Jika sudah, kita hanya perlu menjalankan 
```shell
ab -n 100 -c 10 -H "Authorization: Bearer $token" http://192.168.2.2:8001/api/me
```
karena kita sudah memasukkan token ke variabel global, seharusnya tidak ada error dikarenakan "Authorization: Bearer $token".
Dan dapat dilihat hasilnya sebagai berikut :
[Foto 17_berhasil]

## Soal Nomor 18
```Untuk memastikan ketiganya bekerja sama secara adil untuk mengatur atreides Channel maka implementasikan Proxy Bind pada Stilgar untuk mengaitkan IP dari Leto, Duncan, dan Jessica. (```
Pertama kita menambahkan konfigurasi bind9 pada irulan agar dapat diakses atreides.it04.com dengan konfigurasi berikut :
```shell
$TTL    604800
@       IN      SOA     atreides.it04.com. root.atreides.it04.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      atreides.it04.com.
@       IN      A       192.168.4.2
```

Setelah melakukan konfigurasi tersebut, kita menambahkan konfigurasi nginx agar dapat mengakses 3 worker-laravel kita
```shell
upstream worker {
  
    server 192.168.2.2:8001;
    server 192.168.2.3:8002;
    server 192.168.2.4:8003;
}

server {
    listen 80;
    server_name atreides.it04.com www.atreides.it04.com;

    location / {
        proxy_pass http://worker;
    }
}
```
Setelah itu, kita jalankan command untuk memberikan akses dan merestrart nginx
```
ln -s /etc/nginx/sites-available/laravel-worker /etc/nginx/sites-enabled/laravel-worker

service nginx restart
```
lalu kita uji coba pada client paul
ab -n 100 -c 10 -p creds.json -T application/json http://atreides.it04.com/api/auth/login

## Soal Nomor 19
```Untuk meningkatkan performa dari Worker, coba implementasikan PHP-FPM pada Leto, Duncan, dan Jessica. Untuk testing kinerja naikkan 
- pm.max_children
- pm.start_servers
- pm.min_spare_servers
- pm.max_spare_servers
sebanyak tiga percobaan dan lakukan testing sebanyak 100 request dengan 10 request/second kemudian berikan hasil analisisnya pada PDF.
```

kita akan mengatur konfugurasi parameter-parameter PHP-FPM yang berada di worker-laravel pada file /etc/php/8.0/fpm/pool.d/www.conf dengan 3 script berbeda untuk setiap tingkatan. Setelah mengatur konfigurasi file tersebut jangan lupa menjalankan ```service php8.0-fpm restart```.
#### Tingkat 1
```
[www]
user = www-data
group = www-data
listen = /run/php/php8.0-fpm.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

pm = dynamic
pm.max_children = 3
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```
#### Tingkat 2
```
[www]
user = www-data
group = www-data
listen = /run/php/php8.0-fpm.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

pm = dynamic
pm.max_children = 15
pm.start_servers = 3
pm.min_spare_servers = 3
pm.max_spare_servers = 5
```

#### Tingkat 3
```
[www]
user = www-data
group = www-data
listen = /run/php/php8.0-fpm.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

pm = dynamic
pm.max_children = 25
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
```

## Soal Nomor 20
```Nampaknya hanya menggunakan PHP-FPM tidak cukup untuk meningkatkan performa dari worker maka implementasikan Least-Conn pada Stilgar. Untuk testing kinerja dari worker tersebut dilakukan sebanyak 100 request dengan 10 request/second. ```

Disini kita akan mengatur kembali konfigurasi load balancer pada file /etc/nginx/sites-available/laravel-worker dengan menambahkan perintah berikut :
```
upstream worker {
    least_conn;
    server 192.168.2.2:8001;
    server 192.168.2.3:8002;
    server 192.168.2.4:8003;
}

server {
    listen 80;
    server_name atreides.it04.com www.atreides.it04.com;

    location / {
        proxy_pass http://worker;
    }
}
```
Setelah selesai, kita lakukan service nginx restart dan kembali melakukan test dengan command 
```
ab -n 100 -c 10 -p creds.json -T application/json http://atreides.it04.com/api/auth/login
```
Maka hasilnya seperti berikut :
