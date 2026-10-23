# Sovereign Platinum — Evolution Changes (added species)

> Generated from `data/evolution_changes.yaml` by `tools/design/gen_evolution_doc.py`.

Renegade Platinum's own evolution changes (`RenegadePlatinumV130/Documentation/EvolutionChanges.txt`) are unchanged. This document covers only species added in Sovereign Platinum whose official evolution method can't run on the Gen IV engine (trades, Gen V+ triggers, regional-form requirements, and so on). Every other added species evolves exactly as in its home game — see the `evolution_method` column of `data/species.csv`.

| # | Species | Evolves from | Official method | Sovereign method | Why |
|---|---|---|---|---|---|
| 526 | Gigalith | Boldore | Trade | **Level 36** | Trade evolution (Renegade precedent) |
| 534 | Conkeldurr | Gurdurr | Trade | **Level 36** | Trade evolution (Renegade precedent) |
| 709 | Trevenant | Phantump | Trade | **Level 36** | Trade evolution (Renegade precedent) |
| 711 | Gourgeist | Pumpkaboo | Trade | **Level 36** | Trade evolution (Renegade precedent) |
| 589 | Escavalier | Karrablast | Trade for Shelmet | **Level up with Shelmet in the party** | Uses Gen IV's party-species method (as Mantyke/Remoraid) |
| 617 | Accelgor | Shelmet | Trade for Karrablast | **Level up with Karrablast in the party** | Uses Gen IV's party-species method |
| 683 | Aromatisse | Spritzee | Trade holding Sachet | **Use Sachet** | Trade-holding-item (Renegade precedent) |
| 685 | Slurpuff | Swirlix | Trade holding Whipped Dream | **Use Whipped Dream** | Trade-holding-item (Renegade precedent) |
| 675 | Pangoro | Pancham | Level 32 with a Dark-type in party | **Level 32** | No 'Dark-type in party' method in Gen IV |
| 687 | Malamar | Inkay | Level 30 with the console upside down | **Level 30** | Can't detect an upside-down console |
| 697 | Tyrantrum | Tyrunt | Level 39 at day | **Level 39** | Gen IV can't combine plain levelling with time of day |
| 699 | Aurorus | Amaura | Level 39 at night | **Level 39** | Gen IV can't combine plain levelling with time of day |
| 700 | Sylveon | Eevee | Level up with high affection knowing a Fairy-type move OR Level up with high friendship knowing a Fairy-type move | **Level up knowing Charm** | Gen IV has 'knows move' but not 'knows a move of type'; Charm is Fairy-type in Renegade. Renegade's other Eeveelutions use stones, so this doesn't clash. |
| 706 | Goodra | Sliggoo | Level 50 in rain OR Level 50 in rain from the sliggoo-hisui form | **Level 50** | No overworld-rain check in Gen IV |
| 735 | Gumshoos | Yungoos | Level 20 at day | **Level 20** | Time of day dropped |
| 754 | Lurantis | Fomantis | Level 34 at day | **Level 34** | Time of day dropped |
| 972 | Houndstone | Greavard | Level 30 at night | **Level 30** | Time of day dropped |
| 745 | Lycanroc | Rockruff | Level 25 at day OR Level 25 at night OR Level 25 at dusk | **Level 25 (Midday Form by day, Midnight Form at night; Dusk Form needs a form-change hook — Midday until then)** | Form chosen by time of day needs a small engine hook |
| 849 | Toxtricity | Toxel | Level 30 | **Level 30 (Amped Form; Low Key Form by nature once a form hook exists)** | Nature-dependent form needs an engine hook |
| 862 | Obstagoon | Linoone | Level 35 at night from the linoone-galar form | **Level up holding a Razor Claw at night** | The base form's route, set before Galarian Linoone was in the game (Galarian Linoone: see regional_forms); uses Gen IV's held-item-at-night method |
| 863 | Perrserker | Meowth | Level 28 from the meowth-galar form | **Use Metal Coat** | The base form's route, set before Galarian Meowth was in the game (Galarian Meowth: see regional_forms); Meowth still becomes Persian at Lv. 28 |
| 864 | Cursola | Corsola | Level 38 from the corsola-galar form | **Use Dusk Stone** | The base form's route, set before Galarian Corsola was in the game (Galarian Corsola: see regional_forms) |
| 865 | Sirfetch’d | Farfetch’d | Three critical hits from the farfetchd-galar form | **Level 40** | Can't count critical hits; the base form's route, set before Galarian Farfetch'd was in the game (Galarian Farfetch'd: see regional_forms). Renegade's Farfetch'd is already Fighting/Flying, which suits Sirfetch'd |
| 866 | Mr. Rime | Mr. Mime | Level 42 from the mr-mime-galar form | **Level 42** | The base form's route, set before Galarian Mr. Mime was in the game (Galarian Mr. Mime: see regional_forms); Gen VIII level kept |
| 867 | Runerigus | Yamask | Take damage at Dusty Bowl from the yamask-galar form | **Use Dusk Stone** | The base form's route, set before Galarian Yamask was in the game (Galarian Yamask: see regional_forms); Yamask still becomes Cofagrigus at Lv. 34 |
| 980 | Clodsire | Wooper | Level 20 from the wooper-paldea form | **Use Dusk Stone** | The base form's route, set before Paldean Wooper was in the game (Paldean Wooper: see regional_forms); Wooper still becomes Quagsire at Lv. 20 |
| 903 | Sneasler | Sneasel | Level up holding Razor Claw at day from the sneasel-hisui form | **Level up holding a Razor Claw by day** | The base form's route, set before Hisuian Sneasel was in the game (Hisuian Sneasel: see regional_forms); Weavile stays Razor Claw at night |
| 904 | Overqwil | Qwilfish | Strong style move after using Barb Barrage from the qwilfish-hisui form OR Level up knowing Barb Barrage from the qwilfish-hisui form OR Use move after using Barb Barrage from the qwilfish-hisui form | **Level up knowing Pin Missile** | Barb Barrage isn't in the engine; the base form's route, set before Hisuian Qwilfish was in the game (Hisuian Qwilfish: see regional_forms) |
| 902 | Basculegion | Basculin | Recoil damage (male) OR Recoil damage (female) | **Level 36 (male → Male Form, female → Female Form)** | Can't count recoil damage; the base form's route, set before White-Striped Basculin was in the game (White-Striped Basculin: see regional_forms) |
| 899 | Wyrdeer | Stantler | Agile style move after using Psyshield Bash | **Level up knowing Zen Headbutt** | Psyshield Bash isn't in the engine |
| 900 | Kleavor | Scyther | Use Black Augurite | **Use Black Augurite** | Item kept; Scyther still becomes Scizor with a Metal Coat |
| 901 | Ursaluna | Ursaring | Use Peat Block at full-moon | **Use Peat Block** | Full-moon condition dropped |
| 979 | Annihilape | Primeape | Use move after using Rage Fist | **Level 50** | Rage Fist isn't in the engine |
| 981 | Farigiraf | Girafarig | Level up knowing Twin Beam | **Level up knowing Psychic** | Twin Beam isn't in the engine |
| 982 | Dudunsparce | Dunsparce | Level up knowing Hyper Drill | **Level up knowing Drill Run** | Hyper Drill isn't in the engine; Drill Run was added by Renegade |
| 983 | Kingambit | Bisharp | Three defeated bisharp | **Use Leader's Crest** | Can't count defeated Bisharp |
| 1000 | Gholdengo | Gimmighoul | Gimmighoul coins | **Level 40** | No coin collection mechanic |
| 923 | Pawmot | Pawmo | Level up after walking 1000 steps (Let's Go) | **Level 40** | No Let's Go step counter |
| 947 | Brambleghast | Bramblin | Level up after walking 1000 steps (Let's Go) | **Level 40** | No Let's Go step counter |
| 954 | Rabsca | Rellor | Level up after walking 1000 steps (Let's Go) | **Level 35** | No Let's Go step counter |
| 964 | Palafin | Finizen | Level 38 in a Union Circle (multiplayer) | **Level 38** | Union Circle (multiplayer) requirement dropped |
| 925 | Maushold | Tandemaus | In battle level up | **Level 25** | In-battle level-up requirement dropped |
| 841 | Flapple | Applin | Use Tart Apple | **Use Tart Apple** | New item |
| 842 | Appletun | Applin | Use Sweet Apple | **Use Sweet Apple** | New item |
| 1011 | Dipplin | Applin | Use Syrupy Apple | **Use Syrupy Apple** | New item |
| 1019 | Hydrapple | Dipplin | Level up knowing Dragon Cheer | **Level up knowing Dragon Pulse** | Dragon Cheer isn't in the engine |
| 855 | Polteageist | Sinistea | Use Cracked Pot OR Use Chipped Pot | **Use Cracked Pot** | New item (Chipped Pot form not needed: Antique/Phony forms are cosmetic) |
| 1013 | Sinistcha | Poltchageist | Use Unremarkable Teacup OR Use Masterpiece Teacup | **Use Unremarkable Teacup** | New item (Masterpiece form is cosmetic) |
| 869 | Alcremie | Milcery | Spin holding Strawberry Sweet at day OR Spin holding Strawberry Sweet at night OR Spin holding Strawberry Sweet at dusk OR Spin holding Berry Sweet at day OR Spin holding Berry Sweet at night OR Spin holding Berry Sweet at dusk OR Spin holding Love Sweet at day OR Spin holding Love Sweet at night OR Spin holding Love Sweet at dusk OR Spin holding Star Sweet at day OR Spin holding Star Sweet at night OR Spin holding Star Sweet at dusk OR Spin holding Clover Sweet at day OR Spin holding Clover Sweet at night OR Spin holding Clover Sweet at dusk OR Spin holding Flower Sweet at day OR Spin holding Flower Sweet at night OR Spin holding Flower Sweet at dusk OR Spin holding Ribbon Sweet at day OR Spin holding Ribbon Sweet at night OR Spin holding Ribbon Sweet at dusk | **Use Strawberry Sweet** | Can't detect spinning; other sweets/forms are cosmetic and can come later |
| 936 | Armarouge | Charcadet | Use Auspicious Armor | **Use Auspicious Armor** | New item |
| 937 | Ceruledge | Charcadet | Use Malicious Armor | **Use Malicious Armor** | New item |
| 1018 | Archaludon | Duraludon | Use Metal Alloy | **Use Metal Alloy** | New item |
| 809 | Melmetal | Meltan | Meltan candies | **Not an evolution — Melmetal is given by its own post-game event** | No Meltan Candy / GO link |
| 892 | Urshifu | Kubfu | Tower of darkness OR Tower of waters OR Use Scroll of Darkness OR Use Scroll of Waters | **Use Scroll of Darkness (Single Strike) / Scroll of Waters (Rapid Strike)** | Tower challenge replaced by the scrolls |
| 791 | Solgaleo | Cosmoem | Level 53 | **Use Sun Stone** | Sun/Moon split by version; Sovereign has one version |
| 792 | Lunala | Cosmoem | Level 53 | **Use Moon Stone** | Sun/Moon split by version; Sovereign has one version |

## New evolution items

These must be added to the item table (alongside the Mega Stones). All have a "Use" option like an evolution stone.

| Item | Where to get it |
|---|---|
| Sachet | Snowpoint City evolution-item seller ($10,000) |
| Whipped Dream | Snowpoint City evolution-item seller ($10,000) |
| Black Augurite | Snowpoint City evolution-item seller ($10,000) |
| Peat Block | Snowpoint City evolution-item seller ($10,000) |
| Leader's Crest | Snowpoint City evolution-item seller ($10,000) |
| Tart Apple | Snowpoint City evolution-item seller ($10,000) |
| Sweet Apple | Snowpoint City evolution-item seller ($10,000) |
| Syrupy Apple | Snowpoint City evolution-item seller ($10,000) |
| Cracked Pot | Snowpoint City evolution-item seller ($10,000) |
| Unremarkable Teacup | Snowpoint City evolution-item seller ($10,000) |
| Strawberry Sweet | Snowpoint City evolution-item seller ($10,000) |
| Auspicious Armor | Snowpoint City evolution-item seller ($10,000) |
| Malicious Armor | Snowpoint City evolution-item seller ($10,000) |
| Metal Alloy | Snowpoint City evolution-item seller ($10,000) |
| Scroll of Darkness | Kubfu's post-game event |
| Scroll of Waters | Kubfu's post-game event |

## Regional forms

A regional form evolves like its base species and keeps its region (Alolan Rattata → Alolan Raticate, Galarian Darumaka → Galarian Darmanitan). These evolve differently (`regional_forms`; `tools/engine/gen_forms.py` builds them into the forms' data):

| Form | Sovereign method | Why |
|---|---|---|
| Alolan Vulpix | **Use Ice Stone** | Official |
| Alolan Sandshrew | **Use Ice Stone** | Official |
| Alolan Meowth | **Level 28 (Alolan Persian)** | Renegade's level for Meowth (official: friendship); no Perrserker |
| Galarian Meowth | **Level 28 (Perrserker)** | Official |
| Galarian Slowpoke | **Use Galarica Cuff / Galarica Wreath** | Official |
| Galarian Corsola | **Level 38 (Cursola)** | Official |
| Galarian Darumaka | **Use Ice Stone** | Official |
| Galarian Yamask | **Level 34 (Runerigus)** | Can't count HP lost; Yamask's own level, so it never becomes Cofagrigus |
| Hisuian Voltorb | **Use Leaf Stone** | Official |
| Hisuian Sneasel | **Level up holding a Razor Claw by day (Sneasler)** | Official |
| Paldean Wooper | **Level 20 (Clodsire)** | Official |

An Egg hatches into its parent's regional form (the mother's, or the parent that isn't Ditto), or the base form when the baby has no form of that region. These species hatch from Eggs in their regional form, as in the official games: Perrserker → Galarian Meowth, Sirfetch’d → Galarian Farfetch’d, Cursola → Galarian Corsola, Obstagoon → Galarian Zigzagoon, Runerigus → Galarian Yamask, Sneasler → Hisuian Sneasel, Overqwil → Hisuian Qwilfish, Clodsire → Paldean Wooper, Basculegion → White-Striped Basculin.
