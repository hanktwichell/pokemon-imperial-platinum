# Platinum's moves under Gen IV rules: audit

Battles follow Pokémon Champions, and Gen IX where Champions changes nothing (`docs/BattleMechanics.md`). Platinum's own
moves (#1–467) kept their Gen IV battle effects (`docs/MoveChecklist.md`). This audit (2026-10-27) takes every Platinum
move whose rule changed after Gen IV, from Showdown's per-generation move overrides (`data/mods/gen4`…`gen8/moves.ts`),
and compares three things: the Gen IV rule, the Gen IX rule (Showdown's `data/moves.ts`, with Champions'
`data/mods/champions` on top), and what Sovereign does now, checked against the code, not its comments. Pure Gen VIII+
flags (Dynamax, Instruct, Assist bans) are skipped.

Line numbers are from commit 672e9825 and drift as the code changes; each also names its function or script. As move
batches fix these, mark them ✅ here.

- **Part 1** (moves #1–203): 61 moves with a later rule. 27 already follow Gen IX, 27 still follow Gen IV, 6 are partly
  updated, 1 is unsure.
- **Part 2** (moves #204–467): 94 moves. 30 already follow Gen IX, 57 still follow Gen IV, 6 are partly updated, 1 is
  unsure.

## Part 1: moves #1–203

Paths in this part are relative to the repo root.

Classes: **GEN_IX_ALREADY** (Sovereign already follows Gen IX/Champions, or Gen IV and Gen IX don't differ in a way
this engine models) · **GEN_IV** (still Gen IV, needs a change) · **PARTIAL** (part done) · **UNSURE**.

| # | Move | Gen IV | Gen IX / Champions | Sovereign now (with file:line) | Class |
|---|---|---|---|---|---|
| 6 | Pay Day | Scatters 5×level money on hit (the gen4 override only adds a "coins scattered" message) | Same money rule | `INCREASE_PRIZE_MONEY`, `decomp/res/battle/scripts/effects/effect_script_0034.s:5`. Same rule. | GEN_IX_ALREADY |
| 18 | Whirlwind | Protect blocks it; Magic Coat doesn't reflect it; 100% acc; level check (random fail if user's level < target's) in **trainer and wild** battles | Goes through Protect (Gen VI+); Magic Coat/Magic Bounce reflect it (Gen V+); never misses; wind move; in trainer battles no level check, in wild battles it fails if the user's level is lower (Bulbapedia; Showdown doesn't model levels) | Never misses (acc 0) and wind move (`sWindMoves`, `battle_lib.c:4125`) are done. Still `MOVE_FLAG_CAN_PROTECT` and no `CAN_MAGIC_COAT` (`decomp/res/moves/whirlwind/data.json:21-22`). Gen IV level roll `BattleSystem_CanWhirlwind` (`decomp/src/battle/battle_lib.c:3583`) is still called in trainer battles (`decomp/src/battle/battle_script.c:5627`) and wild ones (`:5646`) | PARTIAL |
| 19 | Fly | Semi-invulnerable; hit by Gust/Twister (×2), Sky Uppercut, Thunder | Same, plus the later moves (Hurricane, Smack Down, Thousand Arrows) | `SYSCTL_HIT_DURING_FLY` set by those moves' effects (`effect_script_0146/0149/0152/0207/0277/0302.s`); semi-invulnerable check `battle_controller_player.c` ~3658 | GEN_IX_ALREADY |
| 26 | Jump Kick | On a miss/Protect/immunity: crash for **½ the damage it would have dealt**, capped at ½ the **target's** max HP | Crash for **½ the user's max HP** | Gen IV formula: `decomp/res/battle/scripts/subscripts/subscript_crash_on_miss.s:11-17` (`BTLVAR_DAMAGE`/2, capped by `BTLSCR_DEFENDER` max HP/2). Supercell Slam (`CRASH_ON_MISS`) and Axe Kick (`effect_script_0346.s`) share it | GEN_IV |
| 34 | Body Slam | Plain hit; no Minimize interaction | `minimize` flag (Gen VI+): ×2 damage and never misses against a Minimized target | Only `FLINCH_MINIMIZE_DOUBLE_HIT` (Stomp, Steamroller) doubles (`effect_script_0150.s:7-8`), and nothing gives sure-hit. Body Slam is `PARALYZE_HIT` (`decomp/res/moves/body_slam/data.json`) | GEN_IV |
| 38 | Double-Edge | Recoil ⌊damage/3⌋ | Recoil 33/100 of damage (rounded) | `subscript_recoil_1_3.s:10` (÷3). At most 1 HP different | GEN_IX_ALREADY |
| 45 | Growl | Blocked by Substitute | Sound move, goes through Substitute (Gen VI+) | `sSoundMoves` (`decomp/src/battle/battle_lib.c:4075`) + `Sovereign_BypassesSubstitute` (`:4157`), used in the stat-drop check (`battle_script.c:3151`) | GEN_IX_ALREADY |
| 46 | Roar | As Whirlwind (sound move; already went through Substitute) | As Whirlwind | Never misses (acc 0) is done. Still `CAN_PROTECT`, no `CAN_MAGIC_COAT` (`decomp/res/moves/roar/data.json:21-22`), same Gen IV level roll as Whirlwind | PARTIAL |
| 47 | Sing | Blocked by Substitute | Sound, goes through Substitute | Sound list + `CheckSubstitute` bypass (`battle_script.c:9739`; `subscript_fall_asleep.s`) | GEN_IX_ALREADY |
| 48 | Supersonic | Blocked by Substitute | Sound, goes through Substitute | Same (`subscript_confuse.s` → `CheckSubstitute`) | GEN_IX_ALREADY |
| 50 | Disable | Lasts **4–7 turns** (random); not reflectable; 80% acc | Lasts **4 turns**; Magic Coat/Bounce reflect it; 100% acc. (Champions only adds a `cantusetwice` nuance for Gigaton Hammer/Blood Moon) | `disabledTurns = rand % 4 + 3` (`decomp/src/battle/battle_script.c:4914`, "range: [3-6]"); no `CAN_MAGIC_COAT` (`decomp/res/moves/disable/data.json:21`). Acc 100 done. (Cursed Body already sets 4, `battle_lib.c` ~6686) | GEN_IV |
| 54 | Mist | 5 turns, blocks foes' stat drops (only end-of-turn order differs) | Same | Platinum's Mist, `effect_script_0046`; Infiltrator handled | GEN_IX_ALREADY |
| 59 | Blizzard | Never misses in hail | Never misses in hail/snow | `WEATHER_IS_HAIL` check (`decomp/src/battle/battle_controller_player.c:3647`); Sovereign's hail is Snow | GEN_IX_ALREADY |
| 67 | Low Kick | Weight-based power | Same (the override is only a Dynamax check) | `INCREASE_POWER_WITH_WEIGHT` | GEN_IX_ALREADY |
| 71 | Absorb | Under Heal Block it can be used, and deals damage but restores nothing | `heal` flag (Gen VI+): **can't be selected or used** under Heal Block (or Psychic Noise) | Heal Block list has only the pure healing moves (`sMovesAffectedByHealBlock`, `decomp/src/battle/battle_lib.c:4012`); the drain just shows "prevented from healing" (`subscript_drain_half_damage_dealt.s:28`) | GEN_IV |
| 72 | Mega Drain | As Absorb | As Absorb | As Absorb | GEN_IV |
| 73 | Leech Seed | 1/8 per turn (only end-of-turn order differs) | Same | Platinum's Leech Seed | GEN_IX_ALREADY |
| 74 | Growth | +1 Sp. Atk | +1 Atk and +1 Sp. Atk, +2 each in sun; Champions: Grass type | `SOVEREIGN_GROWTH` (`effect_script_0396.s`, `subscript_sovereign_stats_growth.s`); `TYPE_GRASS` | GEN_IX_ALREADY |
| 77 | Poison Powder | Hits Grass types | Powder: Grass types, Overcoat, Safety Goggles immune | `sPowderMoves` (`battle_lib.c:9798`), check at `battle_controller_player.c:3676` | GEN_IX_ALREADY |
| 78 | Stun Spore | As Poison Powder | As Poison Powder | Same | GEN_IX_ALREADY |
| 79 | Sleep Powder | As Poison Powder | As Poison Powder | Same | GEN_IX_ALREADY |
| 81 | String Shot | Target Speed **−1** | Target Speed **−2** (Gen VI+) | `BATTLE_EFFECT_SPEED_DOWN` (`decomp/res/moves/string_shot/data.json:16`) → `SPEED_DOWN_1_STAGE` (`effect_script_0020.s:5`) | GEN_IV |
| 91 | Dig | Semi-invulnerable; Earthquake/Magnitude ×2 | Same (only Sleep Talk/Assist flags differ) | `SYSCTL_HIT_DURING_DIG` | GEN_IX_ALREADY |
| 92 | Toxic | 85% acc, can miss for anyone | 90% acc; **a Poison-type user can't miss** (also hits Fly/Dig users, Gen VI+) | Acc 90 done. No Poison-type rule: the sure-hit overrides (`BattleControllerPlayer_CheckMoveHitOverrides`, `decomp/src/battle/battle_controller_player.c:3626-3634`) only know Lock-On, No Guard, Telekinesis, Glaive Rush. No code mentions `MOVE_TOXIC` | GEN_IV |
| 100 | Teleport | Flees a wild battle; **fails in trainer battles** | Priority −6; the user **switches out** (fails with nothing to switch to); a wild Pokémon flees (Gen VIII+) | Priority −6 done; effect still `FLEE_FROM_WILD_BATTLE`, fails when `BATTLE_TYPE_TRAINER` (`decomp/res/battle/scripts/effects/effect_script_0153.s:5`) | GEN_IV |
| 102 | Mimic | Fails against a Substitute; copied move gets **5 PP**; can't copy Metronome, Struggle, Sketch, Mimic, Chatter | Goes through Substitute; copied move gets **its full PP**; also can't copy Transform, Mirror Move, Sleep Talk, Assist, Copycat, Me First, Nature Power… | `BtlCmd_TryMimic`: Substitute check (`decomp/src/battle/battle_script.c:4803`), PP capped at 5 (`:4829`); Gen IV list `sCannotMetronomeMoves` (`battle_lib.c:11475`) | GEN_IV |
| 103 | Screech | Blocked by Substitute | Sound, goes through Substitute | Sound list (`battle_lib.c:4075`) | GEN_IX_ALREADY |
| 107 | Minimize | Evasion **+1**; Stomp ×2 vs a Minimized target, but it can still miss | Evasion **+2** (Gen V+); every `minimize`-flag move (Body Slam, Stomp, Steamroller, Dragon Rush, Heat Crash, Heavy Slam, Flying Press, Malicious Moonsault, Supercell Slam) does ×2 **and never misses** (Gen VI+) | `MOVE_SUBSCRIPT_PTR_EVASION_UP_1_STAGE` (`decomp/res/battle/scripts/subscripts/subscript_minimize.s:6`); only Stomp/Steamroller double (`effect_script_0150.s:7-8`), and nothing gives sure-hit | GEN_IV |
| 113 | Light Screen | ×½; ×2/3 in doubles **only while both Pokémon on the target's side are alive**; applied in the base formula | ×½; ×2732/4096 in any double battle; a final modifier | Gen IV form, `decomp/src/battle/battle_lib.c:11310-11318` (`CountAliveBattlers(...) == 2`, `*2/3`). Duration 5/8 and Infiltrator are fine. Differs only in that edge case and in rounding | PARTIAL (negligible) |
| 114 | Haze | Resets every stat stage **and removes Focus Energy** | Resets stat stages only | `BtlCmd_ResetAllStatChanges` clears `VOLATILE_CONDITION_FOCUS_ENERGY` (`decomp/src/battle/battle_script.c:3788`) | GEN_IV |
| 115 | Reflect | As Light Screen (physical) | As Light Screen | `battle_lib.c:11268-11276` | PARTIAL (negligible) |
| 117 | Bide | Ends if the user falls asleep or is frozen | Ends when the user's move is cancelled (`onMoveAborted`) | Any cancelled move clears Bide (`Battler_UnlockMoveChoice`, `battle_lib.c:1927-1930`). Same in practice | GEN_IX_ALREADY |
| 118 | Metronome | Never calls a move the user knows; can't call a move Gravity or Heal Block would stop; 25-move ban list | **Can** call moves the user knows; no Gravity/Heal Block filter; bans every move without the `metronome` flag. Among Platinum's moves that adds Transform, Snore, Nature Power, plus about 120 Gen V–IX moves (Wide Guard, Quick Guard, King's Shield, Spiky Shield, Baneful Bunker, Obstruct, Silk Trap, Mat Block, Crafty Shield, Rage Powder, Spotlight, Instruct, Shell Trap, Beak Blast, Belch, Celebrate, Hold Hands, most signature moves…) | `BtlCmd_Metronome` skips known moves (`decomp/src/battle/battle_script.c:4855-4870`); `Move_CanBeMetronomed` uses the Gravity/Heal Block filter and the Gen IV list (`decomp/src/battle/battle_lib.c:11475-11535`) | GEN_IV |
| 119 | Mirror Move | Copies the last move that **targeted the user** (random one in doubles); target "self"; Gen IV ban list | Copies the **chosen target's last move** if it has the `mirror` flag (Gen V+); target "normal" | `BtlCmd_SetMirrorMove` uses `moveCopied`/`moveCopiedHit` filled when the user is hit (`decomp/src/battle/battle_script.c:3727-3760`, `battle_controller_player.c` ~5943); range `RANGE_SINGLE_TARGET_SPECIAL` | GEN_IV |
| 136 | Hi Jump Kick | As Jump Kick | As Jump Kick | Same subscript (`subscript_crash_on_miss.s:11-17`) | GEN_IV |
| 138 | Dream Eater | **Fails against a Substitute**; usable under Heal Block | Hits the Substitute (drains from it); `heal` flag, so Heal Block stops it; Comatose counts as asleep | Comatose done; `CheckSubstitute BTLSCR_DEFENDER` → "wasn't affected" (`decomp/res/battle/scripts/effects/effect_script_0008.s:5`); not in the Heal Block list | PARTIAL |
| 139 | Poison Gas | 55%, one target | 90%, both foes | `RANGE_ADJACENT_OPPONENTS`, acc 90 | GEN_IX_ALREADY |
| 141 | Leech Life | As Absorb (Heal Block) | As Absorb | As Absorb (power 80 done) | GEN_IV |
| 144 | Transform | Works through a Substitute; a transformed user can Transform again | **Fails** against a Substitute, if the user is already transformed, or with Illusion (Gen V+; Showdown's `transformInto`) | `subscript_transform_into_target.s:5-6` checks only the target's semi-invulnerability and Transform | GEN_IV |
| 147 | Spore | As Poison Powder | As Poison Powder | Same | GEN_IX_ALREADY |
| 160 | Conversion | Type of a **random** move the user knows (not Conversion, not its current type) | Type of the move in its **first slot**; fails if the user already has that type; Snatch can steal it | Random pick, `BtlCmd_TryConversion` (`decomp/src/battle/battle_script.c:4289-4340`); no `CAN_SNATCH` (`decomp/res/moves/conversion/data.json:20`) | GEN_IV |
| 164 | Substitute | Sound moves don't get through | Sound moves and Infiltrator get through (Gen VI+) | `Sovereign_BypassesSubstitute` at damage (`battle_controller_player.c:4339`), `CheckSubstitute` (`battle_script.c:9739`), stat drops (`:3151`) | GEN_IX_ALREADY |
| 165 | Struggle | Typeless, recoil ¼ max HP | Same | `subscript_struggle.s` (¼ max HP) | GEN_IX_ALREADY |
| 166 | Sketch | Fails against a Substitute; can't sketch Struggle, Sketch, Chatter | Goes through Substitute; can't sketch Struggle, Sketch, Dark Void, Hyperspace Fury, Revival Blessing, the Torques, Tera Starstorm | `CheckSubstitute` (`decomp/res/battle/scripts/subscripts/subscript_sketch.s:5`); Gen IV list `BtlCmd_TrySketch` (`battle_script.c:5167-5171`) | GEN_IV |
| 171 | Nightmare | ¼ per turn while asleep (only end-of-turn order differs) | Same (+Comatose) | Platinum's | GEN_IX_ALREADY |
| 173 | Snore | Blocked by Substitute | Sound, goes through Substitute | Sound list; power 50 done | GEN_IX_ALREADY |
| 174 | Curse | Type ???; a Ghost's Curse **fails against a Substitute** | Ghost type; a Ghost's Curse **goes through Substitute**; it targets a random foe when aimed at itself or an ally (Champions: same) | Ghost type done. `CheckSubstitute BTLSCR_DEFENDER` (`decomp/res/battle/scripts/subscripts/subscript_curse_ghost.s:6`). The effect checks only type 1/2 (`effect_script_0109.s:5-6`), but Protect's `Move_IsGhostCurse` (`battle_lib.c:3552`) also counts an added third type | PARTIAL |
| 175 | Flail | Power from ⌊64·HP/max⌋: ≤1→200, ≤5→150, ≤12→100, ≤21→80, ≤42→40, else 20 | ⌊48·HP/max⌋: ≤1→200, ≤4→150, ≤9→100, ≤16→80, ≤32→40, else 20 | `sHPPixelsToFlailPower` 64-pixel table (`decomp/src/battle/battle_script.c:5261-5268`, `:5282`) | GEN_IV |
| 176 | Conversion 2 | Resists the type of the last move that **hit the user** | Resists the type of the **target's last used move** (target "normal", goes through Substitute) | `BtlCmd_TryConversion2` uses `conversion2Move/Type` (`decomp/src/battle/battle_script.c:5085-5140`); range `RANGE_USER`. It also doesn't clear `sovereignAddedType`, though Conversion does | GEN_IV |
| 178 | Cotton Spore | One target, 85% | Both foes, 100%, powder | `RANGE_ADJACENT_OPPONENTS`, acc 100, `sPowderMoves` | GEN_IX_ALREADY |
| 179 | Reversal | As Flail | As Flail | Same table | GEN_IV |
| 180 | Spite | −4 PP, not reflectable | −4 PP, Magic Coat/Bounce reflect it (Gen V+) | −4 done (`battle_script.c:5310`); no `CAN_MAGIC_COAT` (`decomp/res/moves/spite/data.json:21`) | GEN_IV |
| 182 | Protect | +3 priority; ½ chance each use in a row | +4; ⅓ each use (Champions: 5 PP, not adopted by the owner) | Priority 4 (data); `sProtectSuccessRate` ⅓ (`battle_script.c:5448`); shared chain | GEN_IX_ALREADY |
| 191 | Spikes | Not reflectable | Magic Coat/Bounce reflect it (Gen V+); Heavy-Duty Boots | Boots done (`battle_script.c` ~5809); `"flags": []` (`decomp/res/moves/spikes/data.json:21`). Sticky Web already has `CAN_MAGIC_COAT` | GEN_IV |
| 193 | Foresight | Not reflectable | Magic Coat/Bounce reflect it | No `CAN_MAGIC_COAT` (`decomp/res/moves/foresight/data.json:21`) | GEN_IV |
| 194 | Destiny Bond | Can be used every turn | **Fails if used again right after a successful use** (Gen VII+) | The flag is cleared at the start of every move, Destiny Bond too (`decomp/src/battle/battle_controller_player.c:2804`), and `subscript_destiny_bond.s` sets it again with no check | GEN_IV |
| 195 | Perish Song | 3 turns, Soundproof immune | Same, sound move | Sound list (Gen IX's addition, `battle_lib.c:4075`) | GEN_IX_ALREADY |
| 197 | Detect | +3 | +4 | Priority 4 (data), shares Protect's code | GEN_IX_ALREADY |
| 199 | Lock-On | Baton Pass passes it | Baton Pass doesn't (`noCopy`); fails if the user already has a Lock-On up | `MOVE_EFFECT_LOCK_ON` in `MOVE_EFFECT_BATON_PASSED` (`decomp/include/constants/battle/moves.h:46`). Mind Reader shares it | GEN_IV |
| 202 | Giga Drain | As Absorb (Heal Block) | As Absorb | As Absorb (power 75 done) | GEN_IV |
| 203 | Endure | +3; doesn't hold against Future Sight/Doom Desire | +4; holds against any move damage while it's up (Showdown's gen 5+ Endure has no `futuremove` exception) | Priority 4 done. The Future Sight damage path `BtlCmd_CheckHoldOnWith1HP` (`decomp/src/battle/battle_script.c:9608-9636`) checks Focus Sash/Band and Sturdy, not `turnFlags.enduring`. Whether it matters in-game depends on end-of-turn order | UNSURE |

**Counts:** GEN_IX_ALREADY 27 · GEN_IV 27 · PARTIAL 6 · UNSURE 1 (61 moves).

### GEN_IV / PARTIAL moves, most to least visible to a player

1. ✅ *Done in moves batch A (CB-0210).* **String Shot (#81).** Early-game Bugs and trainers use it a lot. Set `string_shot/data.json` effect to
   `BATTLE_EFFECT_SPEED_DOWN_2` (Cotton Spore's and Scary Face's).
2. ✅ *Done in moves batch A (CB-0210).* **Hi Jump Kick / Jump Kick (#136, #26).** Every miss shows it (Buneary/Lopunny, Hitmonlee, Medicham). In
   `subscript_crash_on_miss.s`, set the crash to the **attacker's** max HP / 2 (`UpdateMonDataFromVar OPCODE_GET,
   BTLSCR_ATTACKER, BATTLEMON_MAX_HP` → ÷2 → negate) in place of damage/2 capped by the defender. This also fixes
   Supercell Slam and Axe Kick. The `MoveChecklist.md` row for Supercell Slam ("half its max HP") is wrong today.
3. ✅ *Done in moves batch B (CB-0211): a trainer's Pokémon, or the player's in any battle, switches out; a wild one flees.* **Teleport (#100).** Abra's only move; a trainer's Abra gets "But it failed!". Give it a new effect: switch the
   user out, as Parting Shot does but with no stat drop (`SOVEREIGN_PARTING_SHOT`, effect 328), and fail when there's
   no Pokémon to switch in. A wild Pokémon keeps fleeing (`effect_script_0153.s`).
4. ✅ *Done in moves batch A (CB-0210).* **Minimize (#107).** `subscript_minimize.s:6` → `MOVE_SUBSCRIPT_PTR_EVASION_UP_2_STAGES`.
5. **Body Slam (#34) and the other `minimize` moves.** Add a `sMinimizeMoves` list (Body Slam, Stomp, Steamroller,
   Dragon Rush, Heat Crash, Heavy Slam, Flying Press, Malicious Moonsault, Supercell Slam). Use it in
   `BattleControllerPlayer_CheckMoveHitOverrides` for a sure hit when the target has `MOVE_EFFECT_MINIMIZE`, and in
   the damage code for ×2. Then remove the ×2 from `effect_script_0150.s`, or Stomp doubles twice.
6. ✅ *Done in moves batch A (CB-0210).* **Toxic (#92).** In `BattleControllerPlayer_CheckMoveHitOverrides` (`battle_controller_player.c` ~3626), add
   `move == MOVE_TOXIC && MON_HAS_TYPE(attacker, TYPE_POISON)` to the sure-hit list. Put it before the
   semi-invulnerable check so it also hits Fly/Dig users, as Lock-On does.
7. **Whirlwind / Roar (#18, #46).** Remove `MOVE_FLAG_CAN_PROTECT` and add `MOVE_FLAG_CAN_MAGIC_COAT` in both
   `data.json`. In `BtlCmd_TryWhirlwind`, drop the `BattleSystem_CanWhirlwind` roll in trainer battles, and for wild
   battles make it a plain `attacker level < defender level` → fail.
8. ✅ *Length done in moves batch B (CB-0211); not reflectable yet (14 below).* **Disable (#50).** In `BtlCmd_TryDisable` set a fixed length: `disabledTurns = 4` if the target has already acted
   this turn, else 3. That gives 4 blocked turns with Platinum's countdown; Cursed Body already uses 4. Add
   `CAN_MAGIC_COAT`.
9. ✅ *Done in moves batch B (CB-0211).* **Destiny Bond (#194).** At `CHECK_STATUS_START` (`battle_controller_player.c:2804`), if `moveCur ==
   MOVE_DESTINY_BOND` and the flag is still set, record it (for example, a `sovereignDestinyBondRepeat` bit) before
   clearing. Then make `effect_script_0098.s` fail with "But it failed!".
10. **Metronome (#118).** Remove the "already known" loop in `BtlCmd_Metronome` and the Gravity/Heal Block filter.
    Grow `sCannotMetronomeMoves` to every move Gen IX doesn't flag `metronome` (the list is in this audit's script
    output: Transform, Snore, Nature Power and the Gen V–IX ones). Keep the Mimic part of the list separate (see 18).
11. **Mirror Move (#119).** Rewrite `BtlCmd_SetMirrorMove` to take the chosen target's last move
    (`movePrevByBattler[defender]`) when it has `MOVE_FLAG_CAN_MIRROR_MOVE`, and change its range to
    `RANGE_SINGLE_TARGET`.
12. **Absorb, Mega Drain, Giga Drain, Leech Life (#71, #72, #202, #141), and Dream Eater's Heal Block half.** Make
    `Move_HealBlocked` use the `heal` list `sHealingMoves` (`battle_lib.c:9824`, already used for Triage) in place of
    `sMovesAffectedByHealBlock`. Then Heal Block and Psychic Noise block the drain moves, as in Gen VI+.
13. **Dream Eater (#138).** Remove `CheckSubstitute` from `effect_script_0008.s` so the hit goes to the substitute
    (it drains from it). Heal Block: see 12.
14. **Curse (#174).** Remove `CheckSubstitute` from `subscript_curse_ghost.s` (Ghost Curse has `bypasssub`). Make
    `effect_script_0109.s` test Ghost with the third type too, as `Move_IsGhostCurse` does.
15. **Flail / Reversal (#175, #179).** Use `curHP*48/maxHP` (min 1) and thresholds {1,200},{4,150},{9,100},
    {16,80},{32,40},{48,20} in `BtlCmd_CalcFlailPower`.
16. **Haze (#114).** Delete the Focus Energy line in `BtlCmd_ResetAllStatChanges` (`battle_script.c:3788`).
17. **Spikes, Spite, Foresight (#191, #180, #193).** Add `MOVE_FLAG_CAN_MAGIC_COAT`, as Sticky Web has. Stealth Rock
    and Toxic Spikes (outside this range) lack it too.
18. **Mimic (#102).** In `BtlCmd_TryMimic`, drop the Substitute check and give the copied move `MOVE_DATA(move).pp`.
    Add Transform, Mirror Move, Sleep Talk, Assist, Copycat, Me First and Nature Power (and the Gen V+ `failmimic`
    moves) to the moves Mimic can't copy.
19. **Transform (#144).** In `subscript_transform_into_target.s`, fail when the defender has a substitute
    (`CheckSubstitute`), when the attacker is already transformed, or when either has an active Illusion.
20. **Conversion (#160).** Rewrite `BtlCmd_TryConversion`: type = `MOVE_DATA(moves[0]).type`; fail if
    `MON_HAS_TYPE`. Add `CAN_SNATCH`.
21. **Conversion 2 (#176).** Use the target's last used move (`DEFENDER_LAST_MOVE`) and range `RANGE_SINGLE_TARGET`.
    Clear `sovereignAddedType` as Conversion does.
22. **Sketch (#166).** Remove `CheckSubstitute` from `subscript_sketch.s`. Swap the Gen IV ban list
    (Struggle/Sketch/Chatter) for Gen IX's.
23. **Lock-On / Mind Reader (#199).** Remove `MOVE_EFFECT_LOCK_ON` from `MOVE_EFFECT_BATON_PASSED` (`moves.h:46`).
24. **Reflect / Light Screen (#115, #113)** (negligible). Use `battleType & BATTLE_TYPE_DOUBLES` alone, with ×2732/4096
    in place of the "both alive" ×2/3.
25. **Endure (#203)** (UNSURE). Let `BtlCmd_CheckHoldOnWith1HP` also honour `turnFlags[battler].enduring`, so Endure
    holds against Future Sight/Doom Desire as in Showdown's gen 5+.

### Outside the prepared list (moves 1–203)

- **Bind, Wrap, Fire Spin, Clamp (#20, #35, #83, #128).** These are missing from Showdown's move overrides because
  Showdown keeps their rules in `conditions.ts`. They were Gen IV (2–5 turns, 1/16 per turn, Grip Claw 5). ✅ Done in
  the held-items PR (CB-0209): 4–5 turns, 1/8 (Binding Band 1/6), Grip Claw 7.
- **Counter (#68)** has no `MOVE_FLAG_CAN_PROTECT`, while Gen IX flags it `protect`. That's vanilla Platinum data;
  whether Gen IV differed here is UNSURE.

## Part 2: moves #204–467

Paths in this part are relative to `decomp/`.

Abbreviations: **bs** = `src/battle/battle_script.c`, **bl** = `src/battle/battle_lib.c`, **bcp** = `src/battle/battle_controller_player.c`,
**eff NNNN** = `res/battle/scripts/effects/effect_script_NNNN.s`, **sub X** = `res/battle/scripts/subscripts/subscript_X.s`,
**data** = `res/moves/<move>/data.json`. "Reflectable" means the move has the Magic Coat flag (`MOVE_FLAG_CAN_MAGIC_COAT`). In
Sovereign, Magic Coat and Magic Bounce both use this flag (bcp:~3847, bcp:~3871).

**Counts:** GEN_IX_ALREADY 30 · PARTIAL 6 · GEN_IV 57 (9 of them, marked *negligible*, change only a few HP or other bookkeeping; 4 more differ only in the Snatch flag) · UNSURE 1.

| # | Move | Gen IV | Gen IX / Champions | Sovereign now (file:line) | Class |
|---|---|---|---|---|---|
| 210 | Fury Cutter | Power doubles on each consecutive hit up to ×16 (10→160) | Doubles up to ×4 only: 40→80→160 (cap 160). Champions: Past | bs:6082 `BtlCmd_CalcFuryCutterPower` counts to 5, giving 40→80→160→**320→640** | GEN_IV |
| 212 | Mean Look | Blocked by Protect | Not blocked by Protect (Gen VI+); still reflectable | data has `CAN_PROTECT`; Protect checks it at bcp:3601–3608 | GEN_IV |
| 214 | Sleep Talk | Fails if the user is Choice-locked or Encored | Calls a random move even when Choice-locked or Encored. Never calls: charge moves, Bide, Uproar, Focus Punch, Chatter, Belch, Beak Blast, Shell Trap, Mimic, Sketch, Nature Power, Sky Drop, the move-calling moves | bs:5247 `CheckInvalidMoves(~NO_PP)` applies the Choice lock; bl:2452 always applies Encore, so every slot is invalid and the move fails. Belch, Beak Blast, Shell Trap, Mimic, Sketch and Nature Power are not excluded | GEN_IV |
| 215 | Heal Bell | Partner or bench Pokémon with Soundproof stay uncured; the user too | Cures the user always; skips other Pokémon with Soundproof or Good as Gold; sound move | bs:~5359–5380 (Sovereign comment); party: `battle_io_command.c:653`; in `sSoundMoves` bl:4106 | GEN_IX_ALREADY (confirmed) |
| 219 | Safeguard | 5 turns; only the end-of-turn order differs | Same; Infiltrator gets through | subscripts check `SIDE_CONDITION_SAFEGUARD`; Infiltrator: bl:4361 `Sovereign_Infiltrates` | GEN_IX_ALREADY |
| 227 | Encore | Lasts 4–8 turns; not reflectable; Gen IV list of moves that can't be encored | Lasts 3 turns (counted as 4 if the target already moved this turn); reflectable. Also can't encore Sleep Talk, Assist, Copycat, Me First, Metronome, Nature Power, Instruct, Shell Trap. Champions: the target's choice this turn becomes the encored move | bs:5062 `% 5 + 3` (= 4–8 turns); data has no reflect flag; bl:11540 `sCannotEncoreMoves` is Gen IV's list. Using the encored move this turn: bcp:2225 (fine) | GEN_IV |
| 228 | Pursuit | An asleep, frozen or loafing (Truant) user doesn't react to a switch | (Gen VII) It reacts, then fails because it's asleep | bs:7330 skips asleep/frozen/Truant users | GEN_IV (negligible) |
| 229 | Rapid Spin | Clears hazards, Leech Seed and binding; no Speed boost | Same, plus Sticky Web, and user Speed +1 (100%) | sub rapid_spin:6–11 (Sovereign: Speed +1); bs:6280 also removes Sticky Web | GEN_IX_ALREADY |
| 230 | Sweet Scent | Evasion −1 | Evasion −2 (Gen VI+) | eff 0024 `EVASION_DOWN_1_STAGE` | GEN_IV |
| 234 | Morning Sun | Heals 1/2; 2/3 in sun; 1/4 in other weather | Same, with Snow counted as other weather and Utility Umbrella ignored | bs:6361 `Sovereign_MoveWeather` (umbrella); Hail stands for Snow. Platinum's fog also gives 1/4 (no Gen IX equivalent) | GEN_IX_ALREADY |
| 235 | Synthesis | as Morning Sun | as Morning Sun | same code (bs:6355) | GEN_IX_ALREADY |
| 236 | Moonlight | as Morning Sun | as Morning Sun | same code (bs:6355) | GEN_IX_ALREADY |
| 237 | Hidden Power | Power 30–70 from the IVs | Power fixed at 60 (Gen VI+); type still from the IVs | bs:6429 `movePower * 40 / 63 + 30` | GEN_IV |
| 243 | Mirror Coat | — | Only Gen VIII's Copycat flag differs | Copycat already refuses it (`sCannotMetronomeMoves` bl:11475) | GEN_IX_ALREADY |
| 244 | Psych Up | Copies stat stages and Focus Energy; can be snatched | Copies stages; first removes the user's own Focus Energy and Dragon Cheer, then copies the target's; can't be snatched | bs:6455 ORs in Focus Energy (doesn't clear the user's own, doesn't copy `sovereignDragonCheer`); data still has `CAN_SNATCH` | PARTIAL |
| 245 | ExtremeSpeed | +1 priority | +2 priority | data priority 2 | GEN_IX_ALREADY |
| 248 | Future Sight | Damage worked out when used, typeless (no type effectiveness, hits Dark types), no crit | Damage worked out when it lands; Psychic type (Dark types immune, type effectiveness applies) | bs:6482–6498 works it out at setup with no type check; bcp:2104 and sub future_sight_damage only apply the stored HP | GEN_IV |
| 251 | Beat Up | Typeless; per member: base Atk × 10 power vs the target's base Def; ignores immunities | Dark-type physical; per member power 5 + base Atk/10, using the user's Attack and the target's Defense, with STAB and type effectiveness | bs:6612–6623 base-stat formula; eff 0154 `SYSCTL_IGNORE_IMMUNITIES` | GEN_IV |
| 252 | Fake Out | +1 priority | +3 priority; Champions: can't be selected after the first turn | data priority 3; bl:2479 `CHECK_INVALID_FIRST_TURN` | GEN_IX_ALREADY |
| 253 | Uproar | Lasts 2–5 turns; Substitute blocks it | 3 turns; sound move, goes through Substitute | sub uproar:6 `Random 3, 3` (random counter); sound and Substitute handled (bl:4075, bl:4157) | PARTIAL |
| 254 | Stockpile | Gen IV–VI: loses one stage per layer | Gen VII+: loses only the stages it actually gained | sub stockpile:18–27 already counts the actual stages gained (`STOCKPILE_DEF_BOOSTS`) | GEN_IX_ALREADY |
| 256 | Swallow | Heals 1/4, 1/2, 1 | Same (only Snatch handling differs) | eff 0162:5–12 | GEN_IX_ALREADY |
| 259 | Torment | Not reflectable | Reflectable | data flags lack `CAN_MAGIC_COAT` | GEN_IV |
| 264 | Focus Punch | When focus is lost, PP is used and it counts as the last move | Showdown checks focus before taking PP, so no PP is used | eff 0170:5–16 checks after the move starts | UNSURE (PP only) |
| 266 | Follow Me | +3 priority | +2 priority; fails in singles | data priority 2 | GEN_IX_ALREADY |
| 267 | Nature Power | Move from the battle location (Platinum table) | Thunderbolt, Energy Ball, Moonblast or Psychic on the matching terrain; otherwise Tri Attack, or the location move | bs:8474 `sTerrainMove` (`include/data/terrain/to_move.h`); terrains ignored | GEN_IV |
| 268 | Charge | Doubles Electric power only through the next turn | Lasts until the user uses an Electric move (any number of turns) | sub charge:6 counter = 2; bcp:1946 runs it out at the end of the next turn | GEN_IV |
| 269 | Taunt | Lasts 3–5 turns; not reflectable | 3 turns (4 if the target already moved this turn); reflectable; Me First still usable | sub taunt_start:8 `Random 2, 3`; data has no reflect flag; bl:2430 blocks every 0-power move (Me First too) | GEN_IV |
| 273 | Wish | Heals 1/2 of the **receiver's** max HP; can't be snatched | Heals 1/2 of the **user's** max HP (Gen V+); snatchable | bcp:1295 `battleMons[side].maxHP / 2` (whoever is in the slot); bs:6790 stores no HP | GEN_IV |
| 274 | Assist | Gen IV list of moves it can't call; skips moves blocked by Gravity or Heal Block | Gen V+ list of moves it can't call (two-turn moves, Roar, Whirlwind, Dragon Tail, Circle Throw, Transform, Bestow, King's Shield, Spiky Shield, Baneful Bunker, Mat Block, Rage Powder, Spotlight, Beak Blast, Shell Trap, Belch…); no Gravity or Heal Block filter | bs:6839 uses `Move_CanBeMetronomed` (bl:11517: Gen IV list `sCannotMetronomeMoves` bl:11475, plus the Gravity and Heal Block filter at bl:11526) | GEN_IV |
| 275 | Ingrain | Heals 1/16; traps the user | Same (only the end-of-turn order differs) | bcp:1545 | GEN_IX_ALREADY |
| 277 | Magic Coat | Reflects one move, then ends | Reflects every reflectable move for the rest of the turn, including entry hazards aimed at the user's side; not while the user is semi-invulnerable | bcp:3848 clears `magicCoat` after the first reflect | GEN_IV |
| 278 | Recycle | Can't be snatched | Snatchable | data has no `CAN_SNATCH` | GEN_IV (snatch flag only) |
| 281 | Yawn | Sleep at the end of the next turn | Same (only the order differs) | sub yawn | GEN_IX_ALREADY |
| 282 | Knock Off | No power boost; a Pokémon that lost its item can't get a new one this battle | ×1.5 power if the target holds an item it can lose (Gen VI+); afterwards the target may get a new item | sub knock_off and bs:7020 `TryKnockOff` remove the item; no ×1.5 anywhere (`MOVE_KNOCK_OFF` only at bl:~8178). Sets `knockedOffItemsMask` (Gen IV ban on getting a new item) | GEN_IV |
| 283 | Endeavor | Fails when the user's HP ≥ the target's | Same (only the failure path differs) | eff 0189 | GEN_IX_ALREADY |
| 286 | Imprison | Fails unless a foe knows one of the user's moves; can't be snatched | Always works; snatchable | bs:7136 fails when no move is shared | GEN_IV |
| 289 | Snatch | Gen IV Pressure accounting | Pressure always applies (`mustpressure`) | bcp:3904 | GEN_IV (negligible) |
| 290 | Secret Power | Secondary effect from the location | Terrain overrides it: Electric 30% paralysis, Grassy sleep, Misty Sp. Atk −1, Psychic Speed −1 | bs:8501 `sTerrainSideEffect` (location only) | GEN_IV |
| 291 | Dive | — | Flag changes only (animation, Assist, Instruct) | — | GEN_IX_ALREADY |
| 293 | Camouflage | Type from the location | Terrain overrides it: Electric, Grass, Fairy or Psychic | bs:8441 `sTerrainCamouflageType` (location only) | GEN_IV |
| 294 | Tail Glow | Sp. Atk +2 | Sp. Atk +3 (Gen V+). Champions: Past | eff 0053 `SP_ATTACK_UP_2_STAGES` | GEN_IV |
| 300 | Mud Sport | Electric power ×0.5 while the user stays in | Field effect for 5 turns, Electric power ×1352/4096 (about ⅓); fails if already active | eff 0201:6 sets the user's `MOVE_EFFECT_MUD_SPORT`; bl:10820 halves power | GEN_IV |
| 304 | Hyper Voice | Substitute blocks it | Sound move goes through Substitute | `sSoundMoves` bl:4075; `Sovereign_BypassesSubstitute` bl:4157 (used at bcp:~4333, bs:~3149, bs:~9737) | GEN_IX_ALREADY |
| 305 | Poison Fang | 30% bad poison | 50% bad poison (Gen VI+) | data chance 30 | GEN_IV |
| 312 | Aromatherapy | Cures the whole party | Doesn't cure others with Sap Sipper or Good as Gold, or a partner behind a Substitute | bs:~5380 and `battle_io_command.c:653` cure everyone | GEN_IV |
| 316 | Odor Sleuth | Not reflectable | Reflectable | data has no reflect flag | GEN_IV |
| 319 | Metal Sound | Substitute blocks it | Sound move goes through Substitute | as Hyper Voice | GEN_IX_ALREADY |
| 320 | GrassWhistle | Substitute blocks it | Sound move goes through Substitute | as Hyper Voice | GEN_IX_ALREADY |
| 329 | Sheer Cold | OHKO; 30% + level difference; works on Ice types | Ice types are immune; a non-Ice user has 20% base accuracy (Gen VII+) | bs:4654 `TryOHKOMove`, no Ice check (bs:4668) | GEN_IV |
| 335 | Block | Blocked by Protect | Not blocked by Protect (Gen VI+) | data has `CAN_PROTECT` (bcp:3601) | GEN_IV |
| 336 | Howl | Attack +1 to the user | Attack +1 to the user and its ally (Gen VIII+); sound move (Champions: goes through Substitute) | data `RANGE_USER`, eff ATK_UP; sound list bl:4107 | PARTIAL |
| 340 | Bounce | — | Flag changes only (Assist, Instruct) | — | GEN_IX_ALREADY |
| 344 | Volt Tackle | Recoil 1/3 | Recoil 33/100 | sub recoil_1_3:10 (`/3`) | GEN_IV (negligible) |
| 346 | Water Sport | Fire power ×0.5 while the user stays in | Field effect for 5 turns, Fire power ×1352/4096 | eff 0210:6; bl:10824 | GEN_IV |
| 350 | Rock Blast | — | Bullet move (Bulletproof) | `sBallAndBombMoves` bl:9745 includes it | GEN_IX_ALREADY |
| 353 | Doom Desire | as Future Sight, typeless | Steel-type damage worked out when it lands | same code as Future Sight (bs:6470) | GEN_IV |
| 356 | Gravity | 5 turns; grounds; ×5/3 accuracy; disables Fly, Bounce, Jump Kick, Hi Jump Kick, Splash, Magnet Rise | Same, plus disables Flying Press and Telekinesis, ends Telekinesis | bl:3986 list lacks Flying Press and Telekinesis; sub gravity_start doesn't end Telekinesis; bl:2855 Telekinesis Ground immunity ignores Gravity | PARTIAL |
| 357 | Miracle Eye | Not reflectable | Reflectable | data has no reflect flag | GEN_IV |
| 360 | Gyro Ball | 25 × target Speed / user Speed + 1, max 150 | Same | bs:7549 | GEN_IX_ALREADY |
| 361 | Healing Wish | Replacement comes in at once and is healed after the hazards | Comes in at the end of the turn and is healed before them; the wish waits in the slot; snatchable | eff 0220:5–7 and sub hazards_check:5 (Sovereign); no `CAN_SNATCH` flag | GEN_IX_ALREADY (confirmed; snatch flag missing) |
| 364 | Feint | **Fails unless the target is protecting**; Mirror Move can't copy it | Always hits (30 power, +2 priority) and lifts Protect, Wide Guard, Quick Guard and Mat Block; Mirror Move can copy it | bs:7949 `TryFeint` fails if the target isn't protecting (eff 0223:5) | GEN_IV |
| 366 | Tailwind | 3 turns (counting the turn used) | 4 turns (Gen V+) | sub tailwind_start:11 sets the 2-bit counter to 3 (`condition.h` TAILWIND_0/1); bcp:1241 | GEN_IV |
| 367 | Acupressure | Fails if the target, even the user itself, has a Substitute; snatchable | Works on the user behind its own Substitute; can't be snatched | eff 0226:5 `CheckSubstitute BTLSCR_DEFENDER` (the self-use bypass needs attacker ≠ defender, bl:4159); data has `CAN_SNATCH` | GEN_IV |
| 368 | Metal Burst | — | Only the Gen IX Me First flag differs | Me First can still copy it (see #382) | GEN_IX_ALREADY |
| 371 | Payback | Doubles if the target already acted this turn, switching included | Doesn't double against a target that switched in this turn | bs:7628 doubles whenever the target's action is done (switching too) | GEN_IV |
| 373 | Embargo | Not reflectable | Reflectable | data has no reflect flag | GEN_IV |
| 374 | Fling | — | A user with Cud Chew can eat a flung Berry again | bs:9442 `eater = BATTLER_NONE` for Fling, so Cud Chew isn't primed | GEN_IV (negligible) |
| 377 | Heal Block | Blocks healing moves plus the healing from drain moves, Leech Seed and Wish; not reflectable | Blocks **all** HP recovery (items, abilities, Shell Bell…); healing and drain moves can't be selected; reflectable; Psychic Noise gives 2 turns | Moves list bl:4012 is Gen IV's (no drain moves, no Gen V+ healing moves); blocks Aqua Ring, Ingrain, Grassy Terrain, Wish, drain, Leech Seed; Leftovers path bl:7601 has no check; no reflect flag | PARTIAL |
| 378 | Wring Out | 1 + 120×HP/maxHP | floor(120×HP/maxHP), min 1 | bs:7691 | GEN_IV (negligible) |
| 379 | Power Trick | Can't be snatched | Snatchable | data has no `CAN_SNATCH` | GEN_IV (snatch flag only) |
| 381 | Lucky Chant | Can't be snatched | Snatchable | data has no `CAN_SNATCH` | GEN_IV (snatch flag only) |
| 382 | Me First | ×1.5 to final damage; Gen IV list of moves it can't copy | ×1.5 to power; can't copy Counter, Mirror Coat, Metal Burst, Comeuppance, Covet, Thief, Focus Punch, Chatter, Belch, Beak Blast, Shell Trap | bs:1389–1398 ×1.5 to damage; bl:11561 `sCannotMeFirstMoves` is Gen IV's | GEN_IV |
| 383 | Copycat | Gen IV list of moves it can't copy; skips Gravity- and Heal Block-blocked moves | Gen V+ list: Roar, Whirlwind, Dragon Tail, Circle Throw, Transform, Bestow, the newer protect moves, Belch, Beak Blast, Shell Trap…; no Gravity or Heal Block filter | bs:7759 uses `Move_CanBeMetronomed` (Gen IV list + filter) | GEN_IV |
| 389 | Sucker Punch | Fails unless the target is about to attack | Same (Gen IX also lets Me First count) | bs:7824 | GEN_IX_ALREADY |
| 390 | Toxic Spikes | Magic Guard and a Substitute block the poison; not reflectable | Only Heavy-Duty Boots block it (Magic Guard still poisoned); reflectable | Boots: bs:~8065 (Sovereign); sub hazards_check:68 skips **all** hazards for Magic Guard; sub poison:48 and badly_poison:75 `CheckSubstitute`; no reflect flag | PARTIAL |
| 392 | Aqua Ring | Can't be snatched | Snatchable | data has no `CAN_SNATCH` | GEN_IV (snatch flag only) |
| 393 | Magnet Rise | Fails with Levitate or Ingrain; can't be snatched | Fails with Ingrain, Smack Down or Gravity (not Levitate); snatchable | eff 0252:6–8 fails on Levitate/Eelevate, no Smack Down check | GEN_IV |
| 394 | Flare Blitz | Recoil 1/3 | Recoil 33/100 | sub recoil_1_3_chance_to_burn → recoil_1_3 | GEN_IV (negligible) |
| 405 | Bug Buzz | Substitute blocks it | Sound move goes through Substitute | as Hyper Voice | GEN_IX_ALREADY |
| 407 | Dragon Rush | — | Against a Minimized target: double damage and never misses (Gen VI+) | eff FLINCH_HIT; Minimize handled only for `FLINCH_MINIMIZE_DOUBLE_HIT` (eff 0150) | GEN_IV |
| 409 | Drain Punch | Under Heal Block: usable, no healing | Has the heal flag (Gen VI+): Heal Block stops it being selected | bl:4012 list has no drain moves (sub drain_half_damage_dealt only stops the healing) | GEN_IV |
| 413 | Brave Bird | Recoil 1/3 | Recoil 33/100 | sub recoil_1_3:10 | GEN_IV (negligible) |
| 415 | Switcheroo | — | Only Gen VII→IX edge cases on failure differ | — | GEN_IX_ALREADY |
| 432 | Defog | Evasion −1; clears the **target's** side only: Reflect, Light Screen, Safeguard, Mist, Spikes, Toxic Spikes, Stealth Rock; not reflectable | Also clears Sticky Web and Aurora Veil on the target's side, **the user's own side's** hazards (Spikes, Toxic Spikes, Stealth Rock, Sticky Web) and any terrain; reflectable | sub defog:5–72 handles only the target's side and Gen IV conditions (plus Platinum's fog); no reflect flag | GEN_IV |
| 433 | Trick Room | 5 turns; using it again ends it | Same (only the order differs) | — | GEN_IX_ALREADY |
| 446 | Stealth Rock | Not reflectable | Reflectable (Magic Coat, Magic Bounce) | data `flags: []` (Sticky Web already has the flag); damage and Heavy-Duty Boots fine (bs:8731) | GEN_IV |
| 447 | Grass Knot | — | Dynamax only | — | GEN_IX_ALREADY |
| 448 | Chatter | Confusion 0/10/30% from the recorded cry, Chatot only; Mirror Move can't copy it | 100% confusion (Gen VI+); Mirror Move can copy it; sound move, goes through Substitute | bs:8835–8870 cry-based chance; sound handled (bl:4075) | GEN_IV |
| 452 | Wood Hammer | Recoil 1/3 | Recoil 33/100 | sub recoil_1_3 | GEN_IV (negligible) |
| 461 | Lunar Dance | as Healing Wish | as Healing Wish, also restores PP | same as Healing Wish (Sovereign) | GEN_IX_ALREADY (confirmed; snatch flag missing) |
| 462 | Crush Grip | 1 + 120×HP/maxHP | floor(120×HP/maxHP), min 1 | bs:7691 (shared with Wring Out) | GEN_IV (negligible) |
| 464 | Dark Void | Anyone can use it | Fails unless the user is Darkrai (Gen VII+) | no check anywhere (eff STATUS_SLEEP) | GEN_IV |
| 467 | Shadow Force | — | Against a Minimized target: double damage and never misses (Gen VI+) | eff SHADOW_FORCE; no Minimize check | GEN_IV |

### GEN_IV and PARTIAL moves, most to least player-visible, with the suggested change

1. ✅ *Done in moves batch A (CB-0210).* **Fury Cutter (210)**: in `BtlCmd_CalcFuryCutterPower` (bs:6082), cap `furyCutterCount` at 3 (`< 3`), so 40→80→160 and no more. At present the 4th and 5th hits do 320 and 640 power.
2. ✅ *×1.5 done in moves batch A (CB-0210); a Pokémon whose item was knocked off still can't get a new one.* **Knock Off (282)**: in the power step (a `CalcKnockOffPower` in eff 0188, or `BattleScript_CalcMoveDamage`), give ×1.5 when the target holds an item it could lose (not form-locked, not a Griseous Orb on Giratina; Sticky Hold doesn't cancel the boost). Stop `knockedOffItemsMask` from barring a new item.
3. ✅ *Done in moves batch A (CB-0210), in the trainer AI's damage estimate too.* **Hidden Power (237)**: set `movePower = 60` in `BtlCmd_CalcHiddenPowerParams` (bs:6429) and keep the type calculation.
4. **Defog (432)**: extend sub defog to clear Sticky Web and Aurora Veil on the target's side, Spikes, Toxic Spikes, Stealth Rock and Sticky Web on the user's side, and the terrain. Add `CAN_MAGIC_COAT`.
5. ✅ *Done in moves batch A (CB-0210): always hits, and lifts Protect, Wide Guard, Quick Guard, Mat Block and Crafty Shield; still not in Mirror Move's list.* **Feint (364)**: drop the `TryFeint` failure jump (eff 0223:5, bs:7949) so it always hits. Keep lifting Protect and also lift Wide Guard, Quick Guard and Mat Block. Add `CAN_MIRROR_MOVE`.
6. ✅ *Heal done in moves batch B (CB-0211); not snatchable yet (38 below).* **Wish (273)**: at bs:6790 store the user's `maxHP / 2` (new `wishHP[battler]`) and heal that amount at bcp:1295. Add `CAN_SNATCH`.
7. **Future Sight / Doom Desire (248, 353)**: work the damage out when the attack lands (or at least apply type effectiveness and immunity: Psychic, so Dark is immune; Steel), with crits allowed, instead of the typeless amount stored at bs:6482.
8. ✅ *Done in moves batch A (CB-0210).* **Sheer Cold (329)**: in `TryOHKOMove` (bs:4654), make Ice types immune and use 20 base accuracy when the user isn't Ice-type.
9. ✅ *Done in moves batch B (CB-0211): a third bit marks the 4th turn.* **Tailwind (366)**: give Tailwind a 3-bit or separate per-side counter (the 2-bit field at `condition.h` TAILWIND_0/1 can't hold 4) and set it to 4.
10. ✅ *Lengths done in moves batch B (CB-0211); the reflect flags, Encore's list and Me First are still to do.* **Encore (227) and Taunt (269)**:
    - Encore: `encoredTurns` = 2 if the target hasn't moved yet this turn, else 3 (bs:5062).
    - Taunt: 3, or 4 if the target already moved (replace `Random 2, 3`).
    - Both: add `CAN_MAGIC_COAT`.
    - Encore: add Gen IX's moves to `sCannotEncoreMoves` (bl:11540).
    - Taunt: let Me First through.
11. **Beat Up (251)**: per hit, power = 5 + that member's base Attack/10, then the normal damage calculation: user's Attack, target's Defense, Dark type, STAB and effectiveness. Drop `SYSCTL_IGNORE_IMMUNITIES` (eff 0154, bs:6612).
12. ✅ *Done in moves batch A (CB-0210).* **Poison Fang (305)**: effect chance 30 → 50 in its data.json.
13. ✅ *Done in moves batch B (CB-0211); Electromorphosis's and Wind Power's charge last the same way.* **Charge (268)**: don't expire it after a turn (bcp:1946). Clear `MOVE_EFFECT_CHARGE` when the user uses an Electric move other than Charge, or switches out.
14. **Moves that should be reflectable (259 Torment, 316 Odor Sleuth, 357 Miracle Eye, 373 Embargo, 377 Heal Block, 390 Toxic Spikes, 432 Defog, 446 Stealth Rock, and Encore/Taunt above)**: add `MOVE_FLAG_CAN_MAGIC_COAT`. Check that side moves bounce as Sticky Web's does. Stealth Rock against Magic Bounce is the case players will notice most.
15. **Payback (371)**: at bs:7628, don't double against a target that switched in this turn.
16. **Sleep Talk (214)**: in `TrySleepTalk` don't let Choice lock or Encore mark the slots invalid; pass a mask without `CHECK_INVALID_CHOICE_ITEM`, and bypass the Encore check that runs regardless of the mask (bl:2452). Also exclude Belch, Beak Blast, Shell Trap, Mimic, Sketch and Nature Power.
17. **Mean Look, Block (212, 335)**: remove `MOVE_FLAG_CAN_PROTECT` from both data files.
18. **Dragon Rush, Shadow Force (407, 467)**: double damage and a sure hit against a Minimized target (a Gen VI+ list of Minimize punishers). Stomp, Body Slam and Steamroller should get the sure hit too; those are part 1's range.
19. **Heal Block (377) and Drain Punch (409)**:
    - Add the drain moves (Absorb, Mega Drain, Giga Drain, Drain Punch, Dream Eater, Leech Life, Horn Leech, Draining Kiss, Parabolic Charge, Oblivion Wing, Bitter Blade, Matcha Gotcha, Bouncy Bubble) to `sMovesAffectedByHealBlock` (bl:4012).
    - Add the Gen V+ healing moves too (Heal Pulse, Floral Healing, Shore Up, Strength Sap, Purify, Life Dew, Jungle Healing, Lunar Blessing).
    - Block Leftovers, Black Sludge, Berries, Shell Bell and healing abilities while Heal Block is active.
20. **Chatter (448)**: 100% confusion for any user, replacing the cry-volume roll at bs:8835. Add `CAN_MIRROR_MOVE`.
21. **Assist, Copycat (274, 383)**: give them Gen IX's lists of moves they can't call (separate from Metronome's Gen IV list at bl:11475) and remove the Gravity and Heal Block filter (bl:11526).
22. **Sweet Scent (230)**: a new evasion −2 effect using `MOVE_SUBSCRIPT_PTR_EVASION_DOWN_2_STAGES` (the old EVA_DOWN_2 effect 63 is an unused stub).
23. **Tail Glow (294)**: a user Sp. Atk +3 effect, like Cotton Guard's `SOVEREIGN_COTTON_GUARD`.
24. **Mud Sport, Water Sport (300, 346)**: turn each into a 5-turn field condition that fails while active, with Electric (Fire) power ×1352/4096 (bl:10820, bl:10824).
25. **Uproar (253, PARTIAL)**: fixed counter of 3 instead of `Random 3, 3` (sub uproar:6).
26. **Toxic Spikes (390, PARTIAL)**: in sub hazards_check:68, don't let Magic Guard skip Toxic Spikes (it should only skip the damage), and drop the Substitute check for `SIDE_EFFECT_TYPE_TOXIC_SPIKES`.
27. **Magic Coat (277)**: keep `magicCoat` set for the whole turn (bcp:3848), don't reflect while the user is semi-invulnerable, and bounce side-targeting moves.
28. **Howl (336, PARTIAL)**: also raise the partner's Attack in doubles (Soundproof blocks it), as Gen VIII+ does.
29. **Nature Power, Secret Power, Camouflage (267, 290, 293)**: check the active terrain first.
    - Nature Power: Thunderbolt, Energy Ball, Moonblast or Psychic.
    - Secret Power: 30% paralysis, sleep, Sp. Atk −1 or Speed −1.
    - Camouflage: Electric, Grass, Fairy or Psychic.
    - Keep Platinum's location tables as the fallback.
30. **Me First (382)**: apply the ×1.5 to power instead of final damage (bs:1389). Add Metal Burst, Comeuppance, Belch, Beak Blast and Shell Trap to `sCannotMeFirstMoves`.
31. **Psych Up (244, PARTIAL)**: remove `CAN_SNATCH`. Clear the user's Focus Energy and `sovereignDragonCheer`, then copy the target's (bs:6455).
32. **Gravity (356, PARTIAL)**: add Flying Press and Telekinesis to `sMovesAffectedByGravity` (bl:3986). End Telekinesis in sub gravity_start. Make Gravity override the Telekinesis Ground immunity (bl:2855).
33. **Aromatherapy (312)**: skip the partner or bench Pokémon with Sap Sipper or Good as Gold, and a partner behind a Substitute, as Heal Bell's Sovereign code does.
34. **Magnet Rise (393)**: don't fail on Levitate or Eelevate. Fail on Smack Down (`sovereignSmackedDown`). Add `CAN_SNATCH`.
35. **Imprison (286)**: remove the "no shared move" failure (bs:7136) and add `CAN_SNATCH`.
36. **Acupressure (367)**: skip the Substitute check when the target is the user (eff 0226:5) and remove `CAN_SNATCH`.
37. **Dark Void (464)**: fail unless the user is Darkrai.
38. **Snatch flags (278 Recycle, 379 Power Trick, 381 Lucky Chant, 392 Aqua Ring)**: add `CAN_SNATCH`. Healing Wish and Lunar Dance (361, 461) also gain `CAN_SNATCH` in Gen V+; Psych Up and Acupressure lose it.
39. **Recoil 1/3 → 33/100 (344 Volt Tackle, 394 Flare Blitz, 413 Brave Bird, 452 Wood Hammer)**: a difference of at most about 1% of the damage. Optional.
40. **Wring Out, Crush Grip (378, 462)**: drop the `1 +` at bs:7691 (minimum 1). This changes power by 1.
41. **Pursuit (228)**: let an asleep, frozen or loafing user react to a switch (bs:7330). Negligible.
42. **Snatch (289)**: Gen V+ Pressure accounting. Negligible.
43. **Fling (374)**: prime Cud Chew when its holder flings a Berry (bs:9442). Negligible.
44. **Focus Punch (264, UNSURE)**: Showdown's Gen V+ model doesn't use PP when focus is lost. Check against the cartridge before changing anything.

### Side observations (outside the Gen IV→IX overrides)

- Counter, Mirror Coat and Metal Burst have no `MOVE_FLAG_CAN_PROTECT` in their data.json, but Showdown gives them `protect: 1`
  in both Gen IV and Gen IX. It wasn't checked whether Platinum's cartridge lets them through Protect. If Showdown is right, it's a
  Platinum data gap.
- Spikes (#191, part 1's range) also lacks the Gen V+ reflect flag. Metronome's `sCannotMetronomeMoves` (bl:11475) is Platinum's Gen IV
  list, so Metronome can call King's Shield, Spiky Shield and the other later moves that Gen IX forbids. This belongs to #118 (part 1),
  but Assist and Copycat share the list.
