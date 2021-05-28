/**
 * @file   irqgen_sysfs.c
 * @author Nicola Tuveri
 * @date   11 October 2018
 * @version 0.2
 * @target_device Xilinx PYNQ-Z1
 * @brief   A stub module to support the IRQ Generator IP block for the
 *          Real-Time System course (Bonus task: sysfs support).
 */

//#define BONUS_SYSFS_IS_IMPLEMENTED // FIXME: enable for the bonus exercise
#ifndef BONUS_SYSFS_IS_IMPLEMENTED

int irqgen_sysfs_setup(void) { return 0; }
void irqgen_sysfs_cleanup(void) { return; }

#else

# include <linux/kernel.h>           // Contains types, macros, functions for the kernel
# include <asm/io.h>                 // IO operations

# include <linux/sysfs.h>
# include <linux/device.h>
# include <linux/string.h>

# include "irqgen.h"                 // Shared module specific declarations

# define IRQGEN_ATTR_GET_NAME(_name) \
    irqgen_attr_##_name
# define IRQGEN_ATTR_RO(_name) \
    static struct kobj_attribute IRQGEN_ATTR_GET_NAME(_name) = __ATTR_RO(_name)
# define IRQGEN_ATTR_RW(_name) \
    static struct kobj_attribute IRQGEN_ATTR_GET_NAME(_name) = __ATTR_RW(_name)
# define IRQGEN_ATTR_WO(_name) \
    static struct kobj_attribute IRQGEN_ATTR_GET_NAME(_name) = __ATTR_WO(_name)

static ssize_t count_handled_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    // FIXME: write to buf (as a string) the value stored inside the module data structure
}
IRQGEN_ATTR_RO(count_handled);

static ssize_t enabled_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    // FIXME: read this value from the field in the CTRL register, print 1 or 0 a string to buf
    // HINT: check linux/bitfield.h to see how to use the bitfield macroes
}
static ssize_t enabled_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
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

static u32 delay_store_buf = 0;
static ssize_t delay_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
    // FIXME: check boundaries, then store the value in delay_store_buf
    // HINT: use kstrtoul()
}
static ssize_t amount_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
    unsigned long val;
    // FIXME: save in val, then check boundaries
    // HINT: use kstrtoul()

    do_generate_irqs(val, 0, delay_store_buf);
    return count;
}
IRQGEN_ATTR_WO(delay);
IRQGEN_ATTR_WO(amount);


/*
 * Create a group of attributes so that we can create and destroy them all
 * at once.
 */
static struct attribute *attrs[] = {
    // FIXME: add entries for `enabled`,`delay`,`amount`
    &IRQGEN_ATTR_GET_NAME(count_handled).attr,
    NULL,   /* need to NULL terminate the list of attributes */
};

/*
 * An unnamed attribute group will put all of the attributes directly in
 * the kobject directory.  If we specify a name, a subdirectory will be
 * created for the attributes with the directory being the name of the
 * attribute group.
 */
static struct attribute_group attr_group = {
    .attrs = attrs,
};

static struct kobject *irqgen_kobj = NULL;

int irqgen_sysfs_setup(void)
{
    int retval = 0;

    /*
     * Create a simple kobject with the name of DRIVER_NAME,
     * located under /sys/kernel/
     *
     * As this is a simple directory, no uevent will be sent to
     * userspace.  That is why this function should not be used for
     * any type of dynamic kobjects, where the name and number are
     * not known ahead of time.
     */
    irqgen_kobj = kobject_create_and_add(DRIVER_NAME, kernel_kobj);
    if (IS_ERR(irqgen_kobj)) {
        printk(KERN_ERR KMSG_PFX "kobject_create_and_add() failed.\n");
        return PTR_ERR(irqgen_kobj);
    }

    /* Create the files associated with this kobject */
    retval = sysfs_create_group(irqgen_kobj, &attr_group);
    if (0 != retval) {
        printk(KERN_ERR KMSG_PFX "sysfs_create_group() failed.\n");
        // FIXME: decrease ref count for irqgen_kobj
    }

    return retval;
}

void irqgen_sysfs_cleanup(void)
{
    if (irqgen_kobj)
        // FIXME: decrease ref count for irqgen_kobj
}

#endif /* !defined(BONUS_SYSFS_IS_IMPLEMENTED) */
