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
rm -rf em.log
./emulate-rtt-stream.sh &> em.log &
echo "Waiting before killing rtt-emulator"
sleep ${wait}
echo "DONE"

touch STOP
echo "END of ${0}"
