#meta-yocto-bsp/recipes-kernel/linux/linux-yocto_6.1.bbappend
KBRANCH:galleon = "${KBRANCH:genericx86}"
KMACHINE:galleon = "${KMACHINE:genericx86}"
SRCREV_machine:galleon = "${SRCREV_machine:genericx86}"
COMPATIBLE_MACHINE:galleon = "galleon"
LINUX_VERSION:galleon = "${LINUX_VERSION:genericx86}"

KERNEL_FEATURES:remove = "cfg/sound.scc"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://via.cfg"
