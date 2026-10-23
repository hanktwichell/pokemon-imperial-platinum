# Sovereign Platinum — Post-game Legendaries, Mythicals, Ultra Beasts & Paradox Pokémon

> Generated from `data/postgame_legendaries.yaml` by `tools/design/gen_legendary_doc.py`.

Renegade Platinum's own legendary events (Gen I–IV) are unchanged; see `RenegadePlatinumV130/Documentation/SpecialEvents.txt`.

## How it works

- Everything below unlocks after becoming **Champion**.
- Quests are given by the **Legend Archivist (new), Canalave Library 2F**. Chapters: Unova Chronicle, Kalos Chronicle, Alola Chronicle, Galar Chronicle, Paldea Chronicle.
- Chapters open one after another (each needs the previous chapter's "key" legendary caught), so the post-game has a guided order.
- Static encounters can be retried after fainting or fleeing, and have the normal shiny odds (Renegade behaviour).
- New maps or rooms are marked _(new)_ and need map work in DSPRE.
- **Built:** The Archivist (CB-0035) stands in Canalave Library 2F from the first Hall of Fame; his first talk opens the Unova Chronicle (VAR_SOVEREIGN_CHRONICLE). Later talks name where each Swords of Justice member not caught yet stands, then point to Keldeo (CB-0036), then give hints for Meloetta and Genesect (CB-0037). Static encounters share CommonScript_SovereignLegendaryEncounter: each stays on the map until the Pokédex has it as caught, and vanishes after it's knocked out until the next visit (as in vanilla legendary battles, the player can't run).

Covers **90** species.

## Unova Chronicle

### The Victory Star
- **Pokémon:** #494 Victini
- **Level:** 55
- **Location:** Sunyshore City — Vista Lighthouse basement (new room)
- **How:** Read the Unova Chronicle with the Archivist. A sealed hatch appears in the lighthouse; Volkner opens it.

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
- **Location:** Tornadus and Thundurus roam Sinnoh (like Mesprit/Cresselia). Landorus — Route 228 shrine (new). Enamorus — Route 224, Flower Paradise gate
- **How:** Roamers are released when the chapter opens. Bring both to the Route 228 shrine for Landorus; Enamorus appears after Landorus is caught.

### Truth and Ideals (chapter key)
- **Pokémon:** #643 Reshiram, #644 Zekrom, #646 Kyurem
- **Level:** 70
- **Location:** Reshiram — Fuego Ironworks (furnace room, new). Zekrom — Valley Windworks at night. Kyurem — Mt. Coronet Snow Area cave
- **How:** The Archivist gives the Light Stone and Dark Stone. Using each at its location summons Reshiram/Zekrom. Kyurem appears once both are caught. The DNA Splicers and Kyurem's fused forms are in the game (all forms are in scope, owner 2026-10-22).

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
- **Location:** Xerneas — Eterna Forest, behind the Old Chateau. Yveltal — Lost Tower roof (new floor)
- **How:** Both are static once the chapter opens.

### Order
- **Pokémon:** #718 Zygarde
- **Level:** 70
- **Location:** Wayward Cave — new deep chamber
- **How:** Appears after Xerneas and Yveltal are caught. Zygardite is sold post-game. Zygarde's 10%, 50% and Complete Formes are in the game (all forms are in scope, owner 2026-10-22).

### The Jewel
- **Pokémon:** #719 Diancie
- **Level:** 55
- **Location:** Oreburgh Mine B3F (new room)
- **How:** Bring a Carbink to the mine's back wall.

### Unbound Mischief
- **Pokémon:** #720 Hoopa
- **Level:** 55
- **Location:** Solaceon Ruins — innermost chamber
- **How:** The Archivist gives a Prison Bottle key item; use it in the ruins.

### Steam Engine
- **Pokémon:** #721 Volcanion
- **Level:** 60
- **Location:** Stark Mountain — hot-spring side room (new)
- **How:** Static encounter.

## Alola Chronicle

### The Island Guardians
- **Pokémon:** #785 Tapu Koko, #786 Tapu Lele, #787 Tapu Bulu, #788 Tapu Fini
- **Level:** 65
- **Location:** Koko — Route 222 beach shrine. Lele — Fullmoon Island grove. Bulu — Floaroma Meadow shrine. Fini — Route 226 sea shrine
- **How:** Four new shrine objects; interacting starts the battle.

### Nebby (chapter key)
- **Pokémon:** #789 Cosmog, #790 Cosmoem, #791 Solgaleo, #792 Lunala
- **Level:** 5
- **Location:** Spear Pillar
- **How:** A Cosmog is found at Spear Pillar (gift, Lv. 5). It evolves into Cosmoem at Lv. 43; Cosmoem becomes Solgaleo with a Sun Stone or Lunala with a Moon Stone (see EvolutionChanges_Sovereign.md). Return to Spear Pillar for a second Cosmog after the first evolves, so both Solgaleo and Lunala are obtainable.

### The Blinding One
- **Pokémon:** #800 Necrozma
- **Level:** 70
- **Location:** Spear Pillar
- **How:** Appears after owning Solgaleo or Lunala.

### Ultra Wormholes
- **Pokémon:** #793 Nihilego, #794 Buzzwole, #795 Pheromosa, #796 Xurkitree, #797 Celesteela, #798 Kartana, #799 Guzzlord, #805 Stakataka, #806 Blacephalon
- **Level:** 65
- **Location:** Nihilego — Iron Island B3F. Buzzwole — Route 225. Pheromosa — Route 229. Xurkitree — Sunyshore City power plant. Celesteela — Mt. Coronet Summit. Kartana — Eterna Forest. Guzzlord — Turnback Cave. Stakataka — Route 227. Blacephalon — Stark Mountain (outside)
- **How:** After Necrozma is caught, a glowing wormhole object appears at each location (static encounter).

### The Poison Pin
- **Pokémon:** #803 Poipole, #804 Naganadel
- **Level:** 40
- **Location:** Fight Area — Pokémon Center
- **How:** An Ultra Recon-style researcher gives Poipole (gift). Naganadel by levelling up knowing Dragon Pulse.

### Type Experiments
- **Pokémon:** #772 Type: Null, #773 Silvally
- **Level:** 40
- **Location:** Veilstone City — Team Galactic HQ
- **How:** Gift from the same reformed scientist as Genesect. Silvally via high friendship.

### The Artificial Pokémon
- **Pokémon:** #801 Magearna
- **Level:** 50
- **Location:** Sunyshore City — Volkner's workshop (new room in the Gym)
- **How:** Volkner restores a 500-year-old automaton after you defeat him in a rematch.

### Shadows
- **Pokémon:** #802 Marshadow
- **Level:** 50
- **Location:** Old Chateau (after Renegade's Gengar and Rotom events)
- **How:** Static encounter in the dining room shadow.

### Thunderclap
- **Pokémon:** #807 Zeraora
- **Level:** 50
- **Location:** Route 222 — tall grass at night
- **How:** Static encounter.

### Hex Nut
- **Pokémon:** #808 Meltan, #809 Melmetal
- **Level:** 40
- **Location:** Oreburgh Mine B2F
- **How:** The mine foreman gives a Meltan, and after you show it to him, a Melmetal (Lv. 50).

## Galar Chronicle

### The Hero Legends (chapter key)
- **Pokémon:** #888 Zacian, #889 Zamazenta
- **Level:** 70
- **Location:** Route 210 North (in the fog)
- **How:** Walk through the fog with the chapter open; Zacian appears first, Zamazenta after it is caught. Zacian holds the Rusted Sword and Zamazenta the Rusted Shield (owner, 2026-10-22); holding them gives the Crowned forms.

### Darkest Day
- **Pokémon:** #890 Eternatus
- **Level:** 70
- **Location:** Distortion World
- **How:** Appears after both heroes are caught.

### Master Dojo
- **Pokémon:** #891 Kubfu, #892 Urshifu
- **Level:** 10
- **Location:** Veilstone Gym
- **How:** Maylene gives a Kubfu (gift) and both Scrolls; using one evolves Kubfu into Urshifu (Single Strike or Rapid Strike).

### The Jungle Guardian
- **Pokémon:** #893 Zarude
- **Level:** 60
- **Location:** Great Marsh — Area 6
- **How:** Static encounter.

### New Regis
- **Pokémon:** #894 Regieleki, #895 Regidrago
- **Level:** 65
- **Location:** Regieleki — Valley Windworks (sealed room). Regidrago — Route 228 shrine
- **How:** Need Regirock, Regice and Registeel in the party (all from Renegade's events).

### King of Bountiful Harvests
- **Pokémon:** #898 Calyrex, #896 Glastrier, #897 Spectrier
- **Level:** 70
- **Location:** Calyrex — Celestic Town shrine. Glastrier — Route 217 (blizzard). Spectrier — Lost Tower 5F
- **How:** Calyrex first; then the steeds appear. Calyrex's fused forms (Ice Rider, Shadow Rider) are in the game (all forms are in scope, owner 2026-10-22).

## Paldea Chronicle

### Treasures of Ruin
- **Pokémon:** #1001 Wo-Chien, #1002 Chien-Pao, #1003 Ting-Lu, #1004 Chi-Yu
- **Level:** 65
- **Location:** Wo-Chien — Great Marsh shrine. Chien-Pao — Acuity Lakefront shrine. Ting-Lu — Route 214 shrine. Chi-Yu — Fuego Ironworks shrine
- **How:** Pull the eight stakes hidden around Sinnoh (two per shrine area, hinted by the Archivist) to unseal each shrine.

### The Loyal Three
- **Pokémon:** #1014 Okidogi, #1015 Munkidori, #1016 Fezandipiti
- **Level:** 65
- **Location:** Okidogi — Route 225. Munkidori — Route 229. Fezandipiti — Route 224
- **How:** Static encounters.

### The Masked Ogre
- **Pokémon:** #1017 Ogerpon
- **Level:** 65
- **Location:** Route 211 (East), at the mountain shrine
- **How:** Static encounter; Ogerpon holds the Teal Mask. Show it to the Pokéfan (male) in Celestic Town's northeast house (map CelesticTownNortheastHouse, script CelesticTownNortheastHouse_PokefanM) with Ogerpon at the front of the party, and he gives the Wellspring, Hearthflame and Cornerstone Masks. Holding a mask changes Ogerpon's form (owner, 2026-10-22).

### The Poison Puppeteer
- **Pokémon:** #1025 Pecharunt
- **Level:** 60
- **Location:** Route 224 — after the Loyal Three are caught
- **How:** Static encounter.

### Time Rifts (Paradox Pokémon)
- **Pokémon:** #984 Great Tusk, #985 Scream Tail, #986 Brute Bonnet, #987 Flutter Mane, #988 Slither Wing, #989 Sandy Shocks, #1005 Roaring Moon, #1009 Walking Wake, #1020 Gouging Fire, #1021 Raging Bolt, #990 Iron Treads, #991 Iron Bundle, #992 Iron Hands, #993 Iron Jugulis, #994 Iron Moth, #995 Iron Thorns, #1006 Iron Valiant, #1010 Iron Leaves, #1022 Iron Boulder, #1023 Iron Crown
- **Level:** 65
- **Location:** Ancient (past) Paradox: Spear Pillar time rift after Dialga is caught. Future Paradox: Spear Pillar space rift after Palkia is caught.
- **How:** Each rift is a Poké Radar-style patch on a new Spear Pillar floor; one Paradox Pokémon per patch, rotating daily (Renegade's daily RNG), until all ten of that rift are caught.

### Area Zero (chapter key)
- **Pokémon:** #1007 Koraidon, #1008 Miraidon, #1024 Terapagos
- **Level:** 70
- **Location:** Sendoff Spring — the crater (new map)
- **How:** Koraidon and Miraidon after all twenty Paradox Pokémon are registered; Terapagos after both are caught.
