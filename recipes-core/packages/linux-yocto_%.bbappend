#meta-yocto-bsp/recipes-kernel/linux/linux-yocto_5.10.bbappend
KBRANCH_galleon = "${KBRANCH_genericx86}"
KMACHINE_galleon = "${KMACHINE_genericx86}"
SRCREV_machine_galleon = "${SRCREV_machine_genericx86}"
COMPATIBLE_MACHINE_galleon = "galleon"
LINUX_VERSION_galleon = "${LINUX_VERSION_genericx86}"

KERNEL_FEATURES_remove = "cfg/sound.scc"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://via.cfg"

