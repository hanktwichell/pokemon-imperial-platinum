# Imperial Platinum — Developer final battle (T2)

A hidden, Red-style **double battle** against the mod's developer (the owner), with a custom team and a custom AI
written for this fight. Roadmap item T2; the AI review for doubles is item 12b.

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

## Still open

- Trainer name, class, overworld and battle sprites, and the intro/defeat text.
- Level for the team (suggestion: Lv. 100, as a post-game super-boss).
- Location (suggestion: Mt. Coronet summit, unlocked after the post-game).
