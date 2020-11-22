SUMMARY = "Out-of-tree Linux irqgen module"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e"

inherit module

SRC_URI = "\
        file://Makefile \
        file://COPYING \
        file://irqgen_main.c \
        file://irqgen_main_dbg.c \
        file://irqgen_addresses.h \
        file://irqgen.h \
        file://irqgen_sysfs.c \
        "

S = "${WORKDIR}"

# The inherit of module.bbclass will automatically name module packages with
# "kernel-module-" prefix as required by the oe-core build environment.
