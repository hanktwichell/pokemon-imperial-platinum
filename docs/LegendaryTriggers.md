# Legendary triggers

What makes every legendary, mythical, Ultra Beast and Paradox Pokémon appear in Sovereign Platinum, as the code
stands (CB-0045). The owner asked for this note on 2026-10-23 ("work out what triggers the legendaries to appear").
It was checked against the scripts in `decomp/res/field/scripts/` and the engine code, with the help of a code audit
whose findings are under **Open issues** at the end. The design for each one is `data/postgame_legendaries.yaml`
(rendered as `PostgameLegendaries.md`); the rare wild table is `RareWildEncounters.md`.

## How it works

**Three kinds of encounter** (decision 28, `ProjectStatus.md`):
- **Static:** the Pokémon stands on the map. It shows on entering the map while its condition holds and the Pokédex
  doesn't have it as caught. The shared script (`CommonScript_SovereignLegendaryEncounter`) runs the battle.
  - After a knock-out, a run or a Teleport out, it says "…vanished… It might show itself here again." It's gone
    until the player leaves and comes back.
  - A loss blacks out. Running is allowed, as from any wild battle in Platinum.
- **Roamer:** the Legend Archivist releases it. It moves between the mainland routes (Routes 201–222, Valley
  Windworks, Fuego Ironworks) when the player walks from map to map, and jumps to a random one after Fly. On its
  route, half the wild encounters are it, unless a Repel blocks it.
  - Knocked out: gone. After the next Hall of Fame, the Archivist releases it again the next time the player opens
    its topic.
  - The Pokétch's Marking Map shows every roamer with the same marker.
- **Rare wild:** a share of a map's wild encounters (tall grass, cave floors, surfing), once a gate is met
  (`data/sovereign_rare_wild.yaml`). It can be met again after a catch. There's no roll in a Poké Radar patch, with a
  partner or in the Safari Game.

**The Chronicles** open one at a time. The Legend Archivist stands in Canalave Library 2F from the first Hall of Fame
(`FLAG_GAME_COMPLETED`). Each talk can move `VAR_SOVEREIGN_CHRONICLE` on:

| Value | Chronicle | Opened by a talk once… |
|---|---|---|
| 1 | Unova | the first talk (the topic menu starts from the second) |
| 2 | Kalos | Kyurem is caught |
| 3 | Alola | Xerneas and Yveltal are caught |
| 4 | Galar | Solgaleo or Lunala is caught (Cosmog raised to Lv. 43, then a Sun or Moon Stone) |
| 5 | Paldea | Zacian and Zamazenta are caught |

His menu has a topic for each group, with a hint for every legendary not caught yet. "Caught" always means the
Pokédex's caught entry (`SovereignCheckSpeciesCaught`).

## Unova Chronicle (var 1)

| Pokémon | Kind | Where | Lv. | Appears when | Hint |
|---|---|---|---|---|---|
| Cobalion | static | Iron Island B2F right room (17, 1) | 65 | var ≥ 1 | Swords of Justice |
| Terrakion | static | Route 227, north rock pocket (759, 258) | 65 | var ≥ 1 | Swords of Justice |
| Virizion | static | Eterna Forest (80, 10) | 65 | var ≥ 1 | Swords of Justice |
| Keldeo | static | Lake Valor (36, 14) | 55 | Cobalion, Terrakion and Virizion **in the party** | Swords of Justice (after all three are caught) |
| Victini | static | Vista Lighthouse top floor, west side | 55 | var ≥ 1 | Other legends |
| Meloetta | static | In front of the Contest Hall stage (29, 8) | 55 | `FLAG_SOVEREIGN_MELOETTA_SONG`: the composer in the lobby (8, 7) hears a party Pokémon with Sing | Other legends |
| Genesect | static | Galactic HQ lab, back room (34, 5) | 60 | `FLAG_SOVEREIGN_GENESECT_FREED`: the lab's male scientist confesses (shows at once) | Other legends |
| Reshiram | static | Fuego Ironworks building, furnace pocket | 70 | `ITEM_LIGHT_STONE` in the bag (the Archivist gives both stones) | Truth and Ideals |
| Zekrom | static | Valley Windworks, the island behind the building (Surf) | 70 | `ITEM_DARK_STONE` in the bag, and night (8 pm–4 am) **when entering the map** | Truth and Ideals |
| Kyurem | static | Mt. Coronet's Iceberg Ruins doorway room | 70 | Reshiram and Zekrom caught; no fateful-encounter Regigigas in the party (vanilla's doorway swap) | Truth and Ideals |
| Tornadus, Thundurus | roamers | mainland routes | 65 | released on the first reading of Forces of Nature (`FLAG_SOVEREIGN_RELEASED_FORCES_OF_NATURE`) | Forces of Nature |
| Landorus | static | Route 228 Rock Peak Ruins chamber (7, 5) | 65 | Tornadus and Thundurus **in the party** | Forces of Nature (after both are caught; the Archivist also gives the Reveal Glass) |
| Enamorus | static | Route 224, by the tablet (914, 494) | 65 | Landorus caught | Forces of Nature |

The Archivist gives the DNA Splicers once Kyurem is caught.

## Kalos Chronicle (var 2)

| Pokémon | Kind | Where | Lv. | Appears when | Hint |
|---|---|---|---|---|---|
| Xerneas | static | Eterna Forest | 70 | var ≥ 2 | Life and Destruction |
| Yveltal | static | Lost Tower 5F (13, 14) | 70 | var ≥ 2 | Life and Destruction |
| Zygarde (50%) | static | Wayward Cave B1F, north alcove (21, 4) | 70 | Xerneas and Yveltal caught | Life and Destruction |
| Diancie | static | Oreburgh Mine B2F, west nook (2, 22) | 55 | var ≥ 2 and a **Carbink in the party** | Other legends |
| Hoopa | static | Solaceon Ruins Room 7 | 55 | `ITEM_PRISON_BOTTLE` in the bag (the Archivist gives it) | Other legends |
| Volcanion | static | Stark Mountain room 1 | 60 | var ≥ 2 (on a first visit, the vanilla Team Galactic scene plays first) | Other legends |

Carbink for Diancie: wild outside Stark Mountain, 5%, Lv. 66–68, from the Kalos Chronicle's opening. It's a stopgap
until the planned wild tables (`data/encounters_sovereign.json`) are ported; before CB-0045 no Carbink could be had.

## Alola Chronicle (var 3)

| Pokémon | Kind | Where | Lv. | Appears when | Hint |
|---|---|---|---|---|---|
| Tapu Koko | static | Route 222, east sand strip (808, 795; Rock Smash or Surf) | 65 | var ≥ 3 | Island Guardians |
| Tapu Lele | static | Fullmoon Island grove (13, 12) | 65 | var ≥ 3 | Island Guardians |
| Tapu Bulu | static | Floaroma Meadow, north field | 65 | var ≥ 3 | Island Guardians |
| Tapu Fini | static | Route 226, beach under the cliffs (Surf) | 65 | var ≥ 3 | Island Guardians |
| Cosmog | static | Mt. Coronet's top snowfield (Mt. Coronet outside north, (35, 21)) | 5 | var ≥ 3, until `FLAG_SOVEREIGN_CAUGHT_COSMOG`; a second one once Solgaleo or Lunala is caught, until `_COSMOG_2` | Sun and Moon |
| Necrozma | static | Wayward Cave 1F, dark north-east chamber (70, 9) | 70 | var ≥ 3 and Solgaleo or Lunala caught | Sun and Moon (the Archivist then gives the N-Solarizer and N-Lunarizer) |
| Type: Null | static | Galactic HQ lab (24, 10) | 40 | Genesect caught | Other legends |
| Magearna | static | Sunyshore Gym, Volkner's room (11, 13) | 50 | var ≥ 3 | Other legends |
| Marshadow | static | Old Chateau dining area (21, 9) | 50 | var ≥ 3 | Other legends |
| Zeraora | roamer | mainland routes | 50 | released on the first reading of Other legends (`FLAG_SOVEREIGN_RELEASED_ZERAORA`) | Other legends |
| Meltan | static | Oreburgh Mine B2F (5, 20) | 40 | var ≥ 3 | Other legends |
| Melmetal | static | Oreburgh Mine B2F (5, 24) | 50 | Meltan caught | Other legends |

**Ultra Beasts** (rare wild, 2%, Lv. 65, once Necrozma is caught; hint: Ultra Beasts):

| Pokémon | Maps |
|---|---|
| Nihilego | Iron Island B3F |
| Buzzwole | Route 225 |
| Pheromosa | Route 229 |
| Xurkitree | Route 222 |
| Celesteela | Mt. Coronet outside north |
| Kartana | Eterna Forest |
| Guzzlord | Turnback Cave, the 17 pillar rooms with wild encounters |
| Stakataka | Route 227 |
| Blacephalon | Stark Mountain outside |
| Poipole (Lv. 40) | Route 230 (hint: Other legends) |

## Galar Chronicle (var 4)

| Pokémon | Kind | Where | Lv. | Appears when | Hint |
|---|---|---|---|---|---|
| Zacian | static | Route 210 North, the fog ledge (542, 528) | 70 | var ≥ 4; holds the Rusted Sword (Crowned in battle) | The Hero Legends |
| Zamazenta | static | Route 210 North (540, 528) | 70 | Zacian caught; holds the Rusted Shield | The Hero Legends |
| Eternatus | static | Turnback Cave, Giratina's room (8, 13) | 70 | Zacian and Zamazenta caught | The Hero Legends |
| Calyrex | static | Celestic Town (461, 527) | 70 | var ≥ 4 | King of Harvests (the Archivist then gives the Reins of Unity) |
| Glastrier, Spectrier | roamers | mainland routes | 70 | released once Calyrex is caught, on reading King of Harvests (`FLAG_SOVEREIGN_RELEASED_STEEDS`) | King of Harvests |
| Kubfu | static | Veilstone Gym (13, 17) | 10 | var ≥ 4 | Other legends (the Archivist then gives both Scrolls, once) |
| Zarude | static | Route 212 South, marsh grass | 60 | var ≥ 4 | Other legends |
| Regieleki | static | Valley Windworks building (8, 9) | 65 | var ≥ 4 and Regirock, Regice and Registeel **in the party** | Other legends |
| Regidrago | static | Route 228 Rock Peak Ruins chamber (5, 6) | 65 | var ≥ 4 and Regirock, Regice and Registeel **in the party** | Other legends |

## Paldea Chronicle (var 5)

| Pokémon | Kind | Where | Lv. | Appears when | Hint |
|---|---|---|---|---|---|
| Wo-Chien | static | Route 212 North (464, 788) | 65 | both its stakes pulled out (`FLAG_SOVEREIGN_PULLED_STAKE_1`, `_2`) | Treasures of Ruin |
| Chien-Pao | static | Acuity Lakefront (325, 240) | 65 | stakes 3 and 4 pulled out | Treasures of Ruin |
| Ting-Lu | static | Route 214 (722, 695) | 65 | stakes 5 and 6 pulled out | Treasures of Ruin |
| Chi-Yu | static | Fuego Ironworks outside (180, 593) | 65 | stakes 7 and 8 pulled out | Treasures of Ruin |
| Okidogi, Munkidori, Fezandipiti | roamers | mainland routes | 65 | released on the first reading of The Loyal Three (`FLAG_SOVEREIGN_RELEASED_LOYAL_THREE`) | The Loyal Three |
| Pecharunt | static | Route 224 (898, 526) | 60 | the Loyal Three caught | The Loyal Three |
| Ogerpon | static | Route 211 East (435, 531) | 65 | var ≥ 5; holds the Teal Mask | The Masked Ogre (the Celestic Pokéfan gives the other masks to a player leading with Ogerpon) |
| Koraidon, Miraidon | static | Sendoff Spring (29, 36), (27, 37) | 70 | all twenty Paradox Pokémon caught | Area Zero |
| Terapagos | static | Sendoff Spring (30, 34) | 70 | Koraidon and Miraidon caught | Area Zero |

The stakes stand next to their shrine for now and show while the Paldea Chronicle is open.

**Paradox Pokémon** (rare wild, 2%, from the Paldea Chronicle's opening; hint: Paradox Pokémon):

| Pokémon | Maps | Lv. |
|---|---|---|
| Great Tusk | Route 207 | 65 |
| Scream Tail | Trophy Garden | 65 |
| Brute Bonnet | Route 212 South | 65 |
| Flutter Mane | Lost Tower 1F–5F | 65 |
| Slither Wing | Stark Mountain outside | 65 |
| Sandy Shocks | Route 228 | 65 |
| Roaring Moon | Route 210 North | 68 |
| Walking Wake | Route 213 (surfing) | 68 |
| Gouging Fire | Route 211 East | 68 |
| Raging Bolt | Route 208 | 68 |
| Iron Treads | Oreburgh Mine B1F, B2F | 65 |
| Iron Bundle | Route 217 | 65 |
| Iron Hands | Valley Windworks outside | 65 |
| Iron Jugulis | Route 222 | 65 |
| Iron Moth | Fuego Ironworks outside | 65 |
| Iron Thorns | Route 206 | 65 |
| Iron Valiant | Route 212 North | 68 |
| Iron Leaves | Eterna Forest | 68 |
| Iron Boulder | Route 227 | 68 |
| Iron Crown | Iron Island B2F (both rooms) | 68 |

## Vanilla Platinum legendaries (unchanged except where noted)

| Pokémon | Kind | Where | Lv. | Appears when | Gone when / comes back |
|---|---|---|---|---|---|
| Uxie, Azelf | static | Acuity Cavern, Valor Cavern | 50 | after the Distortion World (Rowan's lab) | knocked out or run from: hidden until the next Hall of Fame |
| Mesprit | roamer | released in Verity Cavern | 50 | after the Distortion World | knocked out: the Hall of Fame puts it back in the cavern |
| Dialga, Palkia | static (rift) | Spear Pillar's Dialga and Palkia maps | 70 | post-game, `FLAG_UNLOCKED_DIALGA_PALKIA_SPEAR_PILLAR` (the Celestic elder), the Adamant or Lustrous Orb carried | the Hall of Fame resets a missed one. Spear Pillar itself has no Chronicle encounter (decision 27) |
| Giratina | static | Distortion World (story); then Turnback Cave's Giratina room | 47 | story; Turnback Cave if it wasn't caught | the Hall of Fame |
| Heatran | static | Stark Mountain room 3 | 50 | post-game, talked to Buck at the Battleground, room state 1 | the Hall of Fame |
| Regigigas | static | Snowpoint Temple B5F | 1 | Regirock, Regice and Registeel in the party | the Hall of Fame |
| Regirock, Regice, Registeel | static | Rock Peak, Iceberg and Iron Ruins | 30 | post-game and a fateful-encounter Regigigas in the party | — |
| Cresselia | roamer | released on Fullmoon Island | 50 | after the Lunar Wing quest | the Hall of Fame |
| Articuno, Zapdos, Moltres | roamers | released by Professor Oak in Eterna City's south house | 60 | post-game | Oak re-releases after a Hall of Fame |
| Darkrai | static | Newmoon Island | 50 | Member Card and the distribution | — |
| Shaymin | static | Flower Paradise | 30 | Oak's Letter and the distribution | — |
| Arceus | static | Hall of Origin | 80 | Azure Flute and the distribution | — |
| Rotom | static | Old Chateau, the TV room | 20 | night | — |

Darkrai, Shaymin and Arceus need vanilla's distribution events, so they can't be met in normal play yet.

## Renegade Platinum's events (documented, not ported: E10)

`RenegadePlatinumV130/Documentation/SpecialEvents.txt` changes or adds these. When E10 ports them, check their spots
against the Chronicles':

| Pokémon | Renegade's place | Lv. | Chronicle encounter nearby |
|---|---|---|---|
| Articuno | Mt. Coronet summit portal (Rock Climb) | 60 | Cosmog's snowfield (35, 21) and the Celesteela rare roll |
| Zapdos | Valley Windworks, the island behind the building | 60 | **Zekrom stands on that island** |
| Moltres | Victory Road, a small room | 60 | — |
| Mewtwo | Oreburgh Gate basement portal | 70 | — |
| Mew | Route 201, after a chain of berry quests | 40 | — |
| Raikou, Entei, Suicune | Routes 208, 211 East and 213 portals | 60 | Raging Bolt, Gouging Fire and Walking Wake rare rolls (by design) |
| Lugia, Ho-Oh | Route 220 island; Lost Tower top floor | 70 | **Yveltal stands on Lost Tower 5F** |
| Celebi | Eterna Forest portals | 40 | **Virizion and Xerneas stand in Eterna Forest** |
| Regirock, Regice, Registeel | Route 228, Mt. Coronet (Route 216 side), Iron Island B3F | 60 | Landorus and Regidrago share the Route 228 chamber; Nihilego's rare roll on Iron Island B3F |
| Latias, Latios | Fullmoon Island clearing | 68 | Tapu Lele (13, 12) |
| Kyogre, Groudon, Rayquaza | Mt. Coronet B1F, Stark Mountain room 1, the League waterfall | 70 | **Volcanion stands in Stark Mountain room 1** |
| Jirachi | Solaceon Ruins | 40 | Hoopa (Room 7) |
| Deoxys | Veilstone City | 70 | — |
| Uxie, Mesprit, Azelf | their caverns, static, until caught | 60 | — |
| Heatran, Regigigas, Cresselia, Darkrai | until caught | 68–70 | — |
| Shaymin | Flower Paradise, near Route 224's tablet | 30 | Enamorus, Pecharunt (Route 224) |
| Giratina | Turnback Cave after the credits | 70 | Eternatus shares the room |
| Arceus | Azure Flute from Hearthome's Foreign Building | 80 | — |

## Open issues

Found by the audit and still open (the CB-0045 fixes are in `EngineChangelog.md`):
- **Cosmog can flee.** At Lv. 5 it knows only Splash and Teleport, and a wild Teleport ends the battle about half the
  time it's picked. It then vanishes until the next visit. A trapping move or ability, or a quick catch, gets around
  it.
- **Rapid Strike Urshifu and Ultra Necrozma** wait on milestone FM: the Scroll of Waters does nothing yet, and the
  Ultranecrozium Z isn't given anywhere.
- **Roamers come back only through the Archivist** after a Hall of Fame. A player who doesn't reopen the topic sees
  nothing return. The RoamerGone line now says so.
- **Gates read the Pokédex,** so a legendary caught another way (a trade) can open the next one early, and a traded
  Reshiram skips the Light and Dark Stones (then Zekrom can't appear).
- **Virizion stands on the only tile facing Eterna Forest's hidden Insect Plate** (80, 9). The player can still take
  it after battling Virizion, before leaving.
- **Meloetta** is inside the lobby Beauty's wander area. She can stand on the tile east of it; the other two sides
  stay open.
- **Poipole is Lv. 40,** below Route 230's own Pokémon, so a Repel with a stronger lead hides it.
- **The Area Zero topic** says "Koraidon and Miraidon have come" while either is still uncaught.
- **The Marking Map and the TV news flash** can't tell the 13 roamers apart (vanilla behaviour).
