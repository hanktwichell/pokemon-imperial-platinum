# Sovereign Platinum — Technical Design

This document covers the engine work needed to turn Renegade Platinum v1.3.0 into Sovereign Platinum. The design data
(encounters, trainers, Megas, evolutions, legendaries) is engine-independent and lives in `data/` and `docs/`.

## Starting point

- **Renegade Platinum is distributed as xdelta patches** (`RenegadePlatinumV130/Base Patches - USE ONE OF THESE FIRST/`).
  Applying one needs a clean US Pokémon Platinum ROM (3541 or 4997/4998 dump). **The ROM isn't in this repository and
  can't be provided by Claude.** Each developer supplies their own dump; `tools/build/apply_renegade_patch.sh` applies
  and checks the patch.
- Renegade is a **binary hack** (no public source). Its changes include expanded NARCs (which is why the Universal
  Randomizer can't read it, per its FAQ), edited scripts, trainer data, learnsets and engine patches (Fairy type, move
  replacements, abilities).

## Two ways to build Sovereign

| | **A. Binary hack on the Renegade ROM** | **B. Rebuild on the pret/pokeplatinum decompilation** |
|---|---|---|
| Tools | DSPRE (maps, scripts, encounters, trainers), Tinke / NitroPaint (graphics), custom ASM injected into a new overlay | C source + Make; data in JSON/text; assets as PNGs |
| Renegade content | Kept automatically | Must be re-implemented from Renegade's docs (all documented in `RenegadePlatinumV130/Documentation`) |
| Adding 532 species, 900+ forms | Very hard: dozens of tables hard-coded around 493; NARC expansion by hand | Feasible: tables are C arrays and data files; species constants can be extended |
| Mega battle mechanic | ASM hooks in the battle overlay | C changes in `src/battle/` |
| New moves/abilities | ASM per effect | C per effect |
| Maintainability / collaboration | Low (binary diffs) | High (text diffs, reviewable PRs) |

**Recommendation: B.** Adding every species from Gen V–IX touches the same hard-coded tables that make A impractical
at this scale. To our knowledge the mature "add every species and Megas to Gen IV" engine (hg-engine) targets HeartGold
and SoulSilver, not Platinum. Its approach (expanded tables in a new overlay, new battle effects) is the model to follow,
or to port, whichever route is chosen. This decision is the project owner's to make. It decides how every item below is
implemented.

## Work packages

### 1. Species expansion (493 → 1025)
- Personal data (base stats, types, abilities, EV yields, egg groups, gender, growth), evolution table, level-up
  learnsets, TM/HM and tutor compatibility, egg moves, Pokédex text, height and weight. Source: `data/species.csv`
  (generated from PokeAPI) plus a learnset export (to be added).
- Pokédex: national dex arrays, Sinnoh dex order (decide whether added species extend the regional dex), and the
  **Pokédex save bitfields, which are sized for 493**. Expanding them **breaks save compatibility with Renegade**.
- Box/party data stores species as 16-bit, so that's fine. Check the PID-based form/gender logic for new species.
- Icons (party/PC), footprints, cries (SDAT; can start as pitch-shifted placeholders), overworld follower sprites (not
  needed: Platinum has no followers).
- Pal Park, Poké Radar, honey trees and swarm tables only need data once species exist.

### 2. Moves and abilities
- Sovereign's move list = Gen IV moves + Renegade's 11 replacements. **Added species need learnsets built from that move
  list** unless new moves are added. Decision needed: (a) remap learnsets to existing moves (cheap; a generator can do
  it), or (b) add selected Gen V–IX moves (each needs a battle effect and animation).
- Most added species' abilities are Gen V+. Same decision: map to Gen IV abilities, or implement new abilities. Mega
  abilities used by boss trainers must be implemented first (Magic Bounce, Parental Bond, Strong Jaw, Tough Claws,
  Aura Guard). See `MegaEvolution.md`.

### 3. Items
- Add 95 Mega Stones/orbs, the Mega Ring, 16 evolution items and the legendary key items (Light Stone, Dark Stone, Prison
  Bottle, Scrolls, etc.). Platinum's item table ends at ~467; expansion needs new item data, icons and palettes, names
  and descriptions, and bag-pocket assignment.
- Field-item replacements are listed in `MegaEvolution.md` (vanilla script names from the decomp; verify against Renegade).

### 4. Mega Evolution / Primal Reversion
- Battle: a per-battler "mega pending" bit set from the move-select UI; at the start of the turn (before moves), swap
  the battler's form → recalculate stats/type/ability → play the animation → print text. Platinum already changes form
  mid-battle (Castform, Cherrim, Giratina, Shaymin), so the form-change plumbing exists.
- UI: a MEGA toggle on the touch-screen fight menu, shown only when `FLAG_SOVEREIGN_MEGA_UNLOCKED` is set, the Pokémon
  holds its stone, and the trainer hasn't Mega Evolved yet this battle.
- AI: trainers Mega Evolve on the first turn possible.
- Forms: 99 new form entries (stats, types, abilities, sprites). Revert on battle end/faint.
- Animation: new battle animation script and particles; spec in `MegaEvolution.md`.

**E8 status and code map** (survey of the decomp, 2026-10-22; paths under `decomp/`):
- **Done (E8 step 1).** The 99 forms are generated by `tools/engine/gen_forms.py` from `data/megas.csv` and packed
  after Platinum's 12 alternate forms.
  - The `speciesproc.c` list includes `sovereign_forms.inc`.
  - `Pokemon_GetFormNarcIndex` (`src/pokemon.c`) looks a species and form up in `include/data/sovereign_forms.h`.
  - `MOVESET_MAX` grows by `SOVEREIGN_FORM_COUNT`, since every form gets a tutor row.
  - A form only gets its Mega ability when the engine has it; otherwise its data lists `ABILITY_NONE` and the battle
    keeps the Pokémon's own ability.
- **Sprites and icons (E12).** Until then a Mega shows its base species. `BuildPokemonSpriteTemplate` (`pokemon.c`)
  ignores the form for these species, and `BoxPokemon_IconFormOffset` (`pokemon_icon.c`) is a whitelist they aren't
  on. Adding art later needs:
  - `pl_otherpoke` members after 250 (Substitute's 248–250 are hard-coded in `battle_anim/ov12_022380BC.c`), with a
    third block in `tools/scripts/make_pl_otherpoke.py`;
  - a lookup in `BuildPokemonSpriteTemplate`;
  - Y offsets from a new source (`height_o.narc` is a prebuilt binary);
  - icons appended to `res/pokemon/meson.build` and the `FormIconIndex` enum, in the same order.
- **Changing form in battle.** Platinum's path:
  1. Set `BATTLEMON_FORM_NUM` with `SYSCTL_RECALC_MON_STATS`.
  2. `BtlCmd_UpdateMonData` → `BattleController_EmitUpdatePartyMon`, which writes the form and ability into the
     party Pokémon and recalculates its stats.
  3. `BtlCmd_RefreshMonData` → `BattleSystem_ReloadPokemon` copies stats back. Types and ability are set separately:
     `LoadArchivedMonData` takes a literal species, so Megas need C code or a new btlcmd.
  4. The sprite swap is `BtlCmd_ChangeForm` → `BtlIOCmd_ChangeWeatherForm`.
  - The Giratina-Transform branch of `BattleSystem_TriggerFormChange` (`battle_lib.c`) does it all in C.
- **Reverting.** The party Pokémon keeps the Mega form and ability while switched out, which is correct. Revert in
  `BattleMain_CopyBattleSysToDTOAndFree` (`battle_main.c`, next to `BattleSystem_SetBurmyForm`): set the form to 0,
  call `Pokemon_CalcAbility`, then `Pokemon_CalcLevelAndStats`. A caught wild Primal skips that path, so it is also
  reverted in `BattleSystem_SetPokemonCatchData`.
- **When it happens.** Switches run inside `BranchActions` (`battle_controller_player.c`) before any FIGHT action, so
  Mega Evolution goes in when the next action is the first FIGHT: switches, then Megas, then moves. Then re-sort the
  remaining actions, because the dynamic-speed re-sort is skipped while `turnOrderCounter` is 0. `TurnFlags` has 22
  spare bits for "Mega this turn".
- **MEGA button.** The move menu is config 11 in `battle_subscreen.c`:
  - `sMoveSelectMenuTouchRects`, results `{0xFF, 1, 2, 3, 4}`; 5 is RUN.
  - `pl_batt_bg` is prebuilt, but `pl_batt_obj` is built from source, so the button is an OBJ sprite there
    (`interface/mega_button.*`, resource ID 20040), with the held stone's item icon as a second sprite (20041). Its
    touch rect is index 5 (result `0x10`); the D-pad reaches it with UP from the top row of moves.
  - Carry the toggle in bits 8–15 of the selected-move int (`ioBuffer[i][1]`) and latch it in `MOVE_SELECT`, since
    target selection clears the buffer.
  - "Can Mega" travels server → client through `MoveSelectMenuMessage` → `MoveSelectMenuData` → `MoveSelectData`.
  - Recording stores one byte per input, so it needs the flag too.
- **Primal Reversion.** A new state in `BattleSystem_TriggerEffectOnSwitch` (`battle_lib.c`) before
  `SWITCH_IN_CHECK_STATE_WEATHER_ABILITIES`, so Primordial Sea and Desolate Land start on the same switch-in.
- **Animation.** It's split around the form change, because `ChangeForm` is a battle-script command:
  - The common animations `sovereign_mega_evolution` / `sovereign_primal_alpha` / `sovereign_primal_omega`
    (`res/battle/scripts/common_anims/`) run before it. `sovereign_mega_evolved` /
    `sovereign_primal_alpha_revealed` / `sovereign_primal_omega_revealed` run after it.
  - Each reveal flashes its symbol, an animation sprite in `res/graphics/battle/moves/` (`anim_*.order`), with
    `SPRITE_FUNC_OFFSET_AND_ANIMATE`. That function deletes the sprite when its non-looping NANR ends.
  - Fades normally return to 0 before an animation ends. `Func_SovereignFadeSprites` (func 84,
    `script_funcs_3.c`) fades one way instead: the attacker stays white and the other battlers stay dim across the
    swap.
  - The palette reload in `BtlIOCmd_ChangeWeatherForm` would undo the fade, so it re-applies a held fade.
  - Load particles with `LoadParticleSystem` while sprites are held faded. `LoadParticleResource` draws unfaded
    battler copies while it loads.
  - In a single battle, `BATTLE_ANIM_BATTLER_PLAYER_2` / `ENEMY_2` fall back to player 1, so don't fade by slot.
- **Mega symbol by the name.** Each healthbox has a third sprite, `sovereignMegaIcon` (`healthbox.c`).
  - Resources: char, cell and anim ID 20042, shared by all the healthboxes; palette `HEALTHBOX_MAIN_PALETTE_RESID`.
  - Animation 0 is the Mega symbol, 1 is α and 2 is Ω.
  - `HealthBox_SovereignPlaceMegaIcon` keeps it at `sSovereignMegaIconOffset` from the box. It's called on create,
    in `HealthBox_OffsetPositionXY` (slide and bob) and in the scroll task.
  - `HealthBox_Enable` and `Healthbox_SetExplicitPriority` apply to it too.
  - `HealthBox_SovereignDrawMegaIcon` runs whenever the name is drawn. It reads the party Pokémon's form and shows
    the symbol only while the box is drawn.
  - The battle-script command `SovereignRefreshHealthBox` (after `End` in `btlcmd.h`) sends
    `BattleController_EmitRefreshHPGauge`, which redraws the name after the reveal.

### 4b. All other forms (milestone FM, decision 16)
- **Data.** `data/forms.csv` (`build_species_data.py`) lists every alternate form with its own data, with a category.
  `gen_forms.py` packs the ones built so far (`FM_FORMS`) after the Megas in `sSovereignForms`.
  - An FM form keeps its real abilities, unlike a Mega.
  - Its form number is saved, so numbers must not shift once saves matter. Numbers count a species' Megas first,
    then its `FM_FORMS` entries.
- **Held-item forms** (`SOVEREIGN_FORM_HELD_ITEM`: Ogerpon's masks, Origin Dialga/Palkia).
  - `BoxPokemon_SetArceusForm` (`pokemon.c`) sets the form from the held item. Every place that changes a held item
    outside battle already calls it for Arceus: the party menu's give and take, and the PC's give.
  - `Pokemon_SetArceusForm` recalculates stats when the form changes.
- **Battle-item forms** (`SOVEREIGN_FORM_BATTLE_ITEM`: Crowned Zacian/Zamazenta).
  - `BattleSys_New` (`battle_main.c`) calls `Pokemon_SovereignSetBattleItemForm` on every party before the battle
    copies them. It swaps Iron Head for the Behemoth move, keeping the PP used.
  - `Pokemon_SovereignRevertBattleForm` undoes it, and undoes Megas and Primals. It runs at the end of the battle
    and in `BattleSystem_SetPokemonCatchData`.
- **Item locks.** `Pokemon_SovereignItemIsLocked(species, item)` is TRUE for any form trigger on its own species
  except Mega Rayquaza's move, and also for the Teal Mask on Ogerpon and the Griseous Core on Giratina.
  `Battler_SovereignHeldItemLocked` (`battle_lib.c`) applies it in battle:
  - `BtlCmd_TryStealItem` (Thief and Covet) and `BtlCmd_TrySwapItems` (Trick and Switcheroo) fail.
  - `BtlCmd_TryKnockOff` leaves the item.
  - `BattleSystem_FlingItem` fails.
- **Key-item forms** (`SOVEREIGN_FORM_KEY_ITEM`: Therian Formes, Hoopa Unbound) and **fusions**
  (`SOVEREIGN_FORM_FUSION`: Kyurem, Necrozma, Calyrex; the form's `trigger` is the partner species).
  - The key items have `ITEM_USE_FUNC_SOVEREIGN_FORM` (`item_use_functions.c`), which opens the party menu with the
    item like the Gracidea.
  - `ApplyItemEffectOnPokemon` (`party_menu/main.c`) hands them to `SovereignFormItem_Use`
    (`src/sovereign_form_items.c`), then plays the Gracidea's form-change animation on the slot that changed
    (`form_change.c` gives Sovereign species Giratina's effect).
  - A fused partner is removed from the party only after the animation, so the slots on screen don't shift during
    it. The party menu then closes back to the bag.
  - **Partner storage:** each fusion item keeps its partner in `MigratedPokemon.mons[item]`, Pal Park's transfer
    storage. Pal Park and migration are removed (decision 22): the Catching Show never starts (the Regional Forms
    Park replaced it) and the main menu's Migrate option is gone, so nothing else writes there.
  - The form's moves are a table in `sovereign_form_items.c`.
  - `BoxAppMan_CheckReleaseMonValid` (`pc_boxes/box_app_manager.c`) refuses to release a fused Pokémon.
- **Regional forms** (`SOVEREIGN_FORM_REGIONAL`), plus `SOVEREIGN_FORM_BATTLE` (Zen Mode, data only).
  - **What's form-aware:**
    - Already, through `Pokemon_GetFormNarcIndex`: stats, types, abilities, TM bits and level-up learnsets (so the
      move reminder and Eggs too).
    - Base species only: egg moves, tutor moves and the baby lookup.
    - `gen_forms.py` builds an FM form's learnset with `gen_species_gen9.build_learnset` from its PokeAPI id.
  - **Evolutions.** `evo.narc` has a member for every form, but Platinum only reads the species'.
    `Pokemon_GetEvolutionTargetSpecies` now reads a regional form's own member, which holds the base species'
    evolutions or `regional_forms` (`data/evolution_changes.yaml`).
  - **The evolved form.** `Pokemon_SovereignSetEvolvedSpecies` (called by `evolution.c` for the evolution and its
    preview sprite) sets the target's form from `sSovereignFormEvolutions`: the target's form of the same region,
    else 0. Other forms are kept, as before.
  - **Eggs.** `Daycare_GiveEggFromDaycare` asks `Pokemon_SovereignBabyForm` for the form of the non-Ditto parent
    (`sSovereignBabyForms`: the baby's form of the parent's region, or 0, and `regional_parents`). Parents with no
    rule keep Platinum's raw form copy.
  - **Numbering.** A species' FM forms come first, in `FM_FORMS` order, and its Megas follow. FM numbers are saved
    and follow the official games; Mega numbers only exist in battle.

- **Regional Forms Park** (decision 22, `docs/RegionalFormsPark.md`).
  - **Encounter slots with a form.** `EncounterSlot.species` is an `int`. `WILD_SLOT(species, form)` puts the form in
    its upper 16 bits (`constants/wild_encounters.h`). `CreateWildMon` and `CreateWildMonShinyWithGenderOrNature`
    (`overlay006/wild_encounters.c`) take the species from the low bits, then `ApplySlotForm` sets the form and
    recalculates the ability and stats.
  - **Zones.** `RegionalFormsPark_FillEncounterTable` runs after the table is built, for grass, Surf, fishing, Sweet
    Scent and mud, on `MAP_HEADER_PAL_PARK` only. It picks the zone by quadrant (x and z below or above 32, as
    `catching_show.c`'s `GetEncounterArea`), one entry by weight and a level in its range, and fills every slot.
  - **Visits.** `VAR_PAL_PARK_STATE` 3 means a park visit; 1 and 2 are still the Catching Show's. The lobby worker
    sets it, the park's init script skips the countdown (it runs on 0), the gate's coord event for 3 asks to leave,
    and the lobby's init script sends 3 to the exit frame script, which sets it back to 0.
  - The Catching Show's own code (`catching_show.c`, Park Balls, `SystemFlag_CheckInPalPark`) is untouched and never
    runs.
- **Totem trials** (decision 18, `docs/TotemTrials.md`).
  - **Data.** `data/totem_trials.yaml` → `tools/engine/gen_totem_trials.py` → `include/data/sovereign_totem_trials.h`
    (Totem, aura stages, 3 helpers) and `include/constants/sovereign_totem_trials.h` (`TOTEM_TRIAL_*`).
  - **Start.** `SovereignStartTotemTrial` → `Encounter_SovereignNewTotemTrial` (`encounter.c`).
    - It builds a plain `BATTLE_TYPE_DOUBLES` wild battle: the Totem, then the helpers, in `parties[1]` through
      `CreateWildMon_SovereignScriptedForm`.
    - The status mask carries `BATTLE_STATUS_SOVEREIGN_TOTEM` and the aura in bits 16-30
      (`BATTLE_STATUS_TOTEM_AURA`).
    - The trainer slots 1 and 3 get an AI mask; `Task_TrainerShowMoveSelectMenu` uses the trainer AI for the flag.
  - **Battle.**
    - Both enemy battlers draw from `parties[1]`, so `ReplaceFainted` sends in the next helper with the existing
      shared-party code.
    - `BattleSystem_SovereignTotemFainted` (wild party slot 0 at 0 HP) stops further calls in `ReplaceFainted`, and
      makes `CheckBattleOver` a win once both enemy battlers are down.
    - `LoadSendOutMessage` prints the "called its ally" line.
    - The ball rule reuses the AI-partner check in `BattleController_EmitShowBagMenu`.
  - **1 vs 2.** With one Pokémon able to battle, the player's second slot starts empty, in the state Platinum leaves a
    doubles slot in after a faint with no replacement: party slot 6, its bit in `battlersSwitchingMask`, 0 HP.
    - `battle_main.c` gives slot 2 party slot 6 when no second able Pokémon is found (plain doubles, so a scripted
      trainer double battle works the same way). `BattleSystem_InitPartyOrder` and `BattleMain_InitTerrains` skip
      it.
    - `BattleControllerPlayer_InitBattleMons` sets the mask bit and, through
      `BattleDisplay_SovereignSetAbsentBattler`, points its sprite at its own inactive slot in the sprite manager
      (what `PokemonSprite_Delete` leaves after a faint), so animations never meet a NULL sprite.
    - The intro skips it: `PokemonSlideIn` and `HealthBoxSlideInDelay` check the mask, the trainer's throw has no
      second ball (`Task_ThrowTrainerBall`), and `LoadLeadMonMessage` prints "Go! {0}!".
  - **Aura.** `SWITCH_IN_CHECK_STATE_SOVEREIGN_TOTEM_AURA` runs once (`sovereignTotemAuraDone`).
    `BattleSystem_SovereignApplyTotemAura` raises the stages and buffers the message for
    `subscript_sovereign_totem_aura`.
  - **No escape.** RUN, `BtlCmd_TryWhirlwind`, `BtlCmd_TryTeleport` and the bag's escape items check the flag.
  - **On the map.**
    - The Totem is an object with `OBJ_EVENT_GFX_TOTEM_<SPECIES>`: a single 64x64 frame on `BILLBOARD_MODEL_GENERIC_64x64`
      (Regigigas's setup). The textures are appended at the end of `field_sprites.order` so no existing NARC index
      moves.
    - Its hidden flag is the trial's `FLAG_SOVEREIGN_TOTEM_TRIAL_*` (0x167–0x171, in trial order). Its script sets
      `VAR_0x8004` to the trial and calls `Common_SovereignTotemTrial` (common script 0x80A).
    - The common script hides the Totem by setting `FLAG_MAP_LOCAL_REMOVE_OBJECT` around the battle: map objects
      survive a battle, so the map's OnLoad script removes the Totem when the field comes back, as Platinum does for
      Regigigas. Removing it sets its hidden flag; a loss clears it again (`SovereignClearFlagFromVar`).
    - A Totem whose place opens before its trial uses `FLAG_MAP_LOCAL_HIDE_TOTEM` (map-local 0x3E) as its hidden flag
      instead: the map's OnTransition sets it while the trial is done or not yet open (Floaroma Meadow, the Old
      Chateau dining area, Lost Tower 5F). Map-local flags are cleared on every map change, so this check runs
      again on each visit.
    - Great Marsh Area 3's OnTransition is the map's own script (Totem check, then `InitGreatMarshTram`), not the shared
      Safari script 0x2260. The trial's loss branch clears `FLAG_SAFARI_GAME_ACTIVE` and `VAR_SAFARI_GAME_STATE` itself:
      `EndSafariGame` hangs between a lost battle and the blackout, since the field isn't loaded then.
    - The piece is `ITEM_GOLD_SHARD + trial`: the 11 piece constants are consecutive in trial order. The merge into
      `ITEM_CROWN` checks and removes `ITEM_GOLD_SHARD`..`ITEM_CROWN_DIAMOND` in a loop.
- **The Chronicles** (post-game legendaries, `docs/PostgameLegendaries.md` from `data/postgame_legendaries.yaml`).
  - **The Archivist.** `LOCALID_SOVEREIGN_ARCHIVIST` in Canalave Library 2F, hidden by OnTransition
    (`FLAG_MAP_LOCAL_HIDE_SOVEREIGN_NPC`) until `FLAG_GAME_COMPLETED`. His first talk sets `VAR_SOVEREIGN_CHRONICLE` to 1
    (the Unova Chronicle open). Later talks show a menu (`InitLocalTextMenu`, one entry per part of the Chronicle, then
    "That's all") that comes back after each topic. Each topic checks the Pokédex and gives only what's left: for the
    swords, one hint message per sword not caught yet, then Keldeo at Lake Valor.
    - A talk with Kyurem caught (the Unova key) raises the var to 2, the Kalos Chronicle. From then on a first menu asks
      which Chronicle to read from, and each Chronicle has its own topic menu and "Anything else" loop.
  - **A static legendary** is an object with `OBJ_EVENT_GFX_LEGENDARY_<SPECIES>`, a 64x64 billboard like the Totems'.
    - Its hidden flag is `FLAG_MAP_LOCAL_HIDE_LEGENDARY`. The map's OnTransition sets it, then clears it once the
      chapter is open and `SovereignCheckSpeciesCaught` says the Pokédex doesn't have the species as caught. No
      persistent flag per Pokémon is needed.
    - Its script sets `VAR_0x8004` (species) and `VAR_0x8005` (level) and calls `Common_SovereignLegendaryEncounter`
      (common script 0x80B).
    - The common script sets the global `FLAG_SOVEREIGN_REMOVE_LEGENDARY` around `StartLegendaryBattle`. The map's
      OnLoad removes the object while it's set, since objects survive a battle.
    - After a win: "{species} vanished... It might show itself here again." The object comes back on the next visit
      until it's caught. A loss blacks out. `StartLegendaryBattle` doesn't let the player run, as in vanilla.
    - Placed so far: Virizion (Eterna Forest), Terrakion (Route 227), Cobalion (Iron Island B2F right room) and Keldeo
      (Lake Valor). Keldeo's OnTransition also needs `CheckPartyHasSpecies` to find all three swords in the party.
      Victini (Vista Lighthouse) needs the var at 1 only.
    - **Kalos** (var 2): Xerneas (Eterna Forest), Yveltal (Lost Tower 5F) and Volcanion (Stark Mountain room 1) need the
      var only. Zygarde (`WAYWARD_CAVE_B1F`, own script archives like the ice chamber's) waits for Xerneas and Yveltal
      caught. Diancie (Oreburgh Mine B2F) checks `CheckPartyHasSpecies` for a Carbink. Hoopa (Solaceon Ruins Room 7)
      checks `CheckItem ITEM_PRISON_BOTTLE`, which the Archivist gives while the player doesn't have it.
    - **Alola** (var 3, from a talk with Xerneas and Yveltal caught): the four Tapus need the var only.
      - Mt. Coronet's top snowfield (`MT_CORONET_OUTSIDE_NORTH`, which had `scripts_empty` and gets its own archives,
        like the ice chamber's) shows a Cosmog (a Lv. 5 battle) while `FLAG_SOVEREIGN_CAUGHT_COSMOG` is unset. It
        shows again while `_COSMOG_2` is unset and the Pokédex has Solgaleo or Lunala as caught. The Pokédex can't
        tell the two apart, so a catch sets the flag.
      - Necrozma (Wayward Cave 1F's dark back chamber, a new OnLoad entry there) needs the same Solgaleo-or-Lunala
        check. Spear Pillar has no Chronicle encounter (decision 27): it's kept for Dialga, Palkia and the story.
    - **Rare wild encounters** (decision 28): the Paradox Pokémon (from var 5) and the Ultra Beasts with Poipole
      (once Necrozma is caught) aren't statics. `data/sovereign_rare_wild.yaml` lists each one's maps, terrain, rate
      and level; `tools/engine/gen_rare_wild.py` checks it (every map must have wild encounters of that terrain, and a
      map's rates add up to 100 or less) and writes `include/data/sovereign_rare_wild.h` and
      `docs/RareWildEncounters.md`.
      - `SovereignRareWild_TryFillEncounterTable` (`src/overlay006/wild_encounters.c`) runs after the swarm, Trophy
        Garden, dual-slot and Regional Forms Park changes, in the grass, surf, Sweet Scent and mud paths. One roll per
        encounter walks the map's entries whose gate is met (`VAR_SOVEREIGN_CHRONICLE` and a caught species) and
        fills all the slots with the one it lands on, so Repel, abilities and shiny odds work as usual.
      - No roll in a Poké Radar patch, with a partner or in the Safari Game. Fishing and roamers are unchanged
        (roamers are still checked first).
    - **Galar** (var 4, from a talk with Solgaleo or Lunala caught) and **Paldea** (var 5, Zacian and Zamazenta
      caught) finish the Chronicles. Every legendary added from CB-0043 on uses one generic pattern:
      - The common script stores the battled species in `VAR_SOVEREIGN_LEGENDARY_SPECIES` (a save var). Each map's
        OnLoad starts with `CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, <Map>_RemoveLegendary<Species>`, which removes
        the object only when that var names its species. Any number of legendaries can then share a map, next to
        the older `VAR_MAP_LOCAL_0x00` notes.
      - Hidden flags `FLAG_MAP_LOCAL_HIDE_LEGENDARY` to `_5` (map-local 0x1E, 0x1C, 0x1B, 0x1A, 0x19).
      - **Held items:** a script sets `VAR_SOVEREIGN_LEGENDARY_HELD_ITEM` before the battle, and
        `Encounter_NewVsSpeciesAtLevel` (`encounter.c`) gives the item to the wild Pokémon and clears the var: Zacian's
        Rusted Sword, Zamazenta's Rusted Shield, Ogerpon's Teal Mask.
      - **Stakes** (the Treasures of Ruin): `Common_SovereignStake` (common script 0x80C) asks to pull one out, sets
        its `FLAG_SOVEREIGN_PULLED_STAKE_*` and removes it. The map script then reruns the shrine's visibility check
        and `AddObject`s the legendary when both stakes are out.
      - Ogerpon's other masks: `CelesticTownNortheastHouse_PokefanM` checks the species in party slot 0 once
        (`FLAG_SOVEREIGN_RECEIVED_OGERPON_MASKS`). `GetPartyMonSpecies` reads the slot from a var, so the script sets
        `VAR_0x8004` to 0 first.
      - Objects must stand on a flat tile the player can face at the same height: talking checks that the two
        heights match exactly (`sub_0203C9B0`). An object on stairs or a slope can't be talked to (Zacian's first spot).
      - A one-frame object such as `OBJ_EVENT_GFX_BOLLARD` (the stakes) must face down, as vanilla's do; facing up
        draws nothing.
      - The Archivist gives the Reins of Unity (Calyrex caught) and both Scrolls (Kubfu caught).
    - **No gifts** (owner, 2026-10-23): every legendary is a battle. `Common_SovereignLegendaryEncounter` returns
      `VAR_RESULT` TRUE after a catch (FALSE after a knock-out or a loss), for encounters that need a flag of their own.
      CB-0042's gift script (common script 0x80C) is gone.
    - **Two legendaries on one map** (Eterna Forest: Virizion and Xerneas). Xerneas hides with
      `FLAG_MAP_LOCAL_HIDE_LEGENDARY_2` (map-local 0x1C, unused in vanilla). The OnLoad removal after a battle has to
      know which one was fought: each talk script stores its species in `VAR_MAP_LOCAL_0x00` first. Map-local vars last
      through a battle (only a map change clears them), while the special vars (`VAR_0x8009`, which the common script
      keeps the species in) can't be read from OnLoad on the way back: a first try with them always removed Virizion.
    - **Quest-triggered ones** show only once a global flag is set:
      - Meloetta (in front of the Contest Hall stage) waits for `FLAG_SOVEREIGN_MELOETTA_SONG`. The composer in the lobby sets it when
        `FindPartySlotWithMove` finds a party Pokémon with Sing and the player agrees.
      - Genesect (Galactic HQ lab, back room) waits for `FLAG_SOVEREIGN_GENESECT_FREED`. The lab's male scientist sets
        it in his confession, then `AddObject` shows Genesect right away.
    - **Truth and Ideals.** The Archivist gives `ITEM_LIGHT_STONE` and `ITEM_DARK_STONE` (`Common_GiveItemQuantity`)
      while the player has neither the Light Stone nor Reshiram. The OnTransitions then check:
      - Reshiram (Fuego Ironworks building): `CheckItem ITEM_LIGHT_STONE`.
      - Zekrom (Valley Windworks outside): `CheckItem ITEM_DARK_STONE`, and `GetTimeOfDay` at `TIMEOFDAY_NIGHT` or
        later (8 pm to 4 am). The check runs on entering the map only.
      - Kyurem (`MT_CORONET_ICEBERG_RUINS`, which gets its own script archives like Iron Island B2F's right room): both
        dragons caught. Vanilla's north room swaps this doorway to the Regice chamber when the party has a
        fateful-encounter Regigigas, so Kyurem waits until the player comes without one.
      - The Archivist gives `ITEM_DNA_SPLICERS` once Kyurem is caught (`CheckItem` keeps it to one).
    - **Forces of Nature.** `ROAMING_SLOT_TORNADUS` and `ROAMING_SLOT_THUNDURUS` (`generated/roaming_slots.txt`) make 8
      roaming slots. Each `Roamer` is in the special-encounter save block, so the save grows by 42 bytes. Save block 0
      is now 0xCEE4 of its 13 sectors (0xD000), measured in the test build; the save still fits Platinum's 32 sectors.
      - Their states are `VAR_ROAMING_TORNADUS_STATE` and `VAR_ROAMING_THUNDURUS_STATE`
        (`SystemVars_SetRoamingSpeciesState`).
      - The Hall of Fame resets a knocked-out one (`ROAMER_STATE_DEFEATED` to `_RESET`), and the Archivist releases it
        again, as Professor Oak does for the legendary birds.
      - Landorus (`ROUTE_228_ROCK_PEAK_RUINS`, own script archives like the ice chamber's) checks `CheckPartyHasSpecies`
        for both. Enamorus (Route 224) waits for Landorus caught.
    - **More roamers** (decision 28): Zeraora takes vanilla's unused Darkrai slot (`ROAMING_SLOT_ZERAORA`), and
      `ROAMING_SLOT_OKIDOGI`, `_MUNKIDORI`, `_FEZANDIPITI`, `_GLASTRIER` and `_SPECTRIER` make 13 slots. The five new
      `Roamer` records and route bytes add 104 bytes to save block 0 (about 0xCF4C of 0xD000).
      - States `VAR_ROAMING_<SPECIES>_STATE` (former `VAR_UNUSED_*`), reset by the Hall of Fame like Tornadus's.
      - The Archivist releases them the first time he reads their topic (`FLAG_SOVEREIGN_RELEASED_ZERAORA`, `_LOYAL_THREE`;
        `_STEEDS` once Calyrex is caught) and again after a Hall of Fame reset.
      - `RoamerAfterBattle_UpdateRoamers` now needs `BATTLE_TYPE_ROAMER`: vanilla matched the battled Pokémon to a
        roamer by species alone, so a wild Galarian Articuno in the Regional Forms Park knocked out or caught would
        have wiped a roaming Articuno.
    - Iron Island B2F's right room had `scripts_empty`. It now has its own `scripts_iron_island_b2f_right_room` and
      `scripts_init_iron_island_b2f_right_room`, appended at the end of `scripts.order` so no other archive moves.
- **Galactic gates** (decision 23, `docs/Story.md`). Each Galactic encounter checks the `FLAG_SOVEREIGN_TOTEM_TRIAL_*`
  flags of the trials before it, at a blocker the player already meets:
  - the Windworks door grunt and the Celestic ruins grunt (`GoToIfUnset` before their battle);
  - a new Eterna door grunt (hidden with `FLAG_MAP_LOCAL_HIDE_TRIAL_GATE`, map-local 0x3F);
  - the Route 218 blockade (`FLAG_HIDE_ROUTE_218_BLOCKADE`, now set by Route 218's OnTransition once Salazzle is done);
  - the Spear Pillar grunts' coord event;
  - a new Victory Road guard with a coord event on `VAR_MAP_LOCAL_0x00`.
- **After the first Hall of Fame** (decision 23, `docs/Story.md`).
  - **The elder at home.** `VAR_PLAYER_HOUSE_POSTGAME_STATE` is 1 from the first Hall of Fame until the player first
    comes downstairs.
    - While it is 1, the 1F OnTransition shows `LOCALID_SOVEREIGN_ELDER` (hidden flag `FLAG_SOVEREIGN_HIDE_HOME_ELDER`,
      recomputed on every visit).
    - Mom's Platinum post-game scene calls `TwinleafTownPlayerHouse1F_SovereignElderVisit`. The elder sets Platinum's
      own `FLAG_UNLOCKED_DIALGA_PALKIA_SPEAR_PILLAR` (vanilla sets it in her Celestic house), then leaves.
    - Mt. Coronet 6F then warps to the Dialga or Palkia map for a player holding that Orb, as in Platinum.
  - **The rematch lock.** Platinum has no save-prompt NPC, so the north Pokémon Center's door guard is the gate.
    - `PokemonLeagueNorthPokecenter1F_SovereignCheckRematchLocked` returns TRUE after the first Hall of Fame until
      both legendaries are done: each one caught (`FLAG_CAUGHT_*`) or its `VAR_SPEAR_PILLAR_*_STATE` at 1 or more.
    - The state vars reset at each Hall of Fame while uncaught, so the first pass sets `FLAG_SOVEREIGN_REMATCH_UNLOCKED`
      for good.
    - While locked, OnTransition leaves the guard at the door and his talk script explains.
  - **The Sovereign Crown.** The Champion room calls `PokemonLeagueChampionRoom_SovereignRematchWin` after any win with
    `FLAG_GAME_COMPLETED` set, which means a rematch, since the first Hall of Fame sets it.
    - The first time, it swaps `ITEM_CROWN` for `ITEM_SOVEREIGN_CROWN`, and Cynthia sends the player to the Spear
      Pillar (`FLAG_SOVEREIGN_CALLED_TO_SPEAR_PILLAR`, which Henry's appearance will check).
    - On later wins she only reminds them, until `FLAG_SOVEREIGN_DEFEATED_HENRY`, which the Sovereign battle will set.
### 5. Trainer data
- Vanilla Gen IV trainer Pokémon can't specify EVs, natures directly (nature comes from the PID seeded by trainer
  data), or abilities. **The EV spreads and natures in `TrainerPokemon_Sovereign.md` need an extended trainer-Pokémon
  format** (as hg-engine does for HGSS: per-mon nature, ability, IVs, EVs, ball, shiny).
- New trainer IDs: 19 for the League (see `EliteFourFormat.md`) plus edited story bosses.

### 6. Scripts and maps
- Elite Four format prompts (`EliteFourFormat.md`), the Mega Ring gift after Fantina, four Mega Stone vendors, five new
  starter Interviewers, the Legend Archivist and ~35 post-game events, some of them in new rooms/maps (Sendoff Spring
  crater, Oreburgh Mine B3F, …).
- Wild encounter tables per `WildPokemon_Sovereign.md` / `data/encounters_sovereign.json` (slot-exact, 12 grass + 5×4 water).

### 7. Graphics
- Gen IV battle sprites: 80×80 per frame, two frames per sheet (160×80), 4bpp, **one 16-colour palette shared by the
  front and back sprite**, plus a shiny palette with the **same index order**.
- The owner-supplied "DPPt Style Gen VI and Beyond" pack provides **back sprites only** (normal + shiny, 2× scale).
  `data/sprite_index.csv` flags each file's colour count and whether it's a clean 2× upscale. Conversion steps:
  downscale 2× (nearest), quantise to ≤15 colours + transparency, then build a **shared** palette with the matching front
  sprite (fronts still needed) and remap the shiny back to the same indices.
- Mega Garchomp Z's owner-supplied front art is 116×95 px and must be redrawn to fit 80×80.

### 8. Testing
- Play-test each badge segment with the encounter tables and boss teams; check that every Renegade species is still
  obtainable (the encounter generator guarantees this for the wild tables).
- Battle tests for each Mega ability, the Mega UI, multi battles with two Mega trainers (Spear Pillar, Fight Area), and
  all E4 format paths (including the one-healthy-Pokémon fallback).
