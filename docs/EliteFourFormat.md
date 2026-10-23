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

## Implementation notes (scripts)

New save variables and flag (IDs to be assigned from unused slots):

| Name | Meaning |
|---|---|
| `VAR_SOVEREIGN_E4_MODE` | 0 = two-and-two (first challenge), 1 = all singles, 2 = all doubles |
| `VAR_SOVEREIGN_E4_FORMAT` | bit 0 Aaron, bit 1 Bertha, bit 2 Flint, bit 3 Lucian, bit 4 Cynthia (1 = doubles) |
| `VAR_SOVEREIGN_E4_STAGE` | how many prompts have been answered this run (0–3) |
| `FLAG_GAME_CLEAR` | existing vanilla flag: Champion beaten at least once |

New trainer entries (each with the double-battle flag set where needed):

- Round 1: Aaron, Bertha, Flint, Lucian × {singles, doubles} = 8, plus Cynthia doubles (+ an optional Cynthia R1 singles test team).
- Round 2: Aaron, Bertha, Flint, Lucian, Cynthia × {singles, doubles} = 10.

Pseudocode in the style of the pret/pokeplatinum script macros (exact command names to be confirmed against DSPRE or the
decomp when implementing):

```
LeagueEntrance_OnEnter:                    ; existing script on entering Aaron's room
    SetVar VAR_SOVEREIGN_E4_FORMAT, 0
    SetVar VAR_SOVEREIGN_E4_STAGE, 0
    GoToIfUnset FLAG_GAME_CLEAR, _first
    SetVar VAR_SOVEREIGN_E4_MODE, 0         ; reset; Aaron asks again
_first:
    End

Aaron_PreBattle:
    Message Aaron_Intro
    GoToIfUnset FLAG_GAME_CLEAR, _ask_aaron
    ShowMenu3 "All singles", "All doubles", "Two and two" -> VAR_RESULT
    CallIfEq VAR_RESULT, 0, _set_all_singles     ; MODE=1, FORMAT=0b00000
    CallIfEq VAR_RESULT, 1, _set_all_doubles     ; MODE=2, FORMAT=0b11111
    GoToIfNe VAR_SOVEREIGN_E4_MODE, 0, _battle_aaron
_ask_aaron:
    Call AskSinglesOrDoubles                     ; VAR_RESULT: 0 singles / 1 doubles
    SetFormatBit 0, VAR_RESULT
    AddVar VAR_SOVEREIGN_E4_STAGE, 1
_battle_aaron:
    Call StartFormatBattle_Aaron                 ; picks R1/R2 x singles/doubles trainer ID from bit 0

Bertha_PreBattle:
    GoToIfNe VAR_SOVEREIGN_E4_MODE, 0, _battle_bertha
    Call AskSinglesOrDoubles
    SetFormatBit 1, VAR_RESULT
    ; if bit0 == bit1: force Flint and Lucian to the opposite and announce it after the battle
    CallIf Bit0EqualsBit1, _force_flint_lucian
_battle_bertha:
    Call StartFormatBattle_Bertha

Flint_PreBattle:
    GoToIfNe VAR_SOVEREIGN_E4_MODE, 0, _battle_flint
    GoToIf Bit0EqualsBit1, _battle_flint         ; already forced
    Call AskSinglesOrDoubles
    SetFormatBit 2, VAR_RESULT
    SetFormatBit 3, !VAR_RESULT                  ; Lucian gets the other one
_battle_flint:
    Call StartFormatBattle_Flint

Lucian_PreBattle:
    Call StartFormatBattle_Lucian                ; no prompt

Cynthia_PreBattle:
    ; first challenge or two-and-two: doubles; otherwise bit 4 from MODE
    Call StartFormatBattle_Cynthia

AskSinglesOrDoubles:
    ShowYesNo-style 2-option menu "Singles" / "Doubles" -> VAR_RESULT
    GoToIfEq VAR_RESULT, 0, _done
    CheckPartyUsableCount -> VAR_0x8004
    GoToIfGe VAR_0x8004, 2, _done
    Message Warn_OnlyOnePokemon                  ; "Are you sure?" -> No => VAR_RESULT = 0
_done:
    Return
```

`StartFormatBattle_<Member>` chooses between the four trainer IDs (round × format) and calls the double-battle or
single-battle start command accordingly.
