#!/bin/bash
S=1
### ATR+OWD part
touch ready.txt
echo "c" > ready.txt
./netperf12.sh &
./netperf23.sh &
./netperf24.sh &  

sleep 3
