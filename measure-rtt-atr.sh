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

waitForIperfServ=10 ; rm -fr datasets/* *-links.dat STOP
echo "Deploying NetTool..." ; nodesNo=`cat mapNetTool | wc -l`

#XXX this loop was include to measure ATR/RTT from CLU, which is the node
#  with the better performance in our testbed, this means that just 3 of
#  the 12 links will be monitored due to the SSH connections delays between
#  nodes; cause of inconsistencies in reading dataset from the Web client
for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
  line=`cat mapNetTool | head -${CNTR} | tail -1`
  nodeId=`echo ${line} | awk '{print $1}'`
  echo -e "\tLaunching IperfServer on site: ${nodeId}"
  ssh ${nodeId}-nt "rm -fr atr-* rtt-* ; ./iperf -p 5210 -s &>/dev/null &"
  echo -e "\tDONE"
  #Getting links of each node
  cat linksNetTool | grep ${nodeId} | awk '{print $2}' >${nodeId}-links.dat
done

echo "Waiting for Iperf servers to bootstrap"
sleep ${waitForIperfServ} ; echo "DONE"

for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
  line=`cat mapNetTool | head -${CNTR} | tail -1`
  nodeId=`echo ${line} | awk '{print $1}'`
  links="${nodeId}-links.dat" #file created in previous loop
  endPoints=`cat ${links} | wc -l`
  for (( i=1; i<=${endPoints}; i+=1 )); do
    dstIp=`cat ${links} | head -${i} | tail -1`
    dstId=`cat mapNetTool | grep ${dstIp} | awk '{print $1}'`
    logF="${nodeId}-${dstId}"
    atrCm="./iperf -p 5210 -c ${dstIp} -t 3600 -i 1 >atr-${logF} &"
    rttCm="ping -i 2 ${dstIp} >rtt-${logF} &"
    echo -e "\tMeasuring ATR and OWD from link: ${logF}"
    ssh ${nodeId}-nt "${atrCm}" 
    ssh ${nodeId}-nt "${rttCm}" 
    echo -e "\tDONE"
  done
done

echo "Deploying Zookeeper Servers..."
#./deployZkServers.sh
echo "DONE"
#TODO CHECK THIS!!!
zkCli="bor"
echo "Start Zookeeper benchmark..."
./startZkBenchmark.sh ${zkCli}
echo "DONE"

echo "Waiting for STOP signal to end with ATR/RTT measurements" ; j=1
while [ ! -f 'STOP' ] ; do
  for (( CNTR=1; CNTR<=${nodesNo}; CNTR+=1 )); do
    line=`cat mapNetTool | head -${CNTR} | tail -1`
    nodeId=`echo ${line} | awk '{print $1}'`
    echo -e "\tUpdating Zookeeper dataset [${j}]"
    if [ ${nodeId} == ${zkCli} ] ; then
      zkF="zk-clu-lan"
      ssh ${nodeId}-ca "cat ${zkF}" >datasets/zk-tmp.log
      grep "READ" datasets/zk-tmp.log >datasets/zk-tmp-reads.log
      grep "WRIT" datasets/zk-tmp.log >datasets/zk-tmp-writes.log
      mv datasets/zk-tmp-reads.log  datasets/${zkF}-reads
      mv datasets/zk-tmp-writes.log datasets/${zkF}-writes
    fi
    echo -e "\tUpdating ATR/RTT datasets [${j}]"
    links="${nodeId}-links.dat" #file created in previous loop
    endPoints=`cat ${links} | wc -l`
    for (( i=1; i<=${endPoints}; i+=1 )); do
      dstIp=`cat ${links} | head -${i} | tail -1`
      dstId=`cat mapNetTool | grep ${dstIp} | awk '{print $1}'`
      atrF="atr-${nodeId}-${dstId}" 
      rttF="rtt-${nodeId}-${dstId}"
      ssh ${nodeId}-nt "cat ${atrF}" >datasets/atr-tmp.log
      ssh ${nodeId}-nt "cat ${rttF}" >datasets/rtt-tmp.log
      mv datasets/atr-tmp.log datasets/${atrF}
      mv datasets/rtt-tmp.log datasets/${rttF}
    done
  done
  echo -e "\tEnd of iteration [${j}]" ; sleep 5 ; let j=j+1
done
echo "DONE"

./killIperfPingProc.sh
echo "Halt Zookeeper benchmark..."
./stopZkBenchmark.sh ${zkCli}
echo "DONE"

echo "END of script ${0}"
