# Sovereign Platinum — Developer final battle (T2)

A hidden, Red-style **double battle** against the mod's developer (the owner), with a custom team and a custom AI
written for this fight. Roadmap item T2; the AI review for doubles is item 12b.

- **Trainer:** Sovereign Henry (class "Sovereign", name "Henry"; owner 2026-10-22, see *Naming*).
  Henry is the last surviving member of the Sovereign lineage, and his dialogue refers to him being the game's
  developer. The story behind the fight is in `docs/Story.md`.
- **Location:** Spear Pillar, at the summit of Mt. Coronet: the Sovereign throne room (post-game).
- **Unlocks** (owner): first Hall of Fame → Dialga and Palkia at Spear Pillar → the Elite Four rematch (locked until
  both are done) → after beating Cynthia the second time, she sends the player back to Spear Pillar, where Henry
  appears only if the player holds the complete 11-piece crown from the Totem trials. Event order: `docs/Story.md`.
- **Afterwards:** the player is granted the Sovereign title, and Cynthia arrives to congratulate them
  (`docs/Story.md`). Cynthia is the reason Henry uses a Garchomp.
- **Level:** 100 for the whole team.
- **Leads:** always Charizard (Mega Y) and Venusaur.
- **Concept:** a triple-weather team built as three synergy pairs:
  - **Sun:** Charizard-Y + Venusaur (Drought powers Chlorophyll, Weather Ball and Heat Wave).
  - **Sand:** Tyranitar + Garchomp.
  - **Rain:** Kyogre + Archaludon (rain makes Electro Shot fire in one turn).

## Team (owner, 2026-10-22, revised the same day)

Changes from the first version:
- Charizard: Hurricane replaced Ancient Power.
- Tyranitar: Ice Punch replaced Protect; Choice Band replaced Assault Vest.
- Archaludon: a new set (now female, Modest, Assault Vest).

| # | Pokémon | Item | Ability | Nature | EVs | IVs | Moves | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | Charizard ♂ | Charizardite Y | Blaze (Mega: Drought) | Modest | 252 SpA / 4 SpD / 252 Spe | 0 Atk | Weather Ball, Heat Wave, Hurricane, Protect | Mega Evolves |
| 2 | Venusaur ♀ | Focus Sash | Chlorophyll | Modest | 4 HP / 252 SpA / 252 Spe | 0 Atk | Sleep Powder, Leaf Storm, Sludge Bomb, Protect | |
| 3 | Tyranitar ♂ | Choice Band | Sand Stream | Adamant | 252 HP / 252 Atk / 4 SpD | — | Rock Slide, Crunch, Low Kick, Ice Punch | |
| 4 | Garchomp ♂ (shiny) | Life Orb | Rough Skin | Jolly | 4 HP / 252 Atk / 252 Spe | — | Dragon Claw, Stomping Tantrum, Fire Fang, Protect | |
| 5 | Kyogre | Blue Orb | Drizzle (Primal: Primordial Sea) | Modest | 252 HP / 252 SpA / 4 SpD | 0 Atk | Water Spout, Origin Pulse, Ice Beam, Protect | Primal Reversion |
| 6 | Archaludon ♀ (shiny) | Assault Vest | Stamina | Modest | 252 HP / 156 SpD / 100 Spe | 0 Atk | Electro Shot, Body Press, Flash Cannon, Dragon Pulse | |

Every Pokémon on the team is in a **Luxury Ball** (owner, 2026-10-22). Unlisted IVs are 31. Every EV spread is within 252 per stat / 510 total. The owner's sets include Tera Types
(Archaludon: Grass), but Sovereign has no Terastallization, so they're unused.

## What the engine needs before this fight works as written

| Need | Milestone | Status |
|---|---|---|
| Per-mon nature, ability, EVs, IVs, held item, gender and shininess in trainer data | E9 | ✅ done. The team is already in this format, held items included, as the test build's `TRAINER_SOVEREIGN_TEST` (SELECT+R) |
| Archaludon (#1018) | E6 step 2 | species being added now |
| Charizardite Y, Blue Orb, Assault Vest | E7 | ✅ the items exist and the test team holds them; Assault Vest has no battle effect yet (E7's hold effects) |
| Mega Evolution (Charizard Y) and Primal Reversion (Kyogre) | E8 | |
| Stamina, Primordial Sea, Drought (on Mega Charizard Y) | E8 / item 11 | Stamina and Primordial Sea have no battle effect yet |
| Electro Shot (charge turn, skipped in rain) and Stomping Tantrum (double power after a failed move) | item 11 | both are plain hits for now; Origin Pulse is exact |
| Hurricane's weather accuracy (never misses in rain, 50% in sun) | item 11 | it hits and may confuse, with 70% accuracy in any weather, for now |
| Body Press (damage from the user's Defense instead of Attack) | item 11 | a plain hit using Attack for now, which is weak on this 0-Attack-IV, Modest Archaludon |
| Custom AI for this fight, and doubles awareness | T2 / 12b | |

## Interactions worth knowing (owner's call; nothing changed)

- **Primal Kyogre's Primordial Sea vs Charizard:** while Primal Kyogre is on the field, Fire moves fail (Heat Wave;
  Weather Ball turns Water-type). Mega Charizard Y's Drought can't replace it.
- **Weather turnover:** Drought (Charizard Y), Sand Stream (Tyranitar) and Drizzle/Primordial Sea (Kyogre) all
  change the weather on switch-in. Ability weather lasts 5 turns in Sovereign (Champions rules); Primal weather is
  permanent while the Primal is out.
- **Archaludon's Electro Shot** needs rain to fire in one turn, so it pairs with Kyogre.
- **Archaludon's Body Press** deals damage from its Defense, which Stamina raises by one stage each time it's hit.
- **Charizard's Hurricane** drops to 50% accuracy in its own sun (Drought), and never misses in Kyogre's rain.

## Custom AI (to-do)

Taking control of the weather by switching weather setters in and out is central to this team. The fight's AI
(T2, built on the doubles review in 12b) should:
- lead Charizard + Venusaur and Mega Evolve Charizard on turn 1;
- track the current weather and how many turns it has left (ability weather lasts 5 turns in Sovereign), and switch
  in the setter whose weather benefits it when the opponent's weather or a weather timeout would hurt it;
- bring in and keep the synergy pairs together: sun (Charizard + Venusaur), sand (Tyranitar + Garchomp) and rain
  (Kyogre + Archaludon);
- use Protect to scout and to stall out the opponent's weather (Charizard, Venusaur, Garchomp and Kyogre have it);
- play around Tyranitar's Choice Band: it is locked into one move until it switches out, which fits the switching
  this team already does;
- be aware of doubles: spread moves (Heat Wave, Rock Slide, Water Spout, Origin Pulse) and not hitting its partner
  (Garchomp's Stomping Tantrum hits only the target, but Earthquake-style moves would hit the partner).

## To-do

- [x] Charizard's moveset: Hurricane replaced Ancient Power (owner, 2026-10-22).
- [ ] Custom AI (above).
- [x] Trainer name, class and the game's name (see *Naming*).

## Naming (decided 2026-10-22; changed the same day)

- **Game:** Pokémon **Sovereign** Platinum (was "Imperial Platinum"). The ROM header title is `SOVEREIGN PL`, which
  fills the header's 12 characters exactly.
- **Trainer:** class **Sovereign**, name **Henry**. In battle that reads "Sovereign Henry", 15 characters (Platinum's
  longest is "Galactic Boss Cyrus", 19).
  - The name fits an NPC trainer's 7-character limit.
- Earlier names: "Sovereign Dev Twich", then "Sovereign Twich", then **Sovereign Henry** (owner, 2026-10-22). The
  owner dropped "Dev" from the name; the dialogue makes the
  developer reference instead.

## Still open

- Trainer sprite (owner: coming soon), overworld sprite, intro/defeat text (owner writes it).
