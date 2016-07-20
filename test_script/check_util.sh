#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger node CPU,mem,net,storage check
# Author: Siriwat K.
# Created: 24 June 2016
# # # # # # # # # # # # # # # # # # # #

node_name=$1
count=$2
mode=$3
inet=$4
port=$5
sleep_time=0

if [ -z "$node_name" ]
  then
  echo "Usage $0 node_name count docker|real network_interrface [sleep_time]"
  echo "Please specify a node_name"
  exit
fi  

if [ -z "$count" ]
  then
  echo "Usage $0 node_name count docker|real network_interrface [sleep_time]"
  echo "Please specify a number of time"
  exit
fi

if [ -z "$mode" ]
  then
  echo "Usage $0 node_name count docker|real network_interrface [sleep_time]"
  echo "Please specify a running mode docker|real"
  exit
fi

if [ -z "$inet" ]
  then
  echo "Usage $0 node_name count docker|real network_interrface [sleep_time]"
  echo "Please specify a network_interrface"
  exit
fi

if [ -z "$port" ]
  then
  echo "Please specify a listening REST port."
  exit
fi

if [ ! -z "$6" ]
  then
  sleep_time=$6
fi

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Time\t\tBlock\tCPU (%)\tMem (KB)\tDisk\tNet-in (byte)\tNet-out (byte)${NC}"

idx=0
while [[ $idx -lt $count ]];
  do
    block=`/hyperledger/hyper_cc/test_script/get_block_height.sh ${port}`

    # Dedicated node mode
    if [ "$mode" == "real" ]
      then
      peer_pid=`docker exec ${node_name} pidof peer`
      cpu=`docker exec ${node_name} ps -p ${peer_pid} -o %cpu | tail -1`
      mem=`docker exec ${node_name} ps -p ${peer_pid} -o size | tail -1`
    # Docker mode -- sum it up
    else
      cpu=`ps u -C peer | awk '{sum += $3} END {print sum}'`
      mem=`ps u -C peer | awk '{sum += $5} END {print sum}'`
    fi
	
	disk=`docker exec ${node_name} du -h /var/hyperledger/production/ | tail -1 | cut -f 1`
	net=`bwm-ng -o csv -T rate -d 1 -c 1 -I ${inet} > bwm.log; cat bwm.log | grep ${inet} | cut -d ";" -f 3,4 | sed 's/;/\t\t/g'`
	printf "$(date +"%T")\t${block}\t${cpu}\t${mem}\t\t${disk}\t${net}\n"

  sleep $sleep_time
  ((idx++))
done
