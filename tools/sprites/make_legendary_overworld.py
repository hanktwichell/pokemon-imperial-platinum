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
    "poipole": 803,
    "type_null": 772,
    "magearna": 801,
    "marshadow": 802,
    "zeraora": 807,
    "meltan": 808,
    "melmetal": 809,
    "zacian": 888,
    "zamazenta": 889,
    "eternatus": 890,
    "kubfu": 891,
    "zarude": 893,
    "regieleki": 894,
    "regidrago": 895,
    "calyrex": 898,
    "glastrier": 896,
    "spectrier": 897,
    "wo_chien": 1001,
    "chien_pao": 1002,
    "ting_lu": 1003,
    "chi_yu": 1004,
    "okidogi": 1014,
    "munkidori": 1015,
    "fezandipiti": 1016,
    "pecharunt": 1025,
    "ogerpon": 1017,
    "great_tusk": 984,
    "scream_tail": 985,
    "brute_bonnet": 986,
    "flutter_mane": 987,
    "slither_wing": 988,
    "sandy_shocks": 989,
    "roaring_moon": 1005,
    "walking_wake": 1009,
    "gouging_fire": 1020,
    "raging_bolt": 1021,
    "iron_treads": 990,
    "iron_bundle": 991,
    "iron_hands": 992,
    "iron_jugulis": 993,
    "iron_moth": 994,
    "iron_thorns": 995,
    "iron_valiant": 1006,
    "iron_leaves": 1010,
    "iron_boulder": 1022,
    "iron_crown": 1023,
    "koraidon": 1007,
    "miraidon": 1008,
    "terapagos": 1024,
}


def main():
    sprites_dir = sys.argv[1] if len(sys.argv) > 1 else None
    for species, pokeapi_id in LEGENDARIES.items():
        out = overworld(load(sprites_dir, pokeapi_id), aura=False)
        out.save(os.path.join(OUT_DIR, f"legendary_{species}.png"), bits=4)
    print(f"wrote {len(LEGENDARIES)} legendary overworld sprites to {OUT_DIR}")


if __name__ == "__main__":
    main()
