#!/usr/bin/env python3
"""Add species #494-1025 to the decomp (milestone E6 step 2).

For each new species this writes decomp/res/pokemon/<stem>/ the way Platinum's own species are laid out:
  data.json         stats, types, abilities, learnsets (Gen IX, same rules as gen_species_gen9.py), evolutions,
                    egg data, Pokédex data in six languages, Pal Park data
  sprite_data.json  copied from Unown (the placeholder sprite's species)
  male/female_front/back  PLACEHOLDER sprites: Unown-? (real sprites are milestone E12)
  icon.png          placeholder icon from assets/sprites/icons_placeholder (PokeAPI art, see CITATIONS.md)
  footprint.png     blank (Gen V+ Pokémon have no footprints; the Pokédex shows none)
and inserts the species into generated/species.txt (before SPECIES_EGG, so species ID = National Dex number).
The new species have no cry (owner, 2026-10-22): 532 cry banks overflowed the sound heap at boot, so cries are the
project's final step and these species play silently (src/sound_playback.c). Evolutions into a new species from one of Platinum's species are
added to the parent's data.json as well.

Evolution methods come from data/evolution_changes.yaml when the species is listed there, otherwise from
data/species.csv (the first alternative, regional-form variants ignored). Methods that need an item Sovereign
doesn't have yet (milestone E7) are left out and listed in docs/NewSpecies.md, which this script writes.

Running it again rewrites the generated files from scratch (the species list is only extended once).

Usage: python3 tools/engine/gen_new_species.py /path/to/pokeapi/data/v2/csv
"""
import csv
import json
import os
import re
import shutil
import sys
import textwrap
from collections import defaultdict

import yaml

sys.path.insert(0, os.path.dirname(__file__))
import gen_species_gen9 as gen9  # noqa: E402

ROOT = gen9.ROOT
DECOMP = gen9.DECOMP
POKEMON = gen9.POKEMON
FIRST, LAST = 494, 1025
LANGS = {"en": "9", "fr": "5", "de": "6", "it": "8", "es": "7", "jp": "1"}
NAME_LEN = 10  # MON_NAME_LEN
LINE_WIDTH = {"jp": 16}  # Pokédex entry line width; latin languages use 36 (Platinum's longest lines are 37-39)
DEFAULT_LINE_WIDTH = 36
CATEGORY_LEN = {"jp": 10}
DEFAULT_CATEGORY_LEN = 19

# English names over 10 characters, shortened Gen V-style (the owner can change these).
SHORT_NAMES = {
    "Fletchinder": "FLETCHINDR", "Crabominable": "CRABMINABL", "Blacephalon": "BLACEPHALN",
    "Corvisquire": "CORVSQUIRE", "Corviknight": "CORVKNIGHT", "Barraskewda": "BARASKEWDA",
    "Centiskorch": "CENTISKRCH", "Polteageist": "POLTEGEIST", "Stonjourner": "STONJORNER",
    "Basculegion": "BASCULEGON", "Meowscarada": "MEOWSCRADA", "Squawkabilly": "SQUAWKABLY",
    "Kilowattrel": "KILOWTTREL", "Brambleghast": "BRAMBLGHST", "Dudunsparce": "DUDUNSPRCE",
    "Scream Tail": "SCREAMTAIL", "Brute Bonnet": "BRUTEBONNT", "Flutter Mane": "FLUTTRMANE",
    "Slither Wing": "SLITHRWING", "Sandy Shocks": "SANDYSHOCK", "Iron Treads": "IRONTREADS",
    "Iron Bundle": "IRONBUNDLE", "Iron Jugulis": "IRONJUGULS", "Iron Thorns": "IRONTHORNS",
    "Roaring Moon": "ROARNGMOON", "Iron Valiant": "IRONVALINT", "Walking Wake": "WALKNGWAKE",
    "Iron Leaves": "IRONLEAVES", "Poltchageist": "POLTCHAGST", "Fezandipiti": "FEZANDIPTI",
    "Gouging Fire": "GOUGNGFIRE", "Raging Bolt": "RAGINGBOLT", "Iron Boulder": "IRONBOULDR",
}

# PokeAPI gives a species with a female's form the male form's gender rate (Oinkologne: male only). Sovereign's
# species has both, its female's form being a form of it (gen_forms.py, SOVEREIGN_FORM_GENDER).
GENDER_RATE_FIXES = {"916": "4"}  # Oinkologne: half female, like Lechonk
GENDER = {"-1": "GENDER_RATIO_NO_GENDER", "0": "GENDER_RATIO_MALE_ONLY", "1": "GENDER_RATIO_FEMALE_12_5",
          "2": "GENDER_RATIO_FEMALE_25", "4": "GENDER_RATIO_FEMALE_50", "6": "GENDER_RATIO_FEMALE_75",
          "7": "GENDER_RATIO_FEMALE_87_5", "8": "GENDER_RATIO_FEMALE_ONLY"}
GROWTH = {"1": "EXP_RATE_SLOW", "2": "EXP_RATE_MEDIUM_FAST", "3": "EXP_RATE_FAST", "4": "EXP_RATE_MEDIUM_SLOW",
          "5": "EXP_RATE_ERRATIC", "6": "EXP_RATE_FLUCTUATING"}
EGG_GROUPS = [None, "EGG_GROUP_MONSTER", "EGG_GROUP_WATER_1", "EGG_GROUP_BUG", "EGG_GROUP_FLYING", "EGG_GROUP_FIELD",
              "EGG_GROUP_FAIRY", "EGG_GROUP_GRASS", "EGG_GROUP_HUMAN_LIKE", "EGG_GROUP_WATER_3", "EGG_GROUP_MINERAL",
              "EGG_GROUP_AMORPHOUS", "EGG_GROUP_WATER_2", "EGG_GROUP_DITTO", "EGG_GROUP_DRAGON",
              "EGG_GROUP_UNDISCOVERED"]
COLORS = {"1": "MON_COLOR_BLACK", "2": "MON_COLOR_BLUE", "3": "MON_COLOR_BROWN", "4": "MON_COLOR_GRAY",
          "5": "MON_COLOR_GREEN", "6": "MON_COLOR_PINK", "7": "MON_COLOR_PURPLE", "8": "MON_COLOR_RED",
          "9": "MON_COLOR_WHITE", "10": "MON_COLOR_YELLOW"}
SHAPES = {"1": "SHAPE_HEAD", "2": "SHAPE_SERPENTINE", "3": "SHAPE_FINS", "4": "SHAPE_HEAD_ARMS", "5": "SHAPE_HEAD_BASE",
          "6": "SHAPE_BIPEDAL_TAILED", "7": "SHAPE_HEAD_LEGS", "8": "SHAPE_QUADRUPED", "9": "SHAPE_WINGED",
          "10": "SHAPE_TENTACLES", "11": "SHAPE_MULTI_BODY", "12": "SHAPE_BIPEDAL_TAILLESS",
          "13": "SHAPE_MULTI_WINGED", "14": "SHAPE_INSECTOID"}
SPECIAL_PLACES = {"Mt. Coronet": "EVO_LEVEL_MAGNETIC_FIELD", "Eterna Forest": "EVO_LEVEL_MOSS_ROCK",
                  "Route 217": "EVO_LEVEL_ICE_ROCK",
                  # Other games' magnetic-field / ice locations map to Sinnoh's (as Magnezone and Glaceon do).
                  "Vast Poni Canyon": "EVO_LEVEL_MAGNETIC_FIELD", "Blush Mountain": "EVO_LEVEL_MAGNETIC_FIELD",
                  "Mount Lanakila": "EVO_LEVEL_ICE_ROCK"}
ITEM_ALIASES = {"Thunder Stone": "ITEM_THUNDERSTONE"}


def rd(api, name):
    return gen9.rd(api, name)


def const_name(identifier):
    return re.sub(r"[^A-Z0-9]+", "_", identifier.upper()).strip("_")


def load_charmap():
    chars = set()
    for line in open(os.path.join(DECOMP, "tools", "msgenc", "charmap.txt"), encoding="utf-8"):
        m = re.match(r"^[0-9A-Fa-f]{4}=(.)$", line.rstrip("\n"))
        if m:
            chars.add(m.group(1))
    return chars


def clean(text, lang):
    text = text.replace("­\n", "").replace("­", "")
    text = re.sub(r"[\s　]+", "　" if lang == "jp" else " ", text).strip()
    for a, b in (("'", "’"), ("—", "-"), ("–", "-"), ("‘", "’"), ("é", "é")):
        text = text.replace(a, b)
    parts = text.split('"')
    return "".join(p + ("“" if i % 2 == 0 else "”") if i < len(parts) - 1 else p for i, p in enumerate(parts))


def fits(text, chars):
    return all(c in chars or c in " 　\n" for c in text)


def wrap(text, lang):
    width = LINE_WIDTH.get(lang, DEFAULT_LINE_WIDTH)
    if lang == "jp":
        words, lines, cur = text.split("　"), [], ""
        for w in words:
            cand = (cur + "　" + w) if cur else w
            if len(cand) <= width:
                cur = cand
            else:
                if cur:
                    lines.append(cur)
                cur = w
        if cur:
            lines.append(cur)
        return lines if all(len(l) <= width for l in lines) else None
    return textwrap.wrap(text, width)


def entry_lines(texts, lang, chars):
    """Pick the newest flavour text that fits 3 lines (or its first sentences), as entry_text lines."""
    for t in texts:
        if not fits(t, chars):
            continue
        sentences = re.split(r"(?<=[.!?。])[ 　]?", t)
        for k in range(len(sentences), 0, -1):
            cand = (" " if lang != "jp" else "").join(s for s in sentences[:k] if s).strip()
            lines = wrap(cand, lang)
            if lines and len(lines) <= 3:
                return [l + "\n" for l in lines[:-1]] + [lines[-1]]
    return None


def evo_entry(method, target, ctx):
    """Translate a human-readable evolution method into a Platinum evolution entry, or a reason it can't be yet."""
    if method.startswith("Not an evolution"):
        return "not an evolution: " + method.split("—")[-1].strip()
    alternatives = [re.sub(r" from the [a-z0-9-]+ form", "", a).strip() for a in method.split(" OR ")]
    genderless = {re.sub(r" \((male|female)\)$", "", a) for a in alternatives}
    if len(alternatives) > 1 and len(genderless) == 1:
        # The same method for either gender (Meowstic, Oinkologne): any gender evolves, and the gender picks the form.
        return evo_entry(genderless.pop(), target, ctx)
    if len(alternatives) > 1:
        # Use the first alternative Platinum can run (e.g. a Sinnoh location or a stone).
        tried = [evo_entry(a, target, ctx) for a in alternatives]
        return next((t for t in tried if isinstance(t, list)), tried[0])
    m = alternatives[0]
    m = re.sub(r"\s*\(.*\)$", "", m) if not re.search(r"\((male|female|Atk [<>=] Def)\)$", m) else m
    items, moves, species = ctx["items"], ctx["moves_by_name"], ctx["species_by_name"]

    def item(name):
        name = re.sub(r"^(a|an) ", "", name)
        c = ITEM_ALIASES.get(name) or "ITEM_" + const_name(name.replace("’", "").replace("'", ""))
        return c if c in items else None

    if mm := re.fullmatch(r"Level (\d+)", m):
        return ["EVO_LEVEL", int(mm.group(1)), target]
    if mm := re.fullmatch(r"Level (\d+) \((male|female)\)", m):
        return ["EVO_LEVEL_" + mm.group(2).upper(), int(mm.group(1)), target]
    if mm := re.fullmatch(r"Level (\d+) \(Atk ([<>=]) Def\)", m):
        return [{">": "EVO_LEVEL_ATK_GT_DEF", "<": "EVO_LEVEL_ATK_LT_DEF", "=": "EVO_LEVEL_ATK_EQ_DEF"}[mm.group(2)],
                int(mm.group(1)), target]
    if m == "Level up with high friendship":
        return ["EVO_LEVEL_HAPPINESS", target]
    if m in ("Level up with high friendship at day", "Level up with high friendship by day"):
        return ["EVO_LEVEL_HAPPINESS_DAY", target]
    if m == "Level up with high friendship at night":
        return ["EVO_LEVEL_HAPPINESS_NIGHT", target]
    if mm := re.fullmatch(r"Use (.+?)(?: \((male|female)\))?", m):
        it = item(mm.group(1))
        if not it:
            return f"needs the {mm.group(1)} item (E7)"
        return ["EVO_USE_ITEM" + ("_" + mm.group(2).upper() if mm.group(2) else ""), it, target]
    if mm := re.fullmatch(r"Level up knowing (.+)", m):
        mv = moves.get(mm.group(1))
        return ["EVO_LEVEL_KNOW_MOVE", mv, target] if mv else f"needs the move {mm.group(1)}"
    if mm := re.fullmatch(r"Level up with (.+?) in (?:the )?party", m):
        sp = species.get(mm.group(1))
        return ["EVO_LEVEL_SPECIES_IN_PARTY", sp, target] if sp else f"unknown species {mm.group(1)}"
    if mm := re.fullmatch(r"Level up holding (.+?) (?:at|by) (day|night)", m):
        it = item(mm.group(1))
        if not it:
            return f"needs the {mm.group(1)} item (E7)"
        return ["EVO_LEVEL_WITH_HELD_ITEM_" + mm.group(2).upper(), it, target]
    if mm := re.fullmatch(r"Level up at (.+)", m):
        if mm.group(1) in SPECIAL_PLACES:
            return [SPECIAL_PLACES[mm.group(1)], target]
    return f"method not translated: {method}"


def replace_evolutions_block(path, entries):
    """Add evolution entries to an existing data.json without reformatting the rest of the file."""
    text = open(path, encoding="utf-8").read()
    start = text.index('\n    "evolutions": [') + 1
    i, depth = text.index("[", start), 0
    for end in range(i, len(text)):
        depth += {"[": 1, "]": -1}.get(text[end], 0)
        if depth == 0:
            end += 1
            break
    old = json.loads("{" + text[start:end] + "}")["evolutions"]
    new = old + [e for e in entries if e not in old]
    body = ",\n".join("        [ " + ", ".join(json.dumps(x, ensure_ascii=False) for x in e) + " ]" for e in new)
    text = text[:start] + '    "evolutions": [\n' + body + "\n    ]" + text[end:]
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    api = sys.argv[1]
    ctx = gen9.load_context(api)
    chars = load_charmap()
    species_rows = {int(r["id"]): r for r in rd(api, "pokemon_species.csv")}
    poke_by_id = {int(r["id"]): r for r in rd(api, "pokemon.csv")}
    names = defaultdict(dict)
    genus = defaultdict(dict)
    lang_of = {v: k for k, v in LANGS.items()}
    for r in rd(api, "pokemon_species_names.csv"):
        lang = lang_of.get(r["local_language_id"])
        if lang:
            names[int(r["pokemon_species_id"])][lang] = r["name"]
            genus[int(r["pokemon_species_id"])][lang] = r["genus"]
    flavor = defaultdict(lambda: defaultdict(list))  # species -> lang -> [(version, text)]
    for r in rd(api, "pokemon_species_flavor_text.csv"):
        lang = lang_of.get(r["language_id"])
        if lang:
            flavor[int(r["species_id"])][lang].append((int(r["version_id"]), clean(r["flavor_text"], lang)))
    egg_groups = defaultdict(list)
    for r in rd(api, "pokemon_egg_groups.csv"):
        egg_groups[int(r["species_id"])].append(EGG_GROUPS[int(r["egg_group_id"])])
    ev_yields = defaultdict(dict)
    for r in rd(api, "pokemon_stats.csv"):
        if r["stat_id"] in gen9.STATS:
            ev_yields[r["pokemon_id"]][gen9.STATS[r["stat_id"]]] = int(r["effort"])
    item_ids = {r["id"]: r["identifier"] for r in rd(api, "items.csv")}
    held = defaultdict(dict)  # pokemon id -> version -> [(rarity, item)]
    for r in rd(api, "pokemon_items.csv"):
        held[int(r["pokemon_id"])].setdefault(int(r["version_id"]), []).append((int(r["rarity"]), item_ids[r["item_id"]]))
    items = {l.strip() for l in open(os.path.join(DECOMP, "generated", "items.txt")) if l.strip()}
    moves_by_name = {}
    for r in rd(api, "move_names.csv"):
        if r["local_language_id"] == "9" and int(r["move_id"]) in ctx["move_ok"]:
            moves_by_name[r["name"]] = ctx["move_ok"][int(r["move_id"])]
    design = {int(r["dex"]): r for r in csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8"))}
    species_by_name = {r["name"]: "SPECIES_" + const_name(species_rows[d]["identifier"]) for d, r in design.items()}
    evo_ctx = {"items": items, "moves_by_name": moves_by_name, "species_by_name": species_by_name}
    ychanges = yaml.safe_load(open(os.path.join(ROOT, "data", "evolution_changes.yaml"), encoding="utf-8"))
    overrides = {c["species"]: c["method"] for c in ychanges["changes"] + ychanges.get("extra", [])}
    # A method with several entries lists them (Urshifu: one per Scroll).
    override_entries = {c["species"]: c["evolutions"] for c in ychanges["changes"] + ychanges.get("extra", [])
                        if c.get("evolutions")}
    icon_pal = {int(r["dex"]): int(r["icon_palette"]) for r in csv.DictReader(open(os.path.join(ROOT, "data", "icon_placeholders.csv")))}
    icon_files = {int(f[:4]): f for f in os.listdir(os.path.join(ROOT, "assets", "sprites", "icons_placeholder"))}

    # Platinum's species, for Pokédex size-comparison values by nearest height.
    vanilla_dex = []
    species_txt = [l.strip() for l in open(os.path.join(DECOMP, "generated", "species.txt")) if l.strip()]
    for c in species_txt[1:494]:
        d = json.load(open(os.path.join(POKEMON, c[8:].lower(), "data.json"), encoding="utf-8"))
        vanilla_dex.append(d["pokedex_data"])
    unown = os.path.join(POKEMON, "unown")

    report, pending_evos = [], []
    new_consts = []
    for dex in range(FIRST, LAST + 1):
        sp = species_rows[dex]
        pk = poke_by_id[dex]
        pid = str(dex)
        const = "SPECIES_" + const_name(sp["identifier"])
        stem = const[8:].lower()
        new_consts.append(const)
        folder = os.path.join(POKEMON, stem)
        os.makedirs(folder, exist_ok=True)

        en_name = names[dex]["en"]
        display = SHORT_NAMES.get(en_name, en_name.upper())
        assert len(display) <= NAME_LEN and fits(display, chars), (dex, display)
        fam, level, tms, tutor, eggs = gen9.build_learnset(ctx, pid, want_eggs=not sp["evolves_from_species_id"])
        a = ctx["pabilities"][pid]
        t = ctx["ptypes"][pid]
        root = dex
        while species_rows[root]["evolves_from_species_id"]:
            root = int(species_rows[root]["evolves_from_species_id"])
        versions = sorted(held.get(dex, {}))
        common = rare = "ITEM_NONE"
        if versions:
            for rarity, ident in held[dex][versions[-1]]:
                c = "ITEM_" + const_name(ident)
                if c not in items:
                    continue
                if rarity >= 50:
                    common = c
                if rarity <= 50:
                    rare = c
        height_in = round(int(pk["height"]) * 10 / 2.54)
        weight_lb = round(int(pk["weight"]) / 10 * 2.20462, 1)
        near = min(vanilla_dex, key=lambda v: abs(v["height_inches"] - height_in))
        pdx = {"height_inches": height_in, "weight_pounds": weight_lb, "body_shape": SHAPES[sp["shape_id"]]}
        for k in ("trainer_scale_f", "pokemon_scale_f", "trainer_scale_m", "pokemon_scale_m",
                  "trainer_pos_f", "pokemon_pos_f", "trainer_pos_m", "pokemon_pos_m"):
            pdx[k] = near[k]
        langs_used = {}
        for lang in LANGS:
            nm = names[dex].get(lang) or en_name
            nm = display if lang == "en" else (nm.upper() if lang != "jp" else nm)
            if not fits(nm, chars) or len(nm) > NAME_LEN:
                nm = display
            cat = clean(genus[dex].get(lang) or genus[dex]["en"], lang)
            if not fits(cat, chars) or len(cat) > CATEGORY_LEN.get(lang, DEFAULT_CATEGORY_LEN):
                cat = clean(genus[dex]["en"], "en")
                if len(cat) > DEFAULT_CATEGORY_LEN:
                    cat = cat.replace(" Pokémon", "")[:DEFAULT_CATEGORY_LEN - 8].rstrip() + " Pokémon"
            texts = [t for _, t in sorted(flavor[dex].get(lang, []), reverse=True)]
            lines = entry_lines(texts, lang, chars)
            langs_used[lang] = "own" if lines else "English"
            if not lines:
                lines = entry_lines([t for _, t in sorted(flavor[dex]["en"], reverse=True)], "en", chars) or ["…"]
            pdx[lang] = {"name": nm, "category": cat, "entry_text": lines}

        data = {
            "base_stats": {k: ctx["stats"][pid][k] for k in ("hp", "attack", "defense", "speed", "special_attack",
                                                             "special_defense")},
            "types": [t[1], t.get(2, t[1])],
            "catch_rate": int(sp["capture_rate"]),
            "base_exp_reward": min(255, int(pk["base_experience"] or 0)),
            "ev_yields": {k: ev_yields[pid][k] for k in ("hp", "attack", "defense", "speed", "special_attack",
                                                         "special_defense")},
            "held_items": {"common": common, "rare": rare},
            "gender_ratio": GENDER[GENDER_RATE_FIXES.get(dex, sp["gender_rate"])],
            "hatch_cycles": int(sp["hatch_counter"]),
            "base_friendship": int(sp["base_happiness"] or 0),
            "exp_rate": GROWTH[sp["growth_rate_id"]],
            "egg_groups": (egg_groups[dex] + egg_groups[dex])[:2] if egg_groups[dex] else ["EGG_GROUP_UNDISCOVERED"] * 2,
            "abilities": [a[1], a.get(2, "ABILITY_NONE"), a.get(3, "ABILITY_NONE")],
            "safari_flee_rate": 0,
            "body_color": COLORS[sp["color_id"]],
            "flip_sprite": False,
            "icon_palette": icon_pal.get(dex, 0),
            "learnset": {"by_level": level, "by_tm": tms, "by_tutor": tutor, **({"egg_moves": eggs} if eggs else {})},
            "evolutions": [],
            "offspring": "SPECIES_" + const_name(species_rows[root]["identifier"]),
            "footprint": {"has": False, "size": "FOOTPRINT_SMALL", "type": "FOOTPRINT_TYPE_NONE"},
            "pokedex_data": pdx,
            "catching_show": {"pal_park_land_area": "PAL_PARK_AREA_LAND_NONE",
                              "pal_park_water_area": "PAL_PARK_AREA_WATER_NONE",
                              "catching_points": 0, "rarity": 0, "unused": 0},
        }
        # Evolution into this species, written to its parent (new or Platinum species).
        parent = sp["evolves_from_species_id"]
        evo_note = ""
        if parent:
            method = overrides.get(design[dex]["name"]) or design[dex]["evolution_method"]
            entries = override_entries.get(design[dex]["name"])
            entry = entries[0] if entries else evo_entry(method, const, evo_ctx)
            if isinstance(entry, list):
                entries = entries or [entry]
                parent_stem = const_name(species_rows[int(parent)]["identifier"]).lower()
                data_path = os.path.join(POKEMON, parent_stem, "data.json")
                if int(parent) < FIRST:
                    replace_evolutions_block(data_path, entries)
                else:
                    pending_evos.extend((parent_stem, e) for e in entries)
                evo_note = " / ".join(" ".join(str(x) for x in e[:-1]) for e in entries)
            elif entry.startswith("not an evolution"):
                evo_note = entry
            else:
                evo_note = "⏳ " + entry
        json.dump(data, open(os.path.join(folder, "data.json"), "w", encoding="utf-8"), indent=4, ensure_ascii=False)
        with open(os.path.join(folder, "data.json"), "a") as f:
            f.write("\n")

        shutil.copyfile(os.path.join(unown, "sprite_data.json"), os.path.join(folder, "sprite_data.json"))
        # Platinum keeps a female sprite for every species (a copy when there's no difference) and shows it for
        # female Pokémon, so both are needed.
        for face in ("front", "back"):
            for gender in ("male", "female"):
                shutil.copyfile(os.path.join(unown, "forms", "que", f"{face}.png"),
                                os.path.join(folder, f"{gender}_{face}.png"))
                shutil.copyfile(os.path.join(unown, "forms", "que", f"{face}.png.key"),
                                os.path.join(folder, f"{gender}_{face}.png.key"))
        for pal in ("normal.pal", "shiny.pal"):
            shutil.copyfile(os.path.join(unown, pal), os.path.join(folder, pal))
        shutil.copyfile(os.path.join(POKEMON, "lapras", "footprint.png"), os.path.join(folder, "footprint.png"))
        shutil.copyfile(os.path.join(ROOT, "assets", "sprites", "icons_placeholder", icon_files[dex]),
                        os.path.join(folder, "icon.png"))
        # No cry (owner, 2026-10-22): 532 cry banks overflowed the sound heap at boot. Cries are the final step.
        for stale in ("cry.txt", "cry.wav"):
            if os.path.exists(os.path.join(folder, stale)):
                os.remove(os.path.join(folder, stale))
        with open(os.path.join(folder, "meson.build"), "w") as f:
            f.write("species_data_files += files('data.json', 'sprite_data.json')\n\n"
                    "poke_icon_files += files('icon.png')\n\n"
                    "pokegra_files += files('female_back.png')\npokegra_files += files('male_back.png')\n"
                    "pokegra_files += files('female_front.png')\npokegra_files += files('male_front.png')\n\n"
                    "pokefoot_files += files('footprint.png')\n")
        report.append((dex, en_name, display, fam or "—", len(level), evo_note,
                       ", ".join(l for l, v in langs_used.items() if v != "own") or "—"))

    # Evolutions between new species.
    by_parent = defaultdict(list)
    for parent_stem, entry in pending_evos:
        by_parent[parent_stem].append(entry)
    for parent_stem, entries in by_parent.items():
        path = os.path.join(POKEMON, parent_stem, "data.json")
        d = json.load(open(path, encoding="utf-8"))
        d["evolutions"] = entries
        json.dump(d, open(path, "w", encoding="utf-8"), indent=4, ensure_ascii=False)
        with open(path, "a") as f:
            f.write("\n")

    # Species list: new species before SPECIES_EGG.
    if new_consts[0] not in species_txt:
        i = species_txt.index("SPECIES_EGG")
        species_txt = species_txt[:i] + new_consts + species_txt[i:]
        with open(os.path.join(DECOMP, "generated", "species.txt"), "w") as f:
            f.write("\n".join(species_txt) + "\n")

    pending = [r for r in report if r[5].startswith("⏳")]
    L = ["# Sovereign Platinum — New species #494–1025", "",
         "> Generated by `tools/engine/gen_new_species.py` from PokeAPI and `data/`. Edit the generator, not this file.",
         "",
         "Stats, types, abilities, learnsets, egg data and Pokédex data are Gen IX (learnsets follow the same rules as "
         "#1–493). **Sprites are placeholders (Unown-?) until milestone E12**; icons are PokeAPI placeholders; new species "
         "have no cry yet (they play silently; cries are the project's final step). Names over 10 characters are "
         "shortened (column *In game*).", "",
         f"Evolutions waiting for an item from milestone E7: {len(pending)} (marked ⏳).", "",
         "| # | Species | In game | Learnset from | Level-up moves | Evolves by | Dex text not in own language |",
         "|---|---|---|---|---|---|---|"]
    L += [f"| {a} | {b} | {c} | {d} | {e} | {f or '—'} | {g} |" for a, b, c, d, e, f, g in report]
    with open(os.path.join(ROOT, "docs", "NewSpecies.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print(f"species added: {len(report)}; evolutions pending items: {len(pending)}")


if __name__ == "__main__":
    main()
