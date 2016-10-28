#!/bin/bash
	cd ~
	groupadd mysql
	useradd -g mysql mysql -s /usr/sbin/nologin

	tar -xvzf mysql-5.6.25.tar.gz
	cd mysql-5.6.25
    
    mkdir /opt/mysql/
	mkdir /opt/mysql/data
	mkdir /opt/mysql/log

	cmake -DCMAKE_INSTALL_PREFIX=/opt/mysql -DMYSQL_UNIX_ADDR=/opt/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/opt/mysql/data -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=3306
	make
	make install

    
	cd /opt/mysql
	#赋予权限，避免执行时出错
	chmod -R 777 /opt/mysql/scripts/mysql_install_db


	/opt/mysql/scripts/mysql_install_db --basedir=/opt/mysql --datadir=/opt/mysql/data --user=mysql
	# cp support-files/my-default.cnf /opt/mysql/my.cnf

	#将MYSQL的配置信息写入配置文件
    mv /etc/my.cnf /etc/my_bak.cnf
    touch /etc/my.cnf
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
tmpdir          = /tmp
bind-address  = 127.0.0.1
max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 4M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

performance_schema = 0
explicit_defaults_for_timestamp

innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

[mysqldump]
quick
max_allowed_packet = 16M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M ">>/etc/my.cnf

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