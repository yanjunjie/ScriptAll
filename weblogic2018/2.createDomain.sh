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
SYS_PASS=$6
CURRENT_HOME=$7
DOMAIN_NAME=$(echo $APP_NAME |sed -e 's/-//g' |sed 's/$/_domain/')
DOMAIN_HOME=/midware/wls12.1.3/user_projects/domains/$DOMAIN_NAME
PYTHON_HOME=/midware/python

#创建weblogic域及AdminServer
function createdomain(){
  #createdomain(wlHome,domainHome,adminip,adminport):
  #createdomain.py /midware/wls12.1.3/wlserver /midware/wls12.1.3/user_projects/domains/webcrcmanage_domain 10.128.148.128 8000
  echo username=$WLS_USER > $CURRENT_HOME/boot.properties
  echo password=$WLS_PASS >> $CURRENT_HOME/boot.properties
  $WLS_HOME/common/bin/wlst.sh -i $CURRENT_HOME/createdomain.py  $WLS_HOME $DOMAIN_HOME $ADMIN_IP $ADMIN_PORT $CURRENT_HOME > /home/weblogic/createdomain.log

}

#生成admin起停脚本
function configAdminscript(){
    if onThisHost; then
       sh $CURRENT_HOME/create-start-admin.sh $DOMAIN_NAME $DOMAIN_HOME >> /home/weblogic/createdomain.log
       startServer
    else
       #echo "$ADMIN_IP is NOT on this host"
       #python getSerialize weblogic weblogic 10.128.148.129 /midware/wls12.1.3/user_projects/domains/webcrcmanage_domain
       echo "paramiko.Transport ... " >> /home/weblogic/createdomain.log
       python $CURRENT_HOME/getSerialize.py $WLS_USER $SYS_PASS $ADMIN_IP $DOMAIN_HOME >> /home/weblogic/createdomain.log
       echo "update SerializedSystemIni.dat file done!" >> /home/weblogic/createdomain.log
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
 if [ "`whoami`" = "weblogic" ];then
    createdomain
 else
    echo "ERROR,startup is wrong,you must use weblogic user!"
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
     echo "Started the WebLogic Server Administration Server [AdminServer] " >> /home/weblogic/createdomain.log
     echo "1"
  else
    echo -n "INFO: starting AdminServer" >>/home/weblogic/createdomain.log
    startAdminServer
    COUNT=0
    ISRUNNING=1
    while [ $ISRUNNING -ne 0 -a $COUNT -lt $MAXWAIT ] ; do
       sleep 3;        echo -n . >> /home/weblogic/createdomain.log
       listenerOnPort $ADMIN_PORT
       ISRUNNING=$?
       COUNT=$(($COUNT +1))
    done
    if [ $ISRUNNING -eq 1 ]; then
       echo "0"
    else
       echo "Server state changed to RUNNING" >> /home/weblogic/createdomain.log
       echo "1"
    fi
  fi
}


function checkinstall(){
  result=$(grep -i "err" /home/weblogic/createdomain.log |wc -l)
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


usage()
{
  echo ""
  echo "=================================================================="
  echo "APP_NAME=$1"
  echo "ADMIN_IP=$2"
  echo "ADMIN_PORT=$3"
  echo ""
  echo 'Usage: sh createDomain.sh web-crc-manage 10.0.0.1 8010 weblogic wlsPass wlssyspass'
  echo "==================================================================="
  exit 1
}


if [ ${#} = 0 ]; then
 usage
fi

main
