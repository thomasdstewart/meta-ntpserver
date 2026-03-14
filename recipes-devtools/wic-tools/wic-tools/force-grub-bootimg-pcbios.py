#!/usr/bin/env python3
"""
Patch bootimg-pcbios plugin in wic-tools source to prefer GRUB loader defaults
instead of syslinux defaults.

This is an in-build override so we can test GRUB-first behavior without carrying
an out-of-tree poky fork.
"""
from pathlib import Path
import re
import sys

if len(sys.argv) != 2:
    print("usage: force-grub-bootimg-pcbios.py <wic-tools-source-root>", file=sys.stderr)
    sys.exit(2)

src_root = Path(sys.argv[1])
plugin = None
for p in src_root.rglob("bootimg-pcbios.py"):
    plugin = p
    break

if plugin is None:
    print(f"ERROR: bootimg-pcbios.py not found under {src_root}", file=sys.stderr)
    sys.exit(1)

text = plugin.read_text()
orig = text

# Common loader default expressions in bootimg-pcbios implementations.
text = re.sub(r"get\(\s*'loader'\s*,\s*'syslinux'\s*\)", "get('loader', 'grub')", text)
text = re.sub(r'get\(\s*"loader"\s*,\s*"syslinux"\s*\)', 'get("loader", "grub")', text)

# Additional common plain assignment patterns.
text = text.replace("loader = 'syslinux'", "loader = 'grub'")
text = text.replace('loader = "syslinux"', 'loader = "grub"')

if text == orig:
    print(f"ERROR: no known syslinux loader-default patterns matched in {plugin}", file=sys.stderr)
    sys.exit(1)

plugin.write_text(text)
print(f"Patched {plugin} to prefer GRUB defaults")
