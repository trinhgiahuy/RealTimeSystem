#!/bin/sh
while read line
do
   kill $line
done < /tmp/torture.pid

killall wget >/dev/null 2>&1
killall dd >/dev/null 2>&1
killall hackbench >/dev/null 2>&1
killall ls >/dev/null 2>&1
killall sleep >/dev/null 2>&1
