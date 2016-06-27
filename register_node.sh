#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger node control center
# Author: Siriwat K.
# Created: 21 June 2016
# # # # # # # # # # # # # # # # # # # #

debug_level=ERROR
node_no=$1
location=$2

if [ -z "$node_no" ]
     then
     echo "Usage $0 node_no location"
     echo "Please specify a node number"
     exit
fi     

if [ -z "$location" ]
     then
     echo "Usage $0 node_no location"
     echo "Please specify where to launch the command"
     exit
fi     

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
elif [ "$location" == "jnx" ]
     then
     domain=".tk.japannext.co.jp"     
     names[0]="dmihadoopstr01"
     names[1]="dmihadoopstr02"
     names[2]="dmihadoopctr01"
     names[3]="dmihadoopctr02"
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

cd /hyperledger/compose/configuration

# ROOT node
if [ $node_no -eq 0 ]
     then
     if [ "$consensus" == "pbft" ]
          then
          # Consensus PBFT mode
          echo -e "..NOOPS.."
          docker run --rm --name=${prefix}${udl}vp${node_no} \
                         -it \
                         --net=host \
                         -p 5000:5000 \
                         -p 30303:30303 \
                         -p 30304:30304 \
                         -p 31315:31315 \
                         -v /var/run/docker.sock:/var/run/docker.sock \
                         -v /hyperledger/db:/var/hyperledger/db \
                         -v /hyperledger/production:/var/hyperledger/production \
                         -v /hyperledger/chaincode:/var/hyperledger/chaincode \
                         -v /hyperledger/chaincode:/go/src/chaincode \
                         -v /hyperledger/compose:/var/hyperledger/compose \
                         -v /hyperledger/compose/net_host_.bashrc:/root/.bashrc \
                         -e CORE_PEER_ID=vp${node_no} \
                         -e CORE_PEER_ADDRESSAUTODETECT=true \
                         -e CORE_PEER_SYNC_BLOCKS_CHANNELSIZE=100 \
                         -e CORE_PEER_SYNC_STATE_SNAPSHOT_CHANNELSIZE=500 \
                         -e CORE_PEER_SYNC_STATE_DELTAS_CHANNELSIZE=200 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_PLUGIN=pbft \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_BUFFERSIZE=7500 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_EVENTS_BUFFERSIZE=1000 \
                         -e CORE_PBFT_GENERAL_N=4 \
                         -e CORE_PBFT_GENERAL_K=2 \
                         -e CORE_PBFT_GENERAL_TIMEOUT_REQUEST=10s \
                         -e CORE_PBFT_GENERAL_MODE=classic \
                         -e CORE_SECURITY_ENABLED=false \
                         -e CORE_LOGGING_LEVEL=${debug_level} \
                         stylix/hyperledger-peer:pbft peer node start
     else
          # Consensus NOOPS mode
          echo -e "..NOOPS.."
          docker run --rm --name=${prefix}${udl}vp${node_no} \
                         -it \
                         --net=host \
                         -p 5000:5000 \
                         -p 30303:30303 \
                         -p 30304:30304 \
                         -p 31315:31315 \
                         -v /var/run/docker.sock:/var/run/docker.sock \
                         -v /hyperledger/db:/var/hyperledger/db \
                         -v /hyperledger/production:/var/hyperledger/production \
                         -v /hyperledger/chaincode:/var/hyperledger/chaincode \
                         -v /hyperledger/chaincode:/go/src/chaincode \
                         -v /hyperledger/compose:/var/hyperledger/compose \
                         -v /hyperledger/compose/net_host_.bashrc:/root/.bashrc \
                         -e CORE_PEER_ID=vp${node_no} \
                         -e CORE_PEER_ADDRESSAUTODETECT=true \
                         -e CORE_PEER_SYNC_BLOCKS_CHANNELSIZE=100 \
                         -e CORE_PEER_SYNC_STATE_SNAPSHOT_CHANNELSIZE=500 \
                         -e CORE_PEER_SYNC_STATE_DELTAS_CHANNELSIZE=200 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_PLUGIN=noops \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_BUFFERSIZE=7500 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_EVENTS_BUFFERSIZE=1000 \
                         -e CORE_NOOPS_BLOCK_SIZE=1 \
                         -e CORE_NOOPS_BLOCK_TIMEOUT=1s \
                         -e CORE_SECURITY_ENABLED=false \
                         -e CORE_LOGGING_LEVEL=${debug_level} \
                         stylix/hyperledger-peer:noops peer node start
     fi
# Child node
else
     if [ "$consensus" == "pbft" ]
          then
          # Consensus PBFT mode
          echo -e "..NOOPS.."
          docker run --rm --name=${prefix}${udl}vp${node_no} \
                         -it \
                         --net=host \
                         -p 5000:5000 \
                         -p 30303:30303 \
                         -p 30304:30304 \
                         -p 31315:31315 \
                         -v /var/run/docker.sock:/var/run/docker.sock \
                         -v /hyperledger/db:/var/hyperledger/db \
                         -v /hyperledger/production:/var/hyperledger/production \
                         -v /hyperledger/chaincode:/var/hyperledger/chaincode \
                         -v /hyperledger/chaincode:/go/src/chaincode \
                         -v /hyperledger/compose:/var/hyperledger/compose \
                         -v /hyperledger/compose/net_host_.bashrc:/root/.bashrc \
                         -e CORE_PEER_ID=vp${node_no} \
                         -e CORE_PEER_ADDRESSAUTODETECT=true \
                         -e CORE_PEER_SYNC_BLOCKS_CHANNELSIZE=100 \
                         -e CORE_PEER_SYNC_STATE_SNAPSHOT_CHANNELSIZE=500 \
                         -e CORE_PEER_SYNC_STATE_DELTAS_CHANNELSIZE=200 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_PLUGIN=pbft \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_BUFFERSIZE=7500 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_EVENTS_BUFFERSIZE=1000 \
                         -e CORE_PEER_DISCOVERY_ROOTNODE=${names[0]}${domain}:30303\
                         -e CORE_PBFT_GENERAL_N=4 \
                         -e CORE_PBFT_GENERAL_K=2 \
                         -e CORE_PBFT_GENERAL_TIMEOUT_REQUEST=10s \
                         -e CORE_PBFT_GENERAL_MODE=classic \
                         -e CORE_SECURITY_ENABLED=false \
                         -e CORE_LOGGING_LEVEL=${debug_level} \
                         stylix/hyperledger-peer:pbft peer node start
     else
          # Consensus NOOPS mode
          echo -e "..NOOPS.."
          docker run --rm --name=${prefix}${udl}vp${node_no} \
                         -it \
                         --net=host \
                         -p 5000:5000 \
                         -p 30303:30303 \
                         -p 30304:30304 \
                         -p 31315:31315 \
                         -v /var/run/docker.sock:/var/run/docker.sock \
                         -v /hyperledger/db:/var/hyperledger/db \
                         -v /hyperledger/production:/var/hyperledger/production \
                         -v /hyperledger/chaincode:/var/hyperledger/chaincode \
                         -v /hyperledger/chaincode:/go/src/chaincode \
                         -v /hyperledger/compose:/var/hyperledger/compose \
                         -v /hyperledger/compose/net_host_.bashrc:/root/.bashrc \
                         -e CORE_PEER_ID=vp${node_no} \
                         -e CORE_PEER_ADDRESSAUTODETECT=true \
                         -e CORE_PEER_SYNC_BLOCKS_CHANNELSIZE=100 \
                         -e CORE_PEER_SYNC_STATE_SNAPSHOT_CHANNELSIZE=500 \
                         -e CORE_PEER_SYNC_STATE_DELTAS_CHANNELSIZE=200 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_PLUGIN=noops \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_BUFFERSIZE=7500 \
                         -e CORE_PEER_VALIDATOR_CONSENSUS_EVENTS_BUFFERSIZE=1000 \
                         -e CORE_PEER_DISCOVERY_ROOTNODE=${names[0]}${domain}:30303\
                         -e CORE_NOOPS_BLOCK_SIZE=1 \
                         -e CORE_NOOPS_BLOCK_TIMEOUT=1s \
                         -e CORE_SECURITY_ENABLED=false \
                         -e CORE_LOGGING_LEVEL=${debug_level} \
                         stylix/hyperledger-peer:noops peer node start
     fi
fi
