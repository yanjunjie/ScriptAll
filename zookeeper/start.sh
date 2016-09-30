#!/bin/sh
export JAVA_HOME="/opt/jdk1.7.0_80"
export PATH="$JAVA_HOME/bin:$PATH"
export ZKHOME="/opt/zookeeper"
pid=`ps -ef|grep zookeeper |grep -v grep |awk '{print $2}'`
if [ "$pid" = "" ];then
  cd $ZKHOME/bin
  ./zkServer.sh start
else
  echo "redis(pid: $pid) already running.."
  exit
fi
#check status
sleep 2
pid=`ps -ef|grep zookeeper|grep -v grep |awk '{print $2}'`
if [ "$pid" = "" ];then
 echo "zookeeper not runing"
else
 echo "zookeeper(Process ID:$pid) start Successfully!"
fi
