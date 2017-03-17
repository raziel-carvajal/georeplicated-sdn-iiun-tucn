#!/bin/bash - 
#===============================================================================
#
#          FILE: cpyAtControllerDemo1.sh
# 
#         USAGE: ./cpyAtControllerDemo1.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/15/2017 15:20
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
dstSer="./atr-owd-server"
dstCli="./atr-owd-cli"
fSer="" ; fCli=""

fSer=${fSer}"${dstSer}/AtrOwdServer.js "
fSer=${fSer}"${dstSer}/package.json "
fSer=${fSer}"${dstSer}/index.html "
fSer=${fSer}"${dstSer}/atr-rtt-monitor.js "

scp ${fSer} dionasys-controller:~/iiun-scripts/georeplicated-sdn-iiun-tucn/atr-owd-server
#scp ${fCli} dionasys-controller:~/iiun-scripts/georeplicated-sdn-iiun-tucn/atr-owd-cli