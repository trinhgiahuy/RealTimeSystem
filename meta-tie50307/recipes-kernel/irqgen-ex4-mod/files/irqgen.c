/**
 * @file   irqgen.c
 * @author Nicola Tuveri
 * @date   11 October 2018
 * @version 0.2
 * @target_device Xilinx PYNQ-Z1
 * @brief   A stub module to support the IRQ Generator IP block for the
 *          Real-Time System course.
 */

#include <linux/init.h>             // Macros used to mark up functions e.g., __init __ex
#include <linux/module.h>           // Core header for loading LKMs into the kern
#include <linux/kernel.h>           // Contains types, macros, functions for the kernel

#include <linux/interrupt.h>        // Interrupt handling functions
#include <asm/io.h>                 // IO operations
#include <linux/slab.h>             // Kernel slab allocator


#include "irqgen.h"                 // Shared module specific declarations

/* Linux IRQ number for the first hwirq line */
#define IRQGEN_FIRST_IRQ 45 

// Kernel token address to access the IRQ Generator core register
void __iomem *irqgen_reg_base = NULL;

// Module data instance
struct irqgen_data *irqgen_data = NULL;

// Dummy identifier for request_irq()
static int dummy;

/* vvvv ---- LKM Parameters vvvv ---- */
static unsigned int generate_irqs = 0;
module_param(generate_irqs, uint, 0444);
MODULE_PARM_DESC(generate_irqs, "Amount of IRQs to generate at load time.");

static unsigned int loadtime_irq_delay = 0;
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
    // return -EINVAL;
}
/* ^^^^ ---- LKM Parameters ^^^^ ---- */


/* Interrupt handler function */
static irqreturn_t irqgen_irqhandler(int irq, void *data)
{
#ifdef DEBUG
    printk(KERN_INFO KMSG_PFX "IRQ #%d received.\n", irq);
#endif

    // increment the `count_handled` counter before ACK
    irqgen_data->count_handled++;


    u32 ctrRegValue = ioread32(IRQGEN_CTRL_REG) 
                    |FIELD_PREP(IRQGEN_CTRL_REG_F_HANDLED, 1) 
                    |FIELD_PREP(IRQGEN_CTRL_REG_F_ACK, 0);

    iowrite32(ctrRegValue, IRQGEN_CTRL_REG);

    return IRQ_HANDLED; 
}

/* Enable the IRQ Generator */
void enable_irq_generator(void)
{
#ifdef DEBUG
    printk(KERN_INFO KMSG_PFX "Enabling IRQ Generator.\n");
#endif

    u32 regValue = 0 | FIELD_PREP(IRQGEN_CTRL_REG_F_ENABLE, 1);
    
    iowrite32(regValue, IRQGEN_CTRL_REG);


}

/* Disable the IRQ Generator */
void disable_irq_generator(void)
{
#ifdef DEBUG
    printk(KERN_INFO KMSG_PFX "Disabling IRQ Generator.\n");
#endif

    u32 cenirqRegValue = ioread32(IRQGEN_GENIRQ_REG) | FIELD_PREP(IRQGEN_GENIRQ_REG_F_AMOUNT, 0);

    u32 ctrRegValue = ioread32(IRQGEN_CTRL_REG) | FIELD_PREP(IRQGEN_CTRL_REG_F_ENABLE, 0);

    iowrite32(cenirqRegValue, IRQGEN_GENIRQ_REG);
    
    iowrite32(ctrRegValue, IRQGEN_CTRL_REG);

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
    u64 regValue = ioread32(IRQGEN_LATENCY_REG);
    return regValue;
}

// Returns the total generated IRQ count from IRQ_GEN_IRQ_COUNT_REG
u32 irqgen_read_count(void)
{
    u32 regValue = ioread32(IRQGEN_IRQ_COUNT_REG);

    return regValue;
}

// Debugging wrapper for request_irq()
#ifdef DEBUG
static
int _request_irq(unsigned int _irq, irq_handler_t _handler, unsigned long _flags, const char *_name, void *_dev)
{
    printk(KERN_DEBUG KMSG_PFX "request_irq(%u, %p, %lu, %s, %p)\n",
            _irq, _handler, _flags, _name, _dev);
    return request_irq(_irq, _handler, _flags, _name, _dev);
}
#else
# define _request_irq request_irq
#endif


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

   
    irqgen_data = kzalloc(sizeof(*irqgen_data), GFP_KERNEL);
    if (NULL == irqgen_data) {
        printk(KERN_ERR KMSG_PFX "Allocation of irqgen_data failed.\n");
        retval = -ENOMEM;
        goto err_alloc_irqgen_data;
    }

    
    irqgen_reg_base = ioremap(IRQGEN_REG_PHYS_BASE, IRQGEN_REG_PHYS_SIZE);
    if (NULL == irqgen_reg_base) {
        printk(KERN_ERR KMSG_PFX "ioremap() failed.\n");
        retval = -EFAULT;
        goto err_ioremap;
    }

   
    retval = _request_irq(IRQGEN_FIRST_IRQ, &irqgen_irqhandler, 0, DRIVER_NAME, NULL);
    if (retval != 0) {
        printk(KERN_ERR KMSG_PFX "request_irq() failed with return value %d while requesting IRQ id %u.\n",
                retval, IRQGEN_FIRST_IRQ);
        goto err_request_irq;
    }


    retval = irqgen_sysfs_setup();
    if (0 != retval) {
        printk(KERN_ERR KMSG_PFX "Sysfs setup failed.\n");
        goto err_sysfs_setup;
    }


    /* Enable the IRQ Generator */
    enable_irq_generator();


    if (generate_irqs > 0) {
        /* Generate IRQs (amount, line, delay) */
        do_generate_irqs(generate_irqs, 0, loadtime_irq_delay);
    }


    return 0;

 err_sysfs_setup:
    irqgen_sysfs_cleanup();
 err_request_irq:
    free_irq(IRQGEN_FIRST_IRQ, NULL);
 err_ioremap:
    iounmap(irqgen_reg_base);
 err_alloc_irqgen_data:
    kfree(irqgen_data);
 err_parse_parameters:
    printk(KERN_ERR KMSG_PFX "module initialization failed\n");
    return retval;
}

// The kernel module exit function
static void __exit irqgen_exit(void)
{
    // Read interrupt latency from the IRQ Generator on exit
    printk(KERN_INFO KMSG_PFX "IRQ count: generated since reboot %u, handled since load %u.\n",
           irqgen_read_count(), irqgen_data->count_handled);
    // Read interrupt latency from the IRQ Generator on exit
    printk(KERN_INFO KMSG_PFX "latency for last handled IRQ: %lluns.\n",
           irqgen_read_latency());


    // Step through `init` in reverse order and disable/free/unmap allocated resources
    disable_irq_generator();
    irqgen_sysfs_cleanup(); 
    free_irq(IRQGEN_FIRST_IRQ, NULL);
    iounmap(irqgen_reg_base);
    kfree(irqgen_data);

    printk(KERN_INFO KMSG_PFX DRIVER_LNAME " exiting.\n");
}

module_init(irqgen_init);
module_exit(irqgen_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Module for the IRQ Generator IP block for the realtime systems course");
MODULE_AUTHOR("Jan Lipponen <jan.lipponen@wapice.com>");
MODULE_AUTHOR("Nicola Tuveri <nicola.tuveri@tut.fi>");
MODULE_AUTHOR("Juho Pyykkönen");
MODULE_AUTHOR("Trinh Gia Huy");
MODULE_VERSION("0.2");
