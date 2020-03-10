#!/bin/sh
#Date: 2018-03-07
#Author:yanjunjie


adminServerListenAddress=$1
adminServerListenPort=$2
clusterName=$3
serverName=$4
CURRENT_HOME=$5
wls_home=/midware/wls12.1.3/wlserver
LOG_HOME=/home/pbcc

function getServerPid(){
  PID=$(ps -ef|grep -e "-Dweblogic.Name=$1" |grep -v grep |awk '{print $2}')
  echo $PID
}




function stopServer(){
  getServerPid $serverName |while read PID
  do
    if [ "$PID" != "" ];then
       echo "killing server $SERVERNAME processes: ${PID}" >> $LOG_HOME/cluster_creation$(date '+%Y-%m-%d').log
       kill -9 ${PID} 2>&1 > /dev/null
       echo "process(Process ID:${PID}) Shutdown Sucessfully!" >> $LOG_HOME/cluster_creation$(date '+%Y-%m-%d').log
    fi
  done
}


#创建集群
function configCluster(){
   $wls_home/common/bin/wlst.sh -i $CURRENT_HOME/cluster_creation.py $adminServerListenAddress $adminServerListenPort $clusterName $serverName $CURRENT_HOME >>  $LOG_HOME/cluster_creation$(date '+%Y-%m-%d').log
}



#配置集群脚本校验
function check_configCluster(){
  result=0
  domain_home=$(grep 'location' /midware/wls12.1.3/domain-registry.xml | sed -r 's/.*"(.+)".*/\1/')
  for domain in $domain_home ;do
      grep -q $1 $domain/config/config.xml
      if [ "$?" -ne "0" ]; then
         result=1
      fi
  done
  return $result
}


function checkcluster(){
 check_configCluster $clusterName
   status=$?
   if [ $status -eq 0 ];then
      echo "configCluster success!" >> $LOG_HOME/cluster_creation$(date '+%Y-%m-%d').log
      echo 1
   else
      #echo "failed"
      echo 0
   fi
}


function main(){
   stopServer
   configCluster
   checkcluster
}


if [ ${#} = 0 ]; then
 usage
fi
main
