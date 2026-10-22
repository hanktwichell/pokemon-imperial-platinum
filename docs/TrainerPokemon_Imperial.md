# Imperial Platinum — Trainer Pokémon (bosses)

> Generated from `data/trainers_imperial.yaml` by `tools/design/gen_trainer_docs.py`. Edit the YAML, not this file.

## General changes

- Every trainer not listed here keeps its Renegade Platinum v1.3.0 team (`RenegadePlatinumV130/Documentation/TrainerPokemon.txt`).
- No opponent Mega Evolves before **Commander Jupiter** in the Team Galactic Eterna Building. From then on every Gym Leader, Elite Four member, Galactic Commander/Boss and the Champion has a Mega. (Saturn's first Mega appears once Alakazam joins his team at Lake Valor.)
- The player can Mega Evolve after beating **Fantina** (the Gym after Jupiter), who hands over the **Mega Ring**.
- A trainer can Mega Evolve at most one Pokémon per battle. In multi/tag battles each opposing trainer may Mega Evolve once.
- EVs, exact natures and 31 IVs need the trainer-data engine extension described in `TechnicalDesign.md`. Until that exists, natures/EVs are design intent only.
- Mega abilities that do not exist in the Gen IV engine are flagged **⚙** — see `MegaEvolution.md` for the fallback each uses until the ability is implemented.
- Renegade Platinum used one of four random teams for each Elite Four member and Cynthia in Round 1. Imperial uses one fixed, optimised team per format (picked from Renegade's four and re-tuned), so the singles/doubles choice is meaningful.

## Story battles

### Commander Jupiter — Team Galactic Eterna Building
_Format: singles_ · First trainer in the game to Mega Evolve. Sableye moved to the last slot as her ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Golbat | 26 | None | Jolly | Inner Focus | Wing Attack, Poison Fang, Bite, Confuse Ray | 4/252/0/0/0/252 |
| Tangela | 26 | Big Root | Modest | Chlorophyll | Giga Drain, Shock Wave, Leech Seed, Sleep Powder | 252/0/0/252/4/0 |
| Skuntank | 26 | Sitrus Berry | Adamant | Aftermath | Poison Jab, Night Slash, Toxic, Torment | 252/252/0/0/4/0 |
| Sableye → **Mega Sableye** (Dark/Ghost) | 27 | Sablenite | Adamant | Magic Guard → **Magic Bounce** ⚙ | Fake Out, Shadow Claw, Knock Off, Will-O-Wisp | 252/252/4/0/0/0 |

### Elite Four Aaron — Route 208 (Renegade's early Aaron battle)
_Format: singles_ · Comes after Jupiter, so Aaron Mega Evolves here too (E4 members "henceforth" have Megas). Scizor promoted to ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Dustox | 31 | Leftovers | Calm | Shield Dust | Bug Buzz, Toxic, Protect, Moonlight | 252/0/0/4/252/0 |
| Beautifly | 31 | Focus Sash | Modest | Swarm | Bug Buzz, Air Slash, Energy Ball, Psychic | 4/0/0/252/0/252 |
| Venomoth | 31 | Wise Glasses | Timid | Tinted Lens | Bug Buzz, Psychic, Sludge Bomb, Sleep Powder | 4/0/0/252/0/252 |
| Drapion | 31 | Scope Lens | Jolly | Sniper | Cross Poison, X-Scissor, Night Slash, Swords Dance | 4/252/0/0/0/252 |
| Scizor → **Mega Scizor** (Bug/Steel) | 32 | Scizorite | Adamant | Technician → **Technician** | Bullet Punch, X-Scissor, Iron Head, Swords Dance | 248/252/0/0/8/0 |

### Leader Fantina — Hearthome Gym
_Format: singles_ · Beating Fantina unlocks Mega Evolution for the player (she gives the Mega Ring). Gengar promoted to ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Drifblim | 32 | Starf Berry | Modest | Unburden | Shadow Ball, Air Slash, Baton Pass, Calm Mind | 252/0/0/252/4/0 |
| Dusclops | 32 | Leftovers | Impish | Pressure | Shadow Punch, Will-O-Wisp, Protect, Pain Split | 252/0/252/0/4/0 |
| Banette | 32 | Muscle Band | Adamant | Insomnia | Shadow Claw, Will-O-Wisp, Sucker Punch, Disable | 252/252/0/0/4/0 |
| Spiritomb | 32 | Zoom Lens | Relaxed | Pressure | Shadow Ball, Will-O-Wisp, Dark Pulse, Disable | 252/0/4/0/252/0 |
| Mismagius | 32 | Sitrus Berry | Timid | Levitate | Shadow Ball, Power Gem, Calm Mind, Dazzling Gleam | 4/0/0/252/0/252 |
| Gengar → **Mega Gengar** (Ghost/Poison) | 33 | Gengarite | Timid | Levitate → **Shadow Tag** | Shadow Ball, Sludge Bomb, Focus Blast, Will-O-Wisp | 4/0/0/252/0/252 |

### Leader Maylene — Veilstone Gym
_Format: singles_

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Medicham | 38 | Sitrus Berry | Jolly | Pure Power | High Jump Kick, Zen Headbutt, Ice Punch, Fake Out | 4/252/0/0/0/252 |
| Machamp | 38 | Toxic Orb | Adamant | Guts | Close Combat, Payback, Thunder Punch, Protect | 252/252/0/0/4/0 |
| Infernape | 38 | Life Orb | Hasty | Iron Fist | Close Combat, Rock Slide, Fire Punch, Mach Punch | 0/252/0/4/0/252 |
| Toxicroak | 38 | Big Root | Adamant | Dry Skin | Drain Punch, Poison Jab, Ice Punch, Sucker Punch | 252/252/0/0/4/0 |
| Gallade | 38 | Light Clay | Adamant | Steadfast | Drain Punch, Zen Headbutt, Light Screen, Reflect | 252/252/0/0/4/0 |
| Lucario → **Mega Lucario Z** (Fighting/Steel) | 39 | Lucarionite Z | Timid | Adaptability → **Aura Guard** ⚙ | Aura Sphere, Flash Cannon, Dark Pulse, Nasty Plot | 4/0/0/252/0/252 |

### Leader Wake — Pastoria Gym
_Format: singles_ · Sharpedo promoted to ace. Mega Sharpedo loses Speed Boost, so Protect was dropped.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Quagsire | 43 | Rindo Berry | Adamant | Water Absorb | Aqua Tail, Earthquake, Recover, Ice Punch | 252/252/0/0/4/0 |
| Gyarados | 43 | Wacan Berry | Jolly | Intimidate | Aqua Tail, Ice Fang, Crunch, Dragon Dance | 4/252/0/0/0/252 |
| Poliwrath | 43 | Sitrus Berry | Careful | Water Absorb | Waterfall, Drain Punch, Ice Punch, Hypnosis | 252/4/0/0/252/0 |
| Ludicolo | 43 | Life Orb | Modest | Swift Swim | Hydro Pump, Ice Beam, Energy Ball, Fake Out | 4/0/0/252/0/252 |
| Floatzel | 43 | Life Orb | Jolly | Swift Swim | Aqua Tail, Crunch, Ice Punch, Aqua Jet | 4/252/0/0/0/252 |
| Sharpedo → **Mega Sharpedo** (Water/Dark) | 44 | Sharpedonite | Jolly | Speed Boost → **Strong Jaw** ⚙ | Waterfall, Crunch, Ice Fang, Earthquake | 4/252/0/0/0/252 |

### Galactic Boss Cyrus — Celestic Town
_Format: singles_ · Gyarados joins Cyrus's team from his first battle so he has a Mega every time he is fought.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Crobat | 45 | Wise Glasses | Timid | Inner Focus | Sludge Bomb, Air Slash, Giga Drain, Hypnosis | 4/0/0/252/0/252 |
| Honchkrow | 45 | Scope Lens | Adamant | Super Luck | Brave Bird, Night Slash, Sucker Punch, Torment | 252/252/0/0/4/0 |
| Magnezone | 45 | Life Orb | Modest | Magnet Pull | Thunderbolt, Flash Cannon, Thunder Wave, Mirror Coat | 252/0/0/252/4/0 |
| Weavile | 45 | Expert Belt | Jolly | Technician | Feint Attack, Icicle Crash, Ice Shard, Swords Dance | 4/252/0/0/0/252 |
| Gyarados → **Mega Gyarados** (Water/Dark) | 46 | Gyaradosite | Jolly | Intimidate → **Mold Breaker** | Waterfall, Crunch, Ice Fang, Dragon Dance | 4/252/0/0/0/252 |

### Commander Saturn — Lake Valor
_Format: singles_ · Alakazam's first appearance on Saturn's team, so this is Saturn's first Mega. (His Route 212/Great Marsh-era battle without Alakazam is unchanged.)

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Octillery | 52 | Expert Belt | Modest | Suction Cups | Hydro Pump, Seed Bomb, Flamethrower, Flash Cannon | 252/0/0/252/4/0 |
| Bronzong | 52 | Bright Powder | Relaxed | Levitate | Iron Head, Zen Headbutt, Shadow Ball, Explosion | 252/4/252/0/0/0 |
| Rhydon | 52 | Muscle Band | Adamant | Rock Head | Stone Edge, Earthquake, Hammer Arm, Megahorn | 252/252/0/0/4/0 |
| Toxicroak | 52 | Life Orb | Jolly | Dry Skin | Gunk Shot, Cross Chop, Fake Out, Sucker Punch | 4/252/0/0/0/252 |
| Alakazam → **Mega Alakazam** (Psychic) | 53 | Alakazite | Timid | Magic Guard → **Trace** | Psychic, Shadow Ball, Focus Blast, Calm Mind | 4/0/0/252/0/252 |

### Commander Mars — Lake Verity
_Format: singles_ · Kangaskhan promoted to ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Crobat | 52 | Bright Powder | Jolly | Inner Focus | Brave Bird, Hypnosis, Double Team, Giga Drain | 4/252/0/0/0/252 |
| Yanmega | 52 | Wise Glasses | Timid | Speed Boost | Bug Buzz, Air Slash, Psychic, Detect | 4/0/0/252/0/252 |
| Bronzong | 52 | Leftovers | Relaxed | Levitate | Stealth Rock, Gyro Ball, Payback, Explosion | 252/4/252/0/0/0 |
| Purugly | 52 | Sitrus Berry | Jolly | Thick Fat | Body Slam, Play Rough, Hypnosis, Fake Out | 4/252/0/0/0/252 |
| Kangaskhan → **Mega Kangaskhan** (Normal) | 53 | Kangaskhanite | Adamant | Scrappy → **Parental Bond** ⚙ | Double-Edge, Crunch, Sucker Punch, Fake Out | 4/252/0/0/0/252 |

### Galactic Boss Cyrus — Team Galactic HQ
_Format: singles_ · Gyarados added as a sixth Pokémon and ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Crobat | 57 | Choice Band | Jolly | Inner Focus | Brave Bird, U-turn, Cross Poison, Zen Headbutt | 4/252/0/0/0/252 |
| Honchkrow | 57 | Scope Lens | Adamant | Super Luck | Brave Bird, Night Slash, Thunder Wave, Heat Wave | 252/252/0/0/4/0 |
| Houndoom | 57 | Life Orb | Timid | Intimidate | Dark Pulse, Flamethrower, Sludge Bomb, Nasty Plot | 4/0/0/252/0/252 |
| Magnezone | 57 | Wise Glasses | Modest | Magnet Pull | Thunderbolt, Flash Cannon, Signal Beam, Mirror Coat | 252/0/0/252/4/0 |
| Weavile | 57 | Expert Belt | Jolly | Technician | Crunch, Icicle Crash, Aerial Ace, X-Scissor | 4/252/0/0/0/252 |
| Gyarados → **Mega Gyarados** (Water/Dark) | 58 | Gyaradosite | Adamant | Intimidate → **Mold Breaker** | Waterfall, Crunch, Earthquake, Dragon Dance | 4/252/0/0/0/252 |

### Commander Saturn — Team Galactic HQ
_Format: singles_ · Alakazam promoted to ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Bronzong | 56 | Light Clay | Relaxed | Levitate | Zen Headbutt, Gyro Ball, Reflect, Light Screen | 252/4/252/0/0/0 |
| Octillery | 56 | Expert Belt | Modest | Suction Cups | Hydro Pump, Ice Beam, Fire Blast, Energy Ball | 252/0/0/252/4/0 |
| Rhyperior | 56 | Choice Band | Adamant | Solid Rock | Stone Edge, Earthquake, Megahorn, Ice Punch | 252/252/0/0/4/0 |
| Magmortar | 56 | Choice Specs | Modest | Flame Body | Fire Blast, Thunderbolt, Focus Blast, Psychic | 4/0/0/252/0/252 |
| Toxicroak | 56 | Focus Sash | Jolly | Dry Skin | Cross Chop, Gunk Shot, Ice Punch, Fake Out | 4/252/0/0/0/252 |
| Alakazam → **Mega Alakazam** (Psychic) | 57 | Alakazite | Timid | Magic Guard → **Trace** | Psychic, Shadow Ball, Focus Blast, Dazzling Gleam | 4/0/0/252/0/252 |

### Leader Byron — Canalave Gym
_Format: singles_ · Mega Aggron chosen over Mega Steelix. Mega Aggron becomes pure Steel (losing its 4x Fighting/Ground weaknesses) and gets Filter, which suits Byron's defensive style; Mega Steelix's Sand Force would need a sand setter Byron doesn't have. Aggron promoted to ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Bronzong | 52 | Light Clay | Impish | Levitate | Gyro Ball, Stealth Rock, Reflect, Light Screen | 252/4/252/0/0/0 |
| Magnezone | 52 | Wise Glasses | Modest | Magnet Pull | Thunderbolt, Flash Cannon, Signal Beam, Thunder Wave | 252/0/0/252/4/0 |
| Steelix | 52 | Muscle Band | Adamant | Rock Head | Gyro Ball, Earthquake, Stone Edge, Explosion | 252/252/0/0/4/0 |
| Forretress | 52 | Sitrus Berry | Impish | Sturdy | Gyro Ball, Spikes, Toxic Spikes, Explosion | 252/4/252/0/0/0 |
| Bastiodon | 52 | Leftovers | Sassy | Soundproof | Iron Head, Toxic, Protect, Metal Burst | 252/0/4/0/252/0 |
| Aggron → **Mega Aggron** (Steel) | 53 | Aggronite | Adamant | Rock Head → **Filter** | Iron Head, Earthquake, Stone Edge, Rock Polish | 252/252/0/0/4/0 |

### Leader Candice — Snowpoint Gym
_Format: singles_

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Abomasnow | 55 | Expert Belt | Brave | Snow Warning | Wood Hammer, Earthquake, Blizzard, Ice Shard | 252/252/0/4/0/0 |
| Weavile | 55 | Focus Sash | Jolly | Technician | Crunch, Icicle Crash, Ice Shard, Swords Dance | 4/252/0/0/0/252 |
| Glaceon | 55 | Bright Powder | Bold | Snow Cloak | Blizzard, Shadow Ball, Earth Power, Wish | 252/0/252/4/0/0 |
| Walrein | 55 | Chople Berry | Modest | Thick Fat | Blizzard, Surf, Yawn, Aqua Ring | 252/0/0/252/4/0 |
| Mamoswine | 55 | Passho Berry | Jolly | Thick Fat | Earthquake, Icicle Crash, Stone Edge, Ice Shard | 4/252/0/0/0/252 |
| Froslass → **Mega Froslass** (Ice/Ghost) | 56 | Froslassite | Timid | Levitate → **Snow Warning** | Blizzard, Shadow Ball, Thunderbolt, Will-O-Wisp | 4/0/0/252/0/252 |

### Commander Mars — Spear Pillar
_Format: multi_ · Multi battle (Mars + Jupiter vs. the player + Barry). Each commander may Mega Evolve once.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Crobat | 57 | Life Orb | Jolly | Inner Focus | Brave Bird, Sludge Bomb, Confuse Ray, Taunt | 4/252/0/0/0/252 |
| Yanmega | 57 | Wise Glasses | Timid | Speed Boost | Bug Buzz, Hurricane, Shadow Ball, Detect | 4/0/0/252/0/252 |
| Bronzong | 57 | Leftovers | Relaxed | Levitate | Trick Room, Gyro Ball, Zen Headbutt, Earthquake | 252/4/252/0/0/0 |
| Electivire | 57 | Expert Belt | Adamant | Motor Drive | Thunder Punch, Ice Punch, Cross Chop, Fire Punch | 4/252/0/0/0/252 |
| Purugly | 57 | Sitrus Berry | Jolly | Thick Fat | Body Slam, Play Rough, Fake Out, Hypnosis | 4/252/0/0/0/252 |
| Kangaskhan → **Mega Kangaskhan** (Normal) | 58 | Kangaskhanite | Adamant | Scrappy → **Parental Bond** ⚙ | Double-Edge, Crunch, Hammer Arm, Fake Out | 4/252/0/0/0/252 |

### Commander Jupiter — Spear Pillar
_Format: multi_ · Multi battle partner of Mars. Sableye promoted to ace.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Crobat | 57 | Bright Powder | Jolly | Inner Focus | Brave Bird, Sludge Bomb, Taunt, Hypnosis | 4/252/0/0/0/252 |
| Bronzong | 57 | Leftovers | Sassy | Levitate | Psychic, Flash Cannon, Grass Knot, Hypnosis | 252/0/0/4/252/0 |
| Tangrowth | 57 | Big Root | Modest | Chlorophyll | Giga Drain, Leech Seed, Focus Blast, Sludge Bomb | 252/0/0/252/4/0 |
| Gastrodon | 57 | Wise Glasses | Modest | Sticky Hold | Muddy Water, Earth Power, Ice Beam, Recover | 252/0/0/252/4/0 |
| Skuntank | 57 | Sitrus Berry | Adamant | Aftermath | Gunk Shot, Crunch, Play Rough, Sucker Punch | 252/252/0/0/4/0 |
| Sableye → **Mega Sableye** (Dark/Ghost) | 58 | Sablenite | Careful | Magic Guard → **Magic Bounce** ⚙ | Fake Out, Will-O-Wisp, Knock Off, Shadow Claw | 252/4/0/0/252/0 |

### Galactic Boss Cyrus — Distortion World
_Format: singles_ · Gyarados (already on this team in Renegade) is the Mega and moved to the ace slot.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Crobat | 59 | Choice Band | Jolly | Inner Focus | Brave Bird, U-turn, Cross Poison, Zen Headbutt | 4/252/0/0/0/252 |
| Honchkrow | 59 | White Herb | Adamant | Super Luck | Brave Bird, Sucker Punch, Thunder Wave, Superpower | 252/252/0/0/4/0 |
| Houndoom | 59 | Life Orb | Timid | Intimidate | Dark Pulse, Flamethrower, Sludge Bomb, Nasty Plot | 4/0/0/252/0/252 |
| Magnezone | 59 | Wise Glasses | Modest | Magnet Pull | Thunderbolt, Flash Cannon, Signal Beam, Mirror Coat | 252/0/0/252/4/0 |
| Weavile | 59 | Focus Sash | Jolly | Technician | Feint Attack, Icicle Crash, Ice Shard, Swords Dance | 4/252/0/0/0/252 |
| Gyarados → **Mega Gyarados** (Water/Dark) | 60 | Gyaradosite | Jolly | Intimidate → **Mold Breaker** | Waterfall, Crunch, Earthquake, Dragon Dance | 4/252/0/0/0/252 |

### Leader Volkner — Sunyshore Gym
_Format: singles_ · Raichu promoted to ace. Mega Raichu Y's No Guard makes Thunder and Focus Blast never miss.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Jolteon | 61 | Focus Sash | Timid | Volt Absorb | Thunderbolt, Shadow Ball, Grass Knot, Thunder Wave | 4/0/0/252/0/252 |
| Rotom-Wash | 61 | Sitrus Berry | Modest | Levitate | Thunderbolt, Hydro Pump, Shadow Ball, Thunder Wave | 252/0/0/252/4/0 |
| Rotom-Heat | 61 | White Herb | Modest | Levitate | Thunderbolt, Overheat, Shadow Ball, Will-O-Wisp | 252/0/0/252/4/0 |
| Luxray | 61 | Choice Band | Adamant | Intimidate | Wild Charge, Crunch, Ice Fang, Fire Fang | 4/252/0/0/0/252 |
| Electivire | 61 | Life Orb | Jolly | Motor Drive | Wild Charge, Close Combat, Ice Punch, Earthquake | 4/252/0/0/0/252 |
| Raichu → **Mega Raichu Y** (Electric) | 62 | Raichunite Y | Timid | Static → **No Guard** | Thunder, Focus Blast, Grass Knot, Nasty Plot | 4/0/0/252/0/252 |

### Leader Volkner & Elite Four Flint — Fight Area (post-game double battle)
_Format: doubles_ · Both partners Mega Evolve. Flint's Flareon is replaced by Houndoom.

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Jolteon _(Volkner)_ | 74 | Focus Sash | Timid | Volt Absorb | Thunderbolt, Shadow Ball, Thunder Wave, Protect | 4/0/0/252/0/252 |
| Electivire _(Volkner)_ | 74 | Life Orb | Jolly | Motor Drive | Wild Charge, Close Combat, Ice Punch, Protect | 4/252/0/0/0/252 |
| Raichu → **Mega Raichu Y** (Electric) _(Volkner)_ | 75 | Raichunite Y | Timid | Static → **No Guard** | Thunder, Focus Blast, Grass Knot, Protect | 4/0/0/252/0/252 |
| Arcanine _(Flint)_ | 74 | Sitrus Berry | Adamant | Intimidate | Flare Blitz, Extreme Speed, Wild Charge, Protect | 4/252/0/0/0/252 |
| Magmortar _(Flint)_ | 74 | Life Orb | Modest | Flame Body | Heat Wave, Thunderbolt, Focus Blast, Protect | 4/0/0/252/0/252 |
| Houndoom → **Mega Houndoom** (Dark/Fire) _(Flint)_ | 75 | Houndoominite | Timid | Intimidate → **Solar Power** | Heat Wave, Dark Pulse, Nasty Plot, Protect | 4/0/0/252/0/252 |

## Pokémon League

See `EliteFourFormat.md` for how singles/doubles are chosen.

### Elite Four Aaron — Round 1 (first challenge)
**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Yanmega | 71 | Wise Glasses | Timid | Speed Boost | Bug Buzz, Air Slash, Giga Drain, Protect | 4/0/0/252/0/252 |
| Vespiquen | 71 | Leftovers | Impish | Intimidate | Attack Order, Defend Order, Heal Order, Toxic | 252/4/252/0/0/0 |
| Heracross | 71 | Choice Scarf | Jolly | Guts | Megahorn, Close Combat, Stone Edge, Night Slash | 4/252/0/0/0/252 |
| Armaldo | 71 | Choice Band | Adamant | Battle Armor | X-Scissor, Stone Edge, Earthquake, Aqua Tail | 252/252/0/0/4/0 |
| Drapion | 71 | Scope Lens | Jolly | Sniper | Cross Poison, Night Slash, X-Scissor, Earthquake | 4/252/0/0/0/252 |
| Scizor → **Mega Scizor** (Bug/Steel) | 72 | Scizorite | Adamant | Technician → **Technician** | Bullet Punch, Bug Bite, Superpower, Swords Dance | 248/252/0/0/8/0 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Vespiquen | 71 | Sitrus Berry | Impish | Intimidate | Attack Order, Heal Order, Toxic, Protect | 252/4/252/0/0/0 |
| Yanmega | 71 | Wise Glasses | Timid | Speed Boost | Bug Buzz, Air Slash, Giga Drain, Protect | 4/0/0/252/0/252 |
| Heracross | 71 | Toxic Orb | Jolly | Guts | Megahorn, Close Combat, Rock Slide, Protect | 4/252/0/0/0/252 |
| Armaldo | 71 | Lum Berry | Adamant | Battle Armor | X-Scissor, Rock Slide, Aqua Tail, Protect | 252/252/0/0/4/0 |
| Drapion | 71 | Scope Lens | Jolly | Sniper | Cross Poison, Night Slash, Ice Fang, Protect | 4/252/0/0/0/252 |
| Scizor → **Mega Scizor** (Bug/Steel) | 72 | Scizorite | Adamant | Technician → **Technician** | Bullet Punch, Bug Bite, Swords Dance, Protect | 248/252/0/0/8/0 |

### Elite Four Bertha — Round 1 (first challenge)
**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Claydol | 72 | Light Clay | Sassy | Levitate | Earthquake, Psychic, Reflect, Light Screen | 252/0/4/0/252/0 |
| Swampert | 72 | Leftovers | Adamant | Torrent | Earthquake, Waterfall, Ice Punch, Stealth Rock | 252/252/0/0/4/0 |
| Dugtrio | 72 | Focus Sash | Jolly | Arena Trap | Earthquake, Stone Edge, Sucker Punch, Night Slash | 4/252/0/0/0/252 |
| Mamoswine | 72 | Life Orb | Jolly | Thick Fat | Earthquake, Icicle Crash, Ice Shard, Stone Edge | 4/252/0/0/0/252 |
| Rhyperior | 72 | Choice Band | Adamant | Solid Rock | Earthquake, Stone Edge, Megahorn, Ice Punch | 252/252/0/0/4/0 |
| Tyranitar → **Mega Tyranitar** (Rock/Dark) | 73 | Tyranitarite | Jolly | Sand Stream → **Sand Stream** | Stone Edge, Crunch, Earthquake, Dragon Dance | 4/252/0/0/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Hippowdon | 72 | Sitrus Berry | Impish | Sand Stream | Earthquake, Crunch, Slack Off, Yawn | 252/4/252/0/0/0 |
| Gliscor | 72 | Toxic Orb | Jolly | Poison Heal | Earthquake, Rock Slide, Swords Dance, Protect | 4/252/0/0/0/252 |
| Claydol | 72 | Light Clay | Sassy | Levitate | Earthquake, Psychic, Reflect, Light Screen | 252/0/4/0/252/0 |
| Rhyperior | 72 | Sitrus Berry | Adamant | Solid Rock | Rock Slide, Earthquake, Megahorn, Protect | 252/252/0/0/4/0 |
| Mamoswine | 72 | Life Orb | Jolly | Thick Fat | Icicle Crash, Earthquake, Ice Shard, Protect | 4/252/0/0/0/252 |
| Tyranitar → **Mega Tyranitar** (Rock/Dark) | 73 | Tyranitarite | Jolly | Sand Stream → **Sand Stream** | Rock Slide, Crunch, Dragon Dance, Protect | 4/252/0/0/0/252 |

### Elite Four Flint — Round 1 (first challenge)
**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Ninetales | 73 | Heat Rock | Timid | Drought | Fire Blast, Solar Beam, Moonblast, Nasty Plot | 4/0/0/252/0/252 |
| Flareon | 73 | Choice Band | Adamant | Flash Fire | Flare Blitz, Superpower, Quick Attack, Wild Charge | 252/252/0/0/4/0 |
| Rapidash | 73 | Life Orb | Jolly | Flame Body | Flare Blitz, Wild Charge, Megahorn, Drill Run | 4/252/0/0/0/252 |
| Infernape | 73 | Expert Belt | Hasty | Iron Fist | Flare Blitz, Close Combat, Thunder Punch, Mach Punch | 0/252/0/4/0/252 |
| Magmortar | 73 | Life Orb | Modest | Flame Body | Fire Blast, Thunderbolt, Focus Blast, Solar Beam | 4/0/0/252/0/252 |
| Houndoom → **Mega Houndoom** (Dark/Fire) | 74 | Houndoominite | Timid | Intimidate → **Solar Power** | Fire Blast, Dark Pulse, Solar Beam, Nasty Plot | 4/0/0/252/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Ninetales | 73 | Heat Rock | Timid | Drought | Heat Wave, Solar Beam, Moonblast, Protect | 4/0/0/252/0/252 |
| Infernape | 73 | Focus Sash | Jolly | Iron Fist | Fake Out, Flare Blitz, Close Combat, Mach Punch | 4/252/0/0/0/252 |
| Arcanine | 73 | Sitrus Berry | Adamant | Intimidate | Flare Blitz, Extreme Speed, Wild Charge, Protect | 4/252/0/0/0/252 |
| Rapidash | 73 | Life Orb | Jolly | Flame Body | Flare Blitz, Wild Charge, Megahorn, Protect | 4/252/0/0/0/252 |
| Magmortar | 73 | Life Orb | Modest | Flame Body | Heat Wave, Thunderbolt, Focus Blast, Protect | 4/0/0/252/0/252 |
| Houndoom → **Mega Houndoom** (Dark/Fire) | 74 | Houndoominite | Timid | Intimidate → **Solar Power** | Heat Wave, Dark Pulse, Nasty Plot, Protect | 4/0/0/252/0/252 |

### Elite Four Lucian — Round 1 (first challenge)
**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Mr. Mime | 74 | Light Clay | Timid | Filter | Psychic, Dazzling Gleam, Reflect, Light Screen | 252/0/0/4/0/252 |
| Espeon | 74 | Life Orb | Timid | Synchronize | Psychic, Dazzling Gleam, Shadow Ball, Calm Mind | 4/0/0/252/0/252 |
| Bronzong | 74 | Leftovers | Relaxed | Levitate | Gyro Ball, Earthquake, Stealth Rock, Hypnosis | 252/4/252/0/0/0 |
| Alakazam | 74 | Life Orb | Timid | Magic Guard | Psychic, Shadow Ball, Focus Blast, Energy Ball | 4/0/0/252/0/252 |
| Gallade | 74 | Scope Lens | Jolly | Steadfast | Psycho Cut, Close Combat, Leaf Blade, Night Slash | 4/252/0/0/0/252 |
| Metagross → **Mega Metagross** (Steel/Psychic) | 75 | Metagrossite | Jolly | Clear Body → **Tough Claws** ⚙ | Meteor Mash, Zen Headbutt, Earthquake, Ice Punch | 4/252/0/0/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Mr. Mime | 74 | Light Clay | Timid | Filter | Fake Out, Psychic, Reflect, Light Screen | 252/0/0/4/0/252 |
| Espeon | 74 | Life Orb | Timid | Synchronize | Psychic, Dazzling Gleam, Shadow Ball, Protect | 4/0/0/252/0/252 |
| Bronzong | 74 | Sitrus Berry | Relaxed | Levitate | Gyro Ball, Psychic, Hypnosis, Protect | 252/4/252/0/0/0 |
| Alakazam | 74 | Focus Sash | Timid | Magic Guard | Psychic, Shadow Ball, Focus Blast, Protect | 4/0/0/252/0/252 |
| Gallade | 74 | Lum Berry | Jolly | Steadfast | Psycho Cut, Close Combat, Leaf Blade, Protect | 4/252/0/0/0/252 |
| Metagross → **Mega Metagross** (Steel/Psychic) | 75 | Metagrossite | Jolly | Clear Body → **Tough Claws** ⚙ | Meteor Mash, Zen Headbutt, Bullet Punch, Protect | 4/252/0/0/0/252 |

### Champion Cynthia — Round 1 (first challenge)
_Always a double battle on the first challenge. Singles set is used only by the "all singles" rematch option (see Round 2) — the Round 1 singles set is provided for completeness/testing._

**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Spiritomb | 77 | Leftovers | Calm | Pressure | Dark Pulse, Shadow Ball, Will-O-Wisp, Pain Split | 252/0/4/0/252/0 |
| Roserade | 77 | White Herb | Timid | Technician | Leaf Storm, Sludge Bomb, Dazzling Gleam, Sleep Powder | 4/0/0/252/0/252 |
| Togekiss | 77 | Leftovers | Timid | Serene Grace | Air Slash, Moonblast, Aura Sphere, Roost | 4/0/0/252/0/252 |
| Lucario | 77 | Life Orb | Jolly | Adaptability | High Jump Kick, Meteor Mash, Extreme Speed, Ice Punch | 4/252/0/0/0/252 |
| Milotic | 77 | Leftovers | Bold | Marvel Scale | Scald, Moonblast, Ice Beam, Recover | 252/0/252/4/0/0 |
| Garchomp → **Mega Garchomp Z** (Dragon) | 78 | Garchompite Z | Naive | Rough Skin → **Levitate** | Draco Meteor, Earthquake, Fire Blast, Stone Edge | 0/128/0/128/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Togekiss | 77 | Sitrus Berry | Timid | Serene Grace | Air Slash, Moonblast, Tailwind, Protect | 252/0/0/4/0/252 |
| Spiritomb | 77 | Leftovers | Calm | Pressure | Dark Pulse, Shadow Ball, Will-O-Wisp, Pain Split | 252/0/4/0/252/0 |
| Roserade | 77 | White Herb | Timid | Technician | Leaf Storm, Sludge Bomb, Sleep Powder, Protect | 4/0/0/252/0/252 |
| Milotic | 77 | Leftovers | Bold | Marvel Scale | Scald, Moonblast, Ice Beam, Recover | 252/0/252/4/0/0 |
| Lucario | 77 | Life Orb | Jolly | Adaptability | Close Combat, Meteor Mash, Extreme Speed, Protect | 4/252/0/0/0/252 |
| Garchomp → **Mega Garchomp Z** (Dragon) | 78 | Garchompite Z | Naive | Rough Skin → **Levitate** | Draco Meteor, Rock Slide, Fire Blast, Protect | 0/128/0/128/0/252 |

### Elite Four Aaron — Round 2 (rematches)
**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Yanmega | 83 | Wise Glasses | Timid | Speed Boost | Bug Buzz, Air Slash, Giga Drain, Protect | 4/0/0/252/0/252 |
| Heracross | 83 | Toxic Orb | Jolly | Guts | Megahorn, Close Combat, Stone Edge, Protect | 4/252/0/0/0/252 |
| Scyther | 83 | Life Orb | Jolly | Technician | Bug Bite, Aerial Ace, Brick Break, Quick Attack | 4/252/0/0/0/252 |
| Armaldo | 83 | Passho Berry | Adamant | Battle Armor | X-Scissor, Stone Edge, Earthquake, Aqua Jet | 252/252/0/0/4/0 |
| Drapion | 83 | Scope Lens | Jolly | Sniper | Cross Poison, Night Slash, X-Scissor, Earthquake | 4/252/0/0/0/252 |
| Scizor → **Mega Scizor** (Bug/Steel) | 84 | Scizorite | Adamant | Technician → **Technician** | Bullet Punch, Bug Bite, Superpower, Swords Dance | 248/252/0/0/8/0 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Yanmega | 83 | Wise Glasses | Timid | Speed Boost | Bug Buzz, Air Slash, Giga Drain, Protect | 4/0/0/252/0/252 |
| Heracross | 83 | Toxic Orb | Jolly | Guts | Megahorn, Close Combat, Rock Slide, Protect | 4/252/0/0/0/252 |
| Scyther | 83 | Focus Sash | Jolly | Technician | Bug Bite, Aerial Ace, Quick Attack, Protect | 4/252/0/0/0/252 |
| Armaldo | 83 | Lum Berry | Adamant | Battle Armor | X-Scissor, Rock Slide, Aqua Jet, Protect | 252/252/0/0/4/0 |
| Drapion | 83 | Scope Lens | Jolly | Sniper | Cross Poison, Night Slash, Ice Fang, Protect | 4/252/0/0/0/252 |
| Scizor → **Mega Scizor** (Bug/Steel) | 84 | Scizorite | Adamant | Technician → **Technician** | Bullet Punch, Bug Bite, Swords Dance, Protect | 248/252/0/0/8/0 |

### Elite Four Bertha — Round 2 (rematches)
**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Hippowdon | 84 | Leftovers | Impish | Sand Stream | Earthquake, Stone Edge, Stealth Rock, Slack Off | 252/4/252/0/0/0 |
| Swampert | 84 | Rindo Berry | Adamant | Torrent | Earthquake, Waterfall, Avalanche, Stealth Rock | 252/252/0/0/4/0 |
| Gliscor | 84 | Toxic Orb | Jolly | Poison Heal | Earthquake, Stone Edge, Protect, Swords Dance | 4/252/0/0/0/252 |
| Dugtrio | 84 | Choice Band | Jolly | Arena Trap | Earthquake, Stone Edge, Night Slash, Aerial Ace | 4/252/0/0/0/252 |
| Rhyperior | 84 | Focus Sash | Adamant | Solid Rock | Earthquake, Rock Wrecker, Megahorn, Hammer Arm | 252/252/0/0/4/0 |
| Tyranitar → **Mega Tyranitar** (Rock/Dark) | 85 | Tyranitarite | Jolly | Sand Stream → **Sand Stream** | Stone Edge, Crunch, Earthquake, Dragon Dance | 4/252/0/0/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Hippowdon | 84 | Sitrus Berry | Impish | Sand Stream | Earthquake, Crunch, Slack Off, Yawn | 252/4/252/0/0/0 |
| Gliscor | 84 | Toxic Orb | Jolly | Poison Heal | Earthquake, Rock Slide, Swords Dance, Protect | 4/252/0/0/0/252 |
| Swampert | 84 | Rindo Berry | Adamant | Torrent | Waterfall, Rock Slide, Ice Punch, Protect | 252/252/0/0/4/0 |
| Rhyperior | 84 | Sitrus Berry | Adamant | Solid Rock | Rock Slide, Earthquake, Megahorn, Protect | 252/252/0/0/4/0 |
| Dugtrio | 84 | Focus Sash | Jolly | Arena Trap | Earthquake, Rock Slide, Sucker Punch, Protect | 4/252/0/0/0/252 |
| Tyranitar → **Mega Tyranitar** (Rock/Dark) | 85 | Tyranitarite | Jolly | Sand Stream → **Sand Stream** | Rock Slide, Crunch, Dragon Dance, Protect | 4/252/0/0/0/252 |

### Elite Four Flint — Round 2 (rematches)
_Moltres stays the final Pokémon; Houndoom is the Mega._

**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Ninetales | 85 | Heat Rock | Timid | Drought | Fire Blast, Solar Beam, Moonblast, Nasty Plot | 4/0/0/252/0/252 |
| Magmortar | 85 | Expert Belt | Modest | Flame Body | Fire Blast, Thunderbolt, Focus Blast, Psychic | 4/0/0/252/0/252 |
| Infernape | 85 | Life Orb | Jolly | Iron Fist | Flare Blitz, Close Combat, Thunder Punch, Mach Punch | 4/252/0/0/0/252 |
| Rapidash | 85 | Life Orb | Jolly | Flame Body | Flare Blitz, Drill Run, Megahorn, Wild Charge | 4/252/0/0/0/252 |
| Houndoom → **Mega Houndoom** (Dark/Fire) | 85 | Houndoominite | Timid | Intimidate → **Solar Power** | Fire Blast, Dark Pulse, Solar Beam, Nasty Plot | 4/0/0/252/0/252 |
| Moltres | 86 | Choice Scarf | Timid | Pressure | Fire Blast, Hurricane, Solar Beam, U-turn | 4/0/0/252/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Ninetales | 85 | Heat Rock | Timid | Drought | Heat Wave, Solar Beam, Moonblast, Protect | 4/0/0/252/0/252 |
| Infernape | 85 | Focus Sash | Jolly | Iron Fist | Fake Out, Flare Blitz, Close Combat, Mach Punch | 4/252/0/0/0/252 |
| Magmortar | 85 | Life Orb | Modest | Flame Body | Heat Wave, Thunderbolt, Focus Blast, Protect | 4/0/0/252/0/252 |
| Rapidash | 85 | Life Orb | Jolly | Flame Body | Flare Blitz, Wild Charge, Megahorn, Protect | 4/252/0/0/0/252 |
| Houndoom → **Mega Houndoom** (Dark/Fire) | 85 | Houndoominite | Timid | Intimidate → **Solar Power** | Heat Wave, Dark Pulse, Nasty Plot, Protect | 4/0/0/252/0/252 |
| Moltres | 86 | Sitrus Berry | Timid | Pressure | Heat Wave, Hurricane, Solar Beam, Protect | 4/0/0/252/0/252 |

### Elite Four Lucian — Round 2 (rematches)
_Latios stays the final Pokémon (no Latiasite/Latiosite on trainers); Metagross is the Mega._

**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Mr. Mime | 86 | Light Clay | Timid | Filter | Psychic, Dazzling Gleam, Reflect, Light Screen | 252/0/0/4/0/252 |
| Espeon | 86 | Salac Berry | Timid | Synchronize | Psychic, Aura Sphere, Calm Mind, Baton Pass | 4/0/0/252/0/252 |
| Gallade | 86 | Muscle Band | Jolly | Steadfast | Zen Headbutt, Close Combat, Ice Punch, Swords Dance | 4/252/0/0/0/252 |
| Alakazam | 86 | Life Orb | Timid | Magic Guard | Psychic, Aura Sphere, Shadow Ball, Grass Knot | 4/0/0/252/0/252 |
| Metagross → **Mega Metagross** (Steel/Psychic) | 86 | Metagrossite | Jolly | Clear Body → **Tough Claws** ⚙ | Meteor Mash, Zen Headbutt, Earthquake, Ice Punch | 4/252/0/0/0/252 |
| Latios | 87 | Choice Specs | Timid | Levitate | Psychic, Draco Meteor, Ice Beam, Thunderbolt | 4/0/0/252/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Mr. Mime | 86 | Light Clay | Timid | Filter | Fake Out, Psychic, Reflect, Light Screen | 252/0/0/4/0/252 |
| Espeon | 86 | Life Orb | Timid | Synchronize | Psychic, Dazzling Gleam, Shadow Ball, Protect | 4/0/0/252/0/252 |
| Gallade | 86 | Lum Berry | Jolly | Steadfast | Psycho Cut, Close Combat, Leaf Blade, Protect | 4/252/0/0/0/252 |
| Alakazam | 86 | Focus Sash | Timid | Magic Guard | Psychic, Shadow Ball, Focus Blast, Protect | 4/0/0/252/0/252 |
| Metagross → **Mega Metagross** (Steel/Psychic) | 86 | Metagrossite | Jolly | Clear Body → **Tough Claws** ⚙ | Meteor Mash, Zen Headbutt, Bullet Punch, Protect | 4/252/0/0/0/252 |
| Latios | 87 | Life Orb | Timid | Levitate | Draco Meteor, Psychic, Ice Beam, Protect | 4/0/0/252/0/252 |

### Champion Cynthia — Round 2 (rematches)
_Singles for the "all singles" rematch option; doubles for "all doubles" and for the 2+2 format. Rayquaza stays her final Pokémon; Garchomp is the Mega._

**Singles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Spiritomb | 88 | Leftovers | Calm | Pressure | Dark Pulse, Shadow Ball, Will-O-Wisp, Calm Mind | 252/0/4/0/252/0 |
| Togekiss | 88 | Leftovers | Timid | Serene Grace | Air Slash, Moonblast, Aura Sphere, Roost | 4/0/0/252/0/252 |
| Lucario | 88 | Life Orb | Jolly | Adaptability | Meteor Mash, High Jump Kick, Crunch, Extreme Speed | 4/252/0/0/0/252 |
| Milotic | 88 | Leftovers | Bold | Marvel Scale | Scald, Moonblast, Ice Beam, Recover | 252/0/252/4/0/0 |
| Garchomp → **Mega Garchomp Z** (Dragon) | 88 | Garchompite Z | Naive | Rough Skin → **Levitate** | Draco Meteor, Earthquake, Fire Blast, Stone Edge | 0/128/0/128/0/252 |
| Rayquaza | 89 | Focus Sash | Jolly | Air Lock | Outrage, Earthquake, Extreme Speed, Dragon Dance | 4/252/0/0/0/252 |

**Doubles**

| Pokémon | Lv. | Item | Nature | Ability | Moves | EVs (HP/Atk/Def/SpA/SpD/Spe) |
|---|---|---|---|---|---|---|
| Togekiss | 88 | Sitrus Berry | Timid | Serene Grace | Air Slash, Moonblast, Tailwind, Protect | 252/0/0/4/0/252 |
| Spiritomb | 88 | Leftovers | Calm | Pressure | Dark Pulse, Shadow Ball, Will-O-Wisp, Pain Split | 252/0/4/0/252/0 |
| Lucario | 88 | Life Orb | Jolly | Adaptability | Close Combat, Meteor Mash, Extreme Speed, Protect | 4/252/0/0/0/252 |
| Milotic | 88 | Leftovers | Bold | Marvel Scale | Scald, Moonblast, Ice Beam, Recover | 252/0/252/4/0/0 |
| Garchomp → **Mega Garchomp Z** (Dragon) | 88 | Garchompite Z | Naive | Rough Skin → **Levitate** | Draco Meteor, Rock Slide, Fire Blast, Protect | 0/128/0/128/0/252 |
| Rayquaza | 89 | Life Orb | Jolly | Air Lock | Dragon Claw, Extreme Speed, Rock Slide, Protect | 4/252/0/0/0/252 |
