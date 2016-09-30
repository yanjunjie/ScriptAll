#!/bin/sh
ps -ef|grep redis|grep -v grep |awk '{print $2}' | while read pid
do
  kill -9 ${pid} 2>&1 > /dev/null
  echo "redis(pid: $pid) shutdown sucessfully!"
done
