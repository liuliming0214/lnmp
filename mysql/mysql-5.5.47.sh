#!/bin/bash
	cd ~
	groupadd mysql
	useradd -g mysql mysql -s /usr/sbin/nologin

	tar -xvzf mysql-5.5.47.tar.gz
	cd mysql-5.5.47
    
    mkdir /opt/mysql/
	mkdir /opt/mysql/data
	mkdir /opt/mysql/log

	cmake -DCMAKE_INSTALL_PREFIX=/opt/mysql -DMYSQL_UNIX_ADDR=/opt/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/opt/mysql/data -DMYSQL_TCP_PORT=3306
	make
	make install

    
	cd /opt/mysql
	#赋予权限，避免执行时出错
	chmod -R 777 /opt/mysql/scripts/mysql_install_db


	/opt/mysql/scripts/mysql_install_db --basedir=/opt/mysql --datadir=/opt/mysql/data --user=mysql
    #5.5是的配置文件是存放在/etc目录下的
	cp -uf support-files/my-large.cnf  /etc/my.cnf

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