#ifndef __IRQGEN_ADDRESSES_H
#define __IRQGEN_ADDRESSES_H

/* IRQ Generator core register address space from devicetree.dts */
# define IRQGEN_REG_PHYS_BASE 0x43C00000
# define IRQGEN_REG_PHYS_SIZE 0x10000

/* IRQ Generator register address map from irq_generator_v1_1.pdf */
# define IRQGEN_CTRL_REG_OFFSET 0x0000
# define IRQGEN_GENIRQ_REG_OFFSET 0x0004
# define IRQGEN_IRQ_COUNT_REG_OFFSET 0x0008
# define IRQGEN_LATENCY_REG_OFFSET 0x000C

# define IRQGEN_CTRL_REG      (irqgen_reg_base + IRQGEN_CTRL_REG_OFFSET)
# define IRQGEN_GENIRQ_REG    (irqgen_reg_base + IRQGEN_GENIRQ_REG_OFFSET)
# define IRQGEN_IRQ_COUNT_REG (irqgen_reg_base + IRQGEN_IRQ_COUNT_REG_OFFSET)
# define IRQGEN_LATENCY_REG   (irqgen_reg_base + IRQGEN_LATENCY_REG_OFFSET)

/* --- bitfield defines for HW registers' fields --- */
# include <linux/bitfield.h>         // bitfield macros for writing the HW registers

# define IRQGEN_CTRL_REG_F_ENABLE             BIT(0)
# define IRQGEN_CTRL_REG_F_HANDLED            BIT(1)
# define IRQGEN_CTRL_REG_F_ACK        GENMASK( 5, 2)

# define IRQGEN_GENIRQ_REG_F_LINE     GENMASK( 3, 0)
# define IRQGEN_GENIRQ_REG_F_DELAY    GENMASK(19, 6)
# define IRQGEN_GENIRQ_REG_F_AMOUNT   GENMASK(31,20)

# define IRQGEN_MAX_LINE   (FIELD_GET(IRQGEN_GENIRQ_REG_F_LINE  , 0xFFFFFFFFL))
# define IRQGEN_MAX_DELAY  (FIELD_GET(IRQGEN_GENIRQ_REG_F_DELAY , 0xFFFFFFFFL))
# define IRQGEN_MAX_AMOUNT (FIELD_GET(IRQGEN_GENIRQ_REG_F_AMOUNT, 0xFFFFFFFFL))

#endif /* !defined(__IRQGEN_ADDRESSES_H) */
