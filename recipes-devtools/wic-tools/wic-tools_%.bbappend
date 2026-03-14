FILESEXTRAPATHS:prepend := "${THISDIR}/wic-tools:"

SRC_URI += "file://force-grub-bootimg-pcbios.py"

do_configure:append() {
    python3 ${WORKDIR}/force-grub-bootimg-pcbios.py "${S}"
}
