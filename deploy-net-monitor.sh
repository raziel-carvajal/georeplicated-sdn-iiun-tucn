#!/bin/bash - 
#===============================================================================
#
#          FILE: deploy-net-monitor.sh
# 
#         USAGE: ./deploy-net-monitor.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/12/2017 22:45
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#if [ $# -lt 1 ]; then
#  echo "USAGE: $0 timeout"
#  exit 1
#fi

echo "Deploying NetTool..."
pairsNu=`cat mapNetTool | wc -l`
rm -fr tmp logs

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  neiIp=`echo ${mapLi} | awk '{print $3}'`

  echo "Copying NetTool-cli source and configuration files in node ${floIp}"
  scp mapNetTool monitor-links.sh ${floIp}-nt:~/
  echo -e "\tDONE"
  
  echo "Launching NetTool-daemon on site ${floIp}"
  ssh ${floIp}-nt "./pathload_1.3.2/pathload_snd -i >/dev/null &"
  echo -e "\tDONE"

  cat linksNetTool | grep ${floIp} >tmp
  linkCnt=`cat tmp | wc -l`
  f="START-${floIp}"
  rm -f ${f}
  for (( CNTR_A=1; CNTR_A<=${linkCnt}; CNTR_A+=1 )); do
    link=`cat tmp | head -${CNTR_A} | tail -1 | awk '{print $2}'`
    echo ${link} >> ${f}
  done
  
  echo "Launching NetTool-cli on site ${floIp}"
  ssh ${floIp}-nt "rm -fr ${f} STOP"
  ssh ${floIp}-nt "source ~/monitor-links.sh ${floIp} ${neiIp} >~/net-c-${floIp}.log &"
  echo -e "\tDONE"
done

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  echo "Send START_MONITORING to site ${floIp}"
  scp START-${floIp} ${floIp}-nt:~/
  if [ ${CNTR} -eq 1 ] ; then
    ssh ${floIp}-nt "touch LOOP-1"
  fi
  echo -e "\tDONE"
done

#Deploy ISPN

echo -e "NetTool was deployed\nWaiting to stop..."
sleep 1800
echo -e "\tDONE\nSending STOP message to nodes"
mkdir logs

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  echo -e "Halting NetTool on node ${floIp}..."
  ssh ${floIp}-nt "killall pathload_rcv pathload_snd & touch STOP"
  scp ${floIp}-nt:~/*.out logs/
  scp ${floIp}-nt:~/*.log logs/
  echo -e "\t\tDONE"
done


