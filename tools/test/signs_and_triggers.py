#!/usr/bin/env python3
"""Read every sign, pick up every hidden item and step on every coord trigger Sovereign added or changed, in the test
build, and check that its script ends.

The events are the bg events (signs, hidden items) and coord triggers of each map that vanilla Platinum (the decomp's
import commit) doesn't have as they are, or whose script's code (the lines under its label) isn't vanilla's. Each is
reached as talk_to_objects.py reaches an object: in by the map's way in first (a scene on entering it plays out), then
a warp to a tile next to it, facing it.
- A bg event: A is pressed facing it (north, for a sign read from the south), and its script is played out.
- A coord trigger: its var is set to the value it waits for (gSovereignTestVar, after the warp, as a map's own local
  vars are cleared on the way in), the player steps onto one of its tiles, and its script is played out.
An event whose script takes another branch later in the story (STORY) runs again with the vars for that branch set.

Each event gets a result, as in talk_to_objects.py: ok, NOSCRIPT (nothing ran: for these events always a problem, as
they don't wait on a flag), OTHER and the script that ran instead (gSovereignTestScripts: a scene, or an object in the
way), NOTILE, NOVAR (the var wasn't set), HANG or STUCK (with a screenshot), or NOWARP and the way in's result. A
script that ends at once (a trigger whose story branch isn't due yet) counts as ok, as gSovereignTestScripts shows
that it ran.

Needs what talk_to_objects.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/signs_and_triggers.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [--postgame | --chronicles] [EVENTS ...]
--postgame and --chronicles work as in talk_to_objects.py: all eight Badges and the Hall of Fame on the way in, and with
--chronicles every Chronicle open too.
"""
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_object_tiles import DIRS, VANILLA_REF, Maps, vanilla_events  # noqa: E402
from talk_to_objects import (DECOMP, FRAME_LIMIT, SYMBOLS, arrive, event_maps, header_names, header_at,  # noqa: E402
                             parse_args, play_out, stand_next_to, symbols, u32, var_ids, way_in_to)

# The way the player faces to read a bg event: the step from the player's tile to it.
BG_DIRS = {'BG_EVENT_DIR_NORTH': ((0, -1),), 'BG_EVENT_DIR_SOUTH': ((0, 1),), 'BG_EVENT_DIR_WEST': ((-1, 0),),
           'BG_EVENT_DIR_EAST': ((1, 0),), 'BG_EVENT_DIR_ALL': DIRS}
KEYS = ('UP', 'DOWN', 'LEFT', 'RIGHT')  # by enum FaceDirection
# Events whose script takes another branch later in the story: (events, event) -> [the vars set first, for each run
# after the first].
STORY = {
    # Mira's exit: with her ribbon quest open she stays (the script ends at once); found, she thanks the player.
    ('events_wayward_cave_1f', 'coord 0'): [(('VAR_SOVEREIGN_MIRA_QUEST_STATE', 3),)],
}


def script_bodies(text):
    """[the code of each script, by its number from 1]: the lines under its ScriptEntry's label, to the next label."""
    bodies = {m.group(1): m.group(2) for m in re.finditer(r'^(\w+):\n(.*?)(?=^\w+:|\Z)', text, re.M | re.S)}
    return [bodies.get(label) for label in re.findall(r'^\s*ScriptEntry (\w+)', text, re.M)]


def changed_scripts(events):
    """The numbers of the map's scripts whose code isn't vanilla's (or that vanilla doesn't have)."""
    path = os.path.join('decomp', 'res', 'field', 'scripts', 'scripts_' + events[len('events_'):] + '.s')
    if not os.path.exists(path):
        return set()
    try:
        old = script_bodies(subprocess.run(['git', 'show', f'{VANILLA_REF}:{path}'], capture_output=True, text=True,
                                           check=True).stdout)
    except subprocess.CalledProcessError:
        old = []
    new = script_bodies(open(path, encoding='utf-8').read())
    return {i + 1 for i, body in enumerate(new) if i >= len(old) or body != old[i]}


def to_test(cur, old, key, changed):
    """The events of this kind that vanilla doesn't have as they are, or whose script changed, with their index in the
    map's list. (Hidden items, scripts from 8000, are the hidden item table's, not the map's.)"""
    have = {json.dumps(e, sort_keys=True) for e in old.get(key, [])}
    return [(i, e) for i, e in enumerate(cur.get(key, []))
            if json.dumps(e, sort_keys=True) not in have or (e['script'] < 8000 and e['script'] in changed)]


def cases():
    """[(events, label, header ID, way in, x, z, facing or None, script, (var, value) for a trigger or None, the story
    vars set first)] for each event, and again for each of its STORY variants."""
    maps = Maps(DECOMP)
    ids = header_names()
    out = []
    for events, headers_of, cur, grid in event_maps():
        matrix = headers_of[0][1]
        old = vanilla_events(os.path.join('decomp', 'res', 'field', 'events', events + '.json'))
        warps = [(w['x'], w['z']) for w in cur.get('warp_events', [])]
        taken = {(o['x'], o['z']) for o in cur.get('object_events', [])}
        changed = changed_scripts(events)
        found = []
        for i, bg in to_test(cur, old, 'bg_events', changed):
            stand = stand_next_to(maps, matrix, grid, warps, taken, bg['x'], bg['z'],
                                  BG_DIRS[bg['player_facing_dir']])
            found.append((f'bg {i}', bg, stand, None))
        for i, c in to_test(cur, old, 'coord_events', changed):
            inside = {(c['x'] + dx, c['z'] + dz) for dx in range(c['width']) for dz in range(c['length'])}
            stand = next((s for s in (stand_next_to(maps, matrix, grid, warps, taken, x, z, enter=True, inside=inside)
                                      for x, z in sorted(inside, key=lambda p: (p[1], p[0]))) if s[2] is not None),
                         (c['x'], c['z'], None))
            found.append((f'coord {i}', c, stand, (c['var'], c['value'])))
        for name, e, stand, trigger in found:
            header = header_at(headers_of, grid, *stand[:2])
            way = way_in_to(maps, matrix, grid, cur, header, taken, stand[:2])
            for story in [()] + STORY.get((events, name), []):
                label = f'{name} (script {e["script"]})' + ''.join(f' {var}={value}' for var, value in story)
                out.append((events, label, ids.index(header), way) + stand + (e['script'], trigger, story))
    return out


def set_var(d, sym, var, value):
    """Set a var on the map the player is on (gSovereignTestVar with no warp target: SELECT+L+R sets only it)."""
    mem = d.emu.memory
    mem.write_short(sym['gSovereignTestVar'], var)
    mem.write_short(sym['gSovereignTestVar'] + 2, value)
    for attempt in range(10):
        d.press('SELECT+L+R', frames=4, after=0)
        d.run(10 + attempt % 2)
        if u32(d, sym['gSovereignTestVar']) & 0xffff == 0:
            return True
    return False


def main():
    from drive import Driver

    rom, state, out, only, part, parts = parse_args(sys.argv[1:])
    sym = symbols(SYMBOLS)
    variables = var_ids()
    chosen = [(i, c) for i, c in enumerate(cases()) if (not only or c[0] in only) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, (events, label, header, way_in, x, z, face, script, trigger, story) in chosen:
            if face is None:
                result, frames = 'NOTILE', 0
            else:
                result, frames = arrive(d, sym, state, variables, events, header, way_in, x, z, face)
                for var, value in story + ((trigger,) if trigger else ()):
                    if result == 'ok' and not set_var(d, sym, variables[var], value):
                        result = 'NOVAR'
                if result == 'ok':
                    d.emu.memory.write_short(sym['gSovereignTestScripts'], 0)
                    if trigger:
                        d.press(KEYS[face], frames=16, after=0)
                    result, frames = play_out(d, sym, FRAME_LIMIT, press_a=not trigger)
                    started = u32(d, sym['gSovereignTestScripts'])
                    if started & 0xffff and started >> 16 != script:
                        result = f'OTHER {started >> 16}'  # another script ran (a scene, an object in the way)
                    elif result == 'NOSCRIPT' and started & 0xffff:
                        result = 'ok'  # it ended at once
            if result != 'ok':
                bad += 1
                if face is not None:
                    d.screenshot().save(os.path.join(out, f'{index:03d}_{events}_{result}.png'))
            line = f'{index} {events} {label} ({x}, {z}): {result} {frames}'
            print(line, file=f, flush=True)
            print(line, flush=True)
    print(f'{len(chosen) - bad} of {len(chosen)} ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
