# TIE-50307 - Exercise 06 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?

## 2. What is a platform device? What makes such a device different from, e.g., a USB device or a PCI device?

## 3. What is the relation between the device-tree and platform device drivers?

## 4. Why did we bother to rewrite the LKM code to implement a platform device driver?

## 5. Imagine you are developing a product on the PYNQ-Z1 board involving several IP blocks of your own design to squeeze all the resources and cabalities of the SoC FPGA; most IP blocks are accessible from the PS through the AMBA/AXI bus. Do you need to alter the device-tree we are using? What's the minimum set of information that you would require for each addressable IP block?

## 6. What capabilities are exposed through the current sysfs interface of the `irqgen`? Describe the available entry points inside `/sys/kernel/irqgen` and their functions.

## 7. Are there code sections that are missing concurrency barriers? Where? Can you think of a way of triggering unintended behaviour?

## 8. Feedback (what was difficult? what was easy? how would you improve it?)

