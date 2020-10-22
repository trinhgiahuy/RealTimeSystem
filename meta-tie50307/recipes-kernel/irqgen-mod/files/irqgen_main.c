/**
 * @file   irqgen.c
 * @author Nicola Tuveri
 * @date   08 November 2018
 * @version 0.6
 * @target_device Xilinx PYNQ-Z1
 * @brief   A stub module to support the IRQ Generator IP block for the
 *          Real-Time System course.
 */

#include <linux/init.h>             // Macros used to mark up functions e.g., __init __ex
#include <linux/module.h>           // Core header for loading LKMs into the kern
#include <linux/kernel.h>           // Contains types, macros, functions for the kernel
#include <linux/platform_device.h>  // Platform device related functions
#include <linux/of.h>               // Property reads from device tree

#include <linux/interrupt.h>        // Interrupt handling functions
#include <asm/io.h>                 // IO operations
#include <linux/slab.h>             // Kernel slab allocator


#include "irqgen.h"                 // Shared module specific declarations

#define PROP_COMPATIBLE "" // FIXME: compatible property for the irqgen device from the devicetree
#define PROP_WAPICE_INTRACK "" // FIXME: custom intrack property from the devicetree

#define FPGA_CLOCK_NS   0 /* 1000 / FPGA_CLOCK_MHZ */ // FIXME: how many nanoseconds is a FPGA clock cycle?

// Kernel token address to access the IRQ Generator core register
void __iomem *irqgen_reg_base = NULL;

// Module data instance
struct irqgen_data *irqgen_data = NULL;

// Platform driver structure (initialized at the end of the file)
static struct platform_driver irqgen_pdriver;

/* vvvv ---- LKM Parameters vvvv ---- */
static unsigned int generate_irqs = 0;
module_param(generate_irqs, uint, 0444);
MODULE_PARM_DESC(generate_irqs, "Amount of IRQs to generate at load time.");

static unsigned int loadtime_irq_delay = 0x3FFF;
module_param(loadtime_irq_delay, uint, 0444);
MODULE_PARM_DESC(loadtime_irq_delay, "Set the delay for IRQs generated at load time.");

/* Makes sure that the input values for parameters are sane */
static int parse_parameters(void)
{
    if (generate_irqs > IRQGEN_MAX_AMOUNT) {
        printk(KERN_WARNING KMSG_PFX "generate_irqs parameter exceeded maximum value: capped at %ld.\n",
                IRQGEN_MAX_AMOUNT);
        generate_irqs = IRQGEN_MAX_AMOUNT;
    }

    if (loadtime_irq_delay > IRQGEN_MAX_DELAY) {
        printk(KERN_WARNING KMSG_PFX "loadtime_irq_delay parameter exceeded maximum value: capped at %ld.\n",
                IRQGEN_MAX_DELAY);
        loadtime_irq_delay = IRQGEN_MAX_DELAY;
    }

    return 0;
}
/* ^^^^ ---- LKM Parameters ^^^^ ---- */

// Returns the latency of last successfully served IRQ, in clock cycles
static inline u32 irqgen_read_latency_clk(void)
{
    // FIXME: copy implementation from your EX04 solution
    return 0;
}

static irqreturn_t irqgen_irqhandler(int irq, void *data)
{
    u32 idx = *(const u32 *)data;
    u32 ack = irqgen_data->intr_acks[idx];
    u32 regvalue = ioread32(IRQGEN_CTRL_REG);
    regvalue &= ~(IRQGEN_CTRL_REG_F_HANDLED | IRQGEN_CTRL_REG_F_ACK);
    regvalue |= 0
                | FIELD_PREP(IRQGEN_CTRL_REG_F_HANDLED, 1)
                | FIELD_PREP(IRQGEN_CTRL_REG_F_ACK, (ack));

    ++irqgen_data->total_handled;
    ++irqgen_data->intr_handled[idx];

# ifdef DEBUG
    printk(KERN_INFO KMSG_PFX "IRQ #%d (idx: %d) received (ACK 0x%0X).\n", irq, idx, ack);
# endif

    iowrite32(regvalue, IRQGEN_CTRL_REG);

    if (irqgen_data->l_cnt < MAX_LATENCIES)
        irqgen_data->latencies[irqgen_data->l_cnt++] = irqgen_read_latency_clk();

    return IRQ_HANDLED;
}

/* Enable the IRQ Generator */
void enable_irq_generator(void)
{
    // FIXME: copy implementation from your EX04 solution
}

/* Disable the IRQ Generator */
void disable_irq_generator(void)
{
    // FIXME: copy implementation from your EX04 solution
}

/* Generate specified amount of interrupts on specified IRQ_F2P line [IRQLINES_AMNT-1:0] */
void do_generate_irqs(uint16_t amount, uint8_t line, uint16_t delay)
{
    u32 regvalue = 0
                   | FIELD_PREP(IRQGEN_GENIRQ_REG_F_AMOUNT,  amount)
                   | FIELD_PREP(IRQGEN_GENIRQ_REG_F_DELAY,    delay)
                   | FIELD_PREP(IRQGEN_GENIRQ_REG_F_LINE,      line);

    printk(KERN_INFO KMSG_PFX "Generating %u interrupts with IRQ delay %u on line %d.\n",
           amount, delay, line);

    iowrite32(regvalue, IRQGEN_GENIRQ_REG);
}

// Returns the latency of last successfully served IRQ, in ns
u64 irqgen_read_latency(void)
{
    u64 ret = irqgen_read_latency_clk();
    return ret * FPGA_CLOCK_NS;
}

// Returns the total generated IRQ count from IRQ_GEN_IRQ_COUNT_REG
u32 irqgen_read_count(void)
{
    return ioread32(IRQGEN_IRQ_COUNT_REG);
}

// Debugging wrapper for devm_request_irq()
#ifdef DEBUG
static
int _devm_request_irq(struct device *_dev, unsigned int _irq, irq_handler_t _handler, unsigned long _flags, const char *_name, void *_data)
{
    printk(KERN_DEBUG KMSG_PFX "devm_request_irq(%p, %u, %p, %lu, %s, %p)\n",
            _dev, _irq, _handler, _flags, _name, _data);
    return devm_request_irq(_dev, _irq, _handler, _flags, _name, _data);
}
#else
# define _devm_request_irq devm_request_irq
#endif

// helper for devm_kzalloc()
#define DEVM_KZALLOC_HELPER(_var,_pdev,_cnt,_flags) \
    do { \
        (_var) = devm_kzalloc(&((_pdev)->dev), \
                              (_cnt)*sizeof(*(_var)), \
                              (_flags)); \
        if (IS_ERR((_var))) { \
            printk(KERN_ERR KMSG_PFX "Allocation of " #_var " failed.\n"); \
            retval=PTR_ERR((_var)); \
            goto err; \
        } \
    } while(0)

static int irqgen_probe(struct platform_device *pdev)
{
    int retval = 0;
    int irqs_count = 0, irqs_acks = 0;
    int i;
    struct resource *iomem_range = NULL;

    // FIXME: use DEVM_KZALLOC_HELPER to dinamically allocate irqgen_data (the pointers inside the structure will need separate allocations)

    // FIXME: platform_get_resource() (and error checking)

    // FIXME: devm_ioremap_resource() (and error checking)

#if 0 // FIXME: enable
    irqs_count = platform_irq_count(pdev);
    irqs_acks = of_property_count_u32_elems(pdev->dev.of_node, PROP_WAPICE_INTRACK);

    if (irqs_count <= 0) {
        printk(KERN_ERR KMSG_PFX
               "No IRQ ID entries found for the device.\n");
        retval = -ENODEV;
        goto err;
    } else if (irqs_acks < 0) {
        printk(KERN_ERR KMSG_PFX
               "Property \"%s\" not found for the device.\n",
               PROP_WAPICE_INTRACK);
        retval = irqs_acks;
        goto err;
    } else if (irqs_count != irqs_acks) {
        printk(KERN_ERR KMSG_PFX
               "Property \"%s\" has invalid lenght (!= %d).\n",
               PROP_WAPICE_INTRACK, irqs_count);
        retval = -EINVAL;
        goto err;
    }

    DEVM_KZALLOC_HELPER(irqgen_data->intr_ids,
                        pdev, irqs_count, GFP_KERNEL);
    DEVM_KZALLOC_HELPER(irqgen_data->intr_idx,
                        pdev, irqs_count, GFP_KERNEL);
    DEVM_KZALLOC_HELPER(irqgen_data->intr_acks,
                        pdev, irqs_count, GFP_KERNEL);
    DEVM_KZALLOC_HELPER(irqgen_data->intr_handled,
                        pdev, irqs_count, GFP_KERNEL);

    irqgen_data->line_count = irqs_count;
    retval = of_property_read_u32_array(/* FIXME */);
    if (retval) {
        printk(KERN_ERR KMSG_PFX
               "Failed to read interrupt ack values from the device tree with %d.\n",
               retval);
        goto err;
    }

    for (i=0; i<irqs_count; ++i) {
        int irq_id = platform_get_irq(pdev, i);

        if (irq_id < 0) { // no valid IRQ ID
            retval = irq_id;
            if (i == 0) {
                printk(KERN_ERR KMSG_PFX
                       "No IRQ ID entries found for the device.\n");
                retval = -ENODEV;
            } else {
                printk(KERN_ERR KMSG_PFX
                       "Invalid IRQ ID entry for the device at index %d.\n",
                       i);
            }
            goto err;
        }

        irqgen_data->intr_ids[i] = irq_id;
        irqgen_data->intr_idx[i] = i;

        /* Register the handle to the relevant IRQ number and the corresponding idx value */
        retval = _devm_request_irq(/* FIXME */);
        if (retval != 0) {
            printk(KERN_ERR KMSG_PFX
                   "devm_request_irq() failed with return value %d "
                   "while requesting IRQ id %u.\n",
                   retval, irq_id);
            goto err;
        }
    }

    retval = irqgen_sysfs_setup(pdev);
    if (0 != retval) {
        printk(KERN_ERR KMSG_PFX "Sysfs setup failed.\n");
        goto err_sysfs_setup;
    }

    return 0;
#endif

 /* HINT: We are using devm_ resources: do we need to free them? */
 err_sysfs_setup:
 err:
    printk(KERN_ERR KMSG_PFX "probe() failed\n");
    return retval;
}

static int irqgen_remove(struct platform_device *pdev)
{
    //irqgen_sysfs_cleanup(pdev); // FIXME: enable

    return 0;
}

// The kernel module init function
static int32_t __init irqgen_init(void)
{
    int retval = 0;

    printk(KERN_INFO KMSG_PFX DRIVER_LNAME " initializing.\n");

    retval = parse_parameters();
    if (0 != retval) {
        printk(KERN_ERR KMSG_PFX "fatal failure parsing parameters.\n");
        goto err_parse_parameters;
    }

    // FIXME: something is missing here

    /* Enable the IRQ Generator */
    enable_irq_generator();

    if (generate_irqs > 0) {
        /* Generate IRQs (amount, line, delay) */
        do_generate_irqs(generate_irqs, 0, loadtime_irq_delay);
    }

    return 0;

 err_platform_driver_probe:
 err_parse_parameters:
    printk(KERN_ERR KMSG_PFX "module initialization failed\n");
    return retval;
}

// The kernel module exit function
static void __exit irqgen_exit(void)
{
    // Read interrupt latency from the IRQ Generator on exit
    printk(KERN_INFO KMSG_PFX "IRQ count: generated since reboot %u, handled since load %u.\n",
           irqgen_read_count(), irqgen_data->total_handled);
    // Read interrupt latency from the IRQ Generator on exit
    printk(KERN_INFO KMSG_PFX "latency for last handled IRQ: %lluns.\n",
           irqgen_read_latency());

    /* Disable the IRQ Generator */
    disable_irq_generator();

    /* FIXME: Unregister the platform driver and associated resources */

    printk(KERN_INFO KMSG_PFX DRIVER_LNAME " exiting.\n");
}





// FIXME: glue together the platform driver and the device-tree (use PROP_COMPATIBLE)


module_init(irqgen_init);
module_exit(irqgen_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Module for the IRQ Generator IP block for the realtime systems course");
// FIXME: add yourself among the authors
MODULE_AUTHOR("Jan Lipponen <jan.lipponen@wapice.com>");
MODULE_AUTHOR("Nicola Tuveri <nicola.tuveri@tut.fi>");
MODULE_VERSION("0.6");
