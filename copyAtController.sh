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

files="deploy-net-monitor.sh mapNetTool"
scp ${files} dionasys-controller:~/tucn-scripts/georeplicated-sdn-iiun-tucn
