#!/bin/bash - 
#===============================================================================
#
#          FILE: stopZkBenchmark.sh
# 
#         USAGE: ./stopZkBenchmark.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/20/2017 00:32
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} -lt 1 ] ; then
  echo "USAGE: ${0} [site (clu, lan, bor or neu) where ZK is running]"
  exit 1
fi
node=${1}

echo "Halt ZK benchmark at node ${node}"
ssh ${node}-ca "touch zk-smoketest-master/STOP"

echo -e "DONE\nEND of ${0}"
