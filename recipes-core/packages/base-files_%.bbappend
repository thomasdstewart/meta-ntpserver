FILESEXTRAPATHS:prepend = "${THISDIR}/base-files:"

SRC_URI:append = " file://fstab"

do_install:append() {
    install -m 0644 ${WORKDIR}/fstab ${D}${sysconfdir}/fstab
}
