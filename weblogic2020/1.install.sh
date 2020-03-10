#!/bin/sh
# use weblogic user
#global variable 

JAVA_HOME=/midware/jdk1.7.0_80

LOG_HOME=/home/pbcc
#BASE_HOME=$(echo `pwd`)
#安装weblogic软件
function installWLS12c(){
 $JAVA_HOME/bin/java -jar /midware/fmw_12.1.3.0.0_wls.jar -silent -responseFile /midware/script/wls12c.resp  -invPtrLoc /midware/script/oraInst.loc > $LOG_HOME/install.log
 
}


#判断当前用户
function checkUser(){
 if [ "`whoami`" = "pbcc" ];then
    installWLS12c
 else
    #echo "ERROR,startup is wrong,you must use weblogic user!"
    echo "0"
    exit
 fi

}



function checkinstall(){
  result=$(grep -i "error" $LOG_HOME/install.log |wc -l)
  if [ "$result" = 0 ];then
     echo "1"
  else
     echo "0"
  fi
}


function main(){
   checkUser
   checkinstall
}
main
