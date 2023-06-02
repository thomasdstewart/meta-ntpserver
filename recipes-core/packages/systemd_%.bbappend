FILESEXTRAPATHS:prepend := "${THISDIR}/systemd:"

SRC_URI:append = " file://vconsole.conf"

FILES:${PN} += " ${sysconfdir}/vconsole.conf "

do_install:append() {
    install -m 0644 "${WORKDIR}/vconsole.conf" \
        "${D}${sysconfdir}/vconsole.conf"

    mkdir -p "${D}${sysconfdir}/systemd/system/"
    ln -s /dev/null \
        "${D}${sysconfdir}/systemd/system/systemd-timesyncd.service"
}
