#!/usr/bin/env python3
"""Show the battle sprites of #494-1025 in the test build: each species' front as the wild foe and its back as the
player's lead, normal and shiny (the Gen 5-9 sprites, tools/sprites/convert_battle_sprites.py).

For each species, normal and then shiny, this loads a save state and sets two test hooks (include/sovereign_test.h):
the lead (gSovereignTestLead: the species at Lv. 50, shiny if asked) and the wild Pokemon (gSovereignTestWild: the
same). SELECT starts the wild battle, and once both are out (SHOT_FRAMES) it saves the top screen. Contact sheets of
those shots, SHEET species a page with their dex numbers, go to OUT_DIR/sheet_NN_normal.png and sheet_NN_shiny.png. A
battle that hangs (the main loop stops) is a line in OUT_DIR/results.txt.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/sprite_check.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [FIRST-LAST]
FIRST-LAST limits it to those dex numbers, and --part I/N to every Nth species from the Ith (from 0; to run N at once,
each with its own OUT_DIR, with the sheets made per part).
"""
import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_trainers import HANG_FRAMES, STEP, VBLANK_COUNTER, symbols  # noqa: E402
from battle_form_changes import LEAD  # noqa: E402
from check_trainer_party import consts  # noqa: E402
from talk_to_objects import u32  # noqa: E402

FIRST, LAST = 494, 1025
LEVEL = 50
SHOT_FRAMES = 1300  # from SELECT until both Pokemon are out and the command menu waits
LEAD_SHINY = 24  # offsetof(struct SovereignTestLead, shiny)
WILD = {'species': 0, 'level': 3, 'shiny': 6}  # struct SovereignTestWild
SHEET, COLUMNS = 48, 8
LABEL = 14  # the label's height above each shot


def shoot(d, sym, species_id, shiny):
    """The top screen once the battle with species_id (shiny or not) has both Pokemon out, or None if it hangs."""
    mem = d.emu.memory
    lead, wild = sym['gSovereignTestLead'], sym['gSovereignTestWild']
    mem.write_short(lead + LEAD['species'], species_id)
    mem.write_byte(lead + LEAD['level'], LEVEL)
    mem.write_byte(lead + LEAD_SHINY, int(shiny))
    mem.write_short(wild + WILD['species'], species_id)
    mem.write_byte(wild + WILD['level'], LEVEL)
    mem.write_byte(wild + WILD['shiny'], int(shiny))
    mem.write_byte(sym['gSovereignTestGodMode'], 1)
    d.press('SELECT')
    vblank, stalled = u32(d, sym['gSystem'] + VBLANK_COUNTER), 0
    for _ in range(SHOT_FRAMES // STEP):
        d.run(STEP)
        now = u32(d, sym['gSystem'] + VBLANK_COUNTER)
        stalled = stalled + STEP if now == vblank else 0
        vblank = now
        if stalled >= HANG_FRAMES:
            return None
    screen = d.screenshot()
    return screen.crop((0, 0, screen.width, screen.height // 2))


def sheets(out, shots, kind):
    """Contact sheets of shots [(dex, image)], SHEET a page."""
    for page in range(0, len(shots), SHEET):
        chunk = shots[page:page + SHEET]
        w, h = chunk[0][1].size
        rows = (len(chunk) + COLUMNS - 1) // COLUMNS
        sheet = Image.new('RGB', (COLUMNS * w, rows * (h + LABEL)), 'white')
        draw = ImageDraw.Draw(sheet)
        for i, (dex, image) in enumerate(chunk):
            x, y = i % COLUMNS * w, i // COLUMNS * (h + LABEL)
            draw.text((x + 4, y + 1), f'#{dex}', fill='black')
            sheet.paste(image, (x, y + LABEL))
        sheet.save(os.path.join(out, f'sheet_{page // SHEET:02d}_{kind}.png'))


def main():
    from drive import Driver

    args = sys.argv[1:]
    part, parts = 0, 1
    if '--part' in args:
        at = args.index('--part')
        part, parts = map(int, args[at + 1].split('/'))
        args = args[:at] + args[at + 2:]
    rom, state, out = args[:3]
    first, last = map(int, args[3].split('-')) if len(args) > 3 else (FIRST, LAST)
    os.makedirs(out, exist_ok=True)
    sym = symbols(('gSovereignTestLead', 'gSovereignTestWild', 'gSovereignTestGodMode', 'gSystem'))
    species_ids = consts('species.txt')
    chosen = [dex for dex in range(first, last + 1) if (dex - first) % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False

    shots = {False: [], True: []}
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for dex in chosen:
            for shiny in (False, True):
                d.load_state(state)
                d.run(30)
                image = shoot(d, sym, dex, shiny)
                if image is None:
                    print(f'{dex} {species_ids[dex]} {"shiny" if shiny else "normal"}: HANG', file=f, flush=True)
                else:
                    shots[shiny].append((dex, image))
    for shiny, kind in ((False, 'normal'), (True, 'shiny')):
        if shots[shiny]:
            sheets(out, shots[shiny], kind)
    print(f'{len(chosen)} species, {len(shots[False]) + len(shots[True])} shots')


if __name__ == '__main__':
    main()
