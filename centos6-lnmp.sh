#!/bin/bash
echo "请选择nginx版本，输入对应版本数字:"
echo "1. nginx-1.8.0"
read nginx

case "$nginx" in
[1] )
nginx="1.8.0"
;;
esac

echo "请选择Mysql版本，输入对应版本数字:"
echo "1. mysql-5.5.47"
echo "2. mysql-5.6.25"
read mysql

case "$mysql" in
[1] )
mysql="5.5.47"
;;
[2] )
mysql="5.6.25"
;;
esac


echo "请选择PHP版本，输入对应版本数字:"
echo "1. php-5.6.12"
echo "1. php-7.0.4"
read php

case "$php" in
[1] )
php="5.6.12"
;;
[2] ) 
php="7.0.4"
;;
esac


	#yum -y update
	#nginx的编译环境
	yum -y install gcc automake libtool make gcc gcc-c++ wget

	#mysql的编译环境
	yum -y install ncurses-devel bison

	#PHP的编译环境
	yum -y install cmake libxml2-devel bzip2-devel curl-devel libjpeg-devel libpng-devel autoconf freetype freetype-devel

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
    #-------------------------------下载必要的软件----------------------------
	download "pcre-8.36.tar.gz"
	download "zlib-1.2.8.tar.gz"
	download "openssl-1.0.2d.tar.gz"
	download "bzip2-1.0.5.tar.gz"
	download "nginx-${nginx}.tar.gz"
	download "mysql-${mysql}.tar.gz"
	download "php-${php}.tar.gz"
    #-------------------------------下载对应版本的nmp安装脚本----------------------------
    download "nginx/nginx-${nginx}.sh"
    download "mysql/mysql-${mysql}.sh"
    download "php/php-${php}.sh"
    
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
    ./config shared zlib
    make && make install
    mv /usr/bin/openssl /usr/bin/openssl.old
    mv /usr/include/openssl /usr/include/openssl.old
    ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
    ln -s /usr/local/ssl/include/openssl /usr/include/openssl
    echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
    ldconfig -v

	cd ~
	tar -zxvf bzip2-1.0.5.tar.gz
	mv bzip2-1.0.5 /opt/bzip2
	cd /opt/bzip2
	make
	make install

    #-------------------------------安装Nginx----------------------------
    sh "nginx-${nginx}.sh"
    #-------------------------------安装Mysql----------------------------
    sh "mysql-${mysql}.sh"
    #-------------------------------安装PHP----------------------------
    sh "php-${php}.sh"
    
	#创建访问目录
	mkdir /var/www
	#-------------------------------下载管理脚本------------------------------
	wget --no-check-certificate https://www.pescms.com/lnmp/status.sh
    echo "Install Complete!"

