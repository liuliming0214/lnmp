#!/bin/bash
filename=`date +%y-%m-%d`
/opt/mysql/bin/mysqldump -uroot -p123456 dbname>/home/backup/dbname-${filename}.sql
find /home/backup -mtime +10 -name "*.sql" -exec rm -rf {} \;