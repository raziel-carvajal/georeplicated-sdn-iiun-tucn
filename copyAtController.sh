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

files="deploy-net-monitor.sh linksNetTool mapCloudAp monitor-links.sh"
files=${files}" mapNetTool linksCloudAp killNetTool.sh parse-atr-logs.sh"
files=${files}" parse-owd-logs.sh deployISPN.sh distributedCache.xml ycsbCacheCfg"
files=${files}" ycsbBenchCfg"
scp ${files} dionasys-controller:~/georeplicated-sdn-iiun-tucn
