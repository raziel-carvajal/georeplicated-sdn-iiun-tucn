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

if [ ${#} -lt 4 ] ; then
  echo "USAGE: $0 [method] [cloud application] [remote tar file] [destination directory]"
  exit 1
fi

method=$1
cloudA=$2
remFil=$3 #<< /PATH/file.ext
dstDir=`dirname ${4}`

echo "Input: ${method} ${cloudA} ${remFil} ${dstDir}"

#TODO VERIFY STRINGS (VERY IMPORTANT)
#TODO CHECK IF DESTINATION DIRECTORY EXISTS
#XXX take into consideration that this tar file contains three datasets: OWD/ATR/(ZK | ISPN)

rm -fr tmp ; mkdir tmp ; cd tmp ; origin=`pwd` 
#TODO CHECK IF REMOTE FILE WITH FULL PATH IS PRESENT
#scp dionasys-controller:${remFil} .

tarFi=`basename ${remFil}`
tarFi="${tarFi}"

echo "${tarFi}"

tar -xzvf "test.tgz"
echo "END"
exit 1
tgetDir=${dstDir}/${method}
mv ${tarFi} ${tgetDir}

i=$((${#tarFi}-4))
diName=${tar:0:${i}}

tmp=${tgetDir}/atr/${diName}
mkdir ${tmp}
mv ${diName}/atr/*.parAtr ${tmp}
cd ${tgetDir}/atr ; rm -f current
ln -s ${diName} current

cd ${origin}

tmp=${tgetDir}/owd/${diName}
mkdir ${tmp}
mv ${diName}/owd/*.parOwd ${tmp}
cd ${tgetDir}/owd ; rm -f current
ln -s ${diName} current

cd ${origin}/${diName}
tar xof ${cloudA}.tgz

tmp=${tgetDir}/${cloudA}/${diName}
mkdir ${tmp}
mv ${cloudA}/*.out ${tmp}
cd ${tgetDir}/${cloudA} ; rm -f current
ln -s ${diName} current

cd ${origin} ; cd .. ; rm -fr tmp
