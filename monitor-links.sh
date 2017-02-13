#!/bin/bash - 
#===============================================================================
#
#          FILE: monitor-links.sh
# 
#         USAGE: ./monitor-links.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/13/2017 00:25
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

TIMEOUT=30
node=$1 ; neig=$2
f="START-${node}"
echo "Waiting to start NetTool-cli..."
while [ ! -f ${f} ] ; do
  sleep 1
done
echo "START NetTool-cli at node ${node}"

links=`cat ${f} | wc -l`
rm -f *.out ; i=1
while [ ! -f STOP ] ; do
  sigF="LOOP-${i}"
  while [ ! -f ${sigF} ] ; do
    echo "Waiting for ${sigF}..."
    sleep 5
    if [ -f STOP ] ; then
      echo "STOP msg was received"
      exit 1
    fi
  done
  echo -e "\tMessage ${sigF} received"
  echo "Round [${i}] to measure OWD & ATR"
  for (( CNTR=1; CNTR<=${links}; CNTR+=1 )); do
    endPoIp=`cat ${f} | head -${CNTR} | tail -1`
    endPoId=`awk '{print $1,$2}' mapNetTool | grep ${endPoIp} | awk '{print $1}'`
    logF="${endPoId}-${node}.out"
    echo -e "Getting data from ${node} to ${endPoId} CNTR[${CNTR}]"
    ./pathload_1.3.2/pathload_rcv -s ${endPoIp} -O ${logF} >/dev/null &
    sleep ${TIMEOUT}
    pkill pathload_rcv
    echo -e "\t\tDONE"
  done
  echo "Sending NEXT message to my neighbour"
  if [ "${node}" == "bor" ]  ; then
    let j=i+1
    ssh ubuntu@${neig} "touch LOOP-${j}"
  else
    ssh ubuntu@${neig} "touch LOOP-${i}"
  fi
  echo -e "\tDONE\nEND of round [${i}]"
  let i=i+1
done

echo "STOP msg was received"
