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
| Meloetta | static | In front of the Contest Hall stage (27, 8) | 55 | `FLAG_SOVEREIGN_MELOETTA_SONG`: the composer in the lobby (8, 7) hears a party Pokémon with Sing | Other legends |
| Genesect | static | Galactic HQ lab, back room (34, 5) | 60 | `FLAG_SOVEREIGN_GENESECT_FREED`: the lab's male scientist confesses (shows at once) | Other legends |
| Reshiram | static | Fuego Ironworks building, furnace pocket | 70 | `ITEM_LIGHT_STONE` in the bag (the Archivist gives both stones) | Truth and Ideals |
| Zekrom | static | Route 215, the north-west loop by the big tree (590, 578) (decision 34; it stood on Valley Windworks' island before) | 70 | `ITEM_DARK_STONE` in the bag, and night (8 pm–4 am) **when entering the map** | Truth and Ideals |
| Kyurem | static | Mt. Coronet's Iceberg Ruins doorway room | 70 | Reshiram and Zekrom caught; no Relicanth and Wailord pair in the party (that pair swaps the doorway to the Iceberg Ruins, part 13) | Truth and Ideals |
| Tornadus, Thundurus | roamers | mainland routes | 65 | released on the first reading of Forces of Nature (`FLAG_SOVEREIGN_RELEASED_FORCES_OF_NATURE`) | Forces of Nature |
| Landorus | static | Route 228, north end of the first sand field (782, 323) | 65 | Tornadus and Thundurus **in the party** | Forces of Nature (after both are caught; the Archivist also gives the Reveal Glass) |
| Enamorus | static | Route 224, the beach field (912, 535) | 65 | Landorus caught | Forces of Nature |

The Archivist gives the DNA Splicers once Kyurem is caught.

## Kalos Chronicle (var 2)

| Pokémon | Kind | Where | Lv. | Appears when | Hint |
|---|---|---|---|---|---|
| Xerneas | static | Eterna Forest | 70 | var ≥ 2 | Life and Destruction |
| Yveltal | static | Route 229, the nook behind the Cut tree (813, 426) | 70 | var ≥ 2 | Life and Destruction |
| Zygarde (50%) | static | Wayward Cave B1F, north-west alcove (12, 4) | 70 | Xerneas and Yveltal caught | Life and Destruction |
| Diancie | static | Oreburgh Mine B2F, west nook (2, 22) | 55 | var ≥ 2 and a **Carbink in the party** | Other legends |
| Hoopa | static | Solaceon Ruins Room 6, north-west dead end (2, 3) | 55 | `ITEM_PRISON_BOTTLE` in the bag (the Archivist gives it) | Other legends |
| Volcanion | static | Stark Mountain room 2, the north-east dead-end tunnel (73, 15) | 60 | var ≥ 2 | Other legends |

Carbink for Diancie: wild outside Stark Mountain, 5%, Lv. 66–68, from the Kalos Chronicle's opening. It's a stopgap
until the planned wild tables (`data/encounters_sovereign.json`) are ported; before CB-0045 no Carbink could be had.

## Alola Chronicle (var 3)

| Pokémon | Kind | Where | Lv. | Appears when | Hint |
|---|---|---|---|---|---|
| Tapu Koko | static | Route 222, east end of the sand strip (813, 795; Rock Smash or Surf) | 65 | var ≥ 3 | Island Guardians |
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
| Eternatus | static | Victory Road B1F, the TM59 island (Surf) (14, 19) | 70 | Zacian and Zamazenta caught | The Hero Legends |
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
| Koraidon | static | Sendoff Spring (29, 36) | 70 | var ≥ 5 and all ten ancient (past) Paradox Pokémon given by the museum's fossil maniac (decision 30; the dealer then mentions Sendoff Spring) | Area Zero |
| Miraidon | static | Sendoff Spring (27, 37) | 70 | var ≥ 5 and all ten future Paradox Pokémon given by the museum's futuristic scientist (decision 30; the dealer then mentions Sendoff Spring) | Area Zero |
| Terapagos | static | Sendoff Spring (30, 34) | 70 | Koraidon and Miraidon caught | Area Zero |

The stakes stand next to their shrine for now and show while the Paldea Chronicle is open.

**Paradox Pokémon** (owner, 2026-10-24; they were rare wild encounters until CB-0062): gifts from two dealers in the
Oreburgh Mining Museum, a fossil maniac (11, 11) for the ancient ones and a futuristic scientist (13, 11) for the future
ones. Both show once the player has all 8 badges (`FLAG_SOVEREIGN_HIDE_PARADOX_DEALERS`, cleared on entry). Showing a
dealer a present-day Pokémon gives its Paradox Pokémon at the shown Pokémon's level, once each:

| Present-day | Ancient (fossil maniac) | Future (futuristic scientist) |
|---|---|---|
| Donphan | Great Tusk | Iron Treads |
| Jigglypuff | Scream Tail | — |
| Amoonguss | Brute Bonnet | — |
| Misdreavus | Flutter Mane | — |
| Volcarona | Slither Wing | Iron Moth |
| Magneton | Sandy Shocks | — |
| Salamence | Roaring Moon | — |
| Suicune | Walking Wake | — |
| Entei | Gouging Fire | — |
| Raikou | Raging Bolt | — |
| Delibird | — | Iron Bundle |
| Hariyama | — | Iron Hands |
| Hydreigon | — | Iron Jugulis |
| Tyranitar | — | Iron Thorns |
| Gardevoir or Gallade | — | Iron Valiant |
| Virizion | — | Iron Leaves |
| Terrakion | — | Iron Boulder |
| Cobalion | — | Iron Crown |

## Vanilla Platinum legendaries (unchanged except where noted)

| Pokémon | Kind | Where | Lv. | Appears when | Gone when / comes back |
|---|---|---|---|---|---|
| Uxie, Mesprit, Azelf | static | Acuity, Verity and Valor Caverns | 60 (Renegade's; vanilla 50) | after the Distortion World (Rowan's lab) | caught; knocked out or run from, it's back on the next visit (Renegade's rule). Mesprit no longer roams |
| Dialga, Palkia | static (rift) | Spear Pillar's Dialga and Palkia maps | 70 | post-game, `FLAG_UNLOCKED_DIALGA_PALKIA_SPEAR_PILLAR` (the Celestic elder), the Adamant or Lustrous Orb carried | the Hall of Fame resets a missed one. Spear Pillar itself has no Chronicle encounter (decision 27) |
| Giratina | static | Distortion World (story); then Turnback Cave's Giratina room | 47; Turnback Cave 70 (Renegade's) | story; Turnback Cave if it wasn't caught | the Hall of Fame |
| Heatran | static | Stark Mountain room 3 | 68 (Renegade's; vanilla 50) | post-game, the Battleground's welcome (E10 part 31: Buck has already left on his Route 227 patrol, so the receptionist's greeting sets his flags), room state 1 | the Hall of Fame. The catch leaves the Magma Stone behind, which the player takes for Steven (E10 part 40) |
| Regigigas | static | Snowpoint Temple B5F | 70 (Renegade's; vanilla 1) | after the Hall of Fame, with Regirock, Regice and Registeel in the party (E10 part 26: the temple now opens before the Snowpoint Gym, for Renegade's story scene where Candice and Maylene put it back to sleep; decision 29) | the Hall of Fame |
| Cresselia | static | Fullmoon Island's clearing (16, 15) | 68 (Renegade's; vanilla 50, a roamer) | after the Lunar Wing quest | caught; it's back on the next visit until then. The catch leaves the Lunar Wing where it stood |
| Articuno, Zapdos, Moltres | no longer roam (E10 part 27, decision 33) | they stand where Renegade put its portals; see Renegade's events below. Professor Oak in Eterna City's south house now only hints at the places with the Up-Grade, and praises the catch as before | — | — | — |
| Darkrai | static | Newmoon Island Forest | 68 (Renegade's; vanilla 50) | post-game, with the National Dex and the Canalave boy woken, and the Member Card from the woman in Route 217's north-east house (the Lunar Wing wakes her; E10 part 36). The Harbor Inn's dream then takes the player to Newmoon Island. No distribution | caught; until then the dream can be repeated (vanilla's reset on waking) |
| Shaymin | static | Flower Paradise | 30 | post-game: once the counterpart has been beaten by Route 224's tablet (E10 part 30), Oak in Eterna City's south house gives Oak's Letter (E10 part 37). On Route 224 Marley's scene plays, then Oak's tablet scene opens the Seabreak Path. No distribution | caught; until then it's back on the next visit |
| Arceus | static | Hall of Origin | 80 | post-game: with all sixteen Type Masters' Plates (E10 part 20), the elder in Hearthome's Foreign Building gives the Azure Flute (E10 part 38; no Pokédex task, decision 44). Played at Spear Pillar, it opens the Hall of Origin. No distribution | — |
| Rotom | static | Old Chateau, the TV room | 20 | any time of day (Renegade's, E10 part 41; vanilla: night) | none: it can be battled and caught again and again (Renegade's) |

## Renegade Platinum's events, ported (E10)

| Pokémon | Kind | Where | Lv. | Appears when | Gone when / comes back |
|---|---|---|---|---|---|
| Raikou | static | Route 208, the Rock Climb ledge west of the Berry Master's house (391, 717) | 60 | after the Distortion World (Cyrus beaten there) | caught. A win or a run makes it vanish until the next visit |
| Entei | static | Route 211 East, the end of the Rock Climb ledge (424, 514), where Platinum had TM29 | 60 | after the Distortion World | as Raikou |
| Suicune | static | Route 213, the Rock Climb ledge (689, 826); the TM05 ball moved to (651, 824), as in Renegade | 60 | after the Distortion World | as Raikou |
| Articuno | static | Mt. Coronet's top snowfield (33, 20), two tiles from Cosmog's (35, 21); Renegade's portal was at (35, 20) | 60 | after the Distortion World | as Raikou |
| Zapdos | static | Valley Windworks, the small island behind the building (241, 644), beside the TM24 ball (Surf); Renegade's portal stood on the ball's tile (Renegade moved TM24) | 60 | after the Distortion World | as Raikou |
| Moltres | static | Victory Road 2F, the small room past the Strength boulders (20, 3), clear of the tiles the boulder puzzle needs; Renegade's portal was at (18, 3), where Sovereign keeps a boulder | 60 | after the Distortion World | as Raikou |
| Celebi | static | Eterna Forest, near the middle of the forest (70, 58) | 40 | Renegade's chain: take the GS Ball from Celestic Town's shrine, then walk into Eterna Forest from the Eterna City side (x = 78); the ball shakes, Celebi peeks out, and eight time portals open around the forest. Each holds the memory of a battle with a Johto Gym Leader (Falkner, Bugsy, Whitney, Morty, Chuck, Jasmine, Pryce, Clair: Renegade's trainers 1029–1036, one Lv. 45 Pokémon each) and closes once beaten. With all eight beaten, Celebi appears. Renegade puts it in a ninth portal; Sovereign shows the Pokémon | caught; a win or a run makes it vanish until the next visit |
| Lugia | static | Route 220, the sandbar island at the bottom of the route (190, 921), Surf | 70 | after the Hall of Fame, carrying the Silver Wing. Professor Oak (Eterna City's south house) gives it once he has praised the three birds and they're all in the party: Renegade's QUESTS, his Clear Wing turns silver | caught; a win or a run makes it vanish until the next visit |
| Ho-Oh | static | Lost Tower 5F, below the old women's graves (7, 12) | 70 | after the Hall of Fame, carrying the Rainbow Wing. Oak's other Clear Wing turns into it once the player has the Silver Wing and brings Raikou, Entei and Suicune in the party | as Lugia |

| Regirock, Regice, Registeel | static | Rock Peak (Route 228), Iceberg (Mt. Coronet, Route 216 side) and Iron (Iron Island B3F) Ruins | 60 | after the Distortion World, with a Relicanth and a Wailord in the party: the doorway opens to the chamber, then the dots and the statue as in vanilla (no Champion check) | caught |
| Latias, Latios | rock | Fullmoon Island's clearing, where Cresselia stood (16, 15) | 68 | Cresselia caught and the Lunar Wing taken; read from below with the Soul Dew and pick red (Latias) or blue (Latios) | caught; either can be fought again until then |
| Kyogre | static | Mt. Coronet B1F, the island in the lake (22, 36); the Light Clay ball moved to (12, 12) | 70 | after the Hall of Fame, once Steven has given the Orbs | caught |
| Groudon | static | Stark Mountain room 1, left of the steps to the next room (6, 6); the Full Heal ball moved to (12, 3) | 70 | as Kyogre | caught |
| Rayquaza | static | Pokémon League, the strip of land below the waterfall (847, 572) | 70 | as Kyogre (Renegade's Jade Orb isn't in Sovereign) | caught |
| Mewtwo | static | Oreburgh Gate B1F, the north-west pocket beside the TM01 ball (7, 9), past the Rock Smash rock and Strength boulder | 70 | after the Hall of Fame | caught |
| Uxie, Mesprit, Azelf; Cresselia; Heatran; Turnback Giratina | static | their vanilla spots | 60; 68; 68; 70 | as in vanilla | the lake trio and Cresselia come back each visit until caught; Heatran and Giratina still come back after a Hall of Fame, as in vanilla (see the vanilla table) |
| Jirachi | static (asleep) | Solaceon Ruins room 7, at the top of the room (5, 3) | 40 | three wishes granted: the Idol in Eterna City's Pokémon Center (TM85 Dazzling Gleam for her Clefairy), the Socialite in Solaceon Town's north-east house (show a Ponyta, Rapidash, Moltres, Quilava or Infernape) and the boy in Pastoria City (show a Carvanha, Sharpedo or Gyarados); then the room's sign, read, shows it. A Jigglypuff in the party sings it awake | caught |
| Deoxys | static | Veilstone City, beside the meteorites (731, 630) | 70 | after the Hall of Fame, touching a meteorite without a Deoxys in the party ("something was seething with rage..."; `FLAG_SOVEREIGN_DEOXYS_SENSED`) | caught |
| Mew | static | Route 201, a Pachirisu's spot (108, 846) | 40 | Renegade's chain: feed a hungry Shroomish on Route 203 an Oran Berry, then a Buneary on Route 209 a Sitrus Berry, then a Torchic in Pastoria City an Old Gateau (Mew shows itself and flies on each time); then the Pachirisu on Route 201 turns out to be Mew | caught |
| Manaphy | static (hatched) | Pokémon Mansion, Mr. Backlot's office, beside his maid (18, 7) | 40 | after Team Galactic's siege of the Mansion (E10 part 24), Backlot's maid shows the deep blue Egg and it hatches; the frightened Manaphy attacks. Renegade gives the Egg instead; Mythicals are battled, never given (decision 26). Phione comes from breeding it | caught; a win or a run makes it vanish until the next visit |

**Steven** (Oreburgh City's south house) gives a Lv. 10 Beldum, then takes requests from his QUESTS menu: the Magma
Stone (Heatran's catch leaves it in Stark Mountain room 3, E10 part 40) for the Soul Dew; Latias and Latios in the
party for the legendary titans' story (Relicanth and Wailord); Regirock, Regice and Registeel in the party for the Red
and Blue Orbs, which Kyogre, Groudon and Rayquaza's events will need (Sovereign has no Jade Orb item, so Rayquaza will
check Steven's flag). After the Hall of Fame he battles (Renegade's Lv. 88–89 team).

Renegade puts a portal on each spot and opens them when Rowan is spoken to after the Distortion World; Sovereign shows
the Pokémon itself (as for its own legendaries) and needs no talk. Spots are provisional (owner, 2026-10-24).

## Open issues

Found by the audit and still open (the CB-0045 to CB-0048 fixes are in `EngineChangelog.md`):
- **Cosmog can flee.** At Lv. 5 it knows only Splash and Teleport, and a wild Teleport ends the battle about half the
  time it's picked. It then vanishes until the next visit. A trapping move or ability, or a quick catch, gets around
  it.
- **Roamers come back only through the Archivist** after a Hall of Fame. A player who doesn't reopen the topic sees
  nothing return. The RoamerGone line now says so.
- **Gates read the Pokédex,** so a legendary caught another way (a trade) can open the next one early, and a traded
  Reshiram skips the Light and Dark Stones (then Zekrom can't appear).
- **Poipole is Lv. 40,** below Route 230's own Pokémon, so a Repel with a stronger lead hides it.
- **The Marking Map and the TV news flash** can't tell the 11 roamers apart (vanilla behaviour).
