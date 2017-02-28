#!/bin/bash
#IP13=10.0.13.13
IP13=172.16.16.89
PORT13=5013
S=1
fileName=measure/neu-lan.txt
fileNameA=measure/atr.txt
fileNameB=measure/time.txt
fileNameReverse=measure/lan-neu.txt
rawFile=measure13.txt
### ATR+OWD part
while [ "$(cat ready.txt)" == "c" ]
	do
                netperf -H $IP13 -p $PORT13 -l 10 >> $rawFile
				echo 20`date '+%y.%m.%d.%H.%M.%S.%3N'` >> $rawFile
        done
#Write every 8th line in file
awk 'NR % 8 == 7 {print$5}' $rawFile >> $fileNameA
awk 'NR % 8 == 0' $rawFile >> $fileNameB
paste $fileNameA $fileNameB > $fileName
cp $fileName $fileNameReverse
#Clean
rm $rawFile $fileNameA $fileNameB
scp -i id_rsa $fileName $fileNameReverse stack@192.168.100.11:/home/stack/TUCN_Measurements/ATR/ &