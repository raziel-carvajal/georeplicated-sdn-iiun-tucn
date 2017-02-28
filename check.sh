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

echo -e "\tLaunching process to measure OWD in Cluj"


if [ ${#} -eq 6 ] ; then
	  server=${2}
	  serverIP=${3}
	  client=${4}
	  timeIperf=${5}
	  bandwidth=${6}
      echo "Launching iperf server on: ${server}-server and ${client}-client"

fi

echo -e "Waiting until timeout expires"
echo -e "\tDONE\nLaunching STOP script in all nodes"

  echo "Doing STOP of OWD measurements in site Cluj..."


