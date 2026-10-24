# Sovereign Platinum — Item Changes

Renegade Platinum's item changes and item locations are unchanged unless listed here
(`RenegadePlatinumV130/Documentation/ItemChanges.txt`).

In the game so far (E10 part 2): Renegade's six TM moves (Scald, Wild Charge, Bug Buzz, Hyper Voice, Dazzling Gleam,
Hurricane), TMs as 99 of each and unsellable, and the Poké/Great/Ultra Ball prices. Renegade's item and TM locations
come next.

## New key items

| Item | Where | Purpose |
|---|---|---|
| Mega Ring | Leader Fantina, Hearthome Gym (with the Relic Badge) | Enables Mega Evolution |
| Light Stone, Dark Stone | Legend Archivist, Canalave Library (post-game, with the Unova Chronicle) | Carried, they wake Reshiram (Fuego Ironworks) and Zekrom (Valley Windworks, at night) |
| Prison Bottle | Legend Archivist, Canalave Library, in the Kalos Chronicle (Other legends) | Hoopa event (Hoopa appears in the Solaceon Ruins while the player carries it); used on Hoopa from the bag, switches it between Hoopa Confined and Hoopa Unbound |
| Scroll of Darkness, Scroll of Waters | Legend Archivist, Canalave Library, once Kubfu is caught (the plan had Maylene) | Evolve Kubfu |
| Infinite Repel | Not placed yet (QoL #3 says Professor Rowan's aide, after the Coal Badge) | Toggles a Repel that never runs out |

## Form items

| Item | Where | Purpose |
|---|---|---|
| Rusted Sword | Held by the wild Zacian (post-game, Route 210 North) | Zacian's Crowned Sword form |
| Rusted Shield | Held by the wild Zamazenta (post-game, Route 210 North) | Zamazenta's Crowned Shield form |
| Teal Mask | Held by the wild Ogerpon (post-game, Route 211 East) | Ogerpon's Teal Mask form |
| Wellspring Mask, Hearthflame Mask, Cornerstone Mask | The Pokéfan (male) in **Celestic Town's northeast house** (`CelesticTownNortheastHouse_PokefanM`). He gives all three if Ogerpon is at the front of the party | Ogerpon's mask forms |
| Adamant Crystal, Lustrous Globe, Griseous Core | Not placed yet | Held: Origin Dialga, Palkia, Giratina |
| Reveal Glass (key item) | Legend Archivist, Canalave Library, once Tornadus and Thundurus are caught | Used on Tornadus, Thundurus, Landorus or Enamorus from the bag: Incarnate ↔ Therian Forme |
| DNA Splicers (key item) | Legend Archivist, Canalave Library, once Kyurem is caught | Used from the bag on Kyurem or on Reshiram/Zekrom: fuses them (White/Black Kyurem); used on the fused Kyurem: separates them |
| N-Solarizer, N-Lunarizer (key items) | Legend Archivist, Canalave Library, once Necrozma is caught | The same for Necrozma and Solgaleo (Dusk Mane) or Lunala (Dawn Wings) |
| Reins of Unity (key item) | Legend Archivist, Canalave Library, once Calyrex is caught | The same for Calyrex and Glastrier (Ice Rider) or Spectrier (Shadow Rider) |

## New held / evolution items

- **95 Mega Stones and Primal orbs**: full list, field locations and vendors in `MegaEvolution.md`.
- **16 evolution items** (Tart/Sweet/Syrupy Apple, Cracked Pot, Unremarkable Teacup, Sachet, Whipped Dream, Strawberry
  Sweet, Black Augurite, Peat Block, Leader's Crest, Auspicious/Malicious Armor, Metal Alloy, Scrolls): `EvolutionChanges_Sovereign.md`.

## Field items replaced

15 low-value pickups (Potions, status heals, Poké/Great Balls, Repels, Escape Ropes) become Mega Stones. TMs,
evolution stones and held items are never replaced. Full table with map and script names: `MegaEvolution.md` →
"Mega Stones hidden in the field".

## New shops

| Shop | Where | Opens | Sells |
|---|---|---|---|
| Mega Stone Collector | Hearthome City, Bebe's house | Relic Badge | 29 Mega Stones |
| Mega Stone Trader | Pastoria City, northeast house | Fen Badge | 30 Mega Stones |
| Mega Stone Sage | Snowpoint City, west house | Icicle Badge | 8 Mega Stones |
| Mega Stone Curator | Survival Area, south house | Champion | 10 legendary/signature Mega Stones (₽30,000) |
| Evolution item seller *(Renegade)* | Snowpoint City | — | adds the 14 new evolution items sold in shops |
| Veilstone Dept. Store, 2F vitamin clerk | Veilstone City | — | Menu: Vitamins / **Held items** (the 38 Gen V–IX held items) / **Gems** (all 18). Owner request. Booster Energy ₽10,000 (no official price) |

## After the Champion

Owner decision 24 (`ProjectStatus.md`):

- Every shop that takes money sells at **half price**. Battle Point shops are unchanged.
- Items **no shop sells** (Nuggets, Pearls, shards, found items) **sell for their full price**. Items a shop sells
  still sell for half, so they can't be bought and resold for a profit.
- The **Youngster at the Survival Area** gives **3 Nuggets** once a day.
- Post-game rematches (Elite Four, Cynthia, Gym Leaders, Battleground trainers) pay **3× prize money**.
