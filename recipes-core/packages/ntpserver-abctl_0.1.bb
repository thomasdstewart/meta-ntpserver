DESCRIPTION = "A/B slot control helpers for syslinux + SWUpdate"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://ntpserver-boot-ok.sh \
    file://ntpserver-boot-ok.service \
    file://ntpserver-swupdate-install.sh \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "ntpserver-boot-ok.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} = "bash coreutils syslinux swupdate util-linux-findmnt"

FILES:${PN} += " \
    ${sbindir}/ntpserver-boot-ok.sh \
    ${sbindir}/ntpserver-swupdate-install.sh \
    ${systemd_system_unitdir}/ntpserver-boot-ok.service \
"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/ntpserver-boot-ok.sh ${D}${sbindir}/ntpserver-boot-ok.sh
    install -m 0755 ${WORKDIR}/ntpserver-swupdate-install.sh ${D}${sbindir}/ntpserver-swupdate-install.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/ntpserver-boot-ok.service ${D}${systemd_system_unitdir}/ntpserver-boot-ok.service
}
