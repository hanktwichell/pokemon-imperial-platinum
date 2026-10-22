# Imperial Platinum — Engine Roadmap (decomp)

Imperial is built on the **pret/pokeplatinum** decompilation, vendored in `decomp/` as a squashed git subtree.
Renegade Platinum's changes are re-implemented from its documentation; the design data in `data/` and `docs/`
says what the finished game must contain.

Decisions this plan follows (project owner, 2026-10-22):
- Decomp route; Imperial has its **own save format**.
- **Gen IX data everywhere:** current base stats, types, abilities **including Hidden Abilities**, learnsets and moves.
- Every big fight after the Eterna Jupiter battle has a Mega (picks pending in `BossFights_MegaPicks.md`).
- **Pokédex:** the Sinnoh (regional) Pokédex stays exactly as in Platinum; the National Pokédex holds all 1025 species.
  Where a species can be caught doesn't depend on which dex it's in.
- **Cries** for #494–1025: from PokeAPI's cry archive (https://github.com/PokeAPI/cries, `cries/pokemon/latest/<dex>.ogg`), converted to the DS format, credited in
  `CITATIONS.md`.

## How the decomp stores data (relevant to us)

| Data | Where | Notes |
|---|---|---|
| Species list | `decomp/generated/species.txt` | Drives every per-species table and archive. `NATIONAL_DEX_COUNT = MAX_SPECIES - 2`, with `MAX_SPECIES = SPECIES_BAD_EGG`. |
| Species data | `decomp/res/pokemon/<species>/data.json` | Stats, types, 2 abilities, learnsets (level/TM/tutor/egg), evolutions, Pokédex text, Pal Park. |
| Sprites/icons/cries | same folder | `male_front.png`, `male_back.png`, `female_*`, `normal.pal`, `shiny.pal`, `icon.png`, `footprint.png`, `cry.wav` |
| Forms | `decomp/res/pokemon/form_registry.json` | data / icon / sprite form types |
| Moves | `decomp/generated/moves.txt`, `decomp/res/moves/<move>/{data.json,anim.s,script.s}` | Data-driven; effects are battle-script effect IDs |
| Abilities | `decomp/generated/abilities.txt` | Enum only; behaviour is C code in `decomp/src/battle/` |
| Items | `decomp/generated/items.txt` + item data | |
| Trainers | `decomp/src/trainer_data.c` + trainer data files | Species packed as 10 bits + 6-bit form, so it can't hold species > 1023 → replaced by the Imperial trainer format |

Engine limits found so far:
- Level-up learnset entries pack the move into **9 bits** (`SpeciesLearnsetEntry`, max move 511), so the format must
  widen before Gen IX moves exist (~920 moves).
- `MoveTable.flags` is a `u8` (8 flags); Gen IX needs more (punch, sound, bite, pulse, ballistic, powder, dance,
  slicing, wind…).
- The AI copies the whole move table into battle memory (`AIContext.moveTable[MAX_MOVES]`, 16 bytes per move).

Stray hard-coded numbers found so far (must be fixed when species are added):
`src/pokemon.c:4935` (`496 - 1 + form`), `src/overlay065/ov65_0222DCE0.c:3700-3704` (`495`), `src/trainer_data.c` (`& 0x3FF`).

### Species IDs

New species are inserted **before** `SPECIES_EGG`, so **species ID = National Dex number** (Victini = 494, …,
Pecharunt = 1025, Egg = 1026, Bad Egg = 1027). That keeps every data tool and document in Dex order. Vanilla saves
are incompatible, which the owner has accepted.

## Milestones (each one a PR that builds)

| # | Milestone | Done when |
|---|---|---|
| E0 | **Import & build.** Decomp vendored, offline-friendly build, CI build | ✅ `make -C decomp` reproduced the official ROM hash |
| E0b | **Fairy type + Gen VI+ type chart** | ✅ type charts match the official chart |
| E1 | **Imperial identity.** ROM title/banner, own save magic | ✅ banner "Pokémon Imperial Platinum"; vanilla saves load as empty |
| E2 | **Abilities → Gen IX.** All ~310 abilities in the enum with names and descriptions; existing behaviour kept; new abilities registered as no-ops, tracked in a checklist | builds; ability names show in summary |
| E3 | **Moves → Gen IX.** All ~919 moves with Gen IX data (type, power, accuracy, PP, priority, class, target, flags) generated from PokeAPI; new moves mapped to the closest existing battle effect and animation; per-move fidelity tracked | builds; every move usable in battle |
| E4 | **Hidden Abilities.** Third ability slot in personal data plus a hidden-ability bit in Pokémon data | HA shown and working |
| E5 | **Gen IX data for #1–493.** Stats, types, abilities, learnsets, evolutions from PokeAPI | generator output checked in |
| E6 | **Species expansion to 1025.** species.txt, data.json for #494–1025 (Gen IX data), placeholder sprites/icons/cries, Pokédex sizes, the stray constants above | new species catchable via debug; Pokédex shows 1025 |
| E7 | **Items.** Item table expansion: Mega Stones, evolution items, key items | items in bag |
| E8 | **Mega Evolution / Primal Reversion.** Forms, battle flow, touch-screen toggle, AI, boss-critical abilities, animation | Mega usable vs. AI |
| E9 | **Trainer format.** Per-mon nature/ability/IVs/EVs/item/form, 16-bit species; enter the boss and League teams | `TrainerPokemon_Imperial.md` playable |
| T1 | **Team compositions (deferred by the owner until the engine features are done).** Enter the 21 post-Jupiter boss teams with the owner's Mega picks (`BossFights_MegaPicks.md`; Lucas uses Dawn's teams), then revise every boss team with Gen IX moves/abilities available | teams validated by `gen_trainer_docs.py` |
| T2 | **Developer final battle** (owner request): Red-style hidden double battle against the mod's developer, custom team and trainer, after the post-game. Waiting on the owner's team, trainer text and sprites | battle playable |
| E10 | **Renegade port.** Wild tables, trainers, items, NPCs/QoL, type and move changes, scripts per Renegade's docs | Renegade docs satisfied |
| E11 | **Imperial content.** Encounter plan, E4 format scripts, starter Interviewers, Mega vendors and field stones, post-game legendaries | Imperial docs satisfied |
| E13 | **Options additions:** level cap, infinite Rare Candy, party Exp. Share, music volume slider (owner request), in the normal OPTIONS list | ✅ menu verified in the emulator; in-battle EXP checks pending a test save with a Pokémon |
| E14 | **Approved QoL:** Nature Mints, Repel prompt, Infinite Repel, type-effectiveness indicator, IV/EV viewer, HM-free field moves, Gen VI+ breeding, Ability Capsule NPC | each feature tested |
| E12 | **Graphics.** Convert the back-sprite pack, add fronts as sourced, real icons | `SpriteChecklist.xlsx` all green |

Gen IX move and ability effects outnumber what can be done in one pass. They're implemented in priority order (boss
teams, then moves and abilities common in the added species' learnsets) and tracked in a generated checklist so
nothing is silently approximate.
