# Bootloader loop investigation: why WIC keeps using syslinux

This note records the root cause of the repeated "enable GRUB -> build fails -> add syslinux -> system boots syslinux" loop.

## Symptom sequence

1. Remove `syslinux` from `WKS_FILE_DEPENDS_BOOTLOADERS`.
2. `do_image_wic` fails trying to copy:
   - `recipe-sysroot/usr/share/syslinux/ldlinux.sys`
3. Re-add `syslinux` dependency.
4. Build succeeds, but runtime `/boot` contains `syslinux.cfg`, `ldlinux.sys`, etc.

## Root cause

Current Scarthgap `bootimg-pcbios` flow in WIC is still executing a syslinux-oriented boot image path for this image build, evidenced by the hard failure on `ldlinux.sys` when syslinux artifacts are absent.

In other words:

- Adding GRUB packages/config alone does **not** switch the PCBios boot image creation path.
- `WKS_FILE_DEPENDS_BOOTLOADERS` only controls what gets staged in the recipe sysroot for WIC.
- If `bootimg-pcbios` takes the syslinux path, syslinux artifacts are required and syslinux boot files are emitted.

## Why we looped

- We toggled `WKS_FILE_DEPENDS_BOOTLOADERS` between including and excluding `syslinux`.
- The underlying WIC boot image source behavior remained unchanged.
- Therefore, we alternated between:
  - build failure (no syslinux artifacts)
  - successful syslinux boot image

## Practical conclusion

A true GRUB-on-BIOS switch for this image requires changing boot image generation behavior, not only package deps.

Likely implementation options:

1. **Custom WIC source plugin in this layer** to replace/override the syslinux PCBios path with a GRUB BIOS path.
2. **Patch/override Poky `bootimg-pcbios` behavior** in the build setup.
3. Use a different supported boot image path that is truly GRUB-based for the target firmware mode.

## Current repo stance

- Current experiment switches to `WKS_FILE_DEPENDS_BOOTLOADERS:galleon = "grub grub-bootconf"` and patches `bootimg-pcbios.py` in `wic-tools` at build time to prefer GRUB defaults.
- Keep the A/B partition layout and SWUpdate work intact.


## Implemented first step

A first in-layer override has been added via `recipes-devtools/wic-tools/wic-tools_%.bbappend`, which patches `bootimg-pcbios.py` during `wic-tools` configure to prefer GRUB loader defaults.

This is intended to validate the override path without forking poky.
