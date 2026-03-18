do_configure:append() {
    echo 'CONFIG_BOOTLOADER_NONE=y' >> .config
    oe_runmake olddefconfig
}
