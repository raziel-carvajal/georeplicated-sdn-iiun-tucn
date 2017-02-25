#!/bin/bash - 
#===============================================================================
#
#          FILE:   deployISPN.sh
# 
#         USAGE: ./deployISPN.sh
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 01/29/2017 21:08
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} -lt 2 ] ; then
  echo "USAGE: $0 [Site ID to bootstrap YCSB-ISPN] [Site ID of ISPN-master]"
  exit 1
fi

cli=${1} ; mas=${2}
isT=`grep "${cli}" mapCloudAp | wc -l`
if [ ${isT} -eq 0 ] ; then
  echo "ERROR: site ${cli} is not in the list of sites to deploy ISPN"
  exit 1
fi
isT=`grep "${mas}" mapCloudAp | wc -l`
if [ ${isT} -eq 0 ] ; then
  echo "ERROR: site ${mas} is not in the list of sites to deploy ISPN"
  exit 1
fi

echo "Getting list of IPs of ISNP servers"
masIp=`cat mapCloudAp | grep ${mas} | awk '{print $2}'`
cliIp=`cat mapCloudAp | grep ${cli} | awk '{print $2}'`
serverStr="${masIp}[7800],"
sitN=`cat mapCloudAp | wc -l`
for (( s=1; s<=${sitN}; s+=1 )); do
  sitId=`cat mapCloudAp | head -${s} | tail -1 | awk '{print $1}'`
  sitIp=`cat mapCloudAp | head -${s} | tail -1 | awk '{print $2}'`
  if [ "${sitId}" != "${mas}" ] ; then
    if [ "${sitId}" != "${cli}" ] ; then
      serverStr="${serverStr}${sitIp}[7800],"
    fi
  fi
done

# Remove last coma from ${serverStr}
seStLen=$((${#serverStr}-1))
serList=${serverStr:0:${seStLen}}
cliList="${masIp}:11222"

echo -e "\tString of ISPN for servers: ${serList}"
echo -e "\tString of YCSB: ${cliList}"
echo "DONE"
cfgFd="cfgFiles"
rm -fr ${cfgFd} ; mkdir  ${cfgFd} 
echo "Creating configuration files and launching ISPN servers..."
#ispnSerOpt="-r hotrod -Djgroups.tcpping.timeout=${PING_ISPN} -Djgroups.tcpping.num_initial_members=2"
ispnSerOpt="-r hotrod"
ispnSerOpt=${ispnSerOpt}" -Djgroups.tcpping.initial_hosts"
for (( cf=1; cf<=${sitN}; cf+=1 )); do
  sitId=`cat mapCloudAp | head -${cf} | tail -1 | awk '{print $1}'`
  sitIp=`cat mapCloudAp | head -${cf} | tail -1 | awk '{print $2}'`
  if [ "${sitId}" != "${cli}" ] ; then
    fNam="node-${cf}.xml"
    fLoc="${cfgFd}/${fNam}"
    cat distributedCache.xml >${fLoc}
    sed -i  s/"machineId=\"MACHINE_ID\""/"machineId=\"node-${sitId}\""/ ${fLoc}
    sed -i  s/"nodeName=\"NODE_ID\""/"nodeName=\"node-${sitId}\""/ ${fLoc}
    echo -e "\tISPN cfg file of site ${sitId} is done\n\tCopying cfg file in site ${sitId}"
    scp ${fLoc} ${sitId}-ca:~/infinispan
    echo -e "\t\tDONE\n\tLaunching ISPN at site ${sitId}..."
    cmd="cd ~/infinispan ; ./bin/startServer.sh -c ${fNam} -l ${sitIp} -Djgroups.bind_addr=${sitIp}"
    cmd=${cmd}" ${ispnSerOpt}=${serList} &>/dev/null &"
    echo -e "\tcurrent command: ${cmd}"
    ssh ${sitId}-ca "${cmd}"
    echo -e "\t\tDONE"
  fi
done
echo "DONE"

#TODO find a better way to wait until all ISPN servers boostrap
echo "Waiting for letting ISPN servers to bootstrap"
sleep 180
echo -e "\tDONE"

caCfg="${cfgFd}/distributed-cache.properties"
cat ycsbCacheCfg >${caCfg}
echo "infinispan.client.hotrod.server_list=${cliList}" >>${caCfg}
echo "Copying cfg file of YCSB cache..."
scp ${caCfg} ${cli}-ca:~/ycsb-infinispan
echo -e "\tDONE"

#Reading YCSB options from <<ycsbBenchCfg>> file
wTy=`grep "workload=" ycsbBenchCfg | awk -F "=" '{print $2}'`
ycsbLoaOpt="load infinispan-cs -s -P workloads/workload${wTy} -P distributed-cache.properties -p measurementtype=raw -p"
ycsbLoaOpt=${ycsbLoaOpt}" measurement.raw.output_file=load.out"
ycsbRunOpt="run infinispan-cs -s -P workloads/workload${wTy} -P distributed-cache.properties -p measurementtype=raw -p"
ycsbRunOpt=${ycsbRunOpt}" measurement.raw.output_file=run.out"
optN=`cat ycsbBenchCfg | wc -l`
for (( opt=1; opt<=${optN}; opt+=1 )); do
  optKeVa=`cat ycsbBenchCfg | head -${opt} | tail -1`
  key=`echo "${optKeVa}" | awk -F "=" '{print $1}'`
  if [ "${key}" != "workload" ] ; then
    ycsbLoaOpt=${ycsbLoaOpt}" -p ${optKeVa}"
    ycsbRunOpt=${ycsbRunOpt}" -p ${optKeVa}"
  fi
done

echo "YCSB <<load>> phase with options as follows: ${ycsbLoaOpt}"
ssh ${cli}-ca "cd ~/ycsb-infinispan ; ./bin/ycsb.sh ${ycsbLoaOpt}"
echo -e "\tDONE"

echo "YCSB <<run>> phase with options as follows: ${ycsbRunOpt}"
ssh ${cli}-ca "cd ~/ycsb-infinispan ; ./bin/ycsb.sh ${ycsbRunOpt}"
echo -e "\tDONE"

echo "Getting ISPN dataset..."
dat="infinispan"
cmd="cd ~/ycsb-infinispan ; rm -fr ${dat}.tgz ; rm -fr ${dat} ; mkdir ${dat} ; mv load.out run.out ${dat} ; ~/tar czf ${dat}.tgz ${dat}"
ssh ${cli}-ca "${cmd}"
scp ${cli}-ca:~/ycsb-infinispan/${dat}.tgz .
echo -e "\tDONE"

#STOP experiment
for (( cf=1; cf<=${sitN}; cf+=1 )); do
  sitId=`cat mapCloudAp | head -${cf} | tail -1 | awk '{print $1}'`
  sitIp=`cat mapCloudAp | head -${cf} | tail -1 | awk '{print $2}'`
  if [ "${sitId}" != "${cli}" ] ; then
    echo "Stop ISPN server in site ${sitId}"
    ssh ${sitId}-ca "pkill java ; pkill startServer.sh"
  fi
  echo -e "\tDONE"
done

echo "ISPN EXPERIMENT IS FINISHED"
