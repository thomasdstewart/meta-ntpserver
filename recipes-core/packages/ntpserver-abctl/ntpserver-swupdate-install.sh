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

slot_label=""
for x in $(cat /proc/cmdline); do
    case "$x" in
        root=LABEL=rootfsA) slot_label="slotA" ;;
        root=LABEL=rootfsB) slot_label="slotB" ;;
    esac
done

case "$slot_label" in
    slotA)
        target_slot=B
        target_label=slotB
        ;;
    slotB)
        target_slot=A
        target_label=slotA
        ;;
    *)
        echo "Could not determine active slot from /proc/cmdline" >&2
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
