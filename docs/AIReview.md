# Sovereign Platinum — Trainer AI review (12b)

Owner request: check whether the trainer AI needs adjusting for double battles (targeting, spread moves, partner
awareness, Mega timing) and for Gen IX moves and abilities, and fix what's needed. This page lists what the AI does
now, what's wrong or missing, and the fix for each. Status: ✅ fixed · 🔧 planned · ➖ no change needed.

The test build's SELECT+R battle (`TRAINER_SOVEREIGN_TEST`, the developer team at Lv. 100 in doubles) is the
opponent for checking these in game.

## How Platinum's AI works

- **Engine:** `decomp/src/battle/trainer_ai/trainer_ai.c`. **Logic:** `decomp/src/battle/trainer_ai/script.s`, a
  bytecode script with one routine per AI flag (`AI_FLAG_BASIC`, `EVAL_ATTACK`, `EXPERT`, `TAG_STRATEGY`, `WEATHER`
  and so on). A trainer's `ai_flags` choose which routines run.
- Every usable move starts at score 100. Each routine adds to or subtracts from it, and the highest score wins (ties
  are broken at random).
- **Singles:** one pass over the moves against the opposing Pokémon.
- **Doubles** (`TrainerAI_MainDoubles`):
  - It runs the whole scoring once per possible target: both foes and the partner.
  - For each target it keeps the best move, then it takes the best target overall.
  - A move aimed at the partner is only used if it scores at least 100.
- **Damage estimates** use the game's own damage formula (`BattleSystem_CalcMoveDamage`). That includes the doubles
  ×0.75 for spread moves, weather, items and abilities.
- `AI_FLAG_TAG_STRATEGY` is the doubles routine (`TagStrategy_Main`). Among other things it:
  - nudges toward the side's highest-damage move;
  - nudges up super-effective moves;
  - has special cases, by move name, for Earthquake/Magnitude, Future Sight, the four weather moves, Gravity, Trick
    Room, Follow Me, Skill Swap and Helping Hand;
  - has a partner-targeting routine (`TagStrategy_Partner`).

## Findings

| # | Area | What happens now | Why it matters | Fix | Status |
|---|---|---|---|---|---|
| 1 | Moves that also hit the partner | Only **Earthquake and Magnitude** are checked, by name. Surf, Discharge, Lava Plume, Explosion/Self-Destruct and the Gen V+ ones (Bulldoze, Sludge Wave, Boomburst, Petal Blizzard, Searing Shot, Parabolic Charge…) are scored as if the partner weren't there | the AI can knock out or badly hurt its own partner (e.g. Surf next to a Fire type) | decide by the move's range (`RANGE_ALL_ADJACENT`), not its name. Estimate the damage to the partner with the same damage formula, including immunities from type and ability (Levitate, Water Absorb/Storm Drain, Volt Absorb/Lightning Rod/Motor Drive, Flash Fire, Earth Eater, Telepathy…). Penalise by how much of the partner's HP it costs, heavily if it would knock the partner out, and reward a partner immunity | 🔧 |
| 2 | Earthquake handler details | it doesn't check that the partner is alive, so a lone Pokémon gets −3 for Earthquake. Its "weak to Ground" list (Fire, Electric, Poison, Rock) misses Steel and ignores dual types and HP | wrong penalties in both directions | replaced by #1 | 🔧 |
| 3 | Spread moves vs. two foes | each target is scored separately, so a spread move gets no credit for hitting both foes (its damage is already ×0.75 per foe) | single-target moves look better than they are against two foes | when both foes are alive and the spread move does real damage to both, add a small bonus | 🔧 |
| 4 | Gen V+ absorbing abilities | the basic immunity check knows Platinum's abilities only: Volt Absorb, Water Absorb, Flash Fire, Wonder Guard, Levitate, Dry Skin, Motor Drive | the AI attacks into Storm Drain, Lightning Rod, Sap Sipper, Earth Eater, Well-Baked Body and similar, which do nothing or boost the foe (these abilities' effects come with item 11) | add them to the immunity check as each ability's effect is built | 🔧 |
| 5 | Redirection | single-target Electric and Water moves aimed at a foe whose partner has Lightning Rod or Storm Drain get redirected (Gen V+) | wasted moves in doubles | penalise them when the target's partner redirects that type | 🔧 (with #4) |
| 6 | Moves that can't be selected | Champions rules make Fake Out selectable only on the first turn (`CHECK_INVALID_FIRST_TURN`) | if the AI still picks it later, it wastes a turn | checked: the AI drops every move the player couldn't select (`TrainerAI_Init` filters with `CHECK_INVALID_ALL`, which includes Sovereign's first-turn check), so it never picks Fake Out after the first turn | ➖ |
| 7 | Weather | weather moves are scored by name. Weather from abilities on switch-in (5 turns under Champions rules) isn't part of switching decisions | this matters most for the developer battle's weather control | general part here; the custom weather AI is T2 | 🔧 / T2 |
| 8 | Ally-targeted support moves | moves on the partner need a score of 100 or more. Gen V+ ally moves are mapped to the closest Gen IV effects (E3), so whether they ever target the partner depends on that effect's scoring | e.g. Pollen Puff, Heal Pulse, Coaching, Decorate, After You, Instruct, Ally Switch | list them and check each one's target and score | 🔧 |
| 9 | Mega Evolution timing | none (E8 adds Mega Evolution) | — | decide with E8 (other session): Mega on the first turn unless there's a reason not to | 🔧 with E8 |

## Order of work

1. #1–#2 (partner safety), the largest real problem. (#6 checked: nothing to fix.)
2. #3 (spread credit), then #4–#5 with item 11's ability effects.
3. #8, then #7 (with T2) and #9 (with E8).

Each fix gets a scenario in the test build. The developer team has Heat Wave and Rock Slide as spread moves, Water
Spout and Origin Pulse with Kyogre, and Venusaur/Charizard sharing the field.
