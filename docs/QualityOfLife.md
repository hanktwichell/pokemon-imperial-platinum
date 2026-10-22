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

## Proposed additions — awaiting the project owner's approval

None of these will be implemented without approval. They are features seen in other ROM hacks (Pokémon Unbound,
Radical Red, Sacred Gold/Storm Silver, Insurgence) or later official games.

| # | Feature | Seen in | Notes / cost |
|---|---|---|---|
| 1 | **Nature Mints** sold alongside the berry seller | Gen VIII, Radical Red, Unbound | Changes the stat nature effect only. Needs a new "stat nature" byte or a reused field. |
| 2 | **Repel prompt**: "Use another Repel?" when one runs out | Gen V+, most hacks | Small script/field change. |
| 3 | **Infinite Repel** key item (toggle) | Radical Red | Small. |
| 4 | **Party-wide Exp. Share** toggle | Gen VI+, Unbound | Medium. Must be rebalanced against Renegade's level curve. |
| 5 | **Type-effectiveness indicator** on the move-select screen | Unbound, Radical Red | Medium. Uses the touch screen. |
| 6 | **IV/EV viewer** on the summary screen | Unbound, Radical Red | Medium. |
| 7 | **PC access from the menu** (or a "Box Link" key item) | Unbound | Medium. |
| 8 | **HMs as key items / no HM slaves** (field moves usable without knowing them) | Unbound, Insurgence | Medium. Story checks stay badge-based. |
| 9 | **Gen VI+ breeding** (Destiny Knot passes 5 IVs; Everstone passes nature 100%) | Gen VI+ | Small–medium. |
| 10 | **Exp. Candies** as rewards instead of some Rare Candies | Gen VIII+ | Small. |
| 11 | **Ability Capsule** NPC (swap between a species' two abilities) | Gen VI+ | Small (item exists in later gens only). |

Please tell us which of these to implement.
