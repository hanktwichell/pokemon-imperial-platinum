# Sovereign Platinum — Progress Report

_Last updated: 2026-10-22_

**Where we are:** the design phase is finished and engine work has started on the pret/pokeplatinum decompilation.
The ROM builds in CI on every PR. Merged so far: Fairy type, the Options additions, the Sovereign save format/identity,
the test build and the whole Gen IX data pass (all 919 moves, all 314 abilities with Hidden Abilities, Gen IX stats,
types and learnsets for #1–493). All 1025 species are in the game (E6). In progress: the remaining QoL features (E14) and the Pokémon Champions
battle rules (10b; core rules built). Next: items (E7).

**Estimate to a first playable version:** about 25–40 more working sessions, roughly 3–6 weeks at one or two sessions
a day. The two biggest uncertainties are fitting 1025 species into the DS engine (E6) and how exactly the Gen IX move
and ability effects behave (the long tail after E2–E5). The owner's sprites and the developer-battle team gate graphics
and T2 only. See `EngineRoadmap.md` for the per-milestone breakdown.

## Engine milestones

| # | Milestone | Status |
|---|---|---|
| E0 | Decomp imported; build reproduces the retail ROM; CI builds every PR | ✅ done |
| E0b | Fairy type + Gen VI+ type chart | ✅ done (checked against the official chart) |
| E13 | Options: level cap, Infinite Rare Candy, party Exp. Share, music volume | ✅ done (PR #5); verified in battle with the test build |
| E1 | Own save signature, ROM title/banner "Pokémon Sovereign Platinum" | ✅ done (PR #7) |
| E14 | Approved QoL | 🟡 4 of 8 done (IV/EV viewer, Repel prompt, HM-free field moves, Gen VI+ breeding; all tested in-game). The type-effectiveness indicator is shelved by the owner. Mints and the Ability Capsule/Patch work as items (E7); their sales and the Infinite Repel come next |
| — | Test build (`tools/test/build_test_rom.sh`): test party at new game, SELECT = wild battle, SELECT+R = trainer battle | ✅ working |
| E3 | All 919 moves, ID = official number; 93 new moves exact, 76 approximate, 211 placeholder (`MoveChecklist.md`) | ✅ done (PR #9); tested in battle |
| E5 | Gen IX stats, types and learnsets for #1–493 and forms; 32-bit learnset entries | ✅ done (PR #9); tested in battle |
| E2/E4 | All 314 abilities, ID = official number (191 new, no battle effect yet: `AbilityChecklist.md`); Hidden Ability slot and flag | ✅ done; tested on the summary screen |
| 10b | Battle mechanics → Pokémon Champions (IVs/EVs unchanged); rules in `BattleMechanics.md` | 🟡 core rules built (status, dynamic speed, crits, weather, Snow, Fake Out, move values); ability/move behaviour with item 11 |
| E6 | Species expansion to 1025 | ✅ done: all 532 Gen V–IX species (`NewSpecies.md`) with placeholder sprites, Easy Chat words, English-only Pokédex; tested in battle and on the summary screen. No cries for the new species yet (last step). 16 evolutions wait on E7 items |
| E7 | Items (Mega Stones, new held/evolution items) | not started |
| E8 | Mega Evolution / Primal Reversion | not started |
| E9 | Extended trainer data (natures, EVs, abilities, forms) | ✅ done: `docs/TrainerFormat.md` |
| E10 / E11 | Renegade port; Sovereign content (encounters, E4 format, gifts, post-game) | not started |
| E12 | Graphics (convert sprites, icons) | waiting on the owner's front sprites |
| T1 | Boss team compositions with the owner's Mega picks; revise all boss teams | deferred by the owner until the engine features are done |
| T2 | Developer final battle (Red-style double battle) | team received (`DeveloperBattle.md`); waiting on trainer text, sprites and level |

## Design work (done)

| Area | Result | Where |
|---|---|---|
| Species data | All 1025 species, 532 to add | `data/species.csv` |
| Wild encounters | 389 added species catchable directly, 8 by evolving, 45 starter-line gifts; no Renegade species lost | `docs/WildPokemon_Sovereign.md` |
| Starters | Gen V–IX starters from Pokémon Center Interviewers | `docs/GiftPokemon_Sovereign.md` |
| Mega Evolution | 99 forms, field stones, vendors, Mega Ring from Fantina, animation spec | `docs/MegaEvolution.md` |
| Boss Megas | Owner's picks for every big fight after Jupiter, including Barry (Mega Staraptor); Lucas uses Dawn's teams | `docs/BossFights_MegaPicks.md`, `docs/TrainerPokemon_Sovereign.md` |
| Level caps | 21 steps from Roark to the Cynthia rematch | `data/level_caps.yaml` |
| Elite Four format | 2 singles + 2 doubles, rematch options | `docs/EliteFourFormat.md` |
| Evolutions | Gen IV-compatible methods for added species; 16 new evolution items | `docs/EvolutionChanges_Sovereign.md` |
| Post-game legendaries | 90 species in five chapters | `docs/PostgameLegendaries.md` |
| Sprites | Fronts and backs for all 532 added species (owner packs); placeholder icons from PokeAPI | `docs/SpriteChecklist.xlsx` |
| Cries | 493 in the game; 532 needed, all with a source in PokeAPI's cry archive | `docs/CryChecklist.xlsx` |
| Citations | Every asset and dataset credited | `CITATIONS.md` |

## Decisions

Made by the owner (2026-10-22):
1. Rebuild on the pret/pokeplatinum decomp; Sovereign has its own save format.
2. Gen IX moves, abilities (with Hidden Abilities), learnsets and base stats everywhere.
3. Every big fight after the Eterna Jupiter battle has a Mega, with these exceptions: Saturn on Route 212, Ace Trainer
   Gene, and the Battleground's Gardenia, Cheryl and Buck. Lucas uses Dawn's teams.
4. Options: level cap, Infinite Rare Candy (needs the cap), party Exp. Share, music volume, all in the normal OPTIONS list.
5. QoL proposals 1–6, 8, 9 and 11 approved; #7 kept as a proposal; #10 dropped.
6. The Sinnoh dex stays as in Platinum; the National Dex holds all 1025. Cries for new species come from PokeAPI's archive.
   They are added last of all; until then the new species are silent, and dropping every cry is the fallback if
   space runs out (2026-10-22).
7. Boss team compositions wait until the engine features are done (T1).
8. A Red-style developer final battle will be added (T2). It gets a custom AI; the trainer AI is also reviewed for double battles (12b).
9. No Z-Moves, Max Moves, Dynamax or Gigantamax.
10. Battles keep main-series PP and PP Ups instead of Champions' fixed PP (2026-10-22).
11. The type-effectiveness indicator is shelved (2026-10-22).
12. The developer battle team: Mega Charizard Y, Venusaur, Tyranitar, shiny Garchomp, Primal Kyogre and shiny
    Archaludon (`DeveloperBattle.md`).
13. The project is renamed **Pokémon Sovereign Platinum** (was Imperial Platinum). The developer battle is against
    **Sovereign Dev Twich** (2026-10-22).
14. The Pokédex is English-only: no foreign-language entries (2026-10-22).
15. Zacian/Zamazenta's Crowned forms and Ogerpon's mask forms are in scope (held-item forms, E7 step 2). Wild Zacian
    and Zamazenta hold the Rusted Sword and Rusted Shield (2026-10-22).
16. **Every Pokémon form is in the game** (owner, 2026-10-22; "imperative"). This covers regional forms (Alolan,
    Galarian, Hisuian, Paldean), Megas and Primals, fusions (Kyurem, Necrozma, Calyrex), Zygarde's formes, Crowned
    Zacian/Zamazenta, Ogerpon's masks, battle and item forms, Totem forms, and cosmetic forms (Vivillon, Alcremie,
    Flabébé, Minior and the rest). Every earlier "out of scope" note about forms is void. Milestone FM in
    `EngineRoadmap.md`.
    **The only exceptions** (owner, 2026-10-22):
    - No Dynamax or Gigantamax: none of the 34 Gigantamax forms (decision 9 stands).
    - No unplayable forms, i.e. forms a player can never use in battle: Eternamax Eternatus, Koraidon's four Builds
      and Miraidon's four Modes.
    - Terapagos-Stellar is shelved for now (it needs Terastallization, which Sovereign doesn't have).
    This leaves 282 alternate Pokémon (99 of them Mega/Primal) plus about 228 cosmetic forms.
17. The battle screen gets a **MEGA** button on the touch-screen move menu for Mega Evolution. Primal Reversion stays
    automatic on switch-in, as in ORAS and later, with no button (owner, 2026-10-22). Spec in `MegaEvolution.md`; built
    in E8.
18. **Totem forms** (12 forms, 11 species) appear only as optional one-time Totem trials scattered along the main
    story, all before the Elite Four, never in the wild. Each Totem has its stat-raising Totem aura and can be caught
    afterwards in its Totem form. Totems call allies: each trial is a double battle where the Totem calls up to 2
    reserve helpers into the empty slot, and balls can be thrown only once the Totem is alone (owner, 2026-10-22).
    Placements, levels and the mechanic: `data/totem_trials.yaml`.
19. **Trade evolutions follow Renegade's system** (owner, 2026-10-22, after briefly considering a Link Stone): plain
    trade evolutions evolve at Level 36, and trade-with-item evolutions by using the item like a stone.
20. **Special evolutions** (Gholdengo's 999 coins, Malamar's upside-down console and other conditions Gen IV can't
    check) are to be discussed with the owner later. Until then the methods in `EvolutionChanges_Sovereign.md`
    stand.
21. **After E7/E8, the next focus is the Pokédex** (owner, 2026-10-22): every new Pokémon is in the dex, and a dex
    number never shows "???".
    - The **National Dex is unlocked when Rowan gives the player the Pokédex**.
    - Everything (summary, Pokédex, lists) refers to a Pokémon by its **National Dex number**.
    - The **Sinnoh dex is cosmetic**: a view inside the Pokédex only. This replaces the "Sinnoh dex stays" part of
      decision 6 for numbering.
    - To check when building it: other things Platinum gates on the National Dex flag (some wild encounters, Pal
      Park, Rowan's post-league upgrade event). Keep or move each one deliberately.
22. **Pal Park is removed, along with the GBA "Migrate" option** (owner, 2026-10-22; it can't work in a ROM hack).
    Its grounds on Route 221 become the **Regional Forms Park**: Pal Park's four areas (field, forest, mountain, sea)
    become Alola, Galar, Hisui and Paldea zones where the 59 regional forms (decision 16) live as wild Pokémon. The
    Catching Show layout is reused. Built with milestone FM, once regional forms exist.
23. **The story: the Sovereign** (owner, 2026-10-22; `docs/Story.md`). The Sovereign are Sinnoh's old ruling class.
    Unseen by the player, they merge other Pokémon worlds into Sinnoh, in a story that runs alongside Team
    Galactic's. One vague reference comes early, then the player learns more through the Totem trials (the
    Sovereign's tests) and the Chronicles. Everything comes together in the final battle against **Sovereign Twich**
    (renamed from Sovereign Dev Twich), the last surviving member of the lineage, whose dialogue nods to him being the
    developer. That battle opens after the Elite Four rematch and the Dialga and Palkia encounters at Spear Pillar.
    End goal (owner): **shield leading into succession**. The Sovereign stitched other worlds into Sinnoh to hold it
    together against Galactic; Twich, the last heir, has held the seams alone and uses the Totem trials to find a
    successor. Beating him grants the player the **Sovereign title**, and **Cynthia** (very close to Twich; the
    reason he uses Garchomp) arrives to congratulate them. Event order: first Hall of Fame → Dialga and Palkia at
    Spear Pillar (catchable) → Elite Four rematch, locked until both are done and then repeatable → after the second
    win against Cynthia, she sends the player to Spear Pillar for the Sovereign battle.

Open:
- Regional Forms Park (decision 22): which zone holds which forms, encounter rates, and when it opens (Route 221
  needs Surf; with the National Dex from the start, Pal Park's old National Dex gate no longer applies).
- Special evolutions (decision 20): owner discussion pending.
- The developer battle: Lv. 100 at Spear Pillar, leads Charizard-Y + Venusaur, custom weather-control AI (`DeveloperBattle.md`). Opponent: Sovereign Twich (decision 23). Open: text, sprites (owner's sprite coming soon).
- Front sprites and the part 2 shiny pack (owner is sourcing them).
- hg-engine and Smogon credit lists: Claude compiles them (owner, 2026-10-22).
