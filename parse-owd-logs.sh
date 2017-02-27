#!/bin/bash - 
#===============================================================================
#
#          FILE: parse-owd-logs.sh
# 
#         USAGE: ./parse-owd-logs.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/14/2017 15:36
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
rm -fr *.dat

for f in `ls *-owd.out` ; do
  i=$(( ${#f} - 4 ))
  fiN=${f:0:${i}}
  dstF="${fiN}".dat
  cat ${f} | awk '{print $12}' | awk -F "=" '{print $2 }' >${dstF}
done

cd ${origin}
