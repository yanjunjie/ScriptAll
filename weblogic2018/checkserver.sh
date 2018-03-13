#!/bin/sh

SERVERNAME=$1
SERVERPORT=$2

#判断PID是否存在
function getServerPid(){
  PID=$(ps -ef|grep -e "-Dweblogic.Name=$1" |grep -v grep |awk '{print $2}')
  test -n "$PID"
  return $?
}
  

#判断端口是否监听
function listenerOnPort(){
  LISTENING=`netstat -an | grep ":$1 " | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' |wc -l`
  echo "$LISTENING"
  test -n "$LISTENING"
}


#main
function main(){
if getServerPid $SERVERNAME; then
   PORT=$(listenerOnPort $SERVERPORT)
   if [ $PORT -eq 0 ];then
       #echo "Server $SERVERNAME not running"
       echo "0"
   else
       #echo "Server $SERVERNAM (pid $PID) already running"
       echo "1"
   fi
else
  echo "0"
fi
}

usage()
{
  echo ""
  echo "=================================================================="
  echo ""
  echo 'Usage: sh checkserver.sh webcrcmanage-wls28-srv01 8011'
  echo "==================================================================="
  exit 1
}

if [ ${#} = 0 ]; then
 usage
fi
main
