SUMMARY = "Script and data to test the evil module"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e"

SRC_URI = "file://evil-tests.sh \
           file://data.txt \
           file://COPYING \
          "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

S = "${WORKDIR}"

do_install() {
	install -Dm 0744 ${S}/evil-tests.sh ${D}/opt/evil-tests/sbin/evil-tests.sh
	install -Dm 0644 ${S}/data.txt ${D}/opt/evil-tests/share/data.txt
}

FILES_${PN} += "/opt/evil-tests"

