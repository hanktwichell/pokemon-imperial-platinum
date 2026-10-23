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
- **HP-bar symbol.** `HealthBox_SovereignDrawMegaIcon` (`healthbox.c`) draws part `HEALTHBOX_PART_SOVEREIGN_MEGA` in
  the caught-icon slot (`sCaughtIconVRAMTransfer`), over the tile it saves first. It's called whenever the name is
  drawn. The battle-script command `SovereignRefreshHealthBox` (after `End` in `btlcmd.h`) sends
  `BattleController_EmitRefreshHPGauge`.

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
    storage. Pal Park and migration are removed (decision 22), and Pal Park needs all six slots filled to open. The
    main menu's Migrate option is gone, so nothing else writes there.
  - The form's moves are a table in `sovereign_form_items.c`.
  - `BoxAppMan_CheckReleaseMonValid` (`pc_boxes/box_app_manager.c`) refuses to release a fused Pokémon.

### 5. Trainer data
- Vanilla Gen IV trainer Pokémon can't specify EVs, natures directly (nature comes from the PID seeded by trainer
  data), or abilities. **The EV spreads and natures in `TrainerPokemon_Sovereign.md` need an extended trainer-Pokémon
  format** (as hg-engine does for HGSS: per-mon nature, ability, IVs, EVs, ball, shiny).
- New trainer IDs: 19 for the League (see `EliteFourFormat.md`) plus edited story bosses.

### 6. Scripts and maps
- Elite Four format prompts (`EliteFourFormat.md`), the Mega Ring gift after Fantina, four Mega Stone vendors, five new
  starter Interviewers, the Legend Archivist and ~35 post-game events, some of them in new rooms/maps (Sendoff Spring
  crater, Spear Pillar rifts, Oreburgh Mine B3F, …).
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
