# Sovereign Platinum — Post-game Legendaries, Mythicals, Ultra Beasts & Paradox Pokémon

> Generated from `data/postgame_legendaries.yaml` by `tools/design/gen_legendary_doc.py`.

Renegade Platinum's own legendary events (Gen I–IV) are unchanged; see `RenegadePlatinumV130/Documentation/SpecialEvents.txt`.

## How it works

- Everything below unlocks after becoming **Champion**.
- Quests are given by the **Legend Archivist (new), Canalave Library 2F**. Chapters: Unova Chronicle, Kalos Chronicle, Alola Chronicle, Galar Chronicle, Paldea Chronicle.
- Chapters open one after another (each needs the previous chapter's "key" legendary caught), so the post-game has a guided order.
- Static encounters can be retried after fainting or fleeing, and have the normal shiny odds (Renegade behaviour).
- New maps or rooms are marked _(new)_ and need map work in DSPRE.
- **Built:** The Archivist (CB-0035) stands in Canalave Library 2F from the first Hall of Fame; his first talk opens the Unova Chronicle (VAR_SOVEREIGN_CHRONICLE). Later talks offer a menu of its legends (CB-0040): Swords of Justice (the swords, then Keldeo, CB-0036), Truth and Ideals (the Light and Dark Stones, the dragons, then the DNA Splicers, CB-0038), Forces of Nature (the roamers' release, then the Reveal Glass, Landorus and Enamorus, CB-0039) and Other legends (Meloetta, Genesect and Victini, CB-0037 and CB-0041). Once Kyurem is caught he opens the Kalos Chronicle (CB-0041) and first asks which Chronicle to read from; Kalos has Life and Destruction (Xerneas and Yveltal, then Zygarde) and Other legends (the Prison Bottle, Diancie, Hoopa and Volcanion). Xerneas and Yveltal caught open the Alola Chronicle (CB-0042): Island Guardians (the Tapus), Sun and Moon (Cosmog, then Necrozma) and Ultra Beasts (CB-0043). Every legendary is battled and caught, never given (owner, 2026-10-23). Static encounters share CommonScript_SovereignLegendaryEncounter: each stays on the map until the Pokédex has it as caught, and vanishes after it's knocked out until the next visit (as in vanilla legendary battles, the player can't run).

Covers **90** species.

## Unova Chronicle

### The Victory Star
- **Pokémon:** #494 Victini
- **Level:** 55
- **Location:** Sunyshore City — Vista Lighthouse (top floor)
- **How:** Read the Unova Chronicle with the Archivist. A sealed hatch appears in the lighthouse; Volkner opens it.
- **Built:** Victini (CB-0041): on the west side of the lighthouse's top floor (2, 7), the Totem Togedemaru's floor, from the moment the Unova Chronicle opens until it's caught. **Changed from the plan** (owner, 2026-10-23: existing spots rather than new rooms): the lighthouse has no basement, so there's no hatch and Volkner doesn't take part; the Archivist's Other legends topic points to the top floor.

### Swords of Justice
- **Pokémon:** #638 Cobalion, #639 Terrakion, #640 Virizion
- **Level:** 65
- **Location:** Cobalion — Iron Island B2F (side cave); Terrakion — Route 227 (rock pocket); Virizion — Eterna Forest (north corridor)
- **How:** All three are static encounters as soon as the chapter opens.
- **Built:** Virizion (CB-0035): at the top of Eterna Forest's north corridor (80, 10), past the Cut trees. Terrakion (CB-0036): in the rock pocket at the north end of Route 227 (759, 258). Cobalion (CB-0036): in the top pocket of Iron Island B2F's right room (17, 1), the side cave reached from B1F; an existing dead end in place of a new one.

### The Young Sword
- **Pokémon:** #647 Keldeo
- **Level:** 55
- **Location:** Lake Valor (north-west clearing)
- **How:** Visit with Cobalion, Terrakion and Virizion in the party.
- **Built:** Keldeo (CB-0036): in the clearing at Lake Valor's north-west shore (36, 14), there while Cobalion, Terrakion and Virizion are all in the party, until it's caught. It comes in its Ordinary Form; the Resolute Form comes with the battle forms (FM).

### Forces of Nature
- **Pokémon:** #641 Tornadus, #642 Thundurus, #645 Landorus, #905 Enamorus
- **Level:** 65
- **Location:** Tornadus and Thundurus roam Sinnoh (like Mesprit/Cresselia). Landorus — Route 228's ruins. Enamorus — Route 224, Flower Paradise gate
- **How:** Roamers are released when the chapter opens. Bring both to the Route 228 shrine for Landorus; Enamorus appears after Landorus is caught.
- **Built:** Forces of Nature (CB-0039). The Archivist releases Tornadus and Thundurus as roamers (two new roaming slots, FLAG_SOVEREIGN_RELEASED_FORCES_OF_NATURE). One that's knocked out comes back after the next Hall of Fame, when the Archivist releases it again. With both caught, he gives the Reveal Glass. Landorus appears in Route 228's ruins (the Rock Peak Ruins chamber, (7, 5)) while both are in the party; that chamber stands in for a new shrine. Enamorus then waits by the Route 224 tablet (914, 494). All four are level 65.

### Truth and Ideals (chapter key)
- **Pokémon:** #643 Reshiram, #644 Zekrom, #646 Kyurem
- **Level:** 70
- **Location:** Reshiram — Fuego Ironworks (by the furnaces). Zekrom — Valley Windworks at night. Kyurem — Mt. Coronet's ice chamber
- **How:** The Archivist gives the Light Stone and Dark Stone. Using each at its location summons Reshiram/Zekrom. Kyurem appears once both are caught. The DNA Splicers and Kyurem's fused forms are in the game (all forms are in scope, owner 2026-10-22).
- **Built:** Truth and Ideals (CB-0038). The Archivist gives the Light and Dark Stones on the first talk that reaches this part. Reshiram stands in Fuego Ironworks (49, 5) while the player carries the Light Stone. Zekrom stands on Valley Windworks' windmill island (236, 650) at night (8 pm to 4 am) while the player carries the Dark Stone. Kyurem sleeps in Mt. Coronet's ice chamber (7, 5), the room off the north room by Route 216, once both are caught. The Archivist then gives the DNA Splicers. The furnaces are the Ironworks' own, in place of a new room. All three are level 70.

### The Relic Song
- **Pokémon:** #648 Meloetta
- **Level:** 55
- **Location:** Hearthome City — Contest Hall stage
- **How:** Talk to the composer in the Contest Hall with a Pokémon that knows Sing in the party.
- **Built:** Meloetta (CB-0037): the composer (a new NPC in the Contest Hall lobby, (8, 7)) lets a party Pokémon that knows Sing sing the Relic Song (FLAG_SOVEREIGN_MELOETTA_SONG). Meloetta then stands on the Contest Hall's stage (28, 5) until it's caught. The stage replaces Amity Square, which has no stage the player can reach and only lets in players leading certain Pokémon. It comes in its Aria Forme; the Pirouette Forme comes with the battle forms (FM).

### Plasma's Leftovers
- **Pokémon:** #649 Genesect
- **Level:** 60
- **Location:** Veilstone City — Team Galactic HQ lab
- **How:** A Galactic scientist confesses to reviving a fossil and asks you to stop it. Battle then catch.
- **Built:** Genesect (CB-0037): the lab's male scientist confesses once the Unova Chronicle is open (FLAG_SOVEREIGN_GENESECT_FREED). Genesect then stands in the lab's back room (34, 5), by the Control Room door, until it's caught. Its Drive forms come with the forms milestone (FM).

## Kalos Chronicle

### Life and Destruction (chapter key)
- **Pokémon:** #716 Xerneas, #717 Yveltal
- **Level:** 70
- **Location:** Xerneas — Eterna Forest, beside the Old Chateau. Yveltal — Lost Tower 5F (top floor)
- **How:** Both are static once the chapter opens.
- **Built:** The Kalos Chronicle (CB-0041) opens when the player talks to the Archivist with Kyurem caught (VAR_SOVEREIGN_CHRONICLE 2). Xerneas stands in the nook west of the Old Chateau's door (70, 14); Yveltal at the end of the Lost Tower top floor's east corridor (13, 14). Both are level 70. **Changed from the plan** (owner, 2026-10-23: existing spots rather than new rooms): Yveltal uses the existing top floor in place of a new roof.

### Order
- **Pokémon:** #718 Zygarde
- **Level:** 70
- **Location:** Wayward Cave — B1F (lowest floor)
- **How:** Appears after Xerneas and Yveltal are caught. Zygardite is sold post-game. Zygarde's 10%, 50% and Complete Formes are in the game (all forms are in scope, owner 2026-10-22).
- **Built:** Zygarde (CB-0041), level 70, in its 50% Forme: in the alcove at the north of Wayward Cave B1F (21, 4) once Xerneas and Yveltal are both caught, until it's caught. **Changed from the plan** (owner, 2026-10-23): an existing alcove in place of a new chamber. The 10% and Complete Formes come with the forms milestone (FM).

### The Jewel
- **Pokémon:** #719 Diancie
- **Level:** 55
- **Location:** Oreburgh Mine B2F (west nook)
- **How:** Bring a Carbink to the mine's back wall.
- **Built:** Diancie (CB-0041), level 55: in the nook by Oreburgh Mine B2F's west wall (2, 22) while the Kalos Chronicle is open and a Carbink (wild outside Stark Mountain) is in the party, until it's caught. **Changed from the plan** (owner, 2026-10-23): the mine's lowest floor, B2F, in place of a new B3F room.

### Unbound Mischief
- **Pokémon:** #720 Hoopa
- **Level:** 55
- **Location:** Solaceon Ruins — innermost chamber
- **How:** The Archivist gives a Prison Bottle key item; use it in the ruins.
- **Built:** Hoopa (CB-0041), level 55: the Archivist's Kalos Other legends topic gives the Prison Bottle. Hoopa then plays in the ruins' innermost room, Room 7 (5, 4), while the player carries the bottle, until it's caught. Carrying the bottle replaces using it there. It comes Confined; the bottle switches it to Unbound from the bag (FM part 2).

### Steam Engine
- **Pokémon:** #721 Volcanion
- **Level:** 60
- **Location:** Stark Mountain — the first cave's east tunnel
- **How:** Static encounter.
- **Built:** Volcanion (CB-0041), level 60: at the end of the long east tunnel in Stark Mountain's first cave room (34, 24), by the PP Up, once the Kalos Chronicle is open, until it's caught. **Changed from the plan** (owner, 2026-10-23): an existing dead end in place of a new hot-spring room.

## Alola Chronicle

### The Island Guardians
- **Pokémon:** #785 Tapu Koko, #786 Tapu Lele, #787 Tapu Bulu, #788 Tapu Fini
- **Level:** 65
- **Location:** Koko — Route 222 beach. Lele — Fullmoon Island grove. Bulu — Floaroma Meadow. Fini — Route 226, an islet at sea
- **How:** Four new shrine objects; interacting starts the battle.
- **Built:** The Island Guardians (CB-0042), all level 65, from the moment the Alola Chronicle opens (VAR_SOVEREIGN_CHRONICLE 3, when the player talks to the Archivist with Xerneas and Yveltal caught) until each is caught. Koko on the sand strip at Route 222's east end (808, 795); Lele at the north-west edge of Fullmoon Island's grove (13, 12); Bulu in Floaroma Meadow's north field (24, 36); Fini on the little beach under Route 226's cliffs, reached by Surf (716, 345). **Changed from the plan** (owner, 2026-10-23: existing spots): each Tapu stands there itself, with no shrine object.

### Nebby (chapter key)
- **Pokémon:** #789 Cosmog, #790 Cosmoem, #791 Solgaleo, #792 Lunala
- **Level:** 5
- **Location:** Spear Pillar
- **How:** A Cosmog waits at Spear Pillar (Lv. 5) to be battled and caught. It evolves into Cosmoem at Lv. 43; Cosmoem becomes Solgaleo with a Sun Stone or Lunala with a Moon Stone (see EvolutionChanges_Sovereign.md). Return to Spear Pillar for a second Cosmog after the first evolves, so both Solgaleo and Lunala are obtainable.
- **Built:** Cosmog (CB-0042, a battle since CB-0043): floating in Spear Pillar's plaza (31, 25) once the Alola Chronicle is open, at level 5, until it's caught (FLAG_SOVEREIGN_CAUGHT_COSMOG). Once the Pokédex has Solgaleo or Lunala as caught, a second one waits there until it's caught too (FLAG_SOVEREIGN_CAUGHT_COSMOG_2). Like every static legendary, one that's knocked out comes back on the next visit. **Changed from the plan** (owner, 2026-10-23: legendaries are battled and caught, never given): CB-0042 made Cosmog a gift.

### The Blinding One
- **Pokémon:** #800 Necrozma
- **Level:** 70
- **Location:** Spear Pillar
- **How:** Appears after owning Solgaleo or Lunala.
- **Built:** Necrozma (CB-0042), level 70: in Spear Pillar's plaza (31, 20), north of Cosmog's spot, once the Pokédex has Solgaleo or Lunala as caught, until it's caught. The Archivist then gives the N-Solarizer and N-Lunarizer, which fuse it with Solgaleo (Dusk Mane) or Lunala (Dawn Wings) from the bag (FM part 2).

### Ultra Wormholes
- **Pokémon:** #793 Nihilego, #794 Buzzwole, #795 Pheromosa, #796 Xurkitree, #797 Celesteela, #798 Kartana, #799 Guzzlord, #805 Stakataka, #806 Blacephalon
- **Level:** 65
- **Location:** Nihilego — Iron Island B3F. Buzzwole — Route 225. Pheromosa — Route 229. Xurkitree — Sunyshore City power plant. Celesteela — Mt. Coronet Summit. Kartana — Eterna Forest. Guzzlord — Turnback Cave. Stakataka — Route 227. Blacephalon — Stark Mountain (outside)
- **How:** After Necrozma is caught, a glowing wormhole object appears at each location (static encounter).
- **Built:** The Ultra Beasts (CB-0043), all level 65, each a static encounter from the moment Necrozma is caught until it's caught: Nihilego in Iron Island B3F's east pocket (15, 4); Buzzwole beside the item at Route 225's north end (633, 330); Pheromosa in the Route 229 pocket by the Reaper Cloth (813, 426); Xurkitree at the end of Sunyshore City's walkway by the Thunderstone (882, 778); Celesteela on Mt. Coronet's highest snowfield (Mt. Coronet outside north, (51, 3)); Kartana by Eterna Forest's east passage (87, 51); Guzzlord by Turnback Cave's entrance (8, 15); Stakataka in the hollow south of Route 227's grass (747, 273); Blacephalon in the hollow east of Stark Mountain's entrance (760, 234). The Archivist's Ultra Beasts topic hints at each one not caught yet. **Changed from the plan** (owner, 2026-10-23: existing spots): each Ultra Beast stands there itself, with no wormhole object, and Xurkitree uses Sunyshore's walkway in place of a power plant.

### The Poison Pin
- **Pokémon:** #803 Poipole, #804 Naganadel
- **Level:** 40
- **Location:** Fight Area — Pokémon Center
- **How:** An Ultra Recon-style researcher tells of a Poipole that came through a wormhole; it then waits nearby to be battled and caught. Naganadel by levelling up knowing Dragon Pulse. **Changed from the plan** (owner, 2026-10-23: legendaries are battled and caught, never given); the plan had a gift.
- **Built:** Poipole (CB-0043), level 40: in the Fight Area (650, 435) once the Alola Chronicle is open and Necrozma is caught, until it's caught. A battle, not a gift. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### Type Experiments
- **Pokémon:** #772 Type: Null, #773 Silvally
- **Level:** 40
- **Location:** Veilstone City — Team Galactic HQ
- **How:** The same reformed scientist as Genesect confesses to a second experiment; Type: Null then waits in the lab to be battled and caught. Silvally via high friendship. **Changed from the plan** (owner, 2026-10-23: legendaries are battled and caught, never given); the plan had a gift.
- **Built:** Type: Null (CB-0043), level 40: in the Galactic HQ lab (24, 10) once Genesect is caught, until it's caught. A battle, not a gift. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### The Artificial Pokémon
- **Pokémon:** #801 Magearna
- **Level:** 50
- **Location:** Sunyshore City — Volkner's workshop (new room in the Gym)
- **How:** Volkner restores a 500-year-old automaton after you defeat him in a rematch; Magearna wakes and must be battled and caught. **Changed from the plan** (owner, 2026-10-23: legendaries are battled and caught, never given); the plan had Volkner hand it over.
- **Built:** Magearna (CB-0043), level 50: in Volkner's room at the Sunyshore Gym (11, 13) once the Alola Chronicle is open, until it's caught. The Volkner rematch and restoring scene aren't built yet. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### Shadows
- **Pokémon:** #802 Marshadow
- **Level:** 50
- **Location:** Old Chateau (after Renegade's Gengar and Rotom events)
- **How:** Static encounter in the dining room shadow.
- **Built:** Marshadow (CB-0043), level 50: in the Old Chateau's dining area (21, 9) once the Alola Chronicle is open, until it's caught. Renegade's Gengar and Rotom events aren't ported yet (E10), so they aren't a condition. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### Thunderclap
- **Pokémon:** #807 Zeraora
- **Level:** 50
- **Location:** Route 222 — tall grass at night
- **How:** Static encounter.
- **Built:** Zeraora (CB-0043), level 50: on Route 222 (774, 783) at night (8 pm to 4 am, checked on entering the map) once the Alola Chronicle is open, until it's caught. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### Hex Nut
- **Pokémon:** #808 Meltan, #809 Melmetal
- **Level:** 40
- **Location:** Oreburgh Mine B2F
- **How:** A Meltan (Lv. 40) is battled and caught in the mine; show it to the foreman and a Melmetal (Lv. 50) appears to battle. **Changed from the plan** (owner, 2026-10-23: legendaries are battled and caught, never given); the plan had the foreman give both.
- **Built:** Meltan (CB-0043), level 40, then Melmetal, level 50, once Meltan is caught: both on Oreburgh Mine B2F's west side, (5, 20) and (5, 24), until caught. Battles, not gifts; the foreman isn't involved yet. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

## Galar Chronicle

### The Hero Legends (chapter key)
- **Pokémon:** #888 Zacian, #889 Zamazenta
- **Level:** 70
- **Location:** Route 210 North (in the fog)
- **How:** Walk through the fog with the chapter open; Zacian appears first, Zamazenta after it is caught. Zacian holds the Rusted Sword and Zamazenta the Rusted Shield (owner, 2026-10-22); holding them gives the Crowned forms.
- **Built:** The Galar Chronicle (CB-0043) opens when the player talks to the Archivist with Solgaleo or Lunala caught (VAR_SOVEREIGN_CHRONICLE 4). Zacian (542, 528) holding the Rusted Sword, then Zamazenta (540, 528) holding the Rusted Shield once Zacian is caught, on Route 210 North, level 70 (VAR_SOVEREIGN_LEGENDARY_HELD_ITEM sets the wild Pokémon's item). **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### Darkest Day
- **Pokémon:** #890 Eternatus
- **Level:** 70
- **Location:** Distortion World
- **How:** Appears after both heroes are caught.
- **Built:** Eternatus (CB-0043), level 70: in Turnback Cave's Giratina room (8, 13) once Zacian and Zamazenta are both caught, until it's caught. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later): the Distortion World needed more than a quick placement.

### Master Dojo
- **Pokémon:** #891 Kubfu, #892 Urshifu
- **Level:** 10
- **Location:** Veilstone Gym
- **How:** A Kubfu trains in the Veilstone Gym; battle and catch it, then Maylene gives both Scrolls; using one evolves Kubfu into Urshifu (Single Strike or Rapid Strike). **Changed from the plan** (owner, 2026-10-23: legendaries are battled and caught, never given); the plan had Maylene give Kubfu.
- **Built:** Kubfu (CB-0043), level 10: in the Veilstone Gym (13, 17) once the Galar Chronicle is open, until it's caught. The Archivist then gives the Scroll of Darkness and the Scroll of Waters. A battle, not a gift; the Archivist stands in for Maylene. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### The Jungle Guardian
- **Pokémon:** #893 Zarude
- **Level:** 60
- **Location:** Great Marsh — Area 6
- **How:** Static encounter.
- **Built:** Zarude (CB-0043), level 60: on Route 212 South (516, 850) once the Galar Chronicle is open, until it's caught. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later): the Great Marsh's Safari rules make a battle there harder.

### New Regis
- **Pokémon:** #894 Regieleki, #895 Regidrago
- **Level:** 65
- **Location:** Regieleki — Valley Windworks (sealed room). Regidrago — Route 228 shrine
- **How:** Need Regirock, Regice and Registeel in the party (all from Renegade's events).
- **Built:** Regieleki in the Valley Windworks building (8, 9) and Regidrago in Route 228's ruins (5, 6) (CB-0043), level 65, while Regirock, Regice and Registeel are all in the party, once the Galar Chronicle is open, until caught. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### King of Bountiful Harvests
- **Pokémon:** #898 Calyrex, #896 Glastrier, #897 Spectrier
- **Level:** 70
- **Location:** Calyrex — Celestic Town shrine. Glastrier — Route 217 (blizzard). Spectrier — Lost Tower 5F
- **How:** Calyrex first; then the steeds appear. Calyrex's fused forms (Ice Rider, Shadow Rider) are in the game (all forms are in scope, owner 2026-10-22).
- **Built:** Calyrex in Celestic Town (461, 527), then Glastrier on Route 217 (305, 319) and Spectrier on Lost Tower 5F (5, 10) once Calyrex is caught (CB-0043), level 70. The Archivist gives the Reins of Unity once Calyrex is caught. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

## Paldea Chronicle

### Treasures of Ruin
- **Pokémon:** #1001 Wo-Chien, #1002 Chien-Pao, #1003 Ting-Lu, #1004 Chi-Yu
- **Level:** 65
- **Location:** Wo-Chien — Great Marsh shrine. Chien-Pao — Acuity Lakefront shrine. Ting-Lu — Route 214 shrine. Chi-Yu — Fuego Ironworks shrine
- **How:** Pull the eight stakes hidden around Sinnoh (two per shrine area, hinted by the Archivist) to unseal each shrine.
- **Built:** The Paldea Chronicle (CB-0043) opens when the player talks to the Archivist with Zacian and Zamazenta caught (VAR_SOVEREIGN_CHRONICLE 5). Each Ruinous shrine has two stakes on its own map (FLAG_SOVEREIGN_PULLED_STAKE_1 to _8, a common script asks to pull each); with both out the legendary appears at once: Wo-Chien on Route 212 North (464, 788), Chien-Pao at Acuity Lakefront (325, 240), Ting-Lu on Route 214 (722, 695), Chi-Yu outside Fuego Ironworks (180, 593), all level 65. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later): the stakes stand next to their shrine for now.

### The Loyal Three
- **Pokémon:** #1014 Okidogi, #1015 Munkidori, #1016 Fezandipiti
- **Level:** 65
- **Location:** Okidogi — Route 225. Munkidori — Route 229. Fezandipiti — Route 224
- **How:** Static encounters.
- **Built:** Okidogi on Route 225 (625, 370), Munkidori on Route 229 (806, 428) and Fezandipiti on Route 224 (896, 527) (CB-0043), level 65, once the Paldea Chronicle is open, until caught. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### The Masked Ogre
- **Pokémon:** #1017 Ogerpon
- **Level:** 65
- **Location:** Route 211 (East), at the mountain shrine
- **How:** Static encounter; Ogerpon holds the Teal Mask. Show it to the Pokéfan (male) in Celestic Town's northeast house (map CelesticTownNortheastHouse, script CelesticTownNortheastHouse_PokefanM) with Ogerpon at the front of the party, and he gives the Wellspring, Hearthflame and Cornerstone Masks. Holding a mask changes Ogerpon's form (owner, 2026-10-22).
- **Built:** Ogerpon (CB-0043), level 65, holding the Teal Mask: on Route 211 East (435, 531) once the Paldea Chronicle is open, until it's caught. The Pokéfan in Celestic Town's northeast house then gives the Wellspring, Hearthflame and Cornerstone Masks once, with Ogerpon at the front of the party (FLAG_SOVEREIGN_RECEIVED_OGERPON_MASKS). **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### The Poison Puppeteer
- **Pokémon:** #1025 Pecharunt
- **Level:** 60
- **Location:** Route 224 — after the Loyal Three are caught
- **How:** Static encounter.
- **Built:** Pecharunt (CB-0043), level 60: on Route 224 (898, 526) once the Loyal Three are all caught, until it's caught. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later).

### Time Rifts (Paradox Pokémon)
- **Pokémon:** #984 Great Tusk, #985 Scream Tail, #986 Brute Bonnet, #987 Flutter Mane, #988 Slither Wing, #989 Sandy Shocks, #1005 Roaring Moon, #1009 Walking Wake, #1020 Gouging Fire, #1021 Raging Bolt, #990 Iron Treads, #991 Iron Bundle, #992 Iron Hands, #993 Iron Jugulis, #994 Iron Moth, #995 Iron Thorns, #1006 Iron Valiant, #1010 Iron Leaves, #1022 Iron Boulder, #1023 Iron Crown
- **Level:** 65
- **Location:** Ancient (past) Paradox: Spear Pillar time rift after Dialga is caught. Future Paradox: Spear Pillar space rift after Palkia is caught.
- **How:** Each rift is a Poké Radar-style patch on a new Spear Pillar floor; one Paradox Pokémon per patch, rotating daily (Renegade's daily RNG), until all ten of that rift are caught.
- **Built:** Two rifts on Spear Pillar's plaza (CB-0043), level 65, once the Paldea Chronicle is open: the ancient one (27, 30) after Dialga is caught, the future one (35, 30) after Palkia is caught. Each shows and battles the first of its ten not caught yet (VAR_OBJ_GFX_ID_1 and _2 for its sprite) and closes when all ten are caught. **Changed from the plan** (owner, 2026-10-23: existing spots, everything in first): Spear Pillar itself in place of a new floor, and a fixed order in place of a daily rotation.

### Area Zero (chapter key)
- **Pokémon:** #1007 Koraidon, #1008 Miraidon, #1024 Terapagos
- **Level:** 70
- **Location:** Sendoff Spring — the crater (new map)
- **How:** Koraidon and Miraidon after all twenty Paradox Pokémon are registered; Terapagos after both are caught.
- **Built:** Koraidon (29, 36) and Miraidon (27, 37) at Sendoff Spring once all twenty Paradox Pokémon are caught, then Terapagos (30, 34) once both are caught (CB-0043), level 70. **Provisional spot** (owner, 2026-10-23: everything in the game first, placements later): Sendoff Spring stands in for a new crater map.
