#!/usr/bin/env python3
"""Warp into every map whose events or scripts Sovereign changed, and check that the field runs there.

For each map header whose events, scripts or init scripts differ from vanilla (VANILLA_REF in check_object_tiles.py),
this picks a spawn tile: the first warp on the map's own part of its matrix, or else the walkable tile nearest the
middle of one of its blocks. It warps there in the test build (it writes the place to gSovereignTestWarpTarget and
presses SELECT+L+R; src/script_manager.c) and waits until the field is idle on that map, which is when
gSovereignTestIdleFrames (src/field_system.c) counts up: no script, warp or battle is running.

A map that is idle but leaves a heap's block lists broken (heap_check.py) is a HEAP: a failed load freed, say,
which crashes the game or writes over memory later. A map that isn't idle within the time limit is a FAIL. That is a
crash or a hang, or a scene on entry: B is pressed now and then to page through text, which isn't enough for a battle
or a long scene. Each map's last screen is saved.
Re-run the FAILs with --scene, which presses A, waits longer and saves a screen every 600 frames, to tell them apart.

Needs the test build (tools/test/build_test_rom.sh) with its symbol map (decomp/build_test/main.nef.xMAP), a save
state at the bedroom made with that build (tools/test/new_game.sh), the git history, py-desmume and Pillow.
From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/visit_changed_maps.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--scene] [INDEX ...]
INDEX picks maps by their place in the list (printed first in each result line). The whole list takes about an hour.
"""
import json
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_object_tiles import COLLISION, VANILLA_REF, Maps  # noqa: E402
from heap_check import heap_info_address, heap_problems  # noqa: E402

DECOMP = 'decomp'
SYMBOLS = ('gSovereignTestWarpTarget', 'gSovereignTestIdleFrames', 'gSovereignTestIdleMapHeaderID')


def changed_maps():
    """[(map header ID, map header name, x, z)] for each changed map header that has a field map."""
    maps = Maps(DECOMP)
    ids = [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'map_headers.txt')) if line.strip()]
    changed = set()
    for path in subprocess.run(['git', 'diff', '--name-only', VANILLA_REF, '--',
                                f'{DECOMP}/res/field/events', f'{DECOMP}/res/field/scripts'],
                               capture_output=True, text=True, check=True).stdout.split():
        changed.add(os.path.splitext(os.path.basename(path))[0])
    headers = open(os.path.join(DECOMP, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
    out = []
    for name, block in re.findall(r'\[(MAP_HEADER_\w+)\] = \{(.*?)\n    \},', headers, re.S):
        fields = dict(re.findall(r'\.(\w+) = (\w+)', block))
        files = {fields.get('eventsArchiveID'), fields.get('scriptsArchiveID'), fields.get('initScriptsArchiveID')}
        if not files & changed or 'mapMatrixID' not in fields or 'eventsArchiveID' not in fields:
            continue
        matrix = fields['mapMatrixID']
        grid = json.load(open(os.path.join(DECOMP, 'res', 'field', 'matrices', matrix + '.json'), encoding='utf-8'))
        events = json.load(open(os.path.join(DECOMP, 'res', 'field', 'events', fields['eventsArchiveID'] + '.json'),
                                encoding='utf-8'))

        def own(x, z):  # on this header's part of a shared matrix
            if not grid.get('headers'):
                return True
            row, col = z // 32, x // 32
            return row < len(grid['headers']) and col < len(grid['headers'][row]) and grid['headers'][row][col] == name

        def free(x, z):
            tile = maps.tile(matrix, x, z)
            return tile is not None and not tile & COLLISION

        spawn = next(((w['x'], w['z']) for w in events.get('warp_events', [])
                      if maps.tile(matrix, w['x'], w['z']) is not None and own(w['x'], w['z'])), None)
        for row, cells in enumerate(grid['maps']):
            for col, cell in enumerate(cells):
                x, z = col * 32 + 16, row * 32 + 16
                if spawn is None and cell != 'MAP_NONE' and own(x, z):
                    near = [(abs(dx) + abs(dz), (x + dx, z + dz)) for dz in range(-16, 16) for dx in range(-16, 16)
                            if free(x + dx, z + dz)]
                    spawn = min(near)[1] if near else None
        if spawn:
            out.append((ids.index(name), name) + spawn)
    return out


def symbol_addresses():
    xmap = open(os.path.join(DECOMP, 'build_test', 'main.nef.xMAP'), encoding='utf-8', errors='replace').read()
    return [int(re.search(r'^\s*([0-9A-F]{8}) [0-9A-F]{8} \.bss\s+' + s + r'\b', xmap, re.M).group(1), 16)
            for s in SYMBOLS]


def main():
    from drive import Driver

    rom, state, out = sys.argv[1:4]
    scene = '--scene' in sys.argv[4:]
    only = {int(a) for a in sys.argv[4:] if a.isdigit()}
    os.makedirs(out, exist_ok=True)
    target_addr, idle_addr, map_addr = symbol_addresses()
    heaps = heap_info_address()
    d = Driver(rom, state)

    def u32(addr):
        return struct.unpack('<I', bytes(d.emu.memory.unsigned[addr:addr + 4]))[0]

    failures = []
    for i, (header, name, x, z) in enumerate(changed_maps()):
        if only and i not in only:
            continue
        d.load_state(state)
        d.run(30)
        d.emu.memory.write_short(target_addr, header)
        d.emu.memory.write_short(target_addr + 2, x)
        d.emu.memory.write_short(target_addr + 4, z)
        d.do('SELECT+L+R', out)
        frames, idle, limit = 0, 0, 12000 if scene else 2400
        while frames < limit and idle < 2:
            before = u32(idle_addr)
            d.run(30)
            frames += 30
            idle = idle + 1 if u32(idle_addr) > before and u32(map_addr) == header else 0
            if scene and frames % 600 == 0:
                d.screenshot().save(os.path.join(out, f'{i:03d}_{frames:05d}.png'))
            if idle == 0 and frames % (60 if scene else 120) == 0:
                d.press('A' if scene else 'B', frames=4, after=4)
        problems = heap_problems(d.emu.memory, heaps) if idle >= 2 else []
        result = 'FAIL' if idle < 2 else 'HEAP' if problems else 'ok'
        d.screenshot().save(os.path.join(out, f'{i:03d}_{name}_{result}.png'))
        print(i, name, result, frames, 'on', u32(map_addr), *problems, flush=True)
        if result != 'ok':
            failures.append(i)
    print('failures:', ' '.join(map(str, failures)) or 'none')
    sys.exit(1 if failures else 0)


if __name__ == '__main__':
    main()
