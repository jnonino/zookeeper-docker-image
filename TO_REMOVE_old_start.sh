#!/bin/bash

NODE_ID=$(cat /var/lib/dbus/machine-id | sed 's/[^0-9]*//g')

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
