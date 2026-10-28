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
- **Battles:** it flies on until it has battled each roamer once, for real: a survey with SURVEY_ROAMERS_BATTLE starts
  a battle with the first roamer it meets (through Encounter_NewVsWild, as a step in the grass would), and the battle
  plays out as talk_to_objects.py plays a script out (god mode: a foe hit loses all its HP). A roamer's AI
  (AI_FLAG_ROAMING_POKEMON) flees on its first turn, in speed order, as in Platinum, where a faster lead can trap one
  first. So one faster than the test party's lead flees, and one slower is knocked out first. Afterwards
  (RoamerAfterBattle_UpdateRoamers), its state var (VAR_ROAMING_<NAME>_STATE, read through gSovereignTestWatch) and
  where it is must match:
  - fled: it still roams, with the HP it had, and its state is still roaming (0);
  - knocked out: it no longer roams, and its state is defeated (2), which the next Hall of Fame resets so the Legend
    Archivist releases it again;
  - either way, every roamer that was on the map has left it.
- **Catching:** it flies on until a roamer still roaming is on the map, battles it, and once the battle asks "What
  will ... do?" (its message log, gSovereignTestMessageLog) throws a Master Ball from the battle's bag
  (gSovereignTestBagItem put it there; CATCH_TAPS), as a player would on its first turn: an item comes before its
  escape. Then it declines the nickname (NICKNAME_NO) and the Pokémon goes to the PC (the party is full).
  Afterwards it must no longer roam, its state var must be captured (1), which the Legend Archivist never releases
  again, and every roamer that was on the map must have left it.
- **Marking Map:** it flies to MARKING_MAP's town with the Pokétch on and showing the Marking Map
  (gSovereignTestPoketchApp), and walks there, each step moving the player a tile (drive.py's pos()): the map looks a
  roamer up only while the player walks (from the 5th step on, CheckPositionsUpdated). Then each roamer still roaming
  must have its icon on the Pokétch at its route's place (PoketchMap_GetPositionFromMapID), read from the sub screen's
  OAM over the icons' blink, and no other roamer icon may show: not the one knocked out, not the one caught. A
  screenshot of both screens is saved (marking_map.png).

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
from battle_mechanics import LOG_CHARS, charmap, decode_log, log_length  # noqa: E402
from talk_to_objects import (DECOMP, FRAME_LIMIT, HOUR, SYMBOLS, header_names, play_out, symbols, u32,  # noqa: E402
                             var_ids, warp)
from wild_forms import MON_SIZE, SURVEY, TERRAINS, cases, run_survey, species_names  # noqa: E402

ROAMER = '<HBBHHI'  # struct SovereignTestRoamer: map, route index, level, species, HP, personality
ROAMER_SIZE = struct.calcsize(ROAMER)
SURVEY_ROAMERS_BATTLE = 2  # SOVEREIGN_TEST_SURVEY_ROAMERS_BATTLE
ROAMER_STATE_ROAMING, ROAMER_STATE_CAPTURED, ROAMER_STATE_DEFEATED = 0, 1, 2  # constants/roamer_states.h
ITEM_MASTER_BALL = 1
# The battle's intro, to "What will ... do?" (which then waits for the player): at most this many frames (a weather's
# message makes it longer: rain on Route 215 took past 1000), then a little more for the menu to come up.
BATTLE_INTRO_FRAMES = 3000
MENU_FRAMES = 60
# Touches (x, y, frames held) that throw the Master Ball: BAG, the Poké Balls pocket, the Master Ball (the pocket's
# second entry, after the test save's Poké Balls) and USE. The items in a pocket only take a touch held a while.
CATCH_TAPS = ((40, 170, 10), (192, 56, 10), (192, 40, 30), (110, 174, 30))
NICKNAME_NO = (128, 140)  # the nickname prompt's No; a touch there also pages through the text and the Pokédex entry
CATCH_TOUCHES = 300
FLIGHTS_MAX = 300
MEET_TIMES = 2
MEET_SHARE = (0.25, 0.75)  # of a survey's encounters; 50% expected, so 12 to 36 of 48 is more than 3 sd either way
# Route 212's two halves, across their border: the tile on the north half the player walks from, and the step south.
WALK = ('MAP_HEADER_ROUTE_212_NORTH', 'MAP_HEADER_ROUTE_212_SOUTH', (459, 830), (0, 1))
CROSSINGS = 40
RANDOM_SHARE = 0.15  # of the moves walking makes; 1/16 expected
# The Marking Map check: a town (no wild Pokémon, so no roamer meets the player there), the tile it starts on, and the
# walk (steps right, then back left).
MARKING_MAP = ('MAP_HEADER_TWINLEAF_TOWN', (106, 877), 6)
SUB_OAM = 0x07000400  # the sub screen's OAM, which the Pokétch draws its sprites into
MAP_ICON_CORNER = 16  # a Marking Map icon's cell is 32x32, placed by its middle
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


def poketch_app(name):
    apps = [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'poketch_apps.txt')) if line.strip()]
    return apps.index(name)


def marking_map_places():
    """{map ID: (x, y)} where the Marking Map shows a roamer on that map (PoketchMap_GetPositionFromMapID)."""
    text = open(os.path.join(DECOMP, 'src', 'applications', 'poketch', 'poketch_map.c'), encoding='utf-8').read()
    table = text[text.index('PoketchMap_GetPositionFromMapID'):]
    return {int(m): (int(x), int(y)) for m, x, y in
            re.findall(r'\{ MAP_(\d+), (\d+), (\d+) \}', table[:table.index('};')])}


def sub_screen_sprites(d):
    """The sub screen's sprites on the screen: [(x, y, tile)]. The map's icons blink, so this looks over two seconds
    and keeps the frame that shows the most."""
    mem = d.emu.memory.unsigned
    best = []
    for _ in range(30):
        d.run(4)
        shown = []
        for i in range(128):
            attr0, attr1, attr2 = struct.unpack('<HHH', bytes(mem[SUB_OAM + i * 8:SUB_OAM + i * 8 + 6]))
            if (attr0 >> 8) & 3 != 2 and (attr0 & 0xff) < 192:  # not disabled, and not parked below the screen
                shown.append((attr1 & 0x1ff, attr0 & 0xff, attr2 & 0x3ff))
        best = shown if len(shown) > len(best) else best
    return best


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


def wait_for_prompt(d, sym, chars):
    """Run the battle until the last message in its log (gSovereignTestMessageLog, cleared before the battle) is
    "What will ... do?", and the menu is up. Returns the frames it took, or None after BATTLE_INTRO_FRAMES."""
    log = sym['gSovereignTestMessageLog']
    for frames in range(0, BATTLE_INTRO_FRAMES, 10):
        length = min(log_length(d, sym), LOG_CHARS)
        # py-desmume's memory gives an empty slice as the byte at its start (a number), so none is read.
        raw = bytes(d.emu.memory.unsigned[log + 2:log + 2 + 2 * length]) if length else b''
        messages = decode_log([raw[i] | raw[i + 1] << 8 for i in range(0, len(raw), 2)], chars)
        if messages and messages[-1].startswith('What will'):
            d.run(MENU_FRAMES)
            return frames
        d.run(10)
    return None


def main():
    from drive import Driver

    rom, state, out = sys.argv[1:4]
    os.makedirs(out, exist_ok=True)
    sym = symbols(SYMBOLS + ('gSovereignTestWildSurvey', 'gSovereignTestRoamers', 'gSovereignTestRoamerRelease',
                             'gSovereignTestSurveyRoamers', 'gSovereignTestWatch', 'gSovereignTestPoketchApp',
                             'gSovereignTestMessageLog'))
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

        flight = {'flown': 0, 'moves': 0, 'left': route_ids[0]}

        def fly():
            """Fly to the next route, and check where the roamers went. Returns (the route's header ID, its terrain,
            the roamers), or None if the flight failed."""
            flown, left = flight['flown'], flight['left']
            header = flights[(flown * 7 + 1) % len(flights)]  # 7 is prime to the 29 routes: each in turn, spread out
            header_id, (x, z), terrain = places[header]
            if header_id == left:
                header = flights[(flown * 7 + 2) % len(flights)]
                header_id, (x, z), terrain = places[header]
            before = read_roamers(d, sym)
            result, frames = warp(d, sym, header_id, x, z, 0)
            flight['flown'] += 1
            if result != 'ok':
                say(f'flight {flight["flown"]} to {header}: {result} {frames}', True)
                return None
            roamers = read_roamers(d, sym)
            for slot in slots:
                old, new = before[slot][0], roamers[slot][0]
                if not old or not new:
                    continue  # caught
                flight['moves'] += 1
                if new not in route_ids or route_ids[roamers[slot][1]] != new or new == old or new == left:
                    say(f'flight {flight["flown"]} to {where(header_id)} from {where(left)}: {name(slot)} went from '
                        f'{where(old)} to {where(new)} (route {roamers[slot][1]})', True)
            flight['left'] = header_id
            return header_id, terrain, roamers

        # Flying, and meeting them.
        met = {slot: 0 for slot in slots}
        surveys = 0
        while flight['flown'] < FLIGHTS_MAX and min(met.values()) < MEET_TIMES:
            flown = fly()
            if not flown:
                break
            header_id, terrain, roamers = flown
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
        say(f'flying: {flight["flown"]} flights, {flight["moves"]} moves; {surveys} surveys with roamers on the map; '
            f'the surveys each was met in: ' + ', '.join(f'{name(s)} {met[s]}' for s in slots))
        for slot in slots:
            if met[slot] < MEET_TIMES:
                say(f'meeting: {name(slot)} met in {met[slot]} surveys in {flight["flown"]} flights', True)

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
        # Battles: each roamer battled once, for real, where it flees.
        variables = var_ids()
        watch = sym['gSovereignTestWatch']
        for i, slot in enumerate(slots):  # struct SovereignTestWatch: var, value
            mem.write_short(watch + 4 * i, variables[f'VAR_ROAMING_{names[slot][len("ROAMING_SLOT_"):]}_STATE'])

        def state_of(slot):
            at = watch + 4 * slots.index(slot) + 2
            return struct.unpack('<H', bytes(mem.unsigned[at:at + 2]))[0]

        def start_battle(wanted, limit):
            """Fly on until one of the wanted roamers is on the map, and battle the first roamer the survey meets
            there. Returns (its slot, the map's header ID, the roamers before), or None after limit flights."""
            while flight['flown'] < limit:
                flown = fly()
                if not flown:
                    return None
                header_id, terrain, roamers = flown
                if not any(roamers[slot][0] == header_id for slot in wanted):
                    continue
                mem.write_byte(sym['gSovereignTestSurveyRoamers'], SURVEY_ROAMERS_BATTLE)
                count = run_survey(d, survey, terrain_index.index(terrain))
                mem.write_byte(sym['gSovereignTestSurveyRoamers'], 0)
                at = survey + SURVEY['mons'] + (count - 1) * MON_SIZE
                last = struct.unpack('<IHBB', bytes(mem.unsigned[at:at + MON_SIZE])) if count > 0 else None
                here = {(roamers[s][3], roamers[s][2], roamers[s][5]): s for s in slots if roamers[s][0] == header_id}
                slot = here.get((last[1], last[3], last[0])) if last else None
                if slot is not None:  # else no roamer was met in the survey's encounters, so no battle
                    return slot, header_id, roamers
            return None

        battled = {}
        limit = flight['flown'] + FLIGHTS_MAX
        while len(battled) < len(slots):
            started = start_battle([s for s in slots if s not in battled], limit)
            if not started:
                break
            slot, header_id, roamers = started
            result, frames = play_out(d, sym, FRAME_LIMIT, header_id, press_a=False)
            after, state = read_roamers(d, sym), state_of(slot)
            stayed = [name(s) for s in slots if after[s][0] == header_id]
            fled = after[slot][0] != 0
            battled[slot] = 'fled' if fled else 'knocked out'
            if fled:
                ok = after[slot][4] == roamers[slot][4] and state == ROAMER_STATE_ROAMING
            else:
                ok = not after[slot][4] and state == ROAMER_STATE_DEFEATED
            if result != 'ok' or not ok or stayed:
                d.screenshot().save(os.path.join(out, f'battle_{name(slot)}.png'))
                say(f'battle with {name(slot)} on {where(header_id)}: {result} after {frames} frames; then on '
                    f'{where(after[slot][0]) if after[slot][0] else "no map (not roaming)"}, HP {roamers[slot][4]} '
                    f'to {after[slot][4]}, state {state}' + (f'; still here: {stayed}' if stayed else '') +
                    f' (screenshot: battle_{name(slot)}.png)', True)
        say(f'battles: {len(battled)} of {len(slots)} roamers battled: ' +
            ', '.join(f'{name(s)} {battled[s]}' for s in slots if s in battled), len(battled) < len(slots))

        # Catching: a roamer still roaming, caught with a Master Ball from the battle's bag.
        mem.write_short(sym['gSovereignTestBagItem'], ITEM_MASTER_BALL)  # the next flight puts it in the bag
        roaming = [s for s in slots if read_roamers(d, sym)[s][0]]
        mem.write_short(sym['gSovereignTestMessageLog'], 0)
        started = start_battle(roaming, flight['flown'] + FLIGHTS_MAX) if roaming else None
        if not started:
            say(f'catching: no roamer still roaming met in {FLIGHTS_MAX} flights', True)
        else:
            slot, header_id, roamers = started
            if wait_for_prompt(d, sym, charmap()) is None:
                say(f'catching: no "What will ... do?" in {BATTLE_INTRO_FRAMES} frames', True)
            for x, y, frames in CATCH_TAPS:
                d.touch(x, y, frames=frames, after=150)
            free = 0
            for touches in range(CATCH_TOUCHES):
                before = u32(d, sym['gSovereignTestIdleFrames'])
                d.touch(*NICKNAME_NO, frames=10, after=30)
                # A busy outdoor map runs the field every other frame (talk_to_objects.start_warp).
                free = free + 1 if u32(d, sym['gSovereignTestIdleFrames']) - before >= 10 else 0
                if free >= 2:
                    break
            after, state = read_roamers(d, sym), state_of(slot)
            stayed = [name(s) for s in slots if after[s][0] == header_id]
            ok = free >= 2 and not after[slot][0] and state == ROAMER_STATE_CAPTURED and not stayed
            if not ok:
                d.screenshot().save(os.path.join(out, f'catch_{name(slot)}.png'))
            say(f'catching: {name(slot)} on {where(header_id)}: ' + (
                'caught, no longer roaming, state captured' if ok else
                f'BAD: then on {where(after[slot][0]) if after[slot][0] else "no map (not roaming)"}, state {state}' +
                (f'; still here: {stayed}' if stayed else '') + ('' if free >= 2 else '; the battle never ended') +
                f' (screenshot: catch_{name(slot)}.png)'), not ok)

        # The Pokétch's Marking Map: the roamers still roaming, each at its route's place.
        town, (x, z), steps = MARKING_MAP
        mem.write_byte(sym['gSovereignTestPoketchApp'], poketch_app('POKETCH_APPID_MARKINGMAP') + 1)
        result, frames = warp(d, sym, ids.index(town), x, z, 0)
        if result != 'ok':
            say(f'marking map: the flight to {town} failed: {result} {frames}', True)
        else:
            walked = 0
            for key in ['RIGHT'] * steps + ['LEFT'] * steps:
                before = d.pos()
                d.press(key, frames=16, after=8)
                play_out(d, sym, FRAME_LIMIT, ids.index(town), press_a=False)  # the Repel running out: A uses another
                walked += d.pos() != before
            if walked < 2 * steps:
                say(f'marking map: walked only {walked} of {2 * steps} steps', True)
            d.run(60)
            d.screenshot().save(os.path.join(out, 'marking_map.png'))
            roamers = read_roamers(d, sym)
            roaming = [s for s in slots if roamers[s][0]]
            places = marking_map_places()
            want = {}
            for slot in roaming:
                place = places.get(roamers[slot][0])
                if not place:
                    say(f'marking map: {name(slot)} roams on {where(roamers[slot][0])}, which has no place on it', True)
                    continue
                want.setdefault((place[0] - MAP_ICON_CORNER, place[1] - MAP_ICON_CORNER), []).append(slot)
            shown = sub_screen_sprites(d)
            tiles = {tile for sx, sy, tile in shown if (sx, sy) in want}
            icons = [(sx, sy) for sx, sy, tile in shown if tile in tiles]
            missing = [name(s) for spot, at in want.items() for s in at[icons.count(spot):]]
            extra = len(icons) - sum(len(at) for at in want.values()) + len(missing)
            ok = not missing and not extra
            say(f'marking map: {len(roaming)} roaming, {len(icons)} roamer icons on the Pokétch'
                + ('' if ok else f'; BAD: missing {missing}, {extra} more')
                + ' (screenshot: marking_map.png)', not ok)

        say(f'{bad} problems')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
