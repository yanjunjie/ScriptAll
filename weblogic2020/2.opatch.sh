#!/bin/sh

LOG_HOME=/home/pbcc

opatch(){

  if [ -d "/midware/PATCH_TOP" ];then
     rm -rf /midware/PATCH_TOP
  fi

  unzip -d /midware/PATCH_TOP /midware/p28710923_121300_Generic.zip > /dev/null 2>&1
  cd /midware/PATCH_TOP/28710923
  echo yes|/midware/wls12.1.3/OPatch/opatch apply > $LOG_HOME/opatch_$(date '+%Y-%m-%d').log
}


nrollback(){
  cd  /midware/PATCH_TOP/27419391
  $WLS_HOME/OPatch/opatch rollback -id 27419391
}


check(){
  num=$(/midware/wls12.1.3/OPatch/opatch lspatches  |grep 12.1.3.0.190115 |wc -l)
  if [[ $num -ne 0 ]];then
     echo "1"
  else
     echo "0"
  fi
}

opatch
#nrollback
check
