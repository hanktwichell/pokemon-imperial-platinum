# Sovereign Platinum — Engine Roadmap (decomp)

Sovereign is built on the **pret/pokeplatinum** decompilation, vendored in `decomp/` as a squashed git subtree.
Renegade Platinum's changes are re-implemented from its documentation; the design data in `data/` and `docs/`
says what the finished game must contain.

Decisions this plan follows (project owner, 2026-10-22):
- Decomp route; Sovereign has its **own save format**.
- **Gen IX data everywhere:** current base stats, types, abilities **including Hidden Abilities**, learnsets and moves.
- Every big fight after the Eterna Jupiter battle has a Mega (picks pending in `BossFights_MegaPicks.md`).
- **No Z-Moves, Max Moves, Dynamax or Gigantamax** (owner, 2026-10-22). Their official move numbers stay as empty,
  unobtainable slots so move ID = official move number; nothing can learn or use them.
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
| Trainers | `decomp/src/trainer_data.c` + trainer data files | Species packed as 10 bits + 6-bit form, so it can't hold species > 1023 → replaced by the Sovereign trainer format |

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

## Milestones (each one a PR that builds), in working order

Estimates are in working sessions (about 5 hours each). Runtime checks use the test build
(`tools/test/build_test_rom.sh`), which keeps testing cheap.

| Order | # | Milestone | Status | Est. | Done when |
|---|---|---|---|---|---|
| 1 | E0 | **Import & build.** Decomp vendored, offline-friendly build, CI build | ✅ | — | `make -C decomp` reproduced the official ROM hash |
| 2 | E0b | **Fairy type + Gen VI+ type chart** | ✅ | — | type charts match the official chart |
| 3 | E13 | **Options additions:** level cap, Infinite Rare Candy, party Exp. Share, music volume (owner request), in the normal OPTIONS list | ✅ | — | menu verified; in-battle EXP check with the test build |
| 4 | E1 | **Sovereign identity.** ROM title/banner, own save signature | ✅ | — | banner "Pokémon Sovereign Platinum"; vanilla saves load as empty |
| 5 | — | **Test build:** test party at new game, SELECT = wild battle, SELECT+R = trainer battle; never shipped | ✅ | — | first in-battle checks pass (E13 verified) |
| 6 | E2–E5 | **Gen IX data pass** (one PR): all abilities (IDs, names, descriptions; new ones registered with no effect yet), all moves (Gen IX data; new moves mapped to the closest existing effect and animation), widened learnset format, Hidden Ability slot, Gen IX stats/types/learnsets for #1–493. Generated from PokeAPI with a fidelity checklist | ✅ moves (E3), learnsets/stats/types (E5), abilities and Hidden Abilities (E2/E4) | — | builds; every move usable in battle; HA shown |
| 7 | E14 | **Approved QoL:** IV/EV viewer (✅), Repel prompt (✅), HM-free field moves (✅), Gen VI+ breeding (✅), ~~type-effectiveness indicator~~ (shelved by the owner); Mints, Infinite Repel and Ability Capsule after E7/E4 | 🟡 4/8 | 1–2 | each feature tested |
| 8 | E6 | **Species expansion to 1025.** species.txt, data for #494–1025, placeholder sprites/icons, cries from PokeAPI, Pokédex sizes, the stray constants above | | 3–6 | new species catchable; National Dex shows 1025 |
| 9 | E7 | **Items.** Mega Stones, evolution items, Gen V+ held items, key items, icons | | 2–3 | items in bag and usable |
| 10 | E8 | **Mega Evolution / Primal Reversion.** Forms, battle flow, touch-screen toggle, AI, boss-critical abilities, animation | | 3–5 | Mega usable vs. AI |
| 10b | BM | **Battle mechanics → Pokémon Champions** (owner request, 2026-10-22): every battle rule follows Pokémon Champions except the stat system — the owner named dynamic speed (turn order updates when Speed changes mid-turn), updated sleep and updated paralysis as examples. **Kept:** IVs (max 31) and EVs (max 252 per stat, 510 total). Rules written in `docs/BattleMechanics.md`; core rules built (status, dynamic speed, crits, multi-hit, Protect, weather, Snow, Fake Out, move values). Ability/move behaviour changes go with item 11 | 🟡 core done | 1–2 more | rules list written; each rule tested |
| 11 | E2b/E3b | **Effect fidelity:** (pinned: Sludge Wave reuses the Surf animation recoloured purple — owner idea) exact behaviour for new abilities and moves, boss teams first, then by how common they are | | 3–6 (spread) | checklist items closed |
| 12 | E9 | **Trainer format.** Per-mon nature/ability/IVs/EVs/item/form, 16-bit species | | 1–2 | boss teams load as written |
| 12b | AI | **AI review** (owner request): check whether the trainer AI needs adjusting for double battles (targeting, spread moves, partner awareness, Mega timing) and for Gen IX moves/abilities; fix what's needed | | 1–2 | AI doubles behaviour reviewed and tested |
| 13 | T1 | **Team compositions** (deferred by the owner until the engine features are done): the 21 post-Jupiter boss teams with the owner's Mega picks (`BossFights_MegaPicks.md`; Lucas uses Dawn's teams), then revise every boss team with Gen IX moves/abilities | | 1–2 | teams validated by `gen_trainer_docs.py` |
| 14 | E10 | **Renegade port.** Wild tables, trainers, items, NPCs/QoL, type and move changes, scripts per Renegade's docs | | 3–6 | Renegade docs satisfied |
| 15 | E11 | **Sovereign content.** Encounter plan, E4 format scripts, starter Interviewers, Mega vendors and field stones, post-game legendaries | | 3–5 | Sovereign docs satisfied |
| 16 | T2 | **Developer final battle** (owner request): Red-style hidden double battle, custom team and trainer, with a **custom AI** written for this fight. Team received; Lv. 100 at Spear Pillar; leads Charizard-Y + Venusaur; custom AI that switches weather setters to control the weather (`DeveloperBattle.md`). Waiting on trainer name/class, text and sprites | team in | 1–2 | battle playable; custom AI tested |
| 17 | E12 | **Graphics.** Convert sprites, add fronts as sourced, real icons | waiting on art | 2–4 | `SpriteChecklist.xlsx` all green |
| 18 | — | **Playtest pass** (automated with the test build, then the owner's playthrough) | | 1–2 | no blockers |

**Total remaining: about 25–40 sessions (≈3–6 weeks at one or two sessions a day).**

Gen IX move and ability effects outnumber what can be done in one pass. They're implemented in priority order (boss
teams, then moves and abilities common in the added species' learnsets) and tracked in a generated checklist so
nothing is silently approximate.
