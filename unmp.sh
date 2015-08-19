#!/bin/bash

#ubuntuϵͳ������������
# ��ִ��һ�θ��£���ֹԤװ�Ļ���������
sudo apt-get update
#nginx�ı��뻷��
sudo apt-get install -y build-essential wget 
sudo apt-get install -y libtool

#mysql�ı��뻷��
sudo apt-get install -y libncurses5-dev bison

#PHP�ı��뻷��
sudo apt-get install -y cmake libxml2-dev libxml2 curl libcurl3 libcurl4-gnutls-dev libjpeg-dev libpng-dev autoconf libfreetype6-dev

#����Ҫ��װ���ļ�
download(){
    cd ~
    wget --no-check-certificate https://www.pescms.com/lnmp/$1
    #ȷ���ļ��ܹ�����ȷ����
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

#-------------------------------����ϵͳ��Ҫ���ļ�----------------------------
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



#-------------------------------��װNginx----------------------------
cd ~
tar -xvzf nginx-1.8.0.tar.gz
mv nginx-1.8.0 /opt/nginx
cd /opt/nginx

./configure --sbin-path=/opt/nginx/nginx --conf-path=/opt/nginx/nginx.conf --pid-path=/opt/nginx/nginx.pid --with-http_ssl_module --with-pcre=/opt/pcre --with-zlib=/opt/zlib --with-openssl=/opt/openssl

make
make install

mkdir /opt/nginx/vhost
mkdir /opt/nginx/log

	#����nginx֧��PHP-FPM
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


#-------------------------------��װMysql----------------------------
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

#����Ȩ�ޣ�����ִ��ʱ����
chmod -R 777 scripts/mysql_install_db 


scripts/mysql_install_db --basedir=/opt/mysql --datadir=/opt/mysql/data --user=mysql 
cp support-files/my-default.cnf /opt/mysql/my.cnf

#��MYSQL��������Ϣд�������ļ�
echo "
sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION 
[mysqld]
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

#�����û�Ȩ��
sudo chown -R mysql:mysql /opt/mysql

cp /opt/mysql/support-files/mysql.server /etc/init.d/mysql

#����Ȩ�ޣ�����ִ�г���
sudo chmod -R 777 /etc/init.d/mysql

#���һ�δ��ڵ�ϵͳ����
sed  -i 's/export PATH=.*$//g' /etc/profile
#��Mysqlд�뻷������
echo "export PATH=/opt/mysql/bin:$PATH" >>/etc/profile 

#���¼��ػ�������
. /etc/profile 

/etc/init.d/mysql start

mysqladmin -u root password "123456" #����root����


#-------------------------------��װPHP------------------------------
cd ~
tar -xvzf php-5.6.12.tar.gz
mv php-5.6.12 /opt/php
cd /opt/php
./configure --prefix=/opt/php  --enable-fpm --enable-mbstring --disable-pdo --with-curl --disable-debug  --disable-rpath --enable-inline-optimization --with-bz2  --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-pdo --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-mysqli --with-pdo_mysql --with-gd --with-jpeg-dir --with-freetype-dir
make
make install

#�ƶ���Ӧ�������ļ�
cp etc/php-fpm.conf.default etc/php-fpm.conf
cp php.ini-development lib/php.ini

#����PHP-FPM���û����飬���޸Ķ�Ӧ������
groupadd www-data
useradd -g www-data www-data
sed  -i 's/user = nobody$/user = www-data/g' /opt/php/etc/php-fpm.conf
sed  -i 's/group = nobody$/group = www-data/g' /opt/php/etc/php-fpm.conf

#�޸�PHP.ini����
sed  -i 's/pdo_mysql\.default_socket.*=$/pdo_mysql\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini
sed  -i 's/mysqli\.default_socket.*=$/mysqli\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini
sed  -i 's/mysql\.default_socket.*=$/mysql\.default_socket =\/opt\/mysql\/mysql\.sock/g' /opt/php/lib/php.ini

#��������Ŀ¼
mkdir /var/www

#����PHP_FPM
/opt/php/sbin/php-fpm
#����NGINX
/opt/nginx/nginx


#-------------------------------���ع���ű�------------------------------
wget --no-check-certificate https://www.pescms.com/status.sh