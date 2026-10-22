#!/usr/bin/env python3
"""Log what the doubles AI estimates its spread moves would do to its own partner (12b, LoadPartnerDamagePercent)
or, with --other-foe, to the foe it isn't scoring the move against (LoadOtherFoeDamagePercent).

Starts the test build's trainer battle (SELECT+R, TRAINER_SOVEREIGN_TEST) from an emulator state and prints, for each
AI Pokemon and move, the percentage of the partner's HP the AI expects the move to take (255 = the move doesn't hit
the partner; with --other-foe, 255 = doesn't hit a second foe and 254 = the second foe absorbs it). To test a scenario, temporarily edit decomp/res/trainers/data/sovereign_test.json (e.g. a lead that
knows Earthquake/Surf/Discharge next to a partner that's weak, immune or absorbs), rebuild the test ROM, and run this.

Usage (from decomp/): python3 ../tools/test/log_ai_partner_damage.py [--other-foe] ROM XMAP STATE [OUT_DIR]
  STATE: an emulator state in the overworld made with this ROM (tools/test/new_game.sh)
Struct offsets below come from the debug info in build_test/main.nef.p/src_battle_trainer_ai_trainer_ai.c.o
(arm-none-eabi-readelf --debug-dump=info): BattleContext.aiContext = 852; in AIContext, move = 2, calcTemp = 8,
attacker = 127, defender = 128. Re-check them if those structs change.
"""
import os
import struct
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from drive import Driver
args = sys.argv[1:]
other_foe = "--other-foe" in args
if other_foe:
    args.remove("--other-foe")
rom, xmap, state = args[:3]
cmd = "AICmd_LoadOtherFoeDamagePercent" if other_foe else "AICmd_LoadPartnerDamagePercent"
want = [cmd, "AICmd_IfLoadedEqualTo"]
addr = {}
for line in open(xmap):
    p = line.split()
    if len(p) >= 4 and p[2] == ".text" and p[3] in want:
        addr[p[3]] = int(p[0], 16)
moves = [l.strip() for l in open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "decomp", "generated", "moves.txt")) if l.strip()]
d = Driver(rom, state=state)
m = d.emu.memory.unsigned
pending = [None]
log = []
def on_load(a, s):
    pending[0] = d.emu.memory.register_arm9.r1
    return True
def on_if(a, s):
    if pending[0] is not None:
        ai = pending[0] + 852
        move = m[ai + 2] | m[ai + 3] << 8
        calc = struct.unpack("<i", bytes(m[ai + 8:ai + 12]))[0]
        log.append((m[ai + 127], m[ai + 128], moves[move], calc))
        pending[0] = None
    return True
d.emu.memory.register_exec(addr[cmd], on_load)
d.emu.memory.register_exec(addr["AICmd_IfLoadedEqualTo"], on_if)
d.do("SELECT+R")
d.do("wait:1500")
d.do("shot:ai_turn", args[3] if len(args) > 3 else ".")
seen = {}
for att, dfn, mv, calc in log:
    seen.setdefault((att, dfn if other_foe else None, mv), set()).add(calc)
for (att, dfn, mv), vals in sorted(seen.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0, kv[0][2])):
    if other_foe:
        print(f"attacker {att} target {dfn} {mv:20s} other-foe damage % {sorted(vals)} (255 = not hit, 254 = absorbs)")
    else:
        print(f"attacker {att} {mv:20s} partner-damage % {sorted(vals)} (255 = not hit)")
