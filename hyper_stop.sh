#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger node control center
# Author: Siriwat K.
# Created: 21 June 2016
# # # # # # # # # # # # # # # # # # # #

total_node=$1

     if [ -z "$total_node" ]
          then
          echo "Usage $0 total_node"
          echo "Please specify the total number of node"
          exit
     fi     

cd /hyperledger/compose/configuration
domain=".bc.ssd.dev.fu"

# Container name prefix
prefix=""
udl=""
if [ ! -z "$2" ]
     then
     prefix="$2"
     udl="_"
fi

# Node range
if [ $total_node -gt 0 ]; then
	idx=0
	while [ $idx -lt $total_node ]; do
	     #ssh node01.bc.ssd.dev.fu docker stop prefix_vp0
	     printf "Stopping.. node0$((idx+1)).bc.ssd.dev.fu:.."
	     ssh node0$((idx+1))${domain} docker stop ${prefix}${udl}vp${idx}
	     printf "Removing.. node0$((idx+1)).bc.ssd.dev.fu:.."
	     ssh node0$((idx+1))${domain} docker rm ${prefix}${udl}vp${idx}
	     ((idx++))
	done

# Specific node
else
     total_node=$((total_node*-1))
     printf "Stopping.. node0${total_node}.bc.ssd.dev.fu:.."
     ssh node0${total_node}${domain} docker stop ${prefix}${udl}vp$((total_node-1))
     printf "Removing.. node0${total_node}.bc.ssd.dev.fu:.."
     ssh node0${total_node}${domain} docker rm ${prefix}${udl}vp$((total_node-1))
     echo "done!"
fi
