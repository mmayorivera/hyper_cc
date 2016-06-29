#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger node control center
# Author: Siriwat K.
# Created: 21 June 2016
# # # # # # # # # # # # # # # # # # # #

total_node=$1
location=$2

if [ -z "$total_node" ]
     then
     echo "Usage $0 total_node location [node_prefix] [consensus_mode]"
     echo "Please specify the total number of node"
     exit
fi     

if [ -z "$location" ]
     then
     echo "Usage $0 total_node location [node_prefix] [consensus_mode]"
     echo "Please specify where to launch the command"
     exit
fi     

cd /hyperledger/compose/configuration
regist_cmd="/hyperledger/hyper_cc/register_node.sh"

# Domain name configuration
domain=""
names[0]="NA"
if [ "$location" == "vm" ]
     then
     domain=".bc.ssd.dev.fu"
     names[0]="node01"
     names[1]="node02"
     names[2]="node03"
     names[3]="node04"
     names[4]="node05"
     names[5]="node06"
     names[6]="node07"
     names[7]="node08"
     names[8]="node09"
     names[9]="node10"
     names[10]="node11"
     names[11]="node12"
     names[12]="node13"
     names[13]="node14"
     names[14]="node15"
     names[15]="node16"
     names[16]="node17"
     names[17]="node18"
     names[18]="node19"
     names[19]="node20"
elif [ "$location" == "jnx" ]
     then
     domain=".tk.japannext.co.jp"    
     names[0]="dmihadoopctr01"
     names[1]="dmihadoopctr02" 
     names[2]="dmihadoopstr01"
     names[3]="dmihadoopstr02"
fi

# Container name prefix
prefix=""
udl=""
if [ ! -z "$3" ]
     then
     prefix="$3"
     udl="_"
fi

# Consensus
consensus=""
if [ ! -z "$4" ]
     then
     consensus="$4"
fi

# Node range
if [ $total_node -gt 0 ]
     then     
     idx=0

     # Root node start first
     printf "Starting.. ${names[idx]}${domain}:${prefix}${udl}vp${idx} .."
     ssh ${names[idx]}${domain} screen -d -m -S ${prefix}${udl}HyperNode0$((idx+1)) ${regist_cmd} ${idx} ${location} ${prefix} ${consensus}
     echo "done!"
     ((idx++))

     # Paralling child node later
     while [ $idx -lt $total_node ]; do
          #ssh node01.bc.ssd.dev.fu screen -d -m -S HyperNode01 /hyperledger/compose/register_node.sh 0; screen -r Hyper
          printf "Starting.. ${names[idx]}${domain}:${prefix}${udl}vp${idx} .."
          ssh ${names[idx]}${domain} screen -d -m -S ${prefix}${udl}HyperNode0$((idx+1)) ${regist_cmd} ${idx} ${location} ${prefix} ${consensus} &
          echo "done!"
          ((idx++))
     done

# Specific node
else
     total_node=$((total_node*-1))
     printf "Starting.. ${names[total_node-1]}${domain}:${prefix}${udl}vp$((total_node-1)) .."
     ssh ${names[total_node-1]}${domain} screen -d -m -S ${prefix}${udl}HyperNode0${total_node} ${regist_cmd} $((total_node-1)) ${location} ${prefix} ${consensus}
     echo "done!"
fi
