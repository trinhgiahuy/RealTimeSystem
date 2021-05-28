		------Running IRQ latency test and plotting with gnuplot------

Running the testandplot.sh will use scp to transfer the pynq/irqtest.sh bash script the to target device
if the ip_address variable is set correctly. The test script is run on the target board and it will
generate 100 sets of interrupts each consisting of 500 IRQs.

When the irqtest.sh is done running on the board the file latencies.csv is downloaded using scp.
It is then parsed with python and fed to gnuplot for plotting.

Running testandplot.sh with "-t" as the first argument will run linux_tools_torture.sh script on the board to test the system under heavy load (and will automatically stop the torture script after collecting the data).

When the first argument is "-nc", the collection phase is skipped and only the postprocessing and plotting is run. When using "-nc", by default it will render "latencies.csv", but using a filepath as the second argument will instead render the specified file.

		------RT patch additional kernel options------

When testing with RT patch the IRQ handler threads can be given higher priority with the chrt-program, 99 being the highest possible value:
	root@pynq:/# chrt -f -p 99 <PID>

The PID can be resolved with the ps-program for each IRQ:
	root@pynq:/# ps

Or, alternatively:
	root@pynq:/# grep irqgen /proc/*/comm

Also the RT threads can be given full CPU time by writing value 1000000 to sched_rt_runtime_us file:
	root@pynq:/# echo "1000000" > /proc/sys/kernel/sched_rt_runtime_us
