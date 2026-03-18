DESCRIPTION = "A/B slot control helpers for syslinux + SWUpdate"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://boot-ok.sh \
    file://boot-ok.service \
    file://swupdate-install.sh \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "boot-ok.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} = "bash coreutils syslinux swupdate util-linux-findmnt"

FILES:${PN} += " \
    ${sbindir}/boot-ok.sh \
    ${sbindir}/swupdate-install.sh \
    ${systemd_system_unitdir}/boot-ok.service \
"

do_install() {
    install -d "${D}${sbindir}"
    install -m 0755 "${WORKDIR}/boot-ok.sh" "${D}${sbindir}/boot-ok.sh"
    install -m 0755 "${WORKDIR}/swupdate-install.sh" "${D}${sbindir}/swupdate-install.sh"

    install -d "${D}${systemd_system_unitdir}"
    install -m 0644 "${WORKDIR}/boot-ok.service" "${D}${systemd_system_unitdir}/boot-ok.service"
}
