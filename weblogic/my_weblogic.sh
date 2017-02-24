#!/bin/sh

COMMAND=${1:status}
MW_HOME=${MW_HOME:-/midware/wls12.1.3}
WL_HOME=${WL_HOME:-${MW_HOME}/wlserver}


function allDomains() {
        grep  'location' $MW_HOME/domain-registry.xml | \
                sed -r 's/.*"(.+)".*/\1/'
        return 0
}


function DomainConfig() {
                DOMAIN_HOME=$1
                DOMAIN=$(basename $DOMAIN_HOME)
                DOMAIN_CONFIG=$DOMAIN_HOME/config/config.xml
                #echo $DOMAIN_CONFIG

                if [ ! -f $DOMAIN_CONFIG ] ; then
                        echo ERROR: Domain configuration file is missing for domain $DOMAIN >&2
                        return 1
                fi
                export DOMAIN_HOME  DOMAIN DOMAIN_CONFIG
                return 0
}


function getAddress() {
	echo $(ping -c 1 $1 2>/dev/null | head -1 | awk '{print $3}' | sed -e 's/[()]//g')
}

function onThisHost() {
        #echo "=========onThisHost========"
        
	ADDRESS=$(getAddress $1)
	if [ -z "$ADDRESS" ] ; then
		echo "WARN: no address specified for $1 " >&2
		return 0
	fi

	if  expr "$ADDRESS" : '127\.' > /dev/null ; then
		echo "INFO: $1 is loopback  address " >&2
		return 0
	fi

	PRESENT=$(/sbin/ifconfig | grep -e "addr:$ADDRESS")
        if [ -z "$PRESENT"  ] ; then
		echo "INFO: $1 is NOT on this host." >&2
		return 1
	else
		echo "INFO: $1 is on this host. " >&2
		return 0
	fi
}

function listenerOnPort() {
		ADDRESS=$(getAddress $1)
		LISTENING=$(netstat -a -n | \
				egrep -e "$ADDRESS:$2[ 	].*LISTEN" -e ":::$2[ 	].*LISTEN" )
		test -n "$LISTENING"
		return $?
}




function getAdminServer() {
  server=$(grep 'admin-server-name' $DOMAIN_CONFIG |sed -r 's/.*>(.+)<.*/\1/')
  address=$(grep -A4 "$server" $DOMAIN_CONFIG |grep 'listen-address' |sed -r 's/.*>(.+)<.*/\1/')
  port=$(grep -B2 "$address" $DOMAIN_CONFIG |grep 'port' |sed -r 's/.*>(.+)<.*/\1/')
  echo "$server" "$address" "$port"
}

function listAllServers() {
adminServer=$(grep 'admin-server-name' $DOMAIN_CONFIG |sed -r 's/.*>(.+)<.*/\1/')
server=$(grep -A1 '<server>' $DOMAIN_CONFIG |grep "name" |grep -v "$adminServer" |sed -r 's/.*>(.+)<.*/\1/')
for n in $server
do
   address=$(grep -A7 $n $DOMAIN_CONFIG |grep "listen-address" | sed -r 's/.*>(.+)<.*/\1/')
   port=$(grep -A1 "$n" $DOMAIN_CONFIG |grep 'port' |sed -r 's/.*>(.+)<.*/\1/')
   echo "$n" "$address" "$port"
done
}

function startAllServers() {
	result=0
	listAllServers | \
	while read LINE ; do
		startServer $LINE
		[ $? -ne 0 ] && result=1
	done
	return $result
}


function startServer() {
  if onThisHost $2 ; then
        if listenerOnPort $2 ${3:-7001} ; then
                echo "INFO: Server $1 of domain $DOMAIN is already running."
        else
                echo -n "INFO: starting $1 of domain $DOMAIN"
                StartWebLogic $@
        fi
  fi
}


function StartWebLogic() {
	#JAVA_OPTIONS=$()
	#export JAVA_OPTIONS
	ADMINSERVERINFO=$(getAdminServer)
	DMINSERVERINFO=$(listAllServers)
	ADMIN_NAME=$(echo $ADMINSERVERINFO | awk '{print $1}')
	ADMIN_HOST=$(echo $ADMINSERVERINFO | awk '{print $2}')
	ADMIN_PORT=$(echo $ADMINSERVERINFO | awk '{print $3}')
        #echo "$ADMINSERVERINFO"
        #echo "$DMINSERVERINFO"
        #echo "$ADMIN_NAME"
        #echo "$ADMIN_HOST"
        #echo "$ADMIN_PORT"
        echo $ADMIN_NAME
	if [ "$ADMIN_NAME" = "$1" ] ; then
		nohup $DOMAIN_HOME/startWebLogic.sh >/dev/null 2>&1 &
	else
		nohup $DOMAIN_HOME/bin/startManagedWebLogic.sh $1 $ADMIN_HOST:$ADMIN_PORT >/dev/null 2>&1 &
	fi
} 


function stopDomain() {
	stopAllServers
	stopServer $(getAdminServer)
}


function startDomain() {
	startServer $(getAdminServer)
	startAllServers
}

if [ "$COMMAND" = "stop" ] ; then

	for domain in $(allDomains) ; do
		if DomainConfig $domain; then
			stopDomain
		fi
	done
fi


if [ "$COMMAND" = "start" ]; then
	for domain in $(allDomains) ; do
		if DomainConfig $domain ; then
			startDomain
		fi
	done
fi


#startServer AdminServer 192.168.91.132 8000
