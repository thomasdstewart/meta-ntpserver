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

label=""
for x in $(cat /proc/cmdline); do
    case "$x" in
        root=LABEL=rootfsA)
            label="slotB"
            ;;
        root=LABEL=rootfsB)
            label="slotA"
            ;;
    esac
done

if [ -z "$label" ]; then
    echo "Could not determine active label from /proc/cmdline" >&2
    exit 1
fi

echo "Installing update to inactive label ${label}"
swupdate -e "stable,${label}" -i "$SWU"

if command -v syslinux-setonce >/dev/null 2>&1; then
    syslinux-setonce "${label}" || true
fi
if command -v extlinux >/dev/null 2>&1; then
    extlinux --once "${label}" /boot
fi

echo "Update installed. Next boot set to ${label}."
