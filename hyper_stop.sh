#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger node control center
# Author: Siriwat K.
# Created: 21 June 2016
# # # # # # # # # # # # # # # # # # # #

regist_cmd="/hyperledger/hyper_cc/register_node.sh"

function display_usage {
     echo -e "Usage"
     echo -e "   $0 location stop_pattern prefix"
     echo -e "Parameters:"
     echo -e "   location        Running node on either \"vm\", \"jnx\", or \"dev\"."
     echo -e "   stop_pattern    The pattern [d-p-l] of stopping node."
     echo -e "        d  --      Stop type pattern [p] or specific [s]."
     echo -e "        p  --      Number of physical host to be stopped."
     echo -e "        l  --      Number of logical node to be stopped."
     echo -e "                   e.g. p-4-4  Stop 16 nodes on 4 hosts with 4 nodes each."
     echo -e "                        p-4-2  Stop 8 nodes on 4 hosts with 2 nodes each."
     echo -e "                        s-9-3  Stop a specific 3rd node on the 9th host."
     echo -e "                        s-2-1  Stop a specific 1st node on the 2nd host."
     echo -e "   prefix          Node prefix."
     exit
}

############## Parameters ##############
location=$1
stop_pattern=$2
############## Optional ##############
prefix=$3 


if [ -z "$location" ]
     then
     echo "Please specify where to launch the command either \"vm\", \"jnx\", or \"dev\"."
     display_usage
fi

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
elif [ "$location" == "dev" ]
     then
     domain=".bc.ssd.dev.fu"    
     names[0]="dev01"
     names[1]="dev02"
else
     echo "Invalid location value."
     exit
fi

if [ -z "$stop_pattern" ]
     then
     echo "Please specify the stop pattern as d-p-l"
     display_usage
fi 

# Extract stop pattern
stop_pattern_array=(${stop_pattern//-/ })
stop_type=${stop_pattern_array[0]}    # d - Stop type
total_pnode=${stop_pattern_array[1]}  # p - Total physical node
total_lnode=${stop_pattern_array[2]}  # l - Total logical node
if [ -z "$stop_type" ] || [ -z "$total_pnode" ] || [ -z "$total_lnode" ]
     then
     echo "Incorrectly specify a stop pattern."
     echo "Please specify the stop pattern as d-p-l."
     display_usage
fi

# Container name prefix
udl=""
if [ ! -z "$prefix" ]
     then
     udl="_"
fi

# Stopping all nodes
if [ "$stop_type" == "p" ]
     then
     pidx=0    # Physical node index

     # Physical host runner
     while [[ $pidx -lt $total_pnode ]]; do
          lidx="0"    # Logical node index

     	while [[ $lidx -lt $total_lnode ]]; do
     	     #ssh node01.bc.ssd.dev.fu docker stop prefix_vp0
     	     printf "Stopping.. ${names[pidx]}${domain}:.."
     	     ssh ${names[pidx]}${domain} docker stop ${prefix}${udl}vp${pidx}${lidx}
     	     printf "Removing.. ${names[pidx]}${domain}:.."
     	     ssh ${names[pidx]}${domain} docker rm ${prefix}${udl}vp${pidx}${lidx}
     	     
               # Next logical node
               ((lidx++))
     	done

          # Next host
          ((pidx++))
     done

# Stopping specific node
elif [ "$stop_type" == "s" ]
     then
     pidx=$((total_pnode-1))
     lidx=$((total_vnode-1))

     printf "Stopping.. ${names[pidx]}${domain}:.."
     ssh ${names[total_node-1]}${domain} docker stop ${prefix}${udl}vp${pidx}${lidx}
     printf "Removing.. ${names[pidx]}${domain}:.."
     ssh ${names[total_node-1]}${domain} docker rm ${prefix}${udl}vp${pidx}${lidx}
     echo "done!"
else
     echo "Invalid deploy type."
     exit
fi
