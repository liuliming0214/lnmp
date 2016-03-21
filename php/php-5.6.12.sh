#!/bin/bash
	cd ~
	tar -xvzf php-5.6.12.tar.gz
	mv php-5.6.12 /opt/php
	cd /opt/php
	./configure --prefix=/opt/php  --enable-fpm --enable-mbstring --disable-pdo --disable-debug  --disable-rpath --enable-inline-optimization --with-bz2  --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-pdo --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-mysqli --with-pdo_mysql --with-gd --with-jpeg-dir --with-freetype-dir --disable-fileinfo
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
    
    ln -s /opt/php/bin/php /usr/bin/
    ln -s /opt/php/bin/php-cgi /usr/bin/
    ln -s /opt/php/bin/php-config /usr/bin/
    ln -s /opt/php/bin/phpize /usr/bin/