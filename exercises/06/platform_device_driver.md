# Platform driver implementation

The platform driver model builds around the `platform_driver` struct. It includes the following members: 

```C
struct platform_driver {
	int (*probe)(struct platform_device *);
	int (*remove)(struct platform_device *);
	void (*shutdown)(struct platform_device *);
	int (*suspend)(struct platform_device *, pm_message_t state);
	int (*suspend_late)(struct platform_device *, pm_message_t state);
	int (*resume_early)(struct platform_device *);
	int (*resume)(struct platform_device *);
	struct device_driver driver;
};
```

In our case only the `probe()` and `remove()` functions needs to be implemented. Also the driver member needs to be initialized; it needs to be given a name, owner and name of the corresponding device tree entry using the name, owner and `of_match_table` members, respectively.
The following declaration of the platform_driver may be used with some user defined name:

```C
static const struct of_device_id irqgen_of_ids[] = {
	{ .compatible = PROP_COMPATIBLE,},
	{/* end of list */}
};

static struct platform_driver irqgen_driver = {
	.driver = {
		.name = DEVICE_NAME,
		.owner = THIS_MODULE,
		.of_match_table = irqgen_of_ids,
	},
	.probe = irqgen_probe,
	.remove = irqgen_remove,
};
```

where `PROP_COMPATIBLE` matches the compatible property of the IRQ generator’s device tree entry. This way the kernel is able to bind drivers to devices.

The `irqgen_driver` can be registered to the kernel using the `platform_driver_probe()` function, from `linux/platform_device.h`. This function should be called at the driver initialization time. When the module is unloaded, the driver needs to be deregistered using the `platform_driver_unregister()` function. The `platform_driver_probe()` is used for non-hotpluggable devices, like the IRQ generator. For hotpluggable devices it’s common to use the `platform_device_register()` variant.

## Probe

The `probe` function is used to resolve if the expected device really exists in the system. It is also the responsibility of the probe function to read the needed device data from the device tree, such as device’s memory region, used IRQs and any custom data. Our probe has the following prototype:

```C
static int irqgen_probe(struct platform_device *pdev)
```

where `pdev` points to a `platform_device` structure associated with a device matched from the `of_device_id` list. The IRQ generator’s memory range is now readable from the device tree using the `platform_get_resource()` function with `IORESOURCE_MEM` flag:

```C
struct resource *iomem_range;
iomem_range = platform_get_resource(pdev, IORESOURCE_MEM, 0);
```

and it can be mapped to kernel virtual memory with the `devm_ioremap_resource()` function:

```C
irqgen_base = devm_ioremap_resource(&pdev->dev, iomem_range);
```

which returns an `__iomem` memory cookie as did the `ioremap()` function, but now the driver developer does not need to know the physical address of the device.

**Note:** in this file and in the code comments, there are several hints at `devm_*` functions: [instructions.md](instructions.md) has links regarding *Devres* or *Device-managed resources*; you should familiarize with the concept.

The used IRQ numbers can be derived using the `platform_get_irq()` function. The function returns an IRQ usable by the interrupt handler registering function `request_irq()`. This way the driver developer does not need to worry about the hardware interrupt numbers.
Custom properties can be read out from the device tree using the `of_property_read_u32()` function, defined in `linux/of.h`. An array of properties can be read out using the `of_property_read_u32_array()` function. For example:

```C
uint32_t intr_acks[IRQLINES_AMNT];
of_property_read_u32_array(pdev->dev.of_node, PROP_WAPICE_INTRACK, intr_acks, qty);
```

reads out `qty` values included in the property named PROP_WAPICE_INTRACK to a preallocated `intr_acks` array. These values are used to clear an interrupt from the interrupting IRQ generator device. This procedure is used with devices generating level-type interrupts, as the IRQ generator.
The interrupt ACK values should now be used as the data/identifying cookie for the `request_irq()` function.

##  Remove
Our remove function has the following prototype:

```C
static int irqgen_remove(struct platform_device *pdev)
```

In the remove function all the allocations done in the probe should be deallocated; possibly dynamically allocated control structures and variables and especially the IRQs. The interrupt handler deregistring function free_irq() should be moved from module exit to the remove.

## Exercise 6: platform driver tasks

With the presented functions, it’s now possible to write a driver that reads the relevant data from the device tree using the platform driver model. Use the stub provided in `meta-tie50307/recipes-kernel/irqgen-mod` as a template (integrating with your solution from EX04) and follow the following steps:

0. Check the `FIXME` requesting to copy implementations from your solution to EX04, including the address header file.
1. Add the `platform_driver` and `of_device_id` structs.
2. Ensure the `probe` and `remove` functions only have test prints and return value of 0.
3. Add the `platform_driver_probe()` function to the module `__init` and `platform_driver_unregister()` to the module ` __exit`. Verify that the test prints work as expected.
4. Enable the devicetree recipe in `meta-tie50307` after making sure that the devicetree entry for the IRQ Generator is complete:
   - Modify `interrupts` line;
   - Modify *intrack* line
   - Modify dt-header `irq_gen_bindings.h`
   - Enable the devicetree recipe in `meta-tie50307`
   - Commit!
4. Add the memory range fetching and mapping functions to the probe and test that the device is controllable through the returned memory cookie. Remember to check return values.
5. Read the custom property containing the ACK values to an array. Remember to check return value.
6. Derive the IRQ numbers using the `platform_get_irq()` function and move the interrupt handler registration from the `__init` to the `probe`. Each IRQ should be registered with its associated ACK value. The handler receives a void pointer to the specific `intr_idx` value, and should use it to retrieve the proper ACK value (the second argument of the handler function). For example (note we user `devm_request_irq` instaed of `request_irq`; why?):

```C
irq = platform_get_irq(pdev, i);
ret_val = devm_request_irq(dev, irq, intr_handler, IRQF_SHARED, DEVICE_NAME, intr_idx[i]);
```

7. Add code to the interrupt handler that clears the interrupt from the device using the ACK value associated with the IEQ line, using the dereferencing `intr_acks[]` with the index received by the handler. The value can be resolved from the void pointer:

```C
u32 idx = *(u32*)data;
u32 ack = irqgen_data->intr_acks[idx];
```

	Also, save the IRQ latencies to an array for later printing.

8. Release allocated resources from the `remove` and module `__exit` functions; everything allocated from the `probe` should be released in `remove` and everything allocated in the `__init` should be released in the `__exit`.
9. Generate interrupts from the end of the `__init` function to all interrupt lines and verify that the interrupt clearing works as expected. You can check amount of received interrupts from the `/proc/interrupts` and browse the contents of `/sys/kernel/irqgen`.
10. Resolve any other pending `FIXME`

