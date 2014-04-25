#!/bin/bash
#-------------------------------预装环境----------------------------
# sudo apt-get install -y build-essential #nginx
# sudo apt-get install -y libtool #nginx
# sudo apt-get install -y cmake #mysql
# sudo apt-get install -y libncurses5-dev #mysql

cd ~
# wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.34.tar.gz
tar -xzvf pcre-8.34.tar.gz
mv pcre-8.34 /opt/pcre
cd /opt/pcre
./configure
make
make install

cd ~
#wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxvf zlib-1.2.8.tar.gz
mv zlib-1.2.8 /opt/zlib
cd /opt/zlib
./configure
make
make install

cd ~
#wget http://www.openssl.org/source/openssl-1.0.1g.tar.gz
tar -zxvf openssl-1.0.1g.tar.gz
mv openssl-1.0.1g /opt/openssl

cd ~
#wget http://www.cmake.org/files/v2.8/cmake-2.8.4.tar.gz
tar zxvf cmake-2.8.4.tar.gz
mv cmake-2.8.4 /opt/cmake
cd /opt/cmake
./configure  --prefix=/opt/cmake
make
make install

#-------------------------------安装Nginx----------------------------

cd ~
#wget http://nginx.org/download/nginx-1.6.0.tar.gz
tar -xvzf nginx-1.6.0.tar.gz
mv nginx-1.6.0 /opt/nginx
cd /opt/nginx

./configure --sbin-path=/opt/nginx/nginx --conf-path=/opt/nginx/nginx.conf --pid-path=/opt/nginx/nginx.pid --with-http_ssl_module --with-pcre=/opt/pcre --with-zlib=/opt/zlib --with-openssl=/opt/openssl

make
make install

#-------------------------------安装Mysql----------------------------
cd ~
groupadd mysql
useradd -g mysql mysql -s /usr/sbin/nologin  
mkdir /opt/mysql/data

#wget http://download.softagency.net/MySQL/Downloads/MySQL-5.6/mysql-5.6.17.tar.gz
tar -xvzf mysql-5.6.17.tar.gz
mv mysql-5.6.16.tar.gz /opt/mysql
cd /opt/mysql

cmake -DCMAKE_INSTALL_PREFIX=/opt/mysql -DMYSQL_UNIX_ADDR=/opt/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/opt/mysql/data -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=3306 
make
make install
chmod -R 777 scripts/mysql_install_db #赋予权限，避免执行时出错
scripts/mysql_install_db --basedir=/opt/mysql --datadir=/opt/mysql/data --user=mysql 
cp support-files/my-default.cnf /opt/mysql/my.cnf

#[mysqld]  
#basedir = /opt/mysql  
#datadir = /opt/mysql/data  
#log-error = /opt/mysql/mysql_error.log  
#pid-file = /opt/mysql/mysql.pid  
#socket = /opt/mysql/mysql.sock
#user = mysql  
#tmpdir          = /tmp 
chown -R mysql:mysql /opt/mysql

cp /opt/mysql/support-files/mysql.server /etc/init.d/mysql
chrom -R 777 /etc/init.d/mysql #赋予权限，避免执行出错
echo "export PATH=/opt/mysql/bin:$PATH" >>/etc/profile #将Mysql写入环境变量
source /etc/profile #重新加载环境变量
/etc/init.d/mysql start

#mysqladmin -u root password "123456" #设置root密码

#-------------------------------安装PHP------------------------------
cd ~
#wget http://cn2.php.net/distributions/php-5.5.10.tar.gz
tar -xvzf php-5.5.10.tar.gz
mv php-5.5.10 /opt/php
cd /opt/php

