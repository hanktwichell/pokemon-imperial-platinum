# Pokémon Sovereign Platinum

A ROM hack of Pokémon Platinum built on Drayano's **Pokémon Renegade Platinum**, rebuilt from source on the
pret/pokeplatinum decompilation. It adds **all 1025 Pokémon and every form**, **Mega Evolution and Primal Reversion**,
battle rules from **Pokémon Champions**, a **singles/doubles Elite Four**, Totem trials, post-game quests for every new
legendary, and a new story running alongside Team Galactic's: **the Sovereign**, Sinnoh's unseen old ruling class.
Renegade's story and quality-of-life features stay as they are.

> Non-commercial fan project. No ROMs are distributed. You need your own Pokémon Platinum (US) dump. See `CITATIONS.md`.

## Features

Built means it's in the decomp and verified in the emulator. Planned means it's designed (see the linked docs) and
waiting for its milestone.

| Feature | Status | Details |
|---|---|---|
| All 1025 species in the National Dex, the save kept at its original size (English-only Pokédex) | Built (E6) | [`NewSpecies.md`](docs/NewSpecies.md), [`SpeciesExpansionPlan.md`](docs/SpeciesExpansionPlan.md) |
| Fairy type and the Gen VI+ type chart | Built (E0b) | |
| Gen IX moves and abilities (data, names, descriptions); exact effects in priority order | Data built; effects in progress | [`MoveChecklist.md`](docs/MoveChecklist.md), [`AbilityChecklist.md`](docs/AbilityChecklist.md) |
| 245 new items with icons: Mega Stones, evolution items, Gen V+ held items, Mints, Ability Capsule/Patch, Infinite Repel | Built (E7) | [`ItemChanges_Sovereign.md`](docs/ItemChanges_Sovereign.md) |
| Battle rules from Pokémon Champions (main-series PP kept) | Core built | [`BattleMechanics.md`](docs/BattleMechanics.md) |
| Options: level cap, Infinite Rare Candy, party Exp. Share, music volume | Built (E13) | |
| Quality of life: IV/EV viewer, Repel prompt, HM-free field moves, Gen VI+ breeding | Built (E14) | [`QualityOfLife.md`](docs/QualityOfLife.md) |
| Post-Champion money: half-price shops, 3× rematch prizes, daily Nuggets | Built | [`ProjectStatus.md`](docs/ProjectStatus.md) (decision 24) |
| Trainer format: exact nature, ability, IVs, EVs, gender, shininess and ball per Pokémon | Built (E9) | [`TrainerFormat.md`](docs/TrainerFormat.md) |
| Doubles AI that protects its partner and values spread moves | In progress (12b) | [`AIReview.md`](docs/AIReview.md) |
| Mega Evolution (MEGA button on the touch screen) and Primal Reversion | Planned (E8) | [`MegaEvolution.md`](docs/MegaEvolution.md) |
| Every form: regional, Mega/Primal, fusion, battle, item, Totem and cosmetic (no Dynamax) | Planned (FM) | [`EngineRoadmap.md`](docs/EngineRoadmap.md) |
| 11 Totem trials along the story, each leaving a piece of a lost crown | Planned | [`data/totem_trials.yaml`](data/totem_trials.yaml), [`Story.md`](docs/Story.md) |
| Elite Four: 2 singles + 2 doubles, rematches up to Lv. 100 | Planned | [`EliteFourFormat.md`](docs/EliteFourFormat.md) |
| Gen V–IX starters from Pokémon Center Interviewers | Planned | [`GiftPokemon_Sovereign.md`](docs/GiftPokemon_Sovereign.md) |
| Post-game quests for all 90 added Legendary, Mythical, Ultra Beast and Paradox Pokémon | Planned | [`PostgameLegendaries.md`](docs/PostgameLegendaries.md) |
| The Sovereign story and the final battle at Spear Pillar | Planned | [`Story.md`](docs/Story.md), [`DeveloperBattle.md`](docs/DeveloperBattle.md) |

Cries: Platinum's 493 Pokémon keep theirs; added species are silent for now (sound memory is full). Cries are the
last thing revisited.

## Status

Engine work is under way on the decomp (`decomp/`), which builds the whole ROM from source, so no base ROM is needed to
develop. Milestones and estimates are in [`docs/EngineRoadmap.md`](docs/EngineRoadmap.md); what's done, blocked and
decided is in [`docs/ProjectStatus.md`](docs/ProjectStatus.md). Every engine change and how it was verified is in
[`docs/EngineChangelog.md`](docs/EngineChangelog.md). `CLAUDE_STATUS.md` is the running log of each work session.

## Documentation

| Document | Contents |
|---|---|
| [`docs/ProjectStatus.md`](docs/ProjectStatus.md) | What's done, what's blocked, the owner's decisions, open questions |
| [`docs/EngineRoadmap.md`](docs/EngineRoadmap.md) | Decomp milestones, species ID scheme, where data lives |
| [`docs/EngineChangelog.md`](docs/EngineChangelog.md) | Every engine change made so far, and how it was verified |
| [`docs/TechnicalDesign.md`](docs/TechnicalDesign.md) | Engine design: species expansion, Mega mechanic, items, trainer data, sprites |
| [`docs/Story.md`](docs/Story.md) | The Sovereign story: beats, event order, Totem gates and the crown (spoilers) |
| [`docs/DeveloperBattle.md`](docs/DeveloperBattle.md) | The final battle against Sovereign Henry (spoilers) |
| [`docs/BattleMechanics.md`](docs/BattleMechanics.md) | Pokémon Champions battle rules and how each is built |
| [`docs/AIReview.md`](docs/AIReview.md) | Trainer AI review for doubles and Gen IX: findings and fixes |
| [`docs/TrainerFormat.md`](docs/TrainerFormat.md) | Trainer data format: per-Pokémon nature, ability, IVs, EVs, gender, shininess, ball |
| [`docs/NewSpecies.md`](docs/NewSpecies.md) | The 532 added species |
| [`docs/SpeciesExpansionPlan.md`](docs/SpeciesExpansionPlan.md) | How the species expansion was done |
| [`docs/SpeciesGen9Changes.md`](docs/SpeciesGen9Changes.md) | Gen IX stat, type and ability changes to existing species |
| [`docs/MoveChecklist.md`](docs/MoveChecklist.md) | Every move and whether its exact effect is built |
| [`docs/AbilityChecklist.md`](docs/AbilityChecklist.md) | Every ability and whether its effect is built |
| [`docs/WildPokemon_Sovereign.md`](docs/WildPokemon_Sovereign.md) | Every encounter table (slot-exact), new species marked ★ |
| [`docs/TrainerPokemon_Sovereign.md`](docs/TrainerPokemon_Sovereign.md) | Boss teams with Megas; E4 and Cynthia singles + doubles sets |
| [`docs/BossFights_MegaPicks.md`](docs/BossFights_MegaPicks.md) | Big fights after Jupiter still needing a Mega pick |
| [`docs/EliteFourFormat.md`](docs/EliteFourFormat.md) | The 2 singles + 2 doubles rule, rematch options, script design |
| [`docs/MegaEvolution.md`](docs/MegaEvolution.md) | All 99 Mega/Primal forms, stone locations, vendors, animation spec |
| [`docs/EvolutionChanges_Sovereign.md`](docs/EvolutionChanges_Sovereign.md) | New evolution methods for added species, new evolution items |
| [`docs/GiftPokemon_Sovereign.md`](docs/GiftPokemon_Sovereign.md) | Gen V–IX starters from Pokémon Center Interviewers |
| [`docs/PostgameLegendaries.md`](docs/PostgameLegendaries.md) | Quests for all 90 added Legendary/Mythical/UB/Paradox Pokémon |
| [`docs/ItemChanges_Sovereign.md`](docs/ItemChanges_Sovereign.md) | New items, replaced field items, new shops |
| [`docs/QualityOfLife.md`](docs/QualityOfLife.md) | Renegade QoL kept, and the approved additions |
| [`docs/SpriteLog.md`](docs/SpriteLog.md) | Front/back/shiny sprite status for every added species and Mega |
| [`docs/SpriteChecklist.xlsx`](docs/SpriteChecklist.xlsx) | Spreadsheet: sprites we have and still need for all 1025 species, Megas, and new item icons |
| [`docs/CryChecklist.xlsx`](docs/CryChecklist.xlsx) | Spreadsheet: which cries we have / still need for all 1025 species (+ Megas), and where each source cry is |
| [`CITATIONS.md`](CITATIONS.md) | Credits for every asset and dataset |
| `RenegadePlatinumV130/` | Drayano's original patches and documentation (unchanged) |
| `decomp/` | pret/pokeplatinum decompilation (git subtree): the Sovereign engine |

## Repository layout

```
data/                 Source-of-truth design data (CSV/YAML/JSON): edit these, then regenerate docs
  species.csv                all 1025 species (generated from PokeAPI)
  megas.csv                  all 99 Mega / Primal forms (generated from PokeAPI)
  encounters_sovereign.json  slot-exact wild tables (generated)
  trainers_sovereign.yaml    boss / League teams (hand-written)
  items_sovereign.yaml       new items (hand-written; decomp tables generated from it)
  mega_stones.yaml           Mega Stone sources (hand-written)
  evolution_changes.yaml     evolution method changes (hand-written)
  postgame_legendaries.yaml  legendary quests (hand-written)
  totem_trials.yaml          the 11 Totem trials: places, levels, auras (hand-written)
  level_caps.yaml            level-cap steps for the LEVEL CAP option (hand-written, validated)
  sprite_index.csv           every sprite file, its credit and DS-readiness (generated)
  icon_placeholders.csv      placeholder box icons for added species (generated)
  item_sprites.csv           new items that still need a bag icon (hand-written)
docs/                 Generated + hand-written documentation
assets/sprites/       Sprite packs (unmodified) and owner-supplied art
tools/design/         Generators and validators for the docs
tools/sprites/        Sprite pack indexer, sprite checklist
tools/audio/          Cry checklist (PokeAPI cry archive)
tools/build/          ROM build helpers (apply the Renegade base patch)
tools/engine/         Generators for engine tables (species, items, level caps…)
tools/test/           Test build, headless emulator tests and the drive.py scripted-input driver
```

## Regenerating the docs

```sh
git clone --depth 1 https://github.com/PokeAPI/pokeapi /tmp/pokeapi
git clone --depth 1 https://github.com/pret/pokeplatinum /tmp/pokeplatinum   # optional
pip install pyyaml pillow openpyxl
tools/regenerate_docs.sh /tmp/pokeapi/data/v2/csv /tmp/pokeplatinum
```

Every generator validates its input: every species is placed or has a documented source, every Renegade species stays
catchable, trainer moves/abilities are legal, every Mega Stone has exactly one source, and Cynthia's singles teams never
use Protect. CI regenerates the docs on every pull request and fails if anything in `data/` or `docs/` is out of date.

## Building the ROM

Sovereign builds from source with the decomp. Install the dependencies listed in `decomp/INSTALL.md` (Linux/WSL:
`bison flex g++ gcc-arm-none-eabi make ninja-build pkg-config wget python3 xz-utils nasm libc6:i386 libpng-dev`), then:

```sh
make -C decomp rom    # builds decomp/build/pokeplatinum.us.nds
```

The ROM is never committed or uploaded. To play the original Renegade Platinum for reference, apply Drayano's patch to
your own Platinum dump: `tools/build/apply_renegade_patch.sh 4997 "Pokemon Platinum (US).nds"`.

### Test build

`tools/test/build_test_rom.sh` builds `decomp/build_test/pokeplatinum.us.nds`, a development-only ROM that is never
shipped. It skips Professor Rowan's intro (hold L to play it), starts with a test party and items, and adds hotkeys in
the overworld:

| Keys | Does |
|---|---|
| SELECT | a wild battle |
| SELECT+R | a Lv. 100 double battle against the developer team (`TRAINER_SOVEREIGN_TEST`) |
| SELECT+L | the breeding test |
| SELECT+B | Easy Chat |
| SELECT+L+R | warp to the next test stop (`sSovereignTestWarps` in `src/script_manager.c`) |

`tools/test/` also has headless checks on py-desmume (`drive.py` drives scripted input): `boot_smoke.py` (boots into the
new-game intro), `new_game.sh` (a save state in the bedroom), `check_trainer_party.py` (the opponent's
Pokémon against its trainer JSON) and `log_ai_partner_damage.py` (the doubles AI's spread-move estimates).

### Updating the decomp from upstream

```sh
git subtree pull --prefix=decomp https://github.com/pret/pokeplatinum main --squash
```
