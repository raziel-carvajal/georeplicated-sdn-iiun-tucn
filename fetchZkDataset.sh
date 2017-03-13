#!/bin/bash - 
#===============================================================================
#
#          FILE: fetchZkDataset.sh
# 
#         USAGE: ./fetchZkDataset.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 03/05/2017 21:12
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} -lt 3 ] ; then
  echo "USAGE: $0 [remote tar file] [destination directory] [site where ZK-benchmark was launched]"
  exit 1
fi

remFil=$1 #<< /PATH/file.ext
dstDir=`dirname ${2}`
compl=`basename ${2}`
zkCli=${3}
dstDir=${dstDir}/${compl}

#TODO VERIFY STRINGS (VERY IMPORTANT)
#TODO CHECK IF DESTINATION DIRECTORY EXISTS
#XXX take into consideration that this tar file contains three datasets: OWD/ATR/(ZK | ISPN)
#TODO CHECK IF REMOTE FILE WITH FULL PATH IS PRESENT
rm -fr tmp ; mkdir tmp ; origin=`pwd` 
cp zkDeploymentCfg tmp/
cd tmp 

scp dionasys-controller:${remFil} .
tarFi=`basename ${remFil}`
tar xof ${tarFi}
mv ${tarFi} ${dstDir}
i=$((${#tarFi}-4))
diName=${tarFi:0:${i}}


tmp=${dstDir}/${diName}
rm -fr ${tmp} ; mkdir ${tmp}
zNodes=`cat zkDeploymentCfg | wc -l`
for (( CNTR=1; CNTR<=${zNodes}; CNTR+=1 )); do
  nodeIx=`cat zkDeploymentCfg | head -${CNTR} | tail -1 | awk '{print $1}'`
  nodeId=`cat zkDeploymentCfg | head -${CNTR} | tail -1 | awk '{print $2}'`
  wriFil="${zkCli}-${nodeId}-writs.dat"
  reaFil="${zkCli}-${nodeId}-reads.dat"
  cat ${diName}/${nodeIx}-READ_timings.dat | awk '{print 1000*($2-$1)}'      >${reaFil}
  cat ${diName}/${nodeIx}-SETSINGLE_timings.dat | awk '{print 1000*($2-$1)}' >${wriFil}
  mv ${reaFil} ${tmp} ; mv ${wriFil} ${tmp} 
done

cd ${dstDir} ; rm -f current
ln -s ${diName} current
cd ${origin} ; rm -fr tmp
