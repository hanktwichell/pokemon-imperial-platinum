#!/usr/bin/env python3
"""Check the rare wild encounters (data/sovereign_rare_wild.yaml: the Ultra Beasts and Carbink) through the real
encounter code, in the test build.

A map's rare entries share one roll from 0 to 99 (SovereignRareWild_TryFillEncounterTable, wild_encounters.c), taken in
the order of the generated table (decomp/include/data/sovereign_rare_wild.h), each entry its rate wide. For each map
and terrain an entry lists, this warps onto the map and runs wild_forms.py's survey there (SAMPLES encounters, no
battle) with the roll fixed at the start of that entry's share (gSovereignTestRareWildRoll), twice:
- **gate met:** every Chronicle open (as talk_to_objects.py --chronicles) and every species counted as caught
  (gSovereignTestCaughtAllBut). Every Pokémon made must be the entry's species, at its level.
- **gate not met:** the new game's save (no Chronicle open, nothing caught). None may be.

Needs what wild_forms.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/rare_wild.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [SPECIES ...]
SPECIES (e.g. SPECIES_GUZZLORD) limits the run to those entries. Each survey is a line in OUT_DIR/results.txt.
"""
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import talk_to_objects  # noqa: E402
from talk_to_objects import DECOMP, SYMBOLS, arrive, parse_args, symbols, var_ids  # noqa: E402
from wild_forms import MON_SIZE, SURVEY, TERRAINS, cases, events_of, run_survey, species_names  # noqa: E402

ENTRY = re.compile(r'\{ (MAP_HEADER_\w+), (SPECIES_\w+), (SPECIES_\w+), (\d+), SOVEREIGN_RARE_WILD_(\w+), (\d+), '
                   r'(\d+), (\d+) \}')
SURVEY_TERRAIN = {'LAND': [t for t, _ in TERRAINS].index('land'), 'SURF': [t for t, _ in TERRAINS].index('surf')}


def entries():
    """[(map header, species, terrain, its roll offset, min level, max level)] in the generated table's order, the
    offset counting the entries before it on the same map and terrain (all of them, as every gate is met)."""
    text = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_rare_wild.h'), encoding='utf-8').read()
    out, taken = [], {}
    for header, species, _, _, terrain, rate, low, high in ENTRY.findall(text):
        offset = taken.get((header, terrain), 0)
        taken[(header, terrain)] = offset + int(rate)
        out.append((header, species, terrain, offset, int(low), int(high)))
    return out


def main():
    from drive import Driver

    rom, state, out, only, part, parts = parse_args(sys.argv[1:])
    sym = symbols(SYMBOLS + ('gSovereignTestWildSurvey', 'gSovereignTestRareWildRoll'))
    variables = var_ids()
    names = species_names()
    places = {header: (header_id, places[0][1:]) for header, header_id, _, places, _ in cases()}
    chosen = [(i, e) for i, e in enumerate(entries()) if (not only or e[1] in only) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory
    survey = sym['gSovereignTestWildSurvey']

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        def say(line):
            print(line, file=f, flush=True)
            print(line, flush=True)

        for index, (header, species, terrain, offset, low, high) in chosen:
            if header not in places:
                bad += 1
                say(f'{index} {header} {species}: NOPLACE (no tile with wild encounters on it)')
                continue
            header_id, (x, z) = places[header]
            for met in (True, False):
                talk_to_objects.CHRONICLES = met

                def setup(met=met, offset=offset):
                    mem.write_byte(sym['gSovereignTestRareWildRoll'], offset + 1)
                    if met:
                        mem.write_short(sym['gSovereignTestCaughtAllBut'], 0xffff)  # no species: all caught

                result, frames = arrive(d, sym, state, variables, events_of(header), header_id, (x, z), x, z, 1,
                                        setup)
                gate = 'gate met' if met else 'gate not met'
                if result != 'ok':
                    bad += 1
                    say(f'{index} {header} {species} {gate}: {result} {frames}')
                    continue
                count = run_survey(d, survey, SURVEY_TERRAIN[terrain])
                made = []
                for i in range(max(count, 0)):
                    at = survey + SURVEY['mons'] + i * MON_SIZE
                    _, kind, _, level = struct.unpack('<IHBB', bytes(mem.unsigned[at:at + MON_SIZE]))
                    made.append((names[kind], level))
                rare = [m for m in made if m[0] == species]
                if met:
                    wrong = [m for m in made if m[0] != species or not low <= m[1] <= high]
                    ok = count > 0 and not wrong
                    detail = f'{len(rare)} of {count} {species[8:].lower()}' + (
                        f'; WRONG {sorted(set(wrong))[:4]}' if wrong else '')
                else:
                    ok = count > 0 and not rare
                    detail = f'{len(rare)} of {count} {species[8:].lower()}'
                if not ok:
                    bad += 1
                say(f'{index} {header} ({x}, {z}) {terrain.lower()} {gate}: {"ok" if ok else "BAD"}, {detail}' +
                    (' (the survey never ended)' if count < 0 else ''))
        say(f'{len(chosen)} entries; {bad} problems')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
