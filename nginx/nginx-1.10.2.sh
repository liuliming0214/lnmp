#!/bin/bash
	cd ~
	tar -xvzf nginx-1.10.2.tar.gz
	mv nginx-1.10.2 /opt/nginx
	cd /opt/nginx

	./configure --sbin-path=/opt/nginx/nginx --conf-path=/opt/nginx/nginx.conf --pid-path=/opt/nginx/nginx.pid --with-http_ssl_module --with-pcre=/opt/pcre --with-zlib=/opt/zlib --with-openssl=/opt/openssl --with-http_v2_module

	make
	make install

	mkdir /opt/nginx/vhost
	mkdir /opt/nginx/log

		#配置nginx支持PHP-FPM
		sed -i '18,$d' /opt/nginx/nginx.conf
	echo "
		include       mime.types;
        default_type       application/octet-stream;

        charset            UTF-8;

        sendfile           on;
        tcp_nopush         on;
        tcp_nodelay        on;

        keepalive_timeout  60;
        gzip               on;
        gzip_vary          on;

        gzip_comp_level    6;
        gzip_buffers       16 8k;

        gzip_min_length    1000;
        gzip_proxied       any;
        gzip_disable       \"msie6\";

        gzip_http_version  1.0;

        gzip_types         text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript image/svg+xml;

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
    
    ln -s /opt/nginx/nginx /usr/bin/