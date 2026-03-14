#!/bin/sh
set -eu

BOOTCFG="/boot/syslinux.cfg"
[ -f "$BOOTCFG" ] || exit 0

label=""
for x in $(cat /proc/cmdline); do
    case "$x" in
        root=LABEL=rootfsA)
            label="slotA"
            ;;
        root=LABEL=rootfsB)
            label="slotB"
            ;;
    esac
done

[ -n "$label" ] || exit 0

tmpcfg="$(mktemp)"
sed "s/^DEFAULT .*/DEFAULT ${label}/" "$BOOTCFG" > "$tmpcfg"
cat "$tmpcfg" > "$BOOTCFG"
rm -f "$tmpcfg"
