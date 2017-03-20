#!/bin/bash - 
#===============================================================================
#
#          FILE: runZkBenchPeriodically.sh
# 
#         USAGE: ./runZkBenchPeriodically.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/20/2017 00:13
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} -lt 1 ] ; then
  echo "USAGE: ${0} [List of ZK servers in form of string]"
  exit 1
fi
zkServers=${1} ; i=1
while [ ! -f STOP ] ; do
  PYTHONPATH=lib.linux-x86_64-2.6 LD_LIBRARY_PATH=lib.linux-x86_64-2.6 python zk-latencies.py --servers "${zkServers}" --znode_count=1 --znode_size=100 --synchronous >tmp
  writ=`cat tmp | head -4 | tail -1 | awk '{print $6}'`
  read=`cat tmp | head -6 | tail -1 | awk '{print $5}'`
  echo "${i} WRIT ${writ}"
  echo "${i} READ ${read}"
  rm *.txt
  let i=i+1
done
echo -e "STOP message received\nEND of ${0}"
