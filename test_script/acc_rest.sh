#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger account creating test
# Author: Siriwat K.
# Created: 16 June 2016
# # # # # # # # # # # # # # # # # # # #

if [ -z "$1" ]
  then
  echo "Usage $0 acc_prefix total_acc chainhash [fps]"
  echo "Please specify the account prefix"
  exit
fi

if [ -z "$2" ]
  then
  echo "Usage $0 acc_prefix total_acc chainhash [fps]"
  echo "Please specify the total account to be created"
  exit
fi

if [ -z "$3" ]
  then
  echo "Usage $0 acc_prefix total_acc chainhash [fps]"
  echo "Please specify the account chainhash"
  exit
fi

acc_prefix=$1
total=$2
chainhash=$3
fps=$4
usleep_time=0
port=$5

if [ -z "$port" ]
  then
  echo "Please specify a targeting REST port."
  exit
fi

# Calculate sleep time
if [ ! -z "$fps" ]
  then
  usleep_time=$((1000000/fps))
fi

idx=0
while [ $idx -lt $total ];
  do
  printf "[$(date +"%T")] Account. ${acc_prefix}_${idx} : "

  curl_result=`curl -s -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
            "jsonrpc": "2.0",
            "method": "invoke",
            "params": {
              "type": 1,
              "chaincodeID": {
                "name": "'${chainhash}'"
              },
              "ctorMsg": {
                "function": "create",
                "args": ["'${acc_prefix}_${idx}'","1"]
              }
            },
            "id": 0
          }
          ' 'http://127.0.0.1:'${port}'/chaincode'`
  message=`echo ${curl_result} | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w status`
  status=`echo ${message##*|} | cut -d ":" -f 2`
  printf "${GREEN}${status}${NC}\n"

  #usleep $usleep_time
  ((idx++))
done
