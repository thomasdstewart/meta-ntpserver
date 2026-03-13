DESCRIPTION = "SWUpdate bundle for ntpserver-image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "file://sw-description"

SWUPDATE_IMAGES = "ntpserver-image"
SWUPDATE_IMAGES_FSTYPES[ntpserver-image] = ".ext4.gz"
SWUPDATE_IMAGES_NOAPPEND_MACHINE[ntpserver-image] = "0"
