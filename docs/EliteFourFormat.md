# Sovereign Platinum — Elite Four & Champion Battle Format

## First challenge: two singles, two doubles

The Elite Four must still be fought in order: **Aaron → Bertha → Flint → Lucian → Cynthia**. Of the four Elite Four
battles, the player picks **two singles and two doubles**. **Cynthia is always a double battle** on the first challenge.

The question is asked inside each member's normal pre-battle dialogue:

| Member | Prompt? | Result |
|---|---|---|
| Aaron | Always: *"Singles or doubles?"* | Aaron uses the chosen format. |
| Bertha | Always: *"Singles or doubles?"* | Bertha uses the chosen format. |
| Flint | Only if Aaron and Bertha were **different** | Flint uses the chosen format; Lucian gets the other one. |
| Lucian | Never | Gets whatever is left. |
| Cynthia | Never | Double battle. |

If the player picks the **same** format for Aaron and Bertha, Bertha says so after the battle. For example: *"You've
chosen singles twice, so Flint and Lucian will meet you in double battles!"* Flint and Lucian then use the other
format with no prompt.

All four possible paths:

| Aaron | Bertha | Flint | Lucian |
|---|---|---|---|
| Singles | Singles | Doubles (forced) | Doubles (forced) |
| Doubles | Doubles | Singles (forced) | Singles (forced) |
| Singles | Doubles | *prompt* — S or D | the other |
| Doubles | Singles | *prompt* — S or D | the other |

## Rematches (after becoming Champion once)

Aaron's pre-battle dialogue opens with a three-way menu:

1. **All singles.** All five battles, Cynthia included, are singles.
2. **All doubles.** All five battles are doubles.
3. **Two and two.** The first-challenge rules above apply again (prompts at Aaron, Bertha and possibly Flint), and Cynthia is doubles.

Rematches use the Round 2 teams in `TrainerPokemon_Sovereign.md`, which have both a singles and a doubles version for
every member, Cynthia included.

## Rules and edge cases

- Choices last for one run. If the player loses (whites out) or leaves the League, the run resets and Aaron asks again.
- Saving mid-run keeps the choices (they live in save variables).
- **Doubles with one healthy Pokémon:** a scripted double battle lets a lone Pokémon fight (it sends out one; the
  engine supports this since CB-0032, tested against the test trainer's double battle). The member warns the player
  first: *"You only have one Pokémon able to fight… are you sure?"* Choosing "No" switches that battle to singles. If
  a member's format is forced (e.g. Flint/Lucian after a matching pair), the same warning and fallback apply, and
  Lucian takes whatever is left over.
- Cynthia's singles teams never use Protect/Detect. Her doubles teams use Protect on the Pokémon where it's optimal. The
  validator in `tools/design/gen_trainer_docs.py` enforces this.
- Renegade's random choice among four teams per member is replaced by one fixed team per format.

## In the game (E11)

Built as designed above. The scripts are in the five room maps (`scripts_pokemon_league_*_room.s`).

**State.** One variable, `VAR_SOVEREIGN_E4_FORMAT` (it was the unused `VAR_DUMMY_0x40F4`), holds the run's formats as
bits. New script commands `CheckVarBit` and `SetVarBit` read and write them.

| Bit | Meaning |
|---|---|
| 0 | Aaron (1 = doubles) |
| 1 | Bertha |
| 2 | Flint |
| 3 | Lucian |
| 4 | Cynthia |
| 5 | the remaining formats are decided, so no more questions |
| 6 | Bertha announces the forced pair after her battle |

**The run.** Aaron starts every run, so his script sets the variable afresh:
- First challenge, or "Two and two": Cynthia doubles, then Aaron asks.
- "All singles": everyone singles, decided.
- "All doubles": everyone doubles, decided.

A loss sends the player back to the Pokémon Center. The defeated flags reset there (vanilla), so Aaron asks again.

**The questions** are two common scripts, so every room shares them:
- `Common_SovereignE4AskFormat` (0x80D) asks "single battle or double battle?" and returns 1 for doubles.
- `Common_SovereignE4CheckLoneMon` (0x80E) runs before a double battle when the player has only one Pokémon able to
  battle. It warns and offers singles, and returns 1 to keep doubles.
- A forced or pre-decided double battle also gets the warning. Choosing singles there changes only that battle.

**Teams.** The singles battles use the existing trainers:
- `TRAINER_ELITE_FOUR_*` and `TRAINER_CHAMPION_CYNTHIA`.
- Their `_REMATCH` versions once Charon is arrested at Stark Mountain, as in vanilla.

The doubles battles use ten new trainers, `TRAINER_SOVEREIGN_ELITE_FOUR_*_DOUBLES` and
`TRAINER_SOVEREIGN_CHAMPION_CYNTHIA_DOUBLES`, each with a `_REMATCH_DOUBLES` version:
- They took over unused dummy trainer slots.
- For now each is a copy of its singles team as a double battle, with the doubles AI (`AI_FLAG_TAG_STRATEGY`).
- The Sovereign teams in `data/trainers_sovereign.yaml` (singles and doubles, both rounds) replace them with T1.

**Elsewhere:**
- The rematch doubles teams pay the post-game 3× prize money (decision 24).
- The level cap's Champion steps end with either Cynthia (`data/level_caps.yaml`).
