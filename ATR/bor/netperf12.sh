#!/bin/bash
#IP12=10.0.12.19
IP12=172.16.16.89
PORT12=5012
S=1
fileName=measure/neu-bor.txt
fileNameA=measure/atr.txt
fileNameB=measure/time.txt
fileNameReverse=measure/bor-neu.txt
rawFile=measure12.txt
### ATR+OWD part
while [ "$(cat ready.txt)" == "c" ]
	do
                netperf -H $IP12 -p $PORT12 -l 10 >> $rawFile
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