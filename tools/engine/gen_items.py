#!/usr/bin/env python3
"""Add Sovereign's new items to the decomp (milestone E7).

Reads data/items_sovereign.yaml (which items) and data/megas.csv (the Mega Stones), takes names, prices, fling power
and descriptions from PokeAPI, and writes for each new item:
  decomp/res/items/data/<stem>.json   item data in Platinum's format (see res/items/data/choice_band.json)
and appends the item constants to decomp/generated/items.txt (after ITEM_SECRET_KEY, before MAX_ITEMS).

With PokeAPI's sprite repository it also writes each item's bag icon (decomp/res/items/icons/<stem>.png + .pal,
32x32 with 15 colours + transparent, converted from PokeAPI's item sprite) and lists it in res/items/icons/meson.build
and res/items/item_icon.order. Items without a sprite keep the placeholder "none" icon.

So far every new item has no hold effect (HOLD_EFFECT_NONE) and, apart from evolution items
(ITEM_USE_FUNC_EVO_STONE), no field use. Battle effects, Mint/Ability Capsule use functions and shops come later.

Running it again rewrites the generated files; the item list in items.txt is only extended once.

Usage: python3 tools/engine/gen_items.py /path/to/pokeapi/data/v2/csv [/path/to/PokeAPI/sprites]
"""
import csv
import json
import os
import re
import sys

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
ITEMS_TXT = os.path.join(DECOMP, "generated", "items.txt")
DATA_DIR = os.path.join(DECOMP, "res", "items", "data")
ICON_DIR = os.path.join(DECOMP, "res", "items", "icons")
ICON_ORDER = os.path.join(DECOMP, "res", "items", "item_icon.order")
ICON_MESON = os.path.join(ICON_DIR, "meson.build")
MART_HEADER = os.path.join(DECOMP, "include", "data", "sovereign_mart_items.h")
# Prices for shop items that have none in PokeAPI (they aren't sold in the official games).
PRICES = {"Booster Energy": 10000}
ICON_SIZE = 32
ICON_ART = 24      # Platinum draws item art in the top-left 24x24 of the 32x32 icon, centred on (11.5, 11.5)
# PokeAPI sprite file names that don't follow the item name.
SPRITE_NAMES = {"N-Solarizer": "n-solarizer--merge", "N-Lunarizer": "n-lunarizer--merge",
                "Ultranecrozium Z": "ultranecrozium-z--bag"}

NAME_LEN = 16       # the bag's name buffer holds 18 characters; what fits on screen is checked in game
DESC_PX = 214       # pixel width of Platinum's widest description line (the box cuts off a 219-pixel line)
DESC_LINES = 3
# Names over NAME_LEN characters, shortened (the owner can change these).
SHORT_NAMES = {
    "Unremarkable Teacup": "Unremark. Teacup",
    "Masterpiece Teacup": "Masterpc. Teacup",
    "Scroll of Darkness": "Darkness Scroll",
}
# Descriptions for items PokeAPI has no English text for.
DESCRIPTIONS = {
    "Booster Energy": "An item to be held by a Pokémon. It powers up the Protosynthesis or Quark Drive ability once.",
    "Ability Shield": "An item to be held by a Pokémon. It protects the holder's Ability from being changed or nullified.",
    "Clear Amulet": "An item to be held by a Pokémon. It stops other Pokémon from lowering the holder's stats.",
    "Mirror Herb": "An item to be held by a Pokémon. It copies one round of stat boosts an opponent gets.",
    "Punching Glove": "An item to be held by a Pokémon. It powers up punches and keeps them from making contact.",
    "Covert Cloak": "An item to be held by a Pokémon. It protects the holder from the added effects of moves.",
    "Loaded Dice": "An item to be held by a Pokémon. Its multistrike moves are more likely to hit many times.",
    "Fairy Feather": "An item to be held by a Pokémon. This feather boosts the power of Fairy-type moves.",
    "Teal Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Teal Mask form.",
    "Wellspring Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Wellspring Mask form.",
    "Hearthflame Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Hearthflame Mask form.",
    "Cornerstone Mask": "A mask worn by Ogerpon. When Ogerpon holds it, it takes on the Cornerstone Mask form.",
    "Adamant Crystal": "A large, glowing gem. When held by Dialga, it changes into its Origin Forme.",
    "Lustrous Globe": "A large, glowing orb. When held by Palkia, it changes into its Origin Forme.",
    "Griseous Core": "A large, glowing gem. When held by Giratina, it changes into its Origin Forme.",
    "Masterpiece Teacup": "A peculiar teacup that makes certain species of Pokémon evolve. A rare, genuine piece.",
    "Syrupy Apple": "A peculiar apple that makes certain species of Pokémon evolve. It is coated in sticky syrup.",
    "Unremarkable Teacup": "A peculiar teacup that makes certain species of Pokémon evolve. It looks like any other.",
    "Black Augurite": "A glassy black stone that makes certain species of Pokémon evolve.",
    "Peat Block": "A block of peat from deep in the earth. It makes certain species of Pokémon evolve.",
    "Auspicious Armor": "Armor that carries the wish for a child's happy growth. It makes certain Pokémon evolve.",
    "Malicious Armor": "Armor steeped in a grudge. It makes certain species of Pokémon evolve.",
    "Leader’s Crest": "A shard of a blade worn by a pack leader. It makes certain species of Pokémon evolve.",
    "Metal Alloy": "A peculiar metal of several layers. It makes certain species of Pokémon evolve.",
    "Scroll of Darkness": "An old scroll on the art of the dark. Kubfu that reads it evolves into Single Strike Urshifu.",
    "Scroll of Waters": "An old scroll on the art of water. Kubfu that reads it evolves into Rapid Strike Urshifu.",
}
PLURALS = {"Heavy-Duty Boots": "Heavy-Duty Boots", "Protective Pads": "Protective Pads", "Loaded Dice": "Loaded Dice",
           "Punching Glove": "Punching Gloves", "Utility Umbrella": "Utility Umbrellas", "Peat Block": "Peat Blocks",
           "DNA Splicers": "DNA Splicers", "Reins of Unity": "Reins of Unity"}


def rd(api, name):
    return list(csv.DictReader(open(os.path.join(api, name), encoding="utf-8")))


def stem_of(name):
    s = name.lower().replace("’", "").replace("'", "").replace("é", "e").replace(".", "")
    return re.sub(r"[^a-z0-9]+", "_", s).strip("_")


def load_font():
    """Glyph widths (pixels) of Platinum's message font, keyed by character."""
    widths = json.load(open(os.path.join(DECOMP, "res", "fonts", "font_message.json")))["glyphWidths"]
    chars = {}
    for line in open(os.path.join(DECOMP, "tools", "msgenc", "charmap.txt"), encoding="utf-8"):
        code, _, char = line.rstrip("\n").partition("=")
        if len(char) == 1 and char not in chars:
            try:
                chars[char] = widths[int(code, 16) - 1]
            except (ValueError, IndexError):
                pass
    return chars


FONT = load_font()


def px(text):
    return sum(FONT[c] for c in text)


def wrap_px(text, width):
    lines, line = [], ""
    for word in text.split(" "):
        candidate = word if not line else line + " " + word
        if px(candidate) <= width:
            line = candidate
        else:
            lines.append(line)
            line = word
    return lines + [line]


def wrap(text):
    # Platinum's character map has ’ but no ASCII apostrophe.
    text = " ".join(text.replace("\u00ad", "").replace("'", "’").split())
    for cut in range(len(text), 0, -1):
        part = text[:cut]
        if cut < len(text) and not part.endswith("."):
            continue
        lines = wrap_px(part, DESC_PX)
        if len(lines) <= DESC_LINES:
            return [l + "\n" for l in lines[:-1]] + [lines[-1]]
    raise SystemExit(f"description doesn't fit in {DESC_LINES} lines: {text}")


def pixels(img):
    return list(img.get_flattened_data() if hasattr(img, "get_flattened_data") else img.getdata())


def make_icon(path):
    """Convert a PokeAPI item sprite to Platinum's icon format: 32x32, index 0 transparent, 15 colours."""
    from PIL import Image
    art = Image.open(path).convert("RGBA")
    box = art.getbbox()
    if box:
        art = art.crop(box)
    if max(art.size) > ICON_ART:
        scale = ICON_ART / max(art.size)
        art = art.resize((max(1, round(art.width * scale)), max(1, round(art.height * scale))), Image.LANCZOS)
    canvas = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    # Centre in the 24x24 area the game shows (bag preview box, shop), like Platinum's own icons.
    canvas.paste(art, ((ICON_ART - art.width) // 2, (ICON_ART - art.height) // 2), art)
    opaque = [p[3] >= 128 for p in pixels(canvas)]
    rgb = Image.new("RGB", canvas.size)
    rgb.putdata([p[:3] if o else (0, 0, 0) for p, o in zip(pixels(canvas), opaque)])
    # Quantize the opaque pixels only, then shift their indices up by one so index 0 is transparent.
    sample = Image.new("RGB", (sum(opaque) or 1, 1))
    sample.putdata([p for p, o in zip(pixels(rgb), opaque) if o] or [(0, 0, 0)])
    quant = sample.quantize(colors=15, method=Image.MEDIANCUT, dither=Image.NONE)
    flat = (quant.getpalette() or []) + [0] * 45
    palette = [tuple(flat[i * 3:i * 3 + 3]) for i in range(15)]
    mapped = rgb.quantize(palette=quant, dither=Image.NONE)
    out = Image.new("P", canvas.size)
    out.putdata([idx + 1 if o else 0 for idx, o in zip(pixels(mapped), opaque)])
    colors = [(180, 180, 180)] + palette  # Platinum's icons use this grey for the transparent colour
    out.putpalette([c for col in colors for c in col])
    return out, colors


def write_icon(stem, path):
    img, colors = make_icon(path)
    img.save(os.path.join(ICON_DIR, stem + ".png"), bits=4)  # 4-bit like Platinum's icons; ncgr expects 4bpp
    with open(os.path.join(ICON_DIR, stem + ".pal"), "w", newline="\r\n") as f:
        f.write("JASC-PAL\n0100\n256\n")
        for r, g, b in colors + [(0, 0, 0)] * (256 - len(colors)):
            f.write(f"{r} {g} {b}\n")


def update_block(text, start, end, lines, indent, label):
    """Replace the generator's block between two marker comments (adding it before `end` if missing)."""
    begin = f"{indent}# Sovereign items ({label}): generated by tools/engine/gen_items.py\n"
    finish = f"{indent}# end of Sovereign items ({label})\n"
    block = begin + "".join(lines) + finish
    if begin in text:
        i = text.index(begin)
        j = text.index(finish, i) + len(finish)
        return text[:i] + block + text[j:]
    i = text.index(start)
    j = text.index(end, i) + 1  # just after the last list line's newline
    return text[:j] + block + text[j:]


def item_lists(spec):
    def flat(o):
        if isinstance(o, list):
            for x in o:
                yield from flat(x)
        elif isinstance(o, dict):
            for v in o.values():
                yield from flat(v)
        elif isinstance(o, str):
            yield o
    groups = {
        "key": list(flat(spec["key_items"])) + ["Scroll of Darkness", "Scroll of Waters"],
        "evolution": [n for n in flat(spec["evolution_items"]) if not n.startswith("Scroll")] + ["Strawberry Sweet"],
        "training": list(flat(spec["training"])),
    }
    order = []
    for k in ("held_items", "gems", "form_items", "evolution_items", "training", "key_items"):
        for n in flat(spec[k]):
            if n not in order:
                order.append(n)
    return order, groups


def main():
    api = sys.argv[1]
    spec = yaml.safe_load(open(os.path.join(ROOT, "data", "items_sovereign.yaml"), encoding="utf-8"))
    order, groups = item_lists(spec)
    megas = []
    for r in csv.DictReader(open(os.path.join(ROOT, "data", "megas.csv"), encoding="utf-8")):
        t = r["trigger_item"]
        if t not in ("Blue Orb", "Red Orb") and "move" not in t and t not in megas:
            megas.append(t)

    names = {r["item_id"]: r["name"] for r in rd(api, "item_names.csv") if r["local_language_id"] == "9"}
    by_name = {v: k for k, v in names.items()}
    items = {r["id"]: r for r in rd(api, "items.csv")}
    flavor = {}
    for r in rd(api, "item_flavor_text.csv"):
        if r["language_id"] == "9":
            flavor.setdefault(r["item_id"], {})[int(r["version_group_id"])] = r["flavor_text"]

    sprites = sys.argv[2] if len(sys.argv) > 2 else None
    icons = []
    if sprites:
        for name in order + megas:
            stem = stem_of(name)
            path = os.path.join(sprites, "sprites", "items", SPRITE_NAMES.get(name, stem.replace("_", "-")) + ".png")
            if os.path.exists(path):
                write_icon(stem, path)
                icons.append(stem)
            else:
                print(f"no PokeAPI sprite for {name}; it keeps the placeholder icon")
    else:
        icons = [stem_of(n) for n in order + megas if os.path.exists(os.path.join(ICON_DIR, stem_of(n) + ".png"))]

    consts = [l.strip() for l in open(ITEMS_TXT) if l.strip()]
    existing = set(consts[:consts.index("ITEM_SECRET_KEY") + 1])  # Platinum's own items
    new_consts = []
    missing = []
    for name in order + megas:
        display = SHORT_NAMES.get(name, name).replace("'", "’")
        if len(display) > NAME_LEN:
            raise SystemExit(f"{name}: name over {NAME_LEN} characters, add it to SHORT_NAMES")
        stem = stem_of(name)
        const = "ITEM_" + stem.upper()
        if const in existing:
            raise SystemExit(f"{const} already exists in items.txt")
        iid = by_name.get(name)
        row = items.get(iid, {})
        texts = flavor.get(iid, {})
        if texts:
            desc = wrap(texts[max(texts)])
        elif name in megas:
            desc = wrap("One of a variety of mysterious Mega Stones. It lets its holder Mega Evolve in battle.")
        elif name in DESCRIPTIONS:
            desc = wrap(DESCRIPTIONS[name])
        else:
            missing.append(name)
            desc = ["?"]
        is_key = name in groups["key"]
        evo = name in groups["evolution"] or name.startswith("Scroll")
        # Mints and the Ability Capsule/Patch open the party menu like medicine; the party menu applies them
        # (PartyMenu_TryUseSovereignTrainingItem in src/applications/party_menu/main.c).
        training = name in groups["training"]
        data = {
            "name": display,
            "plural": PLURALS.get(name, display if display.endswith("s") else display + "s"),
            "article": "an" if display[0] in "AEIOU" else "a",
            "description": desc,
            "icon": ({"sprite": stem + "_NCGR", "palette": stem + "_NCLR"} if stem in icons
                     else {"sprite": "none_NCGR", "palette": "none_NCLR"}),
            "gbaID": "GBA_ITEM_NONE",
            "price": PRICES.get(name, int(row.get("cost") or 0)),
            "effectParam": 0,
            "holdEffect": "HOLD_EFFECT_NONE",
            "pluckEffect": "PLUCK_EFFECT_NONE",
            "flingEffect": "FLING_EFFECT_NONE",
            "flingPower": int(row.get("fling_power") or 0),
            "naturalGiftPower": 0,
            "naturalGiftType": None,
            "preventToss": is_key,
            "canRegister": False,
            "fieldPocket": "POCKET_KEY_ITEMS" if is_key else "POCKET_MEDICINE" if training else "POCKET_ITEMS",
            "battlePocket": "BATTLE_POCKET_MASK_NONE",
            "fieldUseFunc": ("ITEM_USE_FUNC_EVO_STONE" if evo else "ITEM_USE_FUNC_HEALING" if training
                             else "ITEM_USE_FUNC_NONE"),
            "battleUseCategory": "BATTLE_USE_CATEGORY_NONE",
            "itemUseParams": {} if evo else None,
        }
        with open(os.path.join(DATA_DIR, stem + ".json"), "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")
        new_consts.append(const)

    if missing:
        raise SystemExit(f"no description in PokeAPI (add to DESCRIPTIONS): {missing}")

    # Sovereign's own items, appended after the PokeAPI ones.
    for custom in spec.get("custom_items", []):
        stem = stem_of(custom["name"])
        uses = {"bag_message": "ITEM_USE_FUNC_BAG_MESSAGE", None: "ITEM_USE_FUNC_NONE"}
        data = {
            "name": custom["name"],
            "plural": custom["plural"],
            "article": "an" if custom["name"][0] in "AEIOU" else "a",
            "description": wrap(custom["description"]),
            "icon": {"sprite": custom["icon"]["sprite"] + "_NCGR", "palette": custom["icon"]["palette"] + "_NCLR"},
            "gbaID": "GBA_ITEM_NONE",
            "price": custom.get("price", 0),
            "effectParam": 0,
            "holdEffect": "HOLD_EFFECT_NONE",
            "pluckEffect": "PLUCK_EFFECT_NONE",
            "flingEffect": "FLING_EFFECT_NONE",
            "flingPower": 0,
            "naturalGiftPower": 0,
            "naturalGiftType": None,
            "preventToss": custom["pocket"] == "key",
            "canRegister": False,
            "fieldPocket": {"key": "POCKET_KEY_ITEMS", "items": "POCKET_ITEMS"}[custom["pocket"]],
            "battlePocket": "BATTLE_POCKET_MASK_NONE",
            "fieldUseFunc": uses[custom.get("use")],
            "battleUseCategory": "BATTLE_USE_CATEGORY_NONE",
            "itemUseParams": None,
        }
        with open(os.path.join(DATA_DIR, stem + ".json"), "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")
        new_consts.append("ITEM_" + stem.upper())

    meson = open(ICON_MESON).read()
    meson = update_block(meson, "item_icon_pngs = files(", "\n)", [f"    '{s}.png',\n" for s in icons], "    ", "png")
    meson = update_block(meson, "item_icon_pals = files(", "\n)", [f"    '{s}.pal',\n" for s in icons], "    ", "pal")
    with open(ICON_MESON, "w") as f:
        f.write(meson)
    order_lines = [l for l in open(ICON_ORDER).read().splitlines() if l]
    vanilla = order_lines[:order_lines.index("unused_710.NCLR") + 1]
    with open(ICON_ORDER, "w") as f:
        f.write("\n".join(vanilla + [f"{s}.{ext}" for s in icons for ext in ("NCGR", "NCLR")]) + "\n")
    added = [c for c in new_consts if c not in consts]
    if added:
        i = consts.index("MAX_ITEMS")
        consts = consts[:i] + added + consts[i:]
        with open(ITEMS_TXT, "w") as f:
            f.write("\n".join(consts) + "\n")
    # Shop stock: the Veilstone Department Store sells the new held items and Gems (owner request), from the 2F
    # vitamin clerk's menu (res/field/scripts/scripts_veilstone_store_2f.s).
    def stock(name, entries):
        lines = [f"static const u16 {name}[] = {{\n"] + [f"    ITEM_{stem_of(n).upper()},\n" for n in entries]
        return "".join(lines) + "    SHOP_ITEM_END\n};\n"
    with open(MART_HEADER, "w") as f:
        f.write("// Generated by tools/engine/gen_items.py from data/items_sovereign.yaml. Do not edit.\n"
                "#ifndef POKEPLATINUM_DATA_SOVEREIGN_MART_ITEMS_H\n#define POKEPLATINUM_DATA_SOVEREIGN_MART_ITEMS_H\n\n"
                + stock("VeilstoneDeptStoreStock_2F_HeldItems", spec["held_items"]) + "\n"
                + stock("VeilstoneDeptStoreStock_2F_Gems", spec["gems"])
                + "\n#endif // POKEPLATINUM_DATA_SOVEREIGN_MART_ITEMS_H\n")
    for n in spec["held_items"] + spec["gems"]:
        price = PRICES.get(n) or int(items.get(by_name.get(n), {}).get("cost") or 0)
        if price == 0:
            raise SystemExit(f"{n} is sold at Veilstone but has no price: add it to PRICES")

    print(f"items written: {len(new_consts)} (last item ID {consts.index(new_consts[-1])}); icons: {len(icons)}")


if __name__ == "__main__":
    main()
