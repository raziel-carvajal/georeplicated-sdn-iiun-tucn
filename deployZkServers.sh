#!/bin/bash - 
#===============================================================================
#
#          FILE: deployZkServers.sh
# 
#         USAGE: ./deployZkServers.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/19/2017 22:37
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

nodesNo=`cat zkServers | wc -l`
for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
  line=`cat zkServers | head -${CNTR} | tail -1`
  nodeId=`echo ${line} | awk '{print $1}'`
  echo "Launching ZkServer on site: ${nodeId}"
  #TODO add file myId to bootstrap ZK
  ssh ${nodeId}-ca "cd zookeeper ; ./bin/zkServer.sh stop"
  ssh ${nodeId}-ca "cd zookeeper ; ./bin/zkServer.sh start &>/dev/null &" &>/dev/null &
  echo "DONE"
done

echo "END of ${0}"
