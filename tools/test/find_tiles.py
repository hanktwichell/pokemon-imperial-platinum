#!/usr/bin/env python3
"""Print a map's tiles to find spots for test warps and new NPCs: G = tall grass, ~ = water, # = blocked,
. = walkable, o = an object event (NPC, item ball...), W = a warp.

Overworld maps (map matrix 0) use world coordinates: tile (x, z) of chunk (cx, cz) is (cx*32 + x, cz*32 + z), which is
what Warp and sSovereignTestWarps (decomp/src/script_manager.c) take for outdoor maps. Indoor maps have a matrix of
their own (include/data/map_headers.h) and use the map's local coordinates, as their events files do.

Usage: python3 tools/test/find_tiles.py MAP_HEADER_ROUTE_202
"""
import json
import os
import re
import struct
import sys

DECOMP = os.path.join(os.path.dirname(__file__), "..", "..", "decomp")
TALL_GRASS, WATER = 0x02, 0x10  # Gen IV tile behaviours (MB_TALL_GRASS, MB_DEEP_WATER)


def load_events(header):
    """Object and warp positions from the map's events file, or nothing if it has none."""
    text = open(os.path.join(DECOMP, "include/data/map_headers.h"), encoding="utf-8").read()
    m = re.search(r"\[%s\] = \{.*?\.eventsArchiveID = (\w+)," % re.escape(header), text, re.S)
    path = os.path.join(DECOMP, "res/field/events", f"{m.group(1)}.json") if m else None
    if not path or not os.path.exists(path):
        return set(), set()
    events = json.load(open(path, encoding="utf-8"))
    return ({(o["x"], o["z"]) for o in events.get("object_events", [])},
            {(w["x"], w["z"]) for w in events.get("warp_events", [])})


def indoor_matrix(header):
    text = open(os.path.join(DECOMP, "include/data/map_headers.h"), encoding="utf-8").read()
    m = re.search(r"\[%s\] = \{.*?\.mapMatrixID = (\w+)," % re.escape(header), text, re.S)
    return m.group(1) if m else None


def print_chunk(header, map_id, x0, z0, objects, warps):
    data = open(os.path.join(DECOMP, f"res/field/maps/data/map_data_{map_id:03d}.bin"), "rb").read()
    perm = struct.unpack("<1024H", data[16:16 + 2048])
    print(f"{header}: map_data_{map_id:03d}, x {x0}-{x0 + 31}, z {z0}-{z0 + 31}")
    print("     " + "".join(str((x0 + x) // 10 % 10) for x in range(32)))
    print("     " + "".join(str((x0 + x) % 10) for x in range(32)))
    for z in range(32):
        tiles = []
        for x in range(32):
            p = perm[z * 32 + x]
            pos = (x0 + x, z0 + z)
            tiles.append("o" if pos in objects else "W" if pos in warps else "#" if p & 0x8000
                         else "G" if p & 0xFF == TALL_GRASS else "~" if p & 0xFF == WATER else ".")
        print(f"{z0 + z:4d} " + "".join(tiles))


def main():
    header = sys.argv[1]
    objects, warps = load_events(header)
    matrix = json.load(open(os.path.join(DECOMP, "res/field/matrices/map_matrix_000.json")))
    found = False
    for cz, row in enumerate(matrix["headers"]):
        for cx, h in enumerate(row):
            if h == header:
                found = True
                print_chunk(header, int(matrix["maps"][cz][cx].split("_")[-1]), cx * 32, cz * 32, objects, warps)

    if not found:  # an indoor map: its own matrix, local coordinates
        name = indoor_matrix(header)
        if name is None:
            sys.exit(f"{header} not found")
        indoor = json.load(open(os.path.join(DECOMP, f"res/field/matrices/{name}.json")))
        for cz, row in enumerate(indoor["maps"]):
            for cx, map_name in enumerate(row):
                print_chunk(header, int(map_name.split("_")[-1]), cx * 32, cz * 32, objects, warps)


if __name__ == "__main__":
    main()
