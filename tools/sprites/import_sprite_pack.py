#!/usr/bin/env python3
"""Index the "DPPt Style Gen VI and Beyond" sprite pack and write the sprite log.

The pack uses Pokémon Essentials v19+ naming (SPECIES.png, SPECIES_<form>.png) and contains
back sprites only ("Back", "Back shiny"). This script:
  * maps every file to a National Dex number and form (Mega, regional, alternate form, ...),
  * attributes each file to its artist(s) by parsing the pack's Credits.txt,
  * checks each sprite against Nintendo DS limits (80x80 frame, 15 colours + transparency),
  * writes data/sprite_index.csv and docs/SpriteLog.md (status of every added species and every
    Mega/Primal form: front / back / shiny back).

Usage:
  python3 -I tools/sprites/import_sprite_pack.py assets/sprites/packs/dppt_gen6_and_beyond
"""
import csv
import os
import re
import sys
import unicodedata
from collections import defaultdict

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PACK_NAME = "DPPt Style Gen VI and Beyond"

# Essentials form numbers for Mega / Primal forms of species that have them.
MEGA_FORMS = {
    ("VENUSAUR", "1"): "Mega Venusaur", ("CHARIZARD", "1"): "Mega Charizard X", ("CHARIZARD", "2"): "Mega Charizard Y",
    ("BLASTOISE", "1"): "Mega Blastoise", ("BEEDRILL", "1"): "Mega Beedrill", ("PIDGEOT", "1"): "Mega Pidgeot",
    ("ALAKAZAM", "1"): "Mega Alakazam", ("SLOWBRO", "1"): "Mega Slowbro", ("GENGAR", "1"): "Mega Gengar",
    ("KANGASKHAN", "1"): "Mega Kangaskhan", ("PINSIR", "1"): "Mega Pinsir", ("GYARADOS", "1"): "Mega Gyarados",
    ("AERODACTYL", "1"): "Mega Aerodactyl", ("MEWTWO", "1"): "Mega Mewtwo X", ("MEWTWO", "2"): "Mega Mewtwo Y",
    ("AMPHAROS", "1"): "Mega Ampharos", ("STEELIX", "1"): "Mega Steelix", ("SCIZOR", "1"): "Mega Scizor",
    ("HERACROSS", "1"): "Mega Heracross", ("HOUNDOOM", "1"): "Mega Houndoom", ("TYRANITAR", "1"): "Mega Tyranitar",
    ("SCEPTILE", "1"): "Mega Sceptile", ("BLAZIKEN", "1"): "Mega Blaziken", ("SWAMPERT", "1"): "Mega Swampert",
    ("GARDEVOIR", "1"): "Mega Gardevoir", ("SABLEYE", "1"): "Mega Sableye", ("MAWILE", "1"): "Mega Mawile",
    ("AGGRON", "1"): "Mega Aggron", ("MEDICHAM", "1"): "Mega Medicham", ("MANECTRIC", "1"): "Mega Manectric",
    ("SHARPEDO", "1"): "Mega Sharpedo", ("CAMERUPT", "1"): "Mega Camerupt", ("ALTARIA", "1"): "Mega Altaria",
    ("BANETTE", "1"): "Mega Banette", ("ABSOL", "1"): "Mega Absol", ("GLALIE", "1"): "Mega Glalie",
    ("SALAMENCE", "1"): "Mega Salamence", ("METAGROSS", "1"): "Mega Metagross", ("LATIAS", "1"): "Mega Latias",
    ("LATIOS", "1"): "Mega Latios", ("KYOGRE", "1"): "Primal Kyogre", ("GROUDON", "1"): "Primal Groudon",
    ("RAYQUAZA", "1"): "Mega Rayquaza", ("LOPUNNY", "1"): "Mega Lopunny", ("GARCHOMP", "1"): "Mega Garchomp",
    ("LUCARIO", "1"): "Mega Lucario", ("ABOMASNOW", "1"): "Mega Abomasnow", ("GALLADE", "1"): "Mega Gallade",
    ("AUDINO", "1"): "Mega Audino", ("DIANCIE", "1"): "Mega Diancie",
}
# Known non-Mega forms in this pack, for the index (Essentials numbering).
OTHER_FORMS = {
    ("ARCANINE", "1"): "Hisuian Arcanine", ("GROWLITHE", "1"): "Hisuian Growlithe", ("TYPHLOSION", "1"): "Hisuian Typhlosion",
    ("DECIDUEYE", "1"): "Hisuian Decidueye", ("SNEASEL", "1"): "Hisuian Sneasel", ("QWILFISH", "1"): "Hisuian Qwilfish",
    ("BASCULIN", "2"): "White-Striped Basculin", ("BASCULIN", "1"): "Blue-Striped Basculin",
    ("RAICHU", "1"): "Alolan Raichu", ("RATTATA", "1"): "Alolan Rattata", ("RATICATE", "1"): "Alolan Raticate",
    ("SANDSHREW", "1"): "Alolan Sandshrew", ("SANDSLASH", "1"): "Alolan Sandslash", ("VULPIX", "1"): "Alolan Vulpix",
    ("NINETALES", "1"): "Alolan Ninetales", ("DIGLETT", "1"): "Alolan Diglett", ("DUGTRIO", "1"): "Alolan Dugtrio",
    ("MEOWTH", "1"): "Alolan Meowth", ("MEOWTH", "2"): "Galarian Meowth", ("MEOWTH", "3"): "Galarian Meowth (alt)",
    ("PERSIAN", "1"): "Alolan Persian", ("GEODUDE", "1"): "Alolan Geodude", ("GRAVELER", "1"): "Alolan Graveler",
    ("GOLEM", "1"): "Alolan Golem", ("GRIMER", "1"): "Alolan Grimer", ("MUK", "1"): "Alolan Muk",
    ("EXEGGUTOR", "1"): "Alolan Exeggutor", ("MAROWAK", "1"): "Alolan Marowak", ("PONYTA", "1"): "Galarian Ponyta",
    ("RAPIDASH", "1"): "Galarian Rapidash", ("SLOWPOKE", "1"): "Galarian Slowpoke", ("SLOWBRO", "2"): "Galarian Slowbro",
    ("SLOWKING", "1"): "Galarian Slowking", ("FARFETCHD", "1"): "Galarian Farfetch'd", ("WEEZING", "1"): "Galarian Weezing",
    ("MRMIME", "1"): "Galarian Mr. Mime", ("ARTICUNO", "1"): "Galarian Articuno", ("ZAPDOS", "1"): "Galarian Zapdos",
    ("MOLTRES", "1"): "Galarian Moltres", ("CORSOLA", "1"): "Galarian Corsola", ("ZIGZAGOON", "1"): "Galarian Zigzagoon",
    ("LINOONE", "1"): "Galarian Linoone", ("DARUMAKA", "1"): "Galarian Darumaka", ("YAMASK", "1"): "Galarian Yamask",
    ("STUNFISK", "1"): "Galarian Stunfisk", ("ELECTRODE", "1"): "Hisuian Electrode", ("VOLTORB", "1"): "Hisuian Voltorb",
    ("SLIGGOO", "1"): "Hisuian Sliggoo", ("ZORUA", "1"): "Hisuian Zorua", ("EEVEE", "1"): "Partner Eevee",
    ("GRENINJA", "2"): "Ash-Greninja", ("FLOETTE", "5"): "Eternal Flower Floette", ("ZYGARDE", "1"): "Zygarde 10% Forme",
    ("ZYGARDE", "2"): "Zygarde Complete Forme", ("ARCEUS", "18"): "Fairy-type Arceus",
}
# Essentials spellings that differ from a plain normalisation of the species name.
ALIASES = {"RATATTA": "RATTATA"}
# Misspellings in the pack's Credits.txt.
CREDIT_TYPOS = {"Sandyghast": "Sandygast"}


def key_of(name):
    s = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    return re.sub(r"[^A-Za-z0-9]", "", s).upper()


def load_species():
    rows = list(csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8")))
    return rows, {key_of(r["name"]): r for r in rows}


def load_megas():
    return list(csv.DictReader(open(os.path.join(ROOT, "data", "megas.csv"), encoding="utf-8")))


def parse_credits(path, rows, by_key):
    """Return {(dex, form_label_or_None): [artists]} from the pack's Credits.txt."""
    fam = defaultdict(list)
    by_name = {}
    for r in rows:
        fam[r["family_id"]].append(r)
        by_name[key_of(r["name"])] = r
    credit = defaultdict(list)
    general = defaultdict(list)
    artist = None
    text = open(path, encoding="utf-8", errors="replace").read()
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("Special thanks"):
            break
        m = re.match(r"^@\s*([^:*]+?)\s*(\(republished by [^)]+\))?\s*:?\s*(\*.*)?$", line)
        if m and line.startswith("@"):
            artist = m.group(1).strip()
            if m.group(2):
                artist += " " + m.group(2)
            line = (m.group(3) or "").strip()
            if not line:
                continue
        if artist is None:
            continue
        item = line.lstrip("*-").strip()
        if not item or item.lower().startswith("some ") or item.endswith(":"):
            continue
        add = lambda k: credit[k].append(artist) if artist not in credit[k] else None
        if item.startswith("All Unova"):
            for r in rows:
                if 494 <= int(r["dex"]) <= 649:
                    add((r["dex"], None))
            continue
        if item.startswith("Gigantamax"):
            continue
        if re.match(r"^(Mega|Primal) ", item):
            add(("mega", item.replace(" + ", " X / ").strip()))
            if " + " in item:
                base = item.split(" + ")[0]
                add(("mega", base.rsplit(" ", 1)[0] + " Y"))
                credit[("mega", item.replace(" + ", " X / ").strip())].pop()
                add(("mega", base))
            continue
        m3 = re.match(r"^(Alolan|Galarian|Hisuian) (.+?)( line)?$", item)
        if m3 and key_of(m3.group(2)) in by_name:
            members = fam[by_name[key_of(m3.group(2))]["family_id"]] if m3.group(3) else [by_name[key_of(m3.group(2))]]
            for mem in members:
                add(("form", f"{m3.group(1)} {mem['name']}"))
            continue
        if re.match(r"^(Alolan|Galarian|Hisuian|White-striped|Eternal|Ash-|Fairy-type|HOME|Partner|Female|Black)", item):
            add(("form", item.replace("White-striped", "White-Striped")))
            continue
        if "Starters" in item or item in ("Missing shinies", "Recolor edits", "Compiling of sprites"):
            general[artist].append(item)
            continue
        name = re.sub(r"\s*(line|forms?|\(.*\)|edits|\+ colors).*$", "", item, flags=re.I).strip()
        names = [CREDIT_TYPOS.get(n.strip(), n.strip()) for n in name.split(" and ")]
        if all(key_of(n) in by_name for n in names) and len(names) > 1:
            for n in names:
                add((by_name[key_of(n)]["dex"], None))
            continue
        name = names[0]
        k = key_of(name)
        if k in by_name:
            r = by_name[k]
            if " line" in item:
                for m2 in fam[r["family_id"]]:
                    add((m2["dex"], None))
            else:
                add((r["dex"], None))
        else:
            general[artist].append(item)
    return credit, general


def ds_check(path):
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    scale = w // 80 if w % 80 == 0 and w == h else None
    small = im.resize((80, 80), Image.NEAREST) if scale else None
    exact = bool(scale) and small.resize((w, h), Image.NEAREST).tobytes() == im.tobytes()
    img = small or im
    pixels = img.get_flattened_data() if hasattr(img, "get_flattened_data") else img.getdata()
    colours = len({p for p in pixels if p[3] > 0})
    return {"size": f"{w}x{h}", "exact_upscale": int(exact), "colours": colours, "ds_ready": int(exact and colours <= 15)}


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    pack = sys.argv[1]
    pokedir = os.path.join(pack, "Pokemon")
    rows, by_key = load_species()
    megas = load_megas()
    credit, general = parse_credits(os.path.join(pack, "Credits.txt"), rows, by_key)

    index = []
    have = defaultdict(set)  # (dex or 'mega:Label') -> {'back','back_shiny'}
    for sub, kind in (("Back", "back"), ("Back shiny", "back_shiny")):
        for fn in sorted(os.listdir(os.path.join(pokedir, sub))):
            if not fn.endswith(".png"):
                continue
            stem = fn[:-4]
            female = stem.endswith("_female")
            stem = stem[:-7] if female else stem
            base, _, form = stem.partition("_")
            base = ALIASES.get(base, base)
            r = by_key.get(base)
            if r is None:
                print("unmapped:", fn)
                continue
            if form == "gmax":
                label, cat = f"Gigantamax {r['name']}", "gigantamax"
            elif (base, form) in MEGA_FORMS:
                label, cat = MEGA_FORMS[(base, form)], "mega"
            elif (base, form) in OTHER_FORMS:
                label, cat = OTHER_FORMS[(base, form)], "regional/alt"
            elif form:
                label, cat = f"{r['name']} form {form}", "alt_form"
            else:
                label, cat = r["name"], "base"
            if female:
                label += " (female)"
            chk = ds_check(os.path.join(pokedir, sub, fn))
            if cat == "mega":
                artists = credit.get(("mega", label), [])
            elif cat == "base":
                artists = credit.get((r["dex"], None), [])
            else:
                artists = credit.get(("form", label), []) or credit.get((r["dex"], None), [])
            index.append({"file": f"Pokemon/{sub}/{fn}", "dex": r["dex"], "species": r["name"], "form": label,
                          "category": cat, "kind": kind, "artists": "; ".join(artists) or "not individually credited in pack (see Credits.txt)",
                          **chk})
            if cat == "base" and not female:
                have[r["dex"]].add(kind)
            if cat == "mega":
                have["mega:" + label].add(kind)

    with open(os.path.join(ROOT, "data", "sprite_index.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(index[0].keys()))
        w.writeheader()
        w.writerows(index)

    # Fronts supplied directly by the project owner.
    owner_fronts = {"mega:Mega Garchomp Z"}
    write_log(rows, megas, have, index, owner_fronts, general)
    print(f"indexed {len(index)} files")


def write_log(rows, megas, have, index, owner_fronts, general):
    idx = {(e["dex"], e["form"], e["kind"]): e for e in index}
    added = [r for r in rows if r["in_renegade"] == "0"]
    L = ["# Imperial Platinum — Sprite Log\n",
         "> Generated by `tools/sprites/import_sprite_pack.py`. Tracks front / back / shiny-back sprites for every species "
         "added to Imperial Platinum and every Mega Evolution / Primal Reversion. Species already in Renegade Platinum keep "
         "their existing sprites and are not listed.\n",
         "## Sources\n",
         "- **DPPt Style Gen VI and Beyond** (provided by the project owner): Pokémon Essentials-format **back sprites only** "
         "(normal + shiny), 160×160 (2× the DS's 80×80). Artist credits are in `CITATIONS.md` and in the pack's `Credits.txt`.",
         "- **Mega Garchomp Z front + shiny front**: reference image provided by the project owner "
         "(`assets/sprites/reference/mega_garchomp_z_reference.png`; native-size copies in "
         "`assets/sprites/owner_supplied/mega_garchomp_z/`). It is a 4× upscale of a 120×120 sprite whose art is 116×95 px, "
         "so it does not fit Gen IV's 80×80 battle frame and needs a resize/redraw pass. Original artist: **unknown — needs attribution**.\n",
         "## Legend\n",
         "- ✅ available · ❌ missing (log and come back later) · ⚠️ available but needs work for the DS "
         "(more than 15 colours, or not a clean 2× upscale of an 80×80 frame).\n"]
    n_front = sum(1 for r in added if False)
    missing_back = [r for r in added if "back" not in have[r["dex"]]]
    L.append("## Summary\n")
    L.append(f"- Added species: **{len(added)}**")
    L.append(f"- Front sprites available: **0 / {len(added)}** (the pack has no fronts) — *all fronts still needed*.")
    L.append(f"- Back sprites available: **{len(added) - len(missing_back)} / {len(added)}**")
    mega_rows = [m for m in megas]
    mb = sum(1 for m in mega_rows if "back" in have["mega:" + m["form"]])
    L.append(f"- Mega / Primal forms: **{len(mega_rows)}**; back sprites available: **{mb}**; front sprites available: "
             f"**{sum(1 for m in mega_rows if 'mega:' + m['form'] in owner_fronts)}**\n")

    def status(dex, form, kind):
        e = idx.get((dex, form, kind))
        if not e:
            return "❌"
        return "✅" if e["ds_ready"] == "1" or e["ds_ready"] == 1 else f"⚠️ ({e['colours']} col)"

    L.append("## Mega Evolutions and Primal Reversions\n")
    L.append("| Form | Front | Back | Shiny back | Back artist(s) |")
    L.append("|---|---|---|---|---|")
    for m in mega_rows:
        k = "mega:" + m["form"]
        front = "⚠️ owner-supplied; 116×95 art on a 120×120 canvas — must be redrawn to fit the DS 80×80 frame" if k in owner_fronts else "❌"
        e = idx.get((m["dex"], m["form"], "back"))
        L.append(f"| {m['form']} | {front} | {status(m['dex'], m['form'], 'back')} | "
                 f"{status(m['dex'], m['form'], 'back_shiny')} | {e['artists'] if e else ''} |")
    L.append("")
    L.append("## Added species (Gen V–IX)\n")
    L.append("| # | Species | Front | Back | Shiny back | Back artist(s) |")
    L.append("|---|---|---|---|---|---|")
    for r in added:
        e = idx.get((r["dex"], r["name"], "back"))
        L.append(f"| {r['dex']} | {r['name']} | ❌ | {status(r['dex'], r['name'], 'back')} | "
                 f"{status(r['dex'], r['name'], 'back_shiny')} | {e['artists'] if e else ''} |")
    L.append("")
    L.append("## Missing back sprites (to find later)\n")
    L.append(", ".join(f"#{r['dex']} {r['name']}" for r in missing_back) + "\n")
    L.append("## Alternate / regional forms present in the pack (not yet used)\n")
    alts = sorted({(int(e["dex"]), e["form"]) for e in index if e["category"] in ("regional/alt", "alt_form", "gigantamax")})
    L.append(", ".join(f for _, f in alts) + "\n")
    if general:
        L.append("## Credit lines that could not be matched to a single species\n")
        for a, items in general.items():
            L.append(f"- {a}: " + "; ".join(items))
        L.append("")
    with open(os.path.join(ROOT, "docs", "SpriteLog.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(L))


if __name__ == "__main__":
    main()
