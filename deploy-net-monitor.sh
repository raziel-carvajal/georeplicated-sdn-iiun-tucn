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
echo "without iperf: USAGE: $0 [Number of minutes to let ATR and OWD be measured]" 
 echo "with iperf: USAGE: $0 [Number of minutes to let ATR and OWD be measured][iperf server:clu neu lan bor][iperf server IP][iperf client:clu neu lan bor][iperf time:seconds][traffic bandwidth: eg. 20M]"
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
      ssh ${site}-nt-tucn "${cmdAtr} ; ./netserver.sh &>${site}-netServer.log &"
      echo -e "\tLaunching process to measure OWD"
      ssh ${site}-nt-tucn "${cmdOwd} ; ./matlab_script.sh &>${site}-mathLab.log &"
      #timeout for waiting MathLab to be launched
      sleep ${MATHLAB_TIMEOUT}
      echo -e "\t\tDONE\n\tDONE"
  else
      echo "Launching NetPerf in site: ${site}"
      ssh ${site}-nt-tucn "${cmdAtr} ; ./netperf.sh &>${site}-netPerf.log &"
      echo -e "\tDONE"
      echo "Launching process to measure OWD in site: ${site}"
      ssh ${site}-nt-tucn "${cmdOwd} ; ./multicastOWD -p 5000 &>${site}-owd.log &"
      echo -e "\tDONE"
  fi
done

echo -e "\tLaunching process to measure OWD in Cluj"
ssh clu-nt-tucn "${cmdOwd} ; ./multicastOWD -s -p 5000 &>${site}-owd.log &"
echo -e "\tDONE"

if [ ${#} -eq 6 ] ; then
	  server=${2}
	  serverIP=${3}
	  client=${4}
	  timeIperf=${5}
	  bandwidth=${6}
      echo "Launching iperf server on: ${server}-server and ${client}-client"
      ssh ${server}-nt-tucn "${cmdOwd} ; iperf -s -p 5010 -u &>${server}-iperf.log &"
      echo "Launching iperf server on: ${server}-server and ${client}-client"
      ssh ${client}-nt-tucn "${cmdOwd} ; iperf -c ${serverIP} -p 5010 -t ${timeIperf} -u -b ${bandwidth} -i 1 &>${client}-iperf.log &"
fi

echo -e "Waiting until timeout expires"
let tInSec=${timeout}*60
sleep ${tInSec}
echo -e "\tDONE\nLaunching STOP script in all nodes"

  echo "Doing STOP of OWD measurements in site Cluj..."
  ssh clu-nt-tucn "${cmdOwd} ; ./stopOWD.sh &>clu-owd-stop.log"

# Not in background to stop every process
for (( CNTR=${sitesNo}; CNTR>=1; CNTR-=1 )); do
  site=`cat mapNetTool | head -${CNTR} | tail -1 | awk '{print $1}'`
  echo "Doing STOP of OWD/ATR measurements in site ${site}..."
  ssh ${site}-nt-tucn "${cmdAtr} ; ./stop.sh &>${site}-atr-stop.log" 
  ssh ${site}-nt-tucn "${cmdOwd} ; ./stopOWD.sh &>${site}-owd-stop.log" 
  echo -e "\tDONE\nFetching logs from site ${site}..."
  scp ${site}-nt-tucn:/usr/local/src/ATRAM/*.log ${logs}/
  scp ${site}-nt-tucn:/usr/local/src/*.log ${logs}/
  echo -e "\tDONE"
done

logsN=`date +%F_%H.%M`
mv ${logs} ${logsN}
tar czf ${logsN}.tgz ${logsN}
