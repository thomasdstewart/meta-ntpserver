#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <update.swu>" >&2
    exit 2
fi

SWU="$1"
GRUBENV_BOOT="/boot/grub/grubenv"

if [ ! -f "$SWU" ]; then
    echo "Missing SWU file: $SWU" >&2
    exit 2
fi

current_root="$(findmnt -n -o SOURCE / | sed 's#^/dev/##')"
case "$current_root" in
    *2)
        target_slot=B
        ;;
    *3)
        target_slot=A
        ;;
    *)
        echo "Could not determine active slot from root source: $current_root" >&2
        exit 1
        ;;
esac

echo "Installing update to inactive slot ${target_slot}"
swupdate -e "stable,slot${target_slot}" -i "$SWU"

grub-editenv "$GRUBENV_BOOT" set target_slot="${target_slot}"
grub-editenv "$GRUBENV_BOOT" set upgrade_available=1

echo "Update installed. Reboot to try slot ${target_slot}."
