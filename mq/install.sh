#!/bin/sh
# Shell script to check  all and install WebSphere MQ8
#
# junjie yan <yjunjie@sino-cr.org>
# Feb 29, 2016
##

platform=`uname`
UNLIMITED=unlimited

  if [ -t 1 ]; then
    PASS="\033[32mPASS\033[m"
    WARN="\033[33mWARN\033[m"
    FAIL="\033[31mFAIL\033[m"
  else
    PASS=PASS
    WARN=WARN
    FAIL=FAIL
  fi

  CheckRoot() {
        output=`id`
        UserID=`echo $output | cut -f1 -d ' ' | cut -f2 -d '=' | cut -f1 -d '('`
        if [ "$UserID" != "0" ]; then
           echo "This script must be executed as root" 
           exit 1 
        fi
  }
  DisplayLimit() {
    PARAM=$1
    UNITS=$2
    VALUE=$3
    LIMIT=$4

    if [ "$VALUE" = "$UNLIMITED" ]; then
      printf "  %-19s %-34s %-17s %b\n" "$PARAM" "VALUE:$VALUE $UNITS" "VALUE>=$LIMIT"  $PASS
    elif [ "$VALUE" -ge "$LIMIT" ]; then
      printf "  %-19s %-34s %-17s %b\n" "$PARAM" "VALUE:$VALUE $UNITS" "VALUE>=$LIMIT"  $PASS
    else
      printf "  %-19s %-34s %-17s %b\n" "$PARAM" "VALUE:$VALUE $UNITS" "VALUE>=$LIMIT"  $FAIL
    fi
  }

  Setulimit() {
    PARAM=$1
    echo "Set ulimit $PARAM"
 
    cat << EOF >> /etc/security/limits.conf
*    soft    nofile  10240
*    hard    nofile  10240
EOF
    echo "you must restart system!"
    exit
  }
  
setfilemax() {
  PARAM=$1
   echo "Set fs.file-max $PARAM"
   echo "fs.file-max = $PARAM" >> /etc/sysctl.conf
   echo "you must restart system!"  
}


  CreateUser(){
        egrep "^mqm" /etc/group >& /dev/null
        if [ $? -ne 0 ];then
        groupadd -g 1001 mqm
        echo "create group mqm success!"
        fi
        egrep "^mqm" /etc/passwd >& /dev/null
        if [ $? -ne 0 ];then
        useradd -G mqm -g mqm -d /var/mqm -p mqm -u 1001 mqm
        echo "mqmpwd" | passwd --stdin mqm
        echo "create user mqm success!, password: [mqmpwd]"
        fi
  }
  CreateDir() {
  if [ ! -d "/MQHA" ]; then
    mkdir -p /MQHA;
    echo "DIR /MQHA created!"
  fi
    chown -R mqm:mqm /MQHA   
    chmod 755 /MQHA
  }

  GetLinuxValue() {
    PARAM=$1
    VALUE=

    if [ -x /sbin/sysctl ]; then
      VALUE=`/sbin/sysctl -n $PARAM 2>/dev/null`
    fi
    printf "$VALUE"
  }

  CheckKernel() {
 
    IBM_SEMMSL=32
    IBM_SEMMNS=4096
    IBM_SEMOPM=32
    IBM_SEMMNI=128
    IBM_SHMMNI=4096
    IBM_SHMALL=2097152
    IBM_SHMMAX=268435456
    IBM_SHMMAX_MIN=33554432
    IBM_KEEPALIVE=
    IBM_KEEPALIVE_MAX=
    IBM_FILEMAX=524288
    IBM_NOFILE_HARD=10240
    IBM_NOFILE_SOFT=10240
    IBM_NPROC_HARD=4096
    IBM_NPROC_SOFT=4096

    CUR_SHMMNI=`GetLinuxValue kernel.shmmni`
    CUR_SHMALL=`GetLinuxValue kernel.shmall`
    CUR_SHMMAX=`GetLinuxValue kernel.shmmax`
    CUR_SEM=`GetLinuxValue kernel.sem`
    CUR_SEMMSL=`printf "%s" "$CUR_SEM" | awk '{print $1}'`
    CUR_SEMMNS=`printf "%s" "$CUR_SEM" | awk '{print $2}'`
    CUR_SEMOPM=`printf "%s" "$CUR_SEM" | awk '{print $3}'`
    CUR_SEMMNI=`printf "%s" "$CUR_SEM" | awk '{print $4}'`
    CUR_FILEMAX=`GetLinuxValue fs.file-max`
    if [ "$CUR_FILEMAX" -lt "$IBM_FILEMAX"  ]; then
      setfilemax $IBM_FILEMAX
    fi
    CUR_NOFILE_HARD=`ulimit -Hn 2>/dev/null`
    CUR_NOFILE_SOFT=`ulimit -Sn 2>/dev/null`
    CUR_NPROC_HARD=`ulimit -Hu 2>/dev/null`
    CUR_NPROC_SOFT=`ulimit -Su 2>/dev/null`
    
    if [ "$CUR_NOFILE_HARD" -lt "$IBM_NOFILE_HARD"  ]; then
      Setulimit $IBM_NOFILE_HARD
    fi
    printf "\nSystem V Semaphores\n"
    DisplayLimit "semmsl"  semaphores  "$CUR_SEMMSL"       "$IBM_SEMMSL"
    DisplayLimit "semmns"  semaphores  "$CUR_SEMMNS"       "$IBM_SEMMNS"
    DisplayLimit "semopm"  operations  "$CUR_SEMOPM"       "$IBM_SEMOPM"
    DisplayLimit "semmni"  sets        "$CUR_SEMMNI"       "$IBM_SEMMNI"
   
    printf "\nSystem V Shared Memory\n"
    DisplayLimit shmmax                bytes       "$CUR_SHMMAX"       "$IBM_SHMMAX"
    DisplayLimit shmmni                sets        "$CUR_SHMMNI"       "$IBM_SHMMNI"
    DisplayLimit shmall                pages       "$CUR_SHMALL"       "$IBM_SHMALL"
    printf "\nSystem Settings\n"
    DisplayLimit file-max              files       "$CUR_FILEMAX"      "$IBM_FILEMAX"

    printf "\nCurrent User Limits (%s)\n" "`id -un 2>/dev/null`"
    DisplayLimit "nofile       (-Hn)"  files       "$CUR_NOFILE_HARD"  "$IBM_NOFILE_HARD"
    DisplayLimit "nofile       (-Sn)"  files       "$CUR_NOFILE_SOFT"  "$IBM_NOFILE_SOFT"
    DisplayLimit "nproc        (-Hu)"  processes   "$CUR_NPROC_HARD"   "$IBM_NPROC_HARD"
    DisplayLimit "nproc        (-Su)"  processes   "$CUR_NPROC_SOFT"   "$IBM_NPROC_SOFT"
  }
  UnzipMQ() {
    if [ ! -f "WS_MQ_V8.0.0.2_LINUX_ON_X86_64_I.tar.gz" ];then
      echo "Cannot find WS_MQ_V8.0.0.2_LINUX_ON_X86_64_I.tar.gz"
      exit 1
   else
      echo "unzip the files WS_MQ_V8..0.0.2_LINUX_ON_X86_64_I.tar.gz ..."
      tar -zxvf WS_MQ_V8.0.0.2_LINUX_ON_X86_64_I.tar.gz >/dev/null
      echo "unzip the files done!"
   fi
  }

  Checkmqm() {
    result=`rpm -qa|grep MQSeries |wc -l`
    if [ "$result -ge 12" ]; then
      echo "MQ install success"
      echo "MQ installed:"
      rpm -qa|grep MQSeries
      echo "set primary installation:"
      /opt/mqm/bin/setmqinst -i -p /opt/mqm
      echo "MQ Product information:"
      su - mqm -c "
      /opt/mqm/bin/dspmqver -i
      exit"
    else
      echo "MQ install faild"
      exit
    fi
  }

  QueueTest() {
  su - mqm -c "
  crtmqm QMTEST
  strmqm QMTEST
  exit"
  mqstatus=`/opt/mqm/bin/dspmq |awk '{print $2}' |cut -f2 -d '(' |cut -f1 -d ')'`
  echo $mqstatus
  if [ "$mqstatus" = "Running" ]; then
   echo "====================================="
   echo "queue manager (QMTEST) start success!"
   echo "====================================="
  else
   echo "queue manager (QMTEST) start Faild"
   exit 1
  fi
  su - mqm -c "
  echo 'def ql(LQ)' | runmqsc QMTEST >/dev/null
  echo 'put hello message:'
  echo 'hello' | /opt/mqm/samp/bin/amqsput LQ QMTEST
  echo 'get hello message:'
  /opt/mqm/samp/bin/amqsbcg LQ QMTEST |grep 'hello'
  endmqm -i QMTEST
  dltmqm QMTEST
  exit"
  }

  Installmqm() {
    CreateUser
    UnzipMQ
    cd server
    ./mqlicense.sh -accept
    rpm -ivh MQSeriesRuntime-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesServer-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesJava-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesJRE-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesSDK-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesSamples-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesClient-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesMsg_Zh_CN-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesMan-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesGSKit-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesMsg_es-8.0.0-2.x86_64.rpm
    rpm -ivh MQSeriesExplorer-8.0.0-2.x86_64.rpm
    Checkmqm 
    QueueTest
  }
CheckRoot
CheckKernel
Installmqm

