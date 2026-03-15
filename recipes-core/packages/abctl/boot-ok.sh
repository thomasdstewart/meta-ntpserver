#!/bin/sh
set -eu

BOOTCFG="/boot/syslinux.cfg"
[ -f "$BOOTCFG" ] || exit 0

slot=""
for x in $(cat /proc/cmdline); do
    case "$x" in
        label=slotA) slot="slotA" ;;
        label=slotB) slot="slotB" ;;
    esac
done

if [ -z "$slot" ]; then
    echo "Could not determine active slot from /proc/cmdline PARTUUID" >&2
    exit 1
fi

cleanup() {
    mount -o remount,ro /boot || true
}
trap cleanup EXIT

tmpcfg="$(mktemp)"
sed "s/^DEFAULT .*/DEFAULT ${slot}/" "$BOOTCFG" > "$tmpcfg"
mount -o remount,rw /boot
cat "$tmpcfg" > "$BOOTCFG"
rm -f "$tmpcfg"
