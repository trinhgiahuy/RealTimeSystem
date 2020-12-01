#!/bin/sh
while [ 1 ] ; do wget -O - ftp://ftp.funet.fi/dev/100MBnull > /dev/null 2>&1; done &
echo $! > /tmp/torture.pid

dd if=/dev/zero of=/dev/null &
echo $! >> /tmp/torture.pid

while true; do killall hackbench  > /dev/null 2>&1; sleep 5; done &
echo $! >> /tmp/torture.pid

while true; do ./hackbench 1 > /dev/null 2>&1; done &
echo $! >> /tmp/torture.pid

while true; do ls -lR / > /dev/null 2>&1; done &
echo $! >> /tmp/torture.pid

while true; do ls -lR /media > /dev/null 2>&1; done &
echo $! >> /tmp/torture.pid
