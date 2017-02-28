#!/bin/bash
#Server part
killall netserver
netserver -p 5012
netserver -p 5013
S=1
### ATR+OWD part
touch ready.txt
echo "c" > ready.txt
./netperf14.sh &

sleep 3
      
