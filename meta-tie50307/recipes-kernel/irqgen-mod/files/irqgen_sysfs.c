/**
 * @file   irqgen_sysfs.c
 * @author Nicola Tuveri
 * @date   08 November 2018
 * @version 0.6
 * @target_device Xilinx PYNQ-Z1
 * @brief   A stub module to support the IRQ Generator IP block for the
 *          Real-Time System course (sysfs support).
 */

# include <linux/kernel.h>           // Contains types, macros, functions for the kernel
# include <asm/io.h>                 // IO operations

# include <linux/sysfs.h>
# include <linux/device.h>
# include <linux/string.h>

# include "irqgen.h"                 // Shared module specific declarations

# define IRQGEN_ATTR_GET_NAME(_name) \
    dev_attr_##_name
# define IRQGEN_ATTR_RO DEVICE_ATTR_RO
# define IRQGEN_ATTR_RW DEVICE_ATTR_RW
# define IRQGEN_ATTR_WO DEVICE_ATTR_WO

static ssize_t latencies_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    int i;
    char *p = buf;

    for (i=0; i<irqgen_data->l_cnt; i++) {
        ssize_t ret = scnprintf(p, (buf-p+PAGE_SIZE), "%u ", irqgen_data->latencies[i]);
        if (ret < 0) {
            irqgen_data->l_cnt = 0;
            return ret;
        } else if (ret == 0) {
            irqgen_data->l_cnt = 0;
            return -ENOMEM;
        }
        p += ret;
    }
    *(p-1)='\n';

    irqgen_data->l_cnt = 0;
    return p-buf+1;
}
IRQGEN_ATTR_RO(latencies);

static ssize_t line_count_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    return sprintf(buf, "%d\n", irqgen_data->line_count);
}
IRQGEN_ATTR_RO(line_count);

static ssize_t intr_ids_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    ssize_t ret=0, acc=0;
    int i;
    for (i=0; i<irqgen_data->line_count; ++i) {
        ret = sprintf(buf+acc, "%u ", irqgen_data->intr_ids[i]);
        acc += ret;
    }
    *(buf+acc-1)='\n';
    return acc;
}
IRQGEN_ATTR_RO(intr_ids);

static ssize_t intr_idx_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    ssize_t ret=0, acc=0;
    int i;
    for (i=0; i<irqgen_data->line_count; ++i) {
        ret = sprintf(buf+acc, "%u ", irqgen_data->intr_idx[i]);
        acc += ret;
    }
    *(buf+acc-1)='\n';
    return acc;
}
IRQGEN_ATTR_RO(intr_idx);

static ssize_t intr_acks_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    ssize_t ret=0, acc=0;
    int i;
    for (i=0; i<irqgen_data->line_count; ++i) {
        ret = sprintf(buf+acc, "0x%02X ", irqgen_data->intr_acks[i]);
        acc += ret;
    }
    *(buf+acc-1)='\n';
    return acc;
}
IRQGEN_ATTR_RO(intr_acks);

static ssize_t intr_handled_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    ssize_t ret=0, acc=0;
    int i;
    for (i=0; i<irqgen_data->line_count; ++i) {
        ret = sprintf(buf+acc, "%u ", irqgen_data->intr_handled[i]);
        acc += ret;
    }
    *(buf+acc-1)='\n';
    return acc;
}
IRQGEN_ATTR_RO(intr_handled);

static ssize_t count_register_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    u32 val = irqgen_read_count();
    return sprintf(buf, "%lu\n", val);
}
IRQGEN_ATTR_RO(count_register);

static ssize_t latency_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    u64 val = irqgen_read_latency();
    return sprintf(buf, "%llu\n", val);
}
IRQGEN_ATTR_RO(latency);

static ssize_t total_handled_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    return sprintf(buf, "%u\n", irqgen_data->total_handled);
}
IRQGEN_ATTR_RO(total_handled);

static ssize_t enabled_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    u32 regvalue = ioread32(IRQGEN_CTRL_REG);
    u8 val = FIELD_GET(IRQGEN_CTRL_REG_F_ENABLE, regvalue);
    return sprintf(buf, "%u\n", val);
}
static ssize_t enabled_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    bool var;
    if (strtobool(buf, &var) < 0)
        return -EINVAL;

    if (var)
        enable_irq_generator();
    else
        disable_irq_generator();

    return count;
}
IRQGEN_ATTR_RW(enabled);

static u8 line_store_buf = 0;
static ssize_t line_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    unsigned long val;
    int retval = kstrtoul(buf, 10, &val);
    if (0 != retval)
        return retval;

    if (val >= irqgen_data->line_count)
        return -ERANGE;

    line_store_buf = (u8)val;

    return count;
}
static u32 delay_store_buf = 0;
static ssize_t delay_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    unsigned long val;
    int retval = kstrtoul(buf, 10, &val);
    if (0 != retval)
        return retval;

    if (val > IRQGEN_MAX_DELAY)
        return -ERANGE;

    delay_store_buf = val;

    return count;
}
static ssize_t amount_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    unsigned long val;
    int retval = kstrtoul(buf, 10, &val);
    if (0 != retval)
        return retval;

    if (val > IRQGEN_MAX_AMOUNT)
        return -ERANGE;

    do_generate_irqs(val, line_store_buf, delay_store_buf);
    return count;
}
IRQGEN_ATTR_WO(line);
IRQGEN_ATTR_WO(delay);
IRQGEN_ATTR_WO(amount);


/*
 * Create a group of attributes so that we can create and destroy them all
 * at once.
 */
struct attribute *irqgen_attrs[] = {
    &IRQGEN_ATTR_GET_NAME(enabled).attr,
    &IRQGEN_ATTR_GET_NAME(line).attr,
    &IRQGEN_ATTR_GET_NAME(delay).attr,
    &IRQGEN_ATTR_GET_NAME(amount).attr,
    &IRQGEN_ATTR_GET_NAME(total_handled).attr,
    &IRQGEN_ATTR_GET_NAME(latency).attr,
    &IRQGEN_ATTR_GET_NAME(count_register).attr,
    &IRQGEN_ATTR_GET_NAME(latencies).attr,
    &IRQGEN_ATTR_GET_NAME(line_count).attr,
    &IRQGEN_ATTR_GET_NAME(intr_ids).attr,
    &IRQGEN_ATTR_GET_NAME(intr_idx).attr,
    &IRQGEN_ATTR_GET_NAME(intr_acks).attr,
    &IRQGEN_ATTR_GET_NAME(intr_handled).attr,
    NULL,   /* need to NULL terminate the list of attributes */
};

/*
 * An unnamed attribute group will put all of the attributes directly in
 * the kobject directory.  If we specify a name, a subdirectory will be
 * created for the attributes with the directory being the name of the
 * attribute group.
 */
static struct attribute_group irqgen_attr_group = {
    .name = DRIVER_NAME,
    .attrs = irqgen_attrs,
};

static const struct attribute_group *irqgen_attr_groups[] = {
    &irqgen_attr_group,
    NULL
};

#if 1
# define PARENT_KOBJ kernel_kobj
#else
# define PARENT_KOBJ (&pdev->dev.kobj)
#endif

int irqgen_sysfs_setup(struct platform_device *pdev)
{
    int retval = 0;

    retval = sysfs_create_groups(PARENT_KOBJ, irqgen_attr_groups);
    if (0 != retval) {
        printk(KERN_ERR KMSG_PFX "sysfs_create_groups() failed.\n");
    }

    return retval;
}

void irqgen_sysfs_cleanup(struct platform_device *pdev)
{
    sysfs_remove_groups(PARENT_KOBJ, irqgen_attr_groups);
}

