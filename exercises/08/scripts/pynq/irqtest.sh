#!/bin/sh

#set -x

DESTFILE=$1
ITERATIONS=$2
IRQ_LINE=$3
IRQ_DELAY=$4
IRQ_AMOUNT=$5

SYSFS_ENTRYPOINT="/sys/kernel/irqgen"
TMPFILE_TEMPLATE="/tmp/latencies.csv.tmp_XXXXXX"

echo "PYNQ: Saving ${ITERATIONS} sets of ${IRQ_AMOUNT} IRQ requests on line ${IRQ_LINE} (irq delay=${IRQ_DELAY}) to $DESTFILE"

rm -rf "$DESTFILE"

for i in $(seq $ITERATIONS); do
    echo "    Iteration $i/$ITERATIONS"
    TMPFILE=$(mktemp $TMPFILE_TEMPLATE)

    tail -f /dev/irqgen >$TMPFILE &
    TAIL_PID=$!

    TGT=$(( $IRQ_AMOUNT + $(cat ${SYSFS_ENTRYPOINT}/total_handled) ))

    echo $IRQ_LINE > ${SYSFS_ENTRYPOINT}/line
    echo $IRQ_DELAY > ${SYSFS_ENTRYPOINT}/delay
    echo $IRQ_AMOUNT > ${SYSFS_ENTRYPOINT}/amount # This will trigger IRQ generation

    while : ; do
        [ $(cat ${SYSFS_ENTRYPOINT}/total_handled) == $TGT ] && break
        sleep 0.1
    done

    sleep 1
    sync
    kill $TAIL_PID
    sleep 1
    sync

    cat $TMPFILE >>$DESTFILE        # Append the output of this iteration
    echo >>$DESTFILE                # Append an empty line

    rm $TMPFILE
done
