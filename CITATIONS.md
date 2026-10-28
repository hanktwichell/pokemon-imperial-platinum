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
attribution is in `data/sprite_index.csv` and `docs/SpriteLog.md`. In the ROM (owner, 2026-10-28): the backs and shiny
backs of 41 Mega Evolutions and both Primal Reversions, halved back to DS size by `tools/sprites/convert_form_backs.py`
(`decomp/res/pokemon/sovereign_form_backs/`).

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

- **hg-engine DS-style sprite set** ("GenIV_Style_Sprites_Gen5-9"), the 80×80 files (699 fronts and backs): BluRosie
  and the hg-engine contributors and sprite artists — https://github.com/BluRosie/hg-engine. hg-engine credits its
  sprites as a group, not per sprite. Its `CREDITS.md` (commit `f4fca05`, read 2026-10-25) lists, for **Pokémon
  sprites**: the Smogon Sprite Project, TraviS, LennyBitao, MyMarshlands, DarkusShadow, CarmaNekko, kiriaura,
  Gnomowladny, Krune, n-kin, JaegerLucciano23, joshr691, Jefelin, MultiDiegoDani, onigin_pixelart, Prodigal96,
  zerudez, leparagon, arinoelle, diegotoon20, gardow, greyenna, conyjams, kingofthe-x-roads, RayquazaFlygon,
  metalflygon08 (on DeviantArt), MaMe, maple, Layell, SelenaFF, Sopita Yorita and zlolxd; **MaMe and maple** touched up
  many Mega sprites; **Adcroc1** helped with sprite formatting; and **Chritchy** fixed sprite translation errors.
- **Smogon Sprite Project** (Gen 6/7/8 archives), the 96×96 files (727 fronts, backs and shinies, for 197 species from
  #650 on): the Smogon Sprite Project contributors — https://www.smogon.com/forums/forums/smeargles-laptop.325/.
  Pokémon Showdown's credits (https://pokemonshowdown.com/credits, read 2026-10-25) name the leads: the **X/Y and
  Sun/Moon Sprite Projects**, led by **Ian Clail (Layell)**, and the **Sun/Moon and Sword/Shield Sprite Projects**, led
  by **leparagon**. The per-sprite credits are in `docs/SmogonSpriteCredits.md`, from each project's sheet of
  finished sprites (X/Y, Sun/Moon, Gen 8 and Gen 9; snapshots in `assets/sprites/credits/smogon/`, read 2026-10-26).
  The spriters of our 197 species are: arinoelle, Arkeis, aXl, Blaquaza, Branflakes325, Bynine, Corson, Cynda,
  Espeon Scientist, fishbowlsoul90, G.E.Z., Galifia, GeoisEvil, HealnDeal, KingOfThe-X-Roads, Layell, Legitimate
  Username, leParagon, Mega-Pokebattlerz, MyMarshlands, N-Kin, paintseagull, princessofmusic, Quanyails,
  RadicalCharizard, RedRooster, Siiilver, Sleet, Spook, The Cynical Poet, TheAetherPlayer, Wobblebuns, Wyverii,
  Z-nogyroP, Zermonious and Zerudez, with the QC (quality checkers) listed per species. Which files came from which
  set is by size, 80×80 or 96×96.

The owner's README notes a part 2 (257 shiny sprites from the Smogon links) that hasn't been added yet.

**Relabelled pack (2026-10-26).** The owner's `Gen5-9_Sprites_relabeled` replaced this folder: every species now has
all four sprites. Its `README.txt` and `relabel_manifest.csv` say which were relabelled (a shiny back that was filed
as the normal back) and which were generated by the owner's `shinify.py` (a normal back made from the shiny back, or a
shiny front made from the front; estimates, with a confidence score). These are in the game since 2026-10-26
(`tools/sprites/convert_battle_sprites.py`, `docs/BattleSpriteImport.md`).

**Fronts from PokeAPI (owner, 2026-10-26).** The game uses PokeAPI's front and shiny front for #494–1025, with the
backs and shiny backs from this pack. So Nolan Herkomer's 67 front and shiny-front edits listed below (Clawitzer,
Gourgeist and Enamorus fronts, and 64 shiny fronts) are no longer in the game; his 85 back and shiny-back edits are.

**Edited by Nolan Herkomer** (the owner's artist): the 152 sprites in that pack edited by hand after the relabelling
(file dates from 22 October 2026, 2 pm, to 24 October 2026; the relabelling script itself stamped every file at
4:37 am on 22 October):

- 0646-Kyurem: back, shiny front
- 0647-Keldeo: back, shiny front
- 0652-Chesnaught: back, shiny back
- 0655-Delphox: shiny back
- 0657-Frogadier: shiny back
- 0660-Diggersby: back
- 0661-Fletchling: back, shiny back
- 0662-Fletchinder: shiny back
- 0664-Scatterbug: back
- 0668-Pyroar: back, shiny front
- 0669-Flabebe: shiny back, shiny front
- 0673-Gogoat: back, shiny back
- 0675-Pangoro: back, shiny back
- 0676-Furfrou: back, shiny back, shiny front
- 0679-Honedge: back, shiny front
- 0680-Doublade: back, shiny front
- 0681-Aegislash: back, shiny front
- 0686-Inkay: shiny back
- 0687-Malamar: back, shiny back
- 0693-Clawitzer: back, front, shiny front
- 0695-Heliolisk: shiny back, shiny front
- 0696-Tyrunt: back, shiny back
- 0698-Amaura: back
- 0699-Aurorus: back, shiny back
- 0700-Sylveon: shiny front
- 0706-Goodra: back, shiny back
- 0710-Pumpkaboo: back, shiny front
- 0711-Gourgeist: front, shiny front
- 0713-Avalugg: shiny back
- 0715-Noivern: back, shiny back, shiny front
- 0716-Xerneas: back, shiny front
- 0717-Yveltal: back, shiny back
- 0719-Diancie: back, shiny front
- 0720-Hoopa: back, shiny back, shiny front
- 0741-Oricorio: back, shiny front
- 0745-Lycanroc: shiny front
- 0746-Wishiwashi: shiny back, shiny front
- 0773-Silvally: back, shiny front
- 0791-Solgaleo: back, shiny front
- 0792-Lunala: back, shiny front
- 0801-Magearna: back, shiny front
- 0809-Melmetal: back, shiny front
- 0812-Rillaboom: back, shiny front
- 0815-Cinderace: back, shiny front
- 0818-Inteleon: back, shiny front
- 0823-Corviknight: shiny front
- 0826-Orbeetle: back, shiny front
- 0834-Drednaw: back, shiny front
- 0842-Appletun: back, shiny front
- 0861-Grimmsnarl: back, shiny front
- 0875-Eiscue: back
- 0877-Morpeko: shiny front
- 0879-Copperajah: back, shiny front
- 0890-Eternatus: shiny back, shiny front
- 0893-Zarude: shiny front
- 0899-Wyrdeer: back, shiny front
- 0901-Ursaluna: shiny back, shiny front
- 0903-Sneasler: back, shiny front
- 0904-Overqwil: back
- 0905-Enamorus: back, front, shiny back, shiny front
- 0907-Floragato: shiny front
- 0908-Meowscarada: back, shiny front
- 0911-Skeledirge: back, shiny front
- 0913-Quaxwell: back, shiny front
- 0916-Oinkologne: back
- 0917-Tarountula: shiny front
- 0918-Spidops: back, shiny front
- 0920-Lokix: shiny front
- 0923-Pawmot: shiny front
- 0930-Arboliva: back, shiny back
- 0934-Garganacl: shiny front
- 0935-Charcadet: back, shiny front
- 0936-Armarouge: shiny front
- 0937-Ceruledge: shiny front
- 0938-Tadbulb: back, shiny front
- 0939-Bellibolt: back, shiny front
- 0940-Wattrel: back
- 0945-Grafaiai: shiny front
- 0948-Toedscool: back
- 0949-Toedscruel: back, shiny front
- 0950-Klawf: shiny back, shiny front
- 0951-Capsakid: shiny back, shiny front
- 0952-Scovillain: shiny front
- 0953-Rellor: shiny back, shiny front
- 0954-Rabsca: shiny front
- 0955-Flittle: shiny back, shiny front
- 0956-Espathra: shiny back, shiny front

### PokeAPI front sprites (#494–1025)
Location: `assets/sprites/packs/pokeapi_fronts/` (front and shiny front per species). From the PokeAPI sprites
repository (https://github.com/PokeAPI/sprites, `sprites/pokemon/<dex>.png` and `sprites/pokemon/shiny/<dex>.png`).
PokeAPI collects the sprites; the art is © Nintendo / Game Freak / The Pokémon Company, with the newer generations
drawn by the sprite communities PokeAPI credits in its repository. Converted to DS format by
`tools/sprites/convert_battle_sprites.py --fronts`.

The same goes for 368 forms' fronts and shiny fronts: Megas, Primals, regional, battle, item, fusion, cosmetic and
female forms (`pokeapi_fronts/forms/`, PokeAPI's `sprites/pokemon/<form id>.png` or `<dex>-<form>.png`; converted by
`tools/sprites/convert_form_sprites.py`), and the female fronts of Unfezant, Frillish, Jellicent, Pyroar and Hisuian Sneasel
(`pokeapi_fronts/<species>/female_*.png` and `pokeapi_fronts/forms/sneasel-hisui/female_*.png`, PokeAPI's
`sprites/pokemon/female/<id>.png`). Mega Zygarde has none on
PokeAPI yet and keeps Zygarde's sprite.

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

### Battle MEGA button and Mega symbols
These are original art, drawn pixel by pixel with no source image:
- `decomp/res/graphics/battle/interface/mega_button.png`, by `tools/sprites/make_mega_button.py`. The Mega Stone shown
  on the button in battle is the item icon above.
- The Mega, α and Ω stones shown by a Mega's or Primal's name
  (`decomp/res/graphics/battle/healthbox/sovereign_mega_icon.png`), by `tools/sprites/make_mega_icon.py`. Their place
  next to the name follows Pokémon Insurgence's battle screen; the art is not taken from it.
- The Mega, α and Ω symbols that flash in the animation (`decomp/res/graphics/battle/moves/sovereign_*_symbol.png`), by
  `tools/sprites/make_mega_symbols.py`.

### Totems on the map
The huge Totems standing at the Totem trials (`decomp/res/graphics/field_sprites/pokemon/totem_<species>.png`), made by
`tools/sprites/make_totem_overworld.py` from each Totem form's front sprite. Source: **PokeAPI sprites**,
https://github.com/PokeAPI/sprites, `sprites/pokemon/<id>.png` (ids 10093, 10121, 10122, 10128, 10129, 10144, 10146,
10149, 10150, 10153, 10154). The art is © Nintendo / Game Freak / The Pokémon Company; PokeAPI hosts it. Scaled to fit
64×64, reduced to 14 colours and outlined in orange for the Totem aura. **Placeholders**, until DS-style overworld
sprites are drawn.

### Post-game legendaries on the map
The legendaries standing at their static encounters (`decomp/res/graphics/field_sprites/pokemon/legendary_<species>.png`; the Paradox, Ultra Beast and roamer ones are unused since decision 28),
made by `tools/sprites/make_legendary_overworld.py` the same way, without the aura (15 colours). Source: **PokeAPI
sprites**, https://github.com/PokeAPI/sprites, `sprites/pokemon/<id>.png` (ids 494, 638–640, 643–649, 716–721, 772, 785–789, 793–803, 805–809, 888–891, 893–898, 905, 984–995, 1001–1010, 1014–1017 and 1020–1025). The art
is © Nintendo / Game Freak / The Pokémon Company; PokeAPI hosts it. **Placeholders**, until DS-style overworld sprites
are drawn.

### Crown piece icons
The bag icons of the 11 crown pieces, the Crown and the Sovereign Crown (`decomp/res/items/icons/`), by
`tools/sprites/make_crown_icons.py`. Original art, drawn pixel by pixel with no source image. **Placeholders** until the
owner's icons arrive (`data/item_sprites.csv`).

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
