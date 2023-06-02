FILESEXTRAPATHS:prepend := "${THISDIR}/gpsd:"

SRC_URI:append = " file://gpsd"

do_install:append() {
    install -m 0644 "${WORKDIR}/gpsd" "${D}${sysconfdir}/default/gpsd.default"

    mkdir -p "${D}${sysconfdir}/systemd/system/multi-user.target.wants"
    ln -s "/lib/systemd/system/gpsd.service" \
        "${D}${sysconfdir}/systemd/system/multi-user.target.wants/gpsd.service"
}
