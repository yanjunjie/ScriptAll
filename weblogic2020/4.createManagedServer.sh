#!/bin/sh
#Date: 2017-08-03
#Author:yanjunjie
#Description: create weblogic ManagedServer  script
#os_version:RHEL 6.9

WLS_HOME=/midware/wls12.1.3/wlserver
APP_NAME=$1
ADMIN_IP=$2
ADMIN_PORT=$3
SERVER_NAME=$4
LISTEN_ADDRESS=$5
SERVER_PORT=$6
CURRENT_HOME=$7
DOMAIN_NAME=$(echo $APP_NAME |sed -e 's/-//g' |sed 's/$/_domain/')
DOMAIN_HOME=/midware/wls12.1.3/user_projects/domains/$DOMAIN_NAME
LOG_HOME=/home/pbcc


#创建被管server
function createserver(){
  $WLS_HOME/common/bin/wlst.sh -i $CURRENT_HOME/createserver.py $WLS_HOME $DOMAIN_HOME $ADMIN_IP $ADMIN_PORT $SERVER_NAME $LISTEN_ADDRESS $SERVER_PORT $CURRENT_HOME> $LOG_HOME/createserver_$(date '+%Y-%m-%d').log

}

#生成server起停脚本
function configServerscript(){
   sh $CURRENT_HOME/create-start-server.sh $ADMIN_IP $ADMIN_PORT $DOMAIN_HOME $DOMAIN_NAME $SERVER_NAME $CURRENT_HOME >>  $LOG_HOME/createserver_$(date '+%Y-%m-%d').log
}


#超时
MAXWAIT=60


#检查端口
function listenerOnPort(){
  LISTENING=$(netstat -an |grep $SERVER_PORT)
  test -n "$LISTENING"
  return $?
}



#启动Server
function startServer(){
  if listenerOnPort $SERVER_PORT ; then
     echo "1"
  else
    echo -n "INFO: starting Server" >>$LOG_HOME/createserver_$(date '+%Y-%m-%d').log
    #echo -n "INFO: starting $SERVER_NAME"
    startManagedServer
    COUNT=0
    ISRUNNING=1
    while [ $ISRUNNING -ne 0 -a $COUNT -lt $MAXWAIT ] ; do
       sleep 3;        echo -n . >> $LOG_HOME/createserver_$(date '+%Y-%m-%d').log
       listenerOnPort $SERVER_PORT
       ISRUNNING=$?
       COUNT=$(($COUNT +1))
    done
    if [ $ISRUNNING -eq 1 ]; then
       echo "0"
    else
       echo "Server state changed to RUNNING" >> $LOG_HOME/createserver_$(date '+%Y-%m-%d').log
       echo "1"
    fi
  fi
}



#启动MansgedServer

function startManagedServer(){
    python $CURRENT_HOME/start-Server.py /midware/wls12.1.3/script/start-$SERVER_NAME.sh
}


function checkUser(){
 if [ "`whoami`" = "pbcc" ];then
    createserver
 else
    echo "ERROR,startup is wrong,you must use weblogic user!"
    exit
 fi

}


if [ ${#} = 0 ]; then
 usage
fi


function main(){
    checkUser
    configServerscript
    startServer
}
main

