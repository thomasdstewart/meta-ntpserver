# SWUpdate A/B migration plan for `meta-ntpserver`

This document proposes a practical path to move this image from full-disk reflash updates to in-field A/B updates using SWUpdate.

## Goals

- Keep recovery simple on old 32-bit x86 hardware with a 1G single disk.
- Make updates possible remotely from userspace without removing the disk.
- Preserve serial-console recovery options.
- Prioritize "box must boot" behavior over feature richness.

## Decisions captured from current requirements

These are now treated as project decisions for implementation:

1. Partition budget: `boot` at ~64 MB is acceptable.
2. Rootfs budget: `rootfsA` and `rootfsB` at ~200 MB each.
3. Kernel updates are required as part of normal update flow.
4. Signature verification for `.swu` is deferred (not in v1).
5. v1 update UX is CLI-first (no web UI requirement).
6. Rollback policy should prioritize guaranteed bootability.

## Recommended architecture

### Partition layout (v1)

Use 4 partitions:

1. `boot` (FAT32, ~64 MB)
   - GRUB binaries/config
   - GRUB environment block (`grubenv`)
2. `rootfsA` (ext4, ~200 MB, read-only runtime)
3. `rootfsB` (ext4, ~200 MB, read-only runtime)
4. `data` (ext4, remaining space)
   - optional persistent logs/state
   - update staging/marker files if needed

Approximate footprint on a 1G disk:

- 64M + 200M + 200M = 464M fixed
- remainder available for `data` and filesystem overhead

### Kernel + GRUB update model

To include kernel updates safely while keeping rollback robust:

- Keep GRUB and `grubenv` in dedicated `boot` partition.
- Keep the kernel and initramfs **inside each rootfs slot** (`rootfsA` and `rootfsB`).
- GRUB menu entries point directly to kernel files on each slot partition.

Result:

- A normal SWUpdate writes the inactive slot rootfs image.
- That slot receives its matching userspace + kernel together.
- On reboot, GRUB tries that slot once; if boot is not confirmed, fallback remains possible.

This avoids updating GRUB for every release and still allows regular kernel security updates.

### Boot strategy (A/B with fallback)

- GRUB chooses slot via env variables (`active_slot`, `upgrade_available`, optional `bootcount`).
- SWUpdate writes inactive slot and sets `upgrade_available=1` + next slot.
- GRUB attempts the new slot first when upgrade is pending.
- A late-boot health service marks success (`upgrade_available=0`, `active_slot=<new>`).
- If confirmation is missing, GRUB falls back to previous known-good slot.

For this deployment, bootability is the primary success criterion.

### Artifact strategy

Build both:

- `.wic` full image for factory install / worst-case recovery
- `.swu` update bundle for field updates

This keeps operational updates simple and preserves a hard-recovery path.

## Yocto layer changes required

### 1) Add SWUpdate layer dependency

In build setup docs:

- add `meta-swupdate` to `BBLAYERS`
- keep branch aligned with Scarthgap

### 2) Add SWUpdate runtime packages (CLI-first)

In image/packagegroup include:

- `swupdate`
- any required handler/tools for raw/ext4 rootfs update mode
- systemd service unit for daemon/CLI-triggered updates

Do **not** require `swupdate-www` in v1.

### 3) Add recipe for `sw-description`

Create a recipe to generate/install `sw-description` for this board profile.

v1 guidance:

- target inactive slot by stable identifiers (prefer PARTUUID)
- include compatibility/version metadata
- unsigned `.swu` (signing deferred)

### 4) Introduce A/B `.wks`

Replace current single-rootfs layout with explicit fixed-size partitions:

- `boot` 64M
- `rootfsA` 200M
- `rootfsB` 200M
- `data` rest

Use stable labels/PARTUUID references for both GRUB and SWUpdate logic.

### 5) Switch bootloader from syslinux to GRUB (pcbios)

Use GRUB for slot variable control and fallback behavior.

### 6) Add boot confirmation service

Add a small systemd oneshot service that runs after base system is up and marks boot success in GRUB env.

### 7) Build `.swu`

Add update recipe/class wiring to emit `.swu` containing:

- rootfs payload for inactive slot
- board-specific `sw-description`

## Safety policy for this hardware

- Default policy: only promote a slot after successful boot confirmation.
- Keep fallback slot untouched during update.
- Treat GRUB updates as infrequent, maintenance-window operations.
- Keep `.wic` imaging path documented for disaster recovery.

## Scope and release compatibility

This design is intended to be implemented and validated within the current Yocto release line (Scarthgap), then maintained release-by-release with explicit migration testing.

## Implementation sequence

1. Land new A/B `.wks` with fixed partition sizes.
2. Switch machine bootloader integration from syslinux to GRUB.
3. Add GRUB slot-selection + fallback logic.
4. Add SWUpdate runtime + CLI invocation flow.
5. Add `.swu` build artifact generation.
6. Add boot-success confirmation service.
7. Validate end-to-end on QEMU, then hardware with serial console attached.
