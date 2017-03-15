#!/bin/bash - 
#===============================================================================
#
#          FILE: killIperfPingProc.sh
# 
#         USAGE: ./killIperfPingProc.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/15/2017 08:33
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

echo "Killing ping/iperf process on each node"
nodesNo=`cat mapNetTool | wc -l`
for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
  line=`cat mapNetTool | head -${CNTR} | tail -1`
  nodeId=`echo ${line} | awk '{print $1}'`
  echo -e "\tStop ping/iperf on each site: ${nodeId}"
  ssh ${nodeId}-nt "pkill ping &>/dev/null & ; pkill iperf &>/dev/null &" &>/dev/null &
  echo -e "\tDONE"
  rm -fr ${nodeId}-links.dat
done
echo "END of script: ${0}"
