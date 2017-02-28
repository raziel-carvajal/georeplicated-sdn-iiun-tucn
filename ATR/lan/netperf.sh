#!/bin/bash
#Server part
killall netserver
netserver -p 5023
S=1
### ATR+OWD part
touch ready.txt
echo "c" > ready.txt
./netperf13.sh &
./netperf34.sh &
#Clean
sleep 3
