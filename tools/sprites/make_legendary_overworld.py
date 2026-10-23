#!/usr/bin/env python3
"""Draw the overworld sprites of the post-game legendaries (docs/PostgameLegendaries.md, the Chronicles): the
Pokémon standing at each static encounter, decomp/res/graphics/field_sprites/pokemon/legendary_<species>.png.

Each is one 64x64 frame like the Totems' (make_totem_overworld.py, which draws them): the front sprite from PokeAPI's
sprite repository, scaled down to fit when it's larger, standing on the bottom edge, without the Totem aura. These are
placeholders until the owner's overworld art arrives (E12).

Usage: python3 tools/sprites/make_legendary_overworld.py [/path/to/PokeAPI/sprites]
Without a local copy of https://github.com/PokeAPI/sprites the sprites are downloaded from GitHub.
"""
import os
import sys

from make_totem_overworld import OUT_DIR, load, overworld

# The species shown on the map, by PokeAPI Pokémon ID (pokemon.csv), in the order their encounters were added.
LEGENDARIES = {
    "virizion": 640,
    "terrakion": 639,
    "cobalion": 638,
    "keldeo": 647,
    "meloetta": 648,
    "genesect": 649,
    "reshiram": 643,
    "zekrom": 644,
    "kyurem": 646,
    "landorus": 645,
    "enamorus": 905,
    "victini": 494,
    "xerneas": 716,
    "yveltal": 717,
    "zygarde": 718,
    "diancie": 719,
    "hoopa": 720,
    "volcanion": 721,
    "tapu_koko": 785,
    "tapu_lele": 786,
    "tapu_bulu": 787,
    "tapu_fini": 788,
    "cosmog": 789,
    "necrozma": 800,
    "nihilego": 793,
    "buzzwole": 794,
    "pheromosa": 795,
    "xurkitree": 796,
    "celesteela": 797,
    "kartana": 798,
    "guzzlord": 799,
    "stakataka": 805,
    "blacephalon": 806,
}


def main():
    sprites_dir = sys.argv[1] if len(sys.argv) > 1 else None
    for species, pokeapi_id in LEGENDARIES.items():
        out = overworld(load(sprites_dir, pokeapi_id), aura=False)
        out.save(os.path.join(OUT_DIR, f"legendary_{species}.png"), bits=4)
    print(f"wrote {len(LEGENDARIES)} legendary overworld sprites to {OUT_DIR}")


if __name__ == "__main__":
    main()
