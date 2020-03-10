#!/bin/sh
#Date: 2018-02-24 
#Author:yanjunjie
#Description: create weblogic Admin  script
#os_version:RHEL 6.9

#定义变量
JAVA_HOME=/midware/jdk1.7.0_80
WLS_HOME=/midware/wls12.1.3/wlserver
APP_NAME=$1
ADMIN_IP=$2
ADMIN_PORT=$3
WLS_USER=$4
WLS_PASS=$5
SYS_USER=$6
SYS_PASS=$7
CURRENT_HOME=$8
DOMAIN_NAME=$(echo $APP_NAME |sed -e 's/-//g' |sed 's/$/_domain/')
DOMAIN_HOME=/midware/wls12.1.3/user_projects/domains/$DOMAIN_NAME
PYTHON_HOME=/midware/python
LOG_HOME=/home/pbcc


#创建weblogic域及AdminServer
function createdomain(){
  #createdomain(wlHome,domainHome,adminip,adminport):
  #createdomain.py /midware/wls12.1.3/wlserver /midware/wls12.1.3/user_projects/domains/webcrcmanage_domain 10.128.148.128 8000
  echo username=$WLS_USER > $CURRENT_HOME/boot.properties
  echo password=$WLS_PASS >> $CURRENT_HOME/boot.properties
  $WLS_HOME/common/bin/wlst.sh -i $CURRENT_HOME/createdomain.py  $WLS_HOME $DOMAIN_HOME $ADMIN_IP $ADMIN_PORT $CURRENT_HOME > $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log

}

#生成admin起停脚本
function configAdminscript(){
    if onThisHost; then
       sh $CURRENT_HOME/create-start-admin.sh $DOMAIN_NAME $DOMAIN_HOME $CURRENT_HOME >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
       startServer
    else
       #echo "$ADMIN_IP is NOT on this host"
       #python getSerialize weblogic weblogic 10.128.148.129 /midware/wls12.1.3/user_projects/domains/webcrcmanage_domain
       echo "paramiko.Transport ... " >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
       python $CURRENT_HOME/getSerialize.py $SYS_USER $SYS_PASS $ADMIN_IP $DOMAIN_HOME >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
       echo "update SerializedSystemIni.dat file done!" >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
       checkinstall
    fi
}


#启动AdminServer
function startAdminServer(){
    python $CURRENT_HOME/start-Server.py /midware/wls12.1.3/script/start-AdminServer.sh
}



#
#判断adminip是否是当前主机
#

function onThisHost() {

        ADDRESS=$ADMIN_IP
        if [ -z "$ADDRESS" ] ; then
                #echo "WARN: no address specified for $ADMIN_IP " >&2
                return 0
        fi

        if  expr "$ADDRESS" : '127\.' > /dev/null ; then
                #echo "INFO: $ADMIN_IP is loopback  address " >&2
                return 0
        fi

        PRESENT=$(/sbin/ifconfig | grep -e "addr:$ADDRESS")
        if [ -z "$PRESENT"  ] ; then
                #echo "INFO: $ADMIN_IP is NOT on this host." >&2
                return 1
        else
                #echo "INFO: $ADMIN_IP is on this host. " >&2
                return 0
        fi
}


#判断当前用户
function checkUser(){
 if [ "`whoami`" = "pbcc" ];then
    createdomain
 else
    echo "ERROR,startup is wrong,you must use pbcc user!"
    exit
 fi

}



#超时
MAXWAIT=20


#检查端口
function listenerOnPort(){
  LISTENING=$(netstat -an |grep $ADMIN_PORT)
  test -n "$LISTENING"
  return $?
}


#启动Server
function startServer(){
  if listenerOnPort $ADMIN_PORT ; then
     echo "Started the WebLogic Server Administration Server [AdminServer] " >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
     echo "1"
  else
    echo -n "INFO: starting AdminServer" >>$LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
    startAdminServer
    COUNT=0
    ISRUNNING=1
    while [ $ISRUNNING -ne 0 -a $COUNT -lt $MAXWAIT ] ; do
       sleep 3;        echo -n . >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
       listenerOnPort $ADMIN_PORT
       ISRUNNING=$?
       COUNT=$(($COUNT +1))
    done
    if [ $ISRUNNING -eq 1 ]; then
       echo "Server state changed to FAILED" >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
       echo "0"
    else
       echo "Server state changed to RUNNING" >> $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log
       echo "1"
    fi
  fi
}


function checkinstall(){
  result=$(grep -i "err\|FAILED" $LOG_HOME/createdomain_$(date '+%Y-%m-%d').log |wc -l)
  if [ "$result" = 0 ];then
     echo "1"
  else
     echo "0"
  fi
}


function main(){
   checkUser
   configAdminscript
}


if [ ${#} = 0 ]; then
 usage
fi

main
