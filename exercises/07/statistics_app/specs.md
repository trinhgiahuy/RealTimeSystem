# `statistics` Standalone App through the Yocto Standard SDK

The second part of Exercise 7 requires developing a standalone C application, cross-compile it using the provided SDK and run it on the PYNQ board from the microSD card.

The application must be created from scratch, and its source should be committed to your repository in the same folder that contains this file.

## Installing and Using the Yocto SDK

For more info read [../yocto_sdk.md][../yocto_sdk.md].

To test if everything is correctly working you might want to write a very short HelloWorld.c file and cross-compile it:

```c
/* HelloWorld.c */
#include <stdio.h>

int main(int argc, char **argv)
{
    printf("Hello World!\n");
    return 0;
}
```

```bash
cd <this very folder>
source ~/opt/poky-sdk/2.4.3/environment-setup-cortexa9hf-neon-poky-linux-gnueabi
make HelloWorld
```

Copy the `HelloWorld` executable on the microSD card and make sure it work on the PYNQ board.

## `statistics` specs

- the application MUST continuously read from `stdin`
- the expected input format expected to match the CSV file format described for `/dev/irqgen`
- the reading loop MUST be terminated upon receiving `SIGINT` (Ctrl+C)
- after the reading loop the program must print to stdout the following statistics:
  - for each line, it MUST print the line number, the number of events, the average and the worst case latency (in clock cycles)
  - finally, the same statistics should be printed on a final additional line presenting the same values, without differentiating based on the interrupt line of the recorded event
  - the timestamps in each line should be consumed and ignored
- after printing the statistics the program terminates gracefully
- DO NOT CALL IO FUNCTIONS FROM A SIGNAL HANDLER, not even in userspace code

### Example output

~~~csv
0,30,215.82,925
1,30,218.40,669
2,30,202.80,908
3,30,267.60,733
4,30,259.00,957
5,30,244.20,998
6,30,228.10,644
7,30,262.10,453
8,30,201.70,518
9,30,170.80,552
10,30,243.10,969
11,30,205.10,461
12,30,236.20,830
13,30,277.20,518
14,30,175.90,579
15,10,175.70,467
-1,460,226.08,998
~~~

## Tips

- Rather than repeating frustrating cycles of modifying the source code, cross-compiling, saving to the microSD, then execute and debug on the PYNQ board, it might be useful and quicker to develop and debug on the same machine: you can save in a long CSV file the output of `/dev/irqgen` on the PYNQ board and transfer it to your VM using the microSD.
- Use that input as the `stdin` of your program, compiling it for your development machine architecture and using the VM debugging and development tools
- Only when the application seems to be working as specified, you actually start cross-compiling it using the SDK and make sure there are no leftover issues
- DO NOT CALL IO FUNCTIONS (e.g., `printf`) FROM A SIGNAL HANDLER, not even in userspace code: it's better for the SIGINT handler to just modify some flag variable to terminate the main reading loop, and then execute IO from the normal contest.
- You don't need to allocate large memory buffers to solve this problem: use float/double accumulators for each line and integer counters
