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
node=$1
neig=$2
f="START-${node}"
echo "Waiting to start NetTool-cli..."
while [ ! -f ${f} ] ; do
  sleep 1
done
echo "START NetTool-cli at node ${node}"

links=`cat ${f} | wc -l`
loD="${node}-logs"
rm -rf *.out ${loD} ${loD}.tgz
i=1
while [ ! -f STOP ] ; do
  sigF="LOOP-${i}"
  while [ ! -f ${sigF} ] ; do
    echo "Waiting for ${sigF}..."
    sleep 5
    if [ -f STOP ] ; then
      mkdir ${loD}
      cp *.out ${loD}
      ~/tar czf ${loD}.tgz ${loD}
      echo "STOP msg was received"
      exit 1
    fi
  done
  echo "Message ${sigF} received"
  echo "Round [${i}] to measure OWD & ATR"
  for (( CNTR=1; CNTR<=${links}; CNTR+=1 )); do
    endPoIp=`cat ${f} | head -${CNTR} | tail -1`
    endPoId=`awk '{print $1,$2}' mapNetTool | grep ${endPoIp} | awk '{print $1}'`
    atrF="${endPoId}-${node}-${i}-atr.out"
    owdF="${node}-${endPoId}-${i}-owd.out"
    echo -e "\tMeasuring ATR and OWD from link ${node}-${endPoId} (end point: ${endPoIp}) CNTR[${CNTR}]"
    ./pathload_rcv -s ${endPoIp} -o ${atrF} &>~/tmp &
    atrPid=$!
    ping ${endPoIp} | perl -nle 'BEGIN {$|++} print scalar(localtime), " ", $_' > ${owdF} &
    echo "Waiting process [${atrPid}]"
    sleep 40
    echo -e "\tContinue..."
    pkill ping
    pkill perl
    kill -9 ${atrPid} &>>~/tmp
    sleep 25
    echo -e "\tDONE"
  done
  echo "Sending NEXT message to my neighbour"
  if [ "${node}" == "neu" ] ; then
    user="raziel1"
  else
    user="raziel"
  fi
  if [ "${node}" == "bor" ]  ; then
    let j=i+1
    ssh ${user}@${neig} "touch LOOP-${j}"
  else
    ssh ${user}@${neig} "touch LOOP-${i}"
  fi
  echo -e "\tDONE\nEND of round [${i}]"
  let i=i+1
done

mkdir ${loD}
cp *.out ${loD}
~/tar czf ${loD}.tgz ${loD}
echo "STOP msg was received"
