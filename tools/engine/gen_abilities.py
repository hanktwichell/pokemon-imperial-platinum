#!/usr/bin/env python3
"""Generate Sovereign Platinum's Gen IX ability list for the decomp (milestone E2).

Ability ID = official ability number (1-314, including the Legends: Z-A Mega abilities). Writes
decomp/generated/abilities.txt, the three ability text banks (names, uppercase names, descriptions) and
docs/AbilityChecklist.md. Platinum's 123 abilities keep their names, descriptions and battle behaviour; the new ones
are registered with names and descriptions but have no battle effect until they are implemented (the checklist
tracks which).

Usage: python3 tools/engine/gen_abilities.py /path/to/pokeapi/data/v2/csv
"""
import csv
import json
import os
import re
import sys
import textwrap

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
TEXT = os.path.join(DECOMP, "res", "text")
LAST_VANILLA = 123
LAST_ABILITY = 314
EN = "9"
# Names longer than 15 characters, shortened Gen V-style.
SHORT_NAMES = {
    "Water Compaction": "WaterCompaction", "Power of Alchemy": "PowerOfAlchemy", "Dauntless Shield": "DauntlessShield",
    "Wandering Spirit": "WanderingSpirit", "Neutralizing Gas": "NeutralizingGas", "Curious Medicine": "CuriousMedicine",
    "Thermal Exchange": "ThermalExchange", "Electromorphosis": "Electromorphsis", "Orichalcum Pulse": "OrichalcumPulse",
    "Supreme Overlord": "SupremeOverlord", "Supersweet Syrup": "SupersweetSyrup", "Poison Puppeteer": "PoisonPuppeteer",
}
# Written for the 79 abilities whose official text doesn't fit two 26-character lines.
MANUAL_DESCRIPTIONS = {
    165: 'Protects allies from moves that limit moves.',
    166: 'Stops stat drops on allied Grass types.',
    168: 'Changes type to the type of the move used.',
    170: 'Steals the foe’s item when hitting it.',
    176: 'Switches forme to attack or to defend.',
    183: 'Contact lowers the attacker’s Speed.',
    189: 'Summons heavy rain that stops Fire moves.',
    190: 'Summons harsh sun that stops Water moves.',
    191: 'Summons winds that protect Flying types.',
    193: 'Switches out when HP falls below half.',
    194: 'Switches out when HP falls below half.',
    195: 'Water moves sharply raise its Defense.',
    196: 'Always lands critical hits on poisoned foes.',
    197: 'Changes form at half HP; blocks status.',
    198: 'Doubles damage to a foe that switched in.',
    199: 'Halves Fire damage and boosts Water moves.',
    208: 'Forms a school when it has over 25% HP.',
    210: 'Becomes stronger after knocking out a foe.',
    211: 'Changes to Complete Forme at half HP.',
    212: 'Can poison even Steel and Poison types.',
    215: 'Fainting hurts the foe by its remaining HP.',
    216: 'Copies dance moves used by other Pokémon.',
    221: 'Contact lowers the attacker’s Speed.',
    224: 'KOs raise the user’s highest stat.',
    225: 'Changes type to match its held Memory.',
    226: 'Sets Electric Terrain on entering battle.',
    227: 'Sets Psychic Terrain on entering battle.',
    228: 'Sets Misty Terrain on entering battle.',
    229: 'Sets Grassy Terrain on entering battle.',
    231: 'Halves damage taken while at full HP.',
    236: 'Changes type to the type of the move used.',
    237: 'Fetches the first failed Poké Ball.',
    238: 'Getting hit lowers all others’ Speed.',
    239: 'Ignores moves that draw in attacks.',
    241: 'Surf or Dive catches prey to spit back.',
    242: 'Ignores moves that draw in attacks.',
    243: 'Fire or Water hits drastically raise Speed.',
    248: 'Its ice face takes one physical hit.',
    251: 'Removes all screens on entering battle.',
    253: 'Contact makes both faint in three turns.',
    255: 'Boosts Attack but locks it into one move.',
    257: 'Protects itself and allies from poison.',
    258: 'Switches between modes every turn.',
    265: 'KOs raise the user’s Sp. Atk.',
    266: 'Has the effects of Unnerve and its Neigh.',
    268: 'Contact gives the attacker this ability.',
    269: 'Getting hit sets Grassy Terrain.',
    271: 'At half HP, boosts offense and lowers defense.',
    272: 'Blocks status and halves Ghost damage.',
    273: 'Fire moves sharply raise Defense instead.',
    274: 'Wind moves raise Attack instead of hitting.',
    275: 'Intimidate raises Attack; can’t be forced out.',
    277: 'Wind hits charge up its next Electric move.',
    279: 'Hides inside an allied Dondozo.',
    280: 'Getting hit charges its next Electric move.',
    281: 'Sun or Booster Energy raises its best stat.',
    282: 'Terrain or Booster Energy raises best stat.',
    288: 'Sets harsh sun and boosts its Attack in it.',
    289: 'Sets Electric Terrain and boosts Sp. Atk.',
    291: 'Eats a used Berry again the next turn.',
    295: 'Physical hits scatter Toxic Spikes.',
    296: 'Foes can’t use priority moves against it.',
    298: 'Status moves go last but ignore abilities.',
    299: 'Hits Ghost types and ignores evasion.',
    300: 'Lowers foes’ evasion on entering battle.',
    301: 'Restores some HP to an ally on entering.',
    302: 'Its moves may badly poison the target.',
    303: 'Boosts a stat based on Ogerpon’s mask.',
    304: 'Changes into its Terastal Form in battle.',
    305: 'Hits are not very effective at full HP.',
    306: 'Clears weather and terrain in Stellar Form.',
    307: 'Poison from its moves also confuses.',
    308: 'Contact moves hit through protection.',
    309: 'Normal moves become boosted Dragon moves.',
    310: 'Its moves act as if the sun were harsh.',
    311: 'Burns attackers that damage it.',
    312: 'Floats, so it is immune to Ground moves.',
    313: 'Boosts the power of its Fire moves.',
    314: 'Takes half damage from contact moves.',
}
# Implemented beyond Platinum's 123 (updated as abilities get battle code).
# Newer abilities whose battle effect is built (item 11): ability number -> what the Battle effect column says.
IMPLEMENTED = {
    153: "yes: Attack +1 for each foe its move knocks out",  # Moxie
    224: "yes: its highest stat +1 for each foe its move knocks out",  # Beast Boost
    264: "yes: Attack +1 for each foe its move knocks out",  # Chilling Neigh
    265: "yes: Sp. Atk +1 for each foe its move knocks out",  # Grim Neigh
    125: "yes: moves with a chance effect ×1.3, without the effect (or Life Orb recoil)",  # Sheer Force
    126: "yes: stat rises and drops are reversed",  # Contrary
    132: "yes: the partner takes 25% less damage",  # Friend Guard
    134: "yes: weight doubled (Low Kick, Grass Knot)",  # Heavy Metal
    135: "yes: weight halved (Low Kick, Grass Knot)",  # Light Metal
    140: "yes: avoids its partner's damaging moves",  # Telepathy
    151: "partly: ignores Reflect and Light Screen (Substitute, Safeguard and Mist not yet)",  # Infiltrator
    171: "yes: immune to ball and bomb moves",  # Bulletproof
    218: "yes: contact damage halved, Fire damage doubled",  # Fluffy
    133: "yes: Defense −1 and Speed +2 when hit by a physical move",  # Weak Armor
    142: "partly: no sandstorm damage (powder-move immunity not yet)",  # Overcoat
    144: "yes: restores 1/3 of max HP on switching out",  # Regenerator
    145: "yes: Defense can't be lowered by others",  # Big Pecks
    146: "yes: Speed ×2 in a sandstorm; no sandstorm damage",  # Sand Rush
    154: "yes: Attack +1 when hit by a Dark move",  # Justified
    155: "partly: Speed +1 when hit by a Bug, Ghost or Dark move (the Intimidate trigger not yet)",  # Rattled
    158: "yes: status moves +1 priority; they don't affect Dark-type foes",  # Prankster
    159: "yes: Rock/Ground/Steel moves ×1.3 in a sandstorm; no sandstorm damage",  # Sand Force
    173: "yes: biting moves ×1.5",  # Strong Jaw
    195: "yes: Defense +2 when hit by a Water move",  # WaterCompaction
    202: "yes: Speed ×2 in snow",  # Slush Rush
    270: "partly: Attack +1 when hit by a Fire move (burn immunity not yet)",  # ThermalExchange
    157: "yes: absorbs Grass moves, Attack +1 (`BattleSystem_TriggerImmunityAbility`)",  # Sap Sipper
    192: "yes: Defense +1 stage each time a damaging move hits (`BattleSystem_TriggerAbilityOnHit`)",  # Stamina
    273: "yes: absorbs Fire moves, Defense +2 (`BattleSystem_TriggerImmunityAbility`)",  # Well-Baked Body
    297: "yes: absorbs Ground moves, restores 1/4 of max HP (`BattleSystem_TriggerImmunityAbility`)",  # Earth Eater
}


def rd(api, name):
    with open(os.path.join(api, name), newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def clean(t):
    t = re.sub(r"\s+", " ", t).strip()
    # Platinum's charmap has curly quotes, … and × but no straight double quote.
    for a, b in (("—", "-"), ("–", "-"), ("‘", "’"), ("'", "’")):
        t = t.replace(a, b)
    parts = t.split('"')
    return "".join(p + ("“" if i % 2 == 0 else "”") if i < len(parts) - 1 else p for i, p in enumerate(parts))


def describe(texts, width=26, lines=2):
    for t in texts:
        for cand in (t, re.split(r"(?<=[.!?]) ", t)[0]):
            w = textwrap.wrap(cand, width)
            if len(w) <= lines:
                return w
    # Nothing fits: keep the first sentence up to a clause break, never ending on a dangling word.
    words = re.split(r"(?<=[.!?]) ", texts[0])[0].split()
    while words:
        w = textwrap.wrap(" ".join(words), width)
        if len(w) <= lines and words[-1].lower().strip(",;:") not in DANGLING:
            w[-1] = w[-1].rstrip(",;:") + ("" if w[-1].endswith(".") else ".")
            TRIMMED.append(texts[0])
            return w
        words = words[:-1]
    return [texts[0][:width]]


DANGLING = {"a", "an", "the", "of", "to", "from", "by", "with", "and", "or", "in", "on", "for", "its", "that", "when",
            "if", "is", "are", "be", "can", "it", "as", "at", "but", "than"}
TRIMMED = []


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    api = sys.argv[1]
    abilities = {int(r["id"]): r for r in rd(api, "abilities.csv") if int(r["id"]) <= LAST_ABILITY}
    names = {int(r["ability_id"]): r["name"] for r in rd(api, "ability_names.csv") if r["local_language_id"] == EN}
    short = {int(r["ability_id"]): clean(re.sub(r"\[([^\]]*)\]\{[^}]*\}", r"\1", r["short_effect"]))
             for r in rd(api, "ability_prose.csv") if r["local_language_id"] == EN}
    flavor = {}
    for r in rd(api, "ability_flavor_text.csv"):
        if r["language_id"] == EN:
            flavor.setdefault(int(r["ability_id"]), {})[int(r["version_group_id"])] = clean(r["flavor_text"])

    consts = [l.strip() for l in open(os.path.join(DECOMP, "generated", "abilities.txt")) if l.strip()][:LAST_VANILLA + 1]
    for i in range(1, LAST_VANILLA + 1):
        assert consts[i] == "ABILITY_" + abilities[i]["identifier"].upper().replace("-", "_"), (i, consts[i])

    banks = {}
    for stem in ("ability_names", "ability_names_uppercase", "ability_descriptions"):
        path = os.path.join(TEXT, stem + ".json")
        d = json.load(open(path, encoding="utf-8"))
        d["messages"] = d["messages"][:LAST_VANILLA + 1]
        banks[stem] = (path, d, d["messages"][1]["id"].rsplit("_", 1)[0])

    rows = []
    for i in range(LAST_VANILLA + 1, LAST_ABILITY + 1):
        ident = abilities[i]["identifier"]
        consts.append("ABILITY_" + re.sub(r"[^A-Z0-9]+", "_", ident.upper()).strip("_"))
        name = SHORT_NAMES.get(names[i], names[i])
        assert len(name) <= 15, name
        texts = [flavor[i][g] for g in sorted(flavor.get(i, {}), reverse=True)]
        texts += [t for t in (short.get(i),) if t] or ([] if texts else [name + "."])
        desc = textwrap.wrap(MANUAL_DESCRIPTIONS[i], 26) if i in MANUAL_DESCRIPTIONS else describe(texts)
        for stem, value in (("ability_names", name), ("ability_names_uppercase", name.upper()),
                            ("ability_descriptions", [l + "\n" for l in desc[:-1]] + [desc[-1]])):
            path, d, prefix = banks[stem]
            d["messages"].append({"id": f"{prefix}_{i:05d}", "en_US": value})
        rows.append((i, name, f"Gen {abilities[i]['generation_id']}", IMPLEMENTED.get(i, "not yet (no battle effect)")))

    assert len(consts) == LAST_ABILITY + 1 and len(set(consts)) == len(consts)
    with open(os.path.join(DECOMP, "generated", "abilities.txt"), "w") as f:
        f.write("\n".join(consts) + "\n")
    for path, d, _ in banks.values():
        with open(path, "w", encoding="utf-8") as f:
            f.write(json.dumps(d, indent=2, ensure_ascii=False) + "\n")

    L = ["# Sovereign Platinum — Ability Checklist", "",
         "> Generated by `tools/engine/gen_abilities.py` from PokeAPI. Edit the generator, not this file.", "",
         f"Ability ID = official ability number. Platinum's {LAST_VANILLA} abilities keep their Gen IV battle behaviour. "
         f"The {LAST_ABILITY - LAST_VANILLA} newer abilities have names and descriptions; the **Battle effect** column says "
         "which already work in battle.", "",
         "| # | Ability | Introduced | Battle effect |", "|---|---|---|---|"]
    L += [f"| {a} | {b} | {c} | {d} |" for a, b, c, d in rows]
    with open(os.path.join(ROOT, "docs", "AbilityChecklist.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print(f"abilities: {LAST_ABILITY}; new {len(rows)}; implemented new: {len(IMPLEMENTED)}; descriptions trimmed: {len(TRIMMED)}")


if __name__ == "__main__":
    main()
