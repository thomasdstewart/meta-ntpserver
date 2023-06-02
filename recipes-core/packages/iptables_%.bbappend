FILESEXTRAPATHS:prepend := "${THISDIR}/iptables:"

SRC_URI:append = " file://iptables.rules"

do_install:append() {
    install -m 0644 "${WORKDIR}/iptables.rules" \
        "${D}${sysconfdir}/iptables/iptables.rules"
}
