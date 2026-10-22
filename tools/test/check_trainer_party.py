#!/usr/bin/env python3
"""Check a trainer's party in game against its JSON (milestone E9, the Sovereign trainer format).

Boots the test ROM from a battery save, starts the test build's trainer battle (SELECT+R, TRAINER_SOVEREIGN_TEST),
and decrypts every Pokémon the game adds to the opponent's party (a hook on Party_AddPokemon). Each one is compared
with decomp/res/trainers/data/<trainer>.json: species, form, level, item, moves, nature, gender, ability, IVs, EVs,
shininess and ball, plus all six stats recomputed from base stats, IVs, EVs and nature.

Usage: python3 tools/test/check_trainer_party.py ROM XMAP SAVE [TRAINER_JSON]
  ROM           decomp/build_test/pokeplatinum.us.nds
  XMAP          decomp/build_test/main.nef.xMAP (for the Party_AddPokemon address)
  SAVE          an emulator save state in the overworld made with this ROM (*.dst, e.g. from tools/test/new_game.sh),
                or a battery save (drive.py's export:), which works across rebuilds
  TRAINER_JSON  default decomp/res/trainers/data/sovereign_test.json
Saves a screenshot, trainer_battle.png, in $OUT_DIR (default: the current directory). Exits 1 on any mismatch. Requires py-desmume; run with SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy when headless.
"""
import json
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(__file__))
from drive import Driver  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")

# BoxPokemon_GetDataBlock (src/pokemon.c): where blocks A-D sit for ((personality & 0x3E000) >> 13) % 24.
SHUFFLE = [(0, 1, 2, 3), (0, 1, 3, 2), (0, 2, 1, 3), (0, 3, 1, 2), (0, 2, 3, 1), (0, 3, 2, 1),
           (1, 0, 2, 3), (1, 0, 3, 2), (2, 0, 1, 3), (3, 0, 1, 2), (2, 0, 3, 1), (3, 0, 2, 1),
           (1, 2, 0, 3), (1, 3, 0, 2), (2, 1, 0, 3), (3, 1, 0, 2), (2, 3, 0, 1), (3, 2, 0, 1),
           (1, 2, 3, 0), (1, 3, 2, 0), (2, 1, 3, 0), (3, 1, 2, 0), (2, 3, 1, 0), (3, 2, 1, 0)]
STATS = ["hp", "atk", "def", "spe", "spa", "spd"]  # the game's IV/EV order
BASE_KEYS = ["hp", "attack", "defense", "speed", "special_attack", "special_defense"]
GENDERS = {0: "male", 1: "female", 2: "genderless"}


def consts(name):
    return [line.strip() for line in open(os.path.join(DECOMP, "generated", name)) if line.strip()]


def decode(data, seed):
    """EncodeData/DecodeData (src/math_util.c): XOR each u16 with the LCRNG stream."""
    out = bytearray(data)
    for i in range(0, len(out), 2):
        seed = (seed * 1103515245 + 24691) & 0xFFFFFFFF
        v = struct.unpack_from("<H", out, i)[0] ^ (seed >> 16)
        struct.pack_into("<H", out, i, v)
    return bytes(out)


def read_pokemon(raw):
    personality, _flags, checksum = struct.unpack_from("<IHH", raw, 0)
    blocks = decode(raw[8:136], checksum)
    a, b, c, d = (blocks[32 * i:32 * i + 32] for i in SHUFFLE[((personality & 0x3E000) >> 13) % 24])
    party = decode(raw[136:136 + 100], personality)
    species, item, otid = struct.unpack_from("<HHI", a, 0)
    ivword = struct.unpack_from("<I", b, 0x10)[0]
    return {
        "personality": personality,
        "species": species,
        "item": item,
        "ability": a[0x0D] | ((b[0x19] & 1) << 8),
        "hidden_ability": bool(b[0x19] & 2),
        "evs": list(a[0x10:0x16]),
        "moves": list(struct.unpack_from("<4H", b, 0)),
        "ivs": [(ivword >> (5 * i)) & 31 for i in range(6)],
        "gender": GENDERS[(b[0x18] >> 1) & 3],
        "form": b[0x18] >> 3,
        "ball": d[0x1B],
        "shiny": ((otid >> 16) ^ (otid & 0xFFFF) ^ (personality >> 16) ^ (personality & 0xFFFF)) < 8,
        "level": party[4],
        "stats": list(struct.unpack_from("<6H", party, 8)),  # max HP, Atk, Def, Speed, SpAtk, SpDef
    }


def expected_stats(species_const, level, ivs, evs, nature):
    base = json.load(open(os.path.join(DECOMP, "res", "pokemon", species_const[8:].lower(), "data.json")))["base_stats"]
    base = [base[k] for k in BASE_KEYS]
    stats = [(2 * base[0] + ivs[0] + evs[0] // 4) * level // 100 + level + 10]
    # Natures: rows/columns in the order Atk, Def, Speed, SpAtk, SpDef (game order indices 1..5).
    up, down = nature // 5, nature % 5
    for i in range(1, 6):
        v = (2 * base[i] + ivs[i] + evs[i] // 4) * level // 100 + 5
        if up != down:
            if i - 1 == up:
                v = v * 110 // 100
            elif i - 1 == down:
                v = v * 90 // 100
        stats.append(v)
    return stats


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    rom, xmap, save = sys.argv[1:4]
    trainer_path = sys.argv[4] if len(sys.argv) > 4 else os.path.join(DECOMP, "res", "trainers", "data", "sovereign_test.json")
    trainer = json.load(open(trainer_path))

    species, moves, items = consts("species.txt"), consts("moves.txt"), consts("items.txt")
    natures, abilities = consts("natures.txt"), consts("abilities.txt")

    addr = None
    for line in open(xmap):
        p = line.split()
        if len(p) >= 4 and p[2] == ".text" and p[3] == "Party_AddPokemon":
            addr = int(p[0], 16)
    if addr is None:
        sys.exit("Party_AddPokemon not found in the map")

    from_state = save.endswith(".dst")
    d = Driver(rom, state=save) if from_state else Driver(rom, battery=save)
    added, armed = [], [False]

    def on_add(_a, _s):
        if armed[0]:
            r1 = d.emu.memory.register_arm9.r1
            added.append(bytes(d.emu.memory.unsigned[r1:r1 + 236]))
        return True

    d.emu.memory.register_exec(addr, on_add)
    if not from_state:  # a battery save boots to the title screen: continue the game
        for a in "wait:600 A wait:200 START wait:200 A wait:400".split():
            d.do(a)
    armed[0] = True
    d.do("SELECT+R")
    d.do("wait:600")
    d.do("shot:trainer_battle", os.environ.get("OUT_DIR", "."))

    party = trainer["party"]
    print(f"{len(added)} Pokémon added after SELECT+R; the trainer has {len(party)}")
    failures = 0
    if len(added) != len(party):
        failures += 1

    for i, (raw, want) in enumerate(zip(added, party)):
        got = read_pokemon(raw)
        name = want["species"][8:].title()
        ivs = [31] * 6 if "ivs" in want else [want["iv_scale"] * 31 // 255] * 6
        for k, v in want.get("ivs", {}).items():
            ivs[STATS.index(k)] = v
        evs = [want.get("evs", {}).get(k, 0) for k in STATS]
        nature = got["personality"] % 25
        checks = {
            "species": (species[got["species"]], want["species"]),
            "form": (got["form"], want.get("form", 0)),
            "level": (got["level"], want["level"]),
            "item": (items[got["item"]], want.get("item", "ITEM_NONE")),
            "ivs": (got["ivs"], ivs),
            "evs": (got["evs"], evs),
            "stats": (got["stats"], expected_stats(want["species"], want["level"], ivs, evs, nature)),
        }
        if "moves" in want:
            checks["moves"] = ([moves[m] for m in got["moves"]], (want["moves"] + ["MOVE_NONE"] * 4)[:4])
        if "nature" in want:
            checks["nature"] = (natures[nature], want["nature"])
        if "ability" in want:
            checks["ability"] = (abilities[got["ability"]], want["ability"])
        if "gender" in want:
            checks["gender"] = (got["gender"], want["gender"])
        checks["shiny"] = (got["shiny"], bool(want.get("shiny", False)))
        if "ball" in want:
            checks["ball"] = (items[got["ball"]], want["ball"])

        bad = {k: v for k, v in checks.items() if v[0] != v[1]}
        failures += bool(bad)
        flags = []
        if got["shiny"]:
            flags.append("shiny")
        if got["hidden_ability"]:
            flags.append("hidden ability")
        print(f"{'FAIL' if bad else 'ok  '} {i + 1}. {name} Lv. {got['level']} {got['gender']} "
              f"{natures[nature][7:].title()} {abilities[got['ability']][8:].title()} "
              f"stats {got['stats']} {' '.join(flags)}")
        for k, (g, w) in bad.items():
            print(f"       {k}: got {g}, want {w}")

    print("PASS" if not failures else f"FAIL ({failures})")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
