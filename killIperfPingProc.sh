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
for nodeId in `echo -e "neu\nlan\nbor\nclu"` ; do
  echo -e "\tStop ping/iperf on site: ${nodeId}"
  ssh ${nodeId}-nt "pkill ping ; pkill iperf " &>/dev/null &
  echo -e "\tDONE"
  rm -fr ${nodeId}-links.dat
done
echo "END of script: ${0}"
