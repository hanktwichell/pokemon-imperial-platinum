# Sovereign Platinum — Gift Pokémon

Renegade Platinum's gifts are all unchanged (see `RenegadePlatinumV130/Documentation/SpecialEvents.txt`). That includes
the Sinnoh starters, Twinleaf Eevee, the fossils, Porygon (a Poké Ball behind Jupiter in the Eterna Galactic Building,
Lv. 22), Beldum (Steven, Oreburgh City's south house, Lv. 10), Lapras, the Jubilife School Egg, and the Kanto, Johto
and Hoenn starters from the Pokémon Center Interviewers.

## Renegade's gifts built in E10 part 35

These four were in Renegade but not yet in Sovereign until part 35:

| Gift | Where | Level | Notes |
|---|---|---|---|
| Lapras (NeverMeltIce) | Pastoria City, north house: the socialite | 35 | She tells of her days at sea, then entrusts it (story skippable on a second talk) |
| Eevee | Twinleaf Town, the player's house: the Poké Ball by the window | 5 | Mom suggests it once she has given the Journal; before then it's hers to look after |
| The other two Sinnoh starters | Sandgem Town, Rowan's lab: the briefcase | 5 | Rowan lets the player take both; the party needs room for two |
| An evolution stone | Oreburgh Mine B2F: Roark, after his Rock Smash demo | — | The stone the player names (Water, Thunder, Fire, Sun, Moon, Leaf or Ice); "Don't know" gets a random one |

## New: starters from the other regions

Renegade gives each earlier region's starters through the **Interviewer** in a Pokémon Center. Sovereign Platinum
extends that pattern to Gen V–IX: same NPC, same quiz-and-battle event, same "talk again if your party fills up"
behaviour. The starter lines are **not** wild encounters.

| Region | Pokémon | Pokémon Center | Level | Available |
|---|---|---|---|---|
| Kanto *(Renegade)* | Bulbasaur, Charmander, Squirtle | Jubilife City | 5 | Start |
| Hoenn *(Renegade)* | Treecko, Torchic, Mudkip | Oreburgh City | 10 | Start |
| Johto *(Renegade)* | Chikorita, Cyndaquil, Totodile | Floaroma Town | 15 | Start |
| **Unova** | Snivy, Tepig, Oshawott | Eterna City | 20 | After the Forest Badge |
| **Kalos** | Chespin, Fennekin, Froakie | Hearthome City | 25 | After the Relic Badge |
| **Alola** | Rowlet, Litten, Popplio | Veilstone City | 30 | After the Cobble Badge |
| **Galar** | Grookey, Scorbunny, Sobble | Pastoria City | 35 | After the Fen Badge |
| **Paldea** | Sprigatito, Fuecoco, Quaxly | Canalave City | 40 | After the Mine Badge |

Notes (built in E10 part 32)
- Each Interviewer is a reporter at (3, 4) in the Pokémon Center, with a cameraman at (2, 4). Renegade's save-fixing NPC
  isn't in Sovereign, so every Pokémon Center uses the same spot.
- The quiz has five questions, the last being a battle against the prize: the region's three starters at the gift level,
  as in Renegade.
  - Kanto, Hoenn and Johto keep Renegade's questions and lines. Johto's bored reporter skips to the battle after three.
  - Unova–Paldea get four questions about their region, then the battle.
  - A wrong answer ends the quiz, and the player can try again. A loss blacks out.
- The later five Interviewers tell the player to come back with the badge until they have it.
- Like Renegade's starters, these carry a type-boosting held item: Miracle Seed (Grass), Charcoal (Fire), Mystic Water (Water).
- The prize needs room for all three in the party. Renegade hands them over one at a time instead, which needs more
  save flags than Sovereign has left.
- The win is the Interviewer's trainer flag. One flag per Interviewer (`FLAG_SOVEREIGN_INTERVIEWER_*_DONE`) hides the
  pair once the prize is given.

## Fight Area Pokémon Center (post-game, temporary placements)

- **Battle Bond Greninja** (Lv. 50, with Water Shuriken, Aerial Ace, Double Team, Night Slash) from an Ace Trainer,
  once (owner, 2026-10-24).
- **Event forms** from the event-gift deliveryman, each once (owner rule: every form exists):

| Pokémon | Lv. | Signature move |
|---|---|---|
| Own Tempo Rockruff | 10 | — |
| Eternal Floette | 50 | Light of Ruin |
| Bloodmoon Ursaluna | 70 | Blood Moon |
| Roaming Gimmighoul | 20 | — |
| Partner Pikachu, Partner Eevee | 5 | Zippy Zap, Veevee Volley |
| Cosplay Pikachu | 20 | — |
| Pikachu Rock Star, Belle, Pop Star, Ph.D., Libre | 20 | Meteor Mash, Icicle Crash, Draining Kiss, Electric Terrain, Flying Press |
| Original, Hoenn, Sinnoh, Unova, Kalos, Alola, Partner and World Cap Pikachu | 25 | — |
| Spiky-eared Pichu | 30 | — |

  Magearna and Zarude are Mythical, so the deliveryman doesn't give them. He restyles a caught one into Original Color
  Magearna or Dada Zarude instead.

## No legendary gifts

Legendaries, Mythicals and Ultra Beasts are never gifts: the player battles and catches every one (owner, 2026-10-23).
The post-game ones the plan once listed as gifts (Cosmog, Type: Null, Poipole, Magearna, Meltan and Melmetal, Kubfu)
are battles at the same places; see `PostgameLegendaries.md` and `LegendaryTriggers.md`.
