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
rm -fr tmp logs START-*

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  neiIp=`echo ${mapLi} | awk '{print $3}'`

  echo "Copying NetTool-cli source and configuration files in node ${floIp}"
  scp mapNetTool monitor-links.sh ${floIp}-nt:~/
  ssh ${floIp}-nt "rm -fr START-* STOP LOOP-* *.log *.out"
  echo -e "\tDONE"
  
  echo "Launching NetTool-daemon on site ${floIp}"
  ssh ${floIp}-nt "./pathload_snd -i &>~/net-d-${floIp}.log &"
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
  ssh ${floIp}-nt "./monitor-links.sh ${floIp} ${neiIp} &>~/net-c-${floIp}.log &"
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

#TODO launch your script to deploy ISPN

echo -e "NetTool was deployed\nWaiting to stop..."
#sleep 1800
sleep 1200
echo -e "\tDONE\nSending STOP message to nodes"
mkdir logs
mkdir logs/owd
mkdir logs/atr

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  echo -e "Halting NetTool on node ${floIp}..."
  ssh ${floIp}-nt "pkill pathload_snd & touch STOP"
  echo -e "\t\tDONE"
done

echo "Waiting 2m (see monitor-liks.sh:61) just in case one process is still ongoing..."
sleep 120
echo -e "\tcontinue\nGetting logs from each site..."

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  echo -e "Fetching dataset of site ${floIp}..."
  scp ${floIp}-nt:~/${floIp}-logs.tgz logs/
  echo -e "\t\tDONE"
done

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  cd logs
  tar xof ${floIp}-logs.tgz
  cd ..
  echo "Parsing dataset of site ${floIp}"
  ./parse-atr-logs.sh logs/${floIp}-logs
  ./parse-owd-logs.sh logs/${floIp}-logs
  mv logs/${floIp}-logs/*.out logs/
  mv logs/${floIp}-logs/*.parAtr logs/atr/
  mv logs/${floIp}-logs/*.parOwd logs/owd/
  echo -e "\tDONE"
done

logsN=`date +%F_%H.%M`
mv logs ${logsN}
rm -fr tmp START-*
#tar czf ${logsN}.tgz ${logsN}
