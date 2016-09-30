#!/bin/sh
output=`id`
UserID=`echo $output | cut -f1 -d ' ' | cut -f2 -d '=' | cut -f1 -d '('`
if [ "$UserID" != "0" ]; then
   echo "This script must be executed as root" 
   exit 1 
fi
#user
egrep "^midware" /etc/group >& /dev/null
if [ $? -ne 0 ];then
 groupadd -g 1001 midware
else
  echo "group midware already exists"
fi

egrep "^weblogic" /etc/passwd >& /dev/null
if [ $? -ne 0 ];then
  useradd -G midware -g midware -d /home/weblogic -p weblogic -u 1001 weblogic
  echo "weblogic" | passwd --stdin weblogic
else
  echo "user weblogic already exists"
fi
#jdk
chown -R weblogic:midware /midware
cd /midware
if [ ! -f "jdk-7u80-linux-x64.gz" ];then
    echo "jdk-7u80-linux-x64.gz not found!"
    exit 1
  elif [ ! -d "jdk1.7.0_80" ];then
    tar -zxvf jdk-7u80-linux-x64.gz
    chown -R weblogic:midware jdk1.7.0_80
    sed -i '/^securerandom/s/^/#/' /midware/jdk1.7.0_80/jre/lib/security/java.security
    sed -i '/^#securerandom/a\securerandom.source=file:\/\dev/\./\urandom' /midware/jdk1.7.0_80/jre/lib/security/java.security

  else
    echo "the directory jdk1.7.0_80 already exists"
fi
#cronolog
if [ ! -f "cronolog-1.6.2.tar.gz" ];then
    echo "cronolog-1.6.2.tar.gz not found!"
    exit 1
  elif [ ! -d "cronolog-1.6.2" ];then
    tar -zxvf cronolog-1.6.2.tar.gz
    cd cronolog-1.6.2
    ./configure --prefix=/usr/local/
    make && make install
    
  else
    echo "the directory cronolog-1.6.2 already exists"
fi
