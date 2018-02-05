#!/bin/bash

ID="$(cat /var/lib/dbus/machine-id)" 

#OLD_HOSTNAME="$(hostname)"
#NEW_HOSTNAME="zookeeper-$OLD_HOSTNAME"
#sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname
#sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
#hostname $NEW_HOSTNAME

HOSTNAME="$(hostname)"

DEFAULT_IF="$(ip route list | awk '/^default/ {print $5}')"
IPADDRESS="$(ifconfig | grep -A 1 $DEFAULT_IF | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
CIDR="$(ip -o -f inet addr show $DEFAULT_IF | awk '{print $4}')"

NETWORK_HOSTS=( $(nbtscan $CIDR | awk '{print $2}') )
ZOOKEEPER_HOSTS=()
for (( i=0; i<${#NETWORK_HOSTS[@]}; i++ )); 
do 
    if (echo stat | nc ${NETWORK_HOSTS[i]} 2181) ; then
        echo "Host ${NETWORK_HOSTS[i]} IS Running Zookeeper"
        ZOOKEEPER_HOSTS+=(${NETWORK_HOSTS[i]})
    else
        echo "Host ${NETWORK_HOSTS[i]} IS NOT Running Zookeeper"
    fi
done

cd /opt/zookeeper

ZK=$1
if [ -n "$ZK" ] 
then
    echo "`zkCli.sh -server $ZK:2181 get /zookeeper/config | grep ^server`" >> /opt/zookeeper/conf/zoo.cfg.dynamic
    echo "server.$ID=$IPADDRESS:2888:3888:observer;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
    cp /opt/zookeeper/conf/zoo.cfg.dynamic /opt/zookeeper/conf/zoo.cfg.dynamic.org
    zkServer-initialize.sh --force --myid=$ID
    ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' zkServer.sh start
    zkCli.sh -server $ZK:2181 reconfig -add "server.$ID=$IPADDRESS:2888:3888:participant;2181"
    zkServer.sh stop
    ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' zkServer.sh start-foreground
else
    echo "server.$ID=$IPADDRESS:2888:3888;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
    zkServer-initialize.sh --force --myid=$ID
    ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' zkServer.sh start-foreground
fi


