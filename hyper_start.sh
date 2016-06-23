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
regist_cmd="/hyperledger/hyper_cc/register_node.sh"
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
          #ssh node01.bc.ssd.dev.fu screen -d -m -S HyperNode01 /hyperledger/compose/register_node.sh 0; screen -r Hyper
          printf "Starting.. node0$((idx+1)).bc.ssd.dev.fu:${prefix}${udl}vp${idx} .."
          ssh node0$((idx+1))${domain} screen -d -m -S ${prefix}${udl}HyperNode0$((idx+1)) $regist_cmd $idx ${prefix}
          echo "done!"
          ((idx++))
     done

# Specific node
else
     total_node=$((total_node*-1))
     printf "Starting.. node0${total_node}.bc.ssd.dev.fu:${prefix}${udl}vp$((total_node-1)) .."
     ssh node0${total_node}${domain} screen -d -m -S ${prefix}${udl}HyperNode0${total_node} $regist_cmd $((total_node-1)) ${prefix}
     echo "done!"
fi
