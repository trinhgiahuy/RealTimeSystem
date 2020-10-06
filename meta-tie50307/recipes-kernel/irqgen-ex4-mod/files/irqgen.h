#ifndef __IRQGEN_HEADER
#define __IRQGEN_HEADER

#ifdef DEBUG
# define DRIVER_NAME "irqgen_dbg"
# define DRIVER_LNAME "IRQ Generator module (DEBUG build)"
# define KMSG_PFX "IRQGEN_DBG: "
#else
# define DRIVER_NAME "irqgen"
# define DRIVER_LNAME "IRQ Generator module"
# define KMSG_PFX "IRQGEN: "
#endif

// Structure for module data
struct irqgen_data {
    u32 count_handled;
};

// Kernel token address to access the IRQ Generator core register
extern void __iomem *irqgen_reg_base;
#include "irqgen_addresses.h"       // Device specific addresses

// Module data instance
extern struct irqgen_data *irqgen_data;

void enable_irq_generator(void);
void disable_irq_generator(void);
void do_generate_irqs(uint16_t amount, uint8_t line, uint16_t delay);
u64 irqgen_read_latency(void);
u32 irqgen_read_count(void);

int irqgen_sysfs_setup(void);
void irqgen_sysfs_cleanup(void);

#endif /* !defined(__IRQGEN_HEADER) */
