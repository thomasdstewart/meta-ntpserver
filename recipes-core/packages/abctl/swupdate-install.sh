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

slot=""
for x in $(cat /proc/cmdline); do
    case "$x" in
        label=slotA) slot="slotB" ;;
        label=slotB) slot="slotA" ;;
    esac
done

if [ -z "$slot" ]; then
    echo "Could not determine active slot from /proc/cmdline PARTUUID" >&2
    exit 1
fi

echo "Installing update to inactive slot ${slot}"
swupdate -e "stable,${slot}" -i "$SWU"

if command -v syslinux-setonce >/dev/null 2>&1; then
    syslinux-setonce "${slot}" || true
fi

echo "Update installed. Next boot set to ${slot}."
