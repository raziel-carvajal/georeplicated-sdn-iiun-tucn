#!/bin/bash - 
#===============================================================================
#
#          FILE: emulate-rtt-stream.sh
# 
#         USAGE: ./emulate-rtt-stream.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/16/2017 11:28
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

rm -fr STOP ../datasets/* ; i=1 ; icmp=1 ; time=10 ; insertNo=10
lin1="64 bytes from 172.16.16.99: icmp_seq="
lin2=" ttl=64 time="
lin3=" ms"

atrLine1="[  3]  "
atrLine2="- 4.0 sec  1.38 MBytes  "
atrLine3=" Mbits/sec"

touch tmp
while [ ! -f STOP ] ; do
  echo "Doing iteration [${i}]"
  toConcat=""
  atrToConcat=""
  for (( j=0; j<${insertNo}; j+=1 )); do
    if [ ${j} -ne $(( ${insertNo} - 1 )) ] ; then
      atrToConcat=${atrToConcat}${atrLine1}${icmp}".0"${atrLine2}${time}${atrLine3}"\n"
      toConcat=${toConcat}${lin1}${icmp}${lin2}${time}${lin3}"\n"
    else
      atrToConcat=${atrToConcat}${atrLine1}${icmp}".0"${atrLine2}${time}${atrLine3}
      toConcat=${toConcat}${lin1}${icmp}${lin2}${time}${lin3}
    fi
    let icmp=icmp+1
    let time=time+1
  done
  echo -e "${toConcat}" >>../datasets/rtt-clu-neu
  echo -e "${atrToConcat}" >>../datasets/atr-clu-neu
  sleep 2
  let i=i+1
done

echo "END of ${0}"
