#!/bin/bash

# # # # # # # # # # # # # # # # # # # #
# Hyperledger account deploying test
# Author: Siriwat K.
# Created: 16 June 2016
# # # # # # # # # # # # # #

mode=$1
port=$2
acc_hash=$3

if [ -z "$mode" ]
  then
  echo "Usage $0 acc|opt rest_port [acc_hash]"
  echo "Please specify a deploying [acc|opt acc_hash]"
  exit
fi

if [ -z "$port" ]
  then
  echo "Please specify a targeting REST port."
  exit
fi

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ "$mode" == "acc" ]; then
	printf "[$(date +"%T")] Account chainhash: "

	curl_result=`curl -s -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
			"jsonrpc": "2.0",
			"method": "deploy",
			"params": {
			"type": 1,
			"chaincodeID": {
			  "path": "chaincode/LM/accounter"
			},
			"ctorMsg": {
			  "function": "init",
			  "args": []
			}
			},
			"id": 0
			}
			' 'http://127.0.0.1:'${port}'/chaincode'`
	message=`echo ${curl_result} | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w message`
    chainhash=`echo ${message##*|} | cut -d ":" -f 2`

	printf "${GREEN}${chainhash}${NC}\n"
else
	if [ -z "$acc_hash" ]
	  then
	  echo "Usage $0 [acc|opt acc_hash]"
	  echo "Please specify an account chainhash"
	  exit
	fi

	printf "[$(date +"%T")] Option chainhash: "

	curl_result=`curl -s -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
			"jsonrpc": "2.0",
			"method": "deploy",
			"params": {
			"type": 1,
			"chaincodeID": {
			  "path": "chaincode/LM/engine"
			},
			"ctorMsg": {
			  "function": "init",
			  "args":
			["Option1","600000","1465360067","USD/JPY","106","1000","Call","${acc_hash}"]
			    }
			  },
			  "id": 0
			}
			' 'http://127.0.0.1:'${port}'/chaincode'`
	message=`echo ${curl_result} | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w message`
    chainhash=`echo ${message##*|} | cut -d ":" -f 2`

	printf "${GREEN}${chainhash}${NC}\n"
	
fi
