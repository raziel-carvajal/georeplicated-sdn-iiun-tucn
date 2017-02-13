#!/bin/bash - 
#===============================================================================
#
#          FILE: killNetTool.sh
# 
#         USAGE: ./killNetTool.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/13/2017 15:00
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
echo "Killing NetTool in BOR"
ssh bor-nt 'pkill pathload_snd'
echo -e "\tDONE"
echo "Killing NetTool in BOR"
ssh clu-nt 'pkill pathload_snd'
echo -e "\tDONE"
echo "Killing NetTool in BOR"
ssh neu-nt 'pkill pathload_snd'
echo -e "\tDONE"
echo "Killing NetTool in BOR"
ssh lan-nt 'pkill pathload_snd'
echo -e "\tDONE"
