#!/usr/bin/env python3
"""Read Renegade Platinum's field scripts, text and map events from its ROM, for porting them by hand (E10).

Renegade is a binary hack, so its NPC scripts only exist in its ROM. Build vanilla Platinum from the first decomp
import and apply Renegade's patch (`tools/build/apply_renegade_patch.sh`), then:

    renegade_rom.py ROM script scripts_route_216_house   # disassemble a map's scripts (ScriptEntry N = EntryN-1)
    renegade_rom.py ROM text TEXT_BANK_ROUTE_216_HOUSE      # its text bank, decoded
    renegade_rom.py ROM events events_route_216_house       # its NPCs, signs, warps and triggers
    renegade_rom.py ROM gifts                               # every script that gives an item (VAR_0x8004/0x8005)

Run it on the vanilla ROM too to see what Renegade changed. Archive indices are Platinum's, read from the first
decomp import (git commit FIRST_IMPORT), since Sovereign has added files since. The disassembler knows every command
whose macro in asm/macros/scrcmd.inc is a plain list of .byte/.short/.long arguments; it stops at any other (`??`).
Values are printed raw (item, species and flag numbers). Needs ndspy, git, and a release build (for msgenc).
"""
import json
import os
import re
import struct
import subprocess
import sys
import tempfile

import ndspy.narc
import ndspy.rom

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
FIRST_IMPORT = "11c34eff"


def vanilla_list(path):
    out = subprocess.run(["git", "-C", ROOT, "show", f"{FIRST_IMPORT}:decomp/{path}"], capture_output=True, text=True,
                         check=True).stdout
    return [l.strip() for l in out.splitlines() if l.strip()]


def load_macros():
    cmds = re.findall(r"^ScriptCommand\((SCRCMD_\w+),", open(os.path.join(DECOMP, "include/data/scripts/scrcmd.h")).read(), re.M)
    op_of = {c: i for i, c in enumerate(cmds)}
    macros = {}
    text = open(os.path.join(DECOMP, "asm/macros/scrcmd.inc")).read()
    for m in re.finditer(r"^    \.macro (\w+)[^\n]*\n(.*?)^    \.endm", text, re.M | re.S):
        lines = [l.strip() for l in m.group(2).strip().splitlines()]
        if not lines or not lines[0].startswith(".short SCRCMD_") or any(not re.match(r"^\.(byte|short|long) ", l) for l in lines):
            continue
        op = op_of.get(lines[0].split()[1])
        if op is not None and op not in macros:
            macros[op] = (m.group(1), [(l.split(None, 1)[0], "-.-4" in l) for l in lines[1:]])
    return macros


def disassemble(data):
    macros = load_macros()
    entries, pos = [], 0
    while struct.unpack_from("<H", data, pos)[0] != 0xFD13:
        entries.append(pos + 4 + struct.unpack_from("<i", data, pos)[0])
        pos += 4
    labels = {e: f"Entry{i}" for i, e in enumerate(entries)}
    todo, seen, out = list(entries), set(), {}
    while todo:
        pc = todo.pop()
        while pc not in seen and pc < len(data) - 1:
            seen.add(pc)
            op = struct.unpack_from("<H", data, pc)[0]
            if op not in macros:
                out[pc] = f"?? {data[pc:pc + 8].hex()}"
                break
            name, args = macros[op]
            p, vals = pc + 2, []
            if p + sum({".byte": 1, ".short": 2, ".long": 4}[k] for k, _ in args) > len(data):
                out[pc] = f"?? (runs past the end) {data[pc:pc + 8].hex()}"
                break
            for kind, relative in args:
                if kind == ".byte":
                    v, p = data[p], p + 1
                elif kind == ".short":
                    v, p = struct.unpack_from("<H", data, p)[0], p + 2
                else:
                    v, p = struct.unpack_from("<i", data, p)[0], p + 4
                    if relative:
                        target = p + v
                        if name.startswith("ApplyMovement"):  # movement data, not commands
                            labels.setdefault(target, f"Movement_{target:x}")
                        else:
                            labels.setdefault(target, f"L_{target:x}")
                            todo.append(target)
                        v = labels[target]
                vals.append(v)
            out[pc] = f"{name} " + ", ".join(hex(v) if isinstance(v, int) and v >= 0x4000 else str(v) for v in vals)
            if name in ("End", "GoTo", "Return", "ReturnCommonScript"):
                break
            pc = p
    for target, label in labels.items():
        if label.startswith("Movement_"):  # (movement command, count) pairs up to 0xFE
            steps, q = [], target
            while q + 4 <= len(data):
                move, count = struct.unpack_from("<HH", data, q)
                q += 4
                if move == 0xFE:
                    break
                steps.append(f"{move}x{count}")
            out[target] = "movement " + ", ".join(steps)
    lines = []
    for pc in sorted(out):
        if pc in labels:
            lines.append(f"{labels[pc]}:")
        lines.append(f"    {out[pc]}")
    return "\n".join(lines)


def narc_file(rom, path, order_path, name):
    return bytes(ndspy.narc.NARC(rom.getFileByName(path)).files[vanilla_list(order_path).index(name)])


def text_bank(rom, bank):
    data = bytes(ndspy.narc.NARC(rom.getFileByName("msgdata/pl_msg.narc")).files[vanilla_list("generated/text_banks.txt").index(bank)])
    tools = os.path.join(DECOMP, "build", "tools", "msgenc")
    with tempfile.TemporaryDirectory() as t:
        open(os.path.join(t, "bank.bin"), "wb").write(data)
        subprocess.run([os.path.join(tools, "msgenc"), "-d", "--json", "-c", os.path.join(tools, "charmap.txt"),
                        os.path.join(t, "bank.json"), os.path.join(t, "bank.bin")], capture_output=True, check=True)
        messages = json.load(open(os.path.join(t, "bank.json")))["messages"]
    return "\n".join(f"{i}: {m.get('en_US', m) if isinstance(m, dict) else m}" for i, m in enumerate(messages))


def events(data):
    lines, p = [], 0
    n = struct.unpack_from("<I", data, p)[0]; p += 4
    for i in range(n):
        script, kind, x, z, y, facing = struct.unpack_from("<HHIIIH", data, p); p += 20
        lines.append(f"bg{i}: script {script} type {kind} x {x} z {z} y {y} facing {facing}")
    n = struct.unpack_from("<I", data, p)[0]; p += 4
    for i in range(n):
        v = struct.unpack_from("<14HI", data, p); p += 32
        lines.append(f"object{i}: id {v[0]} gfx {v[1]} movement {v[2]} trainer_type {v[3]} hidden_flag {v[4]} "
                     f"script {v[5]} dir {v[6]} data {list(v[7:10])} range {list(v[10:12])} x {v[12]} z {v[13]} y {v[14] >> 16}")
    n = struct.unpack_from("<I", data, p)[0]; p += 4
    for i in range(n):
        x, z, header, warp = struct.unpack_from("<4H", data, p); p += 12
        lines.append(f"warp{i}: x {x} z {z} dest_header {header} dest_warp {warp}")
    n = struct.unpack_from("<I", data, p)[0]; p += 4
    for i in range(n):
        v = struct.unpack_from("<8H", data, p); p += 16
        lines.append(f"coord{i}: script {v[0]} x {v[1]} z {v[2]} width {v[3]} length {v[4]} y {v[5]} value {v[6]} var {v[7]}")
    return "\n".join(lines)


def gifts(rom):
    items = [l.strip() for l in open(os.path.join(DECOMP, "generated", "items.txt")) if l.strip()]
    order = vanilla_list("res/field/scripts/scripts.order")
    for name, f in zip(order, ndspy.narc.NARC(rom.getFileByName("fielddata/script/scr_seq.narc")).files):
        found = []
        for m in re.finditer(re.escape(b"\x28\x00\x04\x80"), bytes(f)):
            o = m.start()
            if f[o + 6:o + 10] == b"\x28\x00\x05\x80":
                item, count = struct.unpack_from("<H", f, o + 4)[0], struct.unpack_from("<H", f, o + 10)[0]
                found.append(f"{items[item] if item < len(items) else item} x{count}")
        if found:
            print(f"{name}: {', '.join(found)}")


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    rom = ndspy.rom.NintendoDSRom.fromFile(sys.argv[1])
    kind = sys.argv[2]
    if kind == "script":
        print(disassemble(narc_file(rom, "fielddata/script/scr_seq.narc", "res/field/scripts/scripts.order", sys.argv[3])))
    elif kind == "text":
        print(text_bank(rom, sys.argv[3]))
    elif kind == "events":
        print(events(narc_file(rom, "fielddata/eventdata/zone_event.narc", "res/field/events/zone_event.order", sys.argv[3])))
    elif kind == "gifts":
        gifts(rom)
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
