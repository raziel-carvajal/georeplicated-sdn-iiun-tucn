#!/bin/bash
#IP24=10.0.24.16
IP24=172.16.16.77
PORT24=5024
S=1
fileName=measure/bor-clj.txt
fileNameA=measure/atr.txt
fileNameB=measure/time.txt
fileNameReverse=measure/clj-bor.txt
rawFile=measure24.txt
### ATR+OWD part
while [ "$(cat ready.txt)" == "c" ]
        do
                netperf -H $IP24 -p $PORT24 -l 10 >> $rawFile
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