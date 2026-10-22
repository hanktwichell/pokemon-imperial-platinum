#!/usr/bin/env python3
"""Drive the ROM headlessly from a save state with a list of actions, then save a state + screenshot.

Actions (space-separated):
  A B X Y L R START SELECT UP DOWN LEFT RIGHT   press the button (add *N to repeat, e.g. A*10; join with + to press
                                                together, e.g. SELECT+L)
  hold:KEY:FRAMES                               hold a button for FRAMES frames
  touch:X,Y                                     tap the touch screen (bottom-screen coordinates)
  wait:FRAMES                                   let the game run
  shot:NAME                                     save a screenshot (both screens) as NAME.png
  export:PATH                                   write the battery save (in-game SAVE) to PATH
  pos                                           print the player's map tile as "pos X Z"
  step:DIR[,DIR...]                             walk one tile per entry (UP/DOWN/LEFT/RIGHT), printing pos after each

Usage:
  python3 tools/test/drive.py ROM STATE_IN|-|sav:FILE STATE_OUT OUT_DIR action...
STATE_IN is an emulator save state, "-" for a fresh boot, or sav:FILE to boot fresh with a battery save
(use this after rebuilding: save states hold the old code in RAM, battery saves don't).
Requires py-desmume and Pillow; run with SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy when headless.
"""
import os
import struct
import sys

from desmume.controls import Keys, keymask
from desmume.emulator import DeSmuME

KEYS = {"A": Keys.KEY_A, "B": Keys.KEY_B, "X": Keys.KEY_X, "Y": Keys.KEY_Y, "L": Keys.KEY_L, "R": Keys.KEY_R,
        "START": Keys.KEY_START, "SELECT": Keys.KEY_SELECT, "UP": Keys.KEY_UP, "DOWN": Keys.KEY_DOWN,
        "LEFT": Keys.KEY_LEFT, "RIGHT": Keys.KEY_RIGHT}


# Player tile coordinates (u16 x, then u16 z 8 bytes later), found by RAM search on this build; they stay put
# across map changes. If they ever read wrong after a code change, re-find them by searching RAM for a known
# position (e.g. a map's arrival warp) before and after a one-tile step.
PLAYER_X_ADDR = 0x021C6026
PLAYER_Z_ADDR = 0x021C602E


class Driver:
    def __init__(self, rom, state=None, battery=None):
        self.emu = DeSmuME()
        self.emu.open(rom)
        self.emu.volume_set(0)
        if battery:
            self.emu.backup.import_file(battery)
            self.emu.reset()
        if state:
            self.emu.savestate.load_file(state)

    def run(self, frames):
        for _ in range(frames):
            self.emu.cycle(with_joystick=False)

    def press(self, key, frames=6, after=20):
        # Keys go down right to left, a frame apart, so in SELECT+L the L is already held when SELECT is pressed.
        keys = key.split("+")
        for k in reversed(keys):
            self.emu.input.keypad_add_key(keymask(KEYS[k]))
            self.run(1)
        self.run(frames)
        for k in keys:
            self.emu.input.keypad_rm_key(keymask(KEYS[k]))
        self.run(after)

    def touch(self, x, y, frames=30, after=60):
        self.emu.input.touch_set_pos(x, y)
        self.run(frames)
        self.emu.input.touch_release()
        self.run(after)

    def pos(self):
        mem = self.emu.memory.unsigned
        x = struct.unpack("<H", bytes(mem[PLAYER_X_ADDR:PLAYER_X_ADDR + 2]))[0]
        z = struct.unpack("<H", bytes(mem[PLAYER_Z_ADDR:PLAYER_Z_ADDR + 2]))[0]
        return x, z

    def screenshot(self):
        # display_buffer_as_rgbx() is really BGRX; the library's own screenshot has the right channel order.
        return self.emu.screenshot()

    def do(self, action, out_dir="."):
        if action.startswith("touch:"):
            x, y = action[6:].split(",")
            self.touch(int(x), int(y))
        elif action.startswith("wait:"):
            self.run(int(action[5:]))
        elif action.startswith("hold:"):
            _, key, frames = action.split(":")
            self.press(key, int(frames))
        elif action == "pos":
            print("pos %d %d" % self.pos(), flush=True)
        elif action.startswith("step:"):
            for key in action[5:].split(","):
                self.press(key, frames=16, after=6)
                print(key, "pos %d %d" % self.pos(), flush=True)
        elif action.startswith("export:"):
            self.emu.backup.export_file(action[7:])
        elif action.startswith("shot:"):
            self.screenshot().save(os.path.join(out_dir, action[5:] + ".png"))
        else:
            key, _, n = action.partition("*")
            for _ in range(int(n or 1)):
                self.press(key)


def main():
    rom, state_in, state_out, out_dir = sys.argv[1:5]
    os.makedirs(out_dir, exist_ok=True)
    if state_in.startswith("sav:"):
        d = Driver(rom, battery=state_in[4:])
    else:
        d = Driver(rom, None if state_in == "-" else state_in)
    for a in sys.argv[5:]:
        d.do(a, out_dir)
    d.emu.savestate.save_file(state_out)
    d.screenshot().save(os.path.join(out_dir, "last.png"))


if __name__ == "__main__":
    main()
