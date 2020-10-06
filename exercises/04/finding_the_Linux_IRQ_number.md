# Finding the *magic* IRQ number

While filling `irqgen.c`, you will have to define a variable mapping the first IRQ line of the IP block to the corresponding Linux IRQ number.
This is a surprisingly difficult step, and luckily one we will remove once we will develop a proper platform device driver.

## Of interrupt lines, HW IRQ numbers and Linux IRQ numbers...

Reading the IP spec you will discover that the 16 IRQ lines of the IRQ Generator block are connected to a (non contiguous) sequence of HW IRQ.

Once you determine the HW IRQ for the first line, you should know that Linux kernel drivers don't directly use the HW IRQ number, e.g., when calling `request_irq()`: instead the kernel provides its own mapping layer.
So you will have to determine the Linux IRQ number corresponding to our HW IRQ number.

The snippet below gives some information on how to manually solve this problem.
Remember, this is quite hackish for now, but, once we will have a full-fledged platform device driver, we will use the kernel API to discover the proper Linux IRQ numbers for our device.

```bash
#
#
#    *---------------*           *----------------*            *---------------*
#    |               |16    HW_16|       |        |   LIRQ_16  |               |
#    |               |---------->|       |        |----------->|               |
#    | IRQ Generator |...     ...|  CPU  | Kernel |...      ...| Device Driver |
#    |               |---------->|       |        |----------->|               |
#    |               |0      HW_0|       |        |   LIRQ_0   |               |
#    *---------------*           *----------------*            *---------------*
#
#

# The Linux kernel exposes the mappings between HWIRQ, LINUXIRQ and associated
# device through the sysfs pseudo filesystem.

cd /sys/kernel/irq
ls -F # will show you a list of folders, each named after one of the available
      # LINUXIRQs
ls * # will show you a list of pseudofiles with interesting information, among
     # which the associated driver and the corresponding HWIRQ.

grep -s <HWIRQ> */hwirq # will show you which Linux IRQ
                        # number (folder name) is mapped to
                        # your HWIRQ

```
