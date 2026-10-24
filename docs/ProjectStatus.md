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
| Sprites | Fronts and backs for all 532 added species (owner packs); placeholder icons from PokeAPI. Bag icons needed for 13 new items (the crown) | `docs/SpriteChecklist.xlsx` |
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
18. **Totem forms** (12 forms, 11 species) appear only as one-time Totem trials scattered along the main story, all
    before the Elite Four, never in the wild. Team Galactic's encounters wait on the trials before them, so they
    are no longer optional (decision 23). Each Totem has its stat-raising Totem aura and can be caught
    afterwards in its Totem form. Totems call allies: each trial is a double battle where the Totem calls up to 2
    reserve helpers into the empty slot, and balls can be thrown only once the Totem is alone (owner, 2026-10-22).
    Placements, levels and the mechanic: `data/totem_trials.yaml`.
    - Built (CB-0027): the Totem forms and the trial battle (`docs/TotemTrials.md`).
    - Built (CB-0028): the Totems on the map (huge overworld sprites), the trial script, and the crown pieces. Totem
      Gumshoos stands on Route 205 South.
    - Built (CB-0029): Ribombee, Vikavolt, Mimikyu and Alolan Marowak on the map, each shown once its trial opens.
    - Built (CB-0030): the last six on the map. All 11 trials are playable.
    - Built (CB-0031): the Galactic gates (`Story.md`).
    - Built (CB-0032): 1 vs 2 for a player with one able Pokémon. The second slot starts empty.
    - The auras were checked against Serebii; the helpers are a proposal from each trial's original allies.
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
    - The other things Platinum gated on the National Dex flag (some wild encounters, Pal Park, the post-game
      story) now open at the Hall of Fame. Rowan's event for a complete Sinnoh dex (Oak, the Poké Radar) has its own
      flag. Its dialogue still needs rewriting (built with DX, `EngineChangelog.md`).
22. **Pal Park is removed, along with the GBA "Migrate" option** (owner, 2026-10-22; it can't work in a ROM hack).
    Its grounds on Route 221 become the **Regional Forms Park**: Pal Park's four areas (field, forest, mountain, sea)
    become Alola, Galar, Hisui and Paldea zones where the 59 regional forms (decision 16) live as wild Pokémon. The
    Catching Show layout is reused. Built with milestone FM, once regional forms exist.
    - The main menu's "Migrate from…" option is removed (FM part 2). Pal Park's transfer storage now holds the
      fusion partners (`EngineChangelog.md`).
    - The regional forms exist (FM part 3): 57, plus White-Striped Basculin, Hisui's own form. The count of 59
      above included Pikachu's Alola cap, a cosmetic cap, and Galarian Zen Darmanitan, a battle form.
    - **Galarian Articuno, Zapdos and Moltres** roam the **Galar zone** as rare encounters (low odds). That's the only
      place they can be caught (owner, 2026-10-22).
    - The park is built (FM, CB-0026), with a proposed zone list in `docs/RegionalFormsPark.md`. It opens after the
      Hall of Fame (Route 221's National Dex check, decision 21).
23. **The story: the Sovereign** (owner, 2026-10-22; `docs/Story.md`). The Sovereign are Sinnoh's old ruling class.
    Unseen by the player, they merge other Pokémon worlds into Sinnoh, in a story that runs alongside Team
    Galactic's. One vague reference comes early, then the player learns more through the Totem trials (the
    Sovereign's tests) and the Chronicles. Everything comes together in the final battle against **Sovereign Henry**
    (first named Sovereign Dev Twich, then Sovereign Twich; renamed by the owner), the last surviving member of the
    lineage, whose dialogue nods to him being the developer.
    End goal (owner): **shield leading into succession**. The Sovereign stitched other worlds into Sinnoh to hold it
    together against Galactic; Henry, the last heir, has held the seams alone and uses the Totem trials to find a
    successor. Beating him grants the player the **Sovereign title**, and **Cynthia** (very close to Henry; the
    reason he uses Garchomp) arrives to congratulate them. Event order: first Hall of Fame → Dialga and Palkia at
    Spear Pillar (catchable) → Elite Four rematch, locked until both are done and then repeatable → after the second
    win against Cynthia, she sends the player to Spear Pillar for the Sovereign battle.
    Gates and crown (owner): each Galactic encounter waits on the Totem trials placed before it (existing blocking
    NPCs get the trial added to their unlock condition; built in CB-0031, `Story.md`). Each trial, once its catch encounter is over (caught or
    not), leaves a crown piece: a Gold Shard first, then jewels or gold shards, and the Crown Diamond 11th; all key
    items, unsellable and untossable. The 11 merge into the **Crown**, which becomes the **Sovereign Crown** after the
    rematch win over Cynthia. Victory Road waits on the last trial (Togedemaru). Henry appears at Spear Pillar only
    with the complete crown. The Celestic Town elder meets the player at home after the first Hall of Fame and sends
    them to Spear Pillar. After the Sovereign battle the Elite Four can still be rematched, with all-Lv. 100 teams.
    - Built (CB-0033): the elder at home, the rematch lock (the League door guard), and the Crown swap with
      Cynthia's call to Spear Pillar. Still to do: Henry at the throne, the title, and the Lv. 100 teams.
24. **Post-Champion money** (owner, 2026-10-22, all four options). Built in E7 part 2:
    - every shop that takes money sells at **half price** after the Hall of Fame (Battle Point shops are unchanged);
    - **3× prize money** from the Elite Four and Cynthia rematches, the Gym Leader rematches and the five Battleground
      trainers (`Sovereign_PostgamePrizeMultiplier` in `battle_script.c`). The developer battle joins the list once
      its trainer exists;
    - a **daily valuables NPC**: the Youngster at the Survival Area gives **3 Nuggets** once a day after the Champion
      (Big Nugget isn't an item in Platinum);
    - items **sell for their full buy price** after the Champion, **except items a shop sells**, which still sell
      for half. Without that rule, buying at the half price and selling at full price would make free money. So
      Nuggets, Pearls, shards and found items sell at full price; shop stock sells for what you paid for it.
25. **Post-game legendaries use existing spots** (owner, 2026-10-23). A legendary the plan put in a new room or floor
    stands in a fitting existing room or dead end nearby, and its `built` note in `data/postgame_legendaries.yaml`
    says "Changed from the plan".
26. **Legendaries are battled and caught, never given** (owner, 2026-10-23). This covers every Legendary, Mythical and
    Ultra Beast. People in the story can still lead to the battle or hand over key items, but the Pokémon itself is
    a battle. What makes each one appear is in `docs/LegendaryTriggers.md`.
27. **Spear Pillar is kept for Dialga, Palkia and the final story** (owner, 2026-10-23). No Chronicle encounter stands
    there. Cosmog (both battles) moves to Mt. Coronet's top snowfield, and Necrozma to Wayward Cave 1F's dark back
    chamber.
28. **Static encounters are for legendaries, and not every legendary needs one** (owner, 2026-10-23):
    - **Paradox Pokémon come from two dealers in the Oreburgh Mining Museum** (owner, 2026-10-24, replacing the
      rare wild encounters): once the player has all 8 badges, a fossil maniac (ancient) and a futuristic scientist
      (future) each give a Paradox Pokémon for a look at its present-day Pokémon, once each (no Cyclizar). Koraidon
      appears once all ten ancient ones are given, Miraidon once all ten future ones are.
    - **Ultra Beasts are rare wild encounters too,** on the maps they stood on, once Necrozma is caught. Poipole
      becomes wild on a route near the Fight Area.
    - **Roamers:** Okidogi, Munkidori, Fezandipiti, Glastrier, Spectrier and Zeraora roam Sinnoh instead of standing
      in one place. The other legendaries stay static (roamers can't hold items, so Zacian, Zamazenta and Ogerpon
      can't roam).

Open:
- **Overworld sprites and sizing for the legendaries** (owner, 2026-10-23: "we will need to work on" it). Today each
  is a 64x64 placeholder shrunk from its PokeAPI front sprite (`tools/sprites/make_legendary_overworld.py`), so tiny
  and huge Pokémon look the same size and the big ones cover the player and nearby tiles.
- Regional Forms Park (decision 22): which zone holds which forms, the odds and levels (proposal in
  `docs/RegionalFormsPark.md`), and when it opens (now after the Hall of Fame; `Story.md` suggests Oak's visit).
- Special evolutions (decision 20): owner discussion pending.
- The developer battle: Lv. 100 at Spear Pillar, leads Charizard-Y + Venusaur, custom weather-control AI (`DeveloperBattle.md`). Opponent: Sovereign Henry (decision 23). Open: text, sprites (owner's sprite coming soon).
- Front sprites and the part 2 shiny pack (owner is sourcing them).
  - Source to check for E12 (owner, 2026-10-23): **thesonicgameryt** on DeviantArt,
    https://www.deviantart.com/thesonicgameryt. It has good custom sprites for a lot of the new Megas, including the
    Mega Garchomp Z the owner supplied. Credit every sprite used in `CITATIONS.md`.
- hg-engine and Smogon credit lists: Claude compiles them (owner, 2026-10-22).
