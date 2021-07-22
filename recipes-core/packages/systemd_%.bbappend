FILESEXTRAPATHS_prepend := "${THISDIR}/systemd:"

SRC_URI += " \
    file://vconsole.conf \
"

FILES_${PN} += " ${sysconfdir}/vconsole.conf "

do_install_append() {
    install -m 0644 ${WORKDIR}/vconsole.conf ${D}${sysconfdir}/vconsole.conf
    mkdir -p ${D}${sysconfdir}/systemd/system/
    ln -s /dev/null ${D}${sysconfdir}/systemd/system/systemd-timesyncd.service
}
