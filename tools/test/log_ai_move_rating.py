#!/usr/bin/env python3
"""Log the trainer AI's ratings of the Gen V+ moves Platinum's AI script doesn't know (12b, LoadSovereignMoveRating).

Starts the test build's trainer battle (SELECT+R, TRAINER_SOVEREIGN_TEST) from an emulator state and prints, for each
AI Pokemon, target and move, the rating: USELESS (score -10 against a foe, -30 on the partner), GOOD (+3 on the
partner), FAIR (+1 on the partner) or NO_RATING (the script's own rules). To test a scenario, temporarily edit
decomp/res/trainers/data/sovereign_test.json (moves, levels, double_battle), rebuild the test ROM, make a new state
with it, and run this.

Usage (from decomp/): python3 ../tools/test/log_ai_move_rating.py ROM XMAP STATE OUT_DIR [ACTIONS...]
  STATE: an emulator state in the overworld made with this ROM (tools/test/new_game.sh)
  ACTIONS: drive.py actions after the battle starts (e.g. "A wait:40 shot:s01" repeated to play a turn)
  SETHP=3:30   environment: set battlers' HP (battler:percent, comma-separated) as the AI first rates a move
  SPLASH=1     environment: the player's Pokemon (battlers 0 and 2) know only Splash
Struct offsets come from the debug info in build_test/main.nef.p/src_battle_trainer_ai_trainer_ai.c.o
(arm-none-eabi-readelf --debug-dump=info): BattleContext.aiContext = 852 (AIContext: move = 2, calcTemp = 8,
attacker = 127, defender = 128), BattleContext.battleMons = 19268, sizeof(BattleMon) = 200 (moves = 0x0C,
curHP = 0x54, maxHP = 0x58). Re-check them if those structs change.
"""
import os
import struct
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from drive import Driver

AI_CONTEXT, BATTLE_MONS, BATTLE_MON_SIZE = 852, 19268, 200
RATINGS = {0: "NO_RATING", 1: "USELESS", 2: "GOOD (+3)", 3: "FAIR (+1)"}

rom, xmap, state, out = sys.argv[1:5]
actions = sys.argv[5:]
want = ["AICmd_LoadSovereignMoveRating", "AICmd_IfLoadedEqualTo"]
addr = {}
for line in open(xmap):
    p = line.split()
    if len(p) >= 4 and p[2] == ".text" and p[3] in want:
        addr[p[3]] = int(p[0], 16)
moves = [l.strip() for l in open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "decomp", "generated", "moves.txt")) if l.strip()]
sethp = [tuple(int(x) for x in kv.split(":")) for kv in os.environ.get("SETHP", "").split(",") if kv]
d = Driver(rom, state=state)
m = d.emu.memory.unsigned
pending, prepared, log = [None], [False], []


def on_load(a, s):
    ctx = d.emu.memory.register_arm9.r1
    pending[0] = ctx
    if not prepared[0]:
        prepared[0] = True
        for battler, pct in sethp:
            mon = ctx + BATTLE_MONS + BATTLE_MON_SIZE * battler
            max_hp = int.from_bytes(bytes(m[mon + 0x58:mon + 0x5C]), "little")
            d.emu.memory.write_long(mon + 0x54, max(1, max_hp * pct // 100))
        if os.environ.get("SPLASH"):
            for battler in (0, 2):
                for slot in range(4):
                    d.emu.memory.write_short(ctx + BATTLE_MONS + BATTLE_MON_SIZE * battler + 0x0C + 2 * slot, moves.index("MOVE_SPLASH"))
    return True


def on_if(a, s):
    if pending[0] is not None:
        ai = pending[0] + AI_CONTEXT
        move = m[ai + 2] | m[ai + 3] << 8
        log.append((m[ai + 127], m[ai + 128], moves[move], struct.unpack("<i", bytes(m[ai + 8:ai + 12]))[0]))
        pending[0] = None
    return True


d.emu.memory.register_exec(addr[want[0]], on_load)
d.emu.memory.register_exec(addr[want[1]], on_if)
d.do("SELECT+R")
d.do("wait:1500")
d.do("shot:ai_turn", out)
for action in actions:
    d.do(action, out)
seen = {}
for att, dfn, mv, rating in log:
    seen.setdefault((att, dfn, mv), set()).add(rating)
for (att, dfn, mv), vals in sorted(seen.items()):
    print(f"attacker {att} target {dfn} {mv:22s} {', '.join(RATINGS.get(v, str(v)) for v in sorted(vals))}")
