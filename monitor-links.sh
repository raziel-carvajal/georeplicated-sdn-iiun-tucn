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

TIMEOUT=30 ; node=$1 ; neig=$2
f="START-${node}"
echo "Waiting to start NetTool-cli..."
while [ ! -f ${f} ] ; do
  sleep 1
done
echo "START NetTool-cli at node ${node}"

links=`cat ${f} | wc -l` ; loD="${node}-logs"
rm -rf *.out ${loD} ${loD}.tgz pids ; mkdir ${loD} ; touch pids
for (( CNTR=1; CNTR<=${links}; CNTR+=1 )); do
  endPoIp=`cat ${f} | head -${CNTR} | tail -1`
  endPoId=`awk '{print $1,$2}' mapNetTool | grep ${endPoIp} | awk '{print $1}'`
  atrF="${node}-${endPoId}-atr.out"
  owdF="${node}-${endPoId}-owd.out"
  echo -e "\tMeasuring ATR and OWD from link ${node}-${endPoId} (end point: ${endPoIp}) CNTR[${CNTR}]"
  ./iperf -c ${endPoIp} -t 360 -i 1 &>${atrF} &
  atrPid=$! ; echo "${atrPid}" >>pids
  ping ${endPoIp} | perl -nle 'BEGIN {$|++} print scalar(localtime), " ", $_' &> ${owdF} &
  pinPid=$! ; echo "${pinPid}" >>pids
  echo -e "\tDONE"
done

echo "Waiting to receive STOP..."
while [ ! -f STOP ] ; do
  sleep 1
done
echo -e "\tSTOP msg received"

pidsNo=`cat pids | wc -l`
for (( CNTR=1; CNTR<=${pidsNo}; CNTR+=1 )); do
  pid=`cat pids | head -${CNTR} | tail -1`
  echo "Killing PID: ${pid}"
  kill -9 ${pid}
  echo -e "\tDONE"
done

#killing server
pkill iperf &>/dev/null &

cp *.out ${loD}
~/tar czf ${loD}.tgz ${loD}
echo "END of ${0}"
