# TIE-50307 - Exercise 04 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?
To start working driver that is related to the actual hardware device.

## 2. Summarize the functionality provided by the IRQ Generator IP block, then describe what is the purpose of the various registers exposed by the FPGA device. Finally, ignore the fact that you were instructed to look for the base address of the IRQ Generator register space in the provided `devicetree.dts` and instead imagine you were also the developer of the FPGA core design, where would you have found the base address of the register space?
The IRQ generator is fpga block that generates interrupts to processor with its interrupt lines. The generator's behaviour is programmable with it's two integral control register and its status is monitorable with two internal status registers.

The first control register is IRQ_GEN_CTRL_REG and it is the main register which cpu uses to communicate with IRQ, at this point the register contains generator enabling and interrupt acknowledge functionalities. The second control register is IRQ_GEN_GENIRQ_REG, which is written once on the beginning to tell to the IRQ the number of interrupts, them timing and which IRQ lines are used. The status registers are called IRQ_GEN_IRQ_COUNT_REG and IRQ_GEN_IRQ_LATENCY_REG whose names are self-explanatory, they tell the amount of generated interrupts (since start) and the latency (from rising to acknowledging) of the last served interrupt.

For the last questions, the Zilinx Zynq-7000 Reference manual [1, p.112] is a friend. From there can be read, that M_AXI_GP0 (where the IP is connected) address range is 0x4000_0000 to 0x7FFF_FFFF.

## 3. Describe the relationship between interrupt lines in the IRQ Generator, HW IRQ and Linux IRQ numbers, and how did you proceed to discover the IRQ number to use in the driver.
From the IRQ IP the 16 interrupt lines are connected to IRQF2P-lines on the cpu. The reference manual [1, p.231] tells the corresponding hardware IRQ numbers for the IRQF2P lines which are 61-63,64-68 and 84-91, from where the first one (61) is needed in this exercise. The corresponding virtual IRQ number can be found from /sys/kernel/irq, which reveals us IRQ number 45.

## 4. How many interrupt lines are available in the documented FPGA core (refer to the spec, even if we only used one in the *beta* bitstream we were given)?
16

## 5. What value is reported in the devicetree for the first IRQ line? How is it determined? (check the spec document, it has all the required information to map the line number to the HW IRQ on the processing system)
0x0 0x1d 0x4, the reguested value is the middle one 0x1d (29).

According to the IP spec document, the determination of correct number is kinda complex due to different mapping policies between Zynz, ARMS GIC and device tree. But as conclusion, the correct ID number forms from Zynq IRQ ID (61) extracted 32, which reveals 29.



## 6. Using the information detailed in the previous answer, what should be written in the `devicetree.dts` line describing the IRQ Generator interrupts if it were to describe all the 16 HW IRQs? (write the exact line as it would appear in the `devicetree.dts`, notice that the HW IRQs are not contiguous!). Each interrupt line is specified by three cells in the device tree file; what information does each of these three cells represent?
<0x0 0x1d 0x4 0x0 0x1e 0x4 0x0 0x1f 0x4 0x0 0x20 0x4 
0x0 0x21 0x4 0x0 0x22 0x4 0x0 0x23 0x4 0x0 0x24 0x4  
0x0 0x34 0x4 0x0 0x35 0x4 0x0 0x36 0x4 0x0 0x37 0x4  
0x0 0x38 0x4 0x0 0x39 0x4 0x0 0x3a 0x4 0x0 0x3b 0x4>;

Examinating the first three cells:

0x0: type (SPI shared peripheral interrupt)
0x1d: interrupt number (29)
0x4: interrupt level type (active high level-sensitive)

## 7. Why do we need to use `ioremap`, `ioread32` and `iowrite32`? Why do we want to use the Linux kernel bitfields macroes rather than using bitwise arithmetic directly?
Depending on the used architecture, the I/O-memory is accessed through page tables. When access passes through page tables, the kernel must first arrange for the physical address to be visible from the driver using ioremap. 

The reason why ioread and iowrite functions should be used when accessing IO registers is that IO operations have side effects. On normal memory access, the cpu or compiler can add some optimization (eg. caching) to improve system speed, but this kind of optimizations are not allowed on IO operations to guarantee that IO device works properly.

## 8. (BONUS, optional) Did you find any bug in the bitstream implementation while testing the sysfs interface?

## 9. Feedback (what was difficult? what was easy? how would you improve it?)
I think that this weeks exercise was a bit easier than previous ones because the points that needed attention were marked. But that's not a bad thing, a good one.


[1] Zynq-7000 SoCTechnical Reference Manual, https://www.xilinx.com/support/documentation/user_guides/ug585-Zynq-7000-TRM.pdf

