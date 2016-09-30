#!/bin/sh
# copy the boot.properties  to the AdminServer.
#

DOMAIN_HOME=`cat config.ini |grep DOMAIN_HOME |cut -d "=" -f 2`
SERVER=AdminServer
SOURCE=boot.properties
TARGETDIR=$DOMAIN_HOME/servers/$SERVER/security
if [ ! -f $TARGETDIR/boot.properties ]; then
  mkdir -p $TARGETDIR
  cp -f $SOURCE $TARGETDIR
  echo "INFO: copied boot.properties to $SERVER"
else
  echo "ERROR: the boot.properties already exists. "
fi
