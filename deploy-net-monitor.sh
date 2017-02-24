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

if [ ${#} -lt 1 ] ; then
  echo "USAGE: $0 [Number of minutes to let ATR and OWD be measured]"
  exit 1
fi
timeout=${1}
logs="tucn-logs"
rm -fr ${logs} ; mkdir ${logs}

sitesNo=`cat mapNetTool | wc -l`
echo "Deploying TUCN tool..."
for (( CNTR=1; CNTR<=${sitesNo}; CNTR+=1 )); do
  site=`cat mapNetTool | head -${CNTR} | tail -1 | awk '{print $1}'`
  cmd="cd /usr/local/src/ATRAM"
  if [ "${site}" == "clu" ]; then
      echo "Launching NetServer in site ${site}..."
      ssh ${site}-nt "${cmd} ; ./netserver.sh &>netServer.log &"
  else
      echo "Launching NetPerf in site ${site}..."
      ssh ${site}-nt "${cmd} ; ./netperf.sh &>netPerf.log &"
  fi
  echo -e "\tDONE"
done

echo -e "Waiting until timeout expires..."
let tInSec=${timeout}*60
sleep ${tInSec}
echo -e "\tDONE\nLaunching STOP script in all nodes"

# Not in background to stop every process
cmd="cd /usr/local/src/ATRAM ; ./stop.sh &>stop.log"
for (( CNTR=1; CNTR<=${sitesNo}; CNTR+=1 )); do
  site=`cat mapNetTool | head -${CNTR} | tail -1 | awk '{print $1}'`
  echo "Doing STOP in site ${site}..."
  ssh ${site}-nt "${cmd}" 
  echo -e "\tDONE\nFetching logs from site ${site}..."
  scp ${site}-nt:/usr/local/src/ATRAM/*.log ${logs}/
  echo -e "\tDONE"
done

logsN=`date +%F_%H.%M`
mv ${logs} ${logsN}
tar czf ${logsN}.tgz ${logsN}
