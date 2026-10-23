#!/usr/bin/env python3
"""Add Sovereign's alternate forms to the decomp: the 99 Mega Evolutions and Primal Reversions (milestone E8), and the
forms of milestone FM built so far (FM_FORMS below, from data/forms.csv).

Platinum packs alternate-form data after every species (tools/dataproc/src/speciesproc.c, altFormsWithData). This
script appends Sovereign's forms to that list and writes everything that follows the list's order:
  res/pokemon/<species>/forms/<form>/data.json   stats, types and abilities from data/megas.csv or data/forms.csv,
                                                 learnsets and evolutions as below; everything else is the base
                                                 species'
  res/pokemon/<species>/meson.build              the form's data.json, inside a generator-owned block
  tools/dataproc/src/sovereign_forms.inc         the entries speciesproc appends to altFormsWithData
  include/constants/sovereign_forms.h            SOVEREIGN_FORM_COUNT and where the forms start
  include/data/sovereign_forms.h                 species, form number and trigger of each form, in packing order
                                                 (src/pokemon.c maps a species and form to its data with it)

Form numbers: a species' FM forms are numbered from 1 in FM_FORMS order, which follows the official games (Ogerpon:
1 = Wellspring, 2 = Hearthflame, 3 = Cornerstone, as in Scarlet and Violet). Its Megas come after them, in
data/megas.csv order (Charizard: 1 = Mega X, 2 = Mega Y). An FM form's number is saved with the Pokemon; a Mega only
exists in battle, so its number never is. Numbering the Megas last means adding a Mega can't change a saved number.

FM forms: an item form keeps its own abilities (they're what the form has for good), whether or not the battle engine
has their effects yet (item 11 adds them).

Abilities: a Mega gets its own ability only when the battle engine has it (a Gen IV ability, or a newer one in
gen_abilities.IMPLEMENTED).
Otherwise its data lists no ability and the battle keeps the Pokémon's own ability (docs/MegaEvolution.md).

Sprites and icons: none yet. Platinum's sprite and icon code ignores the form of these species, so a Mega shows
its base species until milestone E12 adds the art.

Learnsets: an FM form gets its own Gen IX learnset from PokeAPI (tools/engine/gen_species_gen9.py); a Mega keeps its
base species'. Evolutions: a regional form evolves like its base species or as REGIONAL_EVOLUTIONS says.

Usage: python3 tools/engine/gen_forms.py /path/to/pokeapi/data/v2/csv   (rerun after editing data/megas.csv)
"""
import copy
import csv
import json
import os
import re
import sys

import yaml

sys.path.insert(0, os.path.dirname(__file__))
from gen_items import DECOMP, ROOT, stem_of  # noqa: E402
import gen_species_gen9 as gen9  # noqa: E402
from gen_abilities import IMPLEMENTED as IMPLEMENTED_ABILITIES, LAST_VANILLA as LAST_VANILLA_ABILITY  # noqa: E402

ABILITY_IDS = {c: i for i, c in enumerate(open(os.path.join(DECOMP, "generated", "abilities.txt"), encoding="utf-8").read().split())}


def engine_has_ability(const):
    """True for Platinum's own abilities and the newer ones the battle engine implements (gen_abilities.IMPLEMENTED)."""
    i = ABILITY_IDS.get(const)
    return i is not None and (i <= LAST_VANILLA_ABILITY or i in IMPLEMENTED_ABILITIES)

POKEMON = os.path.join(DECOMP, "res", "pokemon")
MESON_START = "# Sovereign forms (tools/engine/gen_forms.py): start"
MESON_END = "# Sovereign forms: end"
VANILLA_FORMS_WITH_DATA = 12  # Deoxys x3, Wormadam x2, Giratina, Shaymin, Rotom x5 (speciesproc.c)

KIND_MEGA, KIND_PRIMAL, KIND_MEGA_BY_MOVE = "SOVEREIGN_FORM_MEGA", "SOVEREIGN_FORM_PRIMAL", "SOVEREIGN_FORM_MEGA_BY_MOVE"
KIND_HELD_ITEM, KIND_BATTLE_ITEM = "SOVEREIGN_FORM_HELD_ITEM", "SOVEREIGN_FORM_BATTLE_ITEM"
KIND_KEY_ITEM, KIND_FUSION = "SOVEREIGN_FORM_KEY_ITEM", "SOVEREIGN_FORM_FUSION"
KIND_REGIONAL, KIND_BATTLE = "SOVEREIGN_FORM_REGIONAL", "SOVEREIGN_FORM_BATTLE"
KIND_TOTEM = "SOVEREIGN_FORM_TOTEM"
MEGA_BY_MOVE = {"Dragon Ascent (move; no stone)": "MOVE_DRAGON_ASCENT"}  # Mega Rayquaza

# Milestone FM forms built so far: PokeAPI identifier (data/forms.csv) -> (kind, the item that gives the form).
#   SOVEREIGN_FORM_HELD_ITEM    the form follows the held item, out of battle too (Ogerpon's masks, Origin Dialga/Palkia)
#   SOVEREIGN_FORM_BATTLE_ITEM  the Pokemon takes the form in battle while holding the item (Crowned Zacian/Zamazenta)
#   SOVEREIGN_FORM_KEY_ITEM     using the key item on the Pokemon switches it in and out of the form (Reveal Glass)
#   SOVEREIGN_FORM_FUSION       the fusion item fuses the Pokemon with this partner species (src/sovereign_form_items.c)
#   SOVEREIGN_FORM_REGIONAL     a form the Pokemon has for good: the regional forms, and Basculin's stripes. It evolves
#                               into its region's form and passes to its Eggs (REGIONAL_EVOLUTIONS, baby forms below)
#   SOVEREIGN_FORM_BATTLE       a form its ability gives it in battle (Zen Mode); the trigger is the ability. Data only so
#                               far, which keeps the official numbers of the forms after it (Galarian Darmanitan: 2)
#   SOVEREIGN_FORM_TOTEM        a Totem Pokemon's form (decision 18), caught after its trial (data/totem_trials.yaml)
#                               and kept for good. It doesn't evolve
# A species' forms are numbered in this order, after its Megas, as in the official games (Kyurem: 1 White, 2 Black).
FM_FORMS = {
    "zacian-crowned": (KIND_BATTLE_ITEM, "ITEM_RUSTED_SWORD"),
    "zamazenta-crowned": (KIND_BATTLE_ITEM, "ITEM_RUSTED_SHIELD"),
    "ogerpon-wellspring-mask": (KIND_HELD_ITEM, "ITEM_WELLSPRING_MASK"),
    "ogerpon-hearthflame-mask": (KIND_HELD_ITEM, "ITEM_HEARTHFLAME_MASK"),
    "ogerpon-cornerstone-mask": (KIND_HELD_ITEM, "ITEM_CORNERSTONE_MASK"),
    "dialga-origin": (KIND_HELD_ITEM, "ITEM_ADAMANT_CRYSTAL"),
    "palkia-origin": (KIND_HELD_ITEM, "ITEM_LUSTROUS_GLOBE"),
    "tornadus-therian": (KIND_KEY_ITEM, "ITEM_REVEAL_GLASS"),
    "thundurus-therian": (KIND_KEY_ITEM, "ITEM_REVEAL_GLASS"),
    "landorus-therian": (KIND_KEY_ITEM, "ITEM_REVEAL_GLASS"),
    "enamorus-therian": (KIND_KEY_ITEM, "ITEM_REVEAL_GLASS"),
    "hoopa-unbound": (KIND_KEY_ITEM, "ITEM_PRISON_BOTTLE"),
    "kyurem-white": (KIND_FUSION, "SPECIES_RESHIRAM"),
    "kyurem-black": (KIND_FUSION, "SPECIES_ZEKROM"),
    "necrozma-dusk": (KIND_FUSION, "SPECIES_SOLGALEO"),
    "necrozma-dawn": (KIND_FUSION, "SPECIES_LUNALA"),
    "calyrex-ice": (KIND_FUSION, "SPECIES_GLASTRIER"),
    "calyrex-shadow": (KIND_FUSION, "SPECIES_SPECTRIER"),
    # The regional forms (decision 16), in the official form order of each species.
    "rattata-alola": (KIND_REGIONAL, "0"), "raticate-alola": (KIND_REGIONAL, "0"), "raichu-alola": (KIND_REGIONAL, "0"),
    "sandshrew-alola": (KIND_REGIONAL, "0"), "sandslash-alola": (KIND_REGIONAL, "0"),
    "vulpix-alola": (KIND_REGIONAL, "0"), "ninetales-alola": (KIND_REGIONAL, "0"),
    "diglett-alola": (KIND_REGIONAL, "0"), "dugtrio-alola": (KIND_REGIONAL, "0"),
    "meowth-alola": (KIND_REGIONAL, "0"), "meowth-galar": (KIND_REGIONAL, "0"), "persian-alola": (KIND_REGIONAL, "0"),
    "geodude-alola": (KIND_REGIONAL, "0"), "graveler-alola": (KIND_REGIONAL, "0"), "golem-alola": (KIND_REGIONAL, "0"),
    "grimer-alola": (KIND_REGIONAL, "0"), "muk-alola": (KIND_REGIONAL, "0"),
    "exeggutor-alola": (KIND_REGIONAL, "0"), "marowak-alola": (KIND_REGIONAL, "0"),
    "ponyta-galar": (KIND_REGIONAL, "0"), "rapidash-galar": (KIND_REGIONAL, "0"),
    "slowpoke-galar": (KIND_REGIONAL, "0"), "slowbro-galar": (KIND_REGIONAL, "0"), "slowking-galar": (KIND_REGIONAL, "0"),
    "farfetchd-galar": (KIND_REGIONAL, "0"), "weezing-galar": (KIND_REGIONAL, "0"), "mr-mime-galar": (KIND_REGIONAL, "0"),
    "articuno-galar": (KIND_REGIONAL, "0"), "zapdos-galar": (KIND_REGIONAL, "0"), "moltres-galar": (KIND_REGIONAL, "0"),
    "corsola-galar": (KIND_REGIONAL, "0"),
    "zigzagoon-galar": (KIND_REGIONAL, "0"), "linoone-galar": (KIND_REGIONAL, "0"),
    "darumaka-galar": (KIND_REGIONAL, "0"),
    "darmanitan-zen": (KIND_BATTLE, "ABILITY_ZEN_MODE"), "darmanitan-galar-standard": (KIND_REGIONAL, "0"),
    "darmanitan-galar-zen": (KIND_BATTLE, "ABILITY_ZEN_MODE"),
    "yamask-galar": (KIND_REGIONAL, "0"), "stunfisk-galar": (KIND_REGIONAL, "0"),
    "growlithe-hisui": (KIND_REGIONAL, "0"), "arcanine-hisui": (KIND_REGIONAL, "0"),
    "voltorb-hisui": (KIND_REGIONAL, "0"), "electrode-hisui": (KIND_REGIONAL, "0"),
    "typhlosion-hisui": (KIND_REGIONAL, "0"), "qwilfish-hisui": (KIND_REGIONAL, "0"), "sneasel-hisui": (KIND_REGIONAL, "0"),
    "samurott-hisui": (KIND_REGIONAL, "0"), "lilligant-hisui": (KIND_REGIONAL, "0"),
    "basculin-blue-striped": (KIND_REGIONAL, "0"), "basculin-white-striped": (KIND_REGIONAL, "0"),
    "zorua-hisui": (KIND_REGIONAL, "0"), "zoroark-hisui": (KIND_REGIONAL, "0"), "braviary-hisui": (KIND_REGIONAL, "0"),
    "sliggoo-hisui": (KIND_REGIONAL, "0"), "goodra-hisui": (KIND_REGIONAL, "0"), "avalugg-hisui": (KIND_REGIONAL, "0"),
    "decidueye-hisui": (KIND_REGIONAL, "0"),
    "tauros-paldea-combat-breed": (KIND_REGIONAL, "0"), "tauros-paldea-blaze-breed": (KIND_REGIONAL, "0"),
    "tauros-paldea-aqua-breed": (KIND_REGIONAL, "0"), "wooper-paldea": (KIND_REGIONAL, "0"),
    # The Totem forms (decision 18). Mimikyu's Busted Form is data only for now, like Zen Darmanitan, so the Totem
    # forms keep their official numbers (Totem Disguised: 2, Totem Busted: 3).
    "raticate-totem-alola": (KIND_TOTEM, "0"), "marowak-totem": (KIND_TOTEM, "0"),
    "gumshoos-totem": (KIND_TOTEM, "0"), "vikavolt-totem": (KIND_TOTEM, "0"), "ribombee-totem": (KIND_TOTEM, "0"),
    "araquanid-totem": (KIND_TOTEM, "0"), "lurantis-totem": (KIND_TOTEM, "0"), "salazzle-totem": (KIND_TOTEM, "0"),
    "togedemaru-totem": (KIND_TOTEM, "0"), "mimikyu-busted": (KIND_BATTLE, "ABILITY_DISGUISE"),
    "mimikyu-totem-disguised": (KIND_TOTEM, "0"), "mimikyu-totem-busted": (KIND_TOTEM, "0"),
    "kommo-o-totem": (KIND_TOTEM, "0"),
}

# A Totem form learns what its usual form learns (PokeAPI only has the Totems' old Ultra Sun/Ultra Moon learnsets):
# its regional form's, or else the species' own (the base data.json).
TOTEM_USUAL_FORMS = {"raticate-totem-alola": "raticate-alola", "marowak-totem": "marowak-alola"}

# Regional evolutions and Egg forms: data/evolution_changes.yaml (regional_forms, regional_parents).
_EVOLUTION_CHANGES = yaml.safe_load(open(os.path.join(ROOT, "data", "evolution_changes.yaml"), encoding="utf-8"))
REGIONAL_EVOLUTIONS = {e["form"]: e["evolutions"] for e in _EVOLUTION_CHANGES["regional_forms"]}
REGIONAL_PARENTS = _EVOLUTION_CHANGES["regional_parents"]

# PokeAPI names both of Calyrex's fused abilities "As One"; the decomp has one per form.
ABILITY_OVERRIDES = {"calyrex-ice": ["ABILITY_AS_ONE_GLASTRIER"], "calyrex-shadow": ["ABILITY_AS_ONE_SPECTRIER"]}


def form_dir(form, species):
    """'Mega Charizard X' -> 'mega_x', 'Primal Kyogre' -> 'primal', 'Mega Tatsugiri (Curly Form)' -> 'mega_curly'."""
    kind = "primal" if form.startswith("Primal ") else "mega"
    rest = form.split(" ", 1)[1]
    rest = rest[len(species):] if rest.startswith(species) else rest
    rest = re.sub(r"\b(Form|Color)\b", "", rest)
    suffix = stem_of(rest.replace("(", " ").replace(")", " "))
    return f"{kind}_{suffix}" if suffix else kind


def type_const(name):
    return "TYPE_" + name.strip().upper()


def load_rows():
    rows = list(csv.DictReader(open(os.path.join(ROOT, "data", "megas.csv"), encoding="utf-8")))
    symbols = {name: set(open(os.path.join(DECOMP, "generated", f"{name}.txt"), encoding="utf-8").read().split())
               for name in ("items", "abilities", "species", "moves")}
    fm_rows = {r["identifier"]: r for r in csv.DictReader(open(os.path.join(ROOT, "data", "forms.csv"), encoding="utf-8"))}
    forms, numbers = [], {}
    for ident in FM_FORMS:  # the FM forms take the first numbers; the Megas follow
        stem = stem_of(fm_rows[ident]["base_species"])
        numbers[stem] = numbers.get(stem, 0) + 1
    fm_numbers = {}
    for row in rows:
        species = row["base_species"]
        stem = stem_of(species)
        numbers[stem] = numbers.get(stem, 0) + 1
        trigger = row["trigger_item"]
        if trigger in MEGA_BY_MOVE:
            kind, trigger_const, table = KIND_MEGA_BY_MOVE, MEGA_BY_MOVE[trigger], "moves"
        else:
            kind = KIND_PRIMAL if row["form"].startswith("Primal ") else KIND_MEGA
            trigger_const, table = "ITEM_" + stem_of(trigger).upper(), "items"
        ability = None
        if row["ability"] and engine_has_ability("ABILITY_" + stem_of(row["ability"]).upper()):
            ability = "ABILITY_" + stem_of(row["ability"]).upper()
        form = {
            "name": row["form"], "stem": stem, "species": "SPECIES_" + stem.upper(), "number": numbers[stem],
            "dir": form_dir(row["form"], species), "kind": kind, "trigger": trigger_const, "ability": ability,
            "types": [type_const(t) for t in row["types"].split("/")],
            "stats": {k: int(row[k]) for k in ("hp", "atk", "def", "spa", "spd", "spe")},
        }
        for const, table_name in ((form["species"], "species"), (trigger_const, table), (ability, "abilities")):
            if const and const not in symbols[table_name]:
                sys.exit(f"{row['form']}: {const} isn't in generated/{table_name}.txt")
        if not os.path.isdir(os.path.join(POKEMON, stem)):
            sys.exit(f"{row['form']}: no res/pokemon/{stem}")
        forms.append(form)

    for ident, (kind, trigger) in FM_FORMS.items():
        row = fm_rows[ident]
        species = row["base_species"]
        stem = stem_of(species)
        fm_numbers[stem] = fm_numbers.get(stem, 0) + 1
        abilities = ABILITY_OVERRIDES.get(ident) or [
            "ABILITY_" + stem_of(a.replace(" (H)", "")).upper() for a in row["abilities"].split("; ")]
        hidden = [a for a in row["abilities"].split("; ") if a.endswith(" (H)")]
        normal = abilities[:len(abilities) - len(hidden)]
        form = {
            "name": row["form"], "stem": stem, "species": "SPECIES_" + stem.upper(), "number": fm_numbers[stem],
            "dir": ident.split("-", 1)[1].replace("-", "_"), "kind": kind, "trigger": trigger,
            "abilities": [normal[0], normal[-1], abilities[-1] if hidden else normal[0]],
            "types": [type_const(t) for t in row["types"].split("/")],
            "stats": {k: int(row[k]) for k in ("hp", "atk", "def", "spa", "spd", "spe")},
            "ident": ident, "pid": row["form_id"],
        }
        if kind == KIND_TOTEM:
            usual = TOTEM_USUAL_FORMS.get(ident)
            form["pid"] = fm_rows[usual]["form_id"] if usual else None
            form["region"] = region_of(usual) if usual else None
        trigger_table = {KIND_FUSION: "species", KIND_BATTLE: "abilities", KIND_REGIONAL: None, KIND_TOTEM: None}.get(
            kind, "items")
        checks = [(form["species"], "species")] + ([(trigger, trigger_table)] if trigger_table else [])
        for const, table_name in checks + [(a, "abilities") for a in abilities]:
            if const not in symbols[table_name]:
                sys.exit(f"{row['form']}: {const} isn't in generated/{table_name}.txt")
        forms.append(form)
    return forms


def form_data(form, ctx):
    base = json.load(open(os.path.join(POKEMON, form["stem"], "data.json"), encoding="utf-8"))
    data = {}
    for key in ("base_stats", "types", "catch_rate", "base_exp_reward", "ev_yields", "held_items", "gender_ratio",
                "hatch_cycles", "base_friendship", "exp_rate", "egg_groups", "abilities", "safari_flee_rate",
                "body_color", "flip_sprite", "icon_palette", "learnset", "evolutions"):
        data[key] = copy.deepcopy(base.get(key))
    s = form["stats"]
    data["base_stats"] = {"hp": s["hp"], "attack": s["atk"], "defense": s["def"], "speed": s["spe"],
                          "special_attack": s["spa"], "special_defense": s["spd"]}
    types = form["types"]
    data["types"] = [types[0], types[-1]]
    data["held_items"] = {"common": "ITEM_NONE", "rare": "ITEM_NONE"}
    data["abilities"] = form["abilities"] if "abilities" in form else [form["ability"] or "ABILITY_NONE"] * 3
    if isinstance(data["icon_palette"], list):  # a species with icon forms: use its base form's palette
        data["icon_palette"] = next(index for name, index in data["icon_palette"] if name == "base")
    data["learnset"] = {k: v for k, v in data["learnset"].items() if k != "egg_moves"}
    if form.get("pid"):
        # An FM form's own Gen IX learnset (a Mega keeps its base species', since PokeAPI's Mega learnsets are old).
        _, level, tms, tutor, _ = gen9.build_learnset(ctx, form["pid"], want_eggs=False)
        if level:
            data["learnset"] = {"by_level": level, "by_tm": tms, "by_tutor": tutor}
    data["evolutions"] = []
    if form["kind"] == KIND_REGIONAL:
        data["evolutions"] = copy.deepcopy(REGIONAL_EVOLUTIONS.get(form["ident"]) or base["evolutions"])
    return data


def region_of(ident):
    return next((r for r in ("alola", "galar", "hisui", "paldea") if r in ident.split("-")), None)


def regional_tables(forms):
    """The evolved-form and Egg-form rules for regional forms (src/pokemon.c: Pokemon_SovereignEvolvedForm and
    Pokemon_SovereignBabyForm). A regional form evolves into the target's form of the same region, or its base form
    if there's none; an Egg hatches into the baby's form of the parent's region."""
    regional = [f for f in forms if f["kind"] == KIND_REGIONAL]

    def form_of(species_const, region, same=None):
        if same is not None and same["species"] == species_const:
            return same["number"]
        return next((f["number"] for f in regional if f["species"] == species_const and region
                     and region_of(f["ident"]) == region), 0)

    evolutions, babies = [], []
    for f in regional:
        for evo in form_data_evolutions(f):
            target_form = form_of(evo[-1], region_of(f["ident"]))
            if target_form:
                evolutions.append((f["species"], f["number"], evo[-1], target_form))
        baby = json.load(open(os.path.join(POKEMON, f["stem"], "data.json"), encoding="utf-8"))["offspring"]
        babies.append((f["species"], f["number"], baby, form_of(baby, region_of(f["ident"]), same=f)))
    for parent, ident in REGIONAL_PARENTS.items():
        f = next(x for x in regional if x["ident"] == ident)
        babies.append(("SPECIES_" + parent.upper(), 0, f["species"], f["number"]))
    for f in forms:  # a regional Totem's Eggs hatch into its region's form (Totem Alolan Raticate: Alolan Rattata)
        if f["kind"] == KIND_TOTEM and f.get("region"):
            baby = json.load(open(os.path.join(POKEMON, f["stem"], "data.json"), encoding="utf-8"))["offspring"]
            babies.append((f["species"], f["number"], baby, form_of(baby, f["region"])))
    return evolutions, babies


def form_data_evolutions(form):
    base = json.load(open(os.path.join(POKEMON, form["stem"], "data.json"), encoding="utf-8"))
    return REGIONAL_EVOLUTIONS.get(form["ident"]) or base["evolutions"]


def update_meson(stem, lines):
    path = os.path.join(POKEMON, stem, "meson.build")
    text = open(path, encoding="utf-8").read()
    text = re.sub(r"\n?" + re.escape(MESON_START) + r".*?" + re.escape(MESON_END) + r"\n", "", text, flags=re.S)
    if lines:
        text = text.rstrip("\n") + "\n\n" + MESON_START + "\n" + "".join(lines) + MESON_END + "\n"
    open(path, "w", encoding="utf-8").write(text)


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8").write(text)


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    ctx = gen9.load_context(sys.argv[1])
    forms = load_rows()
    by_species = {}
    for form in forms:
        path = os.path.join(POKEMON, form["stem"], "forms", form["dir"], "data.json")
        write(path, json.dumps(form_data(form, ctx), indent=4, ensure_ascii=False) + "\n")
        by_species.setdefault(form["stem"], []).append(f"species_data_files += files('forms/{form['dir']}/data.json')\n")
    for stem, lines in by_species.items():
        update_meson(stem, lines)

    header = "// Generated by tools/engine/gen_forms.py from data/megas.csv and data/forms.csv. Do not edit.\n"
    write(os.path.join(DECOMP, "tools", "dataproc", "src", "sovereign_forms.inc"), header + "".join(
        f'    {{ "{f["stem"]}/forms/{f["dir"]}", NULL, .isGiratinaOrigin = false }}, // {f["name"]}\n'
        for f in forms))

    write(os.path.join(DECOMP, "include", "constants", "sovereign_forms.h"), f"""{header}#ifndef POKEPLATINUM_CONSTANTS_SOVEREIGN_FORMS_H
#define POKEPLATINUM_CONSTANTS_SOVEREIGN_FORMS_H

#include "constants/species.h"

// Sovereign's forms are packed after Platinum's {VANILLA_FORMS_WITH_DATA} alternate forms, in include/data/sovereign_forms.h order.
#define SOVEREIGN_FORM_COUNT          {len(forms)}
#define SOVEREIGN_FORM_PERSONAL_START (SPECIES_BAD_EGG + {VANILLA_FORMS_WITH_DATA} + 1)

enum SovereignFormKind {{
    {KIND_MEGA},
    {KIND_PRIMAL},
    {KIND_MEGA_BY_MOVE}, // Mega Rayquaza: knows the move instead of holding a stone
    {KIND_HELD_ITEM}, // the form follows the held item, out of battle too (Ogerpon's masks)
    {KIND_BATTLE_ITEM}, // the form while holding the item in battle (Crowned Zacian)
    {KIND_KEY_ITEM}, // a key item used on the Pokemon switches the form (Reveal Glass)
    {KIND_FUSION}, // fused with the partner species in the trigger field (DNA Splicers)
    {KIND_REGIONAL}, // a form for good: regional forms, Basculin's stripes
    {KIND_BATTLE}, // the form its ability (the trigger) gives it in battle (Zen Mode)
    {KIND_TOTEM}, // a Totem Pokemon's form, caught after its trial
}};

#endif // POKEPLATINUM_CONSTANTS_SOVEREIGN_FORMS_H
""")

    rows = "".join(f'    {{ {f["species"]}, {f["number"]}, {f["kind"]}, {f["trigger"]} }}, // {f["name"]}\n'
                   for f in forms)
    evolutions, babies = regional_tables(forms)
    evo_rows = "".join(f"    {{ {a}, {b}, {d}, {c} }},\n" for a, b, c, d in evolutions)
    baby_rows = "".join(f"    {{ {a}, {b}, {d}, {c} }},\n" for a, b, c, d in babies)
    write(os.path.join(DECOMP, "include", "data", "sovereign_forms.h"), f"""{header}#ifndef POKEPLATINUM_DATA_SOVEREIGN_FORMS_H
#define POKEPLATINUM_DATA_SOVEREIGN_FORMS_H

#include "constants/sovereign_forms.h"
#include "generated/items.h"
#include "generated/moves.h"
#include "generated/species.h"

typedef struct SovereignForm {{
    u16 species;
    u8 form;
    u8 kind; // enum SovereignFormKind
    u16 trigger; // the item it holds or is used on it, the move it knows (MEGA_BY_MOVE), or its partner species (FUSION)
}} SovereignForm;

// In packing order: entry i's data is personal index SOVEREIGN_FORM_PERSONAL_START + i.
static const SovereignForm sSovereignForms[SOVEREIGN_FORM_COUNT] = {{
{rows}}};

// A regional form that evolves into its region's form of the target species (any other evolves into form 0).
typedef struct SovereignFormEvolution {{
    u16 species;
    u8 form;
    u8 targetForm;
    u16 targetSpecies;
}} SovereignFormEvolution;

static const SovereignFormEvolution sSovereignFormEvolutions[] = {{
{evo_rows}}};

// The form an Egg hatches into from a parent of this species and form (its regional form, or 0).
typedef struct SovereignBabyForm {{
    u16 species;
    u8 form;
    u8 babyForm;
    u16 babySpecies;
}} SovereignBabyForm;

static const SovereignBabyForm sSovereignBabyForms[] = {{
{baby_rows}}};

#endif // POKEPLATINUM_DATA_SOVEREIGN_FORMS_H
""")
    print(f"{len(forms)} forms for {len(by_species)} species")


if __name__ == "__main__":
    main()
