#!/bin/bash - 
#===============================================================================
#
#          FILE: measure-rtt-atr.sh
# 
#         USAGE: ./measure-rtt-atr.sh
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/14/2017 18:52
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
waitForIperfServ=10

rm -fr datasets/*.log *-links.dat
echo "Deploying NetTool..."
nodesNo=`cat mapNetTool | wc -l`

for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
  line=`cat mapNetTool | head -${CNTR} | tail -1`
  nodeId=`echo ${line} | awk '{print $1}'`

  echo -e "\tLaunching IperfServer on site: ${nodeId}"
  ssh ${nodeId}-nt "./iperf -p 5210 -s &>iperfServer-${nodeId}.log &"
  echo -e "\tDONE"
  #Getting links of each node
  cat linksNetTool | grep ${nodeId} | awk '{print $2}' >${nodeId}-links.dat
done

echo "Waiting for Iperf servers to bootstrap"
sleep ${waitForIperfServ} ; echo "DONE"

for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
  line=`cat mapNetTool | head -${CNTR} | tail -1`
  nodeId=`echo ${line} | awk '{print $1}'`
  #this file was created in the previous loop
  links="${nodeId}-links.dat"
  endPoints=`cat ${links} | wc -l`
  for (( i=1; i<=${endPoints}; i+=1 )); do
    dstIp=`cat ${links} | head -${i} | tail -1`
    dstId=`cat mapNetTool | grep ${dstIp} | awk '{print $1}'`
    atrCm="./iperf -p 5210 -c ${dstIp} -t 360 -i 2"
    rttCm="ping -i 1 ${dstIp} | awk '{print $7}'"
    logF="${nodeId}-${dstId}"
    #XXX previously, these two commands were tested to let *.log files
    #  be filled until ping/iperf is killed at every node
    echo -e "\tMeasuring ATR and OWD from link: ${logF}"
    #ssh ${nodeId}-nt "${atrCm}" &>datasets/${logF}-atr.log &
    ssh ${nodeId}-nt "${rttCm}" &>datasets/${logF}-rtt.log &
    echo -e "\tDONE"
  done
done

echo "END of script ${0}"
