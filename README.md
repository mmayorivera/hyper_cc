# Hyperledger node control center (hyper_cc)

The scripts were created to take control of hyperledger nodes.

## Requirements
 - Dedicated nodes, VMs or physical servers are fine.
 - Installed docker on each node.
 - SSH, with key installed.

## How it works
The script will generate a docker command then send it through ssh connection for each server. The node will initial hyperledger under a docker environment with predefined parameters as following:
- CORE_PEER_ADDRESSAUTODETECT=true
- CORE_PEER_SYNC_BLOCKS_CHANNELSIZE=100
- CORE_PEER_SYNC_STATE_SNAPSHOT_CHANNELSIZE=500
- CORE_PEER_SYNC_STATE_DELTAS_CHANNELSIZE=200
- CORE_PEER_VALIDATOR_CONSENSUS_PLUGIN=pbft
- CORE_PEER_VALIDATOR_CONSENSUS_BUFFERSIZE=7500
- CORE_PEER_VALIDATOR_CONSENSUS_EVENTS_BUFFERSIZE=1000
- CORE_PBFT_GENERAL_N=4
- CORE_PBFT_GENERAL_K=2
- CORE_PBFT_GENERAL_TIMEOUT_REQUEST=10s
- CORE_PBFT_GENERAL_MODE=classic
- CORE_SECURITY_ENABLED=false
  
## Diagram
coming soon

## Usage
##### Nodes up
To start 4 nodes with sbi as its prefix.\
Cmd: hyper_start.sh total_number node_prefix
```sh
$ hyper_start.sh 4 sbi 
```
##### Nodes up (one specific node)
To start only the 2nd node.\
Cmd: hyper_start.sh -specific_node_index node_prefix
```sh
$ hyper_start.sh -2 sbi
```

##### Nodes down
To stop all 6 nodes.\
Cmd: hyper_stop.sh total_number node_prefix
```sh
$ hyper_stop.sh 6 sbi
```

##### Nodes down (one specific node)
To stop only the 3rd node.\
Cmd: hyper_stop.sh -specific_node_index node_prefix
```sh
$ hyper_stop.sh -3 sbi
```

##### Clean up Hyperledger database
Cmd: clean_db.sh
```sh
$ clean_db.sh
```
