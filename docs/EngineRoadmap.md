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
| 7 | E14 | **Approved QoL:** IV/EV viewer (✅), Repel prompt (✅), HM-free field moves (✅), Gen VI+ breeding (✅), ~~type-effectiveness indicator~~ (shelved by the owner); Mints and Ability Capsule/Patch (✅ items; the Route 208 sale is still to do), Infinite Repel (✅ item; where it's given is the owner's call) | 🟡 4/8 + items | 1–2 | each feature tested |
| 8 | E6 | **Species expansion to 1025.** species.txt, data for #494–1025, placeholder sprites/icons, Pokédex sizes, Easy Chat, the stray constants above. English-only Pokédex; new species have no cry until the last step (owner) | ✅ | — | new species work in battle and on the summary screen; National Dex holds 1025 (wild placement is E10/E11) |
| 9 | E7 | **Items.** Mega Stones, evolution items, Gen V+ held items, key items, icons | ✅ 245 items with icons, evolutions, Mints/Capsule/Patch, Veilstone held-item shop, Infinite Repel, post-Champion money (decision 24). Left for the owner: where the Infinite Repel is given. Held-item battle effects go with item 11; Mega Stone shops with E8 | — | items in bag and usable |
| 10 | E8 | **Mega Evolution / Primal Reversion.** Forms, battle flow, touch-screen toggle, AI, boss-critical abilities, animation | ✅ 99 forms, battle flow, MEGA button, Primal Reversion, Mega Ring, 15 field stones, 4 vendors, the animation with its symbols, the Mega symbol by the name. Mega sprites come with E12, the missing Mega abilities with item 11, Mega timing with 12b | — | Mega usable vs. AI |
| 10b | BM | **Battle mechanics → Pokémon Champions** (owner request, 2026-10-22): every battle rule follows Pokémon Champions except the stat system — the owner named dynamic speed (turn order updates when Speed changes mid-turn), updated sleep and updated paralysis as examples. **Kept:** IVs (max 31) and EVs (max 252 per stat, 510 total). Rules written in `docs/BattleMechanics.md`; core rules built (status, dynamic speed, crits, multi-hit, Protect, weather, Snow, Fake Out, move values). Ability/move behaviour changes go with item 11 | 🟡 core done | 1–2 more | rules list written; each rule tested |
| 10c | FM | **All Pokémon forms** (owner requirement, 2026-10-22: every form exists, except Dynamax/Gigantamax and unplayable forms such as Eternamax Eternatus and Koraidon/Miraidon's ride forms; Terapagos-Stellar shelved). 282 alternate Pokémon: regional (59), Mega/Primal (99, with E8), fusions, Zygarde, Crowned Zacian/Zamazenta, Ogerpon masks, battle and item forms (112), and Totem (12; optional trials along the story before the Elite Four, catchable afterwards, never wild: `data/totem_trials.yaml`). Plus about 228 cosmetic forms. Form data, sprites/icons, form-change triggers, wild placement of regional forms in the **Regional Forms Park** that replaces Pal Park on Route 221 (decision 22; Pal Park and GBA migration are removed). Revisit the `evolution_changes.yaml` entries that say a regional form "isn't in the game". Held-item forms (Crowned, masks) come first, right after E7's items | 🟡 79 forms: the 57 regional forms + Basculin's Blue/White stripes (own learnsets; regional evolutions and Egg forms) and Zen Darmanitan's data; 7 held-item forms (Crowned Zacian/Zamazenta, Ogerpon's three masks, Origin Dialga/Palkia), form items locked against Knock Off/Thief/Trick/Fling (Mega Stones and Orbs too); 11 key-item forms used from the bag (4 Therian Formes, Hoopa Unbound, and the 6 fusions of Kyurem, Necrozma and Calyrex); `data/forms.csv` with every form's category. the **Regional Forms Park** on Route 221 with the regional forms in the wild (`docs/RegionalFormsPark.md`). The 12 Totem forms and the Totem trial battle (`docs/TotemTrials.md`); the Totems' overworld sprites, the trial script and the 13 crown key items, with all 11 Totems on the map, each shown once its trial opens, and 1 vs 2 for a player with one able Pokémon. Next: battle forms | 4–8 | every form obtainable and shown correctly |
| 11 | E2b/E3b | **Effect fidelity:** (pinned: Sludge Wave reuses the Surf animation recoloured purple — owner idea) exact behaviour for new abilities and moves, boss teams first, then by how common they are | | 3–6 (spread) | checklist items closed |
| 12 | E9 | **Trainer format.** Per-mon nature/ability/IVs/EVs/item/form, 16-bit species, plus gender, shininess and ball (`docs/TrainerFormat.md`) | ✅ | — | boss teams load as written (`tools/test/check_trainer_party.py`) |
| 12a | DX | **Pokédex** (owner, decision 21): National Dex from the moment Rowan gives the Pokédex, everything numbered nationally (no "???"), Sinnoh dex as a cosmetic view; decide each thing Platinum gated on the National Dex | ✅ National Dex from Rowan; the post-game gates keep their timing (Hall of Fame); national numbers on the summary and PC | — | every species shows its national number everywhere |
| 12b | AI | **AI review** (owner request): check whether the trainer AI needs adjusting for double battles (targeting, spread moves, partner awareness, Mega timing) and for Gen IX moves/abilities; fix what's needed | | 1–2 | AI doubles behaviour reviewed and tested |
| 13 | T1 | **Team compositions** (deferred by the owner until the engine features are done): the 21 post-Jupiter boss teams with the owner's Mega picks (`BossFights_MegaPicks.md`; Lucas uses Dawn's teams), then revise every boss team with Gen IX moves/abilities | | 1–2 | teams validated by `gen_trainer_docs.py` |
| 14 | E10 | **Renegade port.** Wild tables, trainers, items, NPCs/QoL, type and move changes, scripts per Renegade's docs | | 3–6 | Renegade docs satisfied |
| 15 | E11 | **Sovereign content.** Encounter plan, E4 format scripts, starter Interviewers, post-game legendaries, and the Sovereign story (decision 23, `Story.md`: Totem trial gating, title, post-game events). Mega vendors and field stones are done (E8) | 🟡 The Totem trials and their crown pieces are on the map, and the Galactic gates wait on them (CB-0028 to CB-0031). Post-game: the Celestic elder at home, the Elite Four rematch lock and the Sovereign Crown (CB-0033) | 4–7 | Sovereign docs satisfied |
| 16 | T2 | **Developer final battle** (owner request): Red-style hidden double battle, custom team and trainer, with a **custom AI** written for this fight. Team received; Lv. 100 at Spear Pillar; leads Charizard-Y + Venusaur; custom AI that switches weather setters to control the weather (`DeveloperBattle.md`). Waiting on trainer name/class, text and sprites | team in | 1–2 | battle playable; custom AI tested |
| 17 | E12 | **Graphics.** Convert sprites, add fronts as sourced, real icons | waiting on art | 2–4 | `SpriteChecklist.xlsx` all green |
| 18 | — | **Playtest pass** (automated with the test build, then the owner's playthrough) | | 1–2 | no blockers |
| 19 | — | **Release:** `.xdelta` patches for Platinum (US) Rev 1 ("4997") and Rev 0 ("3541") from `tools/build/make_release_patch.sh`, like Renegade's | script ✅ | — | each patch round-trips to the built ROM |

**Total remaining (2026-10-22, 5:40 pm): about 22–45 sessions**, down from 26–50 at 3:26 pm.
- **Since 3:26 pm:** E7 and almost all of E8 are done (budgeted at 3½–6 sessions), and so is E9 (Claude A). The
  Sovereign story added 1–2 sessions to E11.
- **Pace:** these sessions are budgeted at about 5 hours each, but today Claude B finished that 3½–6 sessions' worth
  in about 2 hours. Not everything left goes that fast: Gen IX move and ability effects (item 11) and the Renegade
  port (E10) are large.
- **Schedule:** with Claude B running continuously and Claude A once a day, the engine work could be done in 1–2
  weeks, and a full playable build in 2–3 weeks. That depends on art (E12, form sprites), story text and the owner's
  decisions arriving in time. This replaces the earlier 3–6 weeks.

Gen IX move and ability effects outnumber what can be done in one pass. They're implemented in priority order (boss
teams, then moves and abilities common in the added species' learnsets) and tracked in a generated checklist so
nothing is silently approximate.
