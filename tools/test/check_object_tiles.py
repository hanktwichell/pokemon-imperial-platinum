#!/usr/bin/env python3
"""Check the tiles of every map object Sovereign added or moved: can the player reach it, and does it block anything?

An object is "added or moved" when vanilla Platinum (the decomp's import commit, VANILLA_REF) has no object with the
same graphics on the same tile of that map. For each one this reports:
- **Overlaps:** another object, a sign or hidden item (bg event), a warp or a coord trigger on the same tile.
- **Unreachable:** the player can't stand next to it (or face it across a counter).
- **Cuts off:** while it stands there, a warp, sign, hidden item or other object nearby can no longer be reached.

Reachability is a walk over the map's tile collision (decomp/res/field/maps/data, bit 15 of each tile's attributes)
that follows the engine's movement rules: Surf, Waterfall and Rock Climb are allowed; jump ledges and bike ramps go
one way; on an elevated bike bridge the player can't turn off it (src/player_move.c). Outdoor maps are searched in a
window of WINDOW tiles around the object, with the window's edge counted as reachable. Objects that a script moves
into place (placed off the map at 999 or similar) are skipped.

Overlaps and blocks that are on purpose (sequenced by flags, or story gates) are listed in KNOWN with the reason.
Anything else is a problem, and the check exits 1.

Needs the git history (it reads vanilla's events with `git show`). Run from the repo root:
    python3 tools/test/check_object_tiles.py decomp
"""
import collections
import json
import os
import re
import struct
import subprocess
import sys

VANILLA_REF = '22fddfd4'  # "Add pret/pokeplatinum decompilation as decomp/"
WINDOW = 40
COLLISION = 0x8000
PASSABLE = {0x13, 0x4b, 0x4c}  # Waterfall, Rock Climb N-S and E-W: collision tiles the player can still cross
JUMPS = {0x38: ((1, 0), 1), 0x39: ((-1, 0), 1), 0x3a: ((0, -1), 1), 0x3b: ((0, 1), 1),
         0x5a: ((0, -1), 2), 0x5b: ((0, 1), 2), 0x5c: ((-1, 0), 2), 0x5d: ((1, 0), 2)}
RAMPS = {0xd7: (1, 0), 0xd8: (-1, 0)}  # bike ramps launch the bike 1 tile (slow gear) or 3 (fast gear)
BRIDGE_START = 0x70
BRIDGE = set(range(0x71, 0x7e))
BIKE_BRIDGE_NS = {0x76, 0x77, 0x78, 0x79}
BIKE_BRIDGE_EW = {0x7a, 0x7b, 0x7c, 0x7d}
TABLE = 0x80  # TILE_BEHAVIOR_TABLE: counters the player talks across
DIRS = ((1, 0), (-1, 0), (0, 1), (0, -1))

# (events, object id): why its overlap or block is fine.
KNOWN = {
    ('events_canalave_library_2f', 'LOCALID_SOVEREIGN_ARCHIVIST'): 'stands before one of the flavour bookshelves',
    ('events_fullmoon_island_forest', 'LOCALID_SOVEREIGN_LATI_ROCK'):
        'shows only after Cresselia is gone and the Lunar Wing is taken',
    ('events_mt_coronet_b1f', 'LOCALID_ITEM_LIGHT_CLAY'): 'an item ball; taking it frees the hidden item behind it',
    ('events_pokemon_league', 'LOCALID_SOVEREIGN_GUARD'): 'guards the League door with its trigger (story gate)',
    ('events_pokemon_mansion', 'LOCALID_SOVEREIGN_GRUNT_TRIO'): 'siege only; the maids on its tile are hidden then',
    ('events_pokemon_mansion', 'LOCALID_SOVEREIGN_GRUNT_EAST'): 'siege only; the maid on its tile is hidden then',
    ('events_pokemon_mansion', 'LOCALID_SOVEREIGN_GRUNT_GARDEN'): 'guards the Trophy Garden door during the siege',
    ('events_route_201', 'LOCALID_SOVEREIGN_MEW_PACHIRISU'): 'turns into Mew: the two never show at once',
    ('events_route_201', 'LOCALID_LEGENDARY_MEW'): 'appears in the Pachirisu\'s place',
    ('events_route_224', 'LOCALID_SOVEREIGN_COUNTERPART'): 'blocks the tablet until beaten, as in Renegade',
    ('events_victory_road_1f', 'LOCALID_COLLECTOR'):
        'Renegade\'s gate to the League: his trigger covers the tiles beside him until the Route 224 counterpart is '
        'beaten',
    ('events_wayward_cave_1f', 'LOCALID_MIRA'):
        'Renegade\'s gate at the hidden entrance: she battles the player, then follows until her quest ends',
}


class Maps:
    def __init__(self, decomp):
        self.decomp = decomp
        self.names = [line.split('=')[0].strip()
                      for line in open(os.path.join(decomp, 'generated', 'maps.txt'), encoding='utf-8') if line.strip()]
        self.land, self.matrices = {}, {}

    def matrix(self, name):
        if name not in self.matrices:
            path = os.path.join(self.decomp, 'res', 'field', 'matrices', name + '.json')
            self.matrices[name] = json.load(open(path, encoding='utf-8'))['maps']
        return self.matrices[name]

    def tile(self, matrix, x, z):
        """The tile's 16-bit attributes, or None outside the map."""
        if x < 0 or z < 0:
            return None
        grid = self.matrix(matrix)
        row, col = z // 32, x // 32
        if row >= len(grid) or col >= len(grid[row]) or grid[row][col] == 'MAP_NONE':
            return None
        name = grid[row][col]
        if name not in self.land:
            path = os.path.join(self.decomp, 'res', 'field', 'maps', 'data',
                                f'map_data_{self.names.index(name):03d}.bin')
            data = open(path, 'rb').read()
            self.land[name] = struct.unpack('<1024H', data[16:16 + 2048])
        return self.land[name][(z % 32) * 32 + x % 32]


def walkable(t):
    return t is not None and (not t & COLLISION or (t & 0xff) in PASSABLE)


def can_turn(maps, matrix, x, z, elevated, d):
    b = maps.tile(matrix, x, z) & 0xff
    return not (elevated and ((b in BIKE_BRIDGE_NS and d[0]) or (b in BIKE_BRIDGE_EW and d[1])))


def explore(maps, matrix, box, edge, warps, blocked):
    """Every (x, z, on_elevated_bridge) the player can reach inside box, starting from edge tiles and warps."""
    x0, z0, x1, z1 = box
    seen, queue = set(), collections.deque()

    def add(x, z, elevated):
        if x0 <= x <= x1 and z0 <= z <= z1 and (x, z) not in blocked and (x, z, elevated) not in seen:
            seen.add((x, z, elevated))
            queue.append((x, z, elevated))

    for x, z in edge:
        t = maps.tile(matrix, x, z)
        if walkable(t):
            add(x, z, (t & 0xff) == BRIDGE_START)
    for x, z in warps:  # the player arrives on a warp even when its tile has collision (doors, stairs)
        if maps.tile(matrix, x, z) is not None:
            add(x, z, False)
    while queue:
        x, z, elevated = queue.popleft()
        for d in DIRS:
            if not can_turn(maps, matrix, x, z, elevated, d):
                continue
            nx, nz = x + d[0], z + d[1]
            t = maps.tile(matrix, nx, nz)
            if t is None:
                continue
            b = t & 0xff
            if b in RAMPS:
                if RAMPS[b] == d:
                    for n in (1, 3):
                        lt = maps.tile(matrix, nx + d[0] * n, nz + d[1] * n)
                        if walkable(lt):
                            add(nx + d[0] * n, nz + d[1] * n, elevated and (lt & 0xff) in BRIDGE)
                continue
            if b in JUMPS:
                jd, n = JUMPS[b]
                if jd != d:
                    continue
                nx, nz = nx + jd[0] * n, nz + jd[1] * n
                t = maps.tile(matrix, nx, nz)
                if t is None:
                    continue
                b = t & 0xff
            if not walkable(t) or (elevated and ((b in BIKE_BRIDGE_NS and d[0]) or (b in BIKE_BRIDGE_EW and d[1]))):
                continue
            add(nx, nz, True if b == BRIDGE_START else (False if elevated and b not in BRIDGE else elevated))
    return seen


def usable(maps, matrix, seen, p):
    """The player can stand on p, face it from a neighbor, or face it across a counter."""
    x, z = p
    if (x, z, False) in seen or (x, z, True) in seen:
        return True
    for d in DIRS:
        nx, nz = x - d[0], z - d[1]
        for elevated in (False, True):
            if (nx, nz, elevated) in seen and can_turn(maps, matrix, nx, nz, elevated, d):
                return True
        t = maps.tile(matrix, nx, nz)
        if t is not None and (t & 0xff) == TABLE:
            if (nx - d[0], nz - d[1], False) in seen:
                return True
    return False


def vanilla_events(path):
    try:
        out = subprocess.run(['git', 'show', f'{VANILLA_REF}:{path}'], capture_output=True, check=True).stdout
    except subprocess.CalledProcessError:
        return {}
    return json.loads(out)


def main():
    decomp = sys.argv[1]
    maps = Maps(decomp)
    if subprocess.run(['git', 'cat-file', '-e', VANILLA_REF], capture_output=True).returncode:
        sys.exit(f'needs the git history: vanilla commit {VANILLA_REF} not found')
    headers = open(os.path.join(decomp, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
    matrix_of = {}
    for block in re.findall(r'\[MAP_HEADER_\w+\] = \{(.*?)\n    \},', headers, re.S):
        fields = dict(re.findall(r'\.(\w+) = (\w+)', block))
        if 'eventsArchiveID' in fields and 'mapMatrixID' in fields:
            matrix_of.setdefault(fields['eventsArchiveID'], fields['mapMatrixID'])
    problems, known, checked = [], [], 0
    for events, matrix in sorted(matrix_of.items()):
        path = os.path.join(decomp, 'res', 'field', 'events', events + '.json')
        if not os.path.exists(path):
            continue
        cur = json.load(open(path, encoding='utf-8'))
        old = {(o['graphics_id'], o['x'], o['z']) for o in vanilla_events(path).get('object_events', [])}
        objs = cur.get('object_events', [])
        warps = [(w['x'], w['z']) for w in cur.get('warp_events', [])]
        targets = [(f'warp {i}', p) for i, p in enumerate(warps)]
        targets += [(f'bg event (script {b["script"]})', (b['x'], b['z'])) for b in cur.get('bg_events', [])]
        targets += [(o['id'], (o['x'], o['z'])) for o in objs]
        grid = maps.matrix(matrix)
        whole_map = len(grid) * len(grid[0]) <= 16  # indoor and small maps: search all of it
        for o in objs:
            x, z = o['x'], o['z']
            if (o['graphics_id'], x, z) in old or maps.tile(matrix, x, z) is None:
                continue
            checked += 1
            notes = []
            for p in objs:
                if p is not o and (p['x'], p['z']) == (x, z):
                    notes.append(f'shares its tile with {p["id"]}')
            for b in cur.get('bg_events', []):
                if (b['x'], b['z']) == (x, z):
                    notes.append(f'stands on a bg event (script {b["script"]})')
            for w in cur.get('warp_events', []):
                if (w['x'], w['z']) == (x, z):
                    notes.append(f'stands on a warp to {w["dest_header_id"]}')
            for c in cur.get('coord_events', []):
                if c['x'] <= x < c['x'] + c.get('width', 1) and c['z'] <= z < c['z'] + c.get('length', 1):
                    notes.append(f'stands in a coord trigger (script {c["script"]})')
            if whole_map:
                box, edge = (0, 0, len(grid[0]) * 32 - 1, len(grid) * 32 - 1), []
            else:
                box = (x - WINDOW, z - WINDOW, x + WINDOW, z + WINDOW)
                edge = [(i, j) for i in range(box[0], box[2] + 1) for j in (box[1], box[3])] + \
                       [(i, j) for j in range(box[1], box[3] + 1) for i in (box[0], box[2])]
            before = explore(maps, matrix, box, edge, warps, set())
            after = explore(maps, matrix, box, edge, warps, {(x, z)})
            if not usable(maps, matrix, after, (x, z)):
                notes.append('the player can\'t reach it')
            lost = [name for name, p in targets
                    if name != o['id'] and box[0] <= p[0] <= box[2] and box[1] <= p[1] <= box[3]
                    and usable(maps, matrix, before, p) and not usable(maps, matrix, after, p)]
            if lost:
                notes.append('cuts off ' + ', '.join(lost))
            if notes:
                line = f'{events} {o["id"]} ({x}, {z}): ' + '; '.join(notes)
                (known if (events, o['id']) in KNOWN else problems).append(line)
    for line in known:
        events, oid = line.split(' ')[:2]
        print(f'known: {line} [{KNOWN[(events, oid)]}]')
    for line in problems:
        print(line)
    if problems:
        print(f'{len(problems)} problem(s)')
        sys.exit(1)
    print(f'ok: {checked} added or moved objects are reachable and block nothing ({len(known)} known cases)')


if __name__ == '__main__':
    main()
