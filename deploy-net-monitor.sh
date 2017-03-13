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

if [ ${#} -lt 2 ] ; then
  echo "USAGE: $0 [Site ID to bootstrap YCSB-ISPN] [Site ID of ISPN-master]"
  exit 1
fi
# TODO: check if both peers are in the list of sites for the experiment,
#     just passed what it is written in deploISPN.sh to this aim
ycsbCli=${1} ; ycsbMas=${2}

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
  #ssh ${floIp}-nt "./pathload_snd -i &>~/net-d-${floIp}.log &"
  # Start up server
  ssh ${floIp}-nt "./iperf -p 5210 -s &>net-d-${floIp}.log &"
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
  echo -e "\tDONE"
done


echo "Start saturation of link ${ycsbCli} - ${ycsbMas}"
#ycsbMasIp=`grep "${ycsbMas}" mapNetTool | awk '{print $2}'`
#ssh ${ycsbMas}-nt "./iperf3 -p 5201 -s &>/dev/null &"
#ssh ${ycsbCli}-nt "./iperf3 -p 5201 -c ${ycsbMasIp} -i 1 -t 180"

#echo -e "Deploying ISPN and YCSB.."
## Bandwidth-intensive mode 
#
## ISPN
#./deployISPN.sh ${ycsbCli} ${ycsbMas}
#
## Baseline
sleep 180
echo -e "\tDONE"
#
#echo -e "\tDONE\nSending STOP message to nodes"

mkdir logs ; mkdir logs/owd ; mkdir logs/atr
# infinispan.tgz is fetched by deployISPN.sh
#mv infinispan.tgz logs/

for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  echo -e "Halting NetTool on node ${floIp}..."
  ssh ${floIp}-nt "touch STOP"
  echo -e "\t\tDONE"
done

echo "Wait until all logs are fetched"
logsNum=0 ; j=1
while [ ${logsNum} -lt ${pairsNu} ] ; do
  echo "Try numb [${j}] to fetch all logs"
  for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
    mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
    floIp=`echo ${mapLi} | awk '{print $1}'`
    if [ ! -f "logs/${floIp}-logs.tgz" ] ; then
      echo -e "Fetching dataset of site ${floIp}..."
      scp ${floIp}-nt:~/${floIp}-logs.tgz logs/
      echo -e "\t\tDONE"
    else
      echo -e "\tFile ${floIp}-logs.tgz was fetched already"
    fi
  done
  sleep 5
  let j=j+1 ; logsNum=`ls logs/*-logs.tgz | wc -l`
done
echo "All logs were received"

#Get raw data from logs
for (( CNTR=1; CNTR<=${pairsNu}; CNTR+=1 )); do
  mapLi=`cat mapNetTool | head -${CNTR} | tail -1`
  floIp=`echo ${mapLi} | awk '{print $1}'`
  cd logs
  tar xof ${floIp}-logs.tgz
  cd ..
  echo "Parsing dataset of site ${floIp}"
  ./parse-atr-logs.sh logs/${floIp}-logs
  mv logs/${floIp}-logs/*-atr.dat logs/atr/
  ./parse-owd-logs.sh logs/${floIp}-logs
  mv logs/${floIp}-logs/*-owd.dat logs/owd/
  mv logs/${floIp}-logs/*.out logs/
  echo -e "\tDONE"
done

logsN=`date +%F_%H.%M`
mv logs ${logsN}
rm -fr tmp START-*
tar czf ${logsN}.tgz ${logsN}
rm -r ${logsN}
echo "END of script ${0}"
