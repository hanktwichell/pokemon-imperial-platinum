# Pokémon Imperial Platinum

A ROM hack of Pokémon Platinum built on Drayano's **Pokémon Renegade Platinum**. It adds all
**1025 Pokémon**, **Mega Evolution and Primal Reversion**, a **singles/doubles Elite Four**, and post-game quests for every
new legendary. Renegade's story and quality-of-life features stay as they are.

> Non-commercial fan project. No ROMs are distributed. You need your own Pokémon Platinum (US) dump. See `CITATIONS.md`.

## Status

**Design phase done; engine work under way on the pret/pokeplatinum decompilation** (`decomp/`). The decomp builds the
whole ROM from source, so no base ROM is needed to develop. Milestones are in
[`docs/EngineRoadmap.md`](docs/EngineRoadmap.md), and status in [`docs/ProjectStatus.md`](docs/ProjectStatus.md).

## Documentation

| Document | Contents |
|---|---|
| [`docs/ProjectStatus.md`](docs/ProjectStatus.md) | What's done, what's blocked, open decisions, roadmap |
| [`docs/EngineRoadmap.md`](docs/EngineRoadmap.md) | Decomp milestones (E0–E12), species ID scheme, where data lives |
| [`docs/EngineChangelog.md`](docs/EngineChangelog.md) | Every engine change made so far, and how it was verified |
| [`docs/TechnicalDesign.md`](docs/TechnicalDesign.md) | Engine work: species expansion, Mega mechanic, items, trainer data, sprites |
| [`docs/WildPokemon_Imperial.md`](docs/WildPokemon_Imperial.md) | Every encounter table (slot-exact), new species marked ★ |
| [`docs/TrainerPokemon_Imperial.md`](docs/TrainerPokemon_Imperial.md) | Boss teams with Megas; E4 and Cynthia singles + doubles sets |
| [`docs/BossFights_MegaPicks.md`](docs/BossFights_MegaPicks.md) | Big fights after Jupiter still needing a Mega pick |
| [`docs/EliteFourFormat.md`](docs/EliteFourFormat.md) | The 2 singles + 2 doubles rule, rematch options, script design |
| [`docs/MegaEvolution.md`](docs/MegaEvolution.md) | All 99 Mega/Primal forms, stone locations, vendors, animation spec |
| [`docs/EvolutionChanges_Imperial.md`](docs/EvolutionChanges_Imperial.md) | New evolution methods for added species, new evolution items |
| [`docs/GiftPokemon_Imperial.md`](docs/GiftPokemon_Imperial.md) | Gen V–IX starters from Pokémon Center Interviewers |
| [`docs/PostgameLegendaries.md`](docs/PostgameLegendaries.md) | Quests for all 90 added Legendary/Mythical/UB/Paradox Pokémon |
| [`docs/ItemChanges_Imperial.md`](docs/ItemChanges_Imperial.md) | New items, replaced field items, new shops |
| [`docs/QualityOfLife.md`](docs/QualityOfLife.md) | Renegade QoL kept, and proposed additions awaiting approval |
| [`docs/SpriteLog.md`](docs/SpriteLog.md) | Front/back/shiny sprite status for every added species and Mega |
| [`docs/SpriteChecklist.xlsx`](docs/SpriteChecklist.xlsx) | Spreadsheet: which of the 5 sprites we have for all 1025 species (+ Megas) |
| [`CITATIONS.md`](CITATIONS.md) | Credits for every asset and dataset |
| `RenegadePlatinumV130/` | Drayano's original patches and documentation (unchanged) |
| `decomp/` | pret/pokeplatinum decompilation (git subtree) — the Imperial engine |

## Repository layout

```
data/                 Source-of-truth design data (CSV/YAML/JSON) — edit these, then regenerate docs
  species.csv           all 1025 species (generated from PokeAPI)
  megas.csv             all 99 Mega / Primal forms (generated from PokeAPI)
  encounters_imperial.json   slot-exact wild tables (generated)
  trainers_imperial.yaml     boss / League teams (hand-written)
  mega_stones.yaml           Mega Stone sources (hand-written)
  evolution_changes.yaml     evolution method changes (hand-written)
  postgame_legendaries.yaml  legendary quests (hand-written)
  sprite_index.csv           every sprite file, its credit and DS-readiness (generated)
  level_caps.yaml            level-cap steps for the LEVEL CAP option (hand-written, validated)
docs/                 Generated + hand-written documentation
assets/sprites/       Sprite packs (unmodified) and owner-supplied art
tools/design/         Generators and validators for the docs
tools/sprites/        Sprite pack indexer
tools/build/          ROM build helpers (apply the Renegade base patch)
tools/engine/         Generators for engine tables (level caps -> decomp/include/data/level_caps.h)
tools/test/           Headless emulator tests and the drive.py scripted-input driver
```

## Regenerating the docs

```sh
git clone --depth 1 https://github.com/PokeAPI/pokeapi /tmp/pokeapi
git clone --depth 1 https://github.com/pret/pokeplatinum /tmp/pokeplatinum   # optional
pip install pyyaml pillow
tools/regenerate_docs.sh /tmp/pokeapi/data/v2/csv /tmp/pokeplatinum
```

Every generator validates its input: every species is placed or has a documented source, every Renegade species stays
catchable, trainer moves/abilities are legal, every Mega Stone has exactly one source, and Cynthia's singles teams never
use Protect.

## Building the ROM

Imperial builds from source with the decomp. Install the dependencies listed in `decomp/INSTALL.md` (Linux/WSL:
`bison flex g++ gcc-arm-none-eabi make ninja-build pkg-config wget python3 xz-utils nasm libc6:i386 libpng-dev`), then:

```sh
make -C decomp        # builds decomp/build/pokeplatinum.us.nds
```

The ROM is never committed or uploaded. To play the original Renegade Platinum for reference, apply Drayano's patch to
your own Platinum dump: `tools/build/apply_renegade_patch.sh 4997 "Pokemon Platinum (US).nds"`.

### Updating the decomp from upstream

```sh
git subtree pull --prefix=decomp https://github.com/pret/pokeplatinum main --squash
```
