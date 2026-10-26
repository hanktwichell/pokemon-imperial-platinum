#!/usr/bin/env python3
"""Show the battle sprites of #494-1025 in the test build: each species' front as the wild foe and its back as the
player's lead, normal and shiny (the Gen 5-9 sprites, tools/sprites/convert_battle_sprites.py).

For each species, normal and then shiny, this loads a save state and sets two test hooks (include/sovereign_test.h):
the lead (gSovereignTestLead: the species at Lv. 50, shiny if asked) and the wild Pokemon (gSovereignTestWild: the
same). SELECT starts the wild battle, and once both are out (SHOT_FRAMES) it saves the top screen. Contact sheets of
those shots, SHEET species a page with their dex numbers, go to OUT_DIR/sheet_NN_normal.png and sheet_NN_shiny.png. A
battle that hangs (the main loop stops) is a line in OUT_DIR/results.txt.

With --forms, it shows Sovereign's forms instead: each form that has a front sprite of its own
(include/data/sovereign_form_sprites.h), in that form, labelled with its name. Their backs are their species' for now.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/sprite_check.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [--forms] [FIRST-LAST]
FIRST-LAST limits it to those dex numbers (or, with --forms, to those places in the list), and --part I/N to every
Nth from the Ith (from 0; to run N at once, each with its own OUT_DIR, with the sheets made per part).
"""
import os
import re
import sys
import unicodedata

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_species import sovereign_forms  # noqa: E402
from battle_all_trainers import DECOMP, HANG_FRAMES, STEP, VBLANK_COUNTER, symbols  # noqa: E402
from battle_form_changes import LEAD  # noqa: E402
from check_trainer_party import consts  # noqa: E402
from talk_to_objects import u32  # noqa: E402

FIRST, LAST = 494, 1025
LEVEL = 50
SHOT_FRAMES = 1300  # from SELECT until both Pokemon are out and the command menu waits
LEAD_SHINY = 24  # offsetof(struct SovereignTestLead, shiny)
WILD = {'species': 0, 'form': 2, 'level': 3, 'shiny': 6}  # struct SovereignTestWild
SHEET, COLUMNS = 48, 8
LABEL = 14  # the label's height above each shot


def form_cases():
    """[(label, species constant, form)]: each of sSovereignForms that has a front sprite of its own, with the name
    tools/dataproc/src/sovereign_forms.inc gives it."""
    table = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_form_sprites.h')).read()
    has = {int(i) for i in re.findall(r'\[(\d+)\] = \d+', table)}
    inc = open(os.path.join(DECOMP, 'tools', 'dataproc', 'src', 'sovereign_forms.inc'), encoding='utf-8').read()
    names = re.findall(r'\{ "[^"/]+/forms/[^"]+", NULL.*?// (.*)', inc)
    return [(names[i].strip(), name, form) for i, (name, form, *_) in enumerate(sovereign_forms()) if i in has]


def ascii_label(text):
    return unicodedata.normalize('NFKD', text).encode('ascii', 'ignore').decode()


def shoot(d, sym, species_id, form, shiny):
    """The top screen once the battle with species_id in form (shiny or not) has both Pokemon out, or None if it
    hangs."""
    mem = d.emu.memory
    lead, wild = sym['gSovereignTestLead'], sym['gSovereignTestWild']
    mem.write_short(lead + LEAD['species'], species_id)
    mem.write_byte(lead + LEAD['form'], form)
    mem.write_byte(lead + LEAD['level'], LEVEL)
    mem.write_byte(lead + LEAD_SHINY, int(shiny))
    mem.write_short(wild + WILD['species'], species_id)
    mem.write_byte(wild + WILD['form'], form)
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
    """Contact sheets of shots [(label, image)], SHEET a page."""
    for page in range(0, len(shots), SHEET):
        chunk = shots[page:page + SHEET]
        w, h = chunk[0][1].size
        rows = (len(chunk) + COLUMNS - 1) // COLUMNS
        sheet = Image.new('RGB', (COLUMNS * w, rows * (h + LABEL)), 'white')
        draw = ImageDraw.Draw(sheet)
        for i, (label, image) in enumerate(chunk):
            x, y = i % COLUMNS * w, i // COLUMNS * (h + LABEL)
            draw.text((x + 4, y + 1), label, fill='black')
            sheet.paste(image, (x, y + LABEL))
        sheet.save(os.path.join(out, f'sheet_{page // SHEET:02d}_{kind}.png'))


def main():
    from drive import Driver

    args = sys.argv[1:]
    forms = '--forms' in args
    args = [a for a in args if a != '--forms']
    part, parts = 0, 1
    if '--part' in args:
        at = args.index('--part')
        part, parts = map(int, args[at + 1].split('/'))
        args = args[:at] + args[at + 2:]
    rom, state, out = args[:3]
    os.makedirs(out, exist_ok=True)
    sym = symbols(('gSovereignTestLead', 'gSovereignTestWild', 'gSovereignTestGodMode', 'gSystem'))
    species_ids = consts('species.txt')
    if forms:
        cases = [(ascii_label(label), species_ids.index(name), form) for label, name, form in form_cases()]
        first, last = map(int, args[3].split('-')) if len(args) > 3 else (0, len(cases) - 1)
        cases = list(enumerate(cases))[first:last + 1]
    else:
        first, last = map(int, args[3].split('-')) if len(args) > 3 else (FIRST, LAST)
        cases = [(dex, (f'#{dex}', dex, 0)) for dex in range(first, last + 1)]
    chosen = [case for at, case in cases if (at - first) % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False

    shots = {False: [], True: []}
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for label, species_id, form in chosen:
            for shiny in (False, True):
                d.load_state(state)
                d.run(30)
                image = shoot(d, sym, species_id, form, shiny)
                if image is None:
                    print(f'{label} {species_ids[species_id]} {form} {"shiny" if shiny else "normal"}: HANG', file=f,
                          flush=True)
                else:
                    shots[shiny].append((label, image))
    for shiny, kind in ((False, 'normal'), (True, 'shiny')):
        if shots[shiny]:
            sheets(out, shots[shiny], kind)
    print(f'{len(chosen)} {"forms" if forms else "species"}, {len(shots[False]) + len(shots[True])} shots')


if __name__ == '__main__':
    main()
