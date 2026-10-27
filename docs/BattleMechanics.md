# Sovereign Platinum — Battle Mechanics (Pokémon Champions rules)

Owner decision (2026-10-22): battles follow **Pokémon Champions** in everything except the stat system. Sovereign
keeps IVs (0–31) and EVs (max 252 per stat, 510 total), and levels work as in the main games.

This page lists each rule: Gen IV's behaviour (what Platinum did), Champions' behaviour, and where Sovereign stands.
Champions is built on Scarlet/Violet, so where Champions changes nothing the Gen IX rule applies.

**Status column:** ✅ done (in the code) · 🟡 partial · ⏳ later (roadmap item named) · ➖ not adopted (reason given).

**Sources.**
- Pokémon Showdown's Champions mod (`data/mods/champions/`, read 2026-10-22). It is built on the community's datamine
  and research, and is the most precise source.
- Serebii's Champions pages (status conditions, updated attacks and abilities, patch notes).
- Bulbapedia (Pokémon Champions, Freeze, Rest, Critical hit, List of modified moves, Stat point, Trick Room, U-turn,
  Fake Out).
- Smogon's "Champions battle mechanics research" thread, and Victory Road VGC.
- Patches covered: 1.0.0 (8 April 2026) to 1.2.2 (7 October 2026).

The full research notes, with confidence levels and URLs, are in the [research notes](#research-notes) at the end.

## Status conditions

| Rule | Gen IV | Champions | Sovereign |
|---|---|---|---|
| Full paralysis | 1/4 | **1/8** | ✅ `battle_controller_player.c` |
| Paralysis Speed drop | ×0.25 | ×0.5 | ✅ `battle_lib.c` (turn order) |
| Electric types | can be paralysed | immune to paralysis | ✅ `subscript_paralyze.s` |
| Sleep length | 1–4 turns asleep | **1 turn (1/3) or 2 turns (2/3)**; acts on the turn it wakes | ✅ `subscript_fall_asleep.s` |
| Rest | asleep 2 turns | unchanged | ✅ (already the same) |
| Freeze | 1/5 thaw per turn, no limit | **1/4 thaw per move attempt, sure thaw on the 3rd** | ✅ `battle_controller_player.c` (`freezeTurns` in BattleMon) |
| Freeze-Dry | (Gen VI move) | can't freeze | ✅ `apply_champions_moves.py` |
| Burn damage | 1/8 per turn | 1/16 | ✅ `subscript_burn_damage.s` |
| Burn attack drop | Attack halved in the formula | final ×0.5 on physical damage | same result in practice; kept |
| Poison / Toxic | 1/8; n/16 | unchanged | ✅ |
| Confusion self-hit | 50% | 33% | ✅ `battle_controller_player.c` |
| Confusion length | 1–4 turns | 1–4 turns | ✅ (unchanged) |
| Infatuation, flinch | — | unchanged | ✅ |

## Turn order

| Rule | Gen IV | Champions | Sovereign |
|---|---|---|---|
| Dynamic speed | order fixed at the start of the turn | **re-sorted before each action** using current Speed (Gen VIII+) | ✅ `BattleControllerPlayer_BranchActions`. Quick Claw rolls stay fixed for the turn. |
| Priority brackets | Gen IV values | Gen IX values (Protect +4, Fake Out +3, Extreme Speed +2) | ✅ from E3 |
| Speed ties | random | random | ✅ |
| Trick Room | reverses order, 5 turns | same (no "1809 Speed" quirk) | ✅ (Gen IV never had the quirk) |

## Damage

| Rule | Gen IV | Champions | Sovereign |
|---|---|---|---|
| Critical hit multiplier | ×2 (Sniper ×3) | **×1.5** (Sniper ×2.25) | ✅ `BattleSystem_ApplyCriticalMul` |
| Critical hit stages | 1/16, 1/8, 1/4, 1/3, 1/2 | **1/24, 1/8, 1/2, always** | ✅ `sCriticalStageRates` |
| Type chart | Gen IV | Gen VI+ (Fairy; Steel no longer resists Ghost/Dark) | ✅ from E0b |
| STAB, random roll, spread ×0.75, weather ×1.5/×0.5 | — | unchanged | ✅ |
| Multi-hit odds (2–5 hits) | 37.5/37.5/12.5/12.5% | 35/35/15/15% | ✅ `BtlCmd_SetMultiHit` |
| Protect used again in a row | 1/2 the chance each time | 1/3 | ✅ `sProtectSuccessRate` |

## Weather and terrain

| Rule | Gen IV | Champions | Sovereign |
|---|---|---|---|
| Weather from an ability | permanent | **5 turns** (8 with the matching rock); fails if that weather is already up | ✅ the four ability subscripts, `battle_lib.c` |
| Weather from a move | 5 turns (8 with rock) | same | ✅ |
| Hail | 1/16 chip to non-Ice | **replaced by Snow**: no chip damage; Ice types get ×1.5 Defense | ✅ no chip (`battle_script.c`), Defense boost (`battle_lib.c`), messages, Hail/Snowscape set Snow. The weather graphic is still Platinum's hail (no graphics changes). |
| Sandstorm | 1/16 chip; Rock ×1.5 Sp. Def | same | ✅ |
| Terrains | — | Gen VIII+ terrains | ✅ item 11: the four terrains (5 turns, 8 with a Terrain Extender), the Surge abilities, the Seeds, and the moves that use or end a terrain. Only Expanding Force's spread to both foes is still missing. |
| Overworld weather (rain, snow, fog on routes) | permanent | — | kept permanent (it's map weather, not a battle effect) |

## Moves

| Rule | Gen IV / Gen IX | Champions | Sovereign |
|---|---|---|---|
| Fake Out (and First Impression) after the user's first turn | selectable, then fails | **can't be selected** | ✅ Fake Out and First Impression: `CHECK_INVALID_FIRST_TURN` and the message "X can use Fake Out only on its first turn!" (moves batch 9). |
| Power/accuracy changes (23 moves): Anchor Shot, Apple Acid, Grav Apple, Fire Lash, Spirit Shackle, Psyshield Bash 90 · Bolt Beak, Fishious Rend 80 · Bone Rush 30 · Slash 80 · Beak Blast 120 · Dragon Hammer, Revelation Dance 100 · Night Daze 90 · Snipe Shot, Trop Kick 85 · Infernal Parade 65 · Triple Dive 35 · Gear Grind 60/90% · Crabhammer 95% · Syrup Bomb 90% · Meteor Assault 170 · First Impression 100 · Make It Rain 95% | Gen IX values | Champions values | ✅ `tools/engine/apply_champions_moves.py` |
| Secondary effects: Iron Head flinch 20%, Moonblast 10% | 30%, 30% | 20%, 10% | ✅ same script |
| Types: Snap Trap Steel, Growth Grass | Grass, Normal | Steel, Grass | ✅ same script |
| Make It Rain −2 Sp. Atk; Dire Claw 30%; Toxic Thread −2 Speed; Salt Cure 1/16 (1/8 vs Water/Steel); Rage Fist counter resets on switch; Unseen Fist ×0.25 through Protect | — | changed | ✅ moves batch 9 (`gen9_move_fixes.py`; Salt Cure and Unseen Fist in `battle_controller_player.c`, Rage Fist in `BattleSystem_UpdateAfterSwitch`). Unseen Fist, like Piercing Drill, gets through Protect and its kin, Wide Guard, Quick Guard and Mat Block, not Crafty Shield. |
| No Retreat traps its user ('trapped', so a Ghost type escapes; fails while that holds) | the No Retreat volatile traps | plain trap | ✅ moves batch 9 (`gen_stat_moves.py`: Mean Look's trap aimed at the user) |
| Healing Wish, Lunar Dance | Gen IV: the replacement comes in at once and is healed after the entry hazards · Gen IX: it comes in at the end of the turn and is healed before them; the wish waits in the slot for a Pokémon that needs it (Gen VIII+) | unchanged (Lunar Dance isn't in Champions) | ✅ Gen IX (`subscript_hazards_check`, `BTLVAR_SOVEREIGN_HEALING_WISH_SWITCHED_MON`). Lunar Dance also restores PP, and a Pokémon short only of PP takes its wish. |
| Belch and Stuff Cheeks without a Berry eaten / held | can't be selected | **can be selected**, then fail | ✅ moves batch 9. Belch counts Bug Bite, Pluck, Stuff Cheeks and a flung Berry, not Natural Gift, Fling's user or Incinerate; Stuff Cheeks raises Defense 2 stages, then eats the Berry (Klutz, Embargo and Magic Room don't stop it). |
| Explosion, Self-Destruct (and Misty Explosion, which uses their effect) halve the target's Defense | yes (Gen IV) | no (Gen V+) | ✅ moves batch 10 (`battle_lib.c`): their power was already Gen V+'s 250/200, so the halving made them hit as if at 500/400 |
| Slicing/punch/sound flag changes (Crush Claw, Dragon Claw, Metal Claw, Shadow Claw, Dire Claw slicing; Double Shock punching; Howl, Dragon Cheer sound) | — | changed | ✅ item 11 (`battle_lib.c`: `sSlicingMoves` for Sharpness, `sPunchingMoves` for Iron Fist and Punching Glove, `sSoundMoves`). The sound list also gets Gen IX's Heal Bell and Perish Song. Soundproof no longer blocks the user's own sound moves (a Soundproof Kommo-o's Clangorous Soul failed). Heal Bell cures its user even with Soundproof, as in Gen VIII+. |
| Protect & co. at 8 PP, and every move's PP on Champions' fixed scale (5→8, 10→12, 15→16, 20+→20; no PP Ups) | Gen IX PP + PP Ups | fixed PP | ➖ **not adopted** (owner, 2026-10-22): Sovereign keeps main-series PP and PP Ups ("a fun part of the game"). |
| Moves removed from Champions (Pursuit, Return, Frustration, Hidden Power, Teleport, Hail, Snatch, Magic Coat…) | — | not available | ➖ kept in Sovereign: Champions removes them from its roster, not as a battle rule. Hail now summons Snow. |

## Abilities and items

| Rule | Champions | Sovereign |
|---|---|---|
| Healer 50% (was 30%), Run Away ignores trapping, Emergency Exit/Wimp Out and Sheer Force tweaks | changed | ✅ item 11, from Showdown's Champions mod (`data/mods/champions/abilities.ts`, `scripts.ts`). Healer 50%. Run Away flees and also switches out past every trap (Mean Look, Shadow Tag, Bind, Ingrain...: `Battler_IsTrapped`). Emergency Exit and Wimp Out don't cancel another Pokémon's switch (a U-turn user still switches out). Sheer Force doesn't stop the target's after-hit effects: Emergency Exit, Wimp Out, Eject Button, Red Card (Gen IX skips them; Berserk, Anger Shell, Pickpocket and Color Change never were). Emergency Exit and Wimp Out also follow the Gen IX rules: after a hit, the holder's own move, the end-of-turn damage or the entry hazards (`docs/AbilityChecklist.md`). |
| Gen V–IX rules Champions inherits: Prankster fails on Dark types, Intimidate blocked by Inner Focus/Oblivious/Own Tempo/Scrappy, Ghost types escape trapping, Grass types immune to powder moves | Gen IX | ✅ item 11 (a Ghost type can always switch out or flee: `Battler_IsTrapped`, `Battler_IsTrappedMsg`; powder: `Battler_SovereignPowderImmune`) |
| Eject Button after U-turn/Volt Switch: the attacker also switches | changed | ✅ item 11 (`BattleSystem_TriggerHeldItemOnHit`): the U-turn user switches out first, then the Eject Button holder |
| Item pool (no Choice Band/Specs, Assault Vest, etc.) | regulation-dependent | ➖ not adopted: Champions limits items per regulation; Sovereign is an RPG with Platinum's + Renegade's items |
| Mega Evolution only (no Tera, Z-Moves, Dynamax) | yes | ✅ matches the owner's decision (E8 adds Megas) |

## Stat system (not adopted)

Champions has no IVs (every stat acts as IV 31), and replaces EVs with **Stat Points**: 66 in total, at most 32 per
stat, so 32 SP = 252 EVs. Levels are fixed at 50. **Sovereign keeps IVs, EVs (252/510) and normal levels** (owner,
2026-10-22).

## Not verifiable yet

These rules come only from Showdown's implementation, so their in-game behaviour is unconfirmed:
- dynamic speed;
- Mega Evolution turn order;
- weather rock durations;
- Salt Cure damage;
- that burn, poison, confusion, infatuation and flinch are unchanged.

Sovereign follows Showdown's behaviour. Same-turn Mega Evolution order is decided in E8.

## Research notes

Compiled 2026-10-22. Web pages could not be opened directly from the build environment, so Bulbapedia, Serebii,
Smogon and news pages were read through search extracts. Pokémon Showdown's code (HEAD `8476966`) was read directly:
`data/mods/champions/{conditions,moves,items,abilities,scripts,rulesets}.ts`, plus `sim/battle.ts` and
`sim/battle-actions.ts`.

Key URLs:
- <https://github.com/smogon/pokemon-showdown/tree/master/data/mods/champions>
- <https://www.smogon.com/forums/threads/champions-battle-mechanics-research.3780372/>
- <https://www.serebii.net/pokemonchampions/statusconditions.shtml>
- <https://www.serebii.net/pokemonchampions/updatedattacks.shtml>
- <https://www.serebii.net/pokemonchampions/updatedabilities.shtml>
- <https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_Champions>
- <https://bulbapedia.bulbagarden.net/wiki/List_of_modified_moves>
- <https://bulbapedia.bulbagarden.net/wiki/Stat_point>
- <https://x.com/VGCVictoryRoad/status/2041748007121514762>

**Why some sources say sleep lasts "2 turns" and others "3 turns".** Both describe the same rule. "Max 2" counts the
turns the Pokémon can't act. "Max 3" counts up to the turn it is sure to wake. Showdown's counter is
`sample([2, 3, 3])`, matching Sovereign's 2-or-3 counter.
