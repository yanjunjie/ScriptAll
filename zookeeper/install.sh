#!/bin/sh
#single node
#
export JAVA_HOME="/opt/jdk1.7.0_80"
export PATH="$JAVA_HOME/bin:$PATH"
export ZKHOME="/opt/zookeeper"
cd /tmp
#zookeeper install
tar -zxvf zookeeper-3.4.6.tar.gz
cp -R zookeeper-3.4.6 $ZKHOME
cd $ZKHOME/conf
mv zoo_sample.cfg zoo.cfg
