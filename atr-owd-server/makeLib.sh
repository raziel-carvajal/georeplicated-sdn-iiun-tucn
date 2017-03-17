#!/bin/bash - 
#===============================================================================
#
#          FILE: makeLib.sh
# 
#         USAGE: ./makeLib.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/18/2017 00:16
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
rm -fr lib/NetMonitor.js
browserify main.js -o NetMonitor.js
mv NetMonitor.js lib/
