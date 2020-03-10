#!/bin/sh
#Date: 2016-11-14 13:00
#Author:yanjunjie
#Description: install weblogic init script
#os_version:RHEL 6.9


#判断执行脚本所属用户
output=`id`
UserID=`echo $output | cut -f1 -d ' ' | cut -f2 -d '=' | cut -f1 -d '('`
if [ "$UserID" != "0" ]; then
   echo "This script must be executed as root"
   exit 1
fi



#创建weblogic用户和组
#uid=501(weblogic) gid=501(mw) groups=501(mw)

egrep "^MW" /etc/group >& /dev/null
if [ $? -ne 0 ];then
 groupadd -g 501 mw
else
  echo "group midware already exists"
fi

egrep "^weblogic" /etc/passwd >& /dev/null
if [ $? -ne 0 ];then
  useradd -G mw -g mw -d /home/weblogic -p weblogic -u 501 weblogic
  echo "Cr@)!&2g" | passwd --stdin weblogic
else
  echo "user weblogic already exists"
fi


#创建所需的目录


if [ ! -d /midware ];then
   mkdir  /midware
   chown -R weblogic:mw /midware
fi

if [ ! -d /midware/software ];then
   mkdir -p /midware/software
   chown -R weblogic:mw /midware/software
fi

if [ ! -d /midware/wls12.1.3/applications ];then
   mkdir -p /midware/wls12.1.3/applications
   chown -R weblogic:mw /midware/wls12.1.3/applications
fi




#安装JDK1.7

cd /midware
if [ ! -f "jdk-7u80-linux-x64.gz" ];then
    echo "jdk-7u80-linux-x64.gz not found!"
    exit 1
  elif [ ! -d "jdk1.7.0_80" ];then
    tar -zxvf jdk-7u80-linux-x64.gz
    sed -i '/^securerandom/s/^/#/' /midware/jdk1.7.0_80/jre/lib/security/java.security
    sed -i '/^#securerandom/a\securerandom.source=file:\/\dev/\./\urandom' /midware/jdk1.7.0_80/jre/lib/security/java.security

  else
    echo "the directory jdk1.7.0_80 already exists"
fi


#环境变量配置
grep -q "export JAVA_HOME=/midware/jdk1.7.0_80" /etc/profile || echo "export JAVA_HOME=/midware/jdk1.7.0_80" >> /etc/profile
grep -q "export CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" /etc/profile || echo "export CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /et/profile
grep -q "export PATH=\$JAVA_HOME/bin:\$PATH" /etc/profile || echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile

#安装日志切割工具

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

#安装paramiko包依赖python环境
#
#
#

#修改字符集编码

grep -q 'export LANG="zh_CN.UTF-8"' /etc/profile || echo 'export LANG="zh_CN.UTF-8"' >> /etc/profile
grep -q 'export LC_ALL="zh_CN.UTF-8"' /etc/profile || echo 'export LANG="zh_CN.UTF-8"' >> /etc/profile

#修改最大句柄数

grep -q "fs.file-max" /etc/sysctl.conf || echo "fs.file-max=2000000" >> /etc/sysctl.conf
grep -q "weblogic soft nproc 65536" /etc/security/limits.conf || echo "weblogic soft nproc 65536" >> /etc/security/limits.conf
grep -q "weblogic hard nproc 65536" /etc/security/limits.conf || echo "weblogic hard nproc 65536" >> /etc/security/limits.conf
grep -q "weblogic soft nofile 65536" /etc/security/limits.conf || echo "weblogic soft nofile 65536" >> /etc/security/limits.conf
grep -q "weblogic hard nofile 65536" /etc/security/limits.conf || echo "weblogic hard nofile 65536" >> /etc/security/limits.conf
grep -q "weblogic soft nproc 65536" /etc/security/limits.d/90-nproc.conf || echo "weblogic soft nproc 65536" >> /etc/security/limits.d/90-nproc.conf
grep -q "ulimit -u 65536" /etc/profile || echo "ulimit -u 65536" >> /etc/profile


mv /midware/jdk-7u80-linux-x64.gz /midware/software
mv /midware/cronolog-1.6.2.tar.gz /midware/software
mv /midware/cronolog-1.6.2 /midware/software
chown -R weblogic:mw /midware


