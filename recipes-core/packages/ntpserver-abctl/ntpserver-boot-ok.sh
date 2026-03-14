#!/bin/sh
set -eu

BOOTCFG="/boot/syslinux.cfg"
[ -f "$BOOTCFG" ] || exit 0

slot_label=""
for x in $(cat /proc/cmdline); do
    case "$x" in
        root=LABEL=rootfsA) slot_label="slotA" ;;
        root=LABEL=rootfsB) slot_label="slotB" ;;
    esac
done

[ -n "$slot_label" ] || exit 0

tmpcfg="$(mktemp)"
sed "s/^DEFAULT .*/DEFAULT ${slot_label}/" "$BOOTCFG" > "$tmpcfg"
cat "$tmpcfg" > "$BOOTCFG"
rm -f "$tmpcfg"
