# Imperial Platinum — Developer final battle (T2)

A hidden, Red-style **double battle** against the mod's developer (the owner), with a custom team and a custom AI
written for this fight. Roadmap item T2; the AI review for doubles is item 12b.

- **Trainer:** working name "Royal Dev Twich". The owner wants the game's name and the trainer class to share a theme,
  so both are still open (see *Naming* below).
- **Location:** Spear Pillar, at the summit of Mt. Coronet (post-game).
- **Level:** 100 for the whole team.
- **Leads:** always Charizard (Mega Y) and Venusaur.
- **Concept:** a triple-weather team built as three synergy pairs:
  - **Sun:** Charizard-Y + Venusaur (Drought powers Chlorophyll, Weather Ball and Heat Wave).
  - **Sand:** Tyranitar + Garchomp.
  - **Rain:** Kyogre + Archaludon (rain makes Electro Shot fire in one turn).

## Team (owner, 2026-10-22)

| # | Pokémon | Item | Ability | Nature | EVs | IVs | Moves | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | Charizard ♂ | Charizardite Y | Blaze (Mega: Drought) | Modest | 252 SpA / 4 SpD / 252 Spe | 0 Atk | Weather Ball, Heat Wave, Ancient Power, Protect | Mega Evolves |
| 2 | Venusaur ♀ | Focus Sash | Chlorophyll | Modest | 4 HP / 252 SpA / 252 Spe | 0 Atk | Sleep Powder, Leaf Storm, Sludge Bomb, Protect | |
| 3 | Tyranitar ♂ | Assault Vest | Sand Stream | Adamant | 252 HP / 252 Atk / 4 SpD | — | Rock Slide, Crunch, Low Kick, Protect | |
| 4 | Garchomp ♂ (shiny) | Life Orb | Rough Skin | Jolly | 4 HP / 252 Atk / 252 Spe | — | Dragon Claw, Stomping Tantrum, Fire Fang, Protect | |
| 5 | Kyogre | Blue Orb | Drizzle (Primal: Primordial Sea) | Modest | 252 HP / 252 SpA / 4 SpD | 0 Atk | Water Spout, Origin Pulse, Ice Beam, Protect | Primal Reversion |
| 6 | Archaludon ♂ (shiny) | Leftovers | Stamina | Calm | 48 HP / 156 Def / 172 SpA / 80 SpD / 52 Spe | 0 Atk | Electro Shot, Dragon Pulse, Flash Cannon, Protect | |

Unlisted IVs are 31. Every EV spread is within 252 per stat / 510 total. The Tera Types in the owner's set are
recorded but unused (Imperial has no Terastallization).

## What the engine needs before this fight works as written

| Need | Milestone | Status |
|---|---|---|
| Per-mon nature, ability, EVs, IVs, held item, gender and shininess in trainer data | E9 | the trainer format will carry these |
| Archaludon (#1018) | E6 step 2 | species being added now |
| Charizardite Y, Blue Orb, Assault Vest | E7 | Life Orb, Focus Sash and Leftovers exist already |
| Mega Evolution (Charizard Y) and Primal Reversion (Kyogre) | E8 | |
| Stamina, Primordial Sea, Drought (on Mega Charizard Y) | E8 / item 11 | Stamina and Primordial Sea have no battle effect yet |
| Electro Shot (charge turn, skipped in rain) and Stomping Tantrum (double power after a failed move) | item 11 | both are plain hits for now; Origin Pulse is exact |
| Custom AI for this fight, and doubles awareness | T2 / 12b | |

## Interactions worth knowing (owner's call; nothing changed)

- **Primal Kyogre's Primordial Sea vs Charizard:** while Primal Kyogre is on the field, Fire moves fail (Heat Wave;
  Weather Ball turns Water-type). Mega Charizard Y's Drought can't replace it.
- **Weather turnover:** Drought (Charizard Y), Sand Stream (Tyranitar) and Drizzle/Primordial Sea (Kyogre) all
  change the weather on switch-in. Ability weather lasts 5 turns in Imperial (Champions rules); Primal weather is
  permanent while the Primal is out.
- **Archaludon's Electro Shot** needs rain to fire in one turn, so it pairs with Kyogre.

## Custom AI (to-do)

Taking control of the weather by switching weather setters in and out is central to this team. The fight's AI
(T2, built on the doubles review in 12b) should:
- lead Charizard + Venusaur and Mega Evolve Charizard on turn 1;
- track the current weather and how many turns it has left (ability weather lasts 5 turns in Imperial), and switch
  in the setter whose weather benefits it when the opponent's weather or a weather timeout would hurt it;
- bring in and keep the synergy pairs together: sun (Charizard + Venusaur), sand (Tyranitar + Garchomp) and rain
  (Kyogre + Archaludon);
- use Protect to scout and to stall out the opponent's weather;
- be aware of doubles: spread moves (Heat Wave, Rock Slide, Water Spout, Origin Pulse) and not hitting its partner
  (Garchomp's Stomping Tantrum hits only the target, but Earthquake-style moves would hit the partner).

## To-do

- [ ] Owner may adjust Charizard's moveset.
- [ ] Custom AI (above).
- [ ] Trainer name, class and the game's name (see *Naming*).

## Naming

The owner wants the game title and Twich's trainer class to share a theme. Suggestions (title / class / full name):

| Title | Class | In battle |
|---|---|---|
| Pokémon Imperial Platinum | Emperor | Emperor Twich |
| Pokémon Sovereign Platinum | Sovereign | Sovereign Twich |
| Pokémon Regal Platinum | Regent | Regent Twich |
| Pokémon Monarch Platinum | Monarch | Monarch Twich |
| Pokémon Dynasty Platinum | Dynast | Dynast Twich |
| Pokémon Crown Platinum | Crowned King | Crowned King Twich |

Trainer class names should stay short (about 12 characters) to fit the battle text.

## Still open

- Trainer sprite (owner: coming soon), overworld sprite, intro/defeat text.
- Trainer name and class, and the game's name (see *Naming*).
