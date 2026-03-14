DESCRIPTION = "Boot partition assets for galleon A/B boot"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://syslinux.cfg"
S = "${WORKDIR}"

inherit deploy

# Deploy is used by WIC/IMAGE_BOOT_FILES to copy syslinux.cfg into the boot partition.
do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/syslinux.cfg ${DEPLOYDIR}/syslinux.cfg
}

addtask deploy after do_compile before do_build
