#!/bin/sh

New_Hostname=$1
Old_Hostname=$(hostname)
echo $New_Hostname

IP=$(ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |tr -d "addr:")
#New_Hostname=wls$(echo $IP|awk -F . '{print $4}')

function Change_hosts(){
    echo "$IP   $New_Hostname" >> /etc/hosts
}

function Change_network(){
  sed -i "s/$Old_Hostname/$New_Hostname/g" /etc/sysconfig/network
  hostname $New_Hostname
}

function Check(){
  result=$(grep -i "$New_Hostname" /etc/sysconfig/network |wc -l)
  if [ "$result" = 0 ];then
     echo "ERROR Change_hosts Failed"
     #echo "0"
  else
     echo "Change_hosts Success"
     echo $(grep -i "$New_Hostname" /etc/sysconfig/network)
     #echo "1"
  fi
}

Change_hosts
Change_network
Check