#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger node control center
# Author: Siriwat K.
# Created: 21 June 2016
# # # # # # # # # # # # # # # # # # # #

regist_cmd="/hyperledger/hyper_cc/register_node.sh"

function display_usage {
     echo -e "Usage"
     echo -e "   $0 location deploy_pattern consensus prefix"
     echo -e "Parameters:"
     echo -e "   location        Running node on either \"vm\", \"jnx\", or \"dev\"."
     echo -e "   deploy_pattern  The pattern [d-p-v-n] of the node deployment."
     echo -e "        d  --      Deploy type pattern [p] or specific [s]."
     echo -e "        p  --      Number of host to deploy."
     echo -e "        v  --      Number of validator node."
     echo -e "        n  --      Number of non-validator node."
     echo -e "                   e.g. p-4-4-0  Create 16 nodes on 4 hosts with 4 validator nodes each."
     echo -e "                        p-4-2-1  Create 12 nodes on 4 hosts with 2 validator nodes"
     echo -e "                                 and 1 non-validator node each."
     echo -e "                        s-9-1-0  Create a specific node on the 9th host, with the 1st node"
     echo -e "                                 as a validator node."
     echo -e "                        s-2-3-1  Create a specific node on the 2nd host, with the 3rd node"
     echo -e "                                 as a non-validator node."
     echo -e "   consensus       Mode of consensus either \"noops\" or \"pbft\"."
     echo -e "   prefix          Node prefix."
     exit
}

############## Parameters ##############
location=$1
deploy_pattern=$2
consensus=$3
############## Optional ##############
prefix=$4


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

if [ -z "$deploy_pattern" ]
     then
     echo "Please specify the deploy pattern as d-p-v-n"
     display_usage
fi

# Extract deploy pattern
deploy_pattern_array=(${deploy_pattern//-/ })
deploy_type=${deploy_pattern_array[0]}  # d - Deploy type
total_pnode=${deploy_pattern_array[1]}   # p - Total physical node
total_vnode=${deploy_pattern_array[2]}  # v - Total validator node
total_nvnode=${deploy_pattern_array[3]} # n - Total non-validator node
if [ -z "$deploy_type" ] || [ -z "$total_pnode" ] || [ -z "$total_vnode" ] || [ -z "$total_nvnode" ]
     then
     echo "Incorrectly specify a deploying pattern."
     echo "Please specify the deploy pattern as d-p-v-n."
     display_usage
fi

# Consensus
if [ "$consensus" != "noops" ] && [ "$consensus" != "pbft" ]
     then
     echo "Invalid consensus value."
     exit
fi

# Container name prefix
udl=""
if [ ! -z "$prefix" ]
     then
     udl="_"
fi

# Deploying all nodes
if [ "$deploy_type" == "p" ]
     then
     pidx=0    # Physical node index

     # regist_cmd location pnode_no lnode_no role consensus prefix

     # Physical host runner
     while [[ $pidx -lt $total_pnode ]]; do
          vidx="0"    # Validator node index
          nidx="0"    # Non-validator node index


          # Root node start first
          if [[ $pidx -eq 0 ]] && [[ $vidx -eq 0 ]]
               then               
               printf "Starting.. ${names[pidx]}${domain}:${prefix}${udl}vp${pidx}${vidx} ..as root.."
               ssh ${names[pidx]}${domain} screen -d -m -S ${prefix}${udl}HyperNode$((pidx+1))$((vidx+1))_root ${regist_cmd} ${location} ${pidx} ${vidx} "mixed" ${consensus} ${prefix}
               echo "done!"
               # Root node is a kind of a validator node
               # Next validator node
               ((vidx++))
          fi

          # Paralling child node later
          # Validator node runner (REST + Validator)
          while [[ $vidx -lt $total_vnode ]]; do
               #ssh node01.bc.ssd.dev.fu screen -d -m -S HyperNode01 /hyperledger/compose/register_node.sh 0; screen -r Hyper
               printf "Starting.. ${names[pidx]}${domain}:${prefix}${udl}vp${pidx}${vidx} ..as validator.."
               ssh ${names[pidx]}${domain} screen -d -m -S ${prefix}${udl}HyperNode$((pidx+1))$((vidx+1))_mixed ${regist_cmd} ${location} ${pidx} ${vidx} "mixed" ${consensus} ${prefix} &
               echo "done!"
               
               # Next validator node
               ((vidx++))
          done

          # Paralling child node later
          # Non-validator node runner (REST)
          while [[ $nidx -lt $total_nvnode ]]; do
               #ssh node01.bc.ssd.dev.fu screen -d -m -S HyperNode01 /hyperledger/compose/register_node.sh 0; screen -r Hyper
               printf "Starting.. ${names[pidx]}${domain}:${prefix}${udl}vp${pidx}$((vidx+nidx)) ..as rest.."
               ssh ${names[pidx]}${domain} screen -d -m -S ${prefix}${udl}HyperNode$((pidx+1))$((vidx+nidx+1))_rest ${regist_cmd} ${location} ${pidx} $((vidx+nidx)) "rest" ${consensus} ${prefix} &
               echo "done!"
               # Next non-validator node
               ((nidx++))
          done

          # Next host
          ((pidx++))
     done

# Deploying specific node
elif [ "$deploy_type" == "s" ]
     then
     pidx=$((total_pnode-1))
     vidx=$((total_vnode-1))

     # Check if non-validator node
     role="mixed"
     if [ "$total_nvnode" == "1" ]
          then
          role="rest"
     fi

     printf "Starting.. ${names[pidx]}${domain}:${prefix}${udl}vp${pidx}${vidx} ..as ${role}.."
     ssh ${names[pidx]}${domain} screen -d -m -S ${prefix}${udl}HyperNode$((pidx+1))$((vidx+1))_${role} ${regist_cmd} ${location} ${pidx} ${vidx} ${role} ${consensus} ${prefix}
     echo "done!"
else
     echo "Invalid deploy type."
     exit
fi
