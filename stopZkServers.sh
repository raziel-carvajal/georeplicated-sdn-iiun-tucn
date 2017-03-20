#!/bin/bash - 
#===============================================================================
#
#          FILE: stopZkServers.sh
# 
#         USAGE: ./stopZkServers.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/19/2017 22:54
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

nodesNo=`cat zkServers | wc -l`
for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
  line=`cat zkServers | head -${CNTR} | tail -1`
  nodeId=`echo ${line} | awk '{print $1}'`
  echo "Halt ZkServer on site: ${nodeId}"
  ssh ${nodeId}-ca "cd zookeeper ; ./bin/zkServer.sh stop"
  echo "DONE"
done

