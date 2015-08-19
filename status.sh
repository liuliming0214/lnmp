#!/bin/bash
echo "请选择您的操作:"
echo "1. 重启Nginx"
echo "2. 重启Mysql"
echo "3. 重启PHP-FPM"
echo "4. 重启LNMP"
echo "5. 启动LNMP"
echo "6. 停止LNMP"
echo "7. 添加新域名"
echo "请输入数字:"
read num

case "$num" in
[1] ) 
echo '执行关闭Nginx进程...'
kill -9 `ps -aux | grep nginx| awk -F' ' '{print $2}'`
echo '进行重启Nginx...'
/opt/nginx/nginx
echo '已成功重启Nginx!'
;;
[2] ) 
echo '执行Mysql重启命令...'
/etc/init.d/mysql restart
echo '已成功重启Mysql!'
;;
[3] )
echo '执行关闭php-fpm进程...'
kill -9 `ps -aux | grep php-fpm| awk -F' ' '{print $2}'`
echo '进行重启php-fpm...'
/opt/php/sbin/php-fpm
echo '已成功重启php-fpm!'
;;
[4] ) 
#执行顺序说明：Nginx执行PHP依赖php-fpm，因此必须先对php-fpm进行重启!
echo '执行关闭php-fpm进程...'
kill -9 `ps -aux | grep php-fpm| awk -F' ' '{print $2}'`
echo '进行重启php-fpm...'
/opt/php/sbin/php-fpm
echo '已成功重启php-fpm!'
echo '执行关闭Nginx进程...'
kill -9 `ps -aux | grep nginx| awk -F' ' '{print $2}'`
echo '进行重启Nginx...'
/opt/nginx/nginx
echo '已成功重启Nginx!'
echo '执行Mysql重启命令...'
/etc/init.d/mysql restart
echo '已成功重启Mysql!'
echo 'LNMP已经成功重启！'
;;
[5] ) 
echo '启动LNMP中...'
/opt/php/sbin/php-fpm
/opt/nginx/nginx
/etc/init.d/mysql start
echo 'LNMP已经成功启动！'
;;
[6] ) 
echo '停止LNMP中...'
kill -9 `ps -aux | grep php-fpm| awk -F' ' '{print $2}'`
kill -9 `ps -aux | grep nginx| awk -F' ' '{print $2}'`
/etc/init.d/mysql stop
echo 'LNMP已经停止！'
;;
[7] )
echo "请输入域名"
read domain
echo "是否开启重写[y/n]"
read rewrite
rewriteStr=""
if [ $rewrite = "y" ]
then
    rewriteStr="
    location ~/ {
      if (!-e \$request_filename){
        rewrite  ^/(.*)\$  /index.php?s=\$1 last;
      }
    }"
fi
echo "
server {
    listen       80;
    server_name $domain;
    root /var/www;
    index index.html index.htm index.php;
    access_log  /opt/nginx/log/$domain.access.log;
    error_log  /opt/nginx/log/$domain.error.log;

    location / {

    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    
    $rewriteStr
}">> /opt/nginx/vhost/$domain.conf
;;
*) echo "没有任何操作，脚本退出";;
esac
