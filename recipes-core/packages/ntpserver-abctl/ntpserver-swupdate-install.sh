#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <update.swu>" >&2
    exit 2
fi

SWU="$1"
if [ ! -f "$SWU" ]; then
    echo "Missing SWU file: $SWU" >&2
    exit 2
fi

current_root="$(findmnt -n -o SOURCE / | sed 's#^/dev/##')"
case "$current_root" in
    *2)
        target_slot=B
        target_label=slotB
        ;;
    *3)
        target_slot=A
        target_label=slotA
        ;;
    *)
        echo "Could not determine active slot from root source: $current_root" >&2
        exit 1
        ;;
esac

echo "Installing update to inactive slot ${target_slot}"
swupdate -e "stable,slot${target_slot}" -i "$SWU"

if command -v syslinux-setonce >/dev/null 2>&1; then
    syslinux-setonce "${target_label}" || true
fi
if command -v extlinux >/dev/null 2>&1; then
    extlinux --once "${target_label}" /boot
fi

echo "Update installed. Next boot set to ${target_label}."
