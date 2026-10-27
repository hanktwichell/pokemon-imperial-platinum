#!/usr/bin/env python3
"""Talk to every map object Sovereign added or moved, in the test build, and check that its script ends.

The objects are check_object_tiles.py's: an object vanilla Platinum doesn't have on that tile with those graphics,
with a script. For each one this finds a tile next to it that the player can reach (or across a counter), warps there
facing it (gSovereignTestWarpTarget, include/sovereign_test.h: the map, the tile and the direction) and presses A.
Then it plays the script out: A pages through text and answers prompts, taps on the touch screen pick moves in a
battle (god mode is on, so a trainer's battle ends at once, as in battle_all_trainers.py), and B now and then backs
out of a menu. It first comes into the map by its way in (the tile a player steps onto from its first warp), and plays
out any scene on entering it the same way, as such a scene expects the player there; then it warps to the object. A
scene that needs the story's own way in (SCENES_SEEN) is marked as seen first. On a warp the inputs wait until a
script has started, so an A press meant for a scene can't talk to the object as the warp ends. The script has ended
when the field is idle again (gSovereignTestIdleFrames). The clock reads noon (HOUR).

Each object gets a result:
- ok: its own script ran and ended (for a trainer, its battle);
- NOSCRIPT: nothing ran when A was pressed, so the object isn't there on a new game (a flag hides it until later in
  the story) or something else stands in the way. A wandering object gets WANDER_TRIES more tries first, as it can
  step off its tile;
- STANDIN: another object answered from its tile, standing in for it while it's hidden (Pokémon Mansion's maids on
  two of Team Galactic's grunts' tiles until the siege, Cresselia on the Lati rock's until she's caught, Route 210's
  Double Team, who walk onto Zamazenta's);
- OTHER and the script that ran instead (gSovereignTestScripts: the first script the field started), twice in a row:
  a trainer who sees the player walks up and battles first, as for a player, and then the test warps back to the
  tile and talks again;
- NOTILE: no reachable tile next to it (check_object_tiles.py reports these too);
- HANG (the game stopped running) or STUCK (still busy at the time limit), with a screenshot. A STUCK can be a menu
  the inputs don't get out of; the screenshot shows which. NOWARP HANG or NOWARP STUCK: the same on the way in, while
  a scene on entering the map plays out;
- HEAP: the script ended, but a heap's block lists are broken (heap_check.py), as after a failed load is freed. The
  game would crash or write over memory later.

The test save is a new game with the test party (src/script_manager.c), so a script follows its early-game branch:
an NPC whose gift waits on badges says so, and that is what runs.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/talk_to_objects.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [--postgame | --chronicles] [--unhide] \\
        [EVENTS ...]
EVENTS (an events file's name, e.g. events_route_201) limits the list to those maps, and --part I/N to every Nth
object from the Ith (from 0; to run N at once, each with its own OUT_DIR). Each result is a line in
OUT_DIR/results.txt.

--postgame gives the player all eight Badges and sets FLAG_GAME_COMPLETED (the Hall of Fame) on the way in, so the
objects that wait for the post-game are there and the scripts take their later branches: gifts that wait on Badges,
the Archivist, the Battle Zone's people. The story's other flags stay as on a new game, so a scene that expects the
story's own way there can still play out oddly; read such a result against the story.

--chronicles goes further into the post-game: as --postgame, with every Chronicle open (VAR_SOVEREIGN_CHRONICLE 5,
the Archivist's last), so the Chronicles' legendaries, stakes and rifts are on their maps.

--unhide clears each object's own hidden_flag on the way in, so an object that a flag hides on this save (until a
story event, a Chronicle or a catch) is there to talk to, and its script runs. For a legendary (LOCALID_LEGENDARY_X),
scripts also count every other species as caught (gSovereignTestCaughtAllBut), as a static waits on others being
caught and on its own not being caught. Most are hidden by a map-local flag instead, which the map's OnTransition
script sets from the story as the map loads: STORY gives what each of those needs (flags and vars, an item in the bag,
Pokémon in the party, the hour). The rest of the story is as before, so this checks that the script runs to its end,
not the story around it. Use it with --chronicles.
"""
import json
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_trainers import (DECOMP, HANG_FRAMES, STEP, SWITCH_FRAMES, TAPS, VBLANK_COUNTER,  # noqa: E402
                                 heap_info, symbols)
from heap_check import heap_problems  # noqa: E402
from check_object_tiles import (DIRS, TABLE, WINDOW, Maps, can_turn, explore, vanilla_events,  # noqa: E402
                                walkable)

FRAME_LIMIT = 20000  # a six-Pokémon trainer battle with its text takes about 8000
START_FRAMES = 90  # a script that hasn't started by then never will
# Scenes on entering a map that need the story's own way in, marked as seen first (gSovereignTestVar): events -> (var,
# the value the scene leaves it at). Every other map's scene plays out on the way in.
SCENES_SEEN = {
    'events_sunyshore_city': ('VAR_SUNYSHORE_CITY_STATE', 1),  # Flint at the gate, as the player comes from Route 222
    'events_stark_mountain_room_1': ('VAR_STARK_MOUNTAIN_ROOM_1_STATE', 1),  # Mars and Jupiter, with Buck along
}
# Scripts that run longer: the Battleground's Battle Marathon is 24 battles in a row.
LONG_SCRIPTS = {('events_battleground', 'LOCALID_SOVEREIGN_MARATHON_GUIDE'): 300000}
WARP = {'header': 0, 'x': 2, 'z': 4, 'dir': 6}  # struct SovereignTestWarpTarget
FACE = {(0, -1): 0, (0, 1): 1, (-1, 0): 2, (1, 0): 3}  # enum FaceDirection: the step from the player to the object
# The hour the clock reads (gSovereignTestClock, which takes the hour + 1): the day, so a result doesn't change with
# the time the test runs at (Route 212's policemen are out only at night).
HOUR = 12
# --postgame (parse_args): all eight Badges and the Hall of Fame on the way in (arrive).
POSTGAME = False
# A wandering object (MOVEMENT_TYPE_WANDER_*) can step off its tile before the test talks to it: it gets this many more
# tries from a fresh warp before it counts as NOSCRIPT.
WANDER_TRIES = 4
# --chronicles (parse_args): --postgame, and every Chronicle open (arrive).
CHRONICLES = False
# --unhide (parse_args): each object's own hidden_flag cleared on the way in (main).
UNHIDE = False
# With --unhide, what puts an object on its map when its map's own scripts set its map-local hide flag from the story
# as the map loads (its OnTransition script): (events, object id) -> [(name, value)]. A name is a flag or var to set
# (at most twelve: gSovereignTestVar[4] to [15]), an item to put in the bag (ITEM_*, at most one), a Pokémon to add to
# the party at that level (SPECIES_*, at most three, after the party is cut to make room) or HOUR (the clock's hour).
# Totems are left out: their trials have test warps of their own (sSovereignTestWarps).
SIEGE = 'VAR_SOVEREIGN_MANSION_SIEGE_STATE'  # 3: at the Mansion's door; 4: the grunt trio beaten
ORBS = [('FLAG_SOVEREIGN_STEVEN_GAVE_ORBS', 1)]
CYRUS = [('FLAG_DEFEATED_TRAINER_GALACTIC_BOSS_CYRUS_DISTORTION_WORLD', 1)]
STORY = {
    ('events_acuity_lakefront', 'LOCALID_LEGENDARY_CHIEN_PAO'): [('FLAG_SOVEREIGN_PULLED_STAKE_3', 1),
                                                                 ('FLAG_SOVEREIGN_PULLED_STAKE_4', 1)],
    ('events_battleground', 'LOCALID_SOVEREIGN_COUNTERPART'): [
        ('FLAG_DEFEATED_TRAINER_SOVEREIGN_DAWN_ROUTE_224_CHIMCHAR', 1)],
    ('events_contest_hall_stage_no_contest', 'LOCALID_LEGENDARY_MELOETTA'): [('FLAG_SOVEREIGN_MELOETTA_SONG', 1)],
    ('events_eterna_forest', 'LOCALID_LEGENDARY_CELEBI'): [('VAR_SOVEREIGN_CELEBI_STATE', 2)] + [
        (f'FLAG_DEFEATED_TRAINER_SOVEREIGN_{leader}_MEMORY', 1)
        for leader in ('FALKNER', 'BUGSY', 'WHITNEY', 'MORTY', 'CHUCK', 'JASMINE', 'PRYCE', 'CLAIR')],
    **{('events_eterna_forest', f'LOCALID_SOVEREIGN_TIME_PORTAL_{i}'): [('VAR_SOVEREIGN_CELEBI_STATE', 2)]
       for i in range(1, 9)},
    ('events_fuego_ironworks_building', 'LOCALID_LEGENDARY_RESHIRAM'): [('ITEM_LIGHT_STONE', 1)],
    ('events_fuego_ironworks_outside', 'LOCALID_LEGENDARY_CHI_YU'): [('FLAG_SOVEREIGN_PULLED_STAKE_7', 1),
                                                                     ('FLAG_SOVEREIGN_PULLED_STAKE_8', 1)],
    ('events_galactic_hq_laboratory', 'LOCALID_LEGENDARY_GENESECT'): [('FLAG_SOVEREIGN_GENESECT_FREED', 1)],
    ('events_lake_valor', 'LOCALID_LEGENDARY_KELDEO'): [('SPECIES_COBALION', 50), ('SPECIES_TERRAKION', 50),
                                                         ('SPECIES_VIRIZION', 50)],
    ('events_mt_coronet_b1f', 'LOCALID_LEGENDARY_KYOGRE'): ORBS,
    ('events_mt_coronet_outside_north', 'LOCALID_LEGENDARY_ARTICUNO'): CYRUS,
    ('events_oreburgh_mine_b2f', 'LOCALID_LEGENDARY_DIANCIE'): [('SPECIES_CARBINK', 50)],
    ('events_pokemon_league', 'LOCALID_LEGENDARY_RAYQUAZA'): ORBS,
    ('events_pokemon_mansion', 'LOCALID_SOVEREIGN_CLEFAIRY_1'): [(SIEGE, 4)],
    ('events_pokemon_mansion', 'LOCALID_SOVEREIGN_CLEFAIRY_2'): [
        (SIEGE, 4), ('FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_1', 1)],
    ('events_pokemon_mansion', 'LOCALID_SOVEREIGN_CLEFAIRY_4'): [
        (SIEGE, 4), ('FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_OFFICE', 1)],
    ('events_pokemon_mansion', 'LOCALID_SOVEREIGN_HAPPINY'): [
        (SIEGE, 4), ('FLAG_DEFEATED_TRAINER_SOVEREIGN_GRUNT_MANSION_ROOM_3', 1)],
    **{('events_pokemon_mansion', f'LOCALID_SOVEREIGN_{who}'): [(SIEGE, 3)]
       for who in ('GRUNT_OFFICE', 'GRUNT_ROOM_1', 'GRUNT_ROOM_3', 'GRUNT_TRIO', 'RIVAL')},
    ('events_pokemon_mansion_office', 'LOCALID_LEGENDARY_MANAPHY'): [(SIEGE, 7)],
    ('events_route_211_east', 'LOCALID_LEGENDARY_ENTEI'): CYRUS,
    ('events_route_212_north', 'LOCALID_SOVEREIGN_GRUNT_2'): [(SIEGE, 3)],
    ('events_route_212_north', 'LOCALID_SOVEREIGN_GRUNT_3'): [(SIEGE, 3)],
    ('events_route_214', 'LOCALID_LEGENDARY_TING_LU'): [('FLAG_SOVEREIGN_PULLED_STAKE_5', 1),
                                                        ('FLAG_SOVEREIGN_PULLED_STAKE_6', 1)],
    ('events_route_215', 'LOCALID_LEGENDARY_ZEKROM'): [('ITEM_DARK_STONE', 1), ('HOUR', 22)],
    ('events_route_220', 'LOCALID_LEGENDARY_LUGIA'): [('ITEM_SILVER_WING', 1)],
    ('events_route_228', 'LOCALID_LEGENDARY_LANDORUS'): [('SPECIES_TORNADUS', 50), ('SPECIES_THUNDURUS', 50)],
    ('events_sendoff_spring', 'LOCALID_LEGENDARY_KORAIDON'): [('VAR_SOVEREIGN_PARADOX_ANCIENT', 0x3ff)],
    ('events_solaceon_ruins_room_6_northwest_dead_end', 'LOCALID_LEGENDARY_HOOPA'): [('ITEM_PRISON_BOTTLE', 1)],
    ('events_solaceon_ruins_room_7', 'LOCALID_LEGENDARY_JIRACHI'): [('FLAG_SOVEREIGN_JIRACHI_SIGN_CHANGED', 1)],
    ('events_stark_mountain_room_1', 'LOCALID_LEGENDARY_GROUDON'): ORBS,
    ('events_valley_windworks_building', 'LOCALID_LEGENDARY_REGIELEKI'): [
        ('SPECIES_REGIROCK', 50), ('SPECIES_REGICE', 50), ('SPECIES_REGISTEEL', 50)],
    ('events_veilstone_city', 'LOCALID_LEGENDARY_DEOXYS'): [('FLAG_SOVEREIGN_DEOXYS_SENSED', 1)],
}
PARTY = 6  # the test save's party


def var_ids():
    """{var or flag name: its number}, from the build's generated enum."""
    text = open(os.path.join(DECOMP, 'build_test', 'generated', 'vars_flags.py'), encoding='utf-8').read()
    return {name: int(value) for name, value in re.findall(r'^\s+(\w+)\s+=\s+(\d+)$', text, re.M)}


def header_names():
    return [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'map_headers.txt')) if line.strip()]


def way_in(maps, matrix, warps, taken):
    """Where a player coming in by the map's first warp stands: the walkable tile next to it with the most walkable
    tiles around (the one inward, as the game steps the player off a door), or None."""
    def free(p):
        return p not in taken and walkable(maps.tile(matrix, *p))

    for wx, wz in warps[:1]:
        steps = [(wx + dx, wz + dz) for dx, dz in DIRS if free((wx + dx, wz + dz))]
        if steps:
            return max(steps, key=lambda p: sum(free((p[0] + dx, p[1] + dz)) for dx, dz in DIRS))
    return None


def event_maps():
    """(events, [(header, matrix)], its events JSON, its matrix JSON) for each map's events file."""
    headers = open(os.path.join(DECOMP, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
    by_events = {}
    for name, block in re.findall(r'\[(MAP_HEADER_\w+)\] = \{(.*?)\n    \},', headers, re.S):
        fields = dict(re.findall(r'\.(\w+) = (\w+)', block))
        if 'eventsArchiveID' in fields and 'mapMatrixID' in fields:
            by_events.setdefault(fields['eventsArchiveID'], []).append((name, fields['mapMatrixID']))
    for events, headers_of in sorted(by_events.items()):
        path = os.path.join(DECOMP, 'res', 'field', 'events', events + '.json')
        if os.path.exists(path):
            grid = os.path.join(DECOMP, 'res', 'field', 'matrices', headers_of[0][1] + '.json')
            yield events, headers_of, json.load(open(path, encoding='utf-8')), json.load(open(grid, encoding='utf-8'))


def header_at(headers_of, grid, x, z):
    """The header of the map the tile is on: on an outdoor matrix, the header of that 32x32 map."""
    if grid.get('headers'):
        row, col = z // 32, x // 32
        if row < len(grid['headers']) and col < len(grid['headers'][row]) \
                and grid['headers'][row][col] in [h for h, _ in headers_of]:
            return grid['headers'][row][col]
    return headers_of[0][0]


def stand_next_to(maps, matrix, grid, warps, taken, x, z, dirs=DIRS, enter=False, inside=()):
    """Where the player stands to face the tile (x, z): (x, z, facing) of a reachable tile next to it (or across a
    counter), or (x, z, None) when there is none. dirs: the steps from that tile to (x, z) allowed (a sign is read
    facing north). With enter (a coord trigger) the player steps onto (x, z), so it must be reachable itself and the
    tile stood on not one of inside (the trigger's other tiles). A coord trigger doesn't look at the elevation (the
    game compares only x and z), so its tiles count reached on a bike bridge's level too (Victory Road 1F's)."""
    rows = grid['maps']
    if len(rows) * len(rows[0]) <= 16:  # an indoor or small map: all of it
        box, edge = (0, 0, len(rows[0]) * 32 - 1, len(rows) * 32 - 1), []
    else:
        box = (x - WINDOW, z - WINDOW, x + WINDOW, z + WINDOW)
        edge = [(i, j) for i in range(box[0], box[2] + 1) for j in (box[1], box[3])] + \
               [(i, j) for j in range(box[1], box[3] + 1) for i in (box[0], box[2])]
    # Past the objects if it can (some may be hidden by a flag, so then through them).
    for blocked in (set(taken) | ({(x, z)} if not enter else set()), set() if enter else {(x, z)}):
        seen = explore(maps, matrix, box, edge, warps, blocked)
        levels = (False, True) if enter else (False,)
        if enter and not any((x, z, e) in seen for e in levels):
            continue
        for d in dirs:
            p = (x - d[0], z - d[1])
            if p not in blocked and p not in inside and any((p + (e,)) in seen
                                                            and can_turn(maps, matrix, p[0], p[1], e, d) for e in levels):
                return p + (FACE[d],)
        for d in () if enter else dirs:
            if (maps.tile(matrix, x - d[0], z - d[1]) or 0) & 0xff == TABLE \
                    and (x - 2 * d[0], z - 2 * d[1], False) in seen:
                return (x - 2 * d[0], z - 2 * d[1], FACE[d])
    return (x, z, None)


def way_in_to(maps, matrix, grid, cur, header, taken, fallback):
    """The way in (way_in) by the first warp on the header's own map, or fallback."""
    own = [(w['x'], w['z']) for w in cur.get('warp_events', []) if not grid.get('headers')
           or grid['headers'][w['z'] // 32][w['x'] // 32] == header]
    return way_in(maps, matrix, own, taken) or fallback


def cases():
    """[(events, object id, header ID, (x, z) of the map's way in, x, z, facing, or None when no tile)] for each added
    or moved object."""
    maps = Maps(DECOMP)
    ids = header_names()
    out = []
    for events, headers_of, cur, grid in event_maps():
        matrix = headers_of[0][1]
        path = os.path.join('decomp', 'res', 'field', 'events', events + '.json')
        old = {(o['graphics_id'], o['x'], o['z']) for o in vanilla_events(path).get('object_events', [])}
        objs = cur.get('object_events', [])
        warps = [(w['x'], w['z']) for w in cur.get('warp_events', [])]
        taken = {(o['x'], o['z']) for o in objs}
        for o in objs:
            x, z = o['x'], o['z']
            if (o['graphics_id'], x, z) in old or maps.tile(matrix, x, z) is None or not o.get('script'):
                continue
            header = header_at(headers_of, grid, x, z)
            stand = stand_next_to(maps, matrix, grid, warps, taken, x, z)
            out.append((events, o['id'], ids.index(header), way_in_to(maps, matrix, grid, cur, header, taken,
                                                                       stand[:2])) + stand)
    return out


def script_id(obj):
    """The script the field starts when the player talks to an object: its script, or for a trainer the battle's
    (from_script in decomp/tools/jsoncnv/convert.py)."""
    script = str(obj['script'])
    if not script.startswith('TRAINER_'):
        return int(script)
    trainers = [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'trainers.txt')) if line.strip()]
    return trainers.index(script) - 1 + (5000 if obj.get('double_battle_id', 1) == 2 else 3000)


def object_scripts(events, oid):
    """(the object's script, the scripts of the other objects on its tile, the scripts of the map's other objects)."""
    path = os.path.join('decomp', 'res', 'field', 'events', events + '.json')
    objs = json.load(open(path))['object_events']
    obj = next(o for o in objs if o['id'] == oid)
    others = [o for o in objs if o['id'] != oid]
    return (script_id(obj), {script_id(o) for o in others if (o['x'], o['z']) == (obj['x'], obj['z'])},
            {script_id(o) for o in others})


def object_event(events, oid):
    path = os.path.join('decomp', 'res', 'field', 'events', events + '.json')
    return next(o for o in json.load(open(path))['object_events'] if o['id'] == oid)


def hidden_flag(events, oid):
    """The flag that hides the object (its hidden_flag; a few objects hold a map header there instead), or None."""
    flag = object_event(events, oid)['hidden_flag']
    return None if str(flag) == '0' else flag


def u32(d, addr):
    return struct.unpack('<I', bytes(d.emu.memory.unsigned[addr:addr + 4]))[0]


def play_out(d, sym, limit, header=None, press_a=True, wait_for_script=False):
    """Play out what starts now (a script, a warp and any scene on entering the map, a battle) until the field is idle
    again (on header, if given). With press_a, A is pressed first, to talk. With wait_for_script, no input goes in
    until a script has started (gSovereignTestScripts, cleared by the caller): a warp needs none, and an A press as it
    ends would talk to what the player faces. Returns ('ok', 'NOSCRIPT' (nothing started), 'HANG', 'STUCK' or 'HEAP'
    (it ended, but a heap's block lists are broken: heap_check.py), frames run)."""
    if press_a:
        d.press('A', frames=4, after=0)
    frames, stalled, started, idle, step = 0, 0, False, 0, 0
    vblank = u32(d, sym['gSystem'] + VBLANK_COUNTER)
    while frames < limit:
        before = u32(d, sym['gSovereignTestIdleFrames'])
        d.run(STEP)
        frames += STEP
        now = u32(d, sym['gSystem'] + VBLANK_COUNTER)
        stalled = stalled + STEP if now == vblank else 0
        vblank = now
        if stalled >= HANG_FRAMES:
            return 'HANG', frames
        if u32(d, sym['gSovereignTestIdleFrames']) == before:
            started, idle = True, 0
            if wait_for_script and not u32(d, sym['gSovereignTestScripts']) & 0xffff:
                continue
            step += 1
            if step % 7 == 0:  # backs out of a menu the other inputs keep open (a shop, the party screen)
                d.press('B', frames=4, after=0)
            elif step % 3 == 0:  # text, prompts, and the move a tap opened in a battle
                d.press('A', frames=4, after=0)
            else:
                d.touch(*TAPS[frames // SWITCH_FRAMES % len(TAPS)], frames=4, after=0)
        elif started and (header is None or u32(d, sym['gSovereignTestIdleMapHeaderID']) == header):
            idle += 1
            if idle >= 2:
                return ('HEAP' if heap_problems(d.emu.memory, heap_info()) else 'ok'), frames
        elif frames >= START_FRAMES:
            return 'NOSCRIPT', frames
    return 'STUCK', frames


def warp(d, sym, header, x, z, dir):
    """Warp to the tile on the header's map facing dir (enum FaceDirection + 1, or 0 for down) and play out what
    starts on the way in. Returns play_out's result."""
    d.emu.memory.write_short(sym['gSovereignTestScripts'], 0)
    start_warp(d, sym, header, x, z, dir)
    return play_out(d, sym, FRAME_LIMIT, header, press_a=False, wait_for_script=True)


def start_warp(d, sym, header, x, z, dir):
    """Start the warp warp() makes, and leave what follows to the caller."""
    mem, target = d.emu.memory, sym['gSovereignTestWarpTarget']
    mem.write_short(target + WARP['x'], x)
    mem.write_short(target + WARP['z'], z)
    mem.write_short(target + WARP['dir'], dir)
    mem.write_short(target + WARP['header'], header)
    # A busy outdoor map runs the field every other frame and can miss the frame SELECT goes down on, so it tries
    # again an odd number of frames later.
    for attempt in range(10):
        before = u32(d, sym['gSovereignTestIdleFrames'])
        d.press('SELECT+L+R', frames=4, after=0)
        d.run(10 + attempt % 2)
        if u32(d, sym['gSovereignTestIdleFrames']) - before < 10:
            break


def arrive(d, sym, state, variables, events, header, way_in, x, z, face, setup=None):
    """From the save state, with god mode on: in by the map's way in first, as a player comes, so a scene on entering
    it plays out where it expects the player (it may walk them about), then to the tile (x, z) facing face. setup, if
    given, runs once the state is loaded (to set test hooks the first warp applies). Returns ('ok', frames) or
    ('NOWARP ' + play_out's result, frames)."""
    d.load_state(state)
    d.emu.memory.write_byte(sym['gSovereignTestClock'], HOUR + 1)
    d.run(30)  # the game reads the clock every 11 frames (UpdateRTC)
    d.emu.memory.write_byte(sym['gSovereignTestGodMode'], 1)
    if POSTGAME or CHRONICLES:
        d.emu.memory.write_byte(sym['gSovereignTestBadges'], 0xff)
        # [1]; [0] is SCENES_SEEN's
        d.emu.memory.write_short(sym['gSovereignTestVar'] + 4, variables['FLAG_GAME_COMPLETED'])
        d.emu.memory.write_short(sym['gSovereignTestVar'] + 6, 1)
    if CHRONICLES:
        d.emu.memory.write_short(sym['gSovereignTestVar'] + 8, variables['VAR_SOVEREIGN_CHRONICLE'])  # [2]
        d.emu.memory.write_short(sym['gSovereignTestVar'] + 10, 5)
    if setup:
        setup()
    if events in SCENES_SEEN:
        var, value = SCENES_SEEN[events]
        d.emu.memory.write_short(sym['gSovereignTestVar'], variables[var])
        d.emu.memory.write_short(sym['gSovereignTestVar'] + 2, value)
    arrived, waited = warp(d, sym, header, *way_in, 0)
    if arrived == 'ok':
        arrived, waited = warp(d, sym, header, x, z, face + 1)  # a warp on the same map runs too, so it waits for it
    return (arrived, waited) if arrived == 'ok' else ('NOWARP ' + arrived, waited)


def talk(d, sym, events, oid, header, x, z, face):
    """Press A to talk to the object from the tile (x, z) and play its script out. Another script can run first (a
    trainer who sees the player walks up and battles): then, as a player would, the test warps back to the tile facing
    the object and talks once more. Returns play_out's result, 'STANDIN' (another object answered from the object's
    tile, so the object is hidden: one placed there, or the second time any object), or ('OTHER ' + the script that ran
    instead, frames)."""
    own, same_tile, others = object_scripts(events, oid)
    for again in (False, True):
        if again:
            result, frames = warp(d, sym, header, x, z, face + 1)
            if result != 'ok':
                return 'NOWARP ' + result, frames
        d.emu.memory.write_short(sym['gSovereignTestScripts'], 0)
        result, frames = play_out(d, sym, LONG_SCRIPTS.get((events, oid), FRAME_LIMIT))
        started = u32(d, sym['gSovereignTestScripts'])
        if not started & 0xffff or started >> 16 == own:
            return ('ok' if started & 0xffff and result == 'NOSCRIPT' else result), frames  # NOSCRIPT: it ended at once
        if result != 'ok':
            return result, frames
        if started >> 16 in (others if again else same_tile):
            return 'STANDIN', frames
    return f'OTHER {started >> 16}', frames


def parse_args(args):
    """(rom, state, out dir, the events files to limit to, part, parts) from the command line."""
    global POSTGAME, CHRONICLES, UNHIDE
    part, parts = 0, 1
    POSTGAME, CHRONICLES, UNHIDE = '--postgame' in args, '--chronicles' in args, '--unhide' in args
    args = [a for a in args if a not in ('--postgame', '--chronicles', '--unhide')]
    if '--part' in args:
        at = args.index('--part')
        part, parts = map(int, args[at + 1].split('/'))
        args = args[:at] + args[at + 2:]
    os.makedirs(args[2], exist_ok=True)
    return args[0], args[1], args[2], set(args[3:]), part, parts


SYMBOLS = ('gSovereignTestWarpTarget', 'gSovereignTestVar', 'gSovereignTestIdleFrames', 'gSovereignTestIdleMapHeaderID',
           'gSovereignTestGodMode', 'gSovereignTestScripts', 'gSovereignTestClock', 'gSovereignTestBadges',
           'gSovereignTestCaughtAllBut', 'gSovereignTestPartyKeep', 'gSovereignTestPartyAdd', 'gSovereignTestBagItem',
           'gSystem')


def main():
    from drive import Driver

    rom, state, out, only, part, parts = parse_args(sys.argv[1:])
    sym = symbols(SYMBOLS)
    variables = var_ids()
    species = [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'species.txt')) if line.strip()]
    items = [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'items.txt')) if line.strip()]
    chosen = [(i, c) for i, c in enumerate(cases()) if (not only or c[0] in only) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, (events, oid, header, way_in, x, z, face) in chosen:
            if face is None:
                result, frames = 'NOTILE', 0
            else:
                flag = hidden_flag(events, oid) if UNHIDE else None

                def unhide(flag=flag, own=oid.replace('LOCALID_LEGENDARY_', 'SPECIES_'), events=events, oid=oid):
                    if flag in variables:  # [3]: [0] is SCENES_SEEN's, [1] --postgame's and [2] --chronicles'
                        d.emu.memory.write_short(sym['gSovereignTestVar'] + 12, variables[flag])
                        d.emu.memory.write_short(sym['gSovereignTestVar'] + 14, 0)
                    if UNHIDE and own in species:
                        d.emu.memory.write_short(sym['gSovereignTestCaughtAllBut'], species.index(own))
                    story = STORY.get((events, oid), []) if UNHIDE else []
                    for i, (name, value) in enumerate((n, v) for n, v in story if n in variables):
                        d.emu.memory.write_short(sym['gSovereignTestVar'] + 16 + 4 * i, variables[name])
                        d.emu.memory.write_short(sym['gSovereignTestVar'] + 18 + 4 * i, value)
                    party = [(n, v) for n, v in story if n.startswith('SPECIES_')]
                    if party:
                        d.emu.memory.write_byte(sym['gSovereignTestPartyKeep'], PARTY - len(party))
                    for i, (name, level) in enumerate(party):
                        d.emu.memory.write_short(sym['gSovereignTestPartyAdd'] + 4 * i, species.index(name))
                        d.emu.memory.write_byte(sym['gSovereignTestPartyAdd'] + 4 * i + 3, level)
                    for name, value in story:
                        if name.startswith('ITEM_'):
                            d.emu.memory.write_short(sym['gSovereignTestBagItem'], items.index(name))
                        elif name == 'HOUR':
                            d.emu.memory.write_byte(sym['gSovereignTestClock'], value + 1)

                result, frames = arrive(d, sym, state, variables, events, header, way_in, x, z, face, unhide)
                if result == 'ok':
                    result, frames = talk(d, sym, events, oid, header, x, z, face)
                tries = WANDER_TRIES if 'WANDER' in object_event(events, oid)['movement_type'] else 0
                while result == 'NOSCRIPT' and tries:  # it may have stepped off its tile: warp back and try again
                    tries -= 1
                    result, frames = warp(d, sym, header, x, z, face + 1)
                    result, frames = talk(d, sym, events, oid, header, x, z, face) if result == 'ok' else (
                        'NOWARP ' + result, frames)
            if result not in ('ok', 'NOSCRIPT', 'STANDIN'):
                bad += 1
                if face is not None:
                    d.screenshot().save(os.path.join(out, f'{index:03d}_{events}_{result}.png'))
            line = f'{index} {events} {oid} ({x}, {z}): {result} {frames}'
            print(line, file=f, flush=True)
            print(line, flush=True)
    print(f'{len(chosen) - bad} of {len(chosen)} ok or not there')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
