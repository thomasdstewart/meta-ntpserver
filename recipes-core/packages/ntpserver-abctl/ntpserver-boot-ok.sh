#!/bin/sh
set -eu

BOOTCFG="/boot/syslinux.cfg"
[ -f "$BOOTCFG" ] || exit 0

slot=""
for x in $(cat /proc/cmdline); do
    case "$x" in
        root=PARTUUID=*-02)
            slot="slotA"
            ;;
        root=PARTUUID=*-03)
            slot="slotB"
            ;;
    esac
done

[ -n "$slot" ] || exit 0

boot_was_ro=0
boot_opts="$(awk '$2 == "/boot" { print $4; exit }' /proc/mounts || true)"
case ",${boot_opts}," in
    *,ro,*)
        mount -o remount,rw /boot
        boot_was_ro=1
        ;;
esac

cleanup() {
    if [ "$boot_was_ro" -eq 1 ]; then
        mount -o remount,ro /boot || true
    fi
}
trap cleanup EXIT

tmpcfg="$(mktemp)"
sed "s/^DEFAULT .*/DEFAULT ${slot}/" "$BOOTCFG" > "$tmpcfg"
cat "$tmpcfg" > "$BOOTCFG"
rm -f "$tmpcfg"
