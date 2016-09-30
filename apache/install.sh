#!/bin/sh
IpAddress=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
cd /tmp
tar -zxvf httpd-2.2.31.gz
cd httpd-2.2.31
./configure --prefix=/apache2  --with-mpm=prefork --with-port=80 --enable-so --enable-http
make && make install
#init config
sed -i "s/#ServerName www.example.com:80/ServerName $IpAddress:80/g" /apache2/conf/httpd.conf
#check httpd
/apache2/bin/apachectl -t
