#!/bin/sh
set -eu

GRUBENV_BOOT="/boot/grub/grubenv"
if [ ! -f "${GRUBENV_BOOT}" ]; then
    exit 0
fi

. /etc/os-release || true

if grub-editenv "${GRUBENV_BOOT}" list | grep -q '^upgrade_available=1$'; then
    target_slot="$(grub-editenv "${GRUBENV_BOOT}" list | sed -n 's/^target_slot=//p')"
    if [ -n "${target_slot}" ]; then
        grub-editenv "${GRUBENV_BOOT}" set active_slot="${target_slot}"
    fi
    grub-editenv "${GRUBENV_BOOT}" set upgrade_available=0
fi
