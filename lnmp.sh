#!/bin/bash
# 先执行一次更新，防止预装的环境出问题
# sudo apt-get update
#-------------------------------预装环境----------------------------
#nginx的编译环境
# sudo apt-get install -y build-essential 
# sudo apt-get install -y libtool

#mysql的编译环境
# sudo apt-get install -y cmake 
# sudo apt-get install -y libncurses5-dev

#PHP的编译环境
# sudo apt-get install -y libxml2 libxml2-dev curl libcurl3 libcurl4-gnutls-dev libjpeg-dev libpng-dev libmcrypt-dev

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

cd ~
#wget http://www.bzip.org/1.0.5/bzip2-1.0.5.tar.gz
tar -zxvf bzip2-1.0.5.tar.gz
mv bzip2-1.0.5 /opt/bzip2
cd /opt/bzip2
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
mv mysql-5.6.17 /opt/mysql
cd /opt/mysql

cmake -DCMAKE_INSTALL_PREFIX=/opt/mysql -DMYSQL_UNIX_ADDR=/opt/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/opt/mysql/data -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=3306 
make
make install

#赋予权限，避免执行时出错
chmod -R 777 scripts/mysql_install_db 


scripts/mysql_install_db --basedir=/opt/mysql --datadir=/opt/mysql/data --user=mysql 
cp support-files/my-default.cnf /opt/mysql/my.cnf

#将MYSQL的配置信息写入配置文件
echo "
[mysqld]  
basedir = /opt/mysql  
datadir = /opt/mysql/data  
log-error = /opt/mysql/mysql_error.log  
pid-file = /opt/mysql/mysql.pid  
socket = /opt/mysql/mysql.sock
user = mysql  
tmpdir          = /tmp ">>/opt/mysql/my.cnf

#配置用户权限
sudo chown -R mysql:mysql /opt/mysql

cp /opt/mysql/support-files/mysql.server /etc/init.d/mysql

#赋予权限，避免执行出错
sudo chmod -R 777 /etc/init.d/mysql

#将Mysql写入环境变量
echo "export PATH=/opt/mysql/bin:$PATH" >>/etc/profile 
#重新加载环境变量
source /etc/profile 

sudo /etc/init.d/mysql start

mysqladmin -u root password "123456" #设置root密码

#-------------------------------安装PHP------------------------------
cd ~
#wget http://cn2.php.net/distributions/php-5.5.10.tar.gz
tar -xvzf php-5.5.10.tar.gz
mv php-5.5.10 /opt/php
cd /opt/php
./configure --prefix=/opt/php  --enable-fpm --with-mcrypt --enable-mbstring --disable-pdo --with-curl --disable-debug  --disable-rpath --enable-inline-optimization --with-bz2  --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-mysqli --with-gd --with-jpeg-dir
make
make install

groupadd www-data
useradd -g www-data www-data

cp etc/php-fpm.conf.default etc/php-fpm.conf
cp cp php.ini-development lib/php.ini

#修改PHP.ini配置
sed  -i 's/pdo_mysql\.default_socket.*=$/pdo_mysql\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini
sed  -i 's/mysqli\.default_socket.*=$/mysqli\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini
sed  -i 's/mysql\.default_socket.*=$/mysql\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini

#配置nginx支持PHP-FPM
sed -i '18,$d' /opt/nginx/nginx.conf
echo "
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    gzip  on;
	
    server {
		listen       80;
		server_name localhost;
		root /var/www;
		index index.html index.htm index.php;
		
		location / {
			
		}
		
		location ~ \.php$ {
			fastcgi_pass 127.0.0.1:9000;
			fastcgi_index index.php;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			include fastcgi_params;
		}
    }
}" >> /opt/nginx/nginx.conf

#启动PHP_FPM
sudo /opt/php/sbin/php-fpm
#启动NGINX
sudo /opt/nginx/ngin