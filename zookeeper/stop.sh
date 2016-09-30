#!/bin/sh
export JAVA_HOME="/opt/jdk1.7.0_80"
export PATH="$JAVA_HOME/bin:$PATH"
export ZKHOME="/opt/zookeeper"
pid=`ps -ef|grep zookeeper |grep -v grep |awk '{print $2}'`
if [ "$pid" = "" ];then
  echo "zookeeper not runing!"
  exit
else
  cd $ZKHOME/bin
  ./zkServer.sh stop
fi
#check status
sleep 2
pid=`ps -ef|grep zookeeper|grep -v grep |awk '{print $2}'`
if [ "$pid" = "" ];then
 echo "zookeeper Shutdown Successfully!"
else
 echo "zookeeper Shutdown Faild!"
fi
