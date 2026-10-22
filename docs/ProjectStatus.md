# Imperial Platinum — Project Status & Roadmap

_Last updated: 2026-10-22_

## Done (design phase)

| Area | Result | Where |
|---|---|---|
| Species data | All 1025 species, with 532 to add (442 regular, 45 legendary, 14 mythical, 11 Ultra Beasts, 20 Paradox) | `data/species.csv` |
| Wild encounters | Every Renegade table re-slotted to Gen IV slot rates. **389** added species directly catchable, **8** by evolving a catchable pre-evolution, **45** starter-line species as gifts. No Renegade species lost. | `docs/WildPokemon_Imperial.md` |
| Starters | Gen V–IX starters through Pokémon Center Interviewers, as Renegade does for Kanto/Johto/Hoenn | `docs/GiftPokemon_Imperial.md` |
| Mega Evolution | 99 forms (XY, ORAS, Legends: Z-A + Mega Dimension), 15 field stones (replacing Potions etc.), 4 vendors, Mega Ring from Fantina, animation spec | `docs/MegaEvolution.md` |
| Boss teams | Megas for Jupiter (from Eterna), Aaron, Fantina, Maylene, Wake, Cyrus ×3, Saturn ×2, Mars ×2, Jupiter (Spear Pillar), Byron, Candice, Volkner, Fight Area; E4 + Cynthia singles/doubles for both rounds; validated | `docs/TrainerPokemon_Imperial.md` |
| Elite Four format | 2 singles + 2 doubles flow, rematch options, script design | `docs/EliteFourFormat.md` |
| Evolutions | 54 added species given Gen IV-compatible methods; 16 new evolution items | `docs/EvolutionChanges_Imperial.md` |
| Post-game legendaries | 90 species across five "Chronicle" chapters | `docs/PostgameLegendaries.md` |
| Sprites | Owner's pack indexed: back sprites for 347/532 added species and 44/99 Megas, with credits; Mega Garchomp Z front logged | `docs/SpriteLog.md` |
| Citations | Every asset and dataset credited | `CITATIONS.md` |

## Blocked / not started

1. **No base ROM in the repository.** Renegade is distributed as xdelta patches that need a Pokémon Platinum (US) dump.
   ROMs can't be downloaded or provided here. A developer must supply their own (`tools/build/apply_renegade_patch.sh`).
2. **Engine:** the decomp route is chosen; setup has started (see `TechnicalDesign.md`).
3. **Front sprites:** the supplied pack has back sprites only. **0/532** added species and **1/99** Megas have fronts.
   **185** added species and **55** Megas also lack backs. All are listed in `SpriteLog.md`.
4. All engine work: species expansion, Mega battle mechanic and UI, new abilities, item table expansion, extended trainer
   data (EVs/natures), scripts and maps, encounter table entry, and play-testing.

## Decisions

Made (2026-10-22):
1. **Engine route: rebuild on the pret/pokeplatinum decompilation.** Renegade's changes are re-implemented from its documentation.
2. **Gen IX data everywhere:** current-generation moves, abilities (including Hidden Abilities), learnsets and base stats.
3. **Early Aaron** (Route 208) keeps Mega Scizor. Every other big fight after the Eterna Jupiter battle also gets a Mega;
   the list awaiting picks is in `BossFights_MegaPicks.md`.
4. **Save format:** Imperial has its own save format (no Renegade save compatibility).

Open:
- Which Megas the fights in `BossFights_MegaPicks.md` use.
- Which QoL proposals in `QualityOfLife.md` to approve.
- Front sprites (the owner is sourcing them).
- Regional forms (Alolan/Galarian/Hisuian/Paldean): out of scope for now.

## Roadmap

| Phase | Work | Depends on |
|---|---|---|
| 1 | Pick the engine route; set up the build (base ROM or decomp + Renegade port) | Decision 1, a ROM dump |
| 2 | Species expansion: data tables, Pokédex, icons, placeholder sprites/cries | Phase 1 |
| 3 | Items: Mega Stones, evolution items, key items, shops | Phase 1 |
| 4 | Mega Evolution: forms, battle flow, UI, AI, boss abilities, animation | Phases 2–3 |
| 5 | Extended trainer data; enter all boss/League teams; E4 format scripts | Phase 4 |
| 6 | Wild tables, evolution changes, starter Interviewers, field items, vendors | Phases 2–3 |
| 7 | Post-game legendary quests and new maps | Phases 2, 5 |
| 8 | Sprites: convert backs, source fronts, palettes; Mega art | parallel |
| 9 | Play-testing and balance passes; regenerate the docs | all |
