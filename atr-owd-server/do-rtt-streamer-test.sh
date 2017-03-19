#!/bin/bash - 
#===============================================================================
#
#          FILE: do-rtt-streamer-test.sh
# 
#         USAGE: ./do-rtt-streamer-test.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/16/2017 11:40
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} -lt 1 ] ; then
  echo "USAGE: ${0} [Number of seconds to let the rtt-emulator running]"
  exit 1
fi

wait=${1}
rm -rf em.log server.log

echo "Start simulation of RTT measures (look at tmp file)"
./emulate-rtt-stream.sh &> em.log &
sleep 3
echo -e "\tDONE"

echo "Launch server to fetch stream of ATR/RTT"
DEBUG=RttStreamer:*,AtrOwdServer:* node BootstrapRttAwdServer.js &> server.log &
sleep 3
echo -e "\tDONE"

echo -e "Write down address localhost:3000 in your browser\nWaiting before killing ${0}"
sleep ${wait}
echo -e "\tDONE"

touch STOP ; pkill node
echo "END of ${0}"
