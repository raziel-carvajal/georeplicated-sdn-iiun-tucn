#!/bin/bash - 
#===============================================================================
#
#          FILE: doDistribution.sh
# 
#         USAGE: ./doDistribution.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/15/2017 11:08
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#TODO CHECK THAT DIRECTORIES PATH ENDS WITH SLASH '/' 
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
rm -fr ${dstD} tmp
mkdir ${dstD}
mkdir ${dstD}/atr
mkdir ${dstD}/owd
origin=`pwd`
cd ${rawD}
ite=`ls *.out | awk -F "-" '{print $3}' | sort | uniq | tail -1`
echo "Number of iterations ${ite}"
cd ${origin}

links=`cat allLinks | wc -l`
x=0
for (( CNTR=1; CNTR<=${ite}; CNTR+=1 )); do
  #This order is importat just when the distribution is shown as function of time
  echo "Doing iteration ${CNTR}"
  for site in `echo -e "neu\nclu\nlan\nbor"`; do
    echo "Getting data from site ${site}"
    grep "^${site}-" allLinks >tmp
    for link in `cat tmp` ; do
      finAtrF="${dstD}/atr/${link}.dat"
      finOwdF="${dstD}/owd/${link}.dat"
      atrF="${atrD}${link}-${CNTR}-atr.parAtr"
      owdF="${owdD}${link}-${CNTR}-owd.parOwd"
      if [ ! -f ${owdF} ] ; then
        if [ ! -f ${atrF} ] ; then
          echo "NA point/dataset for both OWD and ATR at iteration ${CNTR} of link ${link}"
          #XXX nothing to add at the distribution (non available points)
        else
          cat ${atrF} | head -1 >>${finAtrF}
        fi
      else
        cat ${owdF} >>${finOwdF}
        if [ ! -f ${atrF} ] ; then
          echo "NA point/dataset for ATR at iteration ${CNTR} of link ${link}"
        else
          cat ${atrF} | head -1 >>${finAtrF}
        fi
      fi
    done
  done
done
rm -fr tmp
