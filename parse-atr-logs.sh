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
strToG="Rmin-Rmax             ::"
rm -fr tmp* col* *.parAtr

for f in `ls *-atr.out` ; do
  i=$(( ${#f} - 4 ))
  fiN=${f:0:${i}}
  dstF="${fiN}".parAtr
  
  grep "${strToG}" ${f} | awk '{print $3}' >tmp
  lin=`cat tmp | wc -l`
  if [ ${lin} -gt 0 ] ; then
    cat tmp | awk -F "-" '{print $1}' >col1
    cat tmp | awk -F "-" '{print $2}' |  awk -F "Mbps" '{print $1}' >col2
    fL=`cat col1 | tail -1`
    sL=`cat col2 | tail -1`
    bG=`echo "${fL} > ${sL}" | bc`
    if [ ${bG} -gt 0 ] ; then
      echo "${fL}" >>${dstF}
    else
      echo "${sL}" >>${dstF}
    fi
  else
    echo "NA" >>${dstF}
  fi

done

rm -fr tmp* col*
cd ${origin}
