#!/usr/bin/env python3
"""Print an overworld map's tiles to find spots for test warps: G = tall grass, ~ = water, # = blocked, . = walkable.

Overworld maps (map matrix 0) use world coordinates: tile (x, z) of chunk (cx, cz) is (cx*32 + x, cz*32 + z), which is
what Warp and sSovereignTestWarps (decomp/src/script_manager.c) take for outdoor maps.

Usage: python3 tools/test/find_tiles.py MAP_HEADER_ROUTE_202
"""
import json
import os
import struct
import sys

DECOMP = os.path.join(os.path.dirname(__file__), "..", "..", "decomp")
TALL_GRASS, WATER = 0x02, 0x10  # Gen IV tile behaviours (MB_TALL_GRASS, MB_DEEP_WATER)


def main():
    header = sys.argv[1]
    matrix = json.load(open(os.path.join(DECOMP, "res/field/matrices/map_matrix_000.json")))
    for cz, row in enumerate(matrix["headers"]):
        for cx, h in enumerate(row):
            if h != header:
                continue
            map_id = int(matrix["maps"][cz][cx].split("_")[-1])
            data = open(os.path.join(DECOMP, f"res/field/maps/data/map_data_{map_id:03d}.bin"), "rb").read()
            perm = struct.unpack("<1024H", data[16:16 + 2048])
            print(f"{header}: chunk ({cx}, {cz}), map_data_{map_id:03d}, world x {cx * 32}-{cx * 32 + 31}, "
                  f"z {cz * 32}-{cz * 32 + 31}")
            print("     " + "".join(str((cx * 32 + x) // 10 % 10) for x in range(32)))
            print("     " + "".join(str((cx * 32 + x) % 10) for x in range(32)))
            for z in range(32):
                tiles = []
                for x in range(32):
                    p = perm[z * 32 + x]
                    tiles.append("#" if p & 0x8000 else "G" if p & 0xFF == TALL_GRASS
                                 else "~" if p & 0xFF == WATER else ".")
                print(f"{cz * 32 + z:4d} " + "".join(tiles))


if __name__ == "__main__":
    main()
