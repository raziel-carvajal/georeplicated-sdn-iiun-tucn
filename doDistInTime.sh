#!/bin/bash - 
#===============================================================================
#
#          FILE: doDistInTime.sh
# 
#         USAGE: ./doDistInTime.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/14/2017 17:25
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#TODO WRITE DIRECTORIES WITH CHAR '/' AT END OF STRING
if [ $# -lt 3 ]; then
  echo "USAGE: $0 [Directory of raw data] [Directory of ATR logs] [Directory of OWD logs]"
  exit 1
fi
rawD=$1
if [ ! -d "${rawD}" ] ; then
  echo "ERROR: raw data directory doesn't exist or it isn't vaild"
  exit 1
fi
atrD=$2
if [ ! -d "${atrD}" ] ; then
  echo "ERROR: ATR directory doesn't exist or it isn't vaild"
  exit 1
fi
owdD=$3
if [ ! -d "${owdD}" ] ; then
  echo "ERROR: OWD directory doesn't exist or it isn't vaild"
  exit 1
fi

dstD="dataset"
rm -fr ${dstD}
mkdir ${dstD}
origin=`pwd`

cd ${rawD}
ite=`ls *.out | awk -F "-" '{print $3}' | sort | uniq | tail -1`
cd ${origin}
cd ${owdD}
wS=`ls -S *.parOwd | head -1 | cat | wc -l`
cd ${origin}
links=`cat allLinks | wc -l`
x=0
for (( CNTR=1; CNTR<=${ite}; CNTR+=1 )); do
  for site in `echo -e "neu\nclu\nlan\nbor"`; do
    grep "^${site}-" >tmp
    for link in `cat tmp` ; do
      atrF="${atrD}${link}-atr.parAtr"
      owdF="${owdD}${link}-owd.parOwd"
      if [ ! -f ] ; then
      else
      fi
    done
  done
done
