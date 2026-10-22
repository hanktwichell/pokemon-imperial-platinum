#!/usr/bin/env python3
"""Headless boot smoke test for an Imperial Platinum ROM (uses py-desmume).

Boots the ROM, presses through the opening into Professor Rowan's new-game intro, and saves
screenshots. Fails if the screens stay blank (a crash or hang during boot).

Usage: python3 tools/test/boot_smoke.py decomp/build/pokeplatinum.us.nds [out_dir]
Requires: pip install py-desmume pillow
"""
import os
import sys

from desmume.controls import Keys, keymask
from desmume.emulator import DeSmuME


def screens(emu):
    # display_buffer_as_rgbx() is really BGRX; the library's own screenshot has the right channel order.
    return emu.screenshot()


def run(emu, frames, press=None):
    for i in range(frames):
        if press is not None and i % 20 == 0:
            emu.input.keypad_add_key(keymask(press))
        if press is not None and i % 20 == 5:
            emu.input.keypad_rm_key(keymask(press))
        emu.cycle(with_joystick=False)


def main():
    rom = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else "build/smoke"
    os.makedirs(out, exist_ok=True)
    emu = DeSmuME()
    emu.open(rom)
    emu.volume_set(0)
    checkpoints = [(600, None, "boot"), (900, Keys.KEY_A, "intro"), (600, Keys.KEY_START, "rowan")]
    distinct = set()
    for frames, key, name in checkpoints:
        run(emu, frames, key)
        img = screens(emu)
        img.save(os.path.join(out, f"{name}.png"))
        distinct.add(len(set(img.getdata())))
        print(f"{name}: {len(set(img.getdata()))} colours")
    emu.destroy()
    if max(distinct) < 8:
        sys.exit("FAIL: screens look blank — the ROM may have crashed during boot")
    print("PASS")


if __name__ == "__main__":
    main()
