SUMMARY = "LCD Status for galleon device"
SECTION = "console/utils"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://lcdstatus file://lcdstatus.service"
S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE_${PN} = "lcdstatus.service"

do_install() {
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${PN}.service ${D}${systemd_unitdir}/system

    install -d ${D}${bindir}
    install -m 0755 lcdstatus ${D}${bindir}
}
