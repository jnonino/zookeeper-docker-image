#!/bin/bash

DEFAULT_IF="$(ip route list | awk '/^default/ {print $5}')"
IP_ADDRESS="$(ifconfig | grep -A 1 $DEFAULT_IF | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
CIDR="$(ip -o -f inet addr show $DEFAULT_IF | awk '{print $4}')"
NODE_ID=$(echo $IP_ADDRESS | sed 's/[^0-9]*//g')

# TODO
# Look for another host in the network that runs zookeeper and add its IP to OTHER_ZK_NODE variable
    #NETWORK_HOSTS=( $(nbtscan $CIDR | awk '{print $1}') )

# Example node1:2181 or node2:2182
OTHER_ZK_NODE=$1

if [ -n "$OTHER_ZK_NODE" ] 
then
    echo "Other hosts localized, starting this Zookeeper as a cluster node"    
    # Fetch other nodes configurations
    echo "`zkCli.sh -server $OTHER_ZK_NODE get /zookeeper/config | grep ^server`" >> /opt/zookeeper/conf/zoo.cfg.dynamic
    # Add this node as an observer to the cluster
    echo "server.$NODE_ID=$IP_ADDRESS:2888:3888:observer;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
    cp /opt/zookeeper/conf/zoo.cfg.dynamic /opt/zookeeper/conf/zoo.cfg.dynamic.org
    # Initialize and start server
    zkServer-initialize.sh --force --myid=$NODE_ID
    zkServer.sh start
    # Ask the cluster to reconfigure with this node as participant
    zkCli.sh -server $OTHER_ZK_NODE reconfig -add "server.$NODE_ID=$IP_ADDRESS:2888:3888:participant;2181"
    # Restart the server
    zkServer.sh stop
    zkServer.sh start-foreground
else
    echo "No other host localized, starting the first Zookeeper node"
    # Add this node to cluster configuration
    echo "server.$NODE_ID=$IP_ADDRESS:2888:3888;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
    # Initialize and start server
    zkServer-initialize.sh --force --myid=$NODE_ID
    zkServer.sh start-foreground
fi