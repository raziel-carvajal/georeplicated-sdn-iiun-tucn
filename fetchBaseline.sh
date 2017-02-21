#!/bin/bash - 
#===============================================================================
#
#          FILE: fetchBaseline.sh
# 
#         USAGE: ./fetchBaseline.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/21/17 17:09
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

method=$1
cloudA=$2

if [ ${#} -lt 2 ] ; then
  exit 1
fi

