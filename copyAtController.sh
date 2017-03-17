#!/bin/bash - 
#===============================================================================
#
#          FILE: copyAtController.sh
# 
#         USAGE: ./copyAtController.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/13/2017 01:27
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

files="measure-rtt-atr.sh killIperfPingProc.sh mapNetTool linksNetTool"
scp ${files} dionasys-controller:~/iiun-scripts/georeplicated-sdn-iiun-tucn
