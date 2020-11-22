#!/bin/sh

APP=/mnt/microsd/statistics
AMOUNT=500

( tail -f /dev/irqgen | tee /root/latencies.csv | $APP ) &

for i in $(seq 1 10); do
    for line in $(seq 0 15); do
        for delay in 0 100 1000 10000; do
            tgt=$(($AMOUNT + $(cat /sys/kernel/irqgen/total_handled)))
            echo $line > /sys/kernel/irqgen/line
            echo $delay > /sys/kernel/irqgen/delay
            echo $AMOUNT > /sys/kernel/irqgen/amount


            while : ; do
                if [ $tgt -le $(cat /sys/kernel/irqgen/total_handled) ]  ; then
                    break
                fi

                sleep 0.1
            done
        done
    done
done

sleep 5

# Might not work -> Use ps to find process id and kill it manually
kill -INT %1

