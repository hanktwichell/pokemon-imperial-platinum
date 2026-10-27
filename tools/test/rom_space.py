#!/usr/bin/env python3
"""How much room the ROM has left, and what the Pokémon cries take.

The cartridge size is in the ROM header (byte 0x14: 128 KB << n) and the part in use at 0x80. Platinum's cries are the
sound archive's WAVE_ARC_PV### wave archives (decomp/res/sound/pl_sound_data.json names them). This prints the free
space, the cries' total and average size, and what the new species' cries would take at that average (decision 6:
the cries for #494-1025 come last, and dropping them all is the fallback if the space runs out).

Usage: python3 tools/test/rom_space.py decomp [ROM]   (ROM defaults to decomp/build/pokeplatinum.us.nds)
"""
import json
import os
import struct
import sys

NEW_SPECIES = 1025 - 493


def wave_archive_sizes(sdat):
    """Each WAVEARC record's file size, by record index."""
    info_off = struct.unpack_from('<I', sdat, 0x18)[0]
    fat_off = struct.unpack_from('<I', sdat, 0x20)[0]
    count = struct.unpack_from('<I', sdat, fat_off + 8)[0]
    sizes = [struct.unpack_from('<I', sdat, fat_off + 12 + 16 * i + 4)[0] for i in range(count)]
    wavearc = info_off + struct.unpack_from('<I', sdat, info_off + 8 + 4 * 3)[0]  # record type 3: WAVEARC
    out = {}
    for i in range(struct.unpack_from('<I', sdat, wavearc)[0]):
        entry = struct.unpack_from('<I', sdat, wavearc + 4 + 4 * i)[0]
        if entry:
            out[i] = sizes[struct.unpack_from('<H', sdat, info_off + entry)[0]]
    return out


def main():
    decomp = sys.argv[1]
    rom_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(decomp, 'build', 'pokeplatinum.us.nds')
    with open(rom_path, 'rb') as f:
        header = f.read(0x200)
    capacity = (128 * 1024) << header[0x14]
    used = struct.unpack_from('<I', header, 0x80)[0]
    free = capacity - used
    print(f'ROM: {used:,} of {capacity:,} bytes in use; {free:,} free ({free / 2**20:.1f} MiB)')

    sdat = open(os.path.join(decomp, 'res', 'prebuilt', 'data', 'sound', 'sound_data.sdat'), 'rb').read()
    names = json.load(open(os.path.join(decomp, 'res', 'sound', 'pl_sound_data.json'), encoding='utf-8'))['wavarcInfo']
    sizes = wave_archive_sizes(sdat)
    cries = [sizes[i] for i, w in enumerate(names) if w.get('name', '').startswith('WAVE_ARC_PV') and i in sizes]
    average = sum(cries) // len(cries)
    need = average * NEW_SPECIES
    print(f'Cries: {len(cries)} wave archives, {sum(cries):,} bytes, {average:,} on average')
    print(f'{NEW_SPECIES} new cries at that average: about {need:,} bytes; {free - need:,} would be left')


if __name__ == '__main__':
    main()
