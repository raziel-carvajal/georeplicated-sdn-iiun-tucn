#!/bin/bash - 
#===============================================================================
#
#          FILE: startZkBenchmark.sh
# 
#         USAGE: ./startZkBenchmark.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/19/2017 22:45
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} -lt 1 ] ; then
  echo "USAGE: ${0} [site (clu, lan, bor or neu) where Zk client will run]"
  exit 1
fi
node=${1}
zkServers="172.16.16.85:2181"
CMDS="cd zk-smoketest-master ; rm -fr *.txt STOP out.log ;"
CMDS=${CMDS}" ./runZkBenchPeriodically.sh ${zkServers} &>~/zk-clu-lan &"

echo "Zookeeper benchmark will start at node ${node}"
scp runZkBenchPeriodically.sh ${node}-ca:~/zk-smoketest-master
ssh ${node}-ca ${CMDS}
echo -e "DONE\nHalt Zookeeper benchmark with [stopZkBenchmark.sh]"

echo "END of ${0}"
