obj-m += irqgen_ex4.o
obj-m += irqgen_ex4_dbg.o

irqgen_ex4-objs := irqgen.o irqgen_sysfs.o
irqgen_ex4_dbg-objs := irqgen_dbg.o irqgen_sysfs.o

CFLAGS_irqgen_dbg.o += -DDEBUG

SRC := $(shell pwd)

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(SRC)

modules_install:
	$(MAKE) -C $(KERNEL_SRC) M=$(SRC) modules_install

clean:
	rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
	rm -f Module.markers Module.symvers modules.order
	rm -rf .tmp_versions Modules.symvers
