#!/usr/bin/env python3
"""Screenshot the Pokédex's Area page (the area map) for each species given.

For each species, from a save state in the field (new_game.sh's bedroom), the save's Pokédex is given to the player
with the National Dex and that species as the only one seen and caught. The harness finds the Pokédex as
Pokedex_IsObtained's argument when the start menu first asks, and writes it before that call reads it. Then it opens
the Pokédex from the start menu, picks the species (the list's cursor starts on the only one seen), and turns to the
Area page.

Needs the test build (tools/test/build_test_rom.sh) and its symbol map (decomp/build_test/main.nef.xMAP), a save
state made with that ROM, py-desmume and Pillow. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/pokedex_area.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR SPECIES...
SPECIES is a name from decomp/generated/species.txt, with or without SPECIES_ (e.g. RAICHU). Writes
OUT_DIR/<species>.png: the Area page (top screen) as the game draws it. A species with no wild spot reads
"Area Unknown".
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_trainers import DECOMP  # noqa: E402

MAGIC = 0xBEEFCAFE  # struct Pokedex's magic (include/pokedex.h)
TO_AREA = ['X', 'wait:60', 'A', 'wait:200', 'A', 'wait:150', 'RIGHT', 'wait:120', 'A', 'wait:150']


def pokedex_layout(names):
    """Offsets in struct Pokedex (include/pokedex.h): the caught and seen bit arrays, their size, and pokedexObtained
    (nationalDexObtained follows it)."""
    dex_count = names.index('SPECIES_BAD_EGG') - 2  # NATIONAL_DEX_COUNT
    words = (dex_count - 1) // 32 + 1  # DEX_SIZE_U32
    caught, seen = 4, 4 + 4 * words
    # after the bits: recordedGenders[2][words], spindaForm, four u8 form counts, unownFormsSeen[28], canDetectForms,
    # canDetectLanguages
    obtained = 4 + 16 * words + 4 + 4 + 28 + 2
    return caught, seen, 4 * words, obtained


def main():
    from drive import Driver

    if len(sys.argv) < 5:
        sys.exit(__doc__)
    rom, state, out = sys.argv[1:4]
    names = [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'species.txt')) if line.strip()]
    wanted = [s if s.startswith('SPECIES_') else 'SPECIES_' + s for s in (a.upper() for a in sys.argv[4:])]
    for name in wanted:
        if name not in names:
            sys.exit(f'{name} is not in species.txt')
    xmap = open(os.path.join(DECOMP, 'build_test', 'main.nef.xMAP'), encoding='utf-8', errors='replace').read()
    is_obtained = int(re.search(r'^\s*([0-9A-F]{8}) [0-9A-F]{8} \.text\s+Pokedex_IsObtained\b', xmap, re.M).group(1),
                      16)
    caught, seen, size, obtained = pokedex_layout(names)
    os.makedirs(out, exist_ok=True)

    d = Driver(rom)
    mem = d.emu.memory
    current = {}

    def give_pokedex(addr, size_):
        if current.get('done'):
            return True
        dex = mem.register_arm9.r0
        if int.from_bytes(bytes(mem.unsigned[dex:dex + 4]), 'little') != MAGIC:
            sys.exit(f'Pokedex_IsObtained got {dex:#x}, which is no Pokédex')
        mem.write_byte(dex + obtained, 1)
        mem.write_byte(dex + obtained + 1, 1)
        bit = current['species'] - 1
        for base in (caught, seen):
            for i in range(size):
                mem.write_byte(dex + base + i, 0)
            mem.write_byte(dex + base + (bit >> 3), 1 << (bit & 7))
        current['done'] = True
        return True

    mem.register_exec(is_obtained, give_pokedex)
    for name in wanted:
        d.load_state(state)
        current.clear()
        current['species'] = names.index(name)
        for action in TO_AREA:
            d.do(action, out)
        if not current.get('done'):
            sys.exit('the start menu never asked whether the Pokédex is obtained: is the state in the field?')
        shot = name.removeprefix('SPECIES_').lower()
        d.do(f'shot:{shot}', out)
        print(f'{name}: {os.path.join(out, shot)}.png')


if __name__ == '__main__':
    main()
