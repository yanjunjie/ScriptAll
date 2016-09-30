#!/bin/sh
pid=`ps -ef|grep redis|grep -v grep |awk '{print $2}'`
if [ "$pid" = "" ];then
  /usr/local/bin/redis-server /opt/redis-2.8.24/redis.conf
else
 echo "redis(pid: $pid) already running.."
fi
