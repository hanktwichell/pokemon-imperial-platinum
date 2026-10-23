# Citations & Credits

Pokémon Sovereign Platinum is a free, non-commercial fan project made for friends. It isn't affiliated with or endorsed
by Nintendo, Creatures, Game Freak or The Pokémon Company. Pokémon and all related names are trademarks of their
respective owners. No ROM is distributed; players must supply their own legally dumped copy of Pokémon Platinum.

Every external asset or dataset used in this repository is listed here. **When you add an asset, add its citation in
the same commit.**

## Base game

| What | Source | Credit / licence |
|---|---|---|
| Pokémon Renegade Platinum v1.3.0 (patches + documentation in `RenegadePlatinumV130/`) | https://projectpokemon.org/home/forums/topic/52294-pok%C3%A9mon-renegade-platinum/ | **Drayano**. Used as the base with Drayano's permission (per the project owner). Renegade credits Mikelan98 for the accurate Pokédex encounter-location feature. |

## Engine

| What | Source | Credit / licence |
|---|---|---|
| Game engine source (`decomp/`, git subtree) | pret/pokeplatinum — https://github.com/pret/pokeplatinum | pret contributors. Sovereign's engine is built on their decompilation. Pokémon Platinum © Nintendo / Game Freak / The Pokémon Company. |
| Build overlays for rapidjson and yyjson (`decomp/subprojects/packagefiles/`) | Meson WrapDB — https://github.com/mesonbuild/wrapdb | WrapDB contributors, MIT. |

## Data

| What | Source | Credit / licence |
|---|---|---|
| Species, stats, types, abilities, evolutions, learnsets, Pokédex text, Mega Evolution data, item and Mega Stone names, item prices and descriptions (`data/species.csv`, `data/megas.csv`, validation in `tools/design/*`; in the ROM via `tools/engine/gen_*.py`) | PokeAPI — https://github.com/PokeAPI/pokeapi (`data/v2/csv`) | PokeAPI contributors, BSD-3-Clause. Pokémon data © Nintendo / Game Freak / The Pokémon Company. |
| Vanilla Platinum field-item script names and hidden-item list (used to choose and validate Mega Stone placements) | pret/pokeplatinum decompilation — https://github.com/pret/pokeplatinum | pret contributors. |
| Pokémon Champions battle rules (`docs/BattleMechanics.md`, `tools/engine/apply_champions_moves.py`): values read from Showdown's Champions mod, no code copied | Pokémon Showdown — https://github.com/smogon/pokemon-showdown (`data/mods/champions/`, HEAD `8476966`, 2026-10-22) | Smogon / Pokémon Showdown contributors, MIT licence; the Champions data credits the research of Kaphotics and Anubis. |
| Pokémon Champions rule research (cross-checks) | Serebii (serebii.net/pokemonchampions), Bulbapedia, Smogon's "Champions battle mechanics research" thread, Victory Road VGC | Their respective authors; facts only, no text copied. |

## Sprites

### Artwork sourcing
Finding and gathering the sprite artwork used in Sovereign Platinum:

- **Nolan Herkomer**

### Shiny sprites
Creating and modifying many of the shiny sprites:

- **Nolan Herkomer**

### "DPPt Style Gen VI and Beyond" sprite pack (back sprites, normal + shiny)
Location: `assets/sprites/packs/dppt_gen6_and_beyond/` (Pokémon Essentials v19+ layout, kept unmodified).
Supplied by the project owner. The pack's own `Credits.txt` is kept verbatim next to the sprites. Per-file artist
attribution is in `data/sprite_index.csv` and `docs/SpriteLog.md`.

Contributors named in the pack (please thank and credit them):

- **Dreadwing93**: all Unova Pokémon (republished by Aki); most Kalos lines (Chespin, Fennekin, Froakie, Bunnelby, Fletchling, Scatterbug/Vivillon, Litleo, Flabébé, Honedge, Spritzee, Inkay, Skrelp, Helioptile, Tyrunt, Amaura, Carbink) — https://www.deviantart.com/dreadwing93/gallery/50014648/pokemon
- **Prodigal96**: Alolan/Galarian forms, many Galar and Alola Pokémon and Ultra Beasts, many Megas (Venusaur, Charizard X/Y, Blastoise, Beedrill, Pidgeot, Alakazam, Gengar, Kangaskhan, Pinsir, Gyarados, Aerodactyl, Mewtwo X/Y, Ampharos, Scizor, Houndoom, Sceptile, Blaziken, Swampert, Manectric, Altaria, Banette, Absol), Primal Kyogre/Groudon, Gigantamax forms, Barbaracle edits — https://www.deviantart.com/prodigal96
- **MM980**: Dartrix, Decidueye, Ash-Greninja, Eternal Floette, Barbaracle, Goodra, Trevenant, Xerneas, Yveltal, Zygarde forms, Volcanion, Galarian Yamask, Mega Gardevoir
- **44tim44**: Sylveon — https://www.deviantart.com/44tim44
- **Gnomowladny**: Mega Sableye, Mega Mawile, Mega Glalie, Mega Lopunny, Mega Audino, Rowlet, Mimikyu — https://www.deviantart.com/gnomowladny
- **MetalFlygon** (republished by Zygoat): Rockruff, Salandit, Meltan, Nickit, Clobbopus lines, Sirfetch'd, Mr. Rime, many Alolan and Galarian forms
- **Zygoat**: Mega Heracross, Mega Medicham, Mega Garchomp, Mega Lucario, Obstagoon, Alcremie, Pikachu Libre, Galarian Zigzagoon/Linoone
- **WolfPP**: Kubfu line, Dreepy, Inteleon, Galarian Zapdos/Moltres
- **lichenprincess**: Thwackey, Raboot, Drizzile, Hatterene, Drakloak, Dragapult, Regieleki, Galarian Articuno, Dhelmise
- **BiggusWeeabus**: Rookidee line
- **ChromusSama**: Phantump
- **briochee**: Hawlucha, Kleavor, Ursaluna, Litten, Incineroar, Popplio line, Pikipek line, Yungoos line, Grubbin line, Morelull, Jangmo-o line, Zeraora
- **Mak**: Skiddo, Crabrawler, Mudbray line, Dewpider line, Sizzlipede line, Sinistea, Impidimp, Morgrem, Frosmoth, Galarian Stunfisk, Goomy/Sliggoo forms
- **KRLW890**: Rolycoly line, Applin line, Perrserker, Cursola, Hisuian Typhlosion, Hisuian Decidueye, Clauncher line
- **Loafus022**: Basculegion forms
- **Sopita_Yorita**: Hisuian Growlithe
- **lennybitao**: Rillaboom, Hisuian Arcanine, Zeraora, Pancham, Aromatisse, Swirlix line, Noibat line, Hoopa (Unbound) — https://www.deviantart.com/lennybitao
- **Scept**: Sprigatito, Fuecoco, Quaxly
- **Travis**: Sneasler, Overqwil
- **MrEoncito**: Grookey, Scorbunny, Cinderace, Sobble, Mega Latias, Mega Latios, Mega Gallade, Silvally
- **IDesbas / Angy**: Mega Steelix, Mega Tyranitar — https://twitter.com/IDesbas
- **I'mBadAtStuff**: Dedenne
- **SkidMarc25**: Pangoro
- **Mesayas**: Cetitan, Cyclizar
- **PorousMist326**: Runerigus, Marshadow, Galarian Darumaka line, Skwovet line, Blipbug line, Torracat, Sandygast line, Cutiefly, Binacle, Klefki, Xerneas forms, Yveltal, Zygarde, Hoopa, Mega Sharpedo, Hisuian Qwilfish, White-Striped Basculin, missing shinies, recolour edits, and compiling the pack
- Special thanks (from the pack): **leParagon** (https://www.deviantart.com/leparagon), the **DS-style Gen VII and Beyond Pokémon Sprite Repository** (https://www.pokecommunity.com/showthread.php?t=368703), and **Smogon Art Projects** (https://www.smogon.com/forums/forums/smeargles-laptop.325/), for inspiration and bases of many sprites.

A few files in the pack aren't individually credited in its `Credits.txt` (e.g. Bounsweet line, Espurr, Falinks,
Diancie, Mega Salamence, Mega Slowbro). They're marked in `data/sprite_index.csv`; we will add credits if we find them.

### "Gen5-9 Sprites" part 1 (fronts, backs, some shinies for #494–1025)
Location: `assets/sprites/packs/gen5_9_part1/` (`NNNN-Name/{front,back,shiny_front,shiny_back}.png`, kept as supplied).
Compiled and supplied by the project owner from two sources (per the pack's README):

- **hg-engine DS-style sprite set** ("GenIV_Style_Sprites_Gen5-9"), the 80×80 files: BluRosie and the hg-engine
  contributors and sprite artists — https://github.com/BluRosie/hg-engine. Per-sprite artist credits are kept in the
  hg-engine project; **we still need to copy the matching credit list into this file.**
- **Smogon Sprite Project** (Gen 6/7/8 archives), the 96×96 files: the Smogon Sprite Project contributors —
  https://www.smogon.com/forums/forums/smeargles-laptop.325/. **Per-sprite artist credits still needed.**

The owner's README notes a part 2 (257 shiny sprites from the Smogon links) that hasn't been added yet.

### Placeholder box/party icons for #494–1025
Location: `assets/sprites/icons_placeholder/` (converted by `tools/sprites/make_placeholder_icons.py`; per-file source URL in
`data/icon_placeholders.csv`). Source: **PokeAPI sprites** — https://github.com/PokeAPI/sprites (Gen VII USUM icons for
#494–809, Sword/Shield icons for #810–898, Scarlet/Violet icons for #899–1025). The icon art is © Nintendo / Game Freak /
The Pokémon Company; PokeAPI hosts it. In the ROM as `decomp/res/pokemon/<species>/icon.png` (written by
`tools/engine/gen_new_species.py`). **Placeholders only**, to be replaced by DS-style icons.

### Item icons for the 245 new items (#468–712)
Location: `decomp/res/items/icons/<item>.png` + `.pal`, converted by `tools/engine/gen_items.py` (reduced to 15 colours
plus transparent, at most 24×24 px). Source: **PokeAPI sprites**, https://github.com/PokeAPI/sprites (commit
`97a7832`), `sprites/items/<item>.png`. The item art is © Nintendo / Game Freak / The Pokémon Company; PokeAPI hosts
it. **Placeholders**, to be replaced by DS-style icons where the owner wants.

### Battle MEGA button and HP-bar Mega symbol
`decomp/res/graphics/battle/interface/mega_button.png` and the Mega symbol tile at the end of
`decomp/res/graphics/battle/healthbox/healthbox_parts.png` are original art, drawn pixel by pixel by
`tools/sprites/make_mega_button.py` (no source image). The Mega Stone shown on the button in battle is the item icon
above.

## Audio

### Cries for #494–1025 (and form cries)
Source: **PokeAPI cries** — https://github.com/PokeAPI/cries (commit `b3a9044bb839`), `cries/pokemon/latest/<id>.ogg` and
`cries/pokemon/legacy/<id>.ogg`. The cry audio is © Nintendo / Game Freak / The Pokémon Company; PokeAPI hosts it.
Converted copies for the DS will go in `assets/audio/cries/`. Tracked in `docs/CryChecklist.xlsx`
(`tools/audio/gen_cry_checklist.py`).

### Mega Garchomp Z (front + shiny front)
`assets/sprites/reference/mega_garchomp_z_reference.png`, supplied by the project owner. Source: "Custom Sprite | Mega
Garchomp Z" by **thesonicgameryt** on DeviantArt —
https://www.deviantart.com/thesonicgameryt/art/Custom-Sprite-%7C-Mega-Garchomp-Z-1275121452

## Design inspiration (no assets copied)

| What | Credit |
|---|---|
| Mega Evolution presentation (animation spec in `docs/MegaEvolution.md`) | Pokémon Unbound (Skeli and team) and Pokémon Insurgence (Deukhoofd and team) |
| Proposed QoL features in `docs/QualityOfLife.md` | Pokémon Unbound, Radical Red (soupercell), Sacred Gold / Storm Silver (Drayano), Pokémon Insurgence |
| Approach for expanding a Gen IV engine | hg-engine (BluRosie and contributors), https://github.com/BluRosie/hg-engine |
