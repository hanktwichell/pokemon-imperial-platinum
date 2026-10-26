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
    226: "yes: sets Electric Terrain on entry",
    227: "yes: sets Psychic Terrain on entry",
    228: "yes: sets Misty Terrain on entry",
    229: "yes: sets Grassy Terrain on entry",
    289: "yes: sets Electric Terrain on entry; Sp. Atk ×1.33 in it",
    288: "yes: sets harsh sunlight on entry; Attack ×1.33 in it",
    207: "yes: Speed doubled in Electric Terrain",
    179: "yes: Defense ×1.5 in Grassy Terrain",
    282: "yes: in Electric Terrain or after using a Booster Energy, its highest stat ×1.3 (Speed ×1.5)",
    275: "partly: Intimidate raises its Attack instead (immunity to Roar and Whirlwind not yet)",
    181: "yes: contact moves ×1.3",
    178: "yes: pulse moves ×1.5",
    292: "yes: slicing moves ×1.5",
    238: "yes: when a damaging move hits it, every other Pokémon's Speed −1, its ally's too, even as it faints",
    266: "partly: foes can't eat Berries that heal, cure or trigger on a hit, as with Unnerve (damage-halving Berries not yet); Attack +1 for each foe its move knocks out",
    267: "partly: foes can't eat Berries that heal, cure or trigger on a hit, as with Unnerve (damage-halving Berries not yet); Sp. Atk +1 for each foe its move knocks out",
    300: "yes: the first time it enters the battle, each foe's evasiveness −1",
    302: "yes: its damaging moves have a 30% chance to badly poison (Shield Dust stops it)",
    307: "yes: a Pokémon its move poisons or badly poisons becomes confused too",
    213: "yes: no status condition, no drowsiness, Rest fails; counts as asleep for Dream Eater, Nightmare, Hex, Wake-Up Slap, Bad Dreams, Sleep Talk and Snore",
    257: "partly: it can't be poisoned, and a poisoning is healed (its allies' protection not yet)",
    175: "partly: it can't fall asleep or become drowsy, and Rest fails (its allies' protection not yet)",
    167: "partly: when it eats its own held Berry, it also restores a third of its max HP (not yet for a Berry taken by Bug Bite or Pluck, nor a damage-halving Berry)",
    247: "partly: Berries that restore HP restore twice as much, and stat-raising Berries raise 2 stages (damage-halving and other Berries not yet)",
    240: "yes: a stat drop from another Pokémon's move or Ability goes back to that Pokémon (Sticky Web's is only blocked)",
    244: "yes: its sound moves ×1.3, sound damage taken halved",
    274: "yes: wind moves aimed at it do nothing and raise its Attack instead; a tailwind on its side raises its Attack (on entry too)",
    277: "yes: charged when a wind move hits it or a tailwind starts on its side",
    280: "yes: charged when a damaging move hits it (its next Electric move ×2 before the end of next turn, as Platinum's Charge)",
    262: "yes: Electric moves ×1.3",
    263: "yes: Dragon moves ×1.5",
    276: "yes: Rock moves ×1.5",
    200: "yes: Steel moves ×1.5",
    199: "yes: its Water moves ×2, Fire damage taken halved, can't be burned",
    137: "yes: Attack ×1.5 while poisoned",
    138: "yes: Sp. Atk ×1.5 while burned",
    255: "partly: Attack ×1.5 (the move lock not yet)",
    129: "yes: Attack and Sp. Atk halved at half HP or less",
    148: "yes: moves ×1.3 when it moves last",
    252: "yes: Steel moves of the holder and its ally ×1.5",
    281: "yes: in harsh sunlight or after using a Booster Energy, its highest stat ×1.3 (Speed ×1.5)",
    136: "yes: damage halved at full HP",
    231: "yes: damage halved at full HP (not ignored by Mold Breaker)",
    169: "yes: Defense doubled",
    246: "yes: special damage halved",
    272: "yes: Ghost damage halved; no status conditions or drowsiness (Mold Breaker gets past it)",
    284: "yes: Sp. Atk of every other Pokémon ×0.75",
    285: "yes: Defense of every other Pokémon ×0.75",
    286: "yes: Attack of every other Pokémon ×0.75",
    287: "yes: Sp. Def of every other Pokémon ×0.75",
    186: "yes: Dark moves on the field ×1.33",
    187: "yes: Fairy moves on the field ×1.33",
    188: "yes: reverses the Auras (×0.75)",
    232: "yes: super-effective damage ×0.75 (not ignored by Mold Breaker)",
    233: "yes: super-effective moves ×1.25",
    177: "yes: Flying moves +1 priority at full HP",
    205: "yes: healing moves +3 priority",
    214: "yes: foes' priority moves can't hit its side",
    219: "yes: foes' priority moves can't hit its side",
    296: "yes: foes' priority moves can't hit its side",
    230: "yes: other Pokémon can't lower its stats (as Clear Body, not ignored by Mold Breaker)",
    196: "yes: always a critical hit on a poisoned target",
    147: "yes: status moves aimed at it are at most 50% accurate",
    182: "yes: Normal moves become Fairy-type, ×1.2",
    174: "yes: Normal moves become Ice-type, ×1.2",
    184: "yes: Normal moves become Flying-type, ×1.2",
    206: "yes: Normal moves become Electric-type, ×1.2",
    309: "yes: Normal moves become Dragon-type, ×1.2",
    204: "yes: sound moves become Water-type",
    130: "yes: 30% chance to disable the move that hit it, for 4 turns",  # Cursed Body
    141: "yes: each turn, one stat +2 and another −1 (no accuracy/evasion, as in Gen VIII+)",  # Moody
    143: "yes: its contact moves have a 30% chance to poison",  # Poison Touch
    127: "partly: foes can't eat Berries that heal, cure or trigger on a hit (damage-halving Berries not yet)",  # Unnerve
    128: "yes: Attack +2 when a foe's move or Intimidate lowers its stats",  # Defiant
    172: "yes: Sp. Atk +2 when a foe's move or Intimidate lowers its stats",  # Competitive
    160: "yes: contact costs the attacker 1/8 of its max HP (as Rough Skin)",  # Iron Barbs
    183: "yes: a contact move lowers the attacker's Speed 1 stage",  # Gooey
    221: "yes: a contact move lowers the attacker's Speed 1 stage",  # Tangling Hair
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
    151: "partly: ignores Reflect, Light Screen and Substitute (Safeguard and Mist not yet)",  # Infiltrator
    171: "yes: immune to ball and bomb moves",  # Bulletproof
    218: "yes: contact damage halved, Fire damage doubled",  # Fluffy
    133: "yes: Defense −1 and Speed +2 when hit by a physical move",  # Weak Armor
    142: "partly: no sandstorm damage (powder-move immunity not yet)",  # Overcoat
    144: "yes: restores 1/3 of max HP on switching out",  # Regenerator
    145: "yes: Defense can't be lowered by others",  # Big Pecks
    146: "yes: Speed ×2 in a sandstorm; no sandstorm damage",  # Sand Rush
    154: "yes: Attack +1 when hit by a Dark move",  # Justified
    155: "yes: Speed +1 when hit by a Bug, Ghost or Dark move, or when Intimidated",  # Rattled
    158: "yes: status moves +1 priority; they don't affect Dark-type foes",  # Prankster
    159: "yes: Rock/Ground/Steel moves ×1.3 in a sandstorm; no sandstorm damage",  # Sand Force
    173: "yes: biting moves ×1.5",  # Strong Jaw
    195: "yes: Defense +2 when hit by a Water move",  # WaterCompaction
    202: "yes: Speed ×2 in snow",  # Slush Rush
    270: "yes: Attack +1 when hit by a Fire move, can't be burned",  # ThermalExchange
    157: "yes: absorbs Grass moves, Attack +1 (`BattleSystem_TriggerImmunityAbility`)",  # Sap Sipper
    192: "yes: Defense +1 stage each time a damaging move hits (`BattleSystem_TriggerAbilityOnHit`)",  # Stamina
    273: "yes: absorbs Fire moves, Defense +2 (`BattleSystem_TriggerImmunityAbility`)",  # Well-Baked Body
    297: "yes: absorbs Ground moves, restores 1/4 of max HP (`BattleSystem_TriggerImmunityAbility`)",  # Earth Eater
    156: "yes: reflects status moves aimed at it",
    162: "yes: accuracy ×1.1 for it and its ally",
    163: "yes: ignores the target's ability, like Mold Breaker",
    164: "yes: ignores the target's ability, like Mold Breaker",
    168: "yes: becomes its move's type, once per switch-in",
    234: "yes: Attack +1 the first time it enters battle",
    235: "yes: Defense +1 the first time it enters battle",
    236: "yes: becomes its move's type, once per switch-in",
    243: "yes: Fire or Water hits raise Speed 6 stages",
    260: "yes: contact moves go through protection",
    269: "yes: getting hit sets Grassy Terrain",
    283: "yes: immune to other Pokémon's status moves",
    293: "yes: 10% more power per fainted party member (up to 5)",
    298: "partly: its status moves ignore abilities (moving last not yet)",
    299: "yes: hits Ghost types with Normal and Fighting moves, ignores evasion, accuracy can't be lowered",
    198: "yes: double power against a target that switched in this turn",
    203: "yes: its moves make no contact",
    212: "yes: can poison Steel and Poison types",
    217: "yes: its ally's special moves ×1.3",
    239: "yes: ignores moves and abilities that draw in attacks",
    242: "yes: ignores moves and abilities that draw in attacks",
    245: "yes: getting hit whips up a sandstorm",
    249: "yes: its ally's moves ×1.3",
    251: "yes: removes Reflect, Light Screen and Aurora Veil on entry",
    189: "yes: heavy rain while it's in battle; Fire moves fizzle, other weather can't start",
    190: "yes: extremely harsh sun while it's in battle; Water moves evaporate, other weather can't start",
    191: "yes: strong winds while it's in battle; no move is super effective on Flying types",
    185: "yes: single-target damaging moves hit twice, the second hit at 1/4 damage",
    201: "yes: Sp. Atk +1 when a hit drops it to half HP or less",
    271: "yes: Attack, Sp. Atk, Speed +1 and Defense, Sp. Def -1 when a hit drops it to half HP or less",
    215: "yes: when knocked out by a hit, the attacker loses the HP it had left",
    308: "yes: contact moves go through protection at 1/4 damage",
    310: "partly: its moves work as in harsh sunlight (damage, Solar Beam without charging; Weather Ball, Growth, Synthesis not yet)",
    311: "yes: burns the attacker whenever a damaging move hits it",
    312: "yes: Levitate, and a knockout raises its highest stat (from one source; check against official data)",
    313: "yes: Fire moves ×1.5",
    314: "yes: contact damage taken halved",
    131: "yes: 30% chance each turn to cure its ally's status",
    152: "yes: an attacker that makes contact gets Mummy",
    268: "yes: an attacker that makes contact gets Lingering Aroma",
    254: "yes: swaps abilities with an attacker that makes contact",
    253: "yes: contact gives it and the attacker a Perish Song count of 3",
    295: "yes: physical hits scatter Toxic Spikes on the attacker's side",
    # The form-changing abilities (milestone FM, docs/TechnicalDesign.md §4b).
    161: "yes: Zen Mode at half HP or less (Darmanitan, Galarian Darmanitan)",  # Zen Mode
    176: "yes: Blade Forme before a damaging move, Shield Forme before King's Shield",  # Stance Change
    197: "yes: Core at half HP or less; the Meteor Form blocks status and Yawn",  # Shields Down
    208: "yes: School Form at level 20+ with over 1/4 HP",  # Schooling
    209: "yes: takes one hit for 1/8 of its max HP, once per battle",  # Disguise
    211: "yes: Complete Forme at half HP or less, with its higher max HP",  # Power Construct
    258: "yes: switches between Full Belly and Hangry Mode at the end of each turn",  # Hunger Switch
    278: "yes: Hero Form once it switches out, until the battle ends",  # Zero to Hero
    210: "yes: Ash-Greninja after its move knocks out a foe, until the battle ends",  # Battle Bond
    248: "yes: takes one physical hit; snow brings the ice back",  # Ice Face
    241: "yes: Surf or Dive catches prey; a hit spits it for 1/4 HP and Defense -1 or paralysis",  # Gulp Missile
    304: "yes: Terastal Form as it enters battle, until the battle ends",  # Tera Shift
    305: "yes: at full HP, damaging moves are not very effective on it",  # Tera Shell
    225: "yes: Silvally takes its held Memory's type (and form)",  # RKS System
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
