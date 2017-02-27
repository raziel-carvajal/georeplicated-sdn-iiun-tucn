#!/bin/bash - 
#===============================================================================
#
#          FILE: doIspnDataset.sh
# 
#         USAGE: ./doIspnDataset.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 02/26/17 22:04
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} -lt 2 ] ; then
    tmp="[Directory where ISPN dataset stored (YCSB load/run output)]"
    tmp="${tmp} [string 'siteA-siteB' to refer that siteA launched YCSB"
    tmp="${tmp} and siteB was an ISPN server"
    echo "USAGE: ${0} ${tmp}"
    exit 1
fi
dsIspnDir=`dirname ${1}` ; cmpl=`basename ${1}` ; dsIspnDir="${dsIspnDir}/${cmpl}"
loadF="${dsIspnDir}/load.out"
if [ ! -f ${loadF} ] ; then
  echo "ERROR: YCSB-load (writes) output doesn't exist"
  exit 1
fi
runF="${dsIspnDir}/run.out"
if [ ! -f ${runF} ] ; then
  echo "ERROR: YCSB-run (reads) output doesn't exist"
  exit 1
fi
#TODO check that ${link} is a valid string
link=${2} ; rm -fr tmp1 tmp2 tmp3

#TODO once you have chosen which launch YCSB you must plot 6 distributions,
#     one distribution for writes and another one for reads of 3 sites
dstF="${dsIspnDir}/${link}.dat"

echo "#writes ws-timestamp " >tmp1
grep "INSERT," ${loadF} | awk -F "," '{print $3,$2}' >tmp2
paste -d " " tmp1 tmp2 >tmp3

echo "reads rs-timestamp" >tmp1
grep "READ," ${runF} | awk -F "," '{print $3,$2}' >>tmp1
paste -d " " tmp3 tmp1 >${dstF}

rm -fr tmp1 tmp2 tmp3
