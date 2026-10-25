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
| 1 | Moves that also hit the partner | Platinum checked only five moves by name (Earthquake, Magnitude, Discharge, Lava Plume, Surf) and judged the partner by type alone. Explosion/Self-Destruct and every Gen V+ ally-hitting move (Bulldoze, Sludge Wave, Boomburst, Petal Blizzard, Searing Shot, Parabolic Charge…) were scored as if the partner weren't there | the AI could knock out or badly hurt its own partner | **done:** new AI command `LoadPartnerDamagePercent` (`trainer_ai.c`). Any damaging move aimed at every adjacent Pokémon is estimated against the partner with the same damage calc, at the highest roll. Immunities come from the type chart (Levitate, Magnet Rise, Wonder Guard) and from Volt Absorb, Motor Drive, Water Absorb, Dry Skin and Flash Fire. `TagStrategy_CheckSpecialScoring` then scores: partner unhurt +2, knocked out −10, ≥50% −5, ≥25% −3, less −1. The five by-name handlers are removed | ✅ |
| 2 | Earthquake handler details | it doesn't check that the partner is alive, so a lone Pokémon gets −3 for Earthquake. Its "weak to Ground" list (Fire, Electric, Poison, Rock) misses Steel and ignores dual types and HP | wrong penalties in both directions | replaced by #1 (it checks that the partner is alive, and uses real damage, so Steel types, dual types and HP count) | ✅ |
| 3 | Spread moves vs. two foes | each target is scored separately, so a spread move gets no credit for hitting both foes (its damage is already ×0.75 per foe) | single-target moves look better than they are against two foes | **done:** new AI command `LoadOtherFoeDamagePercent` estimates the spread move's hit on the other foe (same damage calc, highest roll). `TagStrategy_CheckOtherFoe` scores it: other foe knocked out +2, ≥25% +1, absorbs the type (heals or gets a boost) −2 | ✅ |
| 4 | Gen V+ absorbing abilities | the basic immunity check knows Platinum's abilities only: Volt Absorb, Water Absorb, Flash Fire, Wonder Guard, Levitate, Dry Skin, Motor Drive | the AI attacks into Storm Drain, Lightning Rod, Sap Sipper, Earth Eater, Well-Baked Body and similar, which do nothing or boost the foe (these abilities' effects come with item 11) | **done:** Sap Sipper, Storm Drain, Lightning Rod, Well-Baked Body and Earth Eater now absorb (item 11), and the AI's basic immunity check, its Thunder Wave check and the partner/other-foe estimates know them. Also fixes Platinum's Dry Skin check, which tested Levitate twice | ✅ |
| 5 | Redirection | single-target Electric and Water moves aimed at a foe whose partner has Lightning Rod or Storm Drain get redirected (Gen V+) | wasted moves in doubles | **done:** new AI command `LoadTargetPartnerRedirects`. A single-target Electric or Water move aimed at a foe whose partner has Lightning Rod or Storm Drain scores −10 (unless the attacker has Mold Breaker) | ✅ |
| 6 | Moves that can't be selected | Champions rules make Fake Out selectable only on the first turn (`CHECK_INVALID_FIRST_TURN`) | if the AI still picks it later, it wastes a turn | checked: the AI drops every move the player couldn't select (`TrainerAI_Init` filters with `CHECK_INVALID_ALL`, which includes Sovereign's first-turn check), so it never picks Fake Out after the first turn | ➖ |
| 7 | Weather | weather moves are scored by name. Weather from abilities on switch-in (5 turns under Champions rules) isn't part of switching decisions | this matters most for the developer battle's weather control | general part here; the custom weather AI is T2 | 🔧 / T2 |
| 8 | Ally-targeted support moves | moves on the partner need a score of 100 or more. Gen V+ ally moves are mapped to the closest Gen IV effects (E3), so whether they ever target the partner depends on that effect's scoring | e.g. Pollen Puff, Heal Pulse, Coaching, Decorate, After You, Instruct, Ally Switch | **checked** (table below): today nothing can hurt the AI's side. Each move gets its partner scoring as item 11 gives it its exact effect | ➖ now / with item 11 |
| 9 | Mega Evolution timing | none (E8 adds Mega Evolution) | — | **done with E8:** the AI Mega Evolves as soon as it can, so on its first turn with the stone (`docs/EngineChangelog.md`, E8 step 2) | ✅ |

## Order of work

1. ✅ #1–#2 (partner safety). (#6 checked: nothing to fix.)
2. ✅ #3 (spread credit). ✅ #4–#5 (absorbing abilities and redirection).
3. ✅ #8 checked (scoring added per move with item 11). ✅ #9 (with E8). #7 waits for T2.

Each fix gets a scenario in the test build. The developer team has Heat Wave and Rock Slide as spread moves, Water
Spout and Origin Pulse with Kyogre, and Venusaur/Charizard sharing the field.

## Verification (#1–#2)

`tools/test/log_ai_partner_damage.py` logs the AI's partner estimate in game. Lead Garchomp (Lv. 100) knows
Earthquake, Surf, Discharge and Lava Plume:

| Partner | Earthquake | Surf | Discharge | Lava Plume |
|---|---|---|---|---|
| Charizard (Flying, Fire) | **0%** (immune) | 33% (×2) | 29% (×2) | 7% (resisted) |
| Vaporeon (Water Absorb) | 30% | **0%** (absorbed) | 17% | 4% (resisted) |

Moves that hit only the opponents (Heat Wave, Hurricane…) read as not hitting the partner.

## Verification (#3)

`log_ai_partner_damage.py --other-foe`: the developer team's Lv. 100 Mega Charizard against the test party.
- **Heat Wave:** reads 100% (a knockout) on the other foe for either target.
- **With a Flash Fire Heatran swapped in temporarily:** when Heat Wave targets Garchomp, the other foe (Heatran) reads "absorbs" (254); when it targets Heatran, Garchomp reads 100%.
- **Single-target moves:** read as not hitting a second foe.

## #8: moves aimed at the partner (checked 2026-10-23)

**How the AI treats a move aimed at its partner** (`TagStrategy_Partner`, `script.s`):
- A damaging move scores −30 unless the partner absorbs its type (Flash Fire, Volt Absorb, Motor Drive, Water
  Absorb). `TrainerAI_MainDoubles` only uses a partner-aimed move if it scores 100 or more, so the AI never attacks
  its own partner.
- A status move scores −30 unless Platinum names it: Skill Swap, Will-O-Wisp, Thunder Wave, the poison moves, Helping
  Hand, Swagger, Trick, Switcheroo, Gastro Acid and Acupressure. Each of those has its own rules.

**The Gen V+ ally moves today.** E3 maps each to the closest Gen IV effect, and those effects act on the user. So
none of these is ever aimed at the partner, and none can hurt the AI's side:

| Move | Range | Gen IV effect used now | What it does now | Partner scoring to add with its exact effect (item 11) |
|---|---|---|---|---|
| Pollen Puff | single target | plain hit | hits a foe; scores −30 on the partner | partner at ≤ 50% HP, or about to be knocked out, and no Heal Block: +3 on the partner |
| Heal Pulse, Floral Healing | single target | Recover | heals the user | partner ≤ 50% HP: +3 (+1 more on Grassy Terrain for Floral Healing); partner at full HP: −30 |
| Life Dew, Jungle Healing, Lunar Blessing | user's side | Recover / none | heals the user / nothing | score as Recover on whichever of the pair is hurt most |
| Decorate | single target | Swords Dance | raises the user's Attack | partner with a strong attacking move: +2 |
| Coaching | user's side | Bulk Up | raises the user's Attack and Defense | partner's Attack < +6 and it has physical moves: +1 |
| Aromatic Mist | ally | Calm Mind-style Sp. Def | raises the user's Sp. Def | partner faces a special attacker: +1 |
| Instruct | single target | none | nothing | partner's last move was a strong hit: +2 on the partner |
| After You | single target | none | nothing | partner slower than a foe it can knock out: +2 on the partner |
| Ally Switch | user | none | nothing | foe aimed a single-target move at us last turn: +1 (random) |
| Hold Hands | ally | none | nothing | −10 always (no battle effect) |
| Dragon Cheer, Magnetic Flux, Gear Up | user's side | none / Def+SpD / Swords Dance | nothing / the user | score as the stat move for each of the pair it can affect |
| Purify, Spotlight, Quash, Entrainment, Simple Beam | single target | none | nothing | Purify: partner has a status condition +2. Others: per their exact effect |

Platinum's own ally moves keep their rules: Helping Hand, Acupressure, Skill Swap, Swagger, Trick and so on.
