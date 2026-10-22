# Sovereign Platinum — Trainer format (E9)

Trainers live in `decomp/res/trainers/data/<trainer>.json`, one file per trainer, packed by
`decomp/tools/dataproc/src/trainerproc.c`. Sovereign keeps Platinum's file format and adds optional fields to each
party member, so a boss team can be written exactly: nature, ability, IVs, EVs, gender, shininess and Poké Ball.

## Party member fields

Platinum's fields (every trainer has these):

| Field | Meaning |
|---|---|
| `species` | `SPECIES_*` constant. Any species, up to #1025 (no 11-bit limit in the Sovereign layout). |
| `form` | form number (0 = base form) |
| `level` | 1–100 |
| `item` | held item, `ITEM_*` (`ITEM_NONE` for none). Optional: Platinum's trainers either all have it or none do. |
| `moves` | up to 4 `MOVE_*`. Optional: without it the Pokémon knows its last four level-up moves. |
| `iv_scale` | 0–255. In Platinum's layouts it sets every IV to `iv_scale × 31 / 255`. In both layouts it also seeds the personality value. |
| `ball_seal` | Ball Capsule ID (0 = none) |

Sovereign's fields (all optional; any of them on any party member switches the whole party to the Sovereign layout):

| Field | Example | Meaning |
|---|---|---|
| `nature` | `"NATURE_MODEST"` | the nature. Left out: from the personality value, as in Platinum. |
| `ability` | `"ABILITY_ROUGH_SKIN"` | the ability. If it is one of the species' two abilities, that slot is used; if it's the Hidden Ability, the Pokémon has its Hidden Ability. Either way the choice survives form changes. Any other ability is set as is (a "custom" ability; a form change would reset it). Left out: from the personality value. |
| `ivs` | `{"atk": 0}` | IVs by stat: `hp`, `atk`, `def`, `spa`, `spd`, `spe`. **A stat left out is 31.** Left out entirely: every IV comes from `iv_scale`. |
| `evs` | `{"hp": 252, "spa": 252, "spd": 4}` | EVs by stat, same keys. At most 255 per stat (252 is the useful most: every 4 EVs is one stat point) and 510 in total. A stat left out is 0. |
| `gender` | `"female"` | `"male"` or `"female"`. Ignored for single-gender and genderless species. Left out: from the personality value. |
| `shiny` | `true` | shiny or not (default `false`) |
| `ball` | `"ITEM_LUXURY_BALL"` | the Poké Ball it's sent out from (default Poké Ball). Must be an item with an ID below 256 (the Pokémon stores its ball in one byte). |

Example (from `sovereign_test.json`):

```json
{
    "species": "SPECIES_GARCHOMP",
    "form": 0,
    "level": 100,
    "item": "ITEM_LIFE_ORB",
    "moves": ["MOVE_DRAGON_CLAW", "MOVE_STOMPING_TANTRUM", "MOVE_FIRE_FANG", "MOVE_PROTECT"],
    "iv_scale": 255,
    "ball_seal": 0,
    "nature": "NATURE_JOLLY",
    "ability": "ABILITY_ROUGH_SKIN",
    "evs": {"hp": 4, "atk": 252, "spe": 252},
    "ivs": {},
    "gender": "male",
    "shiny": true,
    "ball": "ITEM_LUXURY_BALL"
}
```

## How it works

- **Layouts.** A party is packed in one of Platinum's four layouts (with or without moves, with or without items)
  unless a member uses a Sovereign field; then it's packed as `TrainerMonSovereign`
  (`include/struct_defs/trainer_data.h`, `TRDATATYPE_SOVEREIGN`, 38 bytes per Pokémon). Platinum's 928 trainers pack
  byte-for-byte as before.
- **Nature, gender and ability slot** all come from the personality value, as in the main games. The game starts from
  Platinum's seeded value (so a trainer's team is the same every time) and changes it as little as possible
  (`TrainerData_SovereignPersonality`, `src/trainer_data.c`): the low byte sets the gender and the ability slot, and
  the rest is stepped until the nature matches.
- **Hidden Ability** uses Sovereign's Hidden Ability flag (E4), so it behaves like a player's Hidden Ability Pokémon.
- **Shiny** comes from choosing the Pokémon's OT ID to match its personality value; the personality (and so the
  nature, gender and ability) is unaffected.
- **Stats** are recalculated after the form, IVs and EVs are set.

## Testing

- The test build's SELECT+R starts a double battle against `TRAINER_SOVEREIGN_TEST` ("Ace Trainer Twich"): the
  developer team (`docs/DeveloperBattle.md`) in this format, at Lv. 100. Charizardite Y, the Blue Orb and Assault Vest
  come with E7; until then those three slots hold no item.
- `tools/test/check_trainer_party.py ROM XMAP SAVE [TRAINER_JSON]` starts that battle, decrypts every Pokémon the game
  builds for the opponent, and compares each one with the JSON, including all six stats recomputed from base stats,
  IVs, EVs and nature.

## Adding a trainer

1. Add `TRAINER_<NAME>` before `MAX_TRAINERS` in `decomp/generated/trainers.txt`.
2. Add `FLAG_DEFEATED_TRAINER_<NAME>` in `decomp/generated/vars_flags.txt`, right before `TRAINER_DEFEATED_FLAGS_END`,
   and point `TRAINER_DEFEATED_FLAGS_END` at it. Take the place of an unused `FLAG_UNK_*` after it so later flag IDs
   don't move (`TRAINER_SOVEREIGN_TEST` took `FLAG_UNK_0x08F0`). trainerproc fails the build if there are more trainers
   than flags.
3. Write `decomp/res/trainers/data/<name>.json` (lowercase, without `TRAINER_`).
4. Battle scripts are generated per trainer (`trainer_scripts.h`), up to 2,000 trainers.
