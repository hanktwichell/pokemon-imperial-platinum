#!/usr/bin/env python3
"""Talk to every map object Sovereign added or moved, in the test build, and check that its script ends.

The objects are check_object_tiles.py's: an object vanilla Platinum doesn't have on that tile with those graphics,
with a script. For each one this finds a tile next to it that the player can reach (or across a counter), warps there
facing it (gSovereignTestWarpTarget, include/sovereign_test.h: the map, the tile and the direction) and presses A.
Then it plays the script out: A pages through text and answers prompts, taps on the touch screen pick moves in a
battle (god mode is on, so a trainer's battle ends at once, as in battle_all_trainers.py), and B now and then backs
out of a menu. A scene on entering the map is played out the same way, and then it warps again, as the scene may have
moved the player. The script has ended when the field is idle again (gSovereignTestIdleFrames).

Each object gets a result:
- ok: a script ran and ended;
- NOSCRIPT: nothing ran when A was pressed, so the object isn't there on a new game (a flag hides it until later in
  the story) or something else stands in the way;
- NOTILE: no reachable tile next to it (check_object_tiles.py reports these too);
- HANG (the game stopped running) or STUCK (still busy at the time limit), with a screenshot. A STUCK can be a menu
  the inputs don't get out of; the screenshot shows which. NOWARP HANG or NOWARP STUCK: the same on the way in, as
  a scene on entering the map plays out (it may move the player off the tile).

The test save is a new game with the test party (src/script_manager.c), so a script follows its early-game branch:
an NPC whose gift waits on badges says so, and that is what runs.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/talk_to_objects.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [EVENTS ...]
EVENTS (an events file's name, e.g. events_route_201) limits the list to those maps, and --part I/N to every Nth
object from the Ith (from 0; to run N at once, each with its own OUT_DIR). Each result is a line in
OUT_DIR/results.txt.
"""
import json
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_trainers import DECOMP, HANG_FRAMES, STEP, SWITCH_FRAMES, TAPS, VBLANK_COUNTER, symbols  # noqa: E402
from check_object_tiles import DIRS, TABLE, WINDOW, Maps, can_turn, explore, vanilla_events  # noqa: E402

FRAME_LIMIT = 20000  # a six-Pokémon trainer battle with its text takes about 8000
START_FRAMES = 90  # a script that hasn't started by then never will
SCENE_FRAMES = 600  # a warp that took longer had a scene on the way in
WARP = {'header': 0, 'x': 2, 'z': 4, 'dir': 6}  # struct SovereignTestWarpTarget
FACE = {(0, -1): 0, (0, 1): 1, (-1, 0): 2, (1, 0): 3}  # enum FaceDirection: the step from the player to the object


def header_names():
    return [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'map_headers.txt')) if line.strip()]


def cases():
    """[(events, object id, header ID, x, z, facing, or None when no tile)] for each added or moved object."""
    maps = Maps(DECOMP)
    ids = header_names()
    headers = open(os.path.join(DECOMP, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
    by_events = {}
    for name, block in re.findall(r'\[(MAP_HEADER_\w+)\] = \{(.*?)\n    \},', headers, re.S):
        fields = dict(re.findall(r'\.(\w+) = (\w+)', block))
        if 'eventsArchiveID' in fields and 'mapMatrixID' in fields:
            by_events.setdefault(fields['eventsArchiveID'], []).append((name, fields['mapMatrixID']))
    out = []
    for events, headers_of in sorted(by_events.items()):
        path = os.path.join(DECOMP, 'res', 'field', 'events', events + '.json')
        if not os.path.exists(path):
            continue
        matrix = headers_of[0][1]
        cur = json.load(open(path, encoding='utf-8'))
        old = {(o['graphics_id'], o['x'], o['z'])
               for o in vanilla_events(path.replace(DECOMP, 'decomp', 1)).get('object_events', [])}
        objs = cur.get('object_events', [])
        warps = [(w['x'], w['z']) for w in cur.get('warp_events', [])]
        grid = json.load(open(os.path.join(DECOMP, 'res', 'field', 'matrices', matrix + '.json'), encoding='utf-8'))
        rows = grid['maps']
        whole_map = len(rows) * len(rows[0]) <= 16
        taken = {(o['x'], o['z']) for o in objs}
        for o in objs:
            x, z = o['x'], o['z']
            if (o['graphics_id'], x, z) in old or maps.tile(matrix, x, z) is None or not o.get('script'):
                continue
            header = headers_of[0][0]
            if grid.get('headers'):  # an outdoor matrix: the header of the object's own map
                row, col = z // 32, x // 32
                if row < len(grid['headers']) and col < len(grid['headers'][row]) \
                        and grid['headers'][row][col] in [h for h, _ in headers_of]:
                    header = grid['headers'][row][col]
            if whole_map:
                box, edge = (0, 0, len(rows[0]) * 32 - 1, len(rows) * 32 - 1), []
            else:
                box = (x - WINDOW, z - WINDOW, x + WINDOW, z + WINDOW)
                edge = [(i, j) for i in range(box[0], box[2] + 1) for j in (box[1], box[3])] + \
                       [(i, j) for j in range(box[1], box[3] + 1) for i in (box[0], box[2])]
            # Past the other objects if it can (some may be hidden by a flag, so then through them).
            stand = None
            for blocked in (taken, {(x, z)}):
                seen = explore(maps, matrix, box, edge, warps, blocked)
                stand = stand or next(((x - d[0], z - d[1], FACE[d]) for d in DIRS
                                       if (x - d[0], z - d[1]) not in blocked
                                       and (x - d[0], z - d[1], False) in seen
                                       and can_turn(maps, matrix, x - d[0], z - d[1], False, d)), None)
                stand = stand or next(((x - 2 * d[0], z - 2 * d[1], FACE[d]) for d in DIRS
                                       if (maps.tile(matrix, x - d[0], z - d[1]) or 0) & 0xff == TABLE
                                       and (x - 2 * d[0], z - 2 * d[1], False) in seen), None)
            out.append((events, o['id'], ids.index(header)) + (stand or (x, z, None)))
    return out


def play_out(d, sym, limit, header=None, press_a=True):
    """Play out what runs now (a script, a scene on entering a map, a battle) until the field is idle (on header, if
    given). With press_a, A is pressed first, to talk. Returns ('ok', 'NOSCRIPT' (nothing ran), 'HANG' or 'STUCK',
    frames run)."""
    def u32(addr):
        return struct.unpack('<I', bytes(d.emu.memory.unsigned[addr:addr + 4]))[0]

    if press_a:
        d.press('A', frames=4, after=0)
    frames, stalled, started, idle, step = 0, 0, not press_a, 0, 0
    vblank = u32(sym['gSystem'] + VBLANK_COUNTER)
    while frames < limit:
        before = u32(sym['gSovereignTestIdleFrames'])
        d.run(STEP)
        frames += STEP
        now = u32(sym['gSystem'] + VBLANK_COUNTER)
        stalled = stalled + STEP if now == vblank else 0
        vblank = now
        if stalled >= HANG_FRAMES:
            return 'HANG', frames
        if u32(sym['gSovereignTestIdleFrames']) == before:
            started, idle = True, 0
            step += 1
            if step % 7 == 0:  # backs out of a menu the other inputs keep open (a shop, the party screen)
                d.press('B', frames=4, after=0)
            elif step % 3 == 0:  # text, prompts, and the move a tap opened in a battle
                d.press('A', frames=4, after=0)
            else:
                d.touch(*TAPS[frames // SWITCH_FRAMES % len(TAPS)], frames=4, after=0)
        elif started and (header is None or u32(sym['gSovereignTestIdleMapHeaderID']) == header):
            idle += 1
            if idle >= 2:
                return 'ok', frames
        elif frames >= START_FRAMES:
            return 'NOSCRIPT', frames
    return 'STUCK', frames


def main():
    from drive import Driver

    args = sys.argv[1:]
    part, parts = 0, 1
    if '--part' in args:
        at = args.index('--part')
        part, parts = map(int, args[at + 1].split('/'))
        del args[at:at + 2]
    rom, state, out = args[:3]
    only = set(args[3:])
    os.makedirs(out, exist_ok=True)
    sym = symbols(('gSovereignTestWarpTarget', 'gSovereignTestIdleFrames', 'gSovereignTestIdleMapHeaderID',
                   'gSovereignTestGodMode', 'gSystem'))
    chosen = [(i, c) for i, c in enumerate(cases()) if (not only or c[0] in only) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, (events, oid, header, x, z, face) in chosen:
            if face is None:
                result, frames = 'NOTILE', 0
            else:
                d.emu.savestate.load_file(state)
                d.run(30)

                def write_target():
                    target = sym['gSovereignTestWarpTarget']
                    mem.write_short(target + WARP['x'], x)
                    mem.write_short(target + WARP['z'], z)
                    mem.write_short(target + WARP['dir'], face + 1)
                    mem.write_short(target + WARP['header'], header)

                write_target()
                mem.write_byte(sym['gSovereignTestGodMode'], 1)
                d.press('SELECT+L+R')
                # Until the field runs on the map, past any scene on the way in. A scene may move the player, so then
                # it warps again (the scene has run, so it doesn't run twice).
                arrived, waited = play_out(d, sym, FRAME_LIMIT, header, press_a=False)
                if arrived == 'ok' and waited > SCENE_FRAMES:
                    write_target()
                    d.press('SELECT+L+R')
                    arrived, waited = play_out(d, sym, FRAME_LIMIT, header, press_a=False)
                result, frames = play_out(d, sym, FRAME_LIMIT) if arrived == 'ok' else ('NOWARP ' + arrived, waited)
            if result not in ('ok', 'NOSCRIPT'):
                bad += 1
                if face is not None:
                    d.screenshot().save(os.path.join(out, f'{index:03d}_{events}_{result}.png'))
            line = f'{index} {events} {oid} ({x}, {z}): {result} {frames}'
            print(line, file=f, flush=True)
            print(line, flush=True)
    print(f'{len(chosen) - bad} of {len(chosen)} ok or not there')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
