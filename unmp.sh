#!/bin/bash

#ubuntu系统环境基础设置
# 先执行一次更新，防止预装的环境出问题
sudo apt-get update

sudo apt-get install -y build-essential wget cmake libxml2-dev libxml2 curl libcurl3 libcurl4-gnutls-dev libjpeg-dev libpng-dev autoconf libfreetype6-dev libcurl4-openssl-dev libncurses5-dev bison libtool

sudo apt-get install -y build-essential wget cmake libxml2-dev libxml2 curl libcurl3 libcurl4-gnutls-dev libjpeg-dev libpng-dev autoconf libfreetype6-dev libcurl4-openssl-dev libncurses5-dev bison libtool


#下载要安装的文件
download(){
    cd ~
    wget --no-check-certificate https://www.pescms.com/lnmp/$1
    #确保文件能够被正确下载
    if [ ! -f $1 ]
    then
      download $1
    fi
}

download "pcre-8.36.tar.gz"
download "zlib-1.2.8.tar.gz"
download "openssl-1.0.2d.tar.gz"
download "bzip2-1.0.5.tar.gz"
download "nginx-1.8.0.tar.gz"
download "mysql-5.6.25.tar.gz"
download "php-5.6.12.tar.gz"

#-------------------------------编译系统必要的文件----------------------------
cd ~
tar -xzvf pcre-8.36.tar.gz
mv pcre-8.36 /opt/pcre
cd /opt/pcre
./configure
make
make install

cd ~
tar -zxvf zlib-1.2.8.tar.gz
mv zlib-1.2.8 /opt/zlib
cd /opt/zlib
./configure
make
make install

cd ~
tar -zxvf openssl-1.0.2d.tar.gz
mv openssl-1.0.2d /opt/openssl

cd ~
tar -zxvf bzip2-1.0.5.tar.gz
mv bzip2-1.0.5 /opt/bzip2
cd /opt/bzip2
make
make install



#-------------------------------安装Nginx----------------------------
cd ~
tar -xvzf nginx-1.8.0.tar.gz
mv nginx-1.8.0 /opt/nginx
cd /opt/nginx

./configure --sbin-path=/opt/nginx/nginx --conf-path=/opt/nginx/nginx.conf --pid-path=/opt/nginx/nginx.pid --with-http_ssl_module --with-pcre=/opt/pcre --with-zlib=/opt/zlib --with-openssl=/opt/openssl

make
make install

mkdir /opt/nginx/vhost
mkdir /opt/nginx/log

	#配置nginx支持PHP-FPM
	sed -i '18,$d' /opt/nginx/nginx.conf
echo "
	include       mime.types;
	default_type  application/octet-stream;

	sendfile        on;
	keepalive_timeout  65;

	gzip  on;
    
    include vhost/*.conf;
}" >> /opt/nginx/nginx.conf

echo "
server {
    listen       80;
    server_name localhost;
    root /var/www;
    index index.html index.htm index.php;
    access_log  /opt/nginx/log/localhost.access.log;
    error_log  /opt/nginx/log/localhost.error.log;

    location / {

    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}">> /opt/nginx/vhost/localhost.conf


#-------------------------------安装Mysql----------------------------
cd ~
groupadd mysql
useradd -g mysql mysql -s /usr/sbin/nologin  

tar -xvzf mysql-5.6.25.tar.gz
mv mysql-5.6.25 /opt/mysql

mkdir /opt/mysql/data
mkdir /opt/mysql/log
cd /opt/mysql

cmake -DCMAKE_INSTALL_PREFIX=/opt/mysql -DCURSES_LIBRARY=/usr/lib/libncurses.so -DCURSES_INCLUDE_PATH=/usr/include -DMYSQL_UNIX_ADDR=/opt/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/opt/mysql/data -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=3306 
make
make install

#赋予权限，避免执行时出错
chmod -R 777 scripts/mysql_install_db 


scripts/mysql_install_db --basedir=/opt/mysql --datadir=/opt/mysql/data --user=mysql 
#cp support-files/my-default.cnf /opt/mysql/my.cnf

#将MYSQL的配置信息写入配置文件
touch /opt/mysql/my.cnf
echo "[mysqld]
sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION 
basedir = /opt/mysql  
datadir = /opt/mysql/data  
log-error = /opt/mysql/log/mysql_error.log
long_query_time=1
slow_query_log=1
slow_query_log_file=/opt/mysql/log/slow-query.log
pid-file = /opt/mysql/mysql.pid  
socket = /opt/mysql/mysql.sock
user = mysql  
tmpdir          = /tmp ">>/opt/mysql/my.cnf

#配置用户权限
sudo chown -R mysql:mysql /opt/mysql

cp /opt/mysql/support-files/mysql.server /etc/init.d/mysql

#赋予权限，避免执行出错
sudo chmod -R 777 /etc/init.d/mysql

#清空一次存在的系统变量
sed  -i 's/export PATH=.*$//g' /etc/profile
#将Mysql写入环境变量
echo "export PATH=/opt/mysql/bin:$PATH" >>/etc/profile 

#重新加载环境变量
. /etc/profile 

/etc/init.d/mysql start

mysqladmin -u root password "123456" #设置root密码


#-------------------------------安装PHP------------------------------
cd ~
tar -xvzf php-5.6.12.tar.gz
mv php-5.6.12 /opt/php
cd /opt/php
./configure --prefix=/opt/php  --enable-fpm --enable-mbstring --disable-pdo --with-curl --disable-debug  --disable-rpath --enable-inline-optimization --with-bz2  --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-pdo --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-mysqli --with-pdo_mysql --with-gd --with-jpeg-dir --with-freetype-dir
make
make install

#移动对应的配置文件
cp etc/php-fpm.conf.default etc/php-fpm.conf
cp php.ini-development lib/php.ini

#创建PHP-FPM的用户和组，并修改对应的配置
groupadd www-data
useradd -g www-data www-data
sed  -i 's/user = nobody$/user = www-data/g' /opt/php/etc/php-fpm.conf
sed  -i 's/group = nobody$/group = www-data/g' /opt/php/etc/php-fpm.conf

#修改PHP.ini配置
sed  -i 's/pdo_mysql\.default_socket.*=$/pdo_mysql\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini
sed  -i 's/mysqli\.default_socket.*=$/mysqli\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini
sed  -i 's/mysql\.default_socket.*=$/mysql\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini

#创建访问目录
mkdir /var/www

#启动PHP_FPM
/opt/php/sbin/php-fpm
#启动NGINX
/opt/nginx/nginx


#-------------------------------下载管理脚本------------------------------
wget --no-check-certificate https://www.pescms.com/status.sh