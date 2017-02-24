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
MATHLAB_TIMEOUT=10
if [ ${#} -lt 1 ] ; then
  echo "USAGE: $0 [Number of minutes to let ATR and OWD be measured]"
  exit 1
fi
timeout=${1}
logs="tucn-logs"
rm -fr ${logs} ; mkdir ${logs}

sitesNo=`cat mapNetTool | wc -l`
echo "Deploying TUCN tool"
cmdAtr="cd /usr/local/src/ATRAM"
cmdOwd="cd /usr/local/src"
for (( CNTR=1; CNTR<=${sitesNo}; CNTR+=1 )); do
  site=`cat mapNetTool | head -${CNTR} | tail -1 | awk '{print $1}'`
  if [ "${site}" == "clu" ]; then
      echo "Launching NetServer in site: ${site}"
      ssh ${site}-nt "${cmdAtr} ; ./netserver.sh &>${site}-netServer.log &"
      echo -e "\tLaunching process to measure OWD"
      ssh ${site}-nt "${cmdOwd} ; ./matlab_script.sh &>${site}-mathLab.log &"
      #timeout for waiting MathLab to be launched
      sleep ${MATHLAB_TIMEOUT}
      echo -e "\t\tDONE\n\tDONE"
  else
      echo "Launching NetPerf in site: ${site}"
      ssh ${site}-nt "${cmdAtr} ; ./netperf.sh &>${site}-netPerf.log &"
      echo -e "\tDONE"
  fi
  echo "Launching process to measure OWD in site: ${site}"
  ssh ${site}-nt "${cmdOwd} ; ./multicastOWD -p 5000 &>${site}-owd.log &"
  echo -e "\tDONE"
done

echo -e "Waiting until timeout expires"
let tInSec=${timeout}*60
sleep ${tInSec}
echo -e "\tDONE\nLaunching STOP script in all nodes"

# Not in background to stop every process
for (( CNTR=1; CNTR<=${sitesNo}; CNTR+=1 )); do
  site=`cat mapNetTool | head -${CNTR} | tail -1 | awk '{print $1}'`
  echo "Doing STOP of OWD/ATR measurements in site ${site}..."
  ssh ${site}-nt "${cmdAtr} ; ./stop.sh &>${site}-atr-stop.log" 
  ssh ${site}-nt "${cmdOwd} ; ./stopOWD.sh &>${site}-owd-stop.log" 
  echo -e "\tDONE\nFetching logs from site ${site}..."
  scp ${site}-nt:/usr/local/src/ATRAM/*.log ${logs}/
  scp ${site}-nt:/usr/local/src/*.log ${logs}/
  echo -e "\tDONE"
done

logsN=`date +%F_%H.%M`
mv ${logs} ${logsN}
tar czf ${logsN}.tgz ${logsN}
