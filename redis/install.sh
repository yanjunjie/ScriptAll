#!/bin/sh
#single node
REDIS_HOME=/opt/redis-2.8.24
cd /tmp
tar -zxvf  redis-2.8.24.tar.gz
cp -R redis-2.8.24 /opt
cd $REDIS_HOME
make
cd src && make install
#init config
sed -i 's/# maxmemory <bytes>/maxmemory 256mb/g' $REDIS_HOME/redis.conf 
sed -i 's/daemonize no/daemonize yes/g' $REDIS_HOME/redis.conf

#start redis
redis-server $REDIS_HOME/redis.conf 

