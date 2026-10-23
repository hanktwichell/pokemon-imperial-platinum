#!/usr/bin/env python3
"""Draw the Totems' overworld sprites (decision 18, docs/TotemTrials.md): the huge Pokémon standing at each Totem
trial's place, decomp/res/graphics/field_sprites/pokemon/totem_<species>.png.

Each is one 64x64 frame, like Platinum's Regigigas (field_sprites meson.build, field_sprites_textures_single_frame):
the Totem form's front sprite from PokeAPI's sprite repository, scaled down to fit when it's larger, centred and
standing on the bottom edge, with a one-pixel orange outline for the Totem aura. Index 0 is the transparent colour.

Usage: python3 tools/sprites/make_totem_overworld.py [/path/to/PokeAPI/sprites]
Without a local copy of https://github.com/PokeAPI/sprites the sprites are downloaded from GitHub.
"""
import io
import os
import sys
import urllib.request

from PIL import Image, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_DIR = os.path.join(ROOT, "decomp", "res", "graphics", "field_sprites", "pokemon")
URL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{}.png"
SIZE = 64
FIT = SIZE - 2           # room for the aura outline on each side
TRANSPARENT = (66, 107, 165)   # Regigigas's transparent colour
AURA = (255, 140, 40)
ART_COLOURS = 14         # + the aura and the transparent colour = 16

# The Totem form each species shows on the map, by PokeAPI Pokémon ID (pokemon.csv).
TOTEMS = {
    "gumshoos": 10121,     # gumshoos-totem
    "ribombee": 10150,     # ribombee-totem
    "vikavolt": 10122,     # vikavolt-totem
    "mimikyu": 10144,      # mimikyu-totem-disguised
    "marowak": 10149,      # marowak-totem (Alolan)
    "raticate": 10093,     # raticate-totem-alola
    "lurantis": 10128,     # lurantis-totem
    "araquanid": 10153,    # araquanid-totem
    "salazzle": 10129,     # salazzle-totem
    "kommo_o": 10146,      # kommo-o-totem
    "togedemaru": 10154,   # togedemaru-totem
}


def load(sprites_dir, pokeapi_id):
    if sprites_dir:
        return Image.open(os.path.join(sprites_dir, "sprites", "pokemon", f"{pokeapi_id}.png"))
    with urllib.request.urlopen(URL.format(pokeapi_id), timeout=30) as response:
        return Image.open(io.BytesIO(response.read()))


def overworld(src):
    art = src.convert("RGBA")
    art = art.crop(art.getbbox())
    scale = min(1.0, FIT / art.width, FIT / art.height)
    if scale < 1:
        art = art.resize((round(art.width * scale), round(art.height * scale)), Image.LANCZOS)
    # Hard edges: the DS has no partial transparency.
    alpha = art.getchannel("A").point(lambda a: 255 if a >= 128 else 0)
    art.putalpha(alpha)
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    canvas.paste(art, ((SIZE - art.width) // 2, SIZE - 1 - art.height), art)

    opaque = canvas.getchannel("A")
    aura = opaque.filter(ImageFilter.MaxFilter(3))
    rgb = Image.new("RGB", (SIZE, SIZE), TRANSPARENT)
    rgb.paste(canvas.convert("RGB"), (0, 0), opaque)
    quantized = rgb.quantize(colors=ART_COLOURS + 1, method=Image.MEDIANCUT, dither=Image.NONE)
    # Move the art's colours up to 2.., leaving 0 transparent and 1 the aura.
    pal = quantized.getpalette()[:3 * (ART_COLOURS + 1)]
    colours = [tuple(pal[i:i + 3]) for i in range(0, len(pal), 3)]
    out = Image.new("P", (SIZE, SIZE), 0)
    palette = list(TRANSPARENT) + list(AURA)
    remap, used = {}, []
    for y in range(SIZE):
        for x in range(SIZE):
            if opaque.getpixel((x, y)):
                c = quantized.getpixel((x, y))
                if c not in remap:
                    remap[c] = 2 + len(used)
                    used.append(colours[c])
                out.putpixel((x, y), remap[c])
            elif aura.getpixel((x, y)):
                out.putpixel((x, y), 1)
    for c in used:
        palette += list(c)
    palette += [0, 0, 0] * (16 - len(palette) // 3)
    out.putpalette(palette)
    return out


def main():
    sprites_dir = sys.argv[1] if len(sys.argv) > 1 else None
    for species, pokeapi_id in TOTEMS.items():
        out = overworld(load(sprites_dir, pokeapi_id))
        out.save(os.path.join(OUT_DIR, f"totem_{species}.png"), bits=4)
    print(f"wrote {len(TOTEMS)} Totem overworld sprites to {OUT_DIR}")


if __name__ == "__main__":
    main()
