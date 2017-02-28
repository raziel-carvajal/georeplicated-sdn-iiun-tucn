#!/bin/bash
#IP14=10.0.14.7
IP14=172.16.16.77
PORT14=5014
S=1
fileName=measure/neu-clj.txt
fileNameA=measure/atr.txt
fileNameB=measure/time.txt
fileNameReverse=measure/clj-neu.txt
rawFile=measure14.txt
### ATR+OWD part
touch ready.txt
echo "c" > ready.txt
while [ "$(cat ready.txt)" == "c" ]
        do
                netperf -H $IP14 -p $PORT14 -l 10 >> $rawFile
				echo 20`date '+%y.%m.%d.%H.%M.%S.%3N'` >> $rawFile
        done
unset continue
#Write every 8th line in file
awk 'NR % 8 == 7 {print$5}' $rawFile >> $fileNameA
awk 'NR % 8 == 0' $rawFile >> $fileNameB
paste $fileNameA $fileNameB > $fileName
cp $fileName $fileNameReverse
#Clean
rm $rawFile $fileNameA $fileNameB
scp -i id_rsa $fileName $fileNameReverse stack@192.168.100.11:/home/stack/TUCN_Measurements/ATR/ &