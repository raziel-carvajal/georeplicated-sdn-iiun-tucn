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
compl=`basename ${4}`
dstDir=${dstDir}/${compl}
echo -e "Input:\n${method}\n${cloudA}\n${remFil}\n${dstDir}"

#TODO VERIFY STRINGS (VERY IMPORTANT)
#TODO CHECK IF DESTINATION DIRECTORY EXISTS
#XXX take into consideration that this tar file contains three datasets: OWD/ATR/(ZK | ISPN)

#TODO CHECK IF REMOTE FILE WITH FULL PATH IS PRESENT
rm -fr tmp ; mkdir tmp ; cd tmp ; origin=`pwd` 
scp dionasys-controller:${remFil} .
tarFi=`basename ${remFil}`
tar xof ${tarFi}

# XXX this script will work ONLY if ${dstDir} the following SVN directory:
#     /?/dionasys/WP3/sdn_adaptation/papers/georeplicated_sdn/data/baseline
tgetDir=${dstDir}/${method}
mv ${tarFi} ${tgetDir}
i=$((${#tarFi}-4))
diName=${tarFi:0:${i}}

tmp=${tgetDir}/atr/${diName}
rm -fr ${tmp} ; mkdir ${tmp}
mv ${diName}/atr/*.dat ${tmp}
cd ${tgetDir}/atr ; rm -f current
ln -s ${diName} current

cd ${origin}

tmp=${tgetDir}/owd/${diName}
rm -fr ${tmp} ; mkdir ${tmp}
mv ${diName}/owd/*.dat ${tmp}
cd ${tgetDir}/owd ; rm -f current
ln -s ${diName} current

cd ${origin}/${diName}
tar xof ${cloudA}.tgz

tmp=${dstDir}/${cloudA}/${diName}
rm -fr ${tmp} ; mkdir ${tmp}
mv ${cloudA}/*.out ${tmp}
cd ${dstDir}/${cloudA} ; rm -f current
ln -s ${diName} current

cd ${origin} ; cd .. ; rm -fr tmp
