#!/usr/bin/env python3
"""Check the roaming legendaries the scripts release (the Legend Archivist's ActivateRoamingPokemon: Zeraora, the
Forces of Nature, the Loyal Three, Calyrex's steeds), in the test build.

From the new game's save, this releases every slot a script releases (gSovereignTestRoamerRelease,
include/sovereign_test.h, which calls RoamingPokemon_ActivateSlot as the script command does) and reads each slot as
the field writes it down (gSovereignTestRoamers). Then:
- **Release:** each slot is roaming, with the species and level RoamingPokemon_ActivateSlot gives it, and HP. No other
  slot roams.
- **Flying:** it flies (the test warp) from route to route, as a player would. Each flight moves every roamer to a
  random place (RoamingPokemon_RandomizeAllLocations): a map of RoamingPokemonRoutes, not the one it was on, and not
  the one the player left.
- **Meeting:** after each flight, when roamers are on the player's map, it runs wild_forms.py's survey there (SAMPLES
  encounters, no battle) with the roamers in it (gSovereignTestSurveyRoamers), as a step in the grass. About half the
  encounters must be a roamer on the map (TryEncounterRoamer's 50%): between MEET_SHARE of them. Each must be that
  roamer itself: its species, its level, its personality. No roamer elsewhere may turn up. It flies until each roamer
  has been met in MEET_TIMES surveys (at most FLIGHTS_MAX flights).
- **Walking:** it walks back and forth across a border between two routes (WALK, CROSSINGS times). Each crossing moves
  every roamer (RoamingPokemon_MoveAllLocations): to a route next to its own (sNearbyRoutes) or, one time in 16, to a
  random one; never to the one it was on or the one the player left. The random moves must be more than none and at
  most RANDOM_SHARE. What starts on a crossing plays out first (the test save's Repel wearing off: A uses another).

Needs what wild_forms.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/roamers.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR
Each problem is a line in OUT_DIR/results.txt, with a summary of each part.
"""
import glob
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from talk_to_objects import (DECOMP, FRAME_LIMIT, HOUR, SYMBOLS, header_names, play_out, symbols, u32,  # noqa: E402
                             warp)
from wild_forms import MON_SIZE, SURVEY, TERRAINS, cases, run_survey, species_names  # noqa: E402

ROAMER = '<HBBHHI'  # struct SovereignTestRoamer: map, route index, level, species, HP, personality
ROAMER_SIZE = struct.calcsize(ROAMER)
FLIGHTS_MAX = 300
MEET_TIMES = 2
MEET_SHARE = (0.25, 0.75)  # of a survey's encounters; 50% expected, so 12 to 36 of 48 is more than 3 sd either way
# Route 212's two halves, across their border: the tile on the north half the player walks from, and the step south.
WALK = ('MAP_HEADER_ROUTE_212_NORTH', 'MAP_HEADER_ROUTE_212_SOUTH', (459, 830), (0, 1))
CROSSINGS = 40
RANDOM_SHARE = 0.15  # of the moves walking makes; 1/16 expected
FACE = {(0, -1): 0, (0, 1): 1, (-1, 0): 2, (1, 0): 3}  # enum FaceDirection
KEY = {(0, -1): 'UP', (0, 1): 'DOWN', (-1, 0): 'LEFT', (1, 0): 'RIGHT'}


def slot_names():
    return [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'roaming_slots.txt')) if line.strip()]


def released():
    """The slots the field scripts release."""
    found = set()
    for path in glob.glob(os.path.join(DECOMP, 'res', 'field', 'scripts', '*.s')):
        found |= set(re.findall(r'ActivateRoamingPokemon (ROAMING_SLOT_\w+)', open(path, encoding='utf-8').read()))
    return sorted(found, key=slot_names().index)


def slot_species():
    """{slot: (species, level)}, from RoamingPokemon_ActivateSlot."""
    text = open(os.path.join(DECOMP, 'src', 'roaming_pokemon.c'), encoding='utf-8').read()
    return {slot: (species, int(level)) for slot, species, level in
            re.findall(r'case (ROAMING_SLOT_\w+):\s*species = (SPECIES_\w+);\s*level = (\d+);', text)}


def routes():
    """([the header of each route index], [the route indexes next to each]) from RoamingPokemonRoutes and
    sNearbyRoutes."""
    header = open(os.path.join(DECOMP, 'include', 'roaming_pokemon.h'), encoding='utf-8').read()
    index = {name: i for i, name in enumerate(re.findall(r'(RI_\w+)', header[header.index('enum RoamerRouteIndex'):]))
             if name != 'RI_MAX'}
    text = open(os.path.join(DECOMP, 'src', 'roaming_pokemon.c'), encoding='utf-8').read()
    table = text[text.index('RoamingPokemonRoutes[RI_MAX]'):]
    headers = [None] * len(index)
    for name, map_header in re.findall(r'\[(RI_\w+)\] = (MAP_HEADER_\w+)', table[:table.index('};')]):
        headers[index[name]] = map_header
    nearby = [None] * len(index)
    table = text[text.index('sNearbyRoutes[RI_MAX]'):]
    for name, count, entries in re.findall(r'\[(RI_\w+)\] = \{\s*(\d+),\s*\{([^}]*)\}', table[:table.index('\n};')]):
        names = [e.strip() for e in entries.split(',') if e.strip()][:int(count)]
        nearby[index[name]] = [int(e) if e.isdigit() else index[e] for e in names]
    return headers, nearby


def read_roamers(d, sym):
    mem = d.emu.memory.unsigned
    base = sym['gSovereignTestRoamers']
    return [struct.unpack(ROAMER, bytes(mem[base + i * ROAMER_SIZE:base + (i + 1) * ROAMER_SIZE]))
            for i in range(len(slot_names()) - 1)]  # less ROAMING_SLOT_MAX


def walk_across(d, sym, step, to_header):
    """Hold the direction until the player is on to_header's map, then play out what starts there (the test save's
    Repel wearing off: A uses another). Returns whether they crossed and the field is free again."""
    for _ in range(4):
        d.press(KEY[step], frames=12, after=0)
        for _ in range(8):
            d.run(4)
            if u32(d, sym['gSovereignTestIdleMapHeaderID']) == to_header:
                return play_out(d, sym, FRAME_LIMIT, to_header, press_a=False)[0] in ('ok', 'NOSCRIPT')
    return False


def main():
    from drive import Driver

    rom, state, out = sys.argv[1:4]
    os.makedirs(out, exist_ok=True)
    sym = symbols(SYMBOLS + ('gSovereignTestWildSurvey', 'gSovereignTestRoamers', 'gSovereignTestRoamerRelease',
                             'gSovereignTestSurveyRoamers'))
    names, ids, species = slot_names(), header_names(), species_names()
    expected = slot_species()
    slots = [names.index(s) for s in released()]
    route_headers, nearby = routes()
    route_ids = [ids.index(h) for h in route_headers]
    places = {header: (header_id, place[0][1:], 'land' if 'land' in terrains else terrains[0])
              for header, header_id, _, place, terrains in cases() if header in route_headers}
    terrain_index = [t for t, _ in TERRAINS]
    survey = sym['gSovereignTestWildSurvey']
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        def say(line, problem=False):
            nonlocal bad
            bad += problem
            print(line, file=f, flush=True)
            print(line, flush=True)

        def name(slot):
            return names[slot][len('ROAMING_SLOT_'):].lower()

        def where(map_id):
            return ids[map_id][len('MAP_HEADER_'):].lower() if map_id < len(ids) else hex(map_id)

        missing = [h for h in route_headers if h not in places]
        if missing:
            say(f'NOPLACE: no tile with wild encounters on {missing}', True)
        flights = [h for h in route_headers if h in places]

        d.load_state(state)
        mem.write_byte(sym['gSovereignTestClock'], HOUR + 1)
        d.run(30)  # the game reads the clock every 11 frames
        mem.write_byte(sym['gSovereignTestGodMode'], 1)  # a battle that starts on the way ends at once
        mem.write_short(sym['gSovereignTestRoamerRelease'], sum(1 << s for s in slots))

        # Release, and the first flight.
        header_id, (x, z), _ = places[flights[0]]
        result, frames = warp(d, sym, header_id, x, z, 0)
        if result != 'ok':
            say(f'first flight to {flights[0]}: {result} {frames}', True)
            sys.exit(1)
        roamers = read_roamers(d, sym)
        for slot in range(len(roamers)):
            map_id, index, level, kind, hp, _ = roamers[slot]
            if slot not in slots:
                if map_id:
                    say(f'release: {name(slot)} roams ({where(map_id)}), though no script releases it', True)
                continue
            want = expected[names[slot]]
            if (species[kind], level) != want or not hp or map_id not in route_ids \
                    or route_ids[index] != map_id:
                say(f'release: {name(slot)} BAD: {species[kind]} Lv. {level}, HP {hp}, on {where(map_id)} '
                    f'(route {index}); want {want[0]} Lv. {want[1]} on a route', True)
        say(f'release: {len(slots)} slots released ({", ".join(name(s) for s in slots)})')

        # Flying, and meeting them.
        met = {slot: 0 for slot in slots}
        surveys = moves = 0
        left = route_ids[0]
        flown = 0
        while flown < FLIGHTS_MAX and min(met.values()) < MEET_TIMES:
            header = flights[(flown * 7 + 1) % len(flights)]  # 7 is prime to the 29 routes: each in turn, spread out
            header_id, (x, z), terrain = places[header]
            if header_id == left:
                header = flights[(flown * 7 + 2) % len(flights)]
                header_id, (x, z), terrain = places[header]
            before = read_roamers(d, sym)
            result, frames = warp(d, sym, header_id, x, z, 0)
            flown += 1
            if result != 'ok':
                say(f'flight {flown} to {header}: {result} {frames}', True)
                break
            roamers = read_roamers(d, sym)
            for slot in slots:
                old, new = before[slot][0], roamers[slot][0]
                moves += 1
                if new not in route_ids or route_ids[roamers[slot][1]] != new or new == old or new == left:
                    say(f'flight {flown} to {where(header_id)} from {where(left)}: {name(slot)} went from '
                        f'{where(old)} to {where(new)} (route {roamers[slot][1]})', True)
            left = header_id

            here = [slot for slot in slots if roamers[slot][0] == header_id]
            if not here:
                continue
            mem.write_byte(sym['gSovereignTestSurveyRoamers'], 1)
            count = run_survey(d, survey, terrain_index.index(terrain))
            mem.write_byte(sym['gSovereignTestSurveyRoamers'], 0)
            surveys += 1
            if count <= 0:
                say(f'meeting on {where(header_id)}: the survey made {count}', True)
                continue
            made = [struct.unpack('<IHBB', bytes(mem.unsigned[survey + SURVEY['mons'] + i * MON_SIZE:
                                                              survey + SURVEY['mons'] + (i + 1) * MON_SIZE]))
                    for i in range(count)]
            roaming_species = {roamers[slot][3] for slot in slots}
            mine = {(roamers[slot][3], roamers[slot][2], roamers[slot][5]): slot for slot in here}
            seen = [m for m in made if m[1] in roaming_species]
            wrong = [m for m in seen if (m[1], m[3], m[0]) not in mine or m[2] != 0]
            for slot in {mine[(m[1], m[3], m[0])] for m in seen if (m[1], m[3], m[0]) in mine}:
                met[slot] += 1
            share = len(seen) / count
            if wrong or not MEET_SHARE[0] <= share <= MEET_SHARE[1]:
                say(f'meeting on {where(header_id)} ({", ".join(name(s) for s in here)}): {len(seen)} of {count} '
                    f'roamers' + (f'; WRONG {[(species[m[1]], m[2], m[3], hex(m[0])) for m in wrong[:4]]}'
                                  if wrong else ''), True)
        say(f'flying: {flown} flights, {moves} moves; {surveys} surveys with roamers on the map; the surveys each was '
            f'met in: ' + ', '.join(f'{name(s)} {met[s]}' for s in slots))
        for slot in slots:
            if met[slot] < MEET_TIMES:
                say(f'meeting: {name(slot)} met in {met[slot]} surveys in {flown} flights', True)

        # Walking.
        north, south, (x, z), step = WALK
        north_id, south_id = ids.index(north), ids.index(south)
        result, frames = warp(d, sym, north_id, x, z, FACE[step] + 1)
        if result != 'ok':
            say(f'walking: the warp to {north} failed: {result} {frames}', True)
        else:
            nearby_moves = random_moves = 0
            here, there, ahead = north_id, south_id, step
            for crossing in range(CROSSINGS):
                before = read_roamers(d, sym)
                if not walk_across(d, sym, ahead, there):
                    d.screenshot().save(os.path.join(out, 'walking.png'))
                    say(f'walking: crossing {crossing + 1} from {where(here)} to {where(there)} never got there '
                        f'(screenshot: walking.png)', True)
                    break
                roamers = read_roamers(d, sym)
                for slot in slots:
                    old, new = before[slot][1], roamers[slot][1]
                    if new in nearby[old]:
                        nearby_moves += 1
                    else:
                        random_moves += 1
                    if roamers[slot][0] not in route_ids or new == old or roamers[slot][0] == here:
                        say(f'walking: crossing {crossing + 1} from {where(here)}: {name(slot)} went from '
                            f'{where(before[slot][0])} to {where(roamers[slot][0])}', True)
                here, there, ahead = there, here, (-ahead[0], -ahead[1])
            total = nearby_moves + random_moves
            share = random_moves / total if total else 0
            say(f'walking: {crossing + 1} crossings, {total} moves: {nearby_moves} to a route nearby, {random_moves} '
                f'elsewhere ({share:.0%})', not 0 < share <= RANDOM_SHARE)
        say(f'{bad} problems')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
