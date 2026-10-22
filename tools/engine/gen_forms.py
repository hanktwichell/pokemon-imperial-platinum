#!/usr/bin/env python3
"""Add Sovereign's alternate forms to the decomp: the 99 Mega Evolutions and Primal Reversions (milestone E8).

Platinum packs alternate-form data after every species (tools/dataproc/src/speciesproc.c, altFormsWithData). This
script appends Sovereign's forms to that list and writes everything that follows the list's order:
  res/pokemon/<species>/forms/<form>/data.json   stats, types and ability from data/megas.csv; everything else is
                                                 the base species' (learnsets included)
  res/pokemon/<species>/meson.build              the form's data.json, inside a generator-owned block
  tools/dataproc/src/sovereign_forms.inc         the entries speciesproc appends to altFormsWithData
  include/constants/sovereign_forms.h            SOVEREIGN_FORM_COUNT and where the forms start
  include/data/sovereign_forms.h                 species, form number and trigger of each form, in packing order
                                                 (src/pokemon.c maps a species and form to its data with it)

Form numbers: a species' forms are numbered from 1 in data/megas.csv order (Charizard: 1 = Mega X, 2 = Mega Y).
A Mega only exists in battle, so these numbers are never saved; the forms milestone (FM) can renumber them.

Abilities: a Mega gets its own ability only when the battle engine has it (megas.csv ability_in_gen4_engine = 1).
Otherwise its data lists no ability and the battle keeps the Pokémon's own ability (docs/MegaEvolution.md).

Sprites and icons: none yet. Platinum's sprite and icon code ignores the form of these species, so a Mega shows
its base species until milestone E12 adds the art.

Usage: python3 tools/engine/gen_forms.py   (rerun after editing data/megas.csv)
"""
import copy
import csv
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from gen_items import DECOMP, ROOT, stem_of  # noqa: E402

POKEMON = os.path.join(DECOMP, "res", "pokemon")
MESON_START = "# Sovereign forms (tools/engine/gen_forms.py): start"
MESON_END = "# Sovereign forms: end"
VANILLA_FORMS_WITH_DATA = 12  # Deoxys x3, Wormadam x2, Giratina, Shaymin, Rotom x5 (speciesproc.c)

KIND_MEGA, KIND_PRIMAL, KIND_MEGA_BY_MOVE = "SOVEREIGN_FORM_MEGA", "SOVEREIGN_FORM_PRIMAL", "SOVEREIGN_FORM_MEGA_BY_MOVE"
MEGA_BY_MOVE = {"Dragon Ascent (move; no stone)": "MOVE_DRAGON_ASCENT"}  # Mega Rayquaza


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
    forms, numbers = [], {}
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
        if row["ability"] and row["ability_in_gen4_engine"] == "1":
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
    return forms


def form_data(form):
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
    data["abilities"] = [form["ability"] or "ABILITY_NONE"] * 3
    if isinstance(data["icon_palette"], list):  # a species with icon forms: use its base form's palette
        data["icon_palette"] = next(index for name, index in data["icon_palette"] if name == "base")
    data["learnset"] = {k: v for k, v in data["learnset"].items() if k != "egg_moves"}
    data["evolutions"] = []
    return data


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
    forms = load_rows()
    by_species = {}
    for form in forms:
        path = os.path.join(POKEMON, form["stem"], "forms", form["dir"], "data.json")
        write(path, json.dumps(form_data(form), indent=4, ensure_ascii=False) + "\n")
        by_species.setdefault(form["stem"], []).append(f"species_data_files += files('forms/{form['dir']}/data.json')\n")
    for stem, lines in by_species.items():
        update_meson(stem, lines)

    header = "// Generated by tools/engine/gen_forms.py from data/megas.csv. Do not edit.\n"
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
}};

#endif // POKEPLATINUM_CONSTANTS_SOVEREIGN_FORMS_H
""")

    rows = "".join(f'    {{ {f["species"]}, {f["number"]}, {f["kind"]}, {f["trigger"]} }}, // {f["name"]}\n'
                   for f in forms)
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
    u16 trigger; // the item it holds, or the move it knows (SOVEREIGN_FORM_MEGA_BY_MOVE)
}} SovereignForm;

// In packing order: entry i's data is personal index SOVEREIGN_FORM_PERSONAL_START + i.
static const SovereignForm sSovereignForms[SOVEREIGN_FORM_COUNT] = {{
{rows}}};

#endif // POKEPLATINUM_DATA_SOVEREIGN_FORMS_H
""")
    print(f"{len(forms)} forms for {len(by_species)} species")


if __name__ == "__main__":
    main()
