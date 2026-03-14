# SWUpdate A/B migration plan for `meta-ntpserver`

This document describes a practical A/B update design using SWUpdate with syslinux on pcbios hardware.

## Goals

- Keep recovery simple on old 32-bit x86 hardware with a 1G single disk.
- Allow in-field updates without full-disk reflash.
- Prioritize "box must boot" behavior.

## Partition layout

1. `boot` (FAT32, ~64 MB) with syslinux boot files/config
2. `rootfsA` (ext4, ~200 MB)
3. `rootfsB` (ext4, ~200 MB)
4. `srv` (ext4, remainder, mounted at `/srv`)

## Update flow

- SWUpdate writes the inactive rootfs slot (`slotA`/`slotB`) by label.
- Installer helper sets one-shot boot target using `syslinux-setonce` (or `extlinux --once`).
- On successful boot, boot-confirm service updates `DEFAULT` label in `/boot/syslinux.cfg`.
- If boot fails before confirmation, default slot remains unchanged.

## Artifacts

Build both:

- `.wic` full image for recovery/factory reflash
- `.swu` for field updates

## Yocto implementation items

- `wic/galleon.wks` A/B layout with `/srv` partition
- `ntpserver-swu.bb` + `sw-description`
- `ntpserver-abctl` scripts/service for set-once + boot-confirm
- `ntpserver-bootfiles` for deployed `syslinux.cfg`
