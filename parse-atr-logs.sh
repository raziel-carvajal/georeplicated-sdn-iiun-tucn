#!/bin/bash 
#===============================================================================
#
#          FILE: parse-atr-logs.sh
# 
#         USAGE: ./parse-atr-logs.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/14/2017 13:07
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ $# -lt 1 ]; then
  echo "USAGE: $0 [Directory of logs]"
  exit 1
fi
dstD=$1
if [ ! -d "${dstD}" ] ; then
  echo "ERROR: the directory of logs doesn't exist or it isn't vaild"
  exit 1
fi

origin=`pwd`
cd ${dstD}
strToG=".0 sec"
rm -fr *.dat

for f in `ls *-atr.out` ; do
  i=$(( ${#f} - 4 ))
  fiN=${f:0:${i}}
  dstF="${fiN}".dat
  #header=`grep "${strToG}" ${f} | head | tail -1 | awk '{print $NF}'`
  #echo "# ${header}" >${dstF}
  grep "${strToG}" ${f} | awk '{print $(NF - 1) }' >${dstF}
done

cd ${origin}
