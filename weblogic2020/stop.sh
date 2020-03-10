#!/bin/sh
################################
#Name:        stop.sh
#Version:     v1.0
#Author:      yanjunjie
#create Date: 2017-09-21
################################

SERVERNAME=$1

function getServerPid(){
  PID=$(ps -ef|grep -e "-Dweblogic.Name=$1" |grep -v grep |awk '{print $2}')
  echo $PID
}


function stopServer(){
  PID=$(getServerPid $SERVERNAME)
  if [ "$PID" != "" ];then
     #echo "killing server $SERVERNAME processes: $PID"
     kill -9 $PID 2>&1 > /dev/null
  fi
}

function States(){
  PID=$(getServerPid $SERVERNAME)
  if [ "$PID" = "" ];then
    echo "1"
  else
    echo "0"
  fi
}
stopServer
sleep 1;
States
