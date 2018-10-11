#ifndef __IRQGEN_ADDRESSES_H
#define __IRQGEN_ADDRESSES_H

/* IRQ Generator core register address space from devicetree.dts */
# define IRQGEN_REG_PHYS_BASE 0x0 // FIXME: find the right address for the register from the device tree
# define IRQGEN_REG_PHYS_SIZE 0x0 // FIXME: find the size of the register address space from the device tree

/* IRQ Generator register address map from irq_generator_v1_1.pdf */
# define IRQGEN_CTRL_REG_OFFSET 0x0000 // FIXME: check in the reference documentation
# define IRQGEN_GENIRQ_REG_OFFSET 0x0000 // FIXME: check in the reference documentation
# define IRQGEN_IRQ_COUNT_REG_OFFSET 0x0000 // FIXME: check in the reference documentation
# define IRQGEN_LATENCY_REG_OFFSET 0x0000 // FIXME: check in the reference documentation

# define IRQGEN_CTRL_REG      (irqgen_reg_base + IRQGEN_CTRL_REG_OFFSET)
# define IRQGEN_GENIRQ_REG    (irqgen_reg_base + IRQGEN_GENIRQ_REG_OFFSET)
# define IRQGEN_IRQ_COUNT_REG (irqgen_reg_base + IRQGEN_IRQ_COUNT_REG_OFFSET)
# define IRQGEN_LATENCY_REG   (irqgen_reg_base + IRQGEN_LATENCY_REG_OFFSET)

/* --- bitfield defines for HW registers' fields --- */
# include <linux/bitfield.h>         // bitfield macros for writing the HW registers

# define IRQGEN_CTRL_REG_F_ENABLE             BIT(0) // FIXME: check in the reference documentation
# define IRQGEN_CTRL_REG_F_HANDLED            BIT(0) // FIXME: check in the reference documentation
# define IRQGEN_CTRL_REG_F_ACK        GENMASK( 1, 0) // FIXME: check in the reference documentation

# define IRQGEN_GENIRQ_REG_F_LINE     GENMASK( 1, 0) // FIXME: check in the reference documentation
# define IRQGEN_GENIRQ_REG_F_DELAY    GENMASK( 1, 0) // FIXME: check in the reference documentation
# define IRQGEN_GENIRQ_REG_F_AMOUNT   GENMASK( 1, 0) // FIXME: check in the reference documentation

# define IRQGEN_MAX_LINE   (FIELD_GET(IRQGEN_GENIRQ_REG_F_LINE  , 0xFFFFFFFFL))
# define IRQGEN_MAX_DELAY  (FIELD_GET(IRQGEN_GENIRQ_REG_F_DELAY , 0xFFFFFFFFL))
# define IRQGEN_MAX_AMOUNT (FIELD_GET(IRQGEN_GENIRQ_REG_F_AMOUNT, 0xFFFFFFFFL))

#endif /* !defined(__IRQGEN_ADDRESSES_H) */
