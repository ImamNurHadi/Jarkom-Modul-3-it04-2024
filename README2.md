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
