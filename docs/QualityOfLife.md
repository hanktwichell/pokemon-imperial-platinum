# Imperial Platinum — Quality of Life

## Kept from Renegade Platinum (all unchanged)

- **TMs:** every TM has a quantity of 99 when obtained; TMs cost nothing (unsellable); a League NPC refills all TMs to 99.
- **Move Relearner** (Pastoria) is free; no Heart Scales.
- **Move Tutors:** all tutors are gathered in the Route 212 (South) house and teach for free.
- **Move Deleter** moved next to the Oreburgh Pokémon Center.
- **Hidden Power teller** in the Jubilife Trainers' School (and Veilstone).
- **Evolution item seller** in Snowpoint City ($10,000 each). *Imperial adds the new evolution items to her stock.*
- **Rare Berry seller** on Route 208.
- **Item Fanatic** in Floaroma (Light Ball, Stick, Thick Club, Lucky Punch, powders, Deep Sea items).
- **Training NPCs** in the Solaceon Day Care (EXP trainers by badge tier, EV trainers, EV-reducing berry bundle).
- **Trade evolutions** replaced by levels or item use; trade items have a "Use" option.
- **Obedience** check for traded Pokémon disabled.
- **Honey Trees** produce an encounter immediately.
- **Cheaper Poké Balls** (Poké $50, Great $150, Ultra $300).
- **Super Rod** available in Snowpoint City.
- **Pokédex area data** is accurate. *Imperial must regenerate this for the new encounter tables.*
- **Starters from every region** via Pokémon Center Interviewers. *Imperial extends this to Gen V–IX; see `GiftPokemon_Imperial.md`.*
- **Optional patches** (Speed Up, 1/4096 and 1/8192 shiny rates, Classic Version) should be rebuilt against the Imperial ROM.

## Approved Imperial additions (requested by the project owner)

| Feature | Behaviour |
|---|---|
| **Level cap** (Options → LEVEL CAP on/off, default off) ✅ | While on, party Pokémon stop gaining EXP once they reach the level of the **ace of the next big fight** (Gym Leader, Galactic Commander/Boss, Champion). During the Elite Four the cap is **Cynthia's ace level**. EXP isn't banked; Pokémon at the cap gain nothing (EVs still count), and Exp. Share follows the same rule. The cap table is `data/level_caps.yaml` (checked against `data/trainers_imperial.yaml` by `tools/engine/gen_level_caps.py`), keyed by the trainers' defeated flags. Barry's fights count as big fights. |
| **Infinite Rare Candy** (Options → INF. CANDY on/off, only selectable while the level cap is on) ✅ | Rare Candies aren't used up, and can't raise a Pokémon past the current cap. Turning it on gives one Rare Candy if the bag has none. Turning the level cap off also turns this off. |
| **Music volume** (Options → MUSIC slider 0–100) ✅ | Sets background-music volume in steps of 5 (hold left/right to move quickly; the volume changes as you move it). Sound effects and cries are unaffected. Saved with the other options. |

## Approved QoL from the proposal list (owner, 2026-10-22: items 1, 2, 3, 4, 5, 6, 8, 9, 11)

| # | Feature | Imperial design | Depends on |
|---|---|---|---|
| 1 | **Nature Mints** | One Mint per nature (21 stat-changing natures + Serious Mint), sold by Renegade's Route 208 berry seller ($10,000). A minted Pokémon keeps its real nature (for Synchronize, PID) but uses the Mint's stat changes; the summary screen shows the Mint nature. Stored in a spare byte of the Pokémon data. | item table (E7) |
| 2 | **Repel prompt** | When a Repel/Super Repel/Max Repel runs out and the bag still has one of the same kind: "Use another?" (Yes/No). | — |
| 3 | **Infinite Repel** | Key item ("Repel Lure"-style toggle) given by Professor Rowan's aide after the Coal Badge. Using it toggles a permanent repel on/off; while on, a bag icon shows its state. | item table (E7) |
| 4 | **Party-wide Exp. Share** | Options: **EXP. SHARE ON/OFF** (default ON, like Gen VI+). When on, every non-fainted party member that didn't battle gets 50% of the EXP (participants get 100%). Respects the level cap. The old held Exp. Share keeps working when the option is OFF. | ✅ done (E13) |
| 5 | **Type-effectiveness indicator** | On the move-select touch screen, each move shows "Super effective / Not very effective / No effect" against the targeted foe (only for species the player has registered as seen). | — |
| 6 | **IV/EV viewer** | Summary screen stats page: press **SELECT** to cycle Stats → IVs → EVs. | built (E14); in-game test pending |
| 8 | **HMs as key items / no HM slaves** | Once the right badge and HM are obtained, field moves (Cut, Rock Smash, Strength, Surf, Defog, Rock Climb, Waterfall, Fly) work from the field prompt without any party Pokémon knowing them. HMs can be forgotten freely. | — |
| 9 | **Gen VI+ breeding** | Destiny Knot passes 5 of the parents' 10 IVs; Everstone passes nature 100%; Egg moves pass from either parent; Poké Ball inheritance from the mother. | — |
| 11 | **Ability Capsule NPC** | NPC in the Battle Tower lobby (Fight Area) swaps a Pokémon between its two standard abilities for 50 BP (or $20,000). The Hidden Ability needs the Ability Patch (later). | hidden abilities (E4) |

## Remaining proposals (not approved)

| # | Feature | Seen in | Notes / cost |
|---|---|---|---|
| 7 | **PC access from the menu** (or a "Box Link" key item) | Unbound | Medium. |

#7 stays on this list but isn't planned yet (owner, 2026-10-22). #10 (Exp. Candies) was dropped.
