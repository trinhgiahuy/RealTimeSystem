# TIE-50307 - Exercise 04 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?

## 2. Summarize the functionality provided by the IRQ Generator IP block, then describe what is the purpose of the various registers exposed by the FPGA device. Finally, ignore the fact that you were instructed to look for the base address of the IRQ Generator register space in the provided `devicetree.dts` and instead imagine you were also the developer of the FPGA core design, where would you have found the base address of the register space?

## 3. Describe the relationship between interrupt lines in the IRQ Generator, HW IRQ and Linux IRQ numbers, and how did you proceed to discover the IRQ number to use in the driver.

## 4. How many interrupt lines are available in the documented FPGA core (refer to the spec, even if we only used one in the *beta* bitstream we were given)?

## 5. What value is reported in the devicetree for the first IRQ line? How is it determined? (check the spec document, it has all the required information to map the line number to the HW IRQ on the processing system)

## 6. Using the information detailed in the previous answer, what should be written in the `devicetree.dts` line describing the IRQ Generator interrupts if it were to describe all the 16 HW IRQs? (write the exact line as it would appear in the `devicetree.dts`, notice that the HW IRQs are not contiguous!). Each interrupt line is specified by three cells in the device tree file; what information does each of these three cells represent?

## 7. Why do we need to use `ioremap`, `ioread32` and `iowrite32`? Why do we want to use the Linux kernel bitfields macroes rather than using bitwise arithmetic directly?

## 8. (BONUS, optional) Did you find any bug in the bitstream implementation while testing the sysfs interface?

## 9. Feedback (what was difficult? what was easy? how would you improve it?)

