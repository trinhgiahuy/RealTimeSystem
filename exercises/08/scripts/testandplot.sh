#!/bin/bash

# IP address of the running PYNQ board
ip_address=0.0.0.0

PYNQ_DIR=/root/rt-scripts
DESTFILE=latencies.csv
MODNAME="irqgen"
ITERATIONS=100
IRQ_AMOUNT=500
IRQ_DELAY=0
IRQ_LINE=5

NO_COLLECT="false"
TORTURE="false"

if [[ "x$1" == "x-t" ]]; then
    TORTURE="true"
    shift
fi

if [[ "x$1" == "x-nc" ]]; then
    NO_COLLECT="true"
    if [[ ! -z "$2" ]]; then
        DESTFILE=$2
    fi
fi

print_metadata() {
    echo "PYNQ_UNAME=$PYNQ_UNAME"
    echo "IS_RT=$IS_RT"
    echo "ip_address=$ip_address"
    echo "MODNAME=$MODNAME"
    echo "ITERATIONS=$ITERATIONS"
    echo "IRQ_AMOUNT=$IRQ_AMOUNT"
    echo "IRQ_DELAY=$IRQ_DELAY"
    echo "IRQ_LINE=$IRQ_LINE"
    echo "TORTURE=$TORTURE"
}

if [[ ! "$NO_COLLECT" == "true" ]]; then
    ping -q -c1 $ip_address > /dev/null

    # Test if there is a connection to the board
    if [ ! $? -eq 0 ]; then
        echo "No connection to $ip_address"
        echo "Check the network settings"
        exit
    fi

    echo -n "Connected to: "
    ssh root@$ip_address "uname -a"
    # Test if there is a connection to the board
    if [ ! $? -eq 0 ]; then
        echo "Cannot SSH into $ip_address"
        exit
    fi
    PYNQ_UNAME=$(ssh root@$ip_address "uname -a")

    IS_RT="false"
    REGEX="\sPREEMPT RT\s"
    if [[ "$PYNQ_UNAME" =~ $REGEX ]]; then
        IS_RT="true"
    fi

    # Check if the DESTFILE already exists
    if [ -f $DESTFILE ]; then
        echo "$DESTFILE already exists! Saving old data to $DESTFILE.old"
        mv $DESTFILE $DESTFILE.old
        mv $DESTFILE.meta $DESTFILE.meta.old
    fi

    print_metadata > $DESTFILE.meta

    # Transfer the irqtest.sh script to the board
    echo ""
    echo "Transferring ./pynq/irqtest.sh to the PYNQ board.."
    ssh root@$ip_address "mkdir -p $PYNQ_DIR"
    scp pynq/irqtest.sh root@$ip_address:$PYNQ_DIR/
    echo ""
    # Insert the IRQ generator driver module to the kernel
    ssh root@$ip_address "/sbin/modprobe $MODNAME"

    if [[ "$TORTURE" == "true" ]]; then
        scp pynq/linux_tools_torture.sh root@$ip_address:$PYNQ_DIR/
        scp pynq/linux_tools_stoptorture.sh root@$ip_address:$PYNQ_DIR/

        echo "Starting linux_tools_torture.sh"
        ssh root@$ip_address "$PYNQ_DIR/linux_tools_torture.sh"
    fi

    # Run the test script
    ssh root@$ip_address "/usr/bin/time $PYNQ_DIR/irqtest.sh /root/$DESTFILE $ITERATIONS $IRQ_LINE $IRQ_DELAY $IRQ_AMOUNT"

    if [[ "$TORTURE" == "true" ]]; then
        echo "Stopping linux_tools_torture.sh"
        ssh root@$ip_address "$PYNQ_DIR/linux_tools_stoptorture.sh"
    fi

    # Download the latency data
    echo ""
    echo "Downloading $DESTFILE from the PYNQ board.."
    scp root@$ip_address:/root/$DESTFILE .
    echo ""

    # Check if the download succeeded
    if [ ! -f $DESTFILE ]; then
        echo "Could not download $DESTFILE from PYNQ"
        exit
    fi
fi


# Check if there is data in the file
filesize=$(stat --printf="%s" $DESTFILE)
if [ $filesize = 0 ]; then
    echo "No data in $DESTFILE! Removing and exiting.."
    rm $DESTFILE
    exit
fi

filelines=$(cat $DESTFILE | wc -l)
echo "$DESTFILE contains $filelines lines"

# Find the lowest and highest recorded latencies from the file
minmax=$(python csv2minmax.py <$DESTFILE)
lmin=$(echo $minmax | cut -d" " -f1)
lmax=$(echo $minmax | cut -d" " -f2)
echo "Lowest recorded latency: $lmin"
echo "Highest recorded latency: $lmax"
llmin=$(echo $minmax | cut -d" " -f3)
llmax=$(echo $minmax | cut -d" " -f4)
echo "Power of 10 boundaries: $llmin, $llmax"


if true; then

# Format the file according to Gnuplot script expectations
python csv2dat.py <$DESTFILE >$DESTFILE.dat

# Prepare the gnuplot script
cat >plot_latencies.gpi <<EOF
set terminal pdfcairo
set output "$DESTFILE.pdf"
set xlabel 'IRQ request (no)'
set ylabel 'IRQ latency (clk)'
set yrange [$lmin:$lmax]
set yrange [$llmin:$llmax]
#set yrange [1000:10000000]
set logscale y 10
set xrange [-10:]
set title "IRQ latency test"
plot for[i=0:$(($ITERATIONS-1))] "$DESTFILE.dat" matrix index i every ::0 w lines notitle
exit
EOF

# Plot the latencies using gnuplot script
gnuplot plot_latencies.gpi

# Open the generated latency plot .pdf file
xdg-open $DESTFILE.pdf

else
# Format the file according to Gnuplot script expectations
python csv2dat2.py <$DESTFILE >$DESTFILE.dat

# Prepare the gnuplot script
cat >plot_latencies.gpi <<EOF
#set terminal pdfcairo
#set output "latencies.pdf"
set xlabel 'Time from first handled (ns)'
set ylabel 'IRQ latency (clk)'
set yrange [$lmin:$lmax]
set yrange [$llmin:$llmax]
#set yrange [1000:10000000]
set logscale y 10
#set xrange [-10:]
set title "IRQ latency test"
plot for[i=0:$(($ITERATIONS-1))] "$DESTFILE.dat" index i using 1:2 with lines notitle
#exit
EOF

gnuplot -p plot_latencies.gpi

fi



