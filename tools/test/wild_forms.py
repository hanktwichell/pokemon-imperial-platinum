#!/usr/bin/env python3
"""Check the forms of the wild Pokémon the real encounter code makes, on every map with wild encounters.

For each map header with wild encounters, in the test build, this warps onto the map and runs a survey for each of its
terrains (gSovereignTestWildSurvey, include/sovereign_test.h): land (grass, caves), surf, and the three rods. A survey
runs the map's encounter SAMPLES times through the game's own code (WildEncounters_TryWildEncounter or
WildEncounters_TryFishingEncounter, src/overlay006/wild_encounters.c), with no encounter roll and no battle, and
records each Pokémon made: its species, form, level and personality. In the Regional Forms Park (Pal Park's grounds),
it surveys each quadrant, as each is a zone with its own regional forms.

Each Pokémon's form must be what the map and the Pokémon give, by the rules below (first match):
- **Regional Forms Park:** a Pokémon of the zone's list for that terrain (data/regional_forms_park.yaml), in its
  form. A quadrant with no list for a terrain has the park's usual table, and the rules below.
- **Shellos and Gastrodon:** East Sea where the map's encounter file says so (rate_form0 and rate_form1), else West.
- **Unown:** one of the forms of the map's Unown table (unown_table, WildEncounters_UnownTables).
- **Deerling and Sawsbuck:** the season of the month. On their maps each terrain is surveyed in four months, January
  to April (gSovereignTestClock), so all four seasons are seen.
- **Everything else:** the form its personality gives (Pokemon_SovereignPersonalityForm, as battle_evolutions.py
  mirrors it: Minior's core, Vivillon's pattern, a female Meowstic...), or the base form. So no Totem form, regional
  form or other form turns up in the wild outside the park.

Needs what talk_to_objects.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/wild_forms.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [MAP_HEADER ...]
MAP_HEADER (e.g. MAP_HEADER_ROUTE_205_SOUTH) limits the list to those headers. Each Pokémon that breaks a rule is a
line in OUT_DIR/results.txt, and each survey's count.
"""
import collections
import json
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_evolutions import Forms  # noqa: E402
from check_object_tiles import Maps, walkable  # noqa: E402
from talk_to_objects import (DECOMP, SYMBOLS, arrive, event_maps, header_names, parse_args, symbols, u32,  # noqa: E402
                             var_ids, way_in_to)

SAMPLES = 48
# enum SovereignTestSurveyTerrain, with the encounter file's rate for it.
TERRAINS = (('land', 'land_rate'), ('surf', 'surf_rate'), ('old rod', 'old_rod_rate'), ('good rod', 'good_rod_rate'),
            ('super rod', 'super_rod_rate'))
SURVEY = {'wanted': 0, 'terrain': 1, 'count': 2, 'active': 3, 'mons': 4}  # struct SovereignTestWildSurvey
SURVEY_FRAMES = 600  # a survey of SAMPLES encounters takes about 10
MON_SIZE = 8  # struct SovereignTestWildMon: personality, species, form, level
CLOCK_MONTH = 1  # offsetof(struct SovereignTestClock, month)
PARK = 'MAP_HEADER_PAL_PARK'
SEASONAL = ('SPECIES_DEERLING', 'SPECIES_SAWSBUCK')


def species_names():
    return [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'species.txt')) if line.strip()]


def unown_tables():
    """WildEncounters_UnownTables: [the forms of each table]."""
    source = open(os.path.join(DECOMP, 'src', 'overlay006', 'wild_encounters.c'), encoding='utf-8').read()
    forms = {name: int(value) for name, value in
             re.findall(r'#define (UNOWN_FORM_\w+)\s+(\d+)',
                        open(os.path.join(DECOMP, 'include', 'constants', 'forms.h'), encoding='utf-8').read())}
    arrays = {name: [forms[f] for f in re.findall(r'UNOWN_FORM_\w+', body)]
              for name, body in re.findall(r'static const u8 (Unown\w+)\[\] = \{(.*?)\};', source, re.S)}
    table = re.search(r'WildEncounters_UnownTables\[\] = \{(.*?)\};', source, re.S).group(1)
    return [arrays[name] for name in re.findall(r'\{ 0x[0-9a-fA-F]+, (Unown\w+) \}', table)]


def park_zones():
    """sRegionalFormsParkZones: [(name, {terrain: {(species, form)}})], by quadrant (x < 32 or not, then z)."""
    text = open(os.path.join(DECOMP, 'include', 'data', 'regional_forms_park.h'), encoding='utf-8').read()
    lists = {name: {(s, int(f)) for s, f in re.findall(r'\{ (SPECIES_\w+), (\d+),', body)}
             for name, body in re.findall(r'RegionalFormsParkEntry (\w+)\[\] = \{(.*?)\};', text, re.S)}
    zones = []
    table = text[text.index('sRegionalFormsParkZones'):]
    for grass, water, name in re.findall(r'\{ (\w+), [^,]+, (\w+), [^}]+\}, // (\w+)', table[:table.index('};')]):
        found = lists.get(grass, set()), lists.get(water, set())
        zones.append((name, {'land': found[0], 'surf': found[1], 'old rod': found[1], 'good rod': found[1],
                             'super rod': found[1]}))
    return zones


def quadrant_tiles(maps, matrix, rows):
    """A walkable tile in each quadrant of a one-map park, in zone order."""
    width, height = len(rows[0]) * 32, len(rows) * 32
    out = []
    for z0, z1 in ((0, 32), (32, height)):
        for x0, x1 in ((0, 32), (32, width)):
            centre = ((x0 + x1) // 2, (z0 + z1) // 2)
            tiles = [(x, z) for x in range(x0, x1) for z in range(z0, z1) if walkable(maps.tile(matrix, x, z))]
            out.append(min(tiles, key=lambda p: abs(p[0] - centre[0]) + abs(p[1] - centre[1])))
    return out


def tile_on(maps, matrix, grid, header):
    """A walkable tile on the header's own part of an outdoor matrix (one with no warp of its own), nearest the middle
    of its first 32x32 map, or None."""
    for row, names in enumerate(grid.get('headers', [])):
        for col, name in enumerate(names):
            if name == header:
                centre = (col * 32 + 16, row * 32 + 16)
                tiles = [(x, z) for x in range(col * 32, col * 32 + 32) for z in range(row * 32, row * 32 + 32)
                         if walkable(maps.tile(matrix, x, z))]
                if tiles:
                    return min(tiles, key=lambda p: abs(p[0] - centre[0]) + abs(p[1] - centre[1]))
    return None


def cases():
    """[(header, header ID, its encounter file's JSON, [(zone or None, x, z)], [terrains with encounters])]."""
    maps = Maps(DECOMP)
    ids = header_names()
    headers = open(os.path.join(DECOMP, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
    encounters = {}
    for name, block in re.findall(r'\[(MAP_HEADER_\w+)\] = \{(.*?)\n    \},', headers, re.S):
        archive = dict(re.findall(r'\.(\w+) = (\w+)', block)).get('wildEncountersArchiveID')
        if archive and archive.startswith('encounters_'):
            encounters[name] = archive
    zones = park_zones()
    out = []
    for events, headers_of, cur, grid in event_maps():
        matrix = headers_of[0][1]
        taken = {(o['x'], o['z']) for o in cur.get('object_events', [])}
        for header, _ in headers_of:
            if header not in encounters:
                continue
            enc = json.load(open(os.path.join(DECOMP, 'res', 'field', 'encounters', encounters[header] + '.json'),
                                 encoding='utf-8'))
            terrains = [t for t, rate in TERRAINS if enc.get(rate)]
            if not terrains:
                continue
            if header == PARK:
                places = [(zone, x, z) for zone, (x, z) in zip(zones, quadrant_tiles(maps, matrix, grid['maps']))]
            else:
                tile = way_in_to(maps, matrix, grid, cur, header, taken, None) or tile_on(maps, matrix, grid, header)
                if tile is None:
                    continue
                places = [(None,) + tile]
            out.append((header, ids.index(header), enc, places, terrains))
    return out


def run_survey(d, survey, terrain):
    """Run a survey of this terrain (enum SovereignTestSurveyTerrain) and return the Pokémon it made, or -1 if it never
    ended. It takes the game several frames (each encounter sets up a battle), so it waits for it to end."""
    mem = d.emu.memory
    mem.write_byte(survey + SURVEY['terrain'], terrain)
    mem.write_byte(survey + SURVEY['wanted'], SAMPLES)
    for attempt in range(10):  # a busy map can miss the frame SELECT goes down on (talk_to_objects.warp)
        d.press('SELECT+L+R', frames=4, after=0)
        d.run(10 + attempt % 2)
        if mem.unsigned[survey + SURVEY['wanted']] == 0 or mem.unsigned[survey + SURVEY['active']]:
            break
    for _ in range(SURVEY_FRAMES // 5):
        if mem.unsigned[survey + SURVEY['wanted']] == 0 and not mem.unsigned[survey + SURVEY['active']]:
            return mem.unsigned[survey + SURVEY['count']]
        d.run(5)
    return -1


def expected(forms, unown, species, p, enc, zone, terrain, month):
    """The forms the rules allow this Pokémon."""
    if zone and zone[1][terrain]:
        return {f for s, f in zone[1][terrain] if s == species}
    if species == 'SPECIES_SHELLOS':
        return {1 if enc.get('rate_form0') else 0}
    if species == 'SPECIES_GASTRODON':
        return {1 if enc.get('rate_form1') else 0}
    if species == 'SPECIES_UNOWN':
        return set(unown[max(enc.get('unown_table', 0) - 1, 0)])
    if species in SEASONAL:
        return {(month - 1) % 4}
    return {max(forms.personality_form(species, p), 0)}


def main():
    from drive import Driver

    rom, state, out, only, part, parts = parse_args(sys.argv[1:])
    sym = symbols(SYMBOLS + ('gSovereignTestWildSurvey',))
    variables = var_ids()
    names = species_names()
    forms = Forms()
    unown = unown_tables()
    chosen = [(i, c) for i, c in enumerate(cases()) if (not only or c[0] in only) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory
    survey = sym['gSovereignTestWildSurvey']

    bad, made, seen = 0, 0, collections.Counter()
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        def say(line):
            print(line, file=f, flush=True)
            print(line, flush=True)

        for index, (header, header_id, enc, places, terrains) in chosen:
            # Deerling and Sawsbuck take the season of the month: where they live, each terrain is surveyed in all four
            # (January to April: spring, summer, autumn, winter).
            months = (1, 2, 3, 4) if any(s in json.dumps(enc) for s in SEASONAL) else (1,)
            for zone, x, z in places:
                where = f'{header} ({x}, {z})' + (f' {zone[0]}' if zone else '')
                result, frames = arrive(d, sym, state, variables, events_of(header), header_id, (x, z), x, z, 1)
                if result != 'ok':
                    bad += 1
                    say(f'{index} {where}: {result} {frames}')
                    continue
                for terrain, month in [(t, m) for t in terrains for m in months]:
                    mem.write_byte(sym['gSovereignTestClock'] + CLOCK_MONTH, month)
                    d.run(30)  # the game reads the clock every 11 frames (UpdateRTC)
                    count = run_survey(d, survey, [t for t, _ in TERRAINS].index(terrain))
                    wrong = []
                    for i in range(count):
                        at = survey + SURVEY['mons'] + i * MON_SIZE
                        p, species, form, level = struct.unpack('<IHBB', bytes(mem.unsigned[at:at + MON_SIZE]))
                        name = names[species]
                        seen[(name, form)] += 1
                        allowed = expected(forms, unown, name, p, enc, zone, terrain, month)
                        if form not in allowed:
                            wrong.append(f'{name} form {form} (personality {p:08x}, Lv. {level}; want '
                                         f'{" or ".join(map(str, sorted(allowed))) or "none: not in the zone"})')
                    made += max(count, 0)
                    if wrong or count <= 0:
                        bad += 1
                    when = f' month {month}' if len(months) > 1 else ''
                    say(f'{index} {where} {terrain}{when}: {count} made' + (', NONE' if count == 0 else '') +
                        (', STUCK (the survey never ended)' if count < 0 else '') +
                        ''.join(f'\n    WRONG {w}' for w in wrong))
        other = sorted((name, form) for name, form in seen if form)
        say('Forms other than the base form: ' + ', '.join(f'{name[8:].lower()} {form} ({seen[name, form]})'
                                                           for name, form in other))
        say(f'{made} Pokémon made, {len(seen)} species and forms; {bad} problems')
    sys.exit(1 if bad else 0)


_EVENTS = {}


def events_of(header):
    """The events file of a header (talk_to_objects.arrive uses it for SCENES_SEEN)."""
    if not _EVENTS:
        text = open(os.path.join(DECOMP, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
        for name, block in re.findall(r'\[(MAP_HEADER_\w+)\] = \{(.*?)\n    \},', text, re.S):
            _EVENTS[name] = dict(re.findall(r'\.(\w+) = (\w+)', block)).get('eventsArchiveID')
    return _EVENTS[header]


if __name__ == '__main__':
    main()
