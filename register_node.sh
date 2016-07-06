#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger node control center
# Author: Siriwat K.
# Created: 21 June 2016
# # # # # # # # # # # # # # # # # # # #

debug_level=ERROR
# CRITICAL | ERROR | WARNING | NOTICE | INFO | DEBUG

function display_usage {
     echo -e "Usage"
     echo -e "   $0 location pnode_no lnode_no role consensus prefix"
     echo -e "Parameters:"
     echo -e "   location    Running node on either \"vm\", \"jnx\", or \"dev\"."
     echo -e "   pnode_no    Physical node number."
     echo -e "   lnode_no    Logical node number."
     echo -e "   role        Node role either \"rest\", \"validator\", \"mixed\"."
     echo -e "   consensus   Mode of consensus either \"noops\" or \"pbft\"."
     echo -e "   prefix      Node prefix."
     exit
}

############## Parameters ##############
location=$1
pnode_no=$2
lnode_no=$3
role=$4
consensus=$5
############## Optional ##############
prefix=$6

if [ -z "$location" ]
     then
     echo "Please specify where to launch the command either \"vm\", \"jnx\", or \"dev\"."
     display_usage
fi

# Domain name construction
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

# Node number
if [ -z "$pnode_no" ]
     then
     echo "Please specify a physical node number"
     display_usage
fi

if [ -z "$lnode_no" ]
     then
     echo "Please specify a logical node number"
     display_usage
fi

# Dynamic port
PORT_REST="500${lnode_no}"
PORT_CLI="303${lnode_no}4"
PORT_GRPC_ROOT="30303"
PORT_GRPC="303${lnode_no}3"
PORT_VALIDATOR="$((31315+lnode_no))"
#PORT_PKI=50051
#PORT_PROFILE=6060

# ROOT node
rootnode_params=""
if [[ $pnode_no -gt 0 ]] || [[ $lnode_no -gt 0 ]]
     then
     rootnode_params="-e CORE_PEER_DISCOVERY_ROOTNODE=${names[0]}${domain}:${PORT_GRPC_ROOT}"
fi

# PEER parameters
local_address=${names[pnode_no]}${domain}
peer_params="-e CORE_CLI_ADDRESS=${local_address}:${PORT_CLI} \
               -e CORE_PEER_LISTENADDRESS=0.0.0.0:${PORT_GRPC} \
               -e CORE_PEER_ADDRESS=${local_address}:${PORT_GRPC} \
               -e CORE_PEER_PORT=${PORT_GRPC} \
               -e CORE_PEER_ID=vp${pnode_no}${lnode_no} \
               -e CORE_PEER_SYNC_BLOCKS_CHANNELSIZE=100 \
               -e CORE_PEER_SYNC_STATE_SNAPSHOT_CHANNELSIZE=500 \
               -e CORE_PEER_SYNC_STATE_DELTAS_CHANNELSIZE=200"

# Role
role_params=""
if [ "$role" == "rest" ]
     then
     # REST should not be run with Validator node
     role_params="-e CORE_REST_ENABLED=true \
                    -e CORE_PEER_VALIDATOR_ENABLED=false \
                    -e CORE_REST_ADDRESS=0.0.0.0:${PORT_REST}"
elif [ "$role" == "validator" ]
     then
     # Validator node should not run REST
     role_params="-e CORE_REST_ENABLED=false \
                    -e CORE_PEER_VALIDATOR_ENABLED=true \
                    -e CORE_PEER_VALIDATOR_EVENTS_ADDRESS=0.0.0.0:${PORT_VALIDATOR}"
elif [ "$role" == "mixed" ]
     then
     # Mixed between REST and Validator
     role_params="-e CORE_REST_ENABLED=true \
                    -e CORE_REST_ADDRESS=0.0.0.0:${PORT_REST} \
                    -e CORE_PEER_VALIDATOR_ENABLED=true \
                    -e CORE_PEER_VALIDATOR_EVENTS_ADDRESS=0.0.0.0:${PORT_VALIDATOR}"
else
     echo "Invalid role value."
     exit
fi

# Consensus params construction
consensus_params=""
image_name=""
if [ "$consensus" == "noops" ]
     then
     # NOOPS
     echo -e "..NOOPS.."
     consensus="noops"
     consensus_params="-e CORE_PEER_VALIDATOR_CONSENSUS_PLUGIN=noops \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_BUFFERSIZE=7500 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_EVENTS_BUFFERSIZE=1000 \
                         -e CORE_NOOPS_BLOCK_SIZE=1 \
                         -e CORE_NOOPS_BLOCK_TIMEOUT=1s "
     image_name="stylix/hyperledger-peer:noops"
elif [ "$consensus" == "pbft" ]
     then
     # PBFT
     echo -e "..PBFT.."
     consensus_params="-e CORE_PEER_VALIDATOR_CONSENSUS_PLUGIN=pbft \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_BUFFERSIZE=7500 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_EVENTS_BUFFERSIZE=1000 \
                         -e CORE_PBFT_GENERAL_N=4 \
                         -e CORE_PBFT_GENERAL_K=2 \
                         -e CORE_PBFT_GENERAL_TIMEOUT_REQUEST=10s \
                         -e CORE_PBFT_GENERAL_MODE=classic "
     image_name="stylix/hyperledger-peer:pbft"
else
     echo "Invalid consensus value."
     exit
fi

# Container name prefix
udl=""
if [ ! -z "$prefix" ]
     then
     udl="_"
fi

# Node startup
docker run --rm --name=${prefix}${udl}vp${pnode_no}${lnode_no} \
          -it \
          -p ${PORT_REST}:${PORT_REST} \
          -p ${PORT_GRPC}:${PORT_GRPC} \
          -p ${PORT_CLI}:${PORT_CLI} \
          -p ${PORT_VALIDATOR}:${PORT_VALIDATOR} \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v /hyperledger/db/${lnode_no}:/var/hyperledger/db \
          -v /hyperledger/production/${lnode_no}:/var/hyperledger/production \
          -v /hyperledger/chaincode:/var/hyperledger/chaincode \
          -v /hyperledger/chaincode:/go/src/chaincode \
          -v /hyperledger/compose:/var/hyperledger/compose \
          -v /hyperledger/compose/net_host_.bashrc:/root/.bashrc \
          ${rootnode_params} \
          ${peer_params} \
          ${role_params} \
          ${consensus_params} \
          -e CORE_SECURITY_ENABLED=false \
          -e CORE_LOGGING_LEVEL=${debug_level} \
          ${image_name} peer node start

