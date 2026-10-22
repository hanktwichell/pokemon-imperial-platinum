# Pokémon Imperial Platinum

A ROM hack of Pokémon Platinum built on Drayano's **Pokémon Renegade Platinum** (used with permission). It adds all
**1025 Pokémon**, **Mega Evolution and Primal Reversion**, a **singles/doubles Elite Four**, and post-game quests for every
new legendary. Renegade's story and quality-of-life features stay as they are.

> Non-commercial fan project. No ROMs are distributed. You need your own Pokémon Platinum (US) dump. See `CITATIONS.md`.

## Status

**Design phase done; engine work not started.** Everything that can be decided without the ROM is designed, documented
and machine-checked. Building the game needs (1) a base ROM supplied by a developer and (2) a decision on the engine route.
Details are in [`docs/ProjectStatus.md`](docs/ProjectStatus.md).

## Documentation

| Document | Contents |
|---|---|
| [`docs/ProjectStatus.md`](docs/ProjectStatus.md) | What's done, what's blocked, open decisions, roadmap |
| [`docs/TechnicalDesign.md`](docs/TechnicalDesign.md) | Engine work: species expansion, Mega mechanic, items, trainer data, sprites |
| [`docs/WildPokemon_Imperial.md`](docs/WildPokemon_Imperial.md) | Every encounter table (slot-exact), new species marked ★ |
| [`docs/TrainerPokemon_Imperial.md`](docs/TrainerPokemon_Imperial.md) | Boss teams with Megas; E4 and Cynthia singles + doubles sets |
| [`docs/EliteFourFormat.md`](docs/EliteFourFormat.md) | The 2 singles + 2 doubles rule, rematch options, script design |
| [`docs/MegaEvolution.md`](docs/MegaEvolution.md) | All 99 Mega/Primal forms, stone locations, vendors, animation spec |
| [`docs/EvolutionChanges_Imperial.md`](docs/EvolutionChanges_Imperial.md) | New evolution methods for added species, new evolution items |
| [`docs/GiftPokemon_Imperial.md`](docs/GiftPokemon_Imperial.md) | Gen V–IX starters from Pokémon Center Interviewers |
| [`docs/PostgameLegendaries.md`](docs/PostgameLegendaries.md) | Quests for all 90 added Legendary/Mythical/UB/Paradox Pokémon |
| [`docs/ItemChanges_Imperial.md`](docs/ItemChanges_Imperial.md) | New items, replaced field items, new shops |
| [`docs/QualityOfLife.md`](docs/QualityOfLife.md) | Renegade QoL kept, and proposed additions awaiting approval |
| [`docs/SpriteLog.md`](docs/SpriteLog.md) | Front/back/shiny sprite status for every added species and Mega |
| [`CITATIONS.md`](CITATIONS.md) | Credits for every asset and dataset |
| `RenegadePlatinumV130/` | Drayano's original patches and documentation (unchanged) |

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
docs/                 Generated + hand-written documentation
assets/sprites/       Sprite packs (unmodified) and owner-supplied art
tools/design/         Generators and validators for the docs
tools/sprites/        Sprite pack indexer
tools/build/          ROM build helpers (apply the Renegade base patch)
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

## Building the base ROM

```sh
tools/build/apply_renegade_patch.sh 4997 "Pokemon Platinum (US).nds" RenegadePlatinum.nds   # or 3541
```
