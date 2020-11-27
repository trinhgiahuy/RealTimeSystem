# TIE-50307 - Exercise 06 - Q&A

## 1. What is the goal of this exercise? What did you accomplish?
To familiarize with the concept of platform driver and devicetree, which are used to automatically map the right resources for the device on its init phase.

## 2. What is a platform device? What makes such a device different from, e.g., a USB device or a PCI device?
Platform device is a device which is not discoverable by its nature. So its can't promote itselfs "hey I'm here" to the software, at what "normal" device is capable of. So the software need know at the boot time which platform devices are connected.

## 3. What is the relation between the device-tree and platform device drivers? 
Device tree tree is a description of system's hardware configuration. Devices in DT  includes "compatible"-property. The platform driver includes pointer to the of_device_id-struct, which includes also the same "compatible"-property. Now the driver can read right system configuration data from device tree.

## 4. Why did we bother to rewrite the LKM code to implement a platform device driver?
The way the device was initialised in ex4 was more like a "hard-coded" way, which may work in narrow perspective but is not a good practice on larger scale. 

## 5. Imagine you are developing a product on the PYNQ-Z1 board involving several IP blocks of your own design to squeeze all the resources and cabalities of the SoC FPGA; most IP blocks are accessible from the PS through the AMBA/AXI bus. Do you need to alter the device-tree we are using? What's the minimum set of information that you would require for each addressable IP block?
Yes, every individual device needs to be described as a device tree entry. The device tree entry should include at least compatible property and reg property.


## 6. What capabilities are exposed through the current sysfs interface of the `irqgen`? Describe the available entry points inside `/sys/kernel/irqgen` and their functions.
amount: write amount of IRQ:s generated during module load
count_register: Total count of handed interrupts
delay: write delay of the interrupts
enabled: device enabled (1) or disabled (0)
intr_acks: Interrupt ack values read from the device tree
intr_handled: count of total handled interrupts
intr_ids: Interrupt IDs allocated for the IRQ lines
intr_idx: (incremental) index for each IRQ line
latencies: Buffer for latency values from IRQ generator
latancy: latency for last handled IRQ
line: write used IRQ line
line_count: number of used interrupt
total_handled: handled interrupts qty from module load


## 7. Are there code sections that are missing concurrency barriers? Where? Can you think of a way of triggering unintended behaviour?
In main.c in function irqgen_irqhandler. The portitions for irqgen_data writing needs to be protected, so them cannot be write and read same time.

## 8. Feedback (what was difficult? what was easy? how would you improve it?)
Pretty standard excersise.

