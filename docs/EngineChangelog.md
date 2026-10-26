# Sovereign Platinum — Engine Changelog

Changes made to the pret/pokeplatinum decompilation in `decomp/`, newest first. Each entry lists what changed for
players and the verification that was run.


## Item 11 (effect fidelity): moves, batch 5

For players: seven more moves work as in the main games. All seven were placeholders.

- **Jaw Lock:** after the hit, the user and the target are each trapped by the other (as Mean Look), until one of them
  leaves the field. Message: "Neither Pokémon can run away!". Not through a Substitute.
- **Thousand Waves:** after the hit, the target can't escape while the user is in battle. It reuses Spirit Shackle's
  subscript, but always applies, as a hit effect rather than a chance effect. That subscript now also stops at a
  Substitute.
- **Thousand Arrows:**
  - Hits Pokémon that Ground moves can't: Flying types, Levitate, an Air Balloon, Magnet Rise and Telekinesis.
  - It's neutral on a Flying type. The type chart skips the Ground-on-Flying entry for it.
  - It grounds the target, with Smack Down's effect.
- **Sparkling Aria:** a chance effect at 100%: the target's burn is healed ("...'s burn was healed!"). Shield Dust and
  Sheer Force keep it off.
- **Court Change:**
  - Swaps the two sides' field effects, with their turn counts: Reflect, Light Screen, Aurora Veil, Mist, Safeguard,
    Tailwind, Lucky Chant and the entry hazards (Spikes, Toxic Spikes, Stealth Rock, Sticky Web).
  - Message: "...swapped the battle effects affecting each side of the field!".
  - It fails when neither side has any.
- **Flower Shield:** raises the Defense of every Grass-type Pokémon on the field by 1 stage. It fails when there is
  none. Its range is now the whole field.
- **Tidy Up:**
  - Clears the entry hazards from both sides and every Substitute ("...'s substitute faded!").
  - Then "Tidying up complete!" if anything was cleared.
  - Then the user's Attack +1 and Speed +1.
- Checklist: 314 exact, 35 approximate, 31 placeholders.

**Verification:** `tools/test/check_battle_scripts.py` and `check_message_box_lines.py` pass. Harness wild battles:
- **Jaw Lock:** "Neither Pokémon can run away!".
- **Thousand Waves:** against a Slowpoke, "The wild SLOWPOKE can no longer escape!". Against a Ninjask, it doesn't
  affect the Flying type.
- **Thousand Arrows:**
  - Against a Ninjask (Bug/Flying): "It's not very effective...", then "The wild NINJASK fell straight down!".
  - Against a Gastly (Levitate): "It's super effective!", then "The wild GASTLY fell straight down!".
- **Sparkling Aria:** the wild Ninjask holds a Flame Orb. Once it's burned: "The wild NINJASK's burn was healed!".
- **Court Change:** after the wild Ninjask's Spikes, the swap message. With nothing to swap: "But it failed!".
- **Flower Shield:** "VENUSAUR's Defense rose!". With no Grass type: "But it failed!".
- **Tidy Up:**
  - After the wild Ninjask's Spikes: "Tidying up complete!", then Attack and Speed rose.
  - After the wild Ninjask's Substitute: "The wild NINJASK's substitute faded!".

## Item 11 (effect fidelity): moves, batch 4

For players: eight more moves work as in the main games. Six of them were placeholders, and Thunderclap and Toxic
Thread were approximate.

- **Thunderclap:** uses Sucker Punch's effect. It fails unless the target is about to use a damaging move.
- **Toxic Thread:** the target's Speed -1, then it's poisoned, as Swagger chains its two effects. A Substitute blocks
  it.
- **Tar Shot:** the target's Speed -1. Fire moves are then super effective once more against it, until it switches
  out.
  - The type chart reads the new `sovereignTarShot` flags.
  - Message: "...became weaker to fire!".
- **Eerie Spell:** a chance effect at 100%: the target's last move loses 3 PP. `TrySpite` takes 3 for it and 4 for Spite.
- **Corrosive Gas:** takes away the held items of all adjacent Pokémon. It uses `TryKnockOff`, with its own message,
  "...corroded ...'s ...!". Sticky Hold keeps the item.
- **Celebrate:** "Congratulations, (player)!". No effect in battle.
- **Happy Hour:** "Everyone is caught up in the happy atmosphere!". When the player's side uses it, the trainer's prize
  money doubles, on top of an Amulet Coin.
- **Hold Hands:** no effect in battle. It fails without an ally.
- Checklist: 307 exact, 35 approximate, 38 placeholders.

**Verification:** `tools/test/check_battle_scripts.py` and `check_message_box_lines.py` pass. Harness wild battles:
- **Thunderclap:** against Splash, "But it failed!". Against a slower Slowpoke's Tackle, it hits first.
- **Toxic Thread:** "The wild NINJASK's Speed fell!", then "The wild NINJASK was poisoned!".
- **Tar Shot:**
  - "The wild SNORLAX's Speed fell!", then "The wild SNORLAX became weaker to fire!".
  - Flamethrower is then "super effective" on the Normal-type Snorlax.
  - Damage rose from 7 per hit in an all-Flamethrower control run to 12-14 per hit.
- **Eerie Spell:** "It reduced the PP of the wild NINJASK's Tackle by 3!".
- **Corrosive Gas:** "SNORLAX corroded the wild NINJASK's Leftovers!". Used again with no item: "But it failed!".
- **Celebrate:** "Congratulations, A!".
- **Happy Hour:** "Everyone is caught up in the happy atmosphere!". The prize doubling isn't covered, since the
  harness runs wild battles only.
- **Hold Hands:** "But it failed!" in a single battle.

## Item 11 (effect fidelity): moves, batch 3, second half (Glaive Rush, Salt Cure, Syrup Bomb, Rage Fist)

For players: four more moves work as in the main games. Each needed state kept per Pokémon.

- **Glaive Rush:** after a hit, until the user's next move, moves against it never miss and do double damage. The
  effect also ends when the user switches out. The new `sovereignGlaiveRush` flags hold it:
  - The accuracy check reads it, next to Telekinesis and Lock-On.
  - `BtlCmd_CalcDamage` doubles the damage.
  - The status check at the start of the user's next move clears it.
- **Salt Cure:** the target loses 1/8 of its max HP at the end of each turn, or 1/4 if it's Water or Steel type, until
  it switches out.
  - Messages: "...is being salt cured!" and "...is hurt by Salt Cure!".
  - Magic Guard prevents the damage. Sheer Force, Shield Dust, Covert Cloak and a Substitute keep the effect off, as
    for any chance effect.
- **Syrup Bomb:** the target's Speed falls 1 stage at the end of each of the next 3 turns, while the user stays in.
  - Message: "...got covered in sticky candy syrup!".
  - A Mirror Armor holder sends the drop back to the Syrup Bomb's user.
- **Rage Fist:** 50 more power for each hit the user has taken from other Pokémon's moves this battle, up to 350.
  - The count is kept per party slot, so it survives switching.
  - Hits on a Substitute don't count.
- Two new end-of-turn steps, after binding: Salt Cure and Syrup Bomb.
- Checklist: 299 exact, 37 approximate, 44 placeholders.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles, reading both Pokémon's HP from
memory each turn:
- **Glaive Rush:** a Lv. 60 Ninjask's Tackle did 39 damage to Snorlax before it, and exactly 78 the turn after.
- **Salt Cure:**
  - A wild Snorlax with 448 HP loses 56 (1/8) at the end of each turn.
  - A Steelix with 278 HP loses 69 (1/4).
  - Both messages show.
- **Syrup Bomb:** "The wild SLOWPOKE got covered in sticky candy syrup!", then "The wild SLOWPOKE's Speed fell!" at
  the end of the turn.
- **Rage Fist:** against a Slowpoke, 64 damage with no hits taken. After one hit it did at least 124 (a KO). Without
  the count, it could do at most about 75.

## Item 11 (effect fidelity): moves, batch 3 (damage plus an effect)

For players: 13 more moves work as in the main games, along with a few related rules.

- **New effect scripts and subscripts:**
  - **Dire Claw:** 50% chance of sleep, poison or paralysis (one of the three, equally likely). High critical-hit
    ratio.
  - **Triple Arrows:** 50% chance of target Defense -1, then a separate 30% chance of a flinch. High critical-hit
    ratio. The second chance is a new read-only battle var, `BTLVAR_SOVEREIGN_SECOND_EFFECT`.
  - **Ceaseless Edge, Stone Axe:** after the hit, lay a layer of Spikes or set Stealth Rock on the foes' side, even
    through a Substitute. Not with Sheer Force, which powers them up instead. High critical-hit ratio.
  - **Axe Kick:** 30% confusion, and Hi Jump Kick's crash damage on a miss.
  - **Mortal Spin:** poisons the foes (Shield Dust doesn't stop it), then frees the user from binding, Leech Seed and
    its side's hazards.
  - **Matcha Gotcha:** hits both foes, drains half the damage dealt, and has a 20% burn chance. It thaws out a frozen
    user.
  - **Relic Song, Wicked Torque:** 10% sleep. Relic Song still changes Meloetta's Forme.
- **Multi-hit moves:**
  - **Surging Strikes, Triple Dive:** always hit 3 times. Surging Strikes rolled 2-5 before.
  - **Population Bomb:** hits up to 10 times and checks accuracy on each hit. With Loaded Dice it hits 4-10 times;
    with Skill Link, 10 times.
  - Skill Link and Loaded Dice now make Triple Kick, Triple Axel and Population Bomb check accuracy only once.
- **Rules these moves needed:**
  - **Fang moves:** Sheer Force now removes the Fire, Ice and Thunder Fangs' chance effects (it already powered them
    up). Covert Cloak now blocks them too.
  - **Thawing out:** Fusion Flare, Scald, Steam Eruption, Burn Up, Scorching Sands, Pyro Ball and Matcha Gotcha thaw
    out a frozen user. Scald, Steam Eruption and Scorching Sands thaw out a frozen target too.
  - **Rapid Spin:** now also raises the user's Speed 1 stage, as since Gen VIII.
- **Gen IX values the move data had wrong:**
  - Cotton Spore and Poison Gas hit both foes.
  - Take Heart has 15 PP.
  - Roar and Whirlwind never miss.
  - The new `VALUE_FIXES` table in `tools/engine/gen9_move_fixes.py` holds them. The other differences from Showdown
    are the Champions values in `docs/BattleMechanics.md`, and they stay.
- Checklist: 295 exact, 37 approximate, 48 placeholders.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles against a Ninjask (a Slowpoke
for Triple Arrows, so the user moves first). For the chance effects, the lead is a Serene Grace Togekiss:
- **Dire Claw:** "The wild NINJASK is paralyzed!".
- **Triple Arrows:** "The wild SLOWPOKE's Defense fell!", then "The wild SLOWPOKE flinched!".
- **Ceaseless Edge:** "Spikes were scattered all around the feet of the foe's team!" on each hit.
- **Stone Axe:** "Pointed stones float in the air around your foe's team!". A miss sets nothing.
- **Axe Kick:** "The wild NINJASK became confused!". Into Protect: "SNORLAX kept going and crashed!".
- **Mortal Spin:** after the Ninjask's Spikes, "The wild NINJASK was poisoned!", then "SNORLAX blew away Spikes!".
- **Matcha Gotcha:** "The wild NINJASK had its energy drained!", then "The wild NINJASK was burned!".
- **Wicked Torque:** "The wild NINJASK fell asleep!".
- **Relic Song:** "MELOETTA transformed!".
- **Multi-hit moves:**
  - Population Bomb: "Hit 10 time(s)!"; with Loaded Dice, "Hit 9 time(s)!".
  - Triple Dive: "Hit 3 time(s)!".
  - Surging Strikes: a critical hit, "Hit 3 time(s)!".
- **Rapid Spin:** "SNORLAX blew away Spikes!", then "SNORLAX's Speed rose!".

## Item 11 (effect fidelity): moves, batch 2 (status moves)

For players: 11 more status moves work as in the main games. Ten of them did nothing before; Clangorous Soul now
costs HP.

- **Through `tools/engine/gen_stat_moves.py`:**
  - **Spicy Extract:** the target's Attack +2 and Defense -2.
  - **Fillet Away:** the user's Attack, Sp. Atk and Speed +2, for 1/2 of its max HP. It fails at 1/2 or less.
  - **Take Heart:** the user's Sp. Atk and Sp. Def +1, and its status condition is healed.
  - **Clangorous Soul:** now costs 1/3 of the user's max HP, and fails at 1/3 or less. It was approximate.
  - The generator has two new options: `hp_cost_N` and `cure`.
- **Hand-written subscripts** (`subscript_sovereign_<move>.s`):
  - **Topsy-Turvy:** inverts the target's stat stages. It fails when they're all neutral.
  - **Reflect Type:** the user takes the target's types. It fails for Arceus and Silvally.
  - **Magic Powder:** the target becomes pure Psychic-type. It fails if the target is already Psychic.
  - **Purify:** heals the target's status condition, then the user regains 1/2 of its max HP. It fails against a
    target without one.
  - **Strength Sap:** the target's Attack -1, and the user regains HP equal to the target's Attack, with its stage,
    from before the drop. It fails at -6 Attack.
  - **Lunar Blessing, Jungle Healing:** the user and its ally regain 1/4 of their max HP, and their status conditions
    are healed.
- Checklist: 283 exact, 39 approximate, 58 placeholders.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles against a Ninjask:
- **Spicy Extract:** "The wild NINJASK's Attack sharply rose!", then "...Defense harshly fell!".
- **Fillet Away:** Attack, Sp. Atk and Speed sharply rose. Used again at half HP: "But it failed!".
- **Take Heart:** Chansey, badly poisoned by Toxic: Sp. Atk and Sp. Def rose, then "CHANSEY's status returned to
  normal!".
- **Topsy-Turvy:** after the Ninjask's Swords Dance: "All stat changes on the wild NINJASK were inverted!".
- **Reflect Type:** "SNORLAX's type changed to match the target's!".
- **Magic Powder:** "The wild NINJASK transformed into the Psychic type!". Used again: "But it failed!".
- **Purify:** fails while the Ninjask has no status. After its Flame Orb burns it: "The wild NINJASK's status
  returned to normal!".
- **Strength Sap:** after a Tackle, "The wild NINJASK's Attack fell!", then "SNORLAX regained health!".
- **Lunar Blessing:** badly poisoned Cresselia: "CRESSELIA's HP is full!", then "CRESSELIA's status returned to
  normal!".

## Item 11 (effect fidelity): moves, batch 1

For players: 16 more Gen V-IX moves work as in the main games. Most were plain hits or did nothing before.

- **Flying Press:** Fighting and Flying type at once for its effectiveness (the type chart is applied for both).
- **Collision Course, Electro Drift:** 1.33x when super effective.
- **Last Respects:** 50 more power for each fainted Pokémon in the user's party.
- **Fusion Flare, Fusion Bolt:** double power right after the other one worked this turn
  (`sovereignLastMoveThisTurn`).
- **Sunsteel Strike, Moongeist Beam, Photon Geyser:** ignore the target's Ability, as Mold Breaker does.
  - Photon Geyser is also physical when the user's Attack, with its stage, is higher than its Sp. Atk.
- **Ivy Cudgel:** takes the type of Ogerpon's mask (Water, Fire or Rock), with a high critical-hit ratio.
- **Raging Bull:** takes the type of a Paldean Tauros's breed (Fighting, Fire or Water), and breaks Reflect, Light
  Screen and Aurora Veil (Brick Break's effect).
- **Gigaton Hammer, Blood Moon:** can't be selected right after the user used them: "{Pokémon} can't use {move}
  twice in a row!" (`CHECK_INVALID_TWICE_IN_A_ROW`; the AI follows it too).
- **Supercell Slam:** the user loses half its max HP if it misses (Hi Jump Kick's effect).
- **Power Shift:** swaps the user's Attack and Defense (Power Trick's effect).
- **Chloroblast, Mind Blown:** the user loses half its max HP, so far only when the move hits (Steel Beam's effect).
  They're listed as approximate.
- The move checklist is updated through `tools/engine/gen9_move_fixes.py`: 272 exact, 40 approximate, 68 placeholders
  (84 before).
- Burn Up and Double Shock wait for an owner decision. In the main games a pure Fire or Electric user becomes typeless
  ("???"), and Sovereign's Fairy type took that slot.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles:
- **Flying Press:** Hawlucha against a Breloom: "It's super effective!" (Fighting alone is neutral on Grass/Fighting).
- **Gigaton Hammer:** Tinkaton uses it, then the next turn's pick of it: "TINKATON can't use Gigaton Hammer twice in a
  row!". It then uses another move.
- **Sunsteel Strike:** Solgaleo knocks out a Shedinja through Wonder Guard (god mode off). Iron Head: "The wild
  SHEDINJA avoided damage by using Wonder Guard!".
- **Ivy Cudgel:** Ogerpon with the Wellspring Mask against a Charizard: "It's super effective!".
- **Raging Bull:** an Aqua Breed Tauros against a Charizard: "It's super effective!".
- **Power Shift:** "SNORLAX switched its Attack and Defense!".
- Not run in the harness: Collision Course, Electro Drift, Last Respects, the Fusion moves, Moongeist Beam, Photon
  Geyser and Supercell Slam.

## Item 11 (effect fidelity): held items, part 5 (Mirror Herb, Ability Shield)

For players: the Mirror Herb and the Ability Shield from the Veilstone Dept. Store now work in battle. Every held item
the store sells now works, except the three that switch Pokémon out (Eject Button, Eject Pack, Red Card).

- **Mirror Herb:** copies the stat rises the holder's foes get, then is used up. "The Mirror Herb raised {Pokémon}'s
  {stat}!" for each stat.
  - The stat-change code notes each foe's rise (`Sovereign_NoteMirrorHerbRise`), as the actual change after the +6
    cap.
  - The herb copies them on the next switch-in check, which runs on entry, after Mega Evolution and after every move.
    It copies two stages at a time (`subscript_sovereign_mirror_herb`, `BTLVAR_SOVEREIGN_MIRROR_HERB_NEXT`).
  - A rise at the end of a turn (Speed Boost) is copied after the next move; Showdown copies it at once.
  - The herb never copies a rise it made itself, so two herbs don't copy each other.
- **Ability Shield:** the holder's Ability can't be changed, suppressed or ignored (`Sovereign_HasAbilityShield`).
  - Worry Seed, Gastro Acid, Simple Beam and Entrainment on the holder, Role Play by the holder, and Skill Swap with it
    on either side: "{Pokémon} used {move}!", then "{Pokémon}'s Ability Shield protects its Ability!"
    (`subscript_sovereign_ability_shield`).
  - Mummy, Lingering Aroma and Wandering Spirit leave the holder's Ability alone, and a holder with Trace doesn't trace
    (as in Showdown).
  - Mold Breaker, Turboblaze, Teravolt and Mycelium Might don't ignore the holder's Ability (`Battler_IgnorableAbility`).
  - Klutz doesn't stop the shield; Magic Room and Embargo do.
- `docs/HeldItemChecklist.md` is updated.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles against a Ninjask:
- **Mirror Herb:** the wild Ninjask's Dragon Dance. Snorlax: "The Mirror Herb raised SNORLAX's Attack!", then Speed.
  The next Dragon Dance does nothing more.
- **Ability Shield:** the wild Ninjask's Worry Seed, then Skill Swap. Both times: "SNORLAX's Ability Shield protects
  its Ability!". Without the shield: "SNORLAX acquired Insomnia!".
- **Ability Shield against Mold Breaker:** a wild Rampardos (Mold Breaker) uses Earthquake on Bronzong (Levitate)
  holding a shield: "BRONZONG makes Ground moves miss by using Levitate!". Without the shield, Earthquake hits and is
  super effective.

## Item 11 (effect fidelity): held items, part 4 (Room Service, Adrenaline Orb, Utility Umbrella)

For players: three more Veilstone Dept. Store items now work in battle.

- **Room Service:** Speed -1 under Trick Room, when the holder enters or when Trick Room starts. Used up.
  - It shares the terrain Seeds' check, which runs on entry and after every move.
- **Adrenaline Orb:** Speed +1 after an Intimidate that targets the holder. Used up. "The Adrenaline Orb raised
  {Pokémon}'s Speed!"
  - As in Gen VIII+, it works even when an Ability (Hyper Cutter, Clear Body...) keeps the Attack drop off. It doesn't
    work when the holder's Attack is already at -6, or behind a Substitute.
  - `subscript_intimidate` marks the holder (`BTLVAR_SOVEREIGN_ADRENALINE_ORB_CHECK`). The orb then acts where
    Defiant and Rattled answer Intimidate, on switch-in and mid-turn.
- **Utility Umbrella:** rain and harsh sunlight don't act on the holder (`Sovereign_BattlerWeather`).
  - Fire and Water moves that hit the holder take no weather change. The holder's own Fire and Water moves are still
    boosted or weakened, as in the main games.
  - Abilities that need the weather don't work for the holder: Swift Swim, Chlorophyll, Rain Dish, Dry Skin,
    Hydration, Solar Power, Leaf Guard, Flower Gift, Orichalcum Pulse. Castform and Cherrim keep their base form.
  - Moves act as if there were no weather:
    - Solar Beam and Solar Blade need their charge turn in sun, and lose no power in rain.
    - Electro Shot needs its charge turn in rain.
    - Synthesis, Morning Sun and Moonlight heal 1/2.
    - Weather Ball stays a 50-power Normal move.
    - Hydro Steam isn't boosted.
  - Thunder and Hurricane aimed at the holder use its weather (no sure hit in rain, no 50% in sun). The sun doesn't
    stop the holder from being frozen.
  - Protosynthesis still works, and a primal weather's Fire or Water moves still fail (Showdown's rules).
  - The battle scripts read the holder's weather through two new vars: `BTLVAR_SOVEREIGN_ATTACKER_WEATHER` and
    `BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_WEATHER`.
- **Solar Blade** now loses half its power in rain, sand and snow, as Solar Beam does.
- `docs/HeldItemChecklist.md` is updated.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles:
- **Room Service:** Snorlax holding one: the wild Ninjask's Trick Room, the held-item animation, then "SNORLAX's Speed
  fell!". It happens once.
- **Adrenaline Orb:** a wild Gyarados's Intimidate cuts Snorlax's Attack, then "The Adrenaline Orb raised SNORLAX's
  Speed!".
  - Kingler's Hyper Cutter keeps the drop off, and the orb still raises Speed.
  - Without the orb, Intimidate alone.
- **Utility Umbrella:** Snorlax uses Rain Dance while a wild Ninjask uses Water Gun on it, with god mode off.
  - Before the rain both cases take 31.
  - In rain, the umbrella holder takes 28 (no boost); the control takes 46.
- Not run in the harness: the Ability and move cases (Swift Swim, Solar Beam, Synthesis, Weather Ball...). They use
  the same `Sovereign_BattlerWeather` check.

## Item 11 (effect fidelity): held items, part 3 (the Gems, Air Balloon, Ring Target)

For players: the 18 Gems, the Air Balloon and the Ring Target from the Veilstone Dept. Store now work in battle.

- **The Gems:** the holder's first damaging move of the Gem's type is ×1.3 (Gen VI+; ×1.5 in Gen V). The Gem is
  used up as the hit lands: after "{Pokémon} used {move}!", "The {item} strengthened {move}'s power!" shows before the
  HP bar drops.
  - Status moves and fixed-damage moves don't use it (`Item_SovereignGemType`).
  - The damage calculation powers up the move and marks the attacker (`sovereignGemBoost`). `subscript_update_hp`
    then shows the message and takes the Gem (`BTLVAR_SOVEREIGN_GEM_USED`, `subscript_sovereign_gem`).
  - A multi-hit move is powered up on its first hit only.
- **Air Balloon:**
  - On entry: "{Pokémon} floats in the air with its Air Balloon!".
  - Ground moves don't affect the holder ("It doesn't affect {Pokémon}…").
  - The holder isn't grounded: terrain, Spikes, Toxic Spikes, Sticky Web and Arena Trap leave it alone. Spikes and
    Toxic Spikes now go through `Sovereign_IsGrounded` (`BTLVAR_SOVEREIGN_SWITCHED_MON_GROUNDED`), as Sticky Web does.
  - A damaging move that hits the holder pops it ("{Pokémon}'s Air Balloon popped!").
  - Gravity, Ingrain and Smack Down still ground the holder.
- **Ring Target:** the holder's type immunities don't apply. A Ghost type takes Normal and Fighting moves; a Flying
  type takes Ground moves. Abilities such as Levitate still protect it (`BasicTypeMulApplies`).
- `docs/HeldItemChecklist.md` is updated.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles against a Ninjask:
- **Normal Gem:** a wild Ninjask holding one hits Snorlax with Tackle for 106. The same battle without the Gem does
  82. The message shows after "The wild NINJASK used Tackle!" and before the HP drop, and only once.
- **Air Balloon:** Garchomp holding one shows the entry message. The wild Ninjask's Earthquake: "It doesn't affect
  GARCHOMP…". The wild Ninjask's Tackle: "GARCHOMP's Air Balloon popped!", and its next Tackles hit as usual.
- **Ring Target:** Gengar holding one takes the wild Ninjask's Tackle. Without it, Tackle doesn't affect Gengar.
- Not run in the harness: Air Balloon against entry hazards and Arena Trap. The test player has only one Pokémon, so
  it never switches in onto hazards.

## Item 11 (effect fidelity): held items, part 2; Ghost types escape trapping; Healer 50%

For players: ten more held items from the Veilstone Dept. Store now work. A Ghost type can always switch out or run
away, and Healer cures its ally half the time, as in Pokémon Champions.

- **Weakness Policy:** Attack and Sp. Atk +2 when a super-effective move hits the holder.
- **Absorb Bulb, Cell Battery, Luminous Moss, Snowball:** a +1 stat rise when a move of their type hits the holder:
  - Absorb Bulb: Sp. Atk, from a Water move.
  - Cell Battery: Attack, from an Electric move.
  - Luminous Moss: Sp. Def, from a Water move.
  - Snowball: Attack, from an Ice move.
- **Throat Spray:** Sp. Atk +1 after the holder uses a sound move that works.
- **Blunder Policy:** Speed +2 after the holder's move misses.
- All seven of these are used up once they act. They don't act while the stats they raise are already at +6.
  - They share one subscript, `subscript_sovereign_item_stat_up`, which shows "The {item} raised {Pokémon}'s {stat}!".
  - On-hit items: `Sovereign_ItemStatUpOnHit`, in `BattleSystem_TriggerHeldItemOnHit`.
  - After-move items: a new step, `AFTER_MOVE_HIT_STATE_SOVEREIGN_ITEMS`.
- **Float Stone:** the holder's weight is halved for Low Kick, Grass Knot, Heavy Slam and Heat Crash. This stacks
  with Light Metal.
- **Binding Band:** a binding move its holder used costs the target 1/8 of its max HP at the end of each turn, not
  1/16. Sovereign keeps Platinum's 1/16 base, so the band doubles it, as in Gen V.
- **Loaded Dice:** the holder's 2-5 hit moves hit 4 or 5 times.
- **Ghost types and trapping:** since Gen VI, nothing traps a Ghost type. It can switch out or flee past Mean Look,
  Block, binding moves, Ingrain, Shadow Tag, Arena Trap and Magnet Pull (`Battler_IsTrapped`, `Battler_IsTrappedMsg`).
- **Healer:** 50% a turn, as in Pokémon Champions (30% in Gen V-IX).
- `docs/HeldItemChecklist.md` and `docs/BattleMechanics.md` are updated. The Gen V-IX rules Champions inherits
  (Prankster vs Dark types, Intimidate blockers, Ghost types and trapping, Grass types and powder) are all done.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles against a Ninjask:
- **Weakness Policy:** Snorlax hit by Mach Punch: "The Weakness Policy raised SNORLAX's Attack!", then Sp. Atk. It
  happens once; the next super-effective hit does nothing, and Tackle never sets it off.
- **The type items:** Absorb Bulb (Water Gun), Cell Battery (ThunderShock), Luminous Moss (Water Gun) and Snowball
  (Powder Snow) each raise their stat once.
- **Throat Spray:** after Hyper Voice, "The Throat Spray raised SNORLAX's Sp. Atk!", once.
- **Blunder Policy:** Zap Cannon misses: "The Blunder Policy raised SNORLAX's Speed!".
- **Float Stone:** Lucario takes 44 from a Lv. 40 Ninjask's Low Kick with it, 58 without (80 base power at 54 kg, 60
  at 27 kg).
- **Binding Band:** a wild Ninjask holding one wraps Snorlax: 27 at the end of the turn (221/8), 13 without (221/16),
  with the test's god mode off.
- **Loaded Dice:** a wild Ninjask holding them: Bullet Seed hits 4, then 5 times.
- Ghost types and trapping, and Healer, weren't run (the harness has no trapping case or double battle yet).

## Item 11 (effect fidelity): held items, part 1

For players: Eviolite, Assault Vest, Rocky Helmet, Heavy-Duty Boots, Safety Goggles, Covert Cloak and Clear Amulet now
work. The Veilstone Dept. Store sells them. Before this, they did nothing. The new
`docs/HeldItemChecklist.md` lists every held item the store sells and whether it works yet.

- **Eviolite:** the holder's Defense and Sp. Def ×1.5 while it can still evolve.
  - `Pokemon_SovereignCanEvolve` reads the species' evolutions. A regional form uses its own (as
    `Pokemon_GetEvolutionTargetSpecies` does). Megas and other battle forms never evolve.
- **Assault Vest:**
  - Sp. Def ×1.5.
  - Status moves can't be selected: "The Assault Vest prevents status moves from being used!"
    (`CHECK_INVALID_ASSAULT_VEST`). The trainer AI uses the same check.
- **Rocky Helmet:** an attacker that makes contact loses 1/6 of its max HP.
  - It happens after each hit, after the target's on-hit Ability (Iron Barbs, Rough Skin), and even as the holder
    faints. It is a new step after each hit: `ONE_HIT_`/`MULTI_HIT_SOVEREIGN_ROCKY_HELMET`, with
    `subscript_sovereign_rocky_helmet`.
  - Not through a Substitute, not with Magic Guard, and not with Protective Pads, which makes the move non-contact.
- **Heavy-Duty Boots:** no Stealth Rock, Spikes, Toxic Spikes or Sticky Web on entry. A grounded Poison type wearing
  them still takes the Toxic Spikes away.
- **Safety Goggles:** powder moves and Effect Spore don't affect the holder (`Battler_SovereignPowderImmune`), and
  neither does sandstorm damage.
- **Covert Cloak:** another Pokémon's move can't give the holder its chance effect, as with Shield Dust
  (`BattleSystem_TriggerSecondaryEffect`).
- **Clear Amulet:** another Pokémon's move or Ability (Intimidate) can't lower the holder's stats: "{0}'s Clear Amulet
  prevents stat loss!".
- **Gorilla Tactics:** its message now waits for a button, as the Choice item one does.
- `Sovereign_MakesContact` is no longer static, so the controller can use it.

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles against a Lv. 100 Ninjask, each
with a control case. Damage is compared from the same save state, so the random rolls are the same:
- **Eviolite:** Porygon2 takes 40 from Tackle with it, 58 without. Porygon-Z, fully evolved, takes 67 either way.
- **Assault Vest:** Snorlax takes 85 from Bug Buzz with it, 127 without. Picking Swords Dance shows the message, and
  it uses Play Rough instead.
- **Rocky Helmet:** Ferrothorn is hit by Tackle: "FERROTHORN's Iron Barbs hurt the wild NINJASK!", then "The wild
  NINJASK is hurt by FERROTHORN's Rocky Helmet!". When Iron Barbs knocks the Ninjask out, the Helmet stays quiet.
  Double Hit on a Snorlax: the Helmet message after each hit.
- **Safety Goggles:** Spore: "It doesn't affect GARCHOMP…". In a sandstorm, only the Ninjask is buffeted; without the
  goggles, Pikachu is too.
- **Covert Cloak:** Nuzzle never paralyzes Snorlax; without the cloak, "SNORLAX is paralyzed!".
- **Clear Amulet:** Screech: "SNORLAX's Clear Amulet prevents stat loss!"; without it, "Defense harshly fell!".
- **Heavy-Duty Boots:** not run. The harness's player has one Pokémon, so it never switches in onto hazards.

## Item 11 (effect fidelity): Gorilla Tactics, Guard Dog, Mycelium Might, Overcoat and Infiltrator in full

For players: five abilities that only partly worked now work fully. Since Gen VI, Grass types also can't be affected by
powder moves.

- **Gorilla Tactics:** the holder can only use the first move it picked, as with a Choice item, until it switches out.
  Picking another move shows "{0}'s Gorilla Tactics lets it use only {2}!".
  - `Battler_SovereignChoiceLocks` (a Choice item, or Gorilla Tactics) now covers the lock. It is used for move
    selection, for setting the lock after a move and keeping it when the holder is hit, and for Pursuit.
- **Guard Dog:** Roar and Whirlwind (and Dragon Tail and Circle Throw) can't force it out: "{0} anchors itself with
  Guard Dog!", as for Suction Cups. Mold Breaker gets past it, and the trainer AI knows about it.
- **Mycelium Might:** when the holder uses a status move, it goes last in its priority bracket, as with Stall.
- **Powder moves** (Cotton Spore, Magic Powder, Poison Powder, Powder, Rage Powder, Sleep Powder, Spore, Stun Spore):
  - They don't affect Grass types or Overcoat: "It doesn't affect {0}…" (`Move_IsPowder`,
    `Battler_SovereignPowderImmune`). Mold Breaker gets past Overcoat.
  - Effect Spore doesn't affect them either.
  - Safety Goggles still has no effect; held items are their own task.
- **Infiltrator:** its moves now also get past a foe's Safeguard and Mist (`Sovereign_Infiltrates`).
  - Not for an Ability's or item's effect.
  - Not for entry hazards, whose attacker is whoever moved last. `subscript_hazards_check` sets
    `BTLVAR_SOVEREIGN_IN_HAZARDS` while it runs.
- `docs/AbilityChecklist.md`: five "partly" entries are now "yes" (170 of 191 still have an effect).

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles against a Ninjask:
- **Gorilla Tactics:** Galarian Darmanitan uses Dazzling Gleam. Picking another move later gives "DARMANITAN's
  Gorilla Tactics lets it use only Dazzling Gleam!", and it uses Dazzling Gleam again.
- **Guard Dog:** Mabosstiff is hit by Roar: "MABOSSTIFF anchors itself with Guard Dog!".
- **Mycelium Might:** Toedscruel against a Lv. 5 Ninjask. Its Spore comes after the Ninjask's Splash, while its Mega
  Drain comes first.
- **Spore:** "It doesn't affect FORRETRESS…" (Overcoat) and "It doesn't affect VENUSAUR…". Garchomp falls asleep.
- **Infiltrator:** after the Ninjask's Safeguard, Crobat (Infiltrator) badly poisons it with Toxic. Without
  Infiltrator: "The wild NINJASK is protected by Safeguard!". After Mist, Infiltrator Crobat's Screech: "The wild
  NINJASK's Defense harshly fell!". Without Infiltrator: "…is protected by Mist!".

## Item 11 (effect fidelity): Soul-Heart

For players: Magearna's Soul-Heart now works.

- **Soul-Heart:** each time another Pokémon faints, the holder's Sp. Atk rises 1 stage: "{0}'s Soul-Heart raised its
  Sp. Atk!". This happens for every faint, whatever caused it, and also after the last foe faints.
  - The check is at the end of `subscript_faint_mon`, which every faint goes through: knockouts, Explosion, Destiny
    Bond, weather, entry hazards, Healing Wish.
  - Reading `BTLVAR_SOVEREIGN_SOUL_HEART_MON` makes the next holder the side-effect target, in speed order. A holder
    counts when it is on the field, isn't the Pokémon that fainted, has HP left and has Sp. Atk below +6.
  - The first read saves the side-effect battler, type and param; the last read gives them back. The script that
    called the faint subscript gets them unchanged.
- `docs/AbilityChecklist.md`: 170 of the 191 new abilities have a battle effect, counting partial ones (169 before).

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles, with Magearna (Lv. 50) as the
lead:
- Its Flash Cannon knocks out a Lv. 5 Ninjask: "The wild NINJASK fainted!", then the stat-rise animation and
  "MAGEARNA's Soul-Heart raised its Sp. Atk!".
- A Lv. 100 Ninjask uses Explosion: the same message after it faints.
- Garchomp knocking out the same Ninjask: no message.

## Item 11 (effect fidelity): Harvest, Quick Draw, Magician and Pickpocket

For players: Harvest, Quick Draw, Magician and Pickpocket now work.

- **Harvest:** at the end of a turn, the holder grows back the Berry it used up, half the time (every time in harsh
  sunlight): "{0} harvested one {1}!" (`BattleSystem_TriggerTurnEndAbility`, `subscript_sovereign_harvest`). The
  turn-end item check comes right after, so a Sitrus Berry grown back at low HP is eaten at once.
- **Quick Draw:** 30% of the time it uses a damaging move, the holder goes first in its priority bracket, with one
  roll a turn as for Quick Claw: "{0}'s Quick Draw let it move first!" (`BattleSystem_CompareBattlerSpeed`,
  `subscript_sovereign_quick_draw`, which runs in place of Quick Claw's check).
- **Magician:** when the holder has no item, its damaging move takes the item of the Pokémon it hits. **Pickpocket:**
  when the holder has no item, it takes the item of a Pokémon that makes contact with it. "{0} stole {1}'s {2}!"
  (`subscript_sovereign_take_item`).
  - Both follow Thief's rules (`Sovereign_CanTakeItem`, as `BtlCmd_TryStealItem`): not through Sticky Hold or
    Multitype, not an item that sets a form, and a foe's Magician or Pickpocket takes nothing outside the Battle
    Frontier, so the player never loses an item.
- **Test build:** the test hook's wild Pokémon can hold an item (`gSovereignTestWild.item`).
- `docs/AbilityChecklist.md`: 169 of the 191 new abilities have a battle effect, counting partial ones (165 before).

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles, with each message box and HP bar
looked at:
- **Harvest** (Tropius, Lv. 50, 159 HP, holding a Sitrus Berry), with the test's god mode off: the Berry heals it at
  once, a Tackle takes it to 27, then "TROPIUS harvested one Sitrus Berry!" and the Berry heals it to 66.
- **Quick Draw** (Galarian Slowbro, Lv. 50) against a Lv. 100 Ninjask: "SLOWBRO's Quick Draw let it move first!",
  then Slowbro's move before Ninjask's, twice in ten turns.
- **Magician** (Delphox) hits a wild Ninjask holding Leftovers: "DELPHOX stole the wild NINJASK's Leftovers!".
  **Pickpocket** (Weavile) is hit by Tackle: "WEAVILE stole the wild NINJASK's Leftovers!"; by Swift, which makes no
  contact, nothing.
- **Test harness note:** god mode keeps the player's Pokémon's real HP while its HP bar still shows the hit. A Berry
  test that needs real damage has to turn god mode off (Recycle's Sitrus Berry looked unused for that reason).

## FM — decisions 49 and 50: one Scatterbug, one Spewpa, base cosmetic forms for the player

For players: Scatterbug and Spewpa have no patterns. Vivillon is always Meadow and the Flabébé line always Red Flower
when caught, hatched or evolved. Milcery always evolves into Vanilla Cream Strawberry Sweet Alcremie. The Fight Area
deliveryman no longer hands out the costume and cap Pikachu; Partner Pikachu stays. Trainers' teams can still use the
other Vivillon patterns, flower colors, Alcremie and Pikachu.

- `tools/engine/gen_forms.py`: Scatterbug's and Spewpa's 38 pattern forms are gone (421 forms now 383). The Vivillon
  patterns and the Flabébé line's colors are `SOVEREIGN_FORM_REGIONAL` (set only by trainer data), not personality forms.
  Their form folders, meson blocks and PokeAPI fronts are removed.
- `src/pokemon.c`: no Vivillon case in `Pokemon_SovereignPersonalityForm`; `Pokemon_SovereignAlcremieForm` is gone.
- `src/scrcmd.c` `sSovereignEventGifts`, `scripts_fight_area_pokecenter_1f.s` and its text: 23 entries down to 9.
  Spiky-eared Pichu is now entry 8, so its given-bit moved (old test saves may show it as given or not).
- Verified: `make rom`, boot smoke test PASS, `check_battle_sprites.py` (4,340 sprites, 0 problems),
  `check_event_scripts.py`, `check_menus.py`, `check_byte_text_ids.py`, `check_battle_scripts.py`.

## E12 — shinies drawn on their own (Florges, Vivillon, the Furfrou trims)

For players: shiny Florges, Vivillon, Flabébé, Floette, Furfrou (and its trims), Pyroar, Xerneas, Zeraora, Smoliv,
Toedscruel, Ting-Lu, Iron Crown, Galarian Darumaka and female Meowstic show PokeAPI's shiny front as drawn, not a
scrambled recolour.

- PokeAPI draws some shiny fronts apart from the normal front, so no palette swap of the normal front can show them.
  `tools/sprites/convert_form_sprites.py` now finds them (more than 10% of the pixels don't follow one normal-to-shiny
  colour mapping) and converts the shiny as a front sprite of its own, both palettes its colours: 12 species and 11
  forms (438 form-area sprites, from 415).
- `sovereign_form_sprites.h` gains `sSovereignFormShinySprite`, `sSovereignFormFemaleShinySprite` and
  `sSpeciesShinyFront` (species, gender 0/1/2 = male/female/either, sprite). `SovereignForm_FrontSprite`
  (`src/pokemon.c`) takes `shiny` and returns them for a shiny's front; backs are unchanged.
- Verified: `make rom`, boot smoke test PASS, `check_battle_sprites.py` 4,378 sprites 0 problems; the four shown to
  the owner (Florges, Vivillon, Kabuki Furfrou, Xerneas) rendered from the converted files.

## Item 11 (effect fidelity): Cheek Pouch and Ripen

For players: Cheek Pouch and Ripen now work with the Berries they matter most for.

- **Cheek Pouch:** when the holder eats its own held Berry, it also restores a third of its max HP: "{0} restored HP
  using its Cheek Pouch!". It's checked where every Berry is used up (`subscript_pluck_check`, with the read-only
  `BTLVAR_SOVEREIGN_CHEEK_POUCH_MSG_TEMP` and `subscript_sovereign_cheek_pouch`), so items that aren't Berries (Berry
  Juice) don't count.
  - Not yet: a Berry taken by Bug Bite or Pluck, or a damage-halving Berry.
- **Ripen:** Berries that restore HP restore twice as much (`Sovereign_RipenBerryHP`), and Berries that raise a stat
  raise it 2 stages (`subscript_held_item_raise_stat`).
  - Not yet: damage-halving Berries, and the other kinds.
- `docs/AbilityChecklist.md`: 165 of the 191 new abilities have a battle effect, counting partial ones (163 before).

**Verification:** `tools/test/check_battle_scripts.py` passes. Harness wild battles, with each message box and HP bar
looked at:
- **Cheek Pouch** (Greedent, Lv. 50, 180 HP, at 40%): its Sitrus Berry heals it to 117, then "GREEDENT restored HP
  using its Cheek Pouch!" takes it to 177 (+60). An Oran Berry: 82, then 142. Berry Juice: no Cheek Pouch.
- **Ripen** (Appletun, 170 HP, at 40%): its Sitrus Berry heals 84, twice a quarter, from 68 to 152. A Liechi Berry
  at 20%: "The Liechi Berry raised APPLETUN's Attack!" (the message is the same for 2 stages).


## Item 11 (effect fidelity): seven more abilities

For players: As One, Toxic Chain, Poison Puppeteer, Supersweet Syrup and Comatose now work. Pastel Veil and Sweet Veil
protect their holder.

- **As One** (Ice and Shadow Calyrex): as Unnerve, foes can't eat their Berries (Unnerve's own limits apply). Each foe
  its move knocks out raises its Attack (Ice) or Sp. Atk (Shadow) 1 stage, as Chilling Neigh and Grim Neigh do.
- **Toxic Chain:** its damaging moves have a 30% chance to badly poison the target. It counts as a move's added effect
  (`subscript_badly_poison` with `SIDE_EFFECT_TYPE_INDIRECT`), so Shield Dust and a Substitute stop it, as in Gen IX.
- **Poison Puppeteer** (Pecharunt): a Pokémon its move poisons or badly poisons becomes confused too, unless it has
  Own Tempo or is already confused (`subscript_sovereign_poison_puppeteer`, called from both poison subscripts).
- **Supersweet Syrup:** the first time the holder enters the battle, each foe's evasiveness drops 1 stage, as with
  Intimidate (`subscript_sovereign_supersweet_syrup`). Mirror Armor and Clear Body stop it; Defiant and Competitive
  respond.
- **Comatose:** nothing gives the holder a status condition or makes it drowsy, not even through Mold Breaker, and
  Rest fails (`Battler_SovereignStatusImmune`). It never naps out of disobedience.
  - It counts as asleep: Dream Eater and Nightmare work on it, Hex and Wake-Up Slap have double power against it (Wake-Up
    Slap has nothing to wake), Bad Dreams hurts it, and it can use Sleep Talk and Snore (with no "fast asleep"
    message).
- **Pastel Veil and Sweet Veil:** the holder can't be poisoned (Pastel Veil), or fall asleep or become drowsy (Sweet
  Veil), as with Immunity and Insomnia. Not yet: their allies' protection.
- **AI:** Comatose counts as Purifying Salt, Pastel Veil as Immunity and Sweet Veil as Insomnia.
- `docs/AbilityChecklist.md`: 163 of the 191 new abilities have a battle effect, counting partial ones (155 before).

**Verification:** `tools/test/check_battle_scripts.py` passes (the largest script is 1,748 of 2,048 bytes). A harness
wild battle per case, with each message box looked at:
- **As One:** Ice Calyrex knocks out the foe, then "CALYREX's As One raised its Attack!"; Shadow Calyrex, "…raised its
  Sp. Atk!".
- **Toxic Chain** (Okidogi): "The wild NINJASK was badly poisoned!" after its hit.
- **Poison Puppeteer:** Pecharunt's Toxic, then "The wild NINJASK was badly poisoned!" and "…became confused!".
- **Supersweet Syrup** (Hydrapple): "HYDRAPPLE's SupersweetSyrup cuts the wild NINJASK's evasiveness!" on entry.
- **Comatose** (Komala) against Toxic, Spore and Will-O-Wisp: "…prevents poisoning!", "KOMALA stayed awake because of
  its Comatose!", "…prevents burns!".
- **Comatose as asleep:** the foe's Dream Eater ("KOMALA's dream was eaten!") and Nightmare ("KOMALA began having a
  nightmare!", then "…is locked in a nightmare!" at the turn's end); Komala's Snore hits, and its Sleep Talk uses
  Moonblast.
- **Pastel Veil** (Galarian Rapidash) against Toxic, and **Sweet Veil** (Slurpuff) against Spore and Yawn: "…prevents
  poisoning!", "…stayed awake because of its Sweet Veil!", "…made it ineffective!".


## Item 11 (effect fidelity): eight more abilities

For players: Purifying Salt, Water Bubble and Thermal Exchange keep status conditions off as in Gen IX. Mirror Armor
sends stat drops back. Cotton Down, Electromorphosis, Wind Power and Wind Rider now work.

- **Purifying Salt:** no status condition of any kind, and no drowsiness from Yawn. Rest fails. Mold Breaker gets
  past it when another Pokémon's move would give the status; a held Flame Orb or Toxic Orb never does.
  - It uses the same check as Shields Down's shell. `BTLVAR_SOVEREIGN_SHIELDS_UP_EFFECT_MON` became
    `BTLVAR_SOVEREIGN_STATUS_IMMUNE_EFFECT_MON` (`Battler_SovereignStatusImmune`), so the burn, poison, bad poison,
    paralysis, sleep, freeze, Yawn and Rest subscripts all cover it.
- **Water Bubble and Thermal Exchange:** no burns, as with Water Veil, and a burn is healed (Skill Swap).
- **Mirror Armor:** a stat drop from another Pokémon's move or Ability (Intimidate, Cotton Down) goes back to that
  Pokémon: "{holder}'s Mirror Armor cuts {source}'s {stat}!". Mold Breaker gets past it.
  - Not when the holder's stat is already at −6, or when its Substitute stops the drop anyway.
  - The source's own Clear Body, Mist and so on can still stop it; its Substitute and Shield Dust can't. Contrary
    turns it into a rise, and Defiant and Competitive respond.
  - `BtlCmd_ChangeStatStage` swaps the two Pokémon's roles for the drop. `subscript_update_stat_stage` gives the holder
    its side-effect role back afterwards (`BTLVAR_SOVEREIGN_MIRROR_ARMOR_HOLDER`).
  - Sticky Web's drop would go back to the Pokémon that set the web. The engine doesn't track who that was, so Mirror
    Armor only blocks it: "{holder}'s Mirror Armor prevents stat loss!".
- **Cotton Down:** when a damaging move hits the holder, every other Pokémon's Speed drops 1 stage, its ally's too,
  even as the holder faints (`subscript_sovereign_cotton_down`, Intimidate's loop). Defiant and Competitive respond.
- **Electromorphosis and Wind Power:** a damaging hit (any for Electromorphosis, a wind move for Wind Power) charges
  the holder: "{0}'s {1} charged it with power!". Its next Electric move before the end of next turn has double power,
  as after Platinum's Charge. A tailwind starting on its side charges a Wind Power holder too.
- **Wind Rider:** wind moves aimed at it do nothing, and its Attack rises 1 stage, as with Sap Sipper. A tailwind
  starting on its side raises its Attack 1 stage, and so does entering the battle while one blows.
- **Wind moves:** `Move_IsWind` lists Gen IX's 17.
- **AI:** the trainer AI knows Purifying Salt blocks every status move. It also knows Water Bubble and Thermal
  Exchange block burns, wherever it checked Immunity, Limber, Insomnia or Water Veil. It treats Mirror Armor as Clear
  Body when it weighs a stat-lowering move.
- `docs/AbilityChecklist.md`: 155 of the 191 new abilities have a battle effect, counting partial ones (150 before).
- **CI:** `tools/test/check_battle_scripts.py` now also checks that `subscripts/sub_seq.order` lists every subscript in
  `meson.build`, in the order of `generated/battle_subscripts.txt`. A subscript missing from the order still builds,
  at the end of the NARC in another order, so a script's `Call` of it runs a different subscript. That happened here:
  the tailwind's call of the charge subscript ran Cotton Down.

**Verification:** `tools/test/check_battle_scripts.py` (the largest script is 1,680 of 2,048 bytes) and the docs
check pass. A harness wild battle per case, with each message box looked at:
- **Purifying Salt** (Garganacl) against Will-O-Wisp, Toxic, Thunder Wave, Spore and Yawn: "…prevents burns!",
  "…prevents poisoning!", "…prevents paralysis!", "…stayed awake because of its Purifying Salt!", "…made it
  ineffective!".
- **Water Bubble** (Araquanid) and **Thermal Exchange** (Arctibax) against Will-O-Wisp: "…prevents burns!". A
  Flame Orb never burns Araquanid. Garchomp, the control, is burned.
- **Cotton Down** (Eldegoss) hit by Tackle: "ELDEGOSS's Cotton Down cuts the wild NINJASK's Speed!".
- **Electromorphosis** (Bellibolt) hit by Tackle, and **Wind Power** (Kilowattrel) hit by Gust: "…charged it with
  power!".
- **Wind Rider** (Brambleghast) against Gust: "BRAMBLGHST's Wind Rider raised its Attack!".
- **Tailwind:** Kilowattrel's own Tailwind charges it, and Brambleghast's raises its Attack.
- **Mirror Armor** (Corviknight) against Growl, Screech, Icy Wind, Lunge and Struggle Bug: "CORVIKNIGHT's Mirror Armor
  cuts the wild NINJASK's Attack!" (and Defense, Speed, Attack, Sp. Atk). With Pressure instead, its own Attack falls.


## Playtest pass — the trainer, evolution, Egg and species tests with the heap checks

The heap checks (`heap_check.py`) went into every harness in the Trainers' School Egg pass below, but the trainer,
evolution and Egg tests hadn't been rerun with them. Now all four battle tests have, on the test build of `main` (the
species test on the build with decisions 46 and 47).

**Results:** no broken heap (no **HEAP**), and nothing else fails.
- **Trainers:** all 1,039.
- **Evolutions:** all 336.
- **Eggs:** all 874.
- **Species and forms as wild Pokémon:** all 1,510. The run was split three ways when a worker restart stopped the
  first one, and the last two cases ran on their own.


## E10 — Darach mid-game, and the Tea for Route 218's gate (decision 47, as in Renegade)

For players: the Regional Forms Park's lobby on Route 221 is open as soon as the player can Surf there. Darach and Lady
Caitlin wait in it, and Darach's battle (Lv. 48) ends with the Tea. Route 218's gate to Canalave City is closed until
the player brings the thirsty policeman that Tea. The park itself still opens after the Hall of Fame.

- **Route 221:** the two workers no longer stand at the lobby door. Renegade opens the lobby with an early National
  Dex; in Sovereign that check means the Hall of Fame (decision 21), so the workers are simply gone.
- **The lobby:**
  - Before the Hall of Fame, the worker says the park isn't open yet. Oak's first visit (his scene on entering, with
    the Trainer Counter app) waits for the Hall of Fame too.
  - Darach and Caitlin's scene is as before (E10 part 33). It's now hidden by a map-local flag, worked out on entering:
    they're there until the scene is done, and back after the Hall of Fame. Each then has a line of their own.
  - Darach's greeting, about the park's Pokémon seen from the window, fits both times.
  - The other visitors are there from the start, as in Renegade.
- **Route 218's gate to Canalave City:**
  - The policeman moves up a tile, to (2, 4), as in Renegade.
  - A step onto the gate's west column gets his "!". Without the Tea, he gives Renegade's "the road's closed" line,
    which now points to the park on Route 221, and the player steps back.
  - With the Tea, he drinks it (the Tea is used up) and lets the player through. After that he talks about how good
    it was.
  - No new save data: the gate's own var, which the scientist's Pokédex upgrade sets from 0 to 1, becomes 2 once he's
    had the Tea. The trigger waits on 0 and 1.
- `docs/RegionalFormsPark.md` (and its generator) says when the lobby and the park open.
- **Verification** in a test build:
  - From Route 221, the player walks north into the lobby. Before the Hall of Fame: no Oak, and the worker says the
    park isn't open.
  - Without the Tea, the gate's policeman stops the player, and further steps west are stopped again.
  - Darach's scene, then the gate: the policeman takes the Tea and the player walks on into Canalave City.
  - After the Hall of Fame, Oak's first visit plays on entering, Darach is back with his line, and the worker offers
    the park.
  - The CI checks pass.


## E10 — Route 224 before the Elite Four (decision 46, as in Renegade)

For players: Victory Road's back area and Route 224 now come before the League. The counterpart's battle by Route
224's tablet (Lv. 69–70) is the last step before it.

- **Victory Road 1F:**
  - The collector no longer blocks the back area until the post-game.
  - He stands by the way out to the League, at (38, 18), Renegade's spot.
  - Stepping beside him gets "Hold it!", then Renegade's line: "You're not quite ready yet. Have you been to Route
    224? It's through a passage to the east." The player steps back. Talking to him gives the same line.
  - Once any of the six Route 224 counterpart teams has been beaten, he's gone and his trigger is off. The map's
    on-transition script checks the trainer flags, so no new save flag is needed.
- **Level cap:** the Route 224 battle is a step of its own (Lv. 70), between Volkner (62) and Barry at the League
  (71). `tools/engine/gen_level_caps.py` now sizes a step's trainer list from the longest one: six here, three before.
- **Still post-game:** Shaymin's tablet (Oak gives his letter in Eterna only after the Hall of Fame), Enamorus (after
  Landorus) and Pecharunt (after the Loyal Three).
- `tools/test/check_object_tiles.py` lists the collector as known: he stands on the middle tile of his own trigger, as
  in Renegade.
- **Verification** in a test build:
  - Stepping beside him from the west and from the east: he turns with "!", the lines play, and the player steps
    back. A second step north stops the player again.
  - Talking to him gives his line.
  - With the counterpart beaten, he's gone and the player walks on north.
  - The CI checks pass, the object tile check included.


## Battle sprites: no more scrambled sprites

For players: Samurott's front, Hisuian Samurott's front and Talonflame's back no longer come out as noise in battle.

- **The cause:** the game unscrambles each battle sprite with a key it reads from its first four pixels
  (`PokemonSprite_DecryptPt`), which works only if they're clear. Art that reached the top-left corner made the whole
  sprite noise.
- **The fix:** `tools/sprites/convert_battle_sprites.py` and `convert_form_sprites.py` now clear those pixels: 1 for
  each Samurott, 2 for Talonflame.
- **The check:** `tools/test/check_battle_sprites.py`, a new CI check, keeps it that way. It checks all 4,308 battle
  sprites, forms included.
- **Verification:** the three sprites were seen in battle, normal and shiny.


## Playtest pass — the new battle sprites seen in battle

- **`tools/test/sprite_check.py`:** a wild battle against each of #494–1025, with the same species as the player's
  lead, first normal and then shiny. It saves a shot of the top screen once both Pokémon are out, and makes contact
  sheets of the shots. It takes about 40 minutes in 4 parts.
- **Test hooks:**
  - `gSovereignTestWild.shiny` makes the wild Pokémon shiny, through the Poké Radar's own shiny code.
  - `gSovereignTestLead.shiny` gives the lead a shiny personality.
- **Results** on the build of PR #157 (PokeAPI fronts, front and back palettes of their own): 1,064 battles, and none
  hung. `docs/SpriteReview.md` lists what looks wrong:
  - Samurott's front and Talonflame's back are scrambled in battle. The game takes the key that unscrambles a sprite
    from its first four pixels, and both draw there.
  - Nine species show Bulbasaur's back: the pack's placeholder.
  - Vivillon's back is another wing pattern than its front.
  - Flabébé's and Floette's PokeAPI shiny fronts are other drawings than their fronts.
  - A sample of #1–493 looks as before.

The fixes come in the next PR.


## CI: the object tile and double-close checks; the Smogon sprite credits

- **Two more checks run in CI** (the docs job), so a change can't undo them:
  - `tools/test/check_object_tiles.py`: every object Sovereign added or moved can be reached and blocks nothing. It
    tells added objects from vanilla's by the decomp's import commit, so the step fetches that one commit into the
    shallow checkout.
  - `tools/test/check_double_close.py`: no script path runs CloseMessage twice with no message in between, which
    hangs the game (E10 part 28). It now fails on any case but vanilla's two harmless ones.
- **The Smogon Sprite Project's per-sprite credits** are in `docs/SmogonSpriteCredits.md`, for the 197 species whose
  96×96 sprites come from it: the sprites we have, and the spriters and QC the project credits. They come from each
  project's sheet of finished sprites (X/Y, Sun/Moon, Gen 8 and Gen 9; snapshots in `assets/sprites/credits/smogon/`),
  through `tools/sprites/smogon_credits.py`, which `tools/regenerate_docs.sh` runs. `CITATIONS.md` names the 36
  spriters.

## E12 — no scrambled battle sprites; one Pumpkaboo and Gourgeist sprite

- The game unscrambles a battle sprite with a key read from its first four pixels (`PokemonSprite_DecryptPt`), so a
  sprite drawing into that corner comes out as noise (Claude B's review, `docs/SpriteReview.md`: Samurott's PokeAPI
  front, Talonflame's back, Hisuian Samurott's front). `two_frames` (`convert_battle_sprites.py`) now keeps those four
  pixels transparent for every converted sprite; none has them set now.
- Pumpkaboo and Gourgeist keep their four sizes (owner: their stats differ), but every size uses the Average Size
  sprite: the sizes' own form sprites are removed (`pokeapi_fronts/forms/{pumpkaboo,gourgeist}-*`).
- Verification: release build and boot smoke test pass; 414 forms map to their own sprite.

## E12 — shiny colours chosen with the normal ones

For players: shinies of the new species and forms match their source more closely (Alolan Meowth's blue eyes, for
one, had come out purple).

- `convert_battle_sprites.paired_palettes` chooses each sprite's 15 colour slots from the (normal, shiny) colour
  pairs of its pixels, so two places with one normal colour but different shiny colours get slots of their own;
  more than 15 pairs are grouped by k-means. Before, the slots came from the normal colours alone and each slot's
  shiny colour was a majority vote. Both converters use it.
- Still approximate: PokeAPI shinies that don't line up with their fronts (Galarian Darumaka, Pumpkaboo and Gourgeist
  sizes, Vivillon and the Flabébé line) and art with far more than 15 colour pairs (Kabuki Furfrou).
- Verification: release build and boot smoke test pass; Alolan Meowth's shiny now matches PokeAPI's pixel for pixel.

## E12 — Sovereign's forms get their own front sprites

For players: 368 forms (the 98 Megas and Primals, and the regional, battle, item, fusion, cosmetic and female forms)
show their own front and shiny front (PokeAPI's, owner 2026-10-26) instead of the base species'. Every form has one
(420 of 421; owner: "ensure they all have PokeAPI front and shiny front"), including the 52 that PokeAPI draws like
their species (the Totems, Scatterbug's and Spewpa's patterns); only Mega Zygarde, which PokeAPI lacks, keeps Zygarde's. Unfezant,
Frillish, Jellicent and Pyroar get PokeAPI's female front, sharing the front palette with the male one. Their backs are still the species' (no back art yet); Mega Zygarde keeps
Zygarde's sprite (PokeAPI has none).

- `tools/sprites/convert_form_sprites.py` converts `assets/sprites/packs/pokeapi_fronts/forms/` into
  `decomp/res/pokemon/sovereign_form_sprites/` (front, normal and shiny palette per form; `order.txt`, `meson.build`)
  and writes `include/data/sovereign_form_sprites.h` (`sSovereignFormSprite`, by `sSovereignForms` entry).
- `make_pl_pokegra.py` packs them after the back palettes (`zform-*`), and `BuildPokemonSpriteTemplate` uses them for
  a front at `POKEGRA_FORM_SPRITE_BASE + sprite * 3` when the form has one.
- Most Megas are bigger than 80×80 and were scaled (83–99%); 39 had more than 15 colours (the Legends: Z-A Megas
  most). The form's y offset is still the species' (`sprite_data.json`), so a few may sit a little high or low.
- The lookup runs after the species' own cases and before the form is sanitized, so Fairy Arceus and the like are
  covered too. A form can also have a female front (`sSovereignFormFemaleSprite`; Hisuian Sneasel), used for a
  female Pokémon in that form.
- Verification: release build and boot smoke test pass; the archive has 9,315 files and every form's front and
  palettes sit in the slots the game reads. Not yet seen in a battle.

## E12 — front and back sprites get palettes of their own

For players: the new species' sprites keep their colours. Platinum gave a Pokémon's front and back sprite one shared
palette of 15 colours; now each has its own (owner, 2026-10-26), so only 7 of the 532 new species still lose a few
colours, down from 165.

- `pl_pokegra.narc` keeps each species' six files where they were, then adds two back palettes (normal, shiny) per
  species at the end (`tools/scripts/make_pl_pokegra.py`, files named `zback-*` so they sort last).
  `BuildPokemonSpriteTemplate` (`src/pokemon.c`) loads a back sprite's palette from
  `POKEGRA_BACK_PALETTE_BASE + species * 2 + shiny`.
- A species with no `back_normal.pal`/`back_shiny.pal` (#1–493) gets copies of its front palettes, so it looks as
  before. The Diamond/Pearl sprite path and Platinum's own form archive aren't touched.
- `tools/sprites/convert_battle_sprites.py` writes `back_normal.pal` and `back_shiny.pal` for #494–1025.
- Verification: release build and boot smoke test pass; the archive has 8,208 files (1,026 × 6 + 1,026 × 2), and for
  #494–1025 every front and back palette sits in the slot the game reads; #1–493's back slots equal their front
  palettes. Not yet seen in a battle.

## E12 — PokeAPI fronts for #494–1025

For players: the new species' front and shiny front sprites are PokeAPI's (owner, 2026-10-26); their backs and shiny
backs stay those from the owner's pack.

- `assets/sprites/packs/pokeapi_fronts/` holds PokeAPI's front and shiny front for #494–1025.
  `tools/sprites/convert_battle_sprites.py --fronts DIR` takes the fronts from there and the backs from the pack.
- Front and back still share one 15-colour palette, so 165 species had colours reduced, and 107 PokeAPI fronts are
  bigger than 80×80 and were scaled down. 11 PokeAPI shiny fronts don't line up with their fronts (Vivillon,
  Flabébé, Floette, Florges, Toedscruel and others), so their shiny palette is approximate; the owner chose PokeAPI
  fronts for these too. `docs/BattleSpriteImport.md` lists every species.
- Megas and other forms are left for when forms get sprites of their own.
- Verification: release build and boot smoke test pass; a contact sheet of 24 species looked right.

## E12 — the Gen 5–9 battle sprites are in the game

For players: #494–1025 show their real front, back and shiny sprites in battle instead of the Unown placeholder.

- The owner's relabelled pack (`Gen5-9_Sprites_relabeled`, 2026-10-26) replaces `assets/sprites/packs/gen5_9_part1`:
  all four sprites for all 532 species. 152 of them were edited by hand by the owner's artist, Nolan Herkomer
  (`CITATIONS.md`).
- `tools/sprites/convert_battle_sprites.py` writes each species' `{male,female}_{front,back}.png`, `normal.pal`,
  `shiny.pal` and `sprite_data.json`:
  - Front and back share one palette of 15 colours plus transparency; the shiny palette takes, for each colour,
    what the shiny sprite has in the same place.
  - Each frame is 80×80, centred on the art and keeping the source's space under the feet. Art bigger than that is
    scaled down (40 species) and 14 had their colours reduced; `docs/BattleSpriteImport.md` lists them.
  - The y offsets are the empty rows under the art, as in Platinum's own data. Flying types and Levitate users
    hover (`addl_y_offset` 16). The shadow size follows the front's width.
  - #1–493 (Renegade Platinum's sprites) aren't touched. Female sprites are copies of the male ones for now.
- Verification: the release build and the boot smoke test pass; a contact sheet of 24 converted species (normal and
  shiny, front and back) looked right. Not yet seen in a battle.



## Playtest pass — the object test checks it ran the object's own script

The last object run showed that `tools/test/talk_to_objects.py` counted any script as the object's. Now:
- **The object's own script:** after the A press, the first script the field starts (`gSovereignTestScripts`) must
  be the object's own: its script, or for a trainer its battle's.
- **A trainer who sees the player first** walks up and battles, as for a player. Then the test warps back to the
  tile, facing the object, and talks once more.
- **STANDIN:** another object answered from the object's tile, so the object is hidden on a new game. That passes,
  as NOSCRIPT does. It is an object placed on the same tile, or any object the second time. On a new game:
  - Pokémon Mansion's west and far-east maids stand on the tiles of two of Team Galactic's grunts until the siege.
  - Cresselia stands on the Lati rock's tile until she's caught. The rock comes after that, with the Lunar Wing.
  - Route 210 North's Double Team walk onto hidden Zamazenta's tile.
- **OTHER:** any other script, twice in a row. It fails, with a screenshot.
- **No input on a warp until a script starts:** an A press meant for a scene on entering the map could talk to the
  object as the warp ended. At Snowpoint's temple that started the guards' challenge, and their battle removed Aran
  before the test's own A press.
- **The clock reads noon** (`gSovereignTestClock`) in every test that comes in through `arrive()`: the object, sign
  and trigger, gift and wild-form tests. Results no longer change with the time of day, as when Route 212's
  policemen came out at night and saw the player.

**Results:** everything passes, with no **HEAP**.
- **Objects:** all 252. 136 run their own script to its end, 112 are hidden on a new game, and 4 have a stand-in.
  The last run's 142 objects that "ran" a script were 135 objects' own scripts and 7 others':
  - Route 212 North's Stake 1, Grunt 2 and Grunt 3 are hidden on a new game. At Stake 1 and Grunt 3 the
    policemen, out at night, had answered. At Grunt 2's tile a trainer sees the player even by day, so the test
    now fights them and talks again.
  - The Mansion grunt trio and east grunt, the Lati rock and Zamazenta are hidden, with their stand-ins (above).
  - Aran, whom the last run's early A press removed, now runs his own script too.
- **Signs, hidden items and triggers:** all 84.
- **Gifts:** all 59.
- **Wild Pokémon's forms:** all 153 map headers. 19,104 Pokémon were made, with no problems.


## Playtest pass — the Trainers' School Egg, and heap checks in every harness

- **The Trainers' School Egg:** the gift test (`tools/test/gift_pokemon.py`) now also covers the Cowgirl's Egg, for
  59 runs. It must be an Egg of one of the 18 babies her script picks from at random, at Lv. 1, knowing its species'
  moves at that level. The party hook (`gSovereignTestParty`) now notes whether each Pokémon is an Egg, so every other
  gift must not be one.
- **Heap checks in every playtest harness:** a broken heap shows up only later, as a crash or memory written over, so
  the harnesses now check the heaps (`heap_check.py`) where they find the field free again. A step that leaves them
  broken gets the result **HEAP**.
  - The battle tests: `fight()` in `tools/test/battle_all_trainers.py` checks at each battle's end. The trainer,
    species, form-change, evolution and Egg tests all fight through it.
  - The field tests: `talk_to_objects.play_out` and `gift_pokemon.talk_and_answer` check when a script or warp ends,
    for the object, sign and trigger, gift and Elite Four tests. `visit_changed_maps.py` checks on each map.
- **Fix: long harness runs no longer die after 250 cases.** Each save state load reopens desmume's SDL sound. That
  takes one more hold on SDL's audio subsystem, and on its events subsystem, which audio brings up, and the hold is
  never given back. At 255 holds SDL aborts the process. That is why the species test's workers stopped after 250
  cases each. `Driver.load_state` (`tools/test/drive.py`) now gives the holds back after each load, and every harness
  loads its states through it. One process loaded a state 400 times with no abort.

**Results:** the heap checks found no broken heap in any harness (no **HEAP**), and everything else passes as before.
- **Gifts:** all 59 runs, the Trainers' School Egg included (this run's Egg was a Wynaut).
- **Species and forms as wild Pokémon:** all 1,510.
- **Battle form changes and form-change items:** all 211.
- **Signs, hidden items and triggers:** all 84.
- **Objects:** all 252 end with no hang: 142 ran a script, and for 110 nothing ran. The run showed that the test
  can't yet tell an object's own script from another one, so four results differ from the last run:
  - A trainer who sees the player counts as the object's script. Route 212's policemen come out at night, and the
    test's clock is the real one, so Stake 1 and Grunt 3 there (hidden on a new game) "ran" tonight.
  - An A press meant for a scene at the end of the warp can talk to the object first. At Snowpoint's temple that
    starts the guards' challenge, and their battle removes Aran, so the test's own A press finds no one.
  - The Sandgem lab's briefcase ran this time.
- **Changed maps:** all 182 load. 174 are idle at once, and 8 open on the scenes listed under "every changed map
  loads" below.
- **Not rerun yet with the checks:** the trainer, evolution and Egg tests.


## Playtest pass — Elite Four runs

A new test, `tools/test/elite_four_runs.py`, plays the Elite Four and the Champion in the test build. It takes each
path through the battle formats in `docs/EliteFourFormat.md`, for 13 runs of five battles:
- **The first challenge:** all six ways to pick.
  - Singles twice: Flint and Lucian get doubles, with no question.
  - Doubles twice: Flint and Lucian get singles, with no question.
  - The four mixed pairs, with Flint's pick either way.
- **The rematch menu:**
  - All singles, all doubles, and two and two, with the rematch teams.
  - All doubles before Stark Mountain, with the first teams.
- **One Pokémon able to fight:** the warning before a double battle is answered yes (a lone Pokémon in a double
  battle) or no (singles). Three runs:
  - A doubles pick turned down: it counts as singles for the rest of the run.
  - A forced format turned down: only that battle changes.
  - An all-doubles rematch.

Each battle must have the right trainer, format and result. The trainer is the singles one or the Sovereign doubles
one, and the rematch version once Charon is arrested. The format comes from the trainer data, so a doubles team set to
singles would show up. The battle must be won.

The runs play the real scripts. The player warps onto each room's entrance, as the elevator brings them, walks up to
the member and talks. Each menu gets the run's answer, and the battles are fought in god mode. A run ends after
Cynthia's battle, before the Hall of Fame.

**Results:** all 13 runs pass with the fix below: 65 battles, each with the right trainer and format. Before the
fix, the 10 runs with a full party passed, and the 3 with one Pokémon failed.

**Fixed: a double battle with one Pokémon broke the system heap.** The runs with one Pokémon able to fight crashed
or wrote over memory in the room after a double battle. Totem trials with one Pokémon (decision 18) had the same bug.
- **The cause:** the empty slot (CB-0032) had an inactive sprite but no sprite data, as nothing was ever sent out.
  Move animations copy every battler's sprite with its palette (`BattleMonOBJData_New`), and for the empty slot that
  palette came from NARC 0, member 0, which isn't a palette.
- **Why it spread:** the failed load was freed as `Heap_Free(NULL)`. That put a block at 0xFFFFFFE0 on the system
  heap's free list, and later allocations and file loads landed on whatever memory it pointed to.
- **The fix:** `BattleDisplay_SovereignSetAbsentBattler` now also gives the empty slot the sprite data a fainted
  battler would still have: a real palette (species 0's) and blank tiles.
- **Found with:** heap walks between frames, then a hook on `Heap_Free(NULL)` that named the palette load.
- **New check:** `tools/test/heap_check.py` checks every heap's lists of used and free blocks. The Elite Four runs
  call it after each battle.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestTrainerBattles`: the trainer battles the field starts, with each one's trainer, battle type and
  result.
- `gSovereignTestVar` now takes up to four vars or flags. A flag is a number below `VARS_START`: 0 clears it, and
  anything else sets it. A run can set `FLAG_GAME_COMPLETED` and `FLAG_ARRESTED_CHARON_STARK_MOUNTAIN` this way.
- The hooks don't change the shipping ROM: with the fix, it builds to the same bytes with and without them. It builds
  without warnings and passes the boot smoke test.


## Playtest pass — Paradox dealers and Mythical restyles

The gift test (`tools/test/gift_pokemon.py`) now also covers the gifts that need a Pokémon shown to the giver, for 58
runs in all:
- **The Mining Museum's Paradox dealers:** each of the 21 pairs in their list (`sParadoxForms`). The fossil maniac
  takes a present-day Pokémon and gives its ancient Paradox Pokémon, the futuristic scientist its future one. Both
  Gardevoir and Gallade lead to Iron Valiant. The Paradox Pokémon comes at the shown one's level.
- **The deliveryman's two Mythical entries:** a Magearna or Zarude shown to him is restyled into Original Color
  Magearna or Dada Zarude. Its form, ability and stats change; its moves stay.

For these runs, the next test warp adds the Pokémon to show to the party at Lv. 50, and gives all eight badges (the
dealers appear only then). The script's party screen is answered like its other menus: the cursor moves to the
Pokémon's slot and A picks it.

**Results:** all 58 runs pass, and the runs found no game bugs.
- The 23 new runs pass: 21 Paradox Pokémon and the two restyles.
- The 35 earlier gifts still pass.

Rowan's briefcase now starts later in the story, with Rowan back in his lab (`VAR_SANDGEM_TOWN_LAB_STATE` 3). On a
new game his first-visit scene plays as the player comes in, and the briefcase finds him gone. The case passed in one
run and not in the next, so it now starts where his scene is over.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestPartyAdd`: the next test warp adds this Pokémon to the party.
- `gSovereignTestMenu` also counts the party screen a script opens to pick a Pokémon (a third kind of menu).
- The shipping ROM is unchanged: it builds to the same bytes with and without these hooks.

## Playtest pass — gift Pokémon

**`tools/test/gift_pokemon.py` (local; about 20 minutes)** receives every Pokémon gift Sovereign added, in the test
build, through the real scripts and menus, and checks what arrives in the party. There are 35 gift runs:
- **Event-gift deliveryman** (Fight Area Pokémon Center): each event form on his list that is a gift, 21 in all.
  The two Mythical entries are restyles, not gifts.
- **Battle Bond Greninja**, from the Ace Trainer there.
- **The eight Pokémon Center Interviewers:** the quiz, with its right answers read from each script, and the battle
  against the region's three starters. Then, talking again, the prize.
- **The other added gifts:** Lapras, Steven's Beldum, Porygon, the Twinleaf Eevee and Rowan's briefcase.

Each run starts from the save state:
- The party is cut to its lead, to make room.
- The player comes in by the map's way in and warps next to the giver, then talks as many times as the gift takes.
- The script plays out on the real menus. When it shows a menu, the test moves the cursor to the entry it wants and
  presses A, or answers the yes/no question (no nickname). Otherwise A pages through the text, and taps pick moves in
  a battle (god mode).

Each gift must arrive with:
- its species, form and level;
- an ability of its form's, not its Hidden Ability;
- its held item (the Interviewers' starters carry Miracle Seed, Charcoal or Mystic Water, Lapras NeverMeltIce);
- its moves: the form's level-up moves at that level, with an event form's signature move last, or Greninja's four
  set moves.

**Results:** all 35 gifts arrive as they should, and the runs found no game bugs. That is 47 Pokémon: 21 event
forms, Battle Bond Greninja, the 24 Interviewer starters, Lapras, Beldum, Porygon, Eevee, Chimchar and Piplup.

The harness took three fixes:
- A list menu ignores keys for its first frames, so the test waits 10 frames before it answers a menu.
- A press of A for text could land on a yes/no question as it opened, answering it with the default. The test now
  counts menus as the script shows them and never presses A into one it hasn't seen.
- In battle the test taps the moves, as the talk test does. The lead's first move, Precipice Blades, can't touch
  Alola's Rowlet.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestPartyKeep`: the next test warp leaves only that many Pokémon in the party.
- `gSovereignTestBadges`: the next test warp gives these badges.
- `gSovereignTestParty`: the party, written down on request while the field is free.
- `gSovereignTestMenu`: the menus scripts have shown and the last one's kind. A menu is counted as the script starts
  waiting on it, before it reads any input, so the test never presses A into a menu it hasn't seen.
- `talk_to_objects.arrive` takes a setup step that runs once the save state is loaded.
- The shipping ROM is unchanged: it builds to the same bytes with and without these hooks.

## Playtest pass — wild Pokémon forms on every map

**`tools/test/wild_forms.py` (local; about 20 minutes in 4 parts)** checks the forms of the wild Pokémon the real
encounter code makes, in the test build. It covers all 153 map headers that have wild encounters, and each of their
terrains: land (grass and caves), surfing, and the Old, Good and Super Rods.

On each map the test runs a survey (`gSovereignTestWildSurvey`). A survey runs the map's encounter 48 times through
the game's own code (`WildEncounters_TryWildEncounter`, `WildEncounters_TryFishingEncounter`), with no encounter roll
and no battle. It records each Pokémon made: its species, form, level and personality. Each quadrant of the Regional
Forms Park is surveyed on its own.

Each form must follow the first rule that applies:
- **Regional Forms Park:** one of the zone's Pokémon for that terrain, in its form. A quadrant with no list for a
  terrain uses the park's usual table and the rules below.
- **Shellos and Gastrodon:** East Sea where the map's encounter file says so, else West Sea.
- **Unown:** one of the letters of the map's Unown table, across the 18 Solaceon Ruins rooms and their 8 tables.
- **Deerling and Sawsbuck:** the season of the month. On their two maps (Routes 204 and 229), each terrain is
  surveyed in all four seasons.
- **Everything else:** the form its personality gives (Minior's core, Vivillon's pattern, a female Meowstic...) or
  the base form. So no Totem, regional or other form turns up in the wild outside the park.

**Results:** every form was right, and the runs found no game bugs.
- **Scale:** 398 surveys and 19,104 Pokémon. Every survey made all 48.
- **Forms other than the base form:** 108 of them, across 64 species, all as the rules say. They include:
  - the regional forms, in their own park zones;
  - East Sea Shellos and Gastrodon;
  - 26 Unown letters;
  - all four Deerling and Sawsbuck seasons;
  - Basculin's stripes, Oricorio's styles, Paldean Tauros and Wooper;
  - Scatterbug, Spewpa and Vivillon patterns;
  - Squawkabilly's plumages, Tatsugiri's forms, and Antique and Artisan teapots.

The harness took two fixes:
- A survey of 48 encounters takes the game about 10 frames, so the test waits for it to end before reading it.
- The game reads the clock only every 11 frames, so the test waits after setting the month.

**Test-build hooks** (`include/sovereign_test.h`, `src/overlay006/wild_encounters.c`):
- With `gSovereignTestWildSurvey.wanted` set, SELECT+L+R runs `SovereignTest_WildSurvey`. During a survey:
  - the terrain is the one asked for, whatever tile the player stands on;
  - every step and every cast finds a Pokémon;
  - roamers, the Poké Radar, a Repel and the lead's Intimidate or Keen Eye are left out;
  - each Pokémon is recorded, and no battle starts.
- The shipping ROM is unchanged: it builds to the same bytes with and without these hooks.

## Playtest pass — signs, hidden items and triggers

**`tools/test/signs_and_triggers.py` (local; about 10 minutes in 4 parts)** runs each bg event (sign, hidden item) and
coord trigger that Sovereign added or changed, in the test build. That's 83 events in all, each one either missing
from vanilla Platinum or with a script whose code differs from vanilla's:
- 25 new or moved: the library book, the Celestic shrine, the Gengar painting, two hidden items, the Celebi, Mansion siege,
  Snowpoint tremor, Wayward Cave and other story triggers;
- 58 vanilla ones whose script Sovereign changed: the ruins' statues, the League statues, the Galactic lab machines,
  Cheryl, Riley, Mira, Maylene, the Spear Pillar grunts and others.

Each event is reached as the talk test reaches an object. The test comes in by the map's way in, then warps next to the
event, facing it:
- **A sign or hidden item:** A is pressed, from the side the sign is read from.
- **A coord trigger:** its var is set to the value it waits for, then the player steps onto it. The var is set after
  the warp, because a map's own local vars are cleared on the way in.

The script is then played out as in the talk test. To pass, the event's own script must be the first to start, with
no other scene and no object in the way, and it must end with no hang.

Mira's exit at Wayward Cave runs twice:
- with her ribbon quest open: she stays, and the script ends at once;
- with the ribbon found: she thanks the player and gives TM85.

**Results:** all 84 runs pass, and the runs found no game bugs. Two negative controls fail as they should:
- a trigger stepped on with the wrong value;
- a sign pressed while facing away from it.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestVar` with no warp target: SELECT+L+R sets only the var, on the map the player is on.
- `gSovereignTestScripts` counts the scripts the field starts (`ScriptManager_Set`) and keeps the first one's ID. The
  test uses it to tell that a script which ends at once did run, and which script it was.

**Refactor:** `talk_to_objects.py`'s tile finding and arrival steps are now functions that both tests use. The talk
test's list of 252 objects is unchanged.

## Playtest pass — talking to every added object

**`tools/test/talk_to_objects.py` (local; about an hour in 4 parts)** talks to each of the 252 map objects with a script
that Sovereign added or moved (`check_object_tiles.py`'s list), in the test build:
- **Setting up:** it comes into the map by its way in (the tile a player steps onto from its first warp), and plays
  out any scene on entering it there. Then it warps next to the object (or across a counter), facing it, and presses A.
- **Playing it out:** A pages through text and answers prompts, taps pick moves in a battle, and B now and then backs
  out of a menu, until the field is free again. God mode is on, so a trainer's battle ends at once.
- **To pass:** the script must end, with no hang. An object that nothing answers isn't there on a new game: a flag
  hides it until later in the story.

Two scenes on entering a map need the story's own way in, so the test marks them as seen first:
- Flint at Sunyshore's gate, as the player comes from Route 222;
- Mars and Jupiter in Stark Mountain, with Buck along.

**Results:** all 252 pass, and the runs found no game bugs.
- **Script ran and ended:** 140 objects, including all the Battleground's trainers and the 24-battle Battle Marathon.
- **Hidden on a new game:** 112, each behind a flag until later in the story.

The harness took a few rounds to get right:
- A scene on entering a map has to play out where the player really arrives.
- A busy map can miss the frame a button goes down.
- The Battle Marathon ran the lead's moves out of PP, so in god mode the player's moves now cost no PP.

The marathon passed on that last build. The other 251 objects ran on the build before it, which differs only in that
PP rule.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestWarpTarget` also sets the way the player faces.
- `gSovereignTestVar` sets a var before the next test warp.
- In god mode the player's moves cost no PP, so the Battle Marathon's 24 battles can't leave the lead with no move.


## Playtest pass — Zero to Hero, and the forms' TMs

**Fix: the forms that share their species' learnset can learn Renegade's six swapped TMs as it can.** E10's TM swaps
(Scald, Wild Charge, Bug Buzz, Hyper Voice, Dazzling Gleam and Hurricane) reached the base species but not 49 forms
that copy their learnset. Rerunning `tools/engine/gen_forms.py` rebuilds them from the species, so they get its TMs:
- Partner Pikachu, the six costume Pikachu (Wild Charge) and Partner Eevee (Hyper Voice);
- Totem Gumshoos (Wild Charge), Totem Salazzle (Hyper Voice) and Totem Araquanid (Bug Buzz, in place of Scald, which
  Araquanid can't learn here);
- the Megas, which change nothing in play, since a Pokémon is never taught a TM while Mega Evolved.

**`tools/test/battle_form_changes.py` now covers Zero to Hero** (211 cases). Palafin uses Flip Turn, and the foe
survives the first turn, so Palafin switches out. It must become Hero Palafin, and be back in its Zero Form after the
battle. **Result:** it passes. Test-build hook: a Zero to Hero form change on the player's side is recorded in
`gSovereignTestPlayerBattleForm`, as the other battle form changes are.


## Playtest pass — evolving and breeding into forms

**Fixes:**
- **A female Espurr or Lechonk can evolve.** Their only evolution was "level 25 (18) as a male", so a female never
  became Meowstic or Oinkologne. Either gender now evolves at the same level, and the gender picks the form (a female
  becomes the female's form). The species generator (`tools/engine/gen_new_species.py`) now turns a male and a female
  evolution by the same method into one, for any species like them.
- **An Eevee that knows Charm becomes Sylveon, even with high friendship.** Espeon's and Umbreon's friendship came
  first in Eevee's list, so a friendly Eevee that learned Charm still became Espeon or Umbreon. Sylveon now comes first,
  as in Sword and Shield. No other species has two level-up evolutions whose conditions can both hold.
- **A Deerling keeps its season when it evolves.** A Sawsbuck took the season of the day it evolved instead, so a
  Deerling met in spring could become a summer Sawsbuck.
- **Eggs:**
  - A female Basculegion's Egg is a White-Striped Basculin, as a male's is. It was a Blue-Striped one, because the
    female's form number was passed on as Basculin's.
  - A Mr. Rime's Egg is a Galarian Mr. Mime (or a Mime Jr. with the Odd Incense), like the other species found only
    through a regional form (`regional_parents` in `data/evolution_changes.yaml`).
  - A parent in any other Sovereign form passes no form to its Egg (`Pokemon_SovereignBabyForm`): a Totem (a Totem
    Togedemaru or Mimikyu laid Totem Eggs), a female's form, Low Key Toxtricity, or Three-Segment Dudunsparce. An Egg
    whose species takes its form from its personality still does (the Flabébé line's colors). Platinum's own forms are
    kept as in Platinum (Burmy's cloak and Shellos's sea come from the mother).

**`tools/test/battle_evolutions.py` (local; about 25 minutes in 4 parts)** evolves every Pokémon whose evolution
involves a form, as the evolution screen does, then battles in its new form. There are 336 cases:
- **Start forms:** every form but the battle forms. A regional form evolves by its own evolutions (Galarian Meowth
  into Perrserker, the Hisuian, Alolan and Paldean lines, the Basculin stripes, Roaming Gimmighoul). Any other form
  evolves by its species' (the Flabébé and Scatterbug lines' colors and patterns, Pumpkaboo's sizes, Burmy's cloaks,
  Deerling's seasons, the teapots), and so does each base form.
- **Variants:** each form the evolution can give, such as each gender for Meowstic, Basculegion and Oinkologne, a
  Low Key Toxtricity, the Antique and Artisan teapots, and Rapid Strike Urshifu.
  - **Milcery:** every one of Alcremie's 63 forms (each Sweet with each cream).
  - **Rockruff:** Midday, Midnight and Dusk Lycanroc by the hour.
  - **Day and night evolutions:** Hisuian Sneasel into Sneasler, and Espeon and Umbreon.
- **Forms that must not evolve** don't: the cap and costume Pikachu, Partner Pikachu and Eevee, Eternal Floette and
  Spiky-eared Pichu. An Antique Sinistea doesn't evolve with the Cracked Pot, nor an ordinary one with the Chipped Pot
  (the teacups the same).

Each case checks that it evolves into the right species and form, and that the form lasts through a battle. The
expected form is worked out as the game's rules give it. The names cross-check it: Galarian Darumaka must become
Galarian Darmanitan, and Flabébé (Yellow Flower) must become Floette (Yellow Flower). Alcremie must be named for its
Sweet and the cream the time gives.

**`tools/test/battle_eggs.py` (local; about an hour in 4 parts)** breeds every form in the Day Care and hatches the
Egg at once, then battles with the hatched Pokémon. There are 874 cases, from every form but the battle forms of each
species outside the Undiscovered egg group:
- each form as the mother with a Ditto, and as the father with a Ditto;
- for a regional form that passes on its region: a base-form mother with the regional father, whose form must not pass
  on;
- with and without the incense, for a parent whose baby is an incense baby (Galarian Mr. Mime and Mr. Rime).

Each case checks the Egg's species and form, that it hatches into them, and that the form lasts through a battle.
The names cross-check the form when the Egg is another species (Galarian Rapidash: Galarian Ponyta; Alolan Raichu:
Pichu).

**Results:**
- **Evolutions:** 335 of 336 passed on the first build. The failure was the Sylveon bug above; on the fixed build all 16
  of Eevee's cases pass, including Partner Eevee's eight, which must not evolve. (The other changes between the two
  builds don't touch evolution.)
- **Eggs:** all 874 pass (on the build with the fixes), once the harness expects a Burmy's cloak to change in the
  battle: as in Platinum, a Burmy takes the Trash Cloak after an indoor battle.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestEvolve`: evolves the lead before the battle, with an evolution's class and item or map method.
- `gSovereignTestBreed`: breeds two Pokémon in the Day Care with a chosen Egg personality, hatches the Egg and makes it
  the lead.
- `gSovereignTestClock`: the hour and month the game's clock reads (`rtc.c`).
- `gSovereignTestLead` also sets the personality, gender and friendship.


## Playtest pass — form-change key items and held-item forms

**`tools/test/battle_form_changes.py` now also covers the forms the player changes outside battle** (210 cases in all,
about an hour). These are tested through the code the bag and the party menu use, not their screens:
- **Key items**, used on the lead as from the bag (`SovereignFormItem_Use`):
  - the Reveal Glass on the four Forces of Nature, the Prison Bottle on Hoopa and the Zygarde Cube through Zygarde's
    four formes, each from every form to the next;
  - each fusion (DNA Splicers with Reshiram and with Zekrom, N-Solarizer, N-Lunarizer, Reins of Unity with Glastrier and
    with Spectrier), fused before a battle and separated after it;
  - each nectar on an Oricorio of another style, and one on an Oricorio already in its style;
  - the Reveal Glass on Garchomp, and the DNA Splicers on a Kyurem with no partner, which do nothing.

  Each use must give the right result and form. A fusion must take its partner out of the party and give it back.
  The moves a form brings must change both ways (Kyurem's Glaciate and Scary Face, Hoopa's Hyperspace Hole, the fused
  Necrozma's and Calyrex's signature moves). The form must last through a battle.
- **Held-item forms**, given the item as the party menu gives one: Ogerpon's three masks, Origin Dialga and Palkia,
  Arceus with each of the 17 Plates (and an item that isn't one), Silvally with each of the 17 Memories, Genesect with
  each Drive, and Giratina with the Griseous Orb or Core.

**Results:** all 210 cases pass, and the runs found no new bugs. (The 164 battle and key item cases ran on one build and
the 46 held-item cases on the next, which only adds the item-giving step for those species.)

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestPartner`: the party's second Pokémon, for a fusion.
- `gSovereignTestItemUse`: a key item used on the lead, before the battle and optionally after it, with what each use
  did.
- The lead is given its item as the party menu gives one, so a held-item form takes its form.


## Playtest pass — every battle form change from the player's side

**`tools/test/battle_form_changes.py` (local; about an hour) replaces `battle_all_megas.py`.** As well as every Mega,
Primal and Ultra Burst and the forms that must not Mega Evolve, it now makes each form change the battle itself brings
happen to the player's lead. Each case is set up so the change happens:
- **Ability forms:**
  - Zen Mode (Darmanitan and Galarian Darmanitan), Shields Down (all 7 Minior colors) and Power Construct (both
    Zygarde formes), at 40% HP;
  - Gulp Missile, using Surf at full HP (Gulping) and at 40% (Gorging);
  - Disguise and Ice Face, hit by the foe;
  - Stance Change, attacking;
  - Schooling, Tera Shift and Fairy Aura (Active Xerneas), as it comes in;
  - Hunger Switch, at the end of a turn;
  - Battle Bond, knocking the foe out.
- **Item forms:** Crowned Zacian and Zamazenta.
- **Move forms:** Pirouette Meloetta, using Relic Song.

Each must take the right form in battle and be back in its own form afterwards. **All 137 cases pass**, and the run found
no new bugs. Hero Palafin isn't covered, since Zero to Hero needs the harness to switch Pokémon.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestLead` also sets the lead's moves, its HP and its hidden ability.
- `gSovereignTestWild` can give the foe a single move. Here it's Bullet Punch: physical, first to move, and no type is
  immune to it.
- `gSovereignTestFoeSurvivesTurns` keeps the foe from fainting in the first turn in god mode, so turn-end abilities act
  and the foe gets to hit.
- The Crowned form, which the lead takes as the battle starts, is recorded too.


## Playtest pass — every species and form battled, every Mega Evolved; form moves and Megas fixed

**New tool `tools/test/battle_all_species.py` (local; about an hour with 4 jobs).** It battles all 1,510 species and
forms as wild Pokémon at Lv. 50 in the test build: each of the 1,025 species in its base form, and each of the 485
forms (Platinum's 64 and Sovereign's 421). For each one it checks that:
- the game builds the Pokémon from its form's data: species, form, level, the form's level-up moves, all six stats
  (from the form's base stats and the Pokémon's own IVs, EVs and nature), the ability its personality picks and a held
  item the form can have;
- the battle ends and the main loop never stops.

**New tool `tools/test/battle_all_megas.py` (local; about 20 minutes).** It Mega Evolves from the player's side, in a
wild battle, each of the 96 Megas from the form it comes from, Mega Rayquaza with Dragon Ascent, both Primals and both
Ultra Bursts. It also gives each species' stones to its other forms (Alolan Raichu, Galarian Slowbro, Battle Bond
Greninja, 10% Zygarde, a Floette's flower colors), which must not Mega Evolve. Each Pokémon must take the right form
in battle and be back in its own form afterwards.

**Results:** all 1,510 species and forms battle cleanly and are built from their form's data, and all 113 Mega cases
pass. (The first run's four workers were stopped partway by something outside the game; the 539 entries they hadn't
passed were run again on the final build.) The checks follow the game's own rules where a form isn't simply the one
asked for: a base form may come back in a form its personality or the map picks (Minior's core, a Female Meowstic, an
Unown letter, East Sea Shellos), Keldeo is Resolute only while it knows Secret Sword (a Lv. 50 Keldeo has forgotten
it), and Battle Bond Greninja may still become Ash-Greninja. The runs found these, now fixed:
- **Form moves for wild Pokémon, Eggs and gifts.** A Pokémon is made with its base form's moves before its form is set
  (trainers were fixed in the last entry). Now these get their form's level-up moves too:
  - a wild Pokémon whose slot names a form (the Regional Forms Park, the Totems and their helpers);
  - an Egg that takes a regional parent's form;
  - the form gifts (Battle Bond Greninja, the deliveryman's event forms).
- **Megas from another form.** Female Meowstic, Eternal Floette, Droopy and Stretchy Tatsugiri and Original Color
  Magearna couldn't Mega Evolve: the check turned down any Pokémon not in its base form. So Mega Floette, which comes only
  from Eternal Floette, was never possible. Now only a battle form (a Mega, a Primal, Complete Zygarde...) is turned
  down. A Mega comes only from the form it goes back to, so a form without a Mega of its own still can't use the stone.
- **Slot forms for Shellos, Gastrodon and Unown.** Platinum sets these three species' forms from the map (East or West
  Sea, the area's Unown letters) as a wild Pokémon enters the battle, which overwrote a form its slot named. The map's
  form is now only for one the slot didn't name. No encounter table names a form for them yet.

**Test-build hooks** (`include/sovereign_test.h`):
- `gSovereignTestWild`: the next SELECT battles this species and form at this level, made as a slot in a form is.
- `gSovereignTestLead`: before the next test battle the party's lead becomes this Pokémon, with its item and four
  Fairy moves, and the MEGA toggle stays on.
- `gSovereignTestPlayerBattleForm` and `gSovereignTestLeadFormAfter`: the form the player's side took in battle, and
  the lead's form afterwards.
- `check_trainer_party.species_data` now finds every form's data, Sovereign's included, as the game does
  (`Pokemon_GetFormNarcIndex`), and its decoder reads all 7 bits of the form (Alcremie's forms past 31).

Form sprites aren't checked: the forms show their base species' sprites until E12.


## Playtest pass — every trainer battled; held items, form stats and form moves fixed

**New tool `tools/test/battle_all_trainers.py` (local; about 2 hours with 4 jobs).** For each of the 1,039
trainers it starts the battle in the test build. It checks three things:
- the party the game builds matches the trainer's JSON: species, form, level, item, moves, IVs, EVs, nature, ability
  and every stat;
- the battle ends;
- the main loop never stops.

The run found four kinds of trainer bug in the game, now fixed:
- **Held items lost (6 trainers).** The trainer data packer (`tools/dataproc/src/trainerproc.c`, Platinum's) chose a
  party's layout from its first Pokémon: no item there meant no items for the whole party. Renegade's teams give
  items to some members only. Affected:
  - Ace Trainer Henry's Marowak (Thick Club);
  - the three Route 203 counterpart starters (Oran Berry);
  - Mars at Valley Windworks and Jupiter in the Eterna building (Sitrus Berries).

  Now any member's item decides the layout, and a member without one holds nothing. A team that gives moves to some
  members but not others is a build error, because those others would know no moves at all.
- **Form stats (Volkner, his rematch, Ace Trainer Breanna).** In Platinum's layouts a trainer Pokémon got its form
  after its stats were worked out, so it kept the base form's stats. Volkner's two Rotom forms had plain Rotom's
  stats (Defense 116 for 153 at Lv. 61). The stats are now recalculated once the form is set. (Forms that follow
  the Pokémon's gender, such as female Indeedee, were already right.)
- **Form moves (Beauty Devon).** A trainer Pokémon given no moves learned its base form's moves: Devon's Sandy and
  Trash Cloak Wormadam knew Razor Leaf and Growth. New `Pokemon_SovereignSetDefaultMoves` gives a Pokémon with a
  form that form's level-up moves, in every trainer layout that can leave moves out.
- Only those 10 trainers' teams change.

**Test-build hooks** (`include/sovereign_test.h`, behind the `sovereign_test` option):
- `gSovereignTestBattleTrainer`: SELECT+R battles this trainer.
- `gSovereignTestGodMode` makes test battles one-sided:
  - a foe that loses any HP loses all of it, and the player's Pokémon lose none;
  - the player's moves ignore the foes' abilities;
  - no EXP, Set battle style and fast text.
- The harness taps FIGHT and then Dazzling Gleam or Play Rough (it switches between them every 2,000 frames, which
  gets past Torment, Disable and moves out of PP). It presses A for messages and doubles targets.
- The earlier warp and idle hooks moved into the same header.
- `check_trainer_party.compare_party` can now be reused, and handles:
  - trainers that give no moves (the level-up moves) or no item;
  - forms' base stats;
  - Shedinja's 1 HP.

**Result: all 1,039 trainers battle cleanly.**
- **First full run (before the fixes):** 984 of 1,000 ok. The other 16 were the bugs above, or battles stalled by
  Wonder Guard, Torment or Disable before the harness handled them. The run's 2-hour time limit cut off 39 more.
- **Re-run on the fixed build:** those 16 and the 39 cut off, all ok.
- No battle stopped the game.

## Playtest checks — script menus fit on the screen; every changed map loads

**New check `tools/test/check_menus.py` (CI, rom job):** every field-script menu fits on the screen above the
message box.
- **How the window is sized:** as the engine sizes it (`src/overlay005/field_menu.c`).
  - Width: the widest entry in the system font, plus a 12-pixel cursor margin, rounded up to tiles.
  - `{CURSOR_X n}` (a price column) puts the text n − 12 pixels past the margin, as
    `FontManager_CalcStringWidthWithCursorControl` does.
  - Height: two tiles per entry; a list menu shows at most 8.
- **What must fit:**
  - The window must lie within columns 1 to 30, since the frame takes one tile on each side.
  - It must end by row 16, because the message box's frame starts at row 18. Vanilla's lowest menus end at row 16.
- **How a menu is read:** it is followed from its Init command through the script's jumps and calls to its Show
  command.
  - Entries added in branches and subroutines count, and the menu's size is the largest any path gives it.
  - A flag tested one way and then the other on the next line (the half-price shops' `CallIfUnset` /
    `CallIfSet FLAG_GAME_COMPLETED`) counts as one choice.
  - A menu set up in a subroutine is followed back through its callers.
- **Result:** all 138 menus fit. 46 entries take their width from a name or number placeholder, all in vanilla's
  menus. `-v` lists them.
- **Verified:** a lengthened Veilstone Store menu entry and a menu moved down to row 13 are both reported.

**New tool `tools/test/visit_changed_maps.py` (local; about an hour):** it warps into every map whose events or
scripts Sovereign changed (182 map headers) and checks that the field runs there.
- **Test build only** (behind the `sovereign_test` option; the shipping ROM is byte-identical):
  - `gSovereignTestWarpTarget` (`src/script_manager.c`): a place a harness writes, which SELECT+L+R then warps to.
  - `gSovereignTestIdleFrames` (`src/field_system.c`): counts the frames the field runs with no script, warp or
    battle.
- **The tool:**
  - Spawn tile: a warp on the map, or the walkable tile nearest a block's middle.
  - It reads the hooks' addresses from the build's symbol map.
  - It waits until the field is idle on the target map. `--scene` presses A, waits longer and saves screens over
    time.
- **2026-10-25 run:** all 182 maps load.
  - 174 are idle at once.
  - 8 open on a scene that runs, not a hang: the Contest Hall lobby, the Pal Park lobby (the Trainer Counter app),
    the Sandgem lab and the Battleground are vanilla's first-visit scenes and end idle.
  - Cynthia's intro and battle: singles, since warping in skips the lobby's format choice.
  - The Hall of Fame, then the save and the credits.
  - Stark Mountain: the Galactic battle in room 1, and the Charon scene and Looker's arrest in room 3.

## Playtest checks — field message lines fit the box's width

`tools/test/check_message_box_lines.py` (CI, rom job) now also checks each line's **width**.
- **Why:** the field message box is 27 tiles (216 pixels) wide, and a line is never wrapped. The part past the edge
  is cut off.
- **How:** a line's width is the sum of its characters' glyph widths in the message font
  (`res/fonts/font_message.json`, by charmap code; no spacing between letters). Vanilla's widest lines are exactly
  216 pixels. Placeholders such as names count as nothing, so it finds lines whose fixed text alone is too wide.
- **It found two Sovereign lines, now fixed:**
  - Dawn's Route 210 line "While still filling the Pokédex, of course!" (221 pixels) is now "And still filling the
    Pokédex, of course!".
  - The Electric-type Master's intro (217 pixels) breaks its two lines at "I aim", with the same words.
- **Signs too:** the check now covers sign commands (ShowMapSign, ShowArrowSign and the other kinds), against their
  own windows. Map and arrow signs are 20 tiles (160 pixels) wide; vanilla's widest is 159. All 176 sign uses fit,
  in lines and in width.
- Verified by running the check on the old texts, which reported both lines, and on a widened arrow sign.

Also: `CITATIONS.md` now carries hg-engine's sprite credits (its `CREDITS.md` credits them as a group) and the Smogon
Sprite Projects' leads, per Pokémon Showdown's credits. Smogon's per-sprite lists are in its forum threads, which
need a browser, and are still to copy.

## Decision 34 — Zekrom moves to Route 215

The owner's decision 34 (2026-10-24) is now in the game: **Zekrom stands on Route 215**, the always-raining route
between Veilstone and Solaceon, in place of Valley Windworks' island. That leaves the islands to Zapdos's Renegade
portal (decision 33).
- **Its spot:** the north-west loop, north of the big tree (590, 578). It's a quiet loop off the route's path. The
  tile check (`tools/test/check_object_tiles.py`) finds it reachable from either side of the tree, and it cuts
  nothing off.
- **Unchanged trigger:** the Dark Stone in the bag, at night (8 pm to 4 am). The Dark Stone's crackle line now lives
  in Route 215's text bank. Zekrom is Lv. 70 and stays until caught.
- **Route 215 gets an OnLoad script** to remove Zekrom after its battle.
- **Valley Windworks:** Zekrom's object, scripts and text are gone. Zapdos's script entry moved from 10 to 9, and
  the map's OnLoad goes straight to Zapdos's removal.
- **The Archivist's hint** now says "Try rainy Route 215, at night."

Docs:
- `docs/LegendaryTriggers.md`, `docs/LegendaryPlacementReview.md`, decision 34 in `docs/ProjectStatus.md`.
- `data/postgame_legendaries.yaml` → `docs/PostgameLegendaries.md`.
- **The review's last open clash (8, Mt. Coronet) is settled.** Mt. Coronet's doorway leads to Regice's chamber only
  with the Relicanth and Wailord pair in the party, and to Kyurem's room otherwise. That's as designed.
- **`docs/StaticEncounters.xlsx`:** every "Check" verdict is now "None", with the reason (the tile check, or timing).
  Two needed a closer look:
  - Kubfu is off every punching-bag track in the Veilstone Gym's track table (`src/overlay008/gym_features.c`).
  - Tapu Fini can be reached even with Wyver beside it.

Verified in a test build (night forced, Dark Stone given):
- Zekrom shows on Route 215 in the rain; its line, then the Lv. 70 battle; caught, and gone on the next visit.
- Zapdos's battle still starts from (241, 645).
- Zekrom's old island tile is empty.

## Placement tile check — Zygarde, Tapu Koko, a hidden Iron and the tutor-list signs

New tool `tools/test/check_object_tiles.py` checks the exact tile of every map object Sovereign added or moved (256
of them), against vanilla's events in the git history. It closes item 9 of `docs/LegendaryPlacementReview.md`.
- **Overlaps:** it reports another object, a sign or hidden item, a warp or a coord trigger on the same tile.
- **Reach:** it walks the map's tile collision under the engine's movement rules: Surf, Waterfall and Rock Climb;
  one-way jump ledges; bike ramps (1 or 3 tiles); no turning off an elevated bike bridge; talking across counters.
  It reports any object the player can't reach, and anything an object cuts off: a warp, a sign, a hidden item or
  another object.
- Overlaps and blocks that are on purpose are listed in the tool with their reason. Examples are siege grunts on the
  hidden maids' tiles, the Route 224 counterpart before the tablet, and Mira's gate at Wayward Cave's hidden entrance.
- It needs the git history, so it runs locally (`python3 tools/test/check_object_tiles.py decomp`), not in CI.

Fixed:
- **Zygarde couldn't be reached.** Its Wayward Cave B1F alcove (21, 4) lies under an east-west bike bridge: on the
  bridge the player can't turn north, and the ledges below only go down. It now stands in the north-west alcove
  (12, 4), which opens onto the cave floor west of that bridge.
- **Tapu Koko blocked the way to items.** At (808, 795) it stood in the only land entrance to the walled area that
  holds Route 222's Quick Ball and three hidden items, until it was caught. It now stands at the east end of the
  same sand strip (813, 795), clear of the way in.
- **Volcanion stood on a hidden Iron** at the end of its one-tile tunnel in Stark Mountain room 2 (73, 15). The Iron
  moved a tile east (74, 15), where the player can still face it from the tunnel.
- **The tutor-list signs couldn't be read.** In the Route 212 house, Snowpoint's east house and the Survival Area's
  north house, an NPC (the Beauty tutor, the Super Rod fisherman, the Psyduck) stood at (4, 3), the only tile the sign
  above can be read from. Since part 10 the signs say the moves are taught for free in the Route 212 house. Each
  NPC moved a tile east, to (5, 3).

Also checked: Magearna, Kubfu, Calyrex, Meloetta, Mira and every other added legendary are clear. Each overlap the
tool lists is sequenced by flags (Route 201's Mew and Pachirisu, the Fullmoon Island rock, the Mansion siege).

Verified in a test build: Zygarde shows in its new alcove and its battle starts; Tapu Koko's battle starts from
(812, 795); "A found an Iron!" from (75, 15), with Volcanion beside it; and the Route 212 house's sign reads "The
tutors in the Route 212 house..." from (4, 3). On the tree before these fixes, the tool reports exactly these six.

## Playtest checks — map events name scripts that exist

New check `tools/test/check_event_scripts.py`, run in CI (rom job). It catches the mistake behind the silent Battle
Tower Ability researcher (QoL #11): her object named script 26 of a 25-entry table.
- It reads every map header in `decomp/include/data/map_headers.h`.
- For each map's objects, signs and coord triggers, and each entry of its init scripts, it checks that the script
  number is within the map's `ScriptEntry` table (1–1999). Common script numbers (2000 up) must name an entry of
  `scripts_common.s`.
- All 544 map headers pass. Vanilla Platinum already has one out-of-range number, an Oreburgh City sign at
  (256, 808) naming script 45 of 22. It's listed in the check and kept as it is.
- Verified by putting the researcher's old number back, and by breaking an Elite Four room's init script: the check
  reported both.

A second check, `tools/test/check_map_links.py`, also runs in CI:
- **Warps:** every warp's destination warp index must exist in the destination map's events. A missing one drops the
  player at a wrong or garbage position. Index 0x100 ("back to the saved position") is skipped. All 1213 warps pass.
- **Map texts:** a map's scripts look their texts up in the map header's text bank (`msgArchiveID`). A text from
  another map's bank assembles fine, but the game shows the line at the same index of its own bank. Every message,
  sign and menu-entry text in 491 script files is in its map's bank (menu entries may also use the shared menu bank).
- Verified by pointing a Route 207 warp at warp 40, and by using a Jubilife City text in Route 207's scripts: the check
  reported both.

Docs:
- `docs/AIReview.md` #9 (when trainers Mega Evolve) is marked done: the AI has Mega Evolved as soon as it can since E8.
- `docs/ProjectStatus.md`'s opening summary now says where things stand.

## E11 (part) — the Elite Four format: two singles, two doubles, and the rematch menu

`docs/EliteFourFormat.md` is now in the game:
- **First challenge:** Aaron and Bertha each ask "single battle or double battle?" after their intro.
  - If the two answers differ, Flint asks too, and Lucian gets the other format.
  - If they match, Flint and Lucian get the other format with no question, and Bertha says so after her battle
    ("You've chosen single battles twice. Flint and Lucian will meet you in double battles!").
  - Cynthia is always a double battle.
- **Rematches** (after the first Hall of Fame): Aaron first offers "All singles", "All doubles" or "Two and two".
  "Two and two" works like the first challenge.
- **One Pokémon able to battle:** before any double battle the player is warned ("It would face two alone") and may
  switch that battle to singles. This covers the forced and pre-decided ones too.
- A loss resets the run. Aaron asks again, because the defeated flags reset at the Pokémon Center as in vanilla.

How it works:
- **State:** one variable, `VAR_SOVEREIGN_E4_FORMAT` (was the unused `VAR_DUMMY_0x40F4`), holds a bit per member plus
  "decided" and "announce" bits. Its only writes were two dummy increments, in Twinleaf Town and the Hall of Fame;
  those are removed.
  - New script command `SovereignVarBit`, with the macros `CheckVarBit` and `SetVarBit`, reads and writes the bits.
- **Shared scripts:** the question and the warning are new common scripts, `Common_SovereignE4AskFormat` (0x80D) and
  `Common_SovereignE4CheckLoneMon` (0x80E). Their texts are in `common_strings.json`.
- **Doubles trainers:** ten new trainers took over unused dummy slots: `TRAINER_SOVEREIGN_ELITE_FOUR_*_DOUBLES`,
  `TRAINER_SOVEREIGN_CHAMPION_CYNTHIA_DOUBLES`, and a `_REMATCH_DOUBLES` version of each.
  - They're placeholders: each is its singles team as a double battle, with the doubles AI (`AI_FLAG_TAG_STRATEGY`).
  - T1 replaces both formats with the Sovereign teams in `data/trainers_sovereign.yaml`.
  - The round 2 teams still come with Charon's arrest, as in vanilla.
- **Elsewhere:** the rematch doubles teams pay the post-game 3× prize money (decision 24). The level cap's two
  Champion steps now end with either Cynthia (`any:` in `data/level_caps.yaml`).

Verified in a test build. A test-only patch skipped each battle and logged the trainer it would have started. Each of
the seven runs logged the expected five trainers:

| Run | Choices | Logged (Aaron, Bertha, Flint, Lucian, Cynthia) |
|---|---|---|
| First challenge | S, D, Flint asked: S | singles, doubles, singles, doubles, doubles |
| First challenge | S, S | singles, singles, doubles, doubles, doubles (Bertha announced it) |
| First challenge | D, D | doubles, doubles, singles, singles, doubles |
| Rematch | All singles | the five round 2 singles teams |
| Rematch | All doubles | the five round 2 doubles teams |
| Rematch | Two and two: D, S, Flint asked: D | doubles, singles, doubles, singles, doubles (round 2) |
| One Pokémon able | D then No, D then Yes, Flint S, Lucian's forced D then No, Cynthia Yes | singles, doubles, singles, singles, doubles |

A real (unskipped) Aaron double battle starts: Yanmega and Scizor against Garchomp and Turtwig.

## E14 (part) — the Infinite Repel's ON tag in the bag (QoL #3)

The last open piece of QoL #3 (the approved list's "a bag icon shows its state"):
- While the Infinite Repel is on, its row in the Key Items pocket shows **ON** at the right end, where other pockets
  show the item count. The tag appears or goes as soon as the item is used, without closing the bag.
- The Infinite Repel can't be registered to SELECT, so the tag never meets the registered-item icon.
- The tag text is `Bag_Text_SovereignInfiniteRepelOnTag` in the bag's archive. The list's print callback draws it
  (`BagUI_PrintInfiniteRepelOnTag`), and the in-bag use task redraws the list after the toggle.

Verified in a test build:
- Turning it on shows ON on its row once the message closes.
- Closing the bag and opening it again still shows ON.
- Turning it off removes the tag at once, and it stays gone after reopening the bag.

## E14 (part) — the Ability Capsule NPC in the Battle Tower lobby (QoL #11)

A researcher (scientist) now stands in the Battle Tower lobby, at (6, 7) below the reception desks. She switches a
Pokémon between its two regular Abilities, as the Ability Capsule does:
- She asks how to pay: **50 BP**, **$20,000**, or "No, thanks". Without enough BP or money she says so and stops.
- The player then picks a Pokémon from the party screen.
- She charges only when the switch works:
  - **Two regular Abilities:** the Pokémon switches to the other one, and she names it. The payment is taken.
  - **One regular Ability, or an Egg:** "This one has only one regular Ability." Nothing is taken.
  - **Its Hidden Ability:** only the Ability Patch can change that one. Nothing is taken.
- A new script command, `SovereignSwapAbility templateArg, partySlot, destVar`, does the switch. It toggles the same
  ability-slot bit as the Ability Capsule, recalculates the ability, and buffers the new ability's name.

Text fixes:
- Six Sovereign field texts had three lines in one two-line box. The third line was printed below the box, so the
  player never saw it. The researcher's own "There!" line lost the new Ability's name this way. The others were Riley
  (Iron Island), Dawn (Route 210 North), Shade (Route 228), the Legend Archivist and the Route 221 nurse. Each now
  scrolls to a new box at the right place, or is reworded to fit.
- New check `tools/test/check_message_box_lines.py`, run in CI (rom job). It reports any text a field script shows
  through a message command with more than two lines between scrolls. Vanilla has none.

Verified in a test build (60 BP, $30,000), with RAM reads of the BP and money after each talk:
- **BP:** Archaludon switched to Stamina, and BP went from 60 to 10. The next 50 BP choice said "You don't have
  enough BP."
- **Money:** Gallade (Hidden Ability) got the Ability Patch line, and Garchomp (one regular Ability) got the "only
  one" line. Neither changed the money. Archaludon switched back to Sturdy, and the money went from $30,000 to
  $10,000. The next $20,000 choice said "You don't have enough money."
- "No, thanks" and cancelling the party screen both end with "Come back any time!"

## E10 (part 41) — Renegade's special encounters: Gengar, Spiritomb and Rotom

The "Special Encounters" in Renegade's `SpecialEvents.txt`. Gabite (E10 part 5) was already in; these three weren't:
- **Gengar (Old Chateau, the back middle-east room):**
  - A new painting on the north wall (12, 2): "Piercing red eyes are staring at you. You can suddenly feel a chill."
  - Stepping onto the room's exit afterwards fades the screen, and a wild Gengar (Lv. 20) attacks.
  - A win or a catch ends it for good (`FLAG_SOVEREIGN_OLD_CHATEAU_GENGAR_DONE`, was `FLAG_UNUSED_0x0991`). The
    painting then only "appears as if it is glaring". A loss blacks out, and the painting can be read again.
  - `VAR_MAP_LOCAL_0x01` arms the exit only for that visit. The room's texts live in Jubilife City's archive, as in
    vanilla and Renegade.
- **Spiritomb (Route 209, the Hallowed Tower):** pushing the Odd Keystone in brings Spiritomb at once, at Lv. 30.
  Renegade drops the 32 Underground talks, and so does Sovereign. Each Odd Keystone gives one battle.
- **Rotom (the Old Chateau's TV):** any time of day, and as often as the player likes, even after a catch. Vanilla
  wants night, once a day, until caught.

Not ported, owner question: Renegade's Route 218 gate guard wants the Tea before he opens the road to Canalave City.
- Sovereign gives the Tea (Darach, E10 part 33), but the Regional Forms Park lobby opens only after the Hall of Fame.
- So Darach and the Tea come too late to gate Canalave.

Verified in a test build:
- Gengar: the painting's lines, then the exit tile starts the Lv. 20 battle. After the catch, the painting only
  glares.
- Spiritomb: the Odd Keystone, "pushed the Odd Keystone into the stone tower", then the Lv. 30 battle.
- Rotom: the TV, then the Lv. 20 battle. After running away, the next talk starts another battle.

## E10 (part 40) — Renegade's Magma Stone after Heatran's catch, and Route 207's slope cyclist

Steven's first request (E10 part 13) trades the Magma Stone for the Soul Dew, which Latias and Latios need. Nothing
in Sovereign gave the Magma Stone: in vanilla, Charon's scene takes it away. Renegade gives it after Heatran:
- **Stark Mountain room 3:** catching Heatran brings "Oh?", and the Magma Stone shows for a moment where Heatran
  stood. The player obtains it, into the Key Items pocket. Knocking Heatran out gives nothing: it comes back after the
  Hall of Fame, as before.
- The catch flag (`FLAG_CAUGHT_HEATRAN`) is set after the stone, so no new flag is needed.

Found by a new audit that compares the items each map's scripts give, Renegade against Sovereign. Its other hits are
items Renegade gives under reused vanilla item IDs (the Wings, Orbs, GS Ball, Oak's Letter), which Sovereign gives
under its own constants.

**Route 207's slope, closed until Eterna City (a sequence break):**
- Mom gives the Bicycle (E10 part 11), so Route 207's slope was open from the start. A player could ride from Oreburgh
  through Mt. Coronet to Route 208 and Hearthome City before Eterna.
- Renegade's fix: vanilla's slope man moves to the slope's foot (306, 720) with new lines ("I failed to ride up the
  slope and my Bike got broken... Could I ask you to take a different route while I clean this mess up?").
- He's hidden once the Cycle Shop manager is rescued in Eterna City (`FLAG_SOVEREIGN_RECEIVED_CYCLE_SHOP_DAWN_STONE`,
  set with the Dawn Stone), as Renegade does with its own flag.
- A collision check (BFS from Oreburgh's side) shows the slope's one-tile corridor and Mt. Coronet's door can't be
  reached while he stands there.
- Found by a new audit of Renegade's NPCs against Sovereign's. Renegade's other new blockers are not needed:
  - Route 204 North's grunts, the Beedrill swarm outside Eterna Forest, and those on Routes 211 East, 212 North, 214
    and 216 stand in for the Rock Smash rocks and Cut trees Renegade removed everywhere.
  - Sovereign keeps those rocks and trees, which work from the bag's HMs with the badges (E14).

Verified in a test build (post-game, Heatran shown, Charon's scene done):
- Heatran's battle and Master Ball catch, then "Oh?", "A obtained the Magma Stone!" and "put the Magma Stone in the
  KEY ITEMS Pocket."
- Steven's Quests: "That rock you have there... That's the Magma Stone, isn't it?!" Then he takes it, gives "the
  Soul Dew!" into the Items pocket, and goes on to Latias and Latios.
- Route 207, standing below the cyclist:
  - With the Bicycle he gives Renegade's lines, and the player can't step past him.
  - With the Cycle Shop flag set he's gone, and the player reaches the slope's foot.

## E10 (part 39) — Renegade's TM collector, the Pokétch with every app, and its healers

Found by the map-script audit:
- **The TM collector** (Pokémon League, north Pokémon Center, (19, 3)) asks whether the player wants "a full use set
  of every Technical Machine". On a yes the screen fades and every TM, TM01–TM92, is topped up to 99 (Renegade's
  `ItemChanges.txt`: "An NPC at the Pokémon League can reset your inventory to have 99 of all TMs"). A TM always fits
  the bag (E10 part 2), so the script adds one of each.
- **The Pokétch at once, with every app** (Jubilife City):
  - The president no longer sends the player after the three clowns' Coupons. In the campaign scene he says "Well,
    this simply cannot do! Here, a Pokétch for you!", and all 25 apps come installed (Renegade's lines).
  - Looker's hints say "I believe a Pokétch is now free?" (Renegade).
  - The clowns still quiz and give Coupons, as in Renegade. Their old path to the Pokétch also registers every app.
- **Renegade's healers:**
  - A nurse on Route 210 North in the fog (545, 532).
  - Two nurses in Victory Road 1F (5, 36) and (34, 23).
  - A nurse on Route 221 (249, 912). Renegade's "Enjoy yourself at Pal Park!" becomes "the Regional Forms Park".
  - The Route 225 house's worker heals on every talk; vanilla's Fresh Water still comes on the first talk.
  - Stark Mountain: the party is healed between Mars's and Jupiter's battles.

Checked and left alone:
- Renegade's Gardenia "show me a Snover" lines are dead: no object in Renegade uses that script.
- The other audit lines are already ported with Sovereign's wording, or are flavour.

**Open question for the owner:** in Renegade, Victory Road's back area and Route 224 come before the Elite Four.
Renegade removes vanilla's post-game guard in Victory Road 1F, and adds a guard by the League exit ("You're not quite
ready yet. Have you been to Route 224?"). That guard steps aside once the counterpart by Route 224's tablet is beaten
(Lv. 69–70, E10 part 30). Sovereign keeps vanilla's post-game guard, so Route 224 is post-game only.

Verified in test builds:
- **TM collector:** with No, the bag is unchanged. With Yes, his lines play, then the bag holds TM01–TM92 at ×99 each
  (read from RAM), and "Alright. Come back again!".
- **Pokétch:** stepping onto the campaign trigger plays the president's new lines, then "A received a Pokétch!" and
  "That Pokétch has every app installed!". The Pokétch save data shows 25 apps. Switching apps showed the Alarm Clock,
  Stopwatch and Matchup Checker.
- **Healers:** each of the five gave its lines, the heal fade and its closing line. The Route 225 house also gave the
  Fresh Water and its tip-top line.
- Not tested: the Stark Mountain heal (one `HealParty` after the Mars win).

## E10 (part 38) — Renegade's Arceus: the Foreign Building elder's Azure Flute, no distribution

Vanilla's Arceus needs the Azure Flute distribution. Renegade has an elder give the flute in the game instead:
- **Hearthome City's Foreign Building:** a new elder (Renegade's lines) stands at (8, 8), facing the door. The Lady who
  stood there moves to (6, 8).
  - Before the Hall of Fame she greets the player and speaks of the Original One.
  - After it she asks the Champion to beat the sixteen Type Masters (E10 part 20) for their Plates.
  - With all sixteen Plates in the bag she gives the Azure Flute and sends the player to Spear Pillar.
  - Renegade also asks for a Pokédex worthy of the National diploma. That task is dropped (owner, decision 44),
    because Sovereign's National Dex is over 1,000 species.
  - The flute is a key item, so having it marks the event done; no new flag.
- **The Azure Flute's use** (`src/item_use_functions.c` and its common script), **the Hall of Origin and the three
  Spear Pillar maps:** the Arceus distribution checks are gone. The other vanilla gates stay: the flute works only
  post-game, with the National Dex, on Spear Pillar's top step, until Arceus is caught. Arceus stays Lv. 80, as in
  both.

Verified in test builds (post-game, Plates or the flute added to the bag):
- With 15 Plates, the elder gives the Champion and Type Master lines, and the same again on the next talk.
- With 16 Plates: her exclamation, "All sixteen Plates…", "obtained the Azure Flute!" and the Spear Pillar hint.
  The next talk gives the hint only.
- At the Hall of Origin, Arceus stands at the top. Walking up starts its scene ("Dodogyuuun!"), and it battles at
  Lv. 80. A Master Ball catches it, and it's gone afterwards.
- With the National Dex and the flute registered to Y, at Spear Pillar's top step: "A's Azure Flute is making a
  sound!", the Yes/No question, "A blew the Azure Flute.", then the white fade into the Hall of Origin and "A glowing
  stairway appeared!"

Docs: `docs/StaticEncounters.xlsx` gives Darkrai's and Arceus's new conditions (and Darkrai's Lv. 68). Its
generator, `tools/reference/make_static_encounters.py`, had fallen behind the workbook's E10 part 27–29 edits; it now
writes the same workbook again.

## E10 (part 37) — Renegade's Shaymin: Oak's Letter from Oak, no distribution

Vanilla's Shaymin needs the Oak's Letter distribution. Renegade has Oak give it in the game instead:
- **Eterna City's south house:** once the player has beaten the counterpart by Route 224's tablet (E10 part 30), Oak
  greets them ("What fantastic timing"), gives Oak's Letter and asks to meet on Route 224 (Renegade's lines).
  - This comes before his usual talk, once. Having the letter (a key item) marks it done; no new flag.
  - The letter sets `VAR_SHAYMIN_EVENT_STATE` to 1, as the distribution did in vanilla. Route 224 then plays its
    vanilla scenes: Marley meets the player, then Oak at the tablet asks for a name, the flowers bloom, Shaymin
    appears and flees, and the Seabreak Path opens.
- **Route 224 and Flower Paradise:** the Shaymin distribution checks are gone. The other vanilla gates stay
  (post-game, the National Dex, the letter). Shaymin stays Lv. 30, as in both.

Verified in a test build (post-game, the Route 224 counterpart's trainer flag set, Oak shown in Eterna City):
- Eterna City: Oak's new lines, "obtained the Oak's Letter!" into the Key Items pocket, and "Once again, that's Route
  224." The next talk goes on to his usual Up-Grade lines.
- Route 224: stepping onto Marley's trigger plays her scene. Oak stands at the tablet, and his tablet talk and the
  naming screen run.
  - Then the flowers bloom, Shaymin appears and flees, and Oak's and Marley's closing lines play.
- Flower Paradise: Shaymin ("Kyuu uuhn.") battles at Lv. 30, and a Master Ball catches it. On re-entry it's gone.
- Not tested: Shaymin knocked out instead of caught.

## E10 (part 36) — Renegade's Darkrai: the Member Card from Route 217, no distribution

Vanilla's Darkrai needs the Member Card distribution. Renegade gives the card in the game instead:
- **Route 217's north-east house:** the woman still gives the Spell Tag on the first talk, but she no longer vanishes.
  - After that she dozes, muttering about Darkrai's nightmares.
  - If the player has the Lunar Wing (from catching Cresselia), it glows and wakes her. In a rage she hands over the
    Member Card and sends the player to Canalave. Then she praises Darkrai's nightmares (Renegade's lines).
  - Having the card marks this done; no new flag. Her old hide flag is cleared on entry, for saves where she vanished.
  - As in Renegade she sits still, facing east.
- **Canalave City, the Harbor Inn, Newmoon Island Forest:** the distribution checks are gone. The rest of vanilla's
  chain stays:
  - post-game, the National Dex, the Member Card, and the sailor's son woken with the Lunar Wing;
  - then the inn's dream, Newmoon Island, and Darkrai in the forest.
- **Darkrai is Lv. 68** (Renegade's; vanilla 50). Vanilla already lets the dream repeat until it's caught.

Verified in a test build (post-game, the boy woken, the Lunar Wing and Master Balls in the bag):
- Route 217: "...A person...?" and the Spell Tag, then the muttering, "A's Lunar Wing began to glow...", "The muttering
  woman woke up!", her rage, the Member Card into the Key Items pocket, and her after-line.
- Canalave: the Harbor Inn door opens. The dream scene plays and ends on Newmoon Island.
- Newmoon Island Forest: Darkrai stands at (16, 13). The battle is Lv. 68, and a Master Ball catches it.
  - The voice's lines play, then the player wakes in the inn's bed.
  - Back in the forest, Darkrai is gone.
- Bug found and fixed while testing: the patch script's "already applied" check skipped the forest's change, because
  the new text was a prefix of the old. Darkrai stayed hidden until it was fixed by hand.
- Not tested: a defeated (not caught) Darkrai and the repeated dream.

## E10 (part 35) — Renegade's remaining gifts: Lapras, Mom's Eevee, the briefcase starters, Roark's stone

An audit of Renegade's script texts against ours (`SpecialEvents.txt` and the gift list in
`docs/GiftPokemon_Sovereign.md`) found four gifts still missing:
- **Lapras, Pastoria City's north house:** a socialite (new, at (5, 5); the scientist moves to (3, 4) by the Psyduck, as
  in Renegade) tells of her Lapras and its days at sea, then entrusts it (Lv. 35, holding a NeverMeltIce).
  - Saying no to the story skips to the request. A second talk in the same visit skips the story too.
  - A full party is turned away; she asks again next time. `FLAG_SOVEREIGN_RECEIVED_LAPRAS` (was `FLAG_UNUSED_0x0975`).
- **Mom's Eevee, Twinleaf Town:** a Poké Ball by the window of the player's house (4, 3).
  - Before Mom gives the Journal it's "an EEVEE! Mom is taking care of it."
  - When Mom gives the Journal and sees the player off, she now adds Renegade's lines asking the player to take it.
    Then the ball gives a Lv. 5 Eevee (cry and picture first, as in Renegade).
  - `FLAG_SOVEREIGN_RECEIVED_EEVEE` (was `FLAG_UNUSED_0x0976`) hides the ball.
- **The other two Sinnoh starters, Rowan's lab:** his briefcase (18, 4) holds the two starters the player didn't pick.
  - Rowan walks over and offers them (Lv. 5, in Turtwig, Chimchar, Piplup order).
  - The party needs room for both: Renegade gives them one at a time, which would need another save flag.
  - Between the Distortion World and Sunyshore (lab states 2 and 3) Rowan stands by the door with the counterpart,
    so there he speaks from where he is instead of walking over.
  - Before the player has a starter, or while Rowan is away, or once taken, the briefcase only holds papers.
  - `FLAG_SOVEREIGN_TOOK_BRIEFCASE_STARTERS` (was `FLAG_UNUSED_0x0990`).
- **Roark's stone, Oreburgh Mine B2F:** after his Rock Smash demo, the boulder he smashed held an evolution stone.
  - He asks which one it is (Water Stone, Thunderstone, Fire, Sun, Moon, Leaf, Ice). The player gets the stone they
    name, and "Don't know" gets a random one. Then his usual line about fallen boulders, and he leaves.
- Flags: one save flag is left unused (`FLAG_UNUSED_0x0991`).

Verified in a test build (a party of three, Mom's Journal given, lab state 1, and a second build with lab state 3):
- Rowan's lab, state 1: the briefcase lines play, Rowan walks over and asks, and Chimchar and Piplup are received
  (nickname prompts declined). Checking it again shows only the papers.
- Rowan's lab, state 3: the same with Rowan staying by the door.
- Pastoria: the socialite stands at (5, 5). The story, the request, "accepted the LAPRAS!" and the nickname prompt
  play, then her after-line on the next talk.
- Twinleaf: the Eevee picture and cry, then the question. With room, "obtained an EEVEE!" and the nickname prompt
  play. With a full party, "You have no room for Pokémon!" plays instead and the ball stays.
- Oreburgh Mine B2F: Roark's Rock Smash, the stone lines and the question play, with the eight-entry menu at the top
  right.
  - Picking the Water Stone gives it ("Yes, that's correct!", "Obtained the Water Stone!").
  - "Don't know" gives a random one ("You don't know? Then I'll tell you. It's a Moon Stone.").
  - Then his boulder lines and his exit.
- Not tested: Eevee before the Journal (Mom's "taking care of it" line), the briefcase and Lapras with a full party,
  and declining Lapras's story.
- Bugs found and fixed while testing:
  - The naming subroutines closed the message and their callers closed it again. Two CloseMessage in a row hang the
    game. `tools/test/check_double_close.py` misses this, because it resets at every Call. Each message now closes
    once, before the call.
  - The stone menu was off screen (`SetMenuYOriginSide` instead of `SetMenuXOriginToRight`).


## E10 (part 34) — Renegade's last added trainers: Cheryl's test, the Eterna door grunt, Cyrus's Dialga and Palkia

An audit of Renegade's added trainers (IDs 928 and up) against Sovereign's found three still missing:
- **Cheryl, Eterna Forest:** before asking to go through the forest together, she tests the player in a battle
  (Renegade's trainer 1064: Drifloon, Makuhita, Wailmer and Chansey, Lv. 19–20).
  - A win heals the party, then she asks ("Ah, marvelous! … may I go through with you?"). A loss blacks out, and she
    battles again next time.
- **The Eterna City door grunt:** Sovereign's Totem-trial gate grunt now does what Renegade's does once both trials are
  done.
  - Without the Forest Badge, he turns the player away with Renegade's lines.
  - With it, he battles (Renegade's trainer 939, Lv. 24), then leaves to warn Jupiter.
  - His trainer flag keeps him gone. Before the trials he still talks about the Totems.
- **Cyrus, Distortion World:** before his own team, he sends out Dialga and Palkia together in a double battle
  (Renegade's trainer 972, Lv. 70), then heals the player and battles as before.
  - His opening line now boasts of their power, as in Renegade.
  - Renegade turns away a player with one Pokémon ("Bring another Pokémon"). The Distortion World has no way out, so a
    player without two able Pokémon skips the double battle instead.
- **Left out on purpose:**
  - Renegade's three random alternate teams for each Elite Four member and Cynthia (981–995):
    `docs/EliteFourFormat.md` picks one fixed team per format.
  - Dray, Renegade's author (1053): Sovereign's developer battle is its own (`docs/DeveloperBattle.md`).
  - Egadd, Telkin and Palmer (961, 962, 971): no Renegade script or map uses them.
- `docs/TrainerTeamLog.md`: three dummy rows are replaced.
  - The new boss-class rows (this Cyrus and part 31's Battleground commanders) now say no Sovereign team is drafted for
    them yet, instead of the T1 note.

Verified in a test build (a Lv. 100 party, both Eterna trials and the Forest Badge set, and the Distortion World
progress at Cynthia and Cyrus's talk):
- Eterna Forest: stepping onto Cheryl's trigger plays her new "test your strength" lines, then her battle.
  - After the win: "Ah, marvelous! … may I go through with you?", "decided to go with Cheryl!" and the heal line.
- Eterna City: the door grunt's Forest Badge lines play, then his battle and "I must inform Commander Jupiter…".
  - He fades out and is gone on re-entering.
- Distortion World B7F: Cyrus's new opening line ("Not with DIALGA and PALKIA's power!") plays.
  - The Lv. 70 Dialga and Palkia double battle was won, then his own team's battle started and was won.
  - Then the vanilla scene went on (he leaves; Cynthia talks).
  - The line between the two battles wasn't captured on screen: the harness overwrote those frames.
- Not tested: the losses, the grunt without the badge (the Totem text still plays before the trials), and a player
  with one able Pokémon at Cyrus.


## E10 (part 33) — Darach and Lady Caitlin in the Regional Forms Park lobby

Renegade's Darach event, moved from the Catching Show to the Regional Forms Park:
- **Darach and Caitlin** stand at the lobby window, at (5, 4) and (6, 4). Renegade used (3, 4) and (4, 4), but our
  Youngster stands at (3, 4).
  - Talking to either one first walks the player below Darach.
  - Darach's greeting now mentions the park's Pokémon instead of the Catching Show. The rest are Renegade's lines.
  - He introduces Lady Caitlin, owner of the Battle Castle, and asks for a battle in her place: Renegade's trainer 969,
    Castle Valet Darach, Lv. 48.
  - "No" ends the talk. The next talk on the same visit skips the introduction (`VAR_MAP_LOCAL_0x05`).
- **The battle:** win or lose, the scene goes on. A loss heals the party instead of blacking out, as in Renegade.
  - Caitlin's psychic powers flare ("Fight. Fight. Fight..."). Darach calms her with Tea, then gives the player some.
  - They leave for the Battle Frontier. His trainer flag hides them for good, so no new save flag is needed.
- **The Tea:** a key item, Renegade's. Like Renegade, it takes the place of the unused S.S. Ticket (`ITEM_TEA`, #456),
  with Renegade's name, description and icon.
- `docs/TrainerTeamLog.md`: `dummy_254` becomes `sovereign_darach_pal_park` (trainer slot reuse).

Verified in a test build (the test party; Oak's lobby scene marked done; Darach's team raised to Lv. 100 in that build
only, so the loss path runs):
- Talking to Darach from the west walks the player below him. His greeting, Caitlin's line and the Battle Castle
  introduction play, then "no" gets his "disappointment" line.
- Talking again skips the introduction. "Yes" starts the battle against Castle Valet Darach.
- The loss: no blackout. He gives his "valiant effort" line, Caitlin's "Fight. Fight..." fit and the Tea scene play,
  and "Obtained the Tea!" puts it in the Key Items pocket. They say goodbye and fade out, and they're gone on
  re-entering.
- Not tested: the win line (one message, then the same scene), and talking to Caitlin first.


## E10 (part 32) — the Pokémon Center Interviewers: every region's starters

Renegade's Jubilife TV quiz, and Sovereign's five new ones (`docs/GiftPokemon_Sovereign.md`):
- **Where:** a reporter stands at (3, 4) in a Pokémon Center, with a cameraman at (2, 4).
  - Jubilife: Kanto, Lv. 5 (Renegade's Kayla, 1022).
  - Oreburgh: Hoenn, Lv. 10 (Renegade's Helen, 934).
  - Floaroma: Johto, Lv. 15 (Renegade's Jenny, 1021).
  - Eterna, after the Forest Badge: Unova, Lv. 20.
  - Hearthome, after the Relic Badge: Kalos, Lv. 25.
  - Veilstone, after the Cobble Badge: Alola, Lv. 30.
  - Pastoria, after the Fen Badge: Galar, Lv. 35.
  - Canalave, after the Mine Badge: Paldea, Lv. 40.
- **The quiz:** yes/no questions, then "Can you beat me in a battle?"
  - The first three keep Renegade's questions, answers, jingles and lines. Johto's reporter cuts to the battle after
    three questions.
  - The new five ask four questions about their region.
  - A wrong answer ends the quiz, and the player can try again any time. Before the badge, the new five say to come back
    with it.
- **The battle** is against the prize: the region's three starters at the gift level. A loss blacks out, and the win
  sets the reporter's trainer flag.
- **The prize:** talking again gives the three starters, holding a Miracle Seed, Charcoal and Mystic Water, each with
  a nickname prompt. Then the reporter and cameraman leave for good.
  - The party needs room for all three. Renegade hands them over one at a time, but that needs two more save flags
    per reporter than Sovereign has left.
- **Save data:**
  - Eight new flags, `FLAG_SOVEREIGN_INTERVIEWER_{KANTO,HOENN,JOHTO,UNOVA,KALOS,ALOLA,GALAR,PALDEA}_DONE`, from the
    `FLAG_UNUSED_*` pool.
  - `FLAG_UNUSED_0x04E4` wasn't actually free: the new-game script sets it, so it stays as it is.
  - Eight trainers, `TRAINER_SOVEREIGN_INTERVIEWER_*`, reuse unused dummy slots (`dummy_007`–`009`, `238`, `239`,
    `251`–`253`).
- `docs/TrainerTeamLog.md` replaces the eight dummy rows with the reporters.

Verified in a test build (a party of three Lv. 100 Pokémon; only the Mine Badge set):
- Canalave (Paldea): all five questions answered, Marisol's three Lv. 40 starters beaten, and the win lines played.
  - Talking again gave Sprigatito, Fuecoco and Quaxly, each with the nickname prompt.
  - The pair faded out, and they're still gone on re-entering.
- Jubilife (Kanto):
  - A wrong first answer got the buzzer and Renegade's "try again" line.
  - Answered right, Kayla battled and won the prize talk.
  - With six Pokémon now in the party, the prize talk gave the "no room for these three" line.
- Oreburgh (Hoenn): the "Yes Town?" reply played, then Helen's battle and win lines.
- Floaroma (Johto): three questions, then Jenny cut to the battle, then her win lines.
- Eterna (no Forest Badge) and Pastoria (no Fen Badge): both said to come back with the badge.
- Not tested: a battle loss, the nickname screen, and Hearthome's and Veilstone's quizzes (they use the same script as
  Canalave's).


## E10 (part 31) — the Battleground as in Renegade: fixed rematches, a nurse and the Battle Marathon

Renegade's Battleground replaces vanilla's four daily random trainers and their multi battles:
- **Fixed trainers.** Each one asks for a single battle any time, from Renegade's lines; "no" gets their decline line.
  - The eight Gym Leaders use their rematch teams.
  - Cheryl, Mira, Riley, Marley and Buck use their Battleground teams.
  - Barry uses his Survival Area team, by the player's starter.
  - They stand on Renegade's spots and don't walk around.
  - A loss blacks out.
- **The counterpart** (Dawn for a boy, Lucas for a girl) waits at (11, 10) once beaten on Route 224. They use Renegade's
  new teams (1054–1059, Lv. 83–84, by the player's starter).
- **A nurse** at (5, 3) heals the party.
- **The Battle Marathon**, run by the Gym Guide at (6, 3): 24 battles in a row, with a heal after every third.
  - The order is Roark, Cheryl, Gardenia, Mars, Fantina, Mira, Maylene, Jupiter, Wake, Riley, Byron, Saturn, Candice,
    Marley, Volkner, Buck, the counterpart, Cyrus, Barry, the Elite Four and Cynthia (rematch teams).
  - Mars, Jupiter, Saturn and Cyrus are Renegade's Battleground teams (Lv. 81–84).
  - A loss ends the run without a blackout: back on the field, healed.
  - A full clear gives a Master Ball, every time.
  - As in Renegade, it isn't held back by the post-game Elite Four rematch lock (decision 23). The owner may want that
    changed.
- **The welcome.** The receptionist's greeting is now Renegade's, which thanks the player for Buck's patrol.
  - Buck no longer waits here to talk, so the welcome sets his flags. Heatran's room on Stark Mountain still opens
    (`docs/LegendaryTriggers.md`).
- **Trainer slots.** The trainer-flag range is full: 1040 flags, and all 1040 slots are now in use.
  - Saturn and Cyrus take the unused `TRAINER_DUMMY_005` and `TRAINER_DUMMY_006` slots. Their trainer and flag
    constants are renamed, and their `dummy_*.json` files are gone.
  - Later added trainers must reuse dummy slots the same way. 65 are still unreferenced.
- `docs/TrainerTeamLog.md`: the two dummy rows are replaced, and the 10 new trainers are added (1040 files).

Verified in a test build (a Lv. 100 party; the Hall of Fame and the Route 224 win set; the 31 Battleground and rematch
teams cut to one Lv. 2 Pokémon in that build only):
- The welcome plays on the first visit: Renegade's greeting, ending with the thanks for Buck's patrol.
- The nurse says her lines and heals.
- Roark: "no" gets his decline line; "yes" starts the battle, and his after-battle line plays.
- Dawn (a boy's save with Turtwig) stands at (11, 10), asks for a battle, battles and gives her after-battle line.
- Barry asks, battles (Staraptor leads: his team against a Turtwig player) and gives his after-battle line.
- The marathon runs all 24 battles in order: each opponent's lead matched the trainer list above. It ends with
  "Obtained the Master Ball!" and the offer to try again.
- Not tested: a loss in the marathon or to a fixed trainer, Lucas (a girl's save), and the counterpart hidden before
  the Route 224 win.


## E10 (part 30) — the counterpart on Route 224, Route 224's nurse, and Buck on Route 227

Renegade's last counterpart battle before the Battleground, and Buck's battle:
- **The counterpart** (Dawn for a boy, Lucas for a girl) stands by Route 224's stone tablet (908, 492).
  - The first talk gives Renegade's lines: they're looking into the tablet for Professor Rowan and want to battle again
    since Route 210.
  - After that, they ask whether the player is ready. On a yes they battle with Renegade's teams (975–980, Lv. 69–70,
    by the player's starter); a loss blacks out.
  - After the win they leave and don't come back. Their six trainer flags record the win, so the only new flag is
    `FLAG_SOVEREIGN_ROUTE_224_COUNTERPART_MET` (was `FLAG_UNUSED_0x0122`).
  - They also stay hidden while Professor Oak's Shaymin scene is on: Oak's scene uses their tile.
- **A nurse** at the Victory Road entrance (879, 557) heals the party, as in Renegade.
- **Buck** moved from (758, 275) to (758, 257), below the ledges near Stark Mountain, off the main path.
  - Walking through the strip below him (758, 258–260), or talking to him, he asks whether the player has beaten the
    six Battle Zone leaders. Their trainer flags are the badges (part 22).
  - Not yet: he sends the player on (a step west from the strip).
  - With all six, he battles (Renegade's trainer 1023, Lv. 77–78), heals the party, asks for the Stark Mountain patrol
    and leaves.
  - His hidden flag is now his own trainer flag, so visiting Stark Mountain no longer hides him. The coord event uses
    `VAR_ROUTE_227_BUCK_STATE` as before.
  - Vanilla's patrol request at (758, 277) is gone: his after-battle lines carry it.
- `docs/TrainerTeamLog.md` gains the 17 trainer files added since it was written (parts 26, 28 and 30).

Verified in test builds (a Lv. 100 party; the Hall of Fame set):
- Route 224, as a boy with Turtwig: Dawn stands at the tablet.
  - The first talk plays her lines with the "!" emote. Then "no" gets "Go get ready", and "yes" starts the battle.
  - Her full Lv. 69–70 team was beaten, and the win lines played. She walked off, and she's gone on re-entering.
- The nurse heals and says her lines.
- Route 227 without the six badges:
  - Stepping onto the strip, Buck notices the player, who walks up to him; he says "Nope… look for the Trainers in
    the orange winter outfits!" and the player steps west.
  - Talking to him gives the same lines, without the step.
- Route 227 with the six badges, and Buck's team cut to Lv. 5 in that test build only: he battles, heals, asks for the
  patrol and fades out. On return he's gone and the strip does nothing.
- Not tested: Lucas (a girl's save), a loss to either, and Professor Oak's Shaymin scene hiding the counterpart (it
  needs the distribution's Oak's Letter).


## Fix — the half-price menus after the Hall of Fame (decision 43)

Tested decision 43's half-price scripted sales in game, on post-game and pre-game test saves:
- **Bug, fixed:** after the Hall of Fame, the Veilstone 5F vending machines, the Route 208 Mulch shop and the Game
  Corner coin clerk showed blank menu entries (only "NO THANKS" or "EXIT" was readable). The charges were already right.
  - Cause: `AddMenuEntryImm` stores the text ID in one byte. `menu_entries.json` now has 292 entries, and the nine
    half-price entries (283–291) were cut to their low byte.
  - Those nine now use `AddMenuEntry`, which takes the ID as a halfword.
- New check `tools/test/check_byte_text_ids.py`, run in CI (rom job). It reports any `Message`-type or `AddMenuEntryImm`
  text past index 255 in the field scripts. All the map text archives are under 256 messages today.

Verified in a test build:
- **After the Hall of Fame,** the price lines, menus and money taken all match the half prices:
  - Café Cabin Moomoo Milk: ₽250, and ₽3,000 a dozen.
  - Floaroma Meadow honey: ₽50, and ₽500 for 10.
  - Vending machines: the menu reads ₽100 / ₽150 / ₽175, and a Fresh Water took ₽100.
  - B1F Lava Cookies: ₽100, and ₽1,000 for 10.
  - Route 208 Mulch: the menu reads ₽100 each, and one took ₽100.
  - Day Care rancher: ₽2,500.
  - Game Corner: the menu reads ₽500 / ₽5,000, and 50 coins took ₽500.
  - The B1F Poffin seller's line reads ₽3,200. With no Poffin Case nothing was bought.
- **Selling back** at the Jubilife Mart: a Honey (bought for ₽50) fetched ₽50, and a Moomoo Milk (₽250) fetched ₽250.
- **Before the Hall of Fame,** the old prices and texts are unchanged:
  - Moomoo Milk ₽500, and the vending machines ₽200 / ₽300 / ₽350.
  - Honey ₽100, Lava Cookies ₽200 and Poffins ₽6,400.
  - Mulch ₽200, the rancher ₽5,000, and coins ₽1,000 / ₽10,000.
- Checked in the scripts only: the Soda Pop and Lemonade charges (₽150, ₽175) and the 500-coin charge (₽5,000).


## E10 (part 29) — Lugia and Ho-Oh: Professor Oak's Clear Wings

Renegade's last two portal legendaries, with Oak's QUESTS:
- **Professor Oak** (Eterna City's south house): once he has praised the three birds, he shows his two Clear Wings.
  - With Articuno, Zapdos and Moltres in the party, one turns into the **Silver Wing**, with a hint at a sea
    "surrounded by small islands".
  - Then, with Raikou, Entei and Suicune in the party, the other turns into the **Rainbow Wing**, with a hint at a
    tall place where the departed are remembered.
  - Both are new key items (PokeAPI's data and icons). Holding them is the record, so no new flags.
  - Until the party is right, Oak gives the hint and then rates the Pokédex, as before.
- **Lugia:** Route 220, the sandbar island at the bottom of the route (190, 921), Surf. **Ho-Oh:** Lost Tower 5F,
  below the old women's graves (7, 12), clear of Totem Marowak (3, 4).
  - Both are Lv. 70, after the Hall of Fame, while the player carries their wing, until caught.
  - Renegade opens a portal on each spot; Sovereign shows the Pokémon.
- Route 220 had no scripts (`scripts_empty`); it now has its own script archive.
- Lugia's and Ho-Oh's overworld sprites are placeholders, large (64×64) by the owner's size classes.

Verified in a test build (a party of the three birds and the three beasts, Lv. 100; the Hall of Fame and Oak's praise
set):
- Neither legendary shows before the wings.
- Oak's Silver Wing scene, then the Rainbow Wing scene, each with its hint.
- Lugia and Ho-Oh then stand on their tiles, battle at Lv. 70 and are caught, and they're gone afterwards.
- Harness note: in Oak's house a text box sometimes ignored a few B presses before advancing (also seen in part 27).
  It always recovered; worth a look on hardware.

## E10 (part 28) — Celebi: the GS Ball and the time portals in Eterna Forest

Renegade's Celebi event:
- **The GS Ball** (a new key item) waits in the small shrine in the middle of Celestic Town, an offering to the
  forest's protector. Once it's taken, an old man walks over and suggests taking it to a forest.
- **Eterna Forest:** walking in from the Eterna City side with it (x = 78), the GS Ball shakes. Celebi peeks out at
  the player and vanishes, and eight time portals open around the forest.
- **The portals:** each holds the memory of a battle with one of Johto's Gym Leaders: Falkner, Bugsy, Whitney, Morty,
  Chuck, Jasmine, Pryce and Clair. These are Renegade's trainers 1029–1036, one Lv. 45 Pokémon each. A beaten
  memory closes its portal, and Celebi shows itself there for a moment.
- **Celebi:** with all eight beaten, it waits near the middle of the forest (70, 58), Lv. 40, until it's caught.
  Renegade puts it in a ninth portal; Sovereign shows the Pokémon, as for its other legendaries.
- The portals keep Renegade's tiles, all clear of Virizion, Xerneas and the Old Chateau path. The one beside Totem
  Vikavolt moved a tile east, to (24, 68).
- **State:** `VAR_SOVEREIGN_CELEBI_STATE` (1 = GS Ball taken, 2 = portals open) takes over `VAR_DUMMY_0x4083`. Cynthia
  wrote that var once as she left Valor Lakefront, and nothing read it. The portals hide themselves off their
  trainers' defeated flags, so no new flags were needed.
- New art, all placeholders: the GS Ball's icon (Platinum's Poké Ball recoloured gold and silver,
  `tools/sprites/make_gs_ball_icon.py`), a time portal overworld sprite (`tools/sprites/make_time_portal_overworld.py`)
  and Celebi's overworld sprite.

Verified in a test build (a Lv. 100 Garchomp, Master Balls):
- The shrine's YES gives the GS Ball (Key Items pocket), and the old man walks over with his lines.
- The forest scene plays: the ball shakes, the portals appear, Celebi peeks and flees.
- All eight memory battles happen (Pidgeot, Scizor, Miltank, Gengar, Poliwrath, Steelix, Mamoswine, Kingdra). Each
  portal closes after its win.
- After the eighth, "A curious presence..." and Celebi appears at (70, 58). The Lv. 40 battle and catch work, and
  Celebi and the portals stay gone on later visits.
- Not checked here: losing to a memory (the usual blackout), and declining a portal.
- Found while testing: a second `CloseMessage` with no message open in between removes the message window twice,
  and the game hangs. The portal script closed it twice after a win; fixed. `tools/test/check_double_close.py`
  scans every script for this and finds no other Sovereign case.

## E10 (part 27) — Articuno, Zapdos and Moltres where Renegade's portals stood (decision 33)

The legendary birds no longer roam. Like Raikou, Entei and Suicune (part 12), each now stands where Renegade put its
portal, from the Distortion World on (Cyrus beaten there), at Renegade's Lv. 60. A win or a run makes it vanish until
the next visit; it stays away once caught.
- **Articuno:** Mt. Coronet's top snowfield (33, 20). Renegade's portal was at (35, 20), right above Cosmog's tile
  (35, 21), so Articuno stands two tiles west of that, on its own hidden flag.
- **Zapdos:** Valley Windworks, the small island north of the building (241, 644), beside the TM24 ball (Surf).
  Renegade moved TM24 and used the ball's tile. Zekrom stands on the west island (236, 650), so the two don't clash.
  Decision 34 still moves Zekrom to Route 215; that's a separate change.
- **Moltres:** Victory Road 2F, the small room past the Strength boulders (20, 3). Renegade removed the boulders and
  used (18, 3). Sovereign keeps the boulders and the TM79 ball, so Moltres stands clear of the tiles the puzzle
  needs. Platinum gave this map no scripts; it now has its own script archive, like Victory Road B1F.
- **Professor Oak** in Eterna City's south house still gives the Up-Grade, but now hints at the three places
  (Renegade's "somewhere very cold, somewhere that generates electricity, and somewhere Trainers gather") instead of
  releasing roamers. His praise for catching all three reads the Pokédex now, and it waits until after his first
  talk, since the birds can now be caught before it.
- New overworld sprites for the three birds: small placeholders from PokeAPI, listed as unsorted in
  `OverworldSpriteSizes.md`.

Verified in a test build (the Distortion World flag set, a Lv. 100 Garchomp, Master Balls):
- Each bird stands on its tile and battles at Lv. 60.
- Moltres and Zapdos come back on the next visit after a run.
- Each is gone after the catch and on later visits.
- On Mt. Coronet, catching Articuno leaves Cosmog standing: the map's removal now checks which species was battled.
- Oak's first talk gives the Up-Grade and the hint even with all three already caught. The next talk gives his
  praise and the Pokédex rating. With two caught, he repeats the "extremely rare" lines with the hint.
- Not checked here: the birds staying hidden before the Distortion World. That's the same gate as Raikou's
  (part 12).

## E10 (part 26) — Renegade's Snowpoint Temple story and HM08 (decision 29)

- **Snowpoint City shakes** as the player walks in: Regigigas is stirring under the temple. The townspeople talk
  about the tremors.
- **The Gym guide** stands at the Gym door: Candice has gone to the temple to deal with it.
- **The temple:** two Ace Trainers, Aran and Nephenee (Renegade's trainers 936 and 937, Lv. 54), now guard it instead
  of Platinum's champion-only guard. They let in only the strong, after a double battle (two Pokémon needed).
- **On B5F**, Candice and Maylene stand before Regigigas.
  - With the player's help they put it back to sleep.
  - Candice gives **HM08 (Rock Climb)** and heads back to her Gym, and the tremors stop.
  - HM08 had no other source since part 3 replaced its Route 217 item ball, so holding it is the record of the scene.
    An HM can't leave the bag.
- **Regigigas itself** is still the Lv. 70 static on B5F. It now also waits for the Hall of Fame (Renegade: "become
  the Champion"), with Regirock, Regice and Registeel in the party as before.
- **The Route 217 hiker** who lost HM08 lets the player rest (a full heal), as in Renegade. The Icicle Plate he gave
  in Platinum comes from the Ice-type Master.

Also in this part:
- **Decision 30:** the Koraidon and Miraidon gates were already right (all ten past / all ten future Paradox Pokémon,
  independent, with the Paldea Chronicle open). Once a museum dealer has given all ten, they now pass on the rumour:
  "a legendary PAST (FUTURE) Paradox Pokémon can be found at Sendoff Spring".
- **Decision 31:** after the first Champion win, the PC in the player's room holds the **Infinite Repel**, once.

Verified in a test build:
- The tremor on entering Snowpoint, and the Gym guide at the Gym door.
- The guards' double battle starts with both of Renegade's teams. My harness couldn't finish the battle, so the
  lines after it weren't reached.
- The whole B5F scene: HM08 received, Candice and Maylene gone, and the statue's "gather the three Pokémon" line
  before the Champion.
- The Gym guide gone afterwards, and the Route 217 hiker's heal.
- The dealer lines and the PC weren't run in the emulator.

The release build passes.

## E10 (part 25) — Manaphy, from Backlot's Egg

- After the siege of the Pokémon Mansion (part 24), Mr. Backlot points the player to his maid, who now stands beside
  him in his office with the deep blue Egg. Talking to her makes it hatch, and the frightened **Manaphy** attacks: a
  Lv. 40 battle (Renegade gives the Egg instead, but Mythicals are battled and caught, never given: decision 26).
- If it isn't caught, it vanishes until the next visit, then waits in the office (18, 7) until it is. The maid's
  lines follow along: it "still won't calm down", then "take good care of it".
- A placeholder overworld sprite for Manaphy (`legendary_manaphy.png`, from `make_legendary_overworld.py`).
- `VAR_SOVEREIGN_MANSION_SIEGE_STATE` carries it: 7 hatched, 8 caught. Phione comes from breeding Manaphy.

Verified in a test build: the hatch scene and battle, the vanished message, the maid's later line, and Manaphy back in
the office on the next visit, battled again when talked to. The catch itself goes through the common legendary script
used by every static. The release build passes.

## E10 (part 24) — Renegade's Pokémon Mansion siege

After Barry's battle in the Route 209 gate (Hearthome side), a maid from the Pokémon Mansion runs in for help: Team
Galactic has taken over the Mansion. Barry heads off to help, and the siege lasts until Saturn is beaten
(`VAR_SOVEREIGN_MANSION_SIEGE_STATE`, 1 to 5 during the siege, 6 after). All of it is Renegade's, with its trainers
947 to 960.

- **Route 212 North.** Three grunts stand on the route and battle when talked to. The Mansion's visitors (the four
  trainers by the door, the Youngster and the Collector) stay away meanwhile.
- **The Mansion's door.** Two grunts guard it and battle together. Like every Team Galactic encounter, they wait
  on the Totem trial before them, Mimikyu's at the Old Chateau, and send the player back until then. Then Barry runs
  up and goes in ahead.
- **Inside.** The maids are out of sight. Grunts guard the three rooms, the office door and the Trophy Garden door.
  - At the west end, a grunt challenges the player to beat three grunts in a row in exactly 6 turns. He breaks his
    promise, but a Clefairy slips out behind him.
  - Each room grunt beaten frees another of Mr. Backlot's Clefairy, or his Happiny. They gather around the grunt at
    the garden door.
  - With all four Clefairy back, the Happiny's Metronome turns into Teleport, and the grunt is gone. The Happiny
    gives the player a **Lucky Egg**.
  - Saturn then comes out of the garden with Mr. Backlot for a tag battle, with Barry as the partner (his Route 209
    team). After it, Barry leaves for Solaceon Town and Backlot thanks the player.
- **The office.** Mr. Backlot and his guest are with Saturn during the siege. Backlot's Manaphy Egg, which Renegade
  gives here, isn't given: Mythicals are battled and caught, never given (decision 26). Backlot only mentions the Egg
  for now, and Manaphy comes in a later part.
- Barry's line about heading to Solaceon moves from the gate to after the Mansion, as in Renegade.

Verified in a test build, from Barry's gate battle to Backlot's thanks:
- The gate scene, the door guards' double battle, and Barry's arrival on Route 212 North.
- The 6-turn challenge in both outcomes: the turn count after each battle, "That isn't 6" on a miss (5 turns), and
  the Clefairy on a hit.
- The four room grunts, each freeing a Clefairy or the Happiny; the Metronome teleport and the Lucky Egg.
- Saturn and Backlot's tag battle with Barry, and the ending.
- Leaving and coming back: the maids are back and the grunts gone.
- Not reached in the emulator: the three talk-to grunts on the route, and the office during the siege.
- The test found that `StartTrainerBattle` doesn't set a trainer's defeated flag. The scripts now set it after each
  win, so a beaten grunt stays beaten. The earlier parts were checked: they all set it.

The release build passes.

## E10 (part 23) — Renegade's Marley and Dahlia battles

- **Marley** (Victory Road) asks for a battle the first time she's met (Renegade's trainer 974, Lv. 85), then asks to
  go along as before. A loss blacks out, and she asks again next time.
- **Dahlia**, the Arcade Star, relaxes on Sunyshore City's north platform (882, 747). With all eight badges she
  battles (Renegade's trainer 973), then leaves for the Frontier. Her trainer flag also hides her afterwards. Before
  the eighth badge she wishes the player luck.
- **Left out on purpose:** Renegade's Dray, the hack's creator in person ("I created this enhancement hack"), since
  the character is the Renegade author's self-insert. Darach's Pal Park battle, Buck's Route 227 battle and the
  reporters' battles are still to port.

Verified in a test build:
- Marley's battle started from her trigger.
- Dahlia stands on the platform when Sunyshore is entered through a door. A test warp straight into Sunyshore doesn't
  load her (a test-warp quirk on that map).

The release build passes.

## E10 (part 22) — Renegade's Battle Zone leaders

- **Six postgame "leaders"** from Renegade stand on the Battle Zone routes. Each battles a Lv. 76-ish team of one type
  and gives an unofficial badge: a keepsake line with the badge fanfare, but no item and no effect.
  - Heather, Flying, the Wind Badge: Route 225.
  - Wyver, the Fang Badge: Route 226. Renegade's spot is Tapu Fini's (the Chronicles), so Wyver stands one tile down
    and right.
  - Slythe, the Acid Badge: Route 227.
  - Shade, the Shadow Badge: Route 228.
  - Gene, the General Badge: Route 229.
  - Luna, Fairy, the Moon Badge: Route 230.
- **Trainers:** `TRAINER_SOVEREIGN_BATTLE_ZONE_<NAME>`, from Renegade's trainers 938 and 1024–1028. Each one's trainer
  flag records the win, and they don't battle again.
- **Not ported yet:** Renegade's Buck battle on Route 227, which needs all six badges and ties into his Stark Mountain
  story.

Verified in a test build: Heather (Pelipper) and Luna (Wigglytuff) ran their dialogue and started their Lv. 76 battles.
The release build passes.

## E10 (part 21) — Renegade's counterpart battles (Routes 202, 207, 210)

- **Route 202:** Dawn or Lucas no longer demonstrates catching. They heal the player's Pokémon and battle with the
  starter that's weak to the player's (Lv. 9), then give the 30 Poké Balls, with Renegade's lines.
- **Route 207:** the counterpart battles first, a Lv. 29–30 team that depends on the player's starter. They then give
  the Vs. Seeker as a training gift. The Dowsing Machine app still follows, as in Platinum (Renegade drops it here).
- **Route 210 (north):** a new scene. The first time the player crosses the column past the fog, the counterpart walks
  over, heals the party and battles (Lv. 44 team), then leaves. It's tracked in a new var,
  `VAR_SOVEREIGN_ROUTE_210_COUNTERPART_STATE` (an unused one).
- **Trainers:** 18 new ones (`TRAINER_SOVEREIGN_<DAWN|LUCAS>_ROUTE_<202|207|210>_<the player's starter>`), from
  Renegade's trainers 928–945 and 963–968.
- **A loss** blacks out, and the scene runs again on the next pass.

Verified in a test build, entering each scene from its trigger:
- Route 202 ran through the heal, the battle against Dawn's Piplup, "Wasn't that fun?" and the 30 Poké Balls.
- Routes 207 and 210 ran their dialogue and started their battles (Piloswine and Clefable, Lv. 29; Alakazam,
  Lv. 44). The test party lost both, so their post-battle lines weren't seen.

The release build passes.

## E10 (part 20) — Renegade's Type Masters

- **15 more Type Masters**, from Renegade, join Iron Island's Steel-type Master. Each battles one Pokémon of their
  type, alone in the player's party, with a Lv. 85 Pokémon of that type. A win gives their Plate, and they don't
  battle again.
  - Bug: Route 202. Rock: Route 207. Ghost: Lost Tower 1F (the Scientist there becomes the Master, as in Renegade).
  - Fighting: Veilstone City's south-west house. Poison: the Pastoria observatory gate, 2F. Ground: Oreburgh Gate 1F.
  - Grass: Floaroma Meadow. Psychic: Solaceon Ruins. Electric: Vista Lighthouse. Ice: Snowpoint City.
  - Water: Route 219. Dragon: the Celestic Town cave. Fire: Route 226. Dark: Sendoff Spring. Flying: the Pokémon
    League's grounds.
- **Their trainers** (`TRAINER_SOVEREIGN_<TYPE>_MASTER`) are written from Renegade's own trainers 1037–1052 by the
  trainer import tool's new `Renegade.new_trainer()`. Their names, classes, teams and defeat lines come from Renegade.
- **No new flags:** each Master's trainer flag records the win.

Verified in a test build with the party check skipped: the Bug (Yanmega), Ghost (Gengar) and Poison (Nidoking)
Masters ran their dialogue and their Lv. 85 battles. The release build passes.

## E10 (part 19) — Renegade's trainer teams

- **Platinum's trainers now have Renegade Platinum's teams**, read from its ROM by a new one-off tool,
  `tools/engine/import_renegade_trainers.py`.
  - 712 of the 927 trainer files changed: class, items, AI flags, single or double battle, and the whole party
    (species and form, level, held items, moves, IV scale, Ball Capsule). Names and messages stay.
  - Roark, for example, now leads with Nosepass and has six Pokémon (Lv. 15–16) with items and full movesets.
- **Renamed slots:** Renegade renamed 14 moves and 10 items in place (Horn Drill is Drill Run, Lunar Dance is
  Moonblast...). Those are matched by name to Sovereign's real moves and items.
- **Survival Area Barry:** Renegade emptied Barry's first Survival Area teams (for fewer than 20 League wins) and
  filled only the second. Both now get the second team (Lv. 84).
- **Left as they were:**
  - Renegade's own trainers come with the events that use them:
    - the three slots it gave to its own characters (trainer 5 is Steven; Ace Trainers Felix and Dana became
      "Butler" and "Diane");
    - its 138 trainers past Platinum's 928.
  - Three unused rival slots it emptied.
- **Boss teams:** the owner's boss teams (`data/trainers_sovereign.yaml`) still go on top of these at milestone T1.

Verified: the release build passes. In a test build, the SELECT+R battle was pointed at Roark, and
`tools/test/check_trainer_party.py` read his six Pokémon from the battle (species, level, moves, items and all six
stats) and matched each one to the JSON (PASS).

## E10 (part 18) — Renegade's Mew event

- **A chain of hungry Pokémon**, as in Renegade. Feeding each one brings Mew for a moment ("Myuu!"); it flies off,
  and the next Pokémon appears:
  - a Shroomish on Route 203 wants an Oran Berry;
  - then a Buneary on Route 209 wants a Sitrus Berry;
  - then a Torchic in Pastoria City wants an Old Gateau.
- **Mew:** then a Pachirisu waits on Route 201. Talking to it reveals Mew, Lv. 40, which stays until it's caught.
- Renegade's ball moves beside the new Pokémon: Route 209's Calcium to (548, 675), Pastoria City's Mystic Water to
  (627, 828).
- Placeholder overworld sprite for Mew. The sprite tool no longer takes "Mew" for "Mewtwo".

Verified in a test build (the bag checks skipped, all four Pokémon shown): each feeding ran its dialogue, Mew's
appearance and the "strange Pokémon disappeared" line; the Pachirisu turned into Mew, whose Lv. 40 battle ran and
which vanished after a knock-out. The release build passes.

## E10 (part 17) — Renegade's Deoxys event

- After the Hall of Fame, touching one of Veilstone City's meteorites without a Deoxys in the party brings a flash and
  Deoxys's cry: "Suddenly, you got the feeling that something was seething with rage..." Deoxys then stands beside
  the meteorites, Lv. 70, until it's caught. Renegade opens a rift there instead; Sovereign shows the Pokémon, as for
  its other legendaries.
- The meteorites still change a Deoxys's form when it's in the party.
- Placeholder overworld sprite for Deoxys.

Verified in a gate-skipped test build: touching a meteorite showed the message and Deoxys; its Lv. 70 battle ran, and
it vanished after a knock-out. The release build passes.

## E10 (part 16) — Renegade's Jirachi event: three wishes

- **Three wishes:** new NPCs from Renegade, each of whom wants something. Granting it brings a white flash, Jirachi's
  cry and "Someone, somewhere, saw that you made somebody's wish come true."
  - The Idol in Eterna City's Pokémon Center wants her Clefairy to learn Dazzling Gleam (it uses one of the 99 TM85s).
  - The Socialite in Solaceon Town's north-east house wants to see a Pokémon whose head is on fire: Ponyta, Rapidash,
    Moltres, Quilava or Infernape. Magmar, Slugma and Magmortar don't count.
  - A boy in Pastoria City (south of the Gym) wants to see a mean-looking fish: Carvanha, Sharpedo or Gyarados.
- **Jirachi:** with all three granted, reading Solaceon Ruins room 7's sign makes Jirachi appear, asleep, at the top of
  the room. The sign then asks for "the Pokémon whose voice sounds the best".
  - With a Jigglypuff in the party it sings Jirachi awake (the Azure Flute tune), and the Lv. 40 battle starts.
  - Jirachi stays until it's caught. Hoopa's battle in the same room no longer hides Jirachi, nor the other way round.
- Placeholder overworld sprite for Jirachi.

Verified in a test build (Garchomp standing in for the species checks, the TM check skipped): each wish ran its
dialogue and the flash; the sign showed Jirachi; the Jigglypuff song woke it and the Lv. 40 battle ran, then "vanished"
after a knock-out. The release build passes.

## E10 (part 15) — Renegade's legendary events: the lake trio, Cresselia, Heatran, Giratina and Mewtwo

- **Uxie, Mesprit and Azelf** are Lv. 60 (vanilla 50) and stay in their caverns until caught: knocked out or run
  from, one is gone for that visit only (vanilla hid it until the next Hall of Fame). Mesprit no longer roams: it's a
  battle in Verity Cavern like the other two, without Rowan's scene after it.
- **Cresselia** no longer roams: it's a Lv. 68 battle in Fullmoon Island's clearing, back each visit until caught.
  The catch leaves the Lunar Wing where it stood, so the Canalave sailor's quest and the Latias/Latios rock still
  follow it.
- **Heatran** is Lv. 68 (vanilla 50) and **Turnback Cave's Giratina** Lv. 70 (vanilla 47), as in Renegade. They still
  come back only after a Hall of Fame.
- **Mewtwo** stands in Oreburgh Gate B1F's north-west pocket (past the Rock Smash rock and the Strength boulder,
  beside the TM01 ball) after the Hall of Fame, Lv. 70, until caught. Placeholder overworld sprite.

Verified in a gate-skipped test build: Mesprit stands in Verity Cavern and starts its Lv. 60 battle, then "disappeared
deep into the cavern" and is gone; Cresselia starts its Lv. 68 battle through the shared legendary script and
vanishes after a knock-out; Mewtwo stands in the pocket and starts its Lv. 70 battle. The release build passes.

## E10 (part 14) — Renegade's legendary events: Kyogre, Groudon and Rayquaza

- After the Hall of Fame, once Steven has given the Red and Blue Orbs (for showing him the Regis), the weather trio
  stand on Renegade's spots at Lv. 70, until caught:
  - Kyogre on the island in Mt. Coronet B1F's lake (that floor now has its own script archive; vanilla used the
    empty one);
  - Groudon left of the steps in Stark Mountain room 1 (Volcanion stays at the far east end);
  - Rayquaza below the waterfall outside the Pokémon League.
  Renegade wants the matching Orb in the Bag; Sovereign has no Jade Orb, so all three check Steven's flag instead.
- Renegade's ball moves on those spots: Mt. Coronet B1F's Light Clay to (12, 12), Stark Mountain room 1's Full Heal to
  (12, 3).
- Volcanion's removal after a battle in Stark Mountain room 1 now checks the species, so a Groudon battle doesn't
  hide it.
- Placeholder overworld sprites for the three.

Verified in a gate-skipped test build: Kyogre stands on its island and starts its Lv. 70 battle; Groudon stands in
Stark Mountain room 1. The release build passes.

## E10 (part 13) — Renegade's legendary events: the Regis, Steven's requests, Latias and Latios

- **The Regis follow Renegade's rule.** After the Distortion World, a Relicanth and a Wailord in the party open the
  Regi chambers (the Route 228, Mt. Coronet and Iron Island doorways); the dots and the statue work as in vanilla,
  without the Champion check, and Regirock, Regice and Registeel are Lv. 60. Vanilla wanted a fateful-encounter
  Regigigas, which normal play can't get, so the three (and Regigigas, Regieleki and Regidrago after them) were out of
  reach. The doorway check (`CheckPartyHasFatefulEncounterRegigigas`) now tests for the pair.
- **Regigigas is Lv. 70** in Snowpoint Temple, as in Renegade (vanilla: Lv. 1).
- **Steven** lives in Oreburgh City's south house (he replaces the mine worker there). He gives a Lv. 10 Beldum, chats
  about Hoenn, battles after the Hall of Fame (Renegade's Lv. 88–89 team, `TRAINER_SOVEREIGN_STEVEN_OREBURGH`; a loss
  doesn't black out), and takes requests: the Magma Stone for the Soul Dew; Latias and Latios to see; Regirock,
  Regice and Registeel to see, for the Red and Blue Orbs. His sprite and battle class are placeholders (Gentleman,
  Ace Trainer) until the owner's art.
- **Latias and Latios:** once Cresselia is caught and the Lunar Wing taken, a mysterious rock stands in Fullmoon
  Island's clearing. Read from below with the Soul Dew, it asks "red or blue": Latias or Latios at Lv. 68, each until
  caught.
- Tapu Lele's removal after a battle on that map now checks the species, so a Latias battle doesn't hide it.

Verified in the test build: Steven's introduction and Beldum offer; the rock's carving, the Soul Dew, the red/blue
menu and a Lv. 68 Latias battle (with the Cresselia and Soul Dew checks skipped for the test). The release build
passes.

## E10 (part 12) — Renegade's legendary events: Raikou, Entei and Suicune

- **Raikou, Entei and Suicune stand on Renegade's spots** once the Distortion World is done (Cyrus beaten there), at
  Lv. 60, until caught: Raikou on Route 208's Rock Climb ledge, Entei at the end of Route 211 East's ledge, Suicune on
  Route 213's ledge. They use the shared static encounter (a win or a run makes them vanish until the next visit).
  Renegade shows a portal and wants a talk with Rowan first; Sovereign shows the Pokémon, like its own legendaries.
- Renegade's item moves on those spots: the extra TM29 ball on Route 211 East is gone (TM29 is Lucian's gift), and the
  Route 213 TM05 ball moved to Renegade's spot, (651, 824).
- Their overworld sprites are placeholders from `tools/sprites/make_legendary_overworld.py`, like the Chronicles'.
- This also opens the past Paradox dealer's Suicune, Entei and Raikou trades in the Oreburgh museum.

Verified in the test build (with the Distortion World gate skipped): Raikou and Entei stand on their ledges and start
their Lv. 60 battles. The release build passes.

## E10 (part 11) — Renegade's remaining small gifts

- **Mom gives the Bicycle** with the Running Shoes. The Cycle Shop manager, rescued from the Galactic building, gives a
  Dawn Stone instead (he still opens Eterna's exits as before).
- **Barry gives an Exp. Share** after the Route 203 battle ("there were two in the parcel").
- **Oreburgh's guide gives an Oval Stone** from the mine before walking you to the Gym.
- **Eterna Forest's Moss Rock** drops a Leaf Stone the first time it's touched.
- **Keira gives a Shiny Stone** in the Contest Hall, then her Accessory.
- **More starting supplies:** 10 Potions from the Route 201 Mart worker, 30 Poké Balls from Dawn or Lucas on Route 202,
  and 10 Dive Balls with the Old Rod (Route 218 gate).

Not ported here: the Lucky Egg comes inside Renegade's Pokémon Mansion Manaphy Egg story, and the Route 203 Shroomish
starts its Mew chain; both wait for Renegade's legendary events (Sovereign never gives Mythicals as gifts).

Verified in the test build: the Moss Rock's Leaf Stone (once, then its usual text) and the Old Rod with 10 Dive Balls.
The release build passes.

## E10 (part 10) — Renegade's helper NPCs: free tutors and relearner, the Move Deleter, the Berry seller, Traynee

From Renegade's `NPCChanges.txt`, with scripts, texts and spots read from its ROM.

- **The Move Relearner** (Pastoria) teaches for free; no Heart Scale.
- **All three move tutors live in the Route 212 house** and teach for free: special effects (the Route 212 tutor),
  support (Snowpoint's) and power (the Survival Area's). The Snowpoint house keeps its trendy-saying man and the
  Super Rod fisherman; the Survival Area house keeps the tutor's Psyduck. The tutor-list signs say the moves are
  taught for free in the Route 212 house.
- **The Move Deleter** moved from Canalave to the house beside Oreburgh's Pokémon Center. A man in his old Canalave
  house says where he went.
- **Route 208's Rare Berry seller** (in the Berry Master's house) sells the Liechi, Ganlon, Salac, Petaya, Apicot,
  Lansat, Starf, Enigma, Micle, Custap, Jaboca and Rowap Berries, and the Nature Mints, at ₽10,000 each (half price
  after the Hall of Fame, decision 24).
- **Solaceon's Day Care has Renegade's training NPCs:**
  - Traynee gives the six Power items on the first visit, then battles for EXP or EVs, free:
    - EXP: six Healing Wish Chansey or Blissey holding a Toxic Orb, at Lv. 25, 35 (Cobble Badge), 45 (Celestic Town
      reached), 55 (Icicle Badge), 65 (Pokémon League reached), 75 (Champion) or 85 (Stark Mountain finished);
    - EVs: six Lv. 10 Pokémon worth 1, 2 or 3 EVs of the chosen stat (the Azurill, Bellsprout, Geodude, Abra, Lotad
      and Pidgey lines);
    - her 25 teams are `TRAINER_SOVEREIGN_TRAYNEE_*`. Losing doesn't black out.
  - A rancher sells 15 each of the Pomeg, Kelpsy, Qualot, Hondew, Grepa and Tamato Berries for ₽5,000.
- **Fix: the move tutors crashed the game** when their move list opened. The list loads the move-name bank into the
  16 KB field heap, and with the Gen IX moves that bank is about 26 KB. It now reads each name as it needs it. The
  Battle Hall's record list had the same problem with the 1025 species names and gets the same fix.

Verified in the test build: the relearner, the power tutor's move list (Mud-Slap, Iron Head, Aqua Tail, Outrage,
Earth Power, Twister) and the "trying to learn" step with no Shard cost, the Move Deleter, the Berry seller's shop,
Traynee's Power items, menus and Lv. 25 Chansey course, the rancher (not enough money), the Psyduck and the Canalave
man. The release build passes.

## E10 (part 9) — Renegade's NPC gifts: the Trainers' School, the Item Fanatic, the trade-evolution items

Read from Renegade's ROM (scripts, texts and NPC positions).

- **Trainers' School:**
  - a Cowgirl gives a random baby Pokémon Egg, once (any of the 18 babies);
  - a Psychic tells a Pokémon's Hidden Power type.
- **The Item Fanatic** lives in Floaroma's southeast house. Show him a Pokémon that has an item of its own and he gives
  that item, once per Pokémon:
  - Pikachu: Light Ball;
  - Farfetch'd (or Sirfetch'd): Stick;
  - Cubone or Marowak: Thick Club;
  - Chansey: Lucky Punch;
  - Ditto: Metal Powder and Quick Powder;
  - Clamperl: Deep Sea Tooth and Deep Sea Scale.
  The Pokéfan beside him talks about the Thick Club.
- **Trade-evolution items from NPCs**, where Renegade has them:
  - Hotel Grand Lake's lobby: two fans argue; one gives the Electirizer, the other the Magmarizer;
  - Lost Tower 1F: a scientist gives the Reaper Cloth;
  - Veilstone Pokémon Center: Dragon Tamer Nils battles for the Dragon Scale (Dragonair, Shelgon, Vibrava at Lv. 35,
    Kingdra at Lv. 36; `TRAINER_SOVEREIGN_DRAGON_TAMER_VEILSTONE`). Lose and you can try again;
  - Veilstone northeast house: the man gives the Dubious Disc.
- **Porygon is a Poké Ball behind Jupiter** on the Eterna Galactic Building's 4F (Lv. 22), as in Renegade, instead of
  the Veilstone man's gift.
- **Route 214:** a Black Belt gives the Choice Band.
- **Snowpoint's east house:** a fisherman gives the Super Rod. He shares its flag with the Fight Area fisherman, so
  the rod comes once, from whichever is met first.

Verified in the test build: each NPC gives its item and then says its after-line; the Hidden Power teller names a
type; Porygon's ball shows Porygon and, with a full party, keeps it; Nils starts his battle with the Lv. 35 team. The
release build passes.

## E10 (part 8) — No TMs in the shops: Renegade's Veilstone 3F and Game Corner prizes

Read from Renegade's ROM (its mart lists and prize table sit where Platinum's do in `arm9`). These are the only shop
lists Renegade changed.

- **Veilstone Department Store 3F is the "Stone Corner".**
  - Top counter: Fire, Ice, Leaf, Moon, Sun, Thunder and Water Stones.
  - Bottom counter: Dawn and Dusk Stones, Everstone, Hard Stone, Oval Stone and Shiny Stone.
  - The clerks' tips and every floor's directory say so.
- **Game Corner prizes are held items, not TMs:**
  - for 1,000 coins: Focus Sash, Wide Lens, Zoom Lens, Metronome, Light Clay, Expert Belt, Muscle Band, Wise Glasses,
    Life Orb, Toxic Orb, Flame Orb, Leftovers, Mental Herb, Power Herb and White Herb;
  - for 2,000 coins: King's Rock, Metal Coat, Deep Sea Tooth and Deep Sea Scale.
- Every TM that left the shops is found or given elsewhere: `import_renegade_items.py`'s loss check finds none
  missing. The Battle Frontier's BP shop still has its TMs.

Verified in the test build: the 3F top counter lists the stones (a Fire Stone bought for ₽2,100), and the prize
list starts with Focus Sash, Wide Lens and Zoom Lens. The release build passes.

## E10 (part 7) — Iron Island as in Renegade: Riley's battle, HM04, the Steel-type Master

- **Riley battles the player at Iron Island's entrance** instead of handing over HM04. His team is Renegade's,
  read from its ROM (`res/trainers/data/sovereign_riley_iron_island.json`, `TRAINER_SOVEREIGN_RILEY_IRON_ISLAND`):
  Absol, Ursaring, Metagross, Salamence and Slaking at Lv. 49, Lucario at Lv. 50. Then he heals the party and goes
  inside.
- **HM04 (Strength) comes from Riley on B2F**, after the tag battle against the Galactic grunts, as in Renegade.
  He still gives his Riolu Egg there too (Renegade dropped it; Sovereign keeps it). Canalave's library still waits for
  HM04, as in both games.
- **Julian, a Steel-type Master,** stands near the dock, at (116, 505). Bring only one Pokémon, a Steel
  type, and he battles it with a Lv. 85 Lucario (`TRAINER_SOVEREIGN_STEEL_MASTER_IRON_ISLAND`). Win, and he gives the
  Iron Plate; lose, and you can try again.
- **A nurse on B2F** heals the party, as in Renegade.

Every TM and HM is now where Renegade has it, except HM08 (Rock Climb). Renegade's Snowpoint Temple scene, with
Candice, Maylene and a half-awake Regigigas, waits for the owner.

Verified in the test build:
- Riley's challenge and the start of his battle;
- the Steel-type Master turning down a full party;
- the nurse's heal.

Riley's B2F gift goes through the existing Egg scene. The release build passes.

## E10 (part 6) — Renegade's other TM and HM gifts

Every TM and HM now comes from where Renegade gives it (`ItemChanges.txt`, "TM Locations"), with three exceptions
listed below. Where Renegade dropped something to make room, Sovereign keeps it too.

| TM/HM | From | Note |
|---|---|---|
| TM10 Hidden Power | Jubilife Trainers' School, for beating both students | instead of a Potion |
| TM13 Ice Beam | Route 216 lodge, an Ace Trainer, with five badges | new NPC |
| TM15 Hyper Beam | Sunyshore City east house, an Ace Trainer | new NPC; Renegade replaced the Pokétch app scientist, who stays here |
| TM17 Protect | Great Marsh gate, the Cowgirl, for five catches in one Safari Game | together with the Matchup Checker app, which Renegade dropped |
| TM27 Return | Cheryl, at the end of Eterna Forest | instead of the Soothe Bell (a Route 203 ball and the Pokémon Mansion's maid give one) |
| TM29 Psychic | Lucian, who comes down from the Solaceon Ruins once | new scene |
| TM42 Facade | Jubilife TV lobby, an idol | new NPC; the Survival Area house still gives it too |
| TM44 Rest | Hearthome's foreign building, an old woman | new NPC |
| TM52 Focus Blast | Maylene, on Route 217 | in her scene |
| TM54 False Swipe | Cycling Road north gate, the aide, for 150 Pokémon seen | he still gives the Exp. Share at 35 (it works when the party-wide Exp. Share option is off) |
| TM55 Scald | Poffin House, a cook who scalded himself, for a Burn Heal | new NPC |
| HM07 Waterfall | Wake, after his Gym battle | instead of TM55 |

- **Rowan gives the Poké Radar and 10 Repels** in Sandgem Town instead of TM27, as in Renegade. When the National
  Pokédex arrives he skips the Poké Radar gift if the player already has one.
- **Jasmine gives a Metal Coat** in Sunyshore City instead of HM07.
- **Route 216 lodge:** Gardenia stops by once, looking for a Snover.
- **Route 217:** the Ice Rock gives an Ice Stone once.
- **Solaceon Ruins:** the hiker gives a Choice Scarf for lending HM05 instead of a Green Shard (the tutors don't take shards).
- The Cycling Road aide's Exp. Share talk no longer mentions obedience (traded Pokémon always obey since part 4).
- `import_renegade_items.py` only counts real gifts (`SetVar VAR_0x8004`) as a TM's other source, not scripts that
  merely check for the item. Every TM and HM is still obtainable.

Not ported yet:
- **HM04 Strength:** in Renegade, Riley battles the player at Iron Island's entrance and gives HM04 after the B2F tag
  battle, and a Steel-type Master gives the Iron Plate. That needs two more Renegade trainers; for now Riley still gives
  HM04 at the entrance.
- **HM08 Rock Climb:** Renegade removes the Route 217 ball and has Candice give it after a new Snowpoint Temple scene,
  where she, Maylene and the player put a half-awake Regigigas back to sleep before her Gym battle. That puts a
  Regigigas battle in the story, against Sovereign's post-game Regigigas (`LegendaryTriggers.md`), so it waits for the
  owner. The Route 217 ball still holds HM08.
- Renegade's Azure Flute gift in the foreign building is left out: Arceus has its own trigger in Sovereign.

Verified in the test build:
- the Route 216 Ace Trainer without five badges, and Gardenia;
- the TM15, TM42 and TM44 givers;
- the Poffin House cook without a Burn Heal;
- Lucian's scene through his TM29 speech;
- the Ice Rock's Ice Stone, given once.

The other changes are item swaps inside existing scripts; the release build passes.

## E10 (part 5) — Mira's quest in Wayward Cave (TM85), as in Renegade

- **Mira's story is Renegade's.** She now waits just inside the hidden entrance under the Cycling Road, at (38, 42).
  - She battles the player first. Her team is `res/trainers/data/sovereign_mira_wayward_cave.json`
    (`TRAINER_SOVEREIGN_MIRA_WAYWARD_CAVE`): Togetic, Haunter and Porygon2 at Lv. 27, Kadabra at Lv. 28.
  - She then joins as the tag partner, as before, and asks the player to find the Crimson Ribbon she lost deep in the
    cave. It's in a ball where she used to be (72, 11), next to Necrozma's chamber.
  - Heading back to the exit without the ribbon, she stays behind to keep searching. Coming back for her, she rejoins.
  - With the ribbon, at the exit, she gives TM85 (Dazzling Gleam) before she leaves.
  - Leaving the cave another way (Escape Rope, Fly) leaves her waiting at her spot. Finding the ribbon before meeting
    her, or while she waits, works too.
  - `VAR_SOVEREIGN_MIRA_QUEST_STATE` tracks it: 1 following, 2 waiting, 3 ribbon found, 4 done.
- **A Gabite (Lv. 25) waits by the stairs to B1F** in the main part of the cave, once. Beat it, catch it or run, and
  it's gone; losing brings it back.
- **The cave's eleven Rock Smash rocks are gone**, and the TM26 ball (King's Rock in Renegade) moved a step, as in
  Renegade. Two trainers see two tiles instead of one.
- **No ball keeps a Platinum TM any more.** With Mira's TM85 in, `import_renegade_items.py` gives Valor Lakefront's
  ball Renegade's Sharp Beak. Every TM is still obtainable in the main game.

Verified in the test build, with a Lv. 1 team for Mira so the battle stays short:
- Mira's battle and joining, her staying behind at (40, 42) and rejoining at (39, 42);
- the ribbon picked up while she waited, then "That's it!" when the player came back;
- the walk to the exit, and TM85 at the exit;
- the Gabite battle, and the Gabite gone after running.

Mira's real team was seen in battle (Togetic, Haunter, Kadabra). The release build passes.

## E10 (part 4) — Renegade's TM gifts, trades, the evolution-item seller, Aaron at the Route 208 gate

Renegade's NPCs are read from its ROM with `tools/design/renegade_rom.py` (new): it disassembles a map's scripts,
decodes its text and lists its NPCs, so they can be ported by hand. They're ported one map at a time.

- **TM gifts, as in Renegade:**
  - Fantina gives TM30 (Shadow Ball) after her battle, instead of TM65.
  - Bertha sits in the Veilstone Department Store 5F café, gives TM26 (Earthquake) and leaves.
  - Floaroma Town's middle house: an old swordsman gives TM40 (Aerial Ace). The Twin who gave TM88 (Pluck in Platinum;
    Hurricane in Renegade, now in an item ball), the Clefairy and the Pokémon Breeder are gone.
  - Eterna City's Underground Man house: a scientist hands out fossils for the Oreburgh museum (three of each, one Old
    Amber) and gives TM80 (Rock Slide) to a Trainer who shows her an Aerodactyl. A Ninja Boy gives TM28 (Dig).
  - Flint gives TM50 (Overheat) in Sunyshore City before he leaves for the League.
  - **Aaron at the Route 208 gate to Hearthome City.** The first time the player walks through, he comes in, heals the
    party and asks for an unofficial battle (Lv. 31–32 bugs, Renegade's team). Losing is fine. Either way he gives
    TM81 (X-Scissor). The gate's three NPCs are gone, as in Renegade. His team is
    `res/trainers/data/sovereign_aaron_route_208.json` (`TRAINER_SOVEREIGN_AARON_ROUTE_208`).
- **The item balls follow Renegade again.** With those NPCs in, `import_renegade_items.py` keeps only one ball on
  Platinum's TM: Valor Lakefront's TM85, until Mira's quest in Wayward Cave (which gives it in Renegade) is ported.
  Nine balls change, among them TM88 (Hurricane) on Route 210 North.
- **In-game trades are Renegade's:**

  | Where | You give | You get |
  |---|---|---|
  | Oreburgh City | Ponyta | Spheal "Gaia" (Never-Melt Ice) |
  | Eterna City | Snorunt | Chatot "Macaw" (Sharp Beak) |
  | Floaroma Town (was Snowpoint City) | Cherubi | Skorupi "Sting" (Poison Barb) |
  | Route 226 | Magikarp | Magikarp "Foppa" (Starf Berry, perfect IVs) |

- **Traded Pokémon always obey**, whatever their level and the player's badges.
- **The evolution-item seller** replaces the trade NPCs in Snowpoint City's west house (the Mega Stone Sage stays). Her
  shop sells every evolution item that isn't found elsewhere, ₽10,000 each (half after the Hall of Fame). The shop
  can now give every item one price (`Shop_StartFixedPrice`). The 34 items:
  - Renegade's 10: Dragon Scale, Dubious Disc, Electirizer, Magmarizer, Prism Scale, Protector, Razor Claw, Razor Fang,
    Reaper Cloth, Up-Grade;
  - the newer evolution items (Sachet, Whipped Dream, Black Augurite, Peat Block, Leader's Crest, the three Apples,
    Cracked Pot, Unremarkable Teacup, Auspicious and Malicious Armor, Metal Alloy);
  - Milcery's seven Sweets, the Chipped Pot, the Masterpiece Teacup and the Galarica Cuff and Wreath.

Verified in the test build: the swordsman's TM40, the seller's shop (₽10,000 each; "You don't have enough money"
with ₽3,000), the fossils and the Ninja Boy's TM28, Bertha's TM26 and her exit, and Aaron's scene through his battle
(Dustox Lv. 31, then Beautifly) to TM81 and his exit. The win was checked with a weaker team for Aaron in the test
build; losing goes through the same `ReturnToField` path as Platinum's first rival battle. Flint's scene, the Aerodactyl
TM80 and the trades weren't played. The release build passes.

## E10 (part 3) — Renegade's item balls, the Mega Stone spots rechecked, Prism Scale

- **Overworld item balls are Renegade's.** Renegade kept Platinum's 328 item balls and changed 110 of them: TMs
  moved, held items, evolution stones, Plates removed. They're read from Renegade's ROM
  (`tools/engine/import_renegade_items.py`, a one-off step); 73 balls change.
  - Renegade reused two unused Platinum items for its own: its Contest Pass is the Ice Stone (Route 216, Snowpoint
    Temple B4F) and its Loot Sack the Prism Scale (Mt. Coronet B1F).
- **Ten balls keep Platinum's TM for now.** Renegade gives those TMs from NPCs whose scripts aren't ported yet:
  - Bertha's TM26, Fantina's TM30, Floaroma's TM40, Aaron's TM81 and Flint's TM50;
  - Mira's TM85, and the Underground Man's TM28 and TM80;
  - plus the TM41 and TM59 balls that keeping those would cost.
  - The importer keeps any ball whose TM would otherwise have no source in the main game. It lists them, and they
    follow Renegade once their NPCs are in.
- **Mega Stones rechecked against Renegade.** The 15 field Mega Stones replaced Platinum's low-value balls. Eight of
  those balls hold something worth having in Renegade (TM75, a Silk Scarf, a Dusk Stone, a Razor Fang, Black Sludge, a
  Rare Bone and two Ice Stones). Those stones move to a nearby ball that is low-value in Renegade too:

  | Stone | Moves to |
  |---|---|
  | Alakazite | Route 204 South |
  | Aggronite | another Oreburgh Mine B2F ball |
  | Sablenite | Mt. Coronet 1F, Route 211 side |
  | Gardevoirite | another Route 208 ball |
  | Absolite | another Route 215 ball |
  | Kangaskhanite | Great Marsh Area 4 |
  | Abomasite | another Route 216 ball |
  | Glalitite | Snowpoint City |

  See `data/mega_stones.yaml` and `docs/MegaEvolution.md`.
- **Prism Scale** (new evolution item): Feebas also evolves into Milotic when it's used on it, as in Renegade.
- Renegade's hidden items are Platinum's (its table in the ROM is unchanged), so nothing changes there.

Verified in the test build: Route 203's item ball, which held the Alakazite, now gives "A found a Silk Scarf!".
The release build passes.

## E10 (part 2) — Renegade's TMs and ball prices

- **Six TMs teach Renegade's moves:** TM55 Scald (was Brine), TM57 Wild Charge (Charge Beam), TM62 Bug Buzz
  (Silver Wind), TM83 Hyper Voice (Natural Gift), TM85 Dazzling Gleam (Dream Eater) and TM88 Hurricane (Pluck).
  - New bag descriptions. TM85 keeps its pink disc, since there is no Fairy disc colour.
  - Who can learn them:
    - #1–493: Renegade's own compatibility, read from its ROM, plus every Pokémon that can learn the move in the
      newest games;
    - #494–1025 and the forms: the newest games (a form PokeAPI doesn't list follows its species).
  - Learners: TM55 135, TM57 187, TM62 113, TM83 261, TM85 285, TM88 137 (species and forms).
  - `tools/engine/apply_renegade_tms.py` is a one-off step (it needs the patched ROM), like `import_renegade_wild.py`.
    It only rewrites each file's `by_tm` list.
- **Every TM comes as 99 of it**, wherever it's obtained. Getting one again tops it back up to 99. TMs can't be sold
  (in Renegade they are worth ₽0).
  - TMs keep their prices for now, because Veilstone's 3rd floor and the Game Corner still sell some. Renegade moves
    those TMs elsewhere; they leave the shops with the item locations step.
- **Ball prices:** Poké Ball ₽50 (was 200), Great Ball ₽150 (600), Ultra Ball ₽300 (1,200).

Verified in the test build:
- The bag's TM pocket showed "No.55 Scald ×99" and "No.88 Hurricane ×99" with their new descriptions. Scald's details
  read Water, PP 15, power 80, accuracy 100.
- Using TM88 said "It contained Hurricane." The party screen showed Starly ABLE and Garchomp, Turtwig, Gallade,
  Archaludon and Ditto UNABLE.
- The release build passes.

## E10 (part 1) — Renegade's wild Pokémon, with the Sovereign plan

- **Every wild table is Renegade Platinum's now**, with the Gen V–IX species of the Sovereign encounter plan
  (`docs/WildPokemon_Sovereign.md`) in their slots. Before this, the game still had Platinum's tables.
  - Renegade's levels, rates and time-of-day slots, Poké Radar species and fishing tables come from Renegade's own
    ROM, not from its documentation.
  - Renegade left 65 tables as Platinum had them: Solaceon Ruins (Unown), Turnback Cave's pillar rooms, Ruin
    Maniac's cave and the Lake Verity of the opening. They stay that way.
- **How it's built.**
  - `tools/engine/import_renegade_wild.py` is a one-off step: it reads Renegade's tables from a patched ROM into
    `decomp/res/field/encounters/` (118 files changed). Build vanilla Platinum from the first decomp import, then
    apply Renegade with `tools/build/apply_renegade_patch.sh`.
  - `tools/engine/gen_wild_encounters.py` then writes each plan species into its slot and keeps Renegade's levels. It
    runs in `tools/regenerate_docs.sh`, so the docs check catches a plan and a table that disagree.
- **Encounter plan fixes** (`tools/design/gen_encounters.py`). Routes 219 and 220 ("Wild Levels:" in Renegade's
  doc) were read as part of Celestic Town. The first "Turnback Cave", which has no levels line, replaced Lake Valor's
  grass. With both fixed:
  - Routes 219 and 220 have their own tables, and Celestic Town and Lake Valor have theirs back;
  - Slurpuff moves to Lake Valor and Lurantis to Route 221;
  - Dubwool is now placed (Route 229), leaving 7 added species catchable only by evolving.
- **Honey Trees, as in Renegade.**
  - Each of the 21 trees has its area's own species, percentages and level (`decomp/include/data/sovereign_honey_trees.h`,
    from the plan). Platinum shared one table between every tree, at Lv. 5–15.
  - Slathering a tree brings a Pokémon at once. Platinum made the player wait six hours, and sometimes nothing came.
  - Renegade does this with a script per route; its ROM keeps Platinum's honey table (Route 207's script, for example,
    rolls 0–9 for Aipom, Slakoth, Metapod, Kakuna and Munchlax, the doc's 30/20/20/20/10).
  - The Pokédex's area map still shows Platinum's honey species at the trees.

Verified in the test build:
- In Route 202's grass, the wild Pokémon were Shinx, Woobat, Zigzagoon, Litleo and Rattata, all at Lv. 5, Renegade's
  level (Platinum: Lv. 2–4, no Woobat or Litleo).
- At Route 205 South's Honey Tree: "There is a sweet scent in the air...", Yes to "Slather the bark with Honey?", "The
  bark was slathered with Honey." and then a battle straight away. Five tries gave Combee four times and Wurmple once,
  all Lv. 12.
- The release build passes.

## FM — Alcremie, Furfrou's trims, Spiky-eared Pichu and Active Xerneas

- **Alcremie** (63 creams and sweets). Using any of the seven Sweets on Milcery evolves it, and the Sweet decides
  Alcremie's decoration.
  - Platinum can't spin Milcery, so the cream comes from the time of day and the Pokémon: Rainbow Swirl at twilight;
    Vanilla, Ruby Cream, Mint or Lemon Cream by day; Matcha, Salted Cream, Ruby Swirl or Caramel Swirl at night.
- **Furfrou's trims.** A groomer in the Hearthome City Pokémon Fan Club trims a Furfrou into any of its nine trims, or
  back to Natural, for free.
- **Spiky-eared Pichu.** The event-gift deliveryman now also gives a Spiky-eared Pichu (Lv. 30). It doesn't evolve.
- **Active Xerneas.** Xerneas is in its Active Mode in battle.
- A Pokémon's form number can now go up to 127; Platinum's form field only held 31.
- FM: 308 forms.

Verified in the test build:
- The groomer's list showed. Picking Heart Trim and then a Furfrou gave "All done! Doesn't it look fabulous?".
- A Love Sweet showed "ABLE!" on Milcery. Using it, "MILCERY evolved into ALCREMIE!", and the Sweet was used up.
- A wild battle with Xerneas leading ran normally.
- Release build passes.


## FM — Flower colors, wing patterns, seasons and the Antique teapots

- **Cosmetic forms** (79). They copy their species' data; their art comes with milestone E12.
  - **Flabébé, Floette and Florges:** red, yellow, orange, blue or white flower, from the personality. A Pokémon keeps
    its color when it evolves.
  - **Scatterbug, Spewpa and Vivillon:** the 20 wing patterns, from the personality. A Pokémon keeps its pattern when it
    evolves.
  - **Deerling and Sawsbuck:** the season they're met or hatched in. As in Black and White, spring, summer, autumn and
    winter change each month.
  - **Antique Sinistea and Polteageist, Artisan Poltchageist and Masterpiece Sinistcha:** 1 in 10.
    - An Antique Sinistea evolves with a Chipped Pot, and an Artisan Poltchageist with a Masterpiece Teacup.
    - The Cracked Pot and the Unremarkable Teacup work only on the ordinary ones.
- FM: 235 forms.

Verified in the test build: a wild Flabébé battle with a Vivillon, a Florges and a Sawsbuck in the party ran normally,
and the summaries opened. Both species already showed the "?" sprite, since neither has a front sprite yet.
Release build passes.


## FM — Fairy Arceus, Silvally's Memories and Genesect's Drives

- **Fairy Arceus.** Arceus holding the Pixie Plate is Fairy-type, and its Judgment is Fairy-type.
- **Silvally.** With RKS System, Silvally takes its held Memory's type, and Multi-Attack takes the Memory's type. All 17
  Memories work.
- **Genesect.** Its Drive changes its form, and Techno Blast takes the Drive's type: Douse Water, Shock Electric,
  Burn Fire, Chill Ice.
- **Item locks.** These items can't be knocked off, stolen or swapped away from their Pokémon.
- **Fairy boost.** The Pixie Plate and the Fairy Feather power up Fairy moves by 20%, like the other plates.

Verified in the test build:
- Arceus with the Pixie Plate showed FAIRY in the summary, and its Judgment was "not very effective" on a wild Gastly.
  (A Normal Judgment wouldn't affect a Ghost.)
- Silvally with a Fire Memory showed FIRE.
- Genesect with the Douse Drive stayed Bug/Steel.
- Release build passes.


## FM — Oricorio's styles and Resolute Keldeo

- **Oricorio's four styles** (Baile, Pom-Pom, Pa'u, Sensu): a wild or gift Oricorio's style comes from its personality.
  - Using a nectar on it from the bag changes its style: Red for Baile, Yellow for Pom-Pom, Pink for Pa'u, Purple for
    Sensu.
  - The nectar is used up, and a nectar for its current style has no effect.
  - Where the nectars are found comes with the shops step (`data/items_sovereign.yaml`).
- **Keldeo** is in its Resolute Form while it knows Secret Sword, and goes back when it forgets it.
- FM: 156 forms.

Verified in the test build: a Yellow Nectar from the bag on a Baile Style Oricorio said "ORICORIO changed Forme!". It
became Electric/Flying, and the bag went from 2 Yellow Nectars to 1. Not replayed: Keldeo's form, which has no art yet.
Release build passes.


## FM — Event forms and the event-gift deliveryman

- **Deliveryman.** An event-gift deliveryman in the Fight Area Pokémon Center (temporary placement) gives each event
  form once, from a list:
  - Own Tempo Rockruff (Lv. 10).
  - Eternal Floette (Lv. 50, with Light of Ruin).
  - Bloodmoon Ursaluna (Lv. 70, with Blood Moon).
  - Roaming Gimmighoul (Lv. 20).
  - Partner Pikachu with Zippy Zap and Partner Eevee with Veevee Volley (Lv. 5).
  - Cosplay Pikachu and its five costumes, each costume with its contest move (Lv. 20).
  - The eight cap Pikachu (Lv. 25).
- **Mythicals.** Magearna and Zarude are Mythical, and Mythicals are never gifts. He restyles a Magearna or Zarude the
  player caught into Original Color Magearna or Dada Zarude instead.
- The costumes, caps, partners and Eternal Floette don't evolve, as in the official games.
- **Megas:**
  - Mega Floette comes only from Eternal Floette, as in Legends: Z-A, and goes back to it.
  - Original Color Magearna Mega Evolves into Mega Magearna (Original Color).
- FM: 152 forms.

Verified in the test build:
- The list showed. Partner Pikachu came at Lv. 5, met in the Fight Area, with Zippy Zap and its partner Speed.
- Asking for it again gave "I already delivered that one!". World Cap Pikachu came at Lv. 25.
- Showing Donphan for Magearna gave the "isn't a MAGEARNA" line. Showing Magearna restyled it.
- Release build passes.


## FM — Midnight and Dusk Lycanroc

- Rockruff evolves into Midday Lycanroc from 6:00 to 17:59, and into Midnight Lycanroc otherwise, as in Sun and Moon.
- Own Tempo Rockruff (with Own Tempo) evolves into Dusk Lycanroc (Tough Claws) at twilight, 17:00 to 19:59.
- Its Eggs are ordinary Rockruff. How players get it comes with the event-form gifts.
- FM: 131 forms.

Release build passes. Not replayed in the emulator: the evolution depends on the clock.


## FM — Sizes, plumages and other personality forms

These forms are picked by the Pokémon's personality when it's made (wild, gift, Egg) and when it evolves into the
species:
- **Pumpkaboo and Gourgeist sizes:** Average 40%, Small 30%, Large 20%, Super 10%, as in X and Y. A Gourgeist keeps
  its Pumpkaboo's size.
- **Squawkabilly's plumage** (Green, Blue, Yellow, White) and **Tatsugiri's form** (Curly, Droopy, Stretchy).
- **Low Key Toxtricity:** from the Low Key natures (Lonely, Bold, Relaxed, Timid, Serious, Modest, Mild, Quiet,
  Bashful, Calm, Gentle, Careful), as in Sword and Shield. Otherwise Toxtricity is Amped.
- **Maushold Family of Three and Three-Segment Dudunsparce:** 1 in 100, as in Scarlet and Violet.
- **Megas:** a Droopy or Stretchy Tatsugiri Mega Evolves into its own form's Mega Tatsugiri and goes back to its form.
- FM: 128 forms.

Verified in the test build (in-battle summaries):
- Modest Toxtricity: Low Key, with Minus.
- Adamant Toxtricity: Amped, with Plus.
- Super Pumpkaboo: HP 127 at Lv. 50, from its higher base HP.
- Release build passes.


## FM — Female Meowstic, Indeedee, Basculegion and Oinkologne

- A female Meowstic, Indeedee, Basculegion or Oinkologne has its female's form, with its own abilities, learnset and,
  for Indeedee, Basculegion and Oinkologne, stats:
  - wild, gift and Egg Pokémon get it when they're made;
  - a female Espurr, Lechonk or White-Striped Basculin evolving into one gets it;
  - a trainer's Pokémon follows its gender too.
- A Female Meowstic Mega Evolves into Mega Meowstic (Female) and goes back to its female's form after the battle.
- Oinkologne can be female now: PokeAPI had it male only, so a female Lechonk would have evolved into a male.
- FM: 114 forms.

Verified in the test build (in-battle summaries):
- Female Indeedee: Own Tempo, with Sp. Def 110 and Sp. Atk 101.
- Male Indeedee: Inner Focus, with Sp. Atk 137 and Sp. Def 111.
- Female Oinkologne: Aroma Veil.
- Not replayed: evolution into a female's form and Mega Meowstic (Female).
- Release build passes.


## FM — Terastal Terapagos

- **Tera Shift.** Terapagos becomes its Terastal Form as it enters battle ("TERAPAGOS transformed!").
  - Its max HP rises, and its HP rises by as much, as in Scarlet and Violet.
  - It stays Terastal through switching, until the battle ends.
- **Tera Shell** (the Terastal Form's ability). At full HP, every damaging move it isn't immune to is not very effective
  on it, for every hit of a multi-hit move. Mold Breaker ignores it.
- The Stellar Form stays shelved (no Terastallization). FM: 110 forms.

Verified in the test build (Terapagos vs. a wild Rattata):
- It transformed on entry, and its HP rose with its max HP. The summary showed Tera Shell.
- It switched back in still Terastal. At full HP, Rattata's Tackle was "not very effective".
- Release build passes.


## FM — Ice Face and Gulp Missile

- **Ice Face (Eiscue).**
  - The first physical hit on Eiscue does no damage: "EISCUE’s Ice Face took the hit!", and it becomes Noice Face.
  - Mold Breaker ignores Ice Face, and a substitute takes the hit first. Of a multi-hit move, only the first hit is
    blocked.
  - Noice Face stays through switching, until the battle ends.
  - Snow brings the ice back when Eiscue switches in during it or when snow starts, not on every turn of it (as in
    Scarlet and Violet). Platinum's hail is Gen IX snow in Sovereign.
- **Gulp Missile (Cramorant).**
  - When Cramorant's Surf hits, or as it dives (Dive's first turn), it catches an Arrokuda (Gulping Form) above half
    its HP, or a Pikachu (Gorging Form) at half or less.
  - A damaging hit on it spits the catch at the attacker, even as Cramorant faints:
    - The attacker loses 1/4 of its max HP ("CRAMORANT’s Gulp Missile hurt …!"); Magic Guard prevents this.
    - Then an Arrokuda lowers the attacker's Defense, and a Pikachu paralyzes it.
  - Cramorant goes back to its base form. A Cramorant underwater can't be made to spit, and a catch is lost when it
    switches out.
- New forms: Noice Eiscue, and Gulping and Gorging Cramorant (FM: 109 forms).

Verified in the test build:
- **Eiscue vs. a wild Rattata:**
  - Tackle was blocked and Eiscue transformed.
  - After a switch out and back in, Eiscue was still Noice, and Tackle hurt it.
  - Hail ("It started to snow!") brought the ice back once, and the next Tackle was blocked again. Later snowy turns
    didn't restore it.
- **Cramorant vs. a wild Lotad:**
  - At 2/5 HP, Surf caught a Pikachu. Absorb then made Cramorant spit it: "Gulp Missile hurt the wild LOTAD!" and
    Lotad was paralyzed. Later hits did nothing extra.
  - At full HP, Dive caught an Arrokuda; Lotad's Astonish missed while Cramorant was underwater. Its next Astonish
    made Cramorant spit: Lotad was hurt and its Defense fell.
- Release build passes.


## Paradox dealers in the Oreburgh Mining Museum

- **Owner, 2026-10-24:** the Paradox Pokémon are gifts, not rare wild encounters.
  - Once the player has all 8 badges, two NPCs stand in the Oreburgh Mining Museum: a fossil maniac (ancient Paradox
    Pokémon) and a futuristic scientist (future ones).
  - Show either one a Pokémon. If it is the present-day Pokémon of a Paradox Pokémon of their era, they give that
    Paradox Pokémon at the shown Pokémon's level, with a nickname prompt. The shown Pokémon stays with the player.
  - Each Paradox Pokémon is given once. Iron Valiant answers to Gardevoir or Gallade. Cyclizar's Paradox Pokémon,
    Koraidon and Miraidon, aren't given.
  - **Koraidon** appears at Sendoff Spring once all ten ancient Paradox Pokémon are given, and **Miraidon** once all ten
    future ones are (both still from the Paldea Chronicle's opening).
- The twenty wild Paradox encounters are gone, and the Archivist's Paradox topic now points to the museum.
- **How:** three script commands (`SovereignGetParadoxForm`, `SovereignSetParadoxGiven`,
  `SovereignCheckParadoxEraComplete`) over the `sParadoxForms` table in `scrcmd.c`; each era's ten are bits of
  `VAR_SOVEREIGN_PARADOX_ANCIENT` / `VAR_SOVEREIGN_PARADOX_FUTURE`.

Verified in the test build:
- With the museum entered at 8 badges, both dealers stand at (11, 11) and (13, 11).
- Donphan to the fossil maniac gave Great Tusk at Lv. 40, with the nickname screen. With the other nine ancient bits
  preset, talking again gave the "every ancient form" line.
- To the futuristic scientist: Bidoof gave the no-form line; Gallade gave Iron Valiant at Lv. 45; Gallade again gave
  the already-given line; Donphan gave Iron Treads (nickname declined). Cancelling the party menu ends the talk.
- At Sendoff Spring, Koraidon showed and Miraidon didn't.
- Release build passes.


## Revival Blessing left out for now

- **Owner, 2026-10-24:** Revival Blessing stays out of the game for now.
  - No Pokémon learns it: Pawmot and Rabsca lose it from their level-up moves.
  - The move itself stays in the move list (it still does nothing).
- **How:** `LEFT_OUT_MOVES` in `tools/engine/gen_species_gen9.py` keeps it out of every generated learnset. Remove it
  there and rerun `tools/engine/gen_new_species.py` to teach it again.

## Ultra Burst counts as the Mega; Cosmog without Teleport

- **Ultra Burst** (owner, 2026-10-24: no Z-Moves) now counts as the trainer's one Mega Evolution. A trainer who Ultra
  Bursts Necrozma can't Mega Evolve in that battle, and one who Mega Evolved can't Ultra Burst.
- **Cosmog** (owner, 2026-10-24) no longer learns Teleport, so the Cosmog on Mt. Coronet can't flee its battle. It
  knows only Splash until it evolves. This is `LEFT_OUT_BY_POKEMON` in `tools/engine/gen_species_gen9.py`.
- **Verified:** release build, boot smoke, docs. The Ultra Burst change is two lines in `battle_lib.c`; it wasn't
  replayed in the emulator.

## FM — Battle Bond Greninja and Ash-Greninja

- **The gift** (owner, 2026-10-24: the Battle Frontier's Battle Bond).
  - An Ace Trainer in the Fight Area Pokémon Center gives a level 50 Battle Bond Greninja, once.
  - It knows Water Shuriken, Aerial Ace, Double Team and Night Slash, like the official demo's.
  - With a full party, he asks the player to come back.
- **Battle Bond.**
  - When its move knocks out a foe: "GRENINJA became fully charged due to its bond with its Trainer!", then
    "GRENINJA became Ash-Greninja!".
  - It stays Ash-Greninja until the battle ends.
  - Ash-Greninja's Water Shuriken has 20 power and always hits 3 times.
- **How:** `TechnicalDesign.md` (Battle Bond). Both forms share Greninja's sprite until milestone E12.
- **Verified** in the emulator:
  - An Ash-Greninja's Water Shuriken: "Hit 3 time(s)!".
  - A Battle Bond Greninja's Night Slash knocked out a wild Starly, and Greninja became Ash-Greninja with both
    messages.
  - The gift with a full party: "Your party's full". With room: received, nickname prompt, then the summary showed
    Lv. 50, Battle Bond, the four moves and "Fight Area".
  - Release build, boot smoke, docs.

## FM — Hero Palafin

- **Zero to Hero.** Palafin turns into its Hero Form when it switches out. When it comes back in: "PALAFIN underwent a
  heroic transformation!" (only the first time). Hero Palafin has 160 Attack and 106 Sp. Atk, against Zero's 70 and
  53. It stays Hero until the battle ends.
- **How:** `TechnicalDesign.md` (Zero to Hero). Hero Palafin shares Palafin's sprite until milestone E12.
- **Verified** in the emulator (a level 30 Palafin on Route 201): switched out and back in, it showed the heroic
  transformation. Switched out and in a second time, no message. Release build without warnings, boot smoke, docs.

## FM — Hangry Morpeko and Aura Wheel

- **Hunger Switch.** At the end of each turn Morpeko switches between its Full Belly and Hangry Modes: "MORPEKO
  transformed!". It comes back in, and ends the battle, in Full Belly Mode.
- **Aura Wheel** raises the user's Speed by 1 every time. It is Electric-type from a Full Belly Morpeko and Dark-type
  from a Hangry one.
- **Ability checklist:** `docs/AbilityChecklist.md` now lists the form abilities that work in battle: Zen Mode,
  Stance Change, Shields Down, Schooling, Disguise, Power Construct and Hunger Switch.
- **How:** `TechnicalDesign.md` (Hunger Switch). Hangry Morpeko shares Morpeko's sprite until milestone E12.
- **Verified** in the emulator (a level 30 Morpeko against a wild Gastly):
  - Hangry at the end of turn 1, Full Belly at the end of turn 2 (after hurting itself in confusion), Hangry again at
    the end of turn 3.
  - Then Aura Wheel was super effective on Gastly (Dark-type) and Morpeko's Speed rose.
  - Release build without warnings, boot smoke, docs.

## FM — Zygarde's formes and Power Construct

- **Zygarde Cube.**
  - Once Zygarde is caught, the Archivist gives the Zygarde Cube (Kalos Chronicle, Life and Destruction).
  - Used on Zygarde from the bag, it goes through its formes in turn: 50%, 10%, 10% with Power Construct, 50% with
    Power Construct, then 50% again ("ZYGARDE changed Forme!").
  - The 10% Formes have 54 HP and 115 Speed. The ability goes with the forme: Aura Break, or Power Construct.
- **Power Construct.**
  - At the end of a turn at half HP or less, a Zygarde with Power Construct turns Complete: "You sense the presence
    of many!", then "ZYGARDE transformed into its Complete Forme!".
  - Its max HP rises (216 base HP) and its HP rises by as much, shown on the HP bar.
  - It stays Complete when it switches out, until the battle ends. It then goes back to the forme it came from and
    keeps the damage it took.
- **How:** `TechnicalDesign.md` (key-item forms, Power Construct). Every forme shares Zygarde's sprite until milestone
  E12.
- **Verified** in the emulator (two level 70 Zygarde on Route 201):
  - A 10% Power Construct Zygarde at 68/170 turned Complete at the end of the first turn. The HP bar showed 65/397,
    then rose to 292/397.
  - It switched out and came back still Complete at 292/397.
  - After the battle it was 10% again at 64/170, the 106 HP it had lost as Complete kept.
  - The Cube on a 50% Zygarde (240/241): 165/166 twice (the two 10% Formes), then 240/241 twice. The third forme's
    summary showed Power Construct.
  - Release build without warnings, boot smoke, docs.

## FM — Minior and Shields Down

- **Minior's colors.** Minior has its 7 Meteor Forms and 7 Cores, in the official order (0–6 Meteor, Red to Violet;
  7–13 Core). Its color comes from its personality, as in Sun and Moon, and stays for good. A hatched Minior gets its
  own color, not its parent's.
- **Shields Down.**
  - A Minior in Meteor Form drops its shell when it enters battle at half HP or less, or at the end of a turn at half
    HP or less: "MINIOR transformed!". The Core has 100 Attack, 100 Sp. Atk and 120 Speed, against Meteor's 60, 60 and
    60, and 60 Defense and Sp. Def against Meteor's 100.
  - Above half HP at the end of a turn, it goes back to Meteor Form.
  - In Meteor Form it can't be poisoned, paralyzed, burned, frozen, put to sleep or made drowsy: "MINIOR's Shields
    Down prevents ...". Rest fails. Mold Breaker doesn't get past it. A status it got as a Core stays.
  - It goes back to Meteor Form on switch-out and at the battle's end.
- **How:** `TechnicalDesign.md` (Schooling and Shields Down, personality forms). Every Minior shares the base sprite
  until milestone E12.
- **Verified** in the emulator (a wild Minior on Route 201; a Mold Breaker Smeargle; two level 50 Miniors holding a
  Flame Orb):
  - Against the Meteor Minior, Thunder Wave, Toxic (twice) and Yawn were blocked ("Shields Down prevents
    paralysis!", "... prevents poisoning!", "... made it ineffective!"), Mold Breaker or not.
  - False Swipe took it to 1 HP and it became a Core at the end of the turn; Thunder Wave then paralyzed it.
  - The player's full-HP Minior: Flame Orb didn't burn it, and Rest failed.
  - The player's Minior at 40% became a Core as it came in. Flame Orb burned it. Rest healed it and put it to sleep,
    and at the end of the turn it went back to Meteor Form, still asleep.
  - From memory: the player's Minior is form 5 (Indigo) with personality % 7 = 5; the wild one at 1 HP was form 8
    (Orange Core) with personality % 7 = 1.
  - Release build without warnings, boot smoke, docs; every battle script fits its buffer (the largest is
    badly poison, now 1680 bytes).

## Fix — Toxic broke the player's Pokémon

- **Bug:** using Toxic, or any badly-poison effect, could leave the player's lead Pokémon with "has no moves left!", so
  it could only Struggle. It could also change its stats, and even its species, for the rest of the battle.
- **Cause:** Toxic's subscript had grown to 1620 bytes with Corrosion and Misty Terrain. The battle script buffer holds
  1600 (`BATTLE_SCRIPT_SIZE_MAX`, 400 u32s), and the buffer sits right before the first battler's data. Loading the
  script overwrote that battler's species, stats and moves.
- **Fix:**
  - The buffer holds 512 u32s (2048 bytes).
  - `BattleSystem_CallScript` checks against the same constant instead of a copy of 400.
  - `tools/test/check_battle_scripts.py` fails the CI build when a built script doesn't fit.
- **Verified** in the emulator:
  - Before the fix, a Mold Breaker Smeargle used Toxic on a wild Zangoose. The next turn it had "no moves left", and a
    write watch caught the script load overwriting its battle data.
  - After the fix: Zangoose was badly poisoned and cured itself with Immunity, and Smeargle used Yawn the next turn.
  - The checker passes at 512 and fails at 400 (badly poison, 1620 bytes). Release build without warnings, boot
    smoke, docs.

## FM — School Wishiwashi

- **Schooling.**
  - A Wishiwashi at level 20 or more forms a school when it enters battle with over 1/4 of its HP: "WISHIWASHI
    transformed!".
  - School Wishiwashi has 140 Attack, 130 Defense, 140 Sp. Atk and 135 Sp. Def, against Solo's 20, 20, 25 and 25.
  - At the end of a turn at 1/4 HP or less it goes back to Solo, and above 1/4 it schools again. A hit during the
    turn doesn't change it.
  - It goes back on switch-out and at the battle's end.
- **How:** `TechnicalDesign.md` (Schooling). School Wishiwashi shares Wishiwashi's sprite until milestone E12.
- **Verified** in the emulator (Route 201, level 30):
  - At 18/70 HP it schooled on entry (Attack 95).
  - At 20% HP the other one came in Solo, with no message.
  - Switched back in at 18/70 it schooled. A Tackle took it to 17/70, and it went back to Solo only at the end of
    the turn.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — Disguise

- **Disguise.** The first hit a Mimikyu takes in a battle hits its disguise instead: "Its disguise served it as a
  decoy!", then "MIMIKYU's disguise was busted!".
  - It takes no damage from the move but loses 1/8 of its max HP, as in Gen VIII and later.
  - A move's hit or hurting itself in confusion busts the disguise. Life Orb, recoil, poison, burn, sandstorm and entry
    hazards don't. Mold Breaker ignores it, and a substitute takes the hit first.
  - The Totem Mimikyu's disguise works the same way.
- **Once per battle.** A busted Mimikyu stays busted for the rest of the battle: when it switches out and back, and
  when it faints and is revived.
  - A Mimikyu that faints with its disguise intact keeps it when revived.
  - The disguise comes back when the battle ends.
  - Revival Blessing isn't implemented yet (the move does nothing). It will follow these rules, since the disguise is
    kept on the Pokémon's form.
- **How:** `TechnicalDesign.md` (Disguise). Busted Mimikyu shares Mimikyu's sprite until milestone E12.
- **Verified** in the emulator:
  - Route 201: Life Orb recoil and poison didn't bust it.
  - Stark Mountain, Earthquake: the disguise took the hit and cost 1/8. At 3 HP that knocked Mimikyu out, busted.
  - A Mimikyu that fainted to its own Life Orb recoil, disguise intact, was revived with a Revive and switched in; its
    disguise took the next Earthquake.
  - The one revived after busting took the next Earthquake in full.
  - After fleeing, the busted Mimikyu's disguise took a hit in the next battle.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — Zen Mode

- **Zen Mode.** A Darmanitan with Zen Mode turns to Zen Mode at the end of a turn with half its HP or less:
  - Darmanitan becomes Zen Darmanitan (Fire/Psychic).
  - Galarian Darmanitan becomes Zen Galarian Darmanitan (Ice/Fire).
  - Above half HP it turns back. It also goes back on switch-out and at the battle's end, and keeps Zen Mode as its
    ability.
- **Fixed:** a battle form of a regional form now goes back to that regional form (Galarian Darmanitan, not
  Darmanitan). A form change in battle now changes the ability only for a Mega, Primal or Ultra Necrozma; before, Zen
  Darmanitan would have taken Sheer Force.
- **How:** `TechnicalDesign.md` (Zen Mode). The Zen forms share Darmanitan's sprite until milestone E12.
- **Verified** in the emulator:
  - Darmanitan at 40% HP turned to Zen Mode at the end of the turn (Fire/Psychic, Zen Mode).
  - A Galarian Darmanitan switched in at 40% did the same (Ice/Fire).
  - After the battle the two were Fire and Ice again, so the Galarian one stayed Galarian.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — Blade Aegislash

- **Stance Change.**
  - Aegislash switches from Shield Forme (Attack 50, Defense 140) to Blade Forme (Attack 140, Defense 50) before
    using a damaging move, and back to Shield Forme before King's Shield.
  - The change shows before the move's "AEGISLASH used ..." message, with Platinum's form-change scene.
  - Blade Forme goes back to Shield Forme when Aegislash switches out and when the battle ends.
- **How:** `TechnicalDesign.md` (Stance Change). Blade Aegislash shares Aegislash's sprite until milestone E12.
- **Verified** in the emulator (a wild battle on Route 201):
  - Shadow Ball turned Aegislash to Blade Forme even though it couldn't affect the Bidoof. The battle summary went
    from Attack 56 / Defense 125 to Attack 135 / Defense 53.
  - King's Shield turned it back.
  - After another Shadow Ball, it switched out and back in as Shield Forme.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — Pirouette Meloetta

- **Relic Song** switches Meloetta from Aria Forme (Normal/Psychic) to Pirouette Forme (Normal/Fighting, with its own
  stats) and back, as in Black and White. It happens after the move, with Platinum's form-change scene and
  "MELOETTA transformed!". The move must hit: against a Ghost type, or if it misses, Meloetta keeps its form.
- Pirouette Meloetta goes back to Aria Forme when it switches out and when the battle ends.
- **How:** `TechnicalDesign.md` (Move forms). Pirouette Meloetta shares Meloetta's sprite until milestone E12.
- **Verified** in the emulator:
  - Relic Song hit a Camerupt and Meloetta transformed. The battle summary showed Normal/Fighting and Pirouette's
    stats.
  - It switched out and back in as Aria (Normal/Psychic).
  - Against a Gastly, Relic Song had no effect and Meloetta didn't transform.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — Ultra Necrozma

- **Ultra Burst.** Dusk Mane or Dawn Wings Necrozma holding the **Ultranecrozium Z** can Ultra Burst into Ultra
  Necrozma (Psychic/Dragon, Neuroforce) from the battle's MEGA button. It needs the Mega Ring, like Mega Evolution, but
  doesn't use up the trainer's one Mega. Its messages: "Bright light is about to burst out of NECROZMA!" and "NECROZMA
  regained its true power through Ultra Burst!". When the battle ends it goes back to the fused form it burst from.
- **The Ultranecrozium Z** comes from the Legend Archivist, once, in the Sun and Moon topic after Necrozma is caught
  (`FLAG_SOVEREIGN_RECEIVED_ULTRANECROZIUM`). Knock Off, Thief, Trick and Fling can't take it from a Necrozma.
- **How:** `TechnicalDesign.md` (Ultra Burst). Ultra Necrozma shares Necrozma's sprite until milestone E12.
- **Verified** in the emulator:
  - The Archivist gave the Z.
  - In a wild battle a Dusk Mane Necrozma Ultra Burst from the MEGA button. The battle summary showed Psychic/Dragon
    and Neuroforce.
  - A Dawn Wings Necrozma switched in and Ultra Burst in the same battle.
  - After the battle the two were Dusk Mane (Psychic/Steel) and Dawn Wings (Psychic/Ghost) again.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — Rapid Strike Urshifu

- **Rapid Strike Urshifu** (Fighting/Water, Unseen Fist, its own Gen IX learnset) is in the game.
  Kubfu evolves into it with the Scroll of Waters, and into Single Strike Urshifu with the Darkness Scroll, as the
  item descriptions already said. Before, the Scroll of Waters did nothing.
- **How:** an item evolution can now choose the evolved form (`item_evolution_forms` in
  `data/evolution_changes.yaml`; `TechnicalDesign.md`). The form is kept for good, like a regional form. It shares
  Urshifu's sprite and icon until milestone E12 adds form art, as the other forms do.
- **Verified** in the emulator: each Scroll used from the bag on a Kubfu evolved it, and the summaries show
  Fighting/Water and Fighting/Dark; each Scroll was used up. The release ROM builds without warnings and passes boot
  smoke; the docs regenerate clean.

## E11 — The Chronicles: three more fixes from the trigger note

- **The Insect Plate:** Virizion stands on the only tile that faced Eterna Forest's hidden Insect Plate, so the plate
  couldn't be found while Virizion was there. The plate is now one tile down the corridor, in its west wall (79, 11).
- **Meloetta** stood inside the wander range of the Beauty in front of the Contest Hall stage. It now stands two tiles
  west (27, 8), clear of her.
- **The Area Zero topic** said "Koraidon and Miraidon have come" when one of them was already caught. It now says the
  other one still waits at Sendoff Spring.
- **Verified** in the emulator: the Area Zero line with Miraidon caught and Koraidon not; Virizion's battle from the
  corridor, then the Insect Plate from the tile below it; Meloetta's battle from its new tile. The release ROM builds
  without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Chronicles: the legendary trigger note and the fixes it found

`docs/LegendaryTriggers.md` lists what makes every legendary, mythical, Ultra Beast and Paradox Pokémon appear: the
Chronicle statics, roamers and rare wild encounters, vanilla Platinum's legendaries, and Renegade's documented events
with the spots they share with the Chronicles. A code audit for it found these, now fixed:
- **Diancie couldn't appear:** it needs a Carbink in the party, and no Carbink was obtainable. Carbink is now wild
  outside Stark Mountain (5%, Lv. 66–68) from the Kalos Chronicle's opening, a stopgap in
  `data/sovereign_rare_wild.yaml` until the planned wild tables are ported. The Archivist's hint says where.
- **Regidrago's hint:** the Archivist's Galar topic checked Regieleki twice, so once Regieleki was caught he no longer
  said that Regidrago wakes for Regirock, Regice and Registeel in the party.
- **The Scrolls:** evolving Kubfu uses up its scroll, so the Archivist gave both scrolls again on every later reading.
  He gives them once now (`FLAG_SOVEREIGN_RECEIVED_SCROLLS`).
- **Hints:** Poipole's says to catch Necrozma first; the knocked-out roamer line says to come back to the Archivist
  after the next Hall of Fame (the release needs him).
- **Docs:** they said the player can't run from a Chronicle legendary. Running works, as from any wild battle, and
  ends like a knock-out.
- **Verified** in the emulator: the Galar topic gives the scrolls once and shows the Regi hint with Regieleki caught
  and Regidrago not; a wild Carbink on Stark Mountain's grass (the test build forced the roll). The release ROM builds
  without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Chronicles: every legendary in, rare wild encounters and new roamers

Every Chronicle legendary left in the plan is now in the game (`docs/PostgameLegendaries.md`), and the owner's
encounter rules of 2026-10-23 are built (decisions 26 to 28, `ProjectStatus.md`):
- **No gifts.** Cosmog and the other planned gifts are battles; the gift script is gone.
- **Spear Pillar is kept for Dialga, Palkia and the story.** Cosmog (both battles) floats on Mt. Coronet's top
  snowfield, and Necrozma waits in Wayward Cave 1F's dark back chamber.
- **Rare wild encounters.** The twenty Paradox Pokémon (from the Paldea Chronicle's opening) and the nine Ultra Beasts
  with Poipole (once Necrozma is caught) are wild, at 2% of the wild encounters on their maps, and can be met again:
  Great Tusk on Route 207, Walking Wake surfing on Route 213, Iron Moth at Fuego Ironworks, Buzzwole on Route 225,
  Guzzlord in Turnback Cave's pillar rooms and so on (`docs/RareWildEncounters.md`). The roll runs in grass, surf,
  Sweet Scent and mud encounters, but not in Poké Radar patches, with a partner or in the Safari Game.
- **Roamers.** Zeraora, Okidogi, Munkidori, Fezandipiti, Glastrier and Spectrier roam Sinnoh. The Legend Archivist
  releases them (the other Alola legends, the Loyal Three, and the steeds once Calyrex is caught) and again after a
  Hall of Fame if one was knocked out. Five new roaming slots, plus vanilla's unused Darkrai slot.
- **The rest of Alola:** Type: Null, Magearna, Marshadow, Meltan then Melmetal (Oreburgh Mine B2F).
- **Galar:** Zacian holding the Rusted Sword and Zamazenta holding the Rusted Shield (Route 210 North's ledge; they
  turn Crowned in battle), Eternatus, Kubfu (the Archivist then gives both Scrolls), Zarude, Regieleki, Regidrago and
  Calyrex (then the Reins of Unity).
- **Paldea:** the Treasures of Ruin, each behind two stakes to pull out; Ogerpon holding the Teal Mask, and a
  Pokéfan in Celestic Town who gives the other three masks to a player leading with it; Pecharunt once the Loyal
  Three are caught; Koraidon and Miraidon at Sendoff Spring once all twenty Paradox Pokémon are caught, then
  Terapagos.
- The Archivist has a chapter and topics for each, with a hint for every legendary not caught yet.
- **Fixed:**
  - Meloetta stood on the Contest Hall stage, which the player can't walk onto; it's in front of the stage now.
  - A vanilla roamer bug: after any wild battle, a Pokémon of a roaming species counted as the roamer, so knocking
    out or catching a wild Galarian Articuno in the Regional Forms Park would have wiped a roaming Articuno. Only a
    roamer battle counts now.
- Found while testing and fixed: the stakes were invisible (a bollard has only a down frame), Zacian stood on stairs
  the player couldn't face it from, and the Celestic Pokéfan never saw the Ogerpon in the lead.
- **Verified** in the emulator (test builds that set the game completed, opened the Chronicles and marked the key
  legendaries caught):
  - Every static legendary seen, battled at its level, caught and gone afterwards: the Ultra Beasts as they stood
    before decision 28, the rest of Alola, Galar (Zacian and Zamazenta on the ledge, Eternatus once both are caught),
    the Treasures of Ruin after both stakes, the Loyal Three as they stood, Pecharunt, Ogerpon, Koraidon, Miraidon,
    Terapagos, Cosmog twice on the summit, Necrozma in Wayward Cave and Meloetta before the stage.
  - The three masks from the Celestic Pokéfan with Ogerpon leading. Spear Pillar with no Chronicle object.
  - Rare wild: Great Tusk on Route 207, Buzzwole on Route 225 and Iron Jugulis on Route 222, each at its level (the
    test build forced the roll to hit).
  - Roamers: the Archivist's three releases; Zeraora, Okidogi and Glastrier met and caught on Route 201 (the test
    build kept every roamer there); the hints afterwards list only the ones still roaming.
  - Every Archivist topic of the four new chapters, the Paradox hints and the Ultra Beast hints.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.
- **Not tested:** a knocked-out roamer's message and its release after the next Hall of Fame (the same code path as
  Tornadus's), a rare wild Pokémon while surfing, and the real 2% odds.

## E11 — The Chronicles: the Alola Chronicle opens (the Tapus, Cosmog and Necrozma)

The first part of the Alola Chronicle (`docs/PostgameLegendaries.md`), in existing spots (owner, 2026-10-23):
- **The Alola Chronicle** opens when the player talks to the Archivist with Xerneas and Yveltal caught: "XERNEAS and
  YVELTAL, the heart of the Kalos Chronicle, both caught! And look! A third tome has opened: the Alola Chronicle!"
  "Alola Chronicle" then joins his first menu. Its own menu has two topics so far: Island Guardians, and Sun and Moon.
- **The Island Guardians** (Lv. 65):
  - Tapu Koko on the sand strip at Route 222's east end.
  - Tapu Lele at the edge of Fullmoon Island's grove.
  - Tapu Bulu in Floaroma Meadow's north field.
  - Tapu Fini on a little beach under Route 226's cliffs, reached by Surf.
- **Sun and Moon:**
  - A **Cosmog** floats in Spear Pillar's plaza, a gift at Lv. 5: "A little Pokémon is floating here, like a wisp of
    the night sky... It's COSMOG! It seems to want to come along with you." With a full party it waits.
  - Once the player has Solgaleo or Lunala, a second Cosmog waits there, so both can be raised.
  - **Necrozma** (Lv. 70) then stands north of it.
  - With Necrozma caught, the Archivist gives the **N-Solarizer and N-Lunarizer**, not obtainable anywhere before.
- New overworld sprites for the six. Gifts share a new common script with the party check and the nickname prompt.
- **Verified** (test build; a temporary patch set the game completed, opened the Kalos Chronicle, marked Xerneas,
  Yveltal and Solgaleo caught, made room in the party and raised it to level 100):
  - The Tapus hidden before the Alola opening.
  - The opening, the four-entry chapter menu, both Alola topics with their hints, then "You found every one!" and
    "The legends of the sky are yours!".
  - The four Tapus and Necrozma seen, caught and gone afterwards.
  - Both Cosmog gifts ("A received COSMOG!", the nickname prompt), and none after the second. "Your party is full"
    with a full party.
  - The N-Solarizer and N-Lunarizer given once.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Chronicles: Victini and the Kalos Chronicle

The rest of the Unova Chronicle and all of the Kalos Chronicle (`docs/PostgameLegendaries.md`). The owner chose
existing spots over new rooms (2026-10-23), so each legendary planned for a new room stands in a fitting existing one:
- **Victini** (Lv. 55) sits on the west side of Vista Lighthouse's top floor once the Unova Chronicle is open. The
  Archivist's Other legends topic now hints at it: "It loves a view of the sea. Try the top of Sunyshore's Vista
  Lighthouse." The lighthouse has no basement, so there's no hatch for Volkner to open.
- **The Kalos Chronicle** opens when the player talks to the Archivist with Kyurem caught: "You caught KYUREM! That was
  the last legend of the Unova Chronicle. And look what was tucked behind it: a second tome, the Kalos Chronicle!"
  He then asks "Which Chronicle shall I read from?" (Unova Chronicle, Kalos Chronicle, That's all), and each Chronicle
  has its own menu.
- **Life and Destruction**, the Kalos key (Lv. 70):
  - Xerneas in the green nook beside the Old Chateau in Eterna Forest.
  - Yveltal at the end of the Lost Tower top floor's east corridor (moved to Route 229 on 2026-10-24).
  - Zygarde (50% Forme) in an alcove of Wayward Cave B1F once both are caught.
- **Other legends:**
  - The Archivist gives the **Prison Bottle**, not obtainable anywhere before.
  - Hoopa (Lv. 55) then plays in the Solaceon Ruins' innermost room while the player carries the bottle.
  - Diancie (Lv. 55) appears by Oreburgh Mine B2F's west wall to a player with a Carbink in the party. Carbink is wild
    outside Stark Mountain.
  - Volcanion (Lv. 60) stands at the end of the long east tunnel in Stark Mountain's first cave (moved to room 2's
    north-east dead end on 2026-10-24).
- New overworld sprites for all seven. Wayward Cave B1F gets its own script archives (it had `scripts_empty`).
  Xerneas shares Eterna Forest with Virizion, so it has its own hidden flag. Each one's script also notes itself so a
  knock-out removes the right one.
- **Verified** (test build; a temporary patch set the game completed, opened the Unova Chronicle, marked Kyurem caught,
  put a Carbink in the party and raised the party to level 100):
  - Xerneas, Hoopa and Zygarde hidden before their conditions held.
  - The Kalos opening, the chapter menu, both Kalos topics (the Prison Bottle given), Unova's Other legends with the
    Victini hint, and "That's all" in each menu.
  - All seven seen, caught with a Master Ball and gone afterwards.
  - The Zygarde hint once Xerneas and Yveltal were caught, then "You found all three!".
  - Xerneas and Virizion each knocked out and each vanishing alone. A first version took the battled species from a
    special var, which OnLoad can't read after a battle, and always removed Virizion; a map-local var fixed it.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Chronicles: the Archivist's menu

The Legend Archivist's talk had grown to about 45 pages on a fresh post-game save. After his first talk, he now asks
"Which legend of the Unova Chronicle shall I read to you?" with a menu:
- **Swords of Justice:** where each sword not caught yet stands, then Keldeo.
- **Truth and Ideals:** the Light and Dark Stones the first time, a hint per dragon, then Kyurem and the DNA Splicers.
- **Forces of Nature:** the release of Tornadus and Thundurus the first time, then their hint, the Reveal Glass,
  Landorus and Enamorus.
- **Other legends:** Meloetta and Genesect.
- **That's all:** "I'll keep reading the Unova Chronicle."

After each topic he asks "Anything else from the Chronicle?" and the menu comes back. A topic that's finished says so,
for example "RESHIRAM, ZEKROM and KYUREM... You found all three dragons!". The key items and the release come from
their topic, so a player gets them by asking.
- **Verified** (test build; a temporary patch set the game completed and opened the Chronicle): each topic from the
  menu, the menu coming back after each, the stones given once only (Truth and Ideals asked twice), and "That's all".
  The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Chronicles: Forces of Nature (Tornadus, Thundurus, Landorus and Enamorus)

The Unova Chronicle's Forces of Nature (`docs/PostgameLegendaries.md`):
- **Tornadus and Thundurus** (Lv. 65) roam Sinnoh, like Mesprit and the legendary birds.
  - The Archivist releases them: "The Chronicle also tells of TORNADUS and THUNDURUS, who ride the clouds. Have you
    felt the wild winds and the storms lately? They must be here! They never stay in one place."
  - Later talks: "TORNADUS and THUNDURUS roam all over Sinnoh. A Pokétch's Marking Map can show you where they are."
  - One that's knocked out comes back after the next Hall of Fame: "If one was knocked out, it may come back after
    your next Hall of Fame." The Archivist then releases it again.
- With both caught, he gives the **Reveal Glass** ("this REVEAL GLASS shows their true forms"), which was not
  obtainable anywhere before. Then: "Take TORNADUS and THUNDURUS to the ruins on Route 228, and see!"
- **Landorus** (Lv. 65) appears in Route 228's ruins (the Rock Peak Ruins chamber) while both are in the party (moved to Route 228's sand field on 2026-10-24).
  - The design asked for a new shrine; the existing chamber stands in.
  - The chamber had no scripts of its own and now has its own script archives.
- **Enamorus** (Lv. 65) then waits by the tablet at the north end of Route 224, the Flower Paradise gate.
- **Save:** two more roaming slots. The special-encounter save block grows by 42 bytes, and the save still fits its
  32 sectors (block 0 is 0xCEE4 of 0xD000 bytes, measured in the test build).
- New overworld sprites for Landorus and Enamorus.
- **Verified** (test build; a temporary patch set the game completed, opened the Chronicle, added Master Balls,
  raised the party to level 100, made every grass encounter a roamer one while any is active, put Tornadus and
  Thundurus in the party at one warp, and added test warps):
  - the Archivist releasing them, then the Reveal Glass and the Landorus hint once both were caught;
  - Thundurus and Tornadus met on Route 202 and caught with a Master Ball;
  - Landorus hidden without the two in the party, shown with them, caught, and gone afterwards;
  - Enamorus hidden before Landorus was caught, shown after, caught, and gone afterwards;
  - the Archivist with all four caught: no Forces of Nature lines.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## Item 11 (part 26) — Telekinesis

- **Telekinesis:** for 3 turns the target is lifted: Ground moves miss it, it isn't grounded (terrains, Arena Trap,
  Spikes), and moves other than one-hit KOs always hit it.
  - Fails under Gravity, or on a target that is rooted, smacked down or already lifted.
  - Counts down at the end of each turn ("{0} was freed from the telekinesis!").
  - New field `sovereignTelekinesis[4]`, a script variable, effect 332 and two subscripts.
  - The Ground miss reuses Magnet Rise's message ("...evades Ground moves with electromagnetism").
- Move checklist: exact 257, approximate 39, placeholder 84.

**Verified in the test build:** Garchomp's Telekinesis gave "The foe's VENUSAUR was hurled into the air!". Turtwig's
Mud-Slap then missed it.

## Item 11 (part 25) — Magic Room, Wonder Room

- **Magic Room:** for 5 turns no held item has any effect (`Battler_HeldItem` returns nothing). Using it again ends it.
- **Wonder Room:** for 5 turns the target's Defense and Sp. Def stats are swapped in the damage calc; stages stay
  put. Using it again ends it.
- Both count down at the end of each turn, with their own end messages (new field-condition state, new fields
  `sovereignMagicRoomTurns` and `sovereignWonderRoomTurns`, script variables, effects 330 and 331).
- Some newer items read the held item directly (Booster Energy, the terrain seeds, Punching Glove, Protective Pads),
  so Magic Room doesn't stop them yet.
- Move checklist: exact 256, approximate 39, placeholder 85.

**Verified in the test build:** the foe Venusaur's Wonder Room gave its message. Garchomp's physical Dragon Claw then
went against Venusaur's Sp. Def (236 instead of 202): 22 damage before the random factor, down from 29. Magic Room
isn't tested in game yet.

## Item 11 (part 24) — Bestow, Belch

- **Bestow:** gives the user's held item to a target holding none ("{0} obtained one {1}.").
  - Fails if the user holds nothing, the target holds an item, or the item sets the user's form (Mega Stones, Orbs...,
    `Battler_SovereignHeldItemLocked`).
  - New effect `SOVEREIGN_BESTOW` (329).
- **Belch:** fails unless the user has eaten a Berry this battle. A Berry used up through `RemoveItem` is recorded
  per party slot (new field `sovereignAteBerry`). In the games Belch can't be selected at all; here it fails.
  Berries eaten through Bug Bite or Pluck don't count yet.
- Move checklist: exact 254, approximate 39, placeholder 87.

**Verified in the test build:** the foe Charizard's Bestow gave Turtwig its Leftovers ("TURTWIG obtained one
Leftovers."). The foe Venusaur's Belch, with no Berry eaten, gave "But it failed!".

## Item 11 (part 23) — Parting Shot

- **Parting Shot:** lowers the target's Attack and Sp. Atk by 1 stage, then the user switches out as after U-turn.
  If the stats can't be lowered, the user stays in (Gen VII+).
  - New effect `SOVEREIGN_PARTING_SHOT` (328), whose subscript runs Noble Roar's stat drop, then U-turn's switch-out.
- Move checklist: exact 253, approximate 38, placeholder 89.

**Verified in the test build:** Garchomp's Parting Shot lowered Venusaur's Attack and Sp. Atk. "GARCHOMP went back to
A!" followed and the party list opened.

## Item 11 (part 22) — Scale Shot, Coaching, Dragon Cheer

- **Scale Shot:** hits 2–5 times; after the last hit ("Hit N time(s)!") the user's Defense falls 1 stage and its
  Speed rises 1 stage. Done in the multi-hit loop.
- **Coaching:** raises the Attack and Defense of the user's ally by 1 stage; fails without one. New effect
  `SOVEREIGN_COACHING` (326).
- **Dragon Cheer:** gives the user's ally +1 critical-hit stage (+2 for a Dragon type) until it leaves battle. Fails
  without an ally, or if the ally is already cheered.
  - New effect `SOVEREIGN_DRAGON_CHEER` (327).
  - New `BattleContext` field `sovereignDragonCheer[4]` and script variable
    `BTLVAR_SOVEREIGN_DRAGON_CHEER_SIDE_EFFECT_MON`.
- Move checklist: exact 252, approximate 39, placeholder 89.

**Verified in the test build:** the foe Venusaur's Dragon Cheer gave "The foe's CHARIZARD is getting pumped!". Garchomp's
Scale Shot hit 3 times, then its Defense fell and its Speed rose. Turtwig's Coaching then raised Garchomp's Attack and
Defense, ending at Attack +1, Speed +1, Defense 0.
## E11 — The Chronicles: Truth and Ideals (Reshiram, Zekrom and Kyurem)

The Unova Chronicle's key chapter (`docs/PostgameLegendaries.md`):
- **The Archivist** now goes on: "The Chronicle ends with two dragons, RESHIRAM and ZEKROM. They say each one sleeps
  in a stone until a hero wakes it. These two stones came with the Chronicle. Please, take them."
  - He gives the **Light Stone** and the **Dark Stone**, then a hint for each dragon not caught yet:
    - "RESHIRAM: the LIGHT STONE is warm, like a fire. Try Fuego Ironworks."
    - "ZEKROM: the DARK STONE crackles. Try the Valley Windworks, at night."
  - With both caught: "The Chronicle tells of a third dragon, KYUREM, left empty when they split. It sleeps in the
    ice. Try the icy chamber in Mt. Coronet by Route 216."
  - With Kyurem caught, he gives the **DNA Splicers**: "The Chronicle says it can join with RESHIRAM or ZEKROM."
- **Reshiram** (Lv. 70) stands by the furnaces of Fuego Ironworks while the player carries the Light Stone: "The
  LIGHT STONE is glowing with heat!" The design asked for a new furnace room; the Ironworks' own works instead.
- **Zekrom** (Lv. 70) stands on Valley Windworks' windmill island at night (8 pm to 4 am) while the player carries
  the Dark Stone: "The DARK STONE is crackling with electricity!" Getting there needs Surf.
- **Kyurem** (Lv. 70) sleeps in Mt. Coronet's ice chamber (off the room by Route 216) once Reshiram and Zekrom are both
  caught. The chamber had no scripts of its own and now has its own script archives.
- New overworld sprites for all three.
- **Verified** (test build; a temporary patch set the game completed, opened the Chronicle, added Master Balls,
  raised the party to level 100, forced night from one warp on and added test warps):
  - the Archivist's stones, the two hints, the Kyurem hint and the DNA Splicers;
  - Reshiram shown with the Light Stone, its line, caught, and gone afterwards;
  - Zekrom hidden in the daytime and shown at night, its line, caught, and gone afterwards;
  - Kyurem hidden while Zekrom wasn't caught, shown once both were, caught, and gone afterwards.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## Item 11 (part 21) — Final Gambit, Synchronoise, Upper Hand

- **Final Gambit:** deals damage equal to the user's HP. If it hits, the user faints, through a new on-hit side
  effect, so a miss or a Ghost-type target leaves it standing. New effect `SOVEREIGN_FINAL_GAMBIT` (325) and
  subscript.
- **Synchronoise:** has no effect on targets that share no type with the user.
- **Upper Hand:** fails unless the target is about to use a damaging priority move; otherwise it hits and makes the
  target flinch (`FLINCH_HIT`, 100%).
- Move checklist: exact 249, approximate 41, placeholder 90.

**Verified in the test build:** Garchomp's Final Gambit took 171 HP off Venusaur (Garchomp's HP), then "GARCHOMP
fainted!". Synchronoise and Upper Hand aren't tested in game yet.

## Item 11 (part 20) — contact abilities: Mummy, Lingering Aroma, Wandering Spirit, Perish Body, Toxic Debris

- **Mummy / Lingering Aroma:** an attacker that makes contact gets the holder's ability ("{0} acquired Mummy!").
- **Wandering Spirit:** swaps abilities with an attacker that makes contact, if the holder is still standing.
- These three can't overwrite or take the form and signature abilities (new `Sovereign_AbilityIsFixed`: Multitype,
  Stance Change, Schooling, Disguise, Zen Mode and others).
- **Perish Body:** contact gives the holder and the attacker a Perish Song count of 3 ("Both Pokémon will faint in
  three turns!").
- **Toxic Debris:** a physical hit scatters a layer of Toxic Spikes on the attacker's side (up to 2).
- Ability checklist: 136 newer abilities implemented.

**Verified in the test build:** Garchomp's Dragon Claw on a Mummy Venusaur gave "GARCHOMP acquired Mummy!", and
Garchomp's ability became Mummy. The other four aren't tested in game yet.

## Item 11 (part 19) — the last Mega abilities and Healer

Every Mega and Primal now gets its own ability. The six from Pokémon Champions were checked on Bulbapedia, Serebii,
Wikidex and Rotom Labs.
- **Piercing Drill** (Mega Excadrill): contact moves go through Protect and the guard moves at 1/4 damage (applied
  when the hit's HP change is set).
- **Spicy Spray** (Mega Scovillain): any damaging move that hits the holder burns the attacker, even if the hit
  knocks the holder out.
- **Fire Mane** (Mega Pyroar): Fire moves ×1.5.
- **Aura Guard** (Mega Lucario Z): contact damage taken halved.
- **Mega Sol** (Mega Meganium): its moves work as in harsh sunlight: Fire ×1.5, Water ×0.5, and Solar Beam needs no
  charge turn. Weather Ball, Growth and Synthesis are not done yet.
- **Eelevate** (Mega Eelektross): Levitate (Ground immunity, hazards, Gravity, Smack Down, Magnet Rise), and a
  knockout raises its highest stat like Beast Boost. Only one source describes this ability; recheck against
  official data.
- **Healer** (Mega Audino): 30% chance at the end of each turn to cure its ally's status, with a new message
  "{2} was cured by {0}'s Healer!".
- `gen_mega_doc.py` now says when every Mega ability is implemented. Ability checklist: 131 newer abilities.

**Verified in the test build:** Venusaur (Spicy Spray) used Protect. Garchomp's Piercing Drill Dragon Claw went
through for 10 damage (a quarter of the 40 crit), then "The foe's VENUSAUR's Spicy Spray burned GARCHOMP!". The
others aren't tested in game yet.

## Item 11 (part 18) — Parental Bond, Berserk, Anger Shell, Innards Out

- **Parental Bond:** single-target damaging moves hit twice ("Hit 2 time(s)!") through the multi-hit loop. The
  second hit does 1/4 damage.
  - Not for status, spread, multi-hit, charging, fixed-damage or self-KO moves, Fling, Uproar, recharge moves, Final
    Gambit or Sky Drop.
  - Mega Kangaskhan now gets it, Mega Drampa gets Berserk and Mega Victreebel Innards Out (`gen_forms.py`).
- **Berserk / Anger Shell:** when a hit drops the holder from above half HP to half or less:
  - Berserk raises Sp. Atk by 1;
  - Anger Shell raises Attack, Sp. Atk and Speed and lowers Defense and Sp. Def by 1.
- **Innards Out:** when a hit knocks the holder out, the attacker loses as much HP as the holder had left.
- New `BattleContext` fields `sovereignParentalBond` and `sovereignHPBeforeHit[4]` (each battler's HP before the last
  hit it took).
- Ability checklist: 124 newer abilities implemented.

**Verified in the test build:**
- With Parental Bond, Garchomp's Dragon Claw hit Venusaur twice, for 40 then 9 damage (both crits; the second is a
  quarter), then "Hit 2 time(s)!".
- A Lv. 40 Berserk Venusaur hit from 126 to 35 HP rose to Sp. Atk +1.
- Anger Shell and Innards Out aren't tested in game yet.

## Item 11 (part 17) — primal weathers, Megas get their implemented abilities, more abilities

- **Primordial Sea / Desolate Land / Delta Stream:** heavy rain, extremely harsh sunlight or strong winds while the
  holder is in battle.
  - Damaging Fire moves fizzle out in heavy rain; Water moves evaporate in the harsh sunlight, each with its own message.
  - Strong winds: no move is super effective against the Flying type.
  - While one is up, weather moves fail and Drizzle, Drought, Sand Stream, Snow Warning and Sand Spit do nothing. A new
    primal weather replaces another.
  - It ends with a message once no Pokémon with the ability is left (new switch-in state). New field conditions
    `FIELD_CONDITION_SOVEREIGN_PRIMAL` (bit 27) and `_STRONG_WINDS` (bit 28).
- **Megas and Primals get their own ability when the engine has it**: `gen_forms.py` now asks
  `gen_abilities.IMPLEMENTED` instead of "is it a Gen IV ability". 37 Mega and Primal forms changed. Examples: Primal
  Kyogre and Groudon, Mega Rayquaza, Mega Absol (Magic Bounce), Mega Charizard X and Mega Metagross (Tough Claws),
  Mega Gardevoir and Mega Altaria (Pixilate), Mega Garchomp (Sand Force).
  - `gen_mega_doc.py` marks only the abilities still missing. Left: Parental Bond, Aura Guard, Berserk, Eelevate, Fire
    Mane, Healer, Innards Out, Mega Sol, Piercing Drill, Spicy Spray.
- **Long Reach**, **Protective Pads**, **Punching Glove:**
  - The holder's moves don't count as contact for the target's abilities and items (new `Sovereign_MakesContact`).
  - Punching Glove does this for punching moves only, and also powers them up by 10%.
- **Battery / Power Spot:** the ally's special moves / all its moves ×1.3.
- **Stalwart / Propeller Tail** (and the move Snipe Shot): ignore Follow Me, Lightning Rod and Storm Drain.
- **Screen Cleaner:** removes Reflect, Light Screen and Aurora Veil from both sides on entry.
- **Sand Spit:** getting hit whips up a sandstorm.
- **Corrosion:** its poisoning moves work on Poison and Steel types.
- **Stakeout:** double power against a target that switched in this turn.
- Ability checklist: 120 newer abilities implemented.

**Verified in the test build:**
- A foe Kyogre holding the Blue Orb reverted to its primal form, then "A heavy rain began to fall!".
- With Primordial Sea, Garchomp's Heat Wave gave "The Fire-type attack fizzled out in the heavy rain!" and dealt no
  damage.
- The other abilities in this part aren't tested in game yet.

## Item 11 (part 16) — abilities: Mold Breaker family, Protean, Magic Bounce and more

- **Turboblaze, Teravolt:** work as Mold Breaker (new `Sovereign_IsMoldBreaker`, used everywhere Mold Breaker was
  checked, the AI included), and announce themselves on entry. **Mycelium Might:** the holder's status moves ignore
  abilities (moving last in its priority bracket is not done yet).
- **Victory Star:** accuracy ×1.1 for the holder and its ally. **Mind's Eye:** Normal and Fighting moves hit Ghost
  types, the target's raised evasion is ignored, and the holder's accuracy can't be lowered.
- **Supreme Overlord:** 10% more power for each fainted party member, up to 5.
- **Steam Engine:** a Fire or Water hit raises the holder's Speed 6 stages. **Seed Sower:** getting hit sets Grassy
  Terrain.
- **Unseen Fist:** contact moves go through Protect and the guard moves. **Good as Gold:** immune to other Pokémon's
  status moves aimed at it.
- **Protean, Libero:** before its move, the user becomes the move's type ("made it the Fire type!"), once per
  switch-in (new try-move state).
- **Intrepid Sword, Dauntless Shield:** Attack / Defense +1 the first time the holder enters the battle (Gen IX's once
  per battle, kept per party slot).
- **Magic Bounce:** reflects status moves aimed at the holder, like Magic Coat, every turn; a reflected move isn't
  reflected again. New message "...was bounced back by Magic Bounce!".
- **Fix:** Transform copied only the low byte of the (now 16-bit) ability.
- Ability checklist: 108 newer abilities implemented (was 93).

**Verified in the test build:** Turtwig's Intrepid Sword message on entry; Garchomp's Protean made it Fire/Fire before
Heat Wave; Heat Wave raised Venusaur's Speed 6 stages through Steam Engine; Charizard's Magic Bounce sent Turtwig's
Growl back and Turtwig's Attack fell. The others in this part aren't tested in game yet.
## E11 — The Chronicles: Meloetta and Genesect

Two more Unova Chronicle legendaries (`docs/PostgameLegendaries.md`), each started by an NPC:
- **Meloetta** (Lv. 55), the Relic Song. A new composer stands in the Contest Hall lobby.
  - Before the Chronicle opens: "I write the music for the Contests. Lately an old melody keeps running through my
    head."
  - After: "The Unova Chronicle? Then you've read of the Relic Song!... I've written the melody down, but it needs a
    voice that can Sing."
  - With a party Pokémon that knows Sing: "Oh! Your STARLY knows Sing! Will it sing the Relic Song?" On yes, its cry
    plays, then "...Did you hear that? Something sang back, from the stage!"
  - Meloetta then stands on the Contest Hall's stage until it's caught.
  - The design placed it at Amity Square's stage. Amity Square has no stage the player can reach, and only lets in
    players leading certain Pokémon, so it moved to the Contest Hall's stage.
  - It comes in its Aria Forme.
- **Genesect** (Lv. 60). Once the Chronicle is open, the male scientist in the Galactic HQ lab confesses: "Before our
  team fell apart, we found a fossil from a faraway land. We brought it back to life in one of these tanks, and we
  changed it... Last night it broke out of its tank. It's in the back room now."
  - Genesect stands in the lab's back room, by the Control Room door, until it's caught.
  - The scientist thanks the player afterwards.
- **The Archivist** adds a hint for each of the two while they aren't caught:
  - "The Chronicle also tells of MELOETTA, a Pokémon of song. A composer at Hearthome's Contest Hall may know its
    melody."
  - "And of GENESECT, an ancient Pokémon that people brought back and changed. They say Team Galactic tried that too,
    in their Veilstone lab."
- New overworld sprites for both, made by `tools/sprites/make_legendary_overworld.py`.
- **Verified** (test build; a temporary patch set the game completed, opened the Chronicle, added Master Balls,
  raised the party to level 100, taught Starly Sing at one warp, kept the scientist in place and added test warps):
  - the Archivist's hints, and later his talk without them once both were caught;
  - the composer without Sing, then the question with Sing, answering no and then yes;
  - Meloetta hidden before the song and shown after, caught, and the stage empty afterwards;
  - Genesect hidden before the confession and shown after it, caught, and the room empty afterwards;
  - the scientist's and the composer's lines once their Pokémon is caught.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Chronicles: Terrakion, Cobalion and Keldeo

The rest of the Swords of Justice, and the young sword (`docs/PostgameLegendaries.md`):
- **Terrakion** (Lv. 65) stands in the rock pocket at the north end of Route 227, once the Unova Chronicle is open.
- **Cobalion** (Lv. 65) stands in the top pocket of Iron Island B2F's right room, the side cave reached from B1F.
- **Keldeo** (Lv. 55) waits in the clearing on Lake Valor's north-west shore, but only while Cobalion, Terrakion and
  Virizion are all in the party. It comes in its Ordinary Form.
- All four work like Virizion: "{species} cried out!", the battle, and after a win "{species} vanished... It might
  show itself here again." until it's caught. The player can't run from these battles, as in vanilla's legendary
  battles ("Can't escape!"). The entry below said a run makes Virizion vanish; that was wrong and is corrected.
- **The Archivist's later talks** now list where each sword not caught yet stands:
  - "The Chronicle names all three swords: COBALION, TERRAKION and VIRIZION. They never stray far from each other,
    and now all three are here in Sinnoh. Here's where they've been seen:"
  - "COBALION: deep inside Iron Island, in a side cave two floors down."
  - "TERRAKION: in a hollow among the rocks at the north end of Route 227."
  - "VIRIZION: in the north of Eterna Forest, by the Old Chateau."
  - With all three caught: "The Chronicle tells of a fourth one, a young Pokémon named KELDEO... They say it comes to
    the water when the three swords are near. Lake Valor, perhaps? Go there with COBALION, TERRAKION and VIRIZION."
  - With Keldeo caught: "KELDEO too! All four swords of Unova, here in Sinnoh... There's more in this Chronicle."
- Iron Island B2F's right room had no scripts of its own. It now has its own script archives, added at the end of the
  archive list so no other map's scripts move.
- Fixed a comment in the common scripts: the Totem trial's description had ended up above the legendary encounter.
- **Verified** (test build; a temporary patch set the game completed, opened the Chronicle, added Master Balls,
  raised the party to level 100 and added test warps):
  - The Archivist's list with no sword caught, then without Terrakion once it was caught.
  - Terrakion and Cobalion on the map; a Master Ball catch of each, and the maps empty afterwards.
  - Cobalion knocked out: the vanished line, the room empty, Cobalion back on the next visit. A run attempt gets
    "Can't escape!".
  - Lake Valor without the three swords in the party: no Keldeo. With them: Keldeo there, then caught.
  - The Archivist's Keldeo hint and his line once Keldeo is caught.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Chronicles begin: the Legend Archivist and Virizion

The first part of the post-game legendaries (`docs/PostgameLegendaries.md`):
- **The Legend Archivist** stands in Canalave Library 2F from the first Hall of Fame. His first talk opens the Unova
  Chronicle: "Since your Hall of Fame entry, people have reported Pokémon never before recorded in Sinnoh... Its
  legends tell of three Pokémon who stood together like swords. And now one of them, VIRIZION, has been seen in
  northern Eterna Forest." Later talks give the hint again, then "You found VIRIZION!..." once it's caught.
- **Virizion** (Lv. 65) stands at the top of Eterna Forest's north corridor, past the Cut trees, once the Chronicle
  is open.
  - Talking to it: "VIRIZION cried out!", then the battle.
  - After a win: "VIRIZION vanished... It might show itself here again." It is back on the next visit, until it's
    caught. (The player can't run from it: see the entry above.)
- **For the rest of the Chronicles:** a shared encounter script, a script command that checks the Pokédex for a
  caught species (so no flag is needed per Pokémon), and overworld sprites made from PokeAPI's front sprites by
  `tools/sprites/make_legendary_overworld.py`. Cobalion, Terrakion and Keldeo are drawn already.
  `make_totem_overworld.py` gained an `aura` switch; the Totem sprites come out byte for byte the same.
- `docs/PostgameLegendaries.md` now shows what is built.
- **Verified** (test build; a temporary patch set the game completed and added Master Balls, with test warps):
  - Virizion hidden before the Chronicle opens, the Archivist's lines, then Virizion in the forest.
  - The vanished line (gone, and back on the next visit), and a Master Ball catch.
  - After the catch, the Archivist's new line and the forest empty.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## E11 — The Sovereign along the main story: the museum, Rowan, the Celestic elder and the library (decision 23)

The early and mid-game references to the Sovereign (`docs/Story.md`, "Story beats"). The player learns about them
passively:
- **Oreburgh Mining Museum:** a new exhibit under the window, a stone fragment (Mt. Coronet's cave-painting shards).
  "A stone fragment found deep inside the Oreburgh Mine. A crown is carved into it, and words are cut beneath the
  crown: “The Sovereign keep the seams.” The card says no one knows what the words mean."
- **Professor Rowan,** right after he gives the Pokédex: "One more thing. Of late, Pokémon never recorded in Sinnoh
  have been turning up here. I can't explain where they're coming from. Not yet, at any rate. Your Pokédex will
  record them too. Every last one of them."
- **The Celestic elder,** after Cyrus leaves the ruins: "Long ago, they say, rulers sat at the Spear Pillar and
  watched over it all. Who they were, and where they went, not even this old town remembers."
- **Canalave Library 3F:** a new book, "The Sovereign", on the myth shelf. "Most of the pages have been torn out.
  “...sat upon the Spear Pillar...” “...and the Sovereign kept the seams of Sinnoh, that it would not...” “...when
  the last of the line grew old, the crown was to pass to...” The rest of the book is missing." It takes one tile of
  the "Sinnoh Region's Mythology" shelf, which keeps the other.
- **Still to do:** the Spear Pillar throne glimpse, which needs a map change and comes with the throne room.
- **Verified** (test build, with temporary test warps): the exhibit and the book read in full, with every line inside
  the box. Rowan's and the elder's lines are checked against the box width; their scenes are vanilla and come later
  in a new game. The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## E11 — After the Hall of Fame: the elder at home, the rematch lock and the Sovereign Crown (decision 23)

The first three steps of the post-game story (`docs/Story.md`, "After the Hall of Fame: event order"):
- **The Celestic elder at home.** The first time the player comes downstairs after the first Hall of Fame, the
  elder is in the living room with Mom: "You have a visitor. She came all the way from Celestic Town to see you."
  - She walks up, says Mt. Coronet has been restless since the battle at the Spear Pillar, and reads the shrine's
    book: the bearers of the Adamant Orb and the Lustrous Orb summon DIALGA and PALKIA there.
  - She says both Orbs rest inside Mt. Coronet, then leaves through the door. Mom's Platinum line about the rival
    follows.
  - This replaces her Celestic house as the place that opens the Spear Pillar's Dialga and Palkia; her house still
    does it too.
- **The Elite Four rematch waits on Dialga and Palkia.** Platinum has no NPC who asks you to save, so the north
  Pokémon Center's door guard is the gate. After the first Hall of Fame he stays at the door until both encounters
  are done (caught, or the battle won or fled): "I'm sorry, but the Elite Four aren't taking challengers right now. Mt.
  Coronet has been shaking ever since your Hall of Fame entry. They say DIALGA and PALKIA are stirring at the Spear
  Pillar. Please see to them first." Once both are done it stays open for good, even after the Hall of Fame brings an
  uncaught one back.
- **The Sovereign Crown.** After the first rematch win over Cynthia, the Crown becomes the Sovereign Crown:
  - "Cynthia: ...Hm? There's a light coming from your Bag." "The Crown is shining brightly!" Then the player
    obtains the Sovereign Crown.
  - Cynthia: "A crown made from the pieces those huge Pokémon left behind... My grandmother tells old stories of the
    ancient rulers of the Spear Pillar. I think someone has been waiting for you there all along. After the Hall of
    Fame, please go to the Spear Pillar."
  - Later wins get a short reminder until the Sovereign is beaten. Henry's appearance at the throne comes later.
- **Verified** (test build, with a temporary new-game patch for the post-game state: the game completed, the house
  states after the first Hall of Fame, the Crown and both Orbs; Cynthia's battle skipped, and test warps):
  - The elder's whole scene, every line inside the box, and Mom's line after it.
  - Mt. Coronet 6F then leads to the Spear Pillar's Dialga map (its blue rift).
  - With Dialga and Palkia not done, the guard blocks the door with his line. With both done, he stands aside and
    the elevator to Aaron opens.
  - The rematch win: the Crown swap, Cynthia's lines, then the lift and the hallway to the Hall of Fame as before.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — 1 vs 2: a lone Pokémon takes on a Totem trial (decision 18)

A player with only one Pokémon that can battle now fights a Totem trial 1 vs 2. Before, the trial refused with "Its
aura is overwhelming! You'll need two Pokémon that can battle to stand against it." That message is gone.
- **The battle.** "Go! GARCHOMP!" sends out the one Pokémon. The second slot stays empty all battle, as if its
  Pokémon had fainted with none left to replace it: no sprite, no HP bar, greyed out on the target screen, and the
  turn asks only "What will GARCHOMP do?".
- **The engine.** The empty slot takes the state Platinum already uses for a doubles slot whose Pokémon fainted with
  no replacement, so every later check works unchanged (`TechnicalDesign.md`, Totem trials, "1 vs 2"). The intro, the
  trainer's ball throw and the "Go!" line skip it.
- **Trainer double battles** get it too: the same code runs for any plain double battle. That is what the Elite Four's
  "doubles with one healthy Pokémon" rule needs (`EliteFourFormat.md`). Platinum's own double-battle trainers still
  check for two Pokémon first, as before.
- **Verified** (test build, with the other five party members at 0 HP for the test):
  - Totem Gumshoos from SELECT+B+R: "Go! GARCHOMP!", a helper called after Yungoos fainted, Mega toggle shown, a win.
  - The target screen greys out the empty slot. The party menu shows GARCHOMP alone able to battle, and choosing a
    fainted one says it has no energy left. The bag opens.
  - Spread moves (Electroweb) and single-target moves on either foe.
  - Totem Gumshoos on Route 205 South, from the map: a 1 vs 2 win with the Totem gone afterwards, and (GARCHOMP at
    1 HP) a loss: "A is out of usable Pokémon!", the blackout, and Mom's welcome home.
  - The test trainer's double battle: "Go! GARCHOMP!", the foe's Mega Charizard Y and Venusaur both acted, GARCHOMP
    fainted, and the battle ended.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.
## Item 11 (part 15) — trapping hits, ability moves, stat swaps, Clear Smog, Incinerate

- **Spirit Shackle, Anchor Shot:** after the hit the target can't escape while the user is in battle (as Mean Look).
- **Revelation Dance** takes the user's primary type; **Psyshield Bash** raises the user's Defense by 1.
- **Simple Beam / Entrainment:** the target's ability becomes Simple / the user's (Worry Seed's rules, plus Gen IX's list
  of abilities Entrainment can't pass on).
- **Guard Split / Power Split / Speed Swap:** the user and target average their Defense and Sp. Def / Attack and Sp. Atk,
  or swap Speed.
- **Clear Smog:** after the hit the target's stat stages are reset. **Incinerate:** after the hit the target's Berry
  is burnt up (new read-only script variable `BTLVAR_SOVEREIGN_SIDE_EFFECT_MON_HOLDS_BERRY`).
- **Aurora Veil:** only in snow; halves physical and special damage to the user's side for 5 turns (8 with Light Clay),
  without stacking with Reflect and Light Screen; Brick Break breaks it (new side condition and turn counter).
- **Sticky Web:** grounded Pokémon switching in on the foes' side lose 1 Speed stage (Magic Guard doesn't stop it;
  Clear Body does); Rapid Spin clears it.
- **Echoed Voice:** 40 more power for each consecutive turn it's used (by any Pokémon), up to 200.
- **Fell Stinger:** the user's Attack rises 3 stages if it knocks out the target (new after-hit case beside Moxie).
- Move checklist: exact 246, approximate 42, placeholder 92.

**Verified in the test build:** Venusaur, using Swords Dance each turn, ended at Attack stage 0 because Garchomp's
Clear Smog hit it each turn. After Archaludon's Snowscape, Venusaur's Aurora Veil cut Garchomp's Tackle from 14 to 10
(the doubles screen value). Archaludon's Fell Stinger knocked out Turtwig and left it at Attack +3. The other moves
in this part (Sticky Web, Echoed Voice's streak) aren't tested in game yet.

## E11 — The Galactic gates wait on the Totem trials (decision 23)

Each Team Galactic encounter now waits on the Totem trials placed before it (`docs/Story.md`, the table under
"Galactic encounters wait on the trials"). Each blocker's line points the player to the open trials.
- **Commander Mars (Valley Windworks) ← Gumshoos.** The grunt at the door won't battle: "W-what? A battle? Not now!
  There's a huge GUMSHOOS glaring at me from the flowers by the river!"
- **Commander Jupiter (Eterna Building) ← Ribombee, Vikavolt.** A new grunt guards the door (305, 520), behind the
  Cut trees, until both are done. His hidden flag is `FLAG_MAP_LOCAL_HIDE_TRIAL_GATE` (the unused map-local 0x3F),
  set by Eterna City's OnTransition.
- **Cyrus (Celestic ruins) ← Mimikyu, Marowak, Raticate, Lurantis, Araquanid.** The grunt in front of the ruins
  won't battle, and names the five places.
- **Saturn and Mars (the lakes) ← Salazzle.**
  - The Route 218 blockade now leaves once Salazzle's trial is done (Route 218's new OnTransition), not when Cynthia
    speaks after Cyrus.
  - After Cyrus, the Guitarist explains that a huge SALAZZLE chased them out of their practice spot at the Fuego
    Ironworks.
  - Canalave, and so Barry, Byron and the lakes, wait on it.
- **Mars and Jupiter (Spear Pillar) ← Kommo-o.** The grunts' coord event sends the player back with a new line, like
  their one-Pokémon refusal.
- **Victory Road ← Togedemaru.** Platinum has no check at the entrance, so a new guard stands in front of the middle
  warp (851, 598), with a coord event on the tiles beside him.
  - He checks all eight Badges, then Togedemaru's trial, and steps the player back if either is missing.
  - The coord event's var is `VAR_MAP_LOCAL_0x00`, so the check runs again on every visit.
- **Verified in the test build**, with temporary warps to each gate:
  - With no trials done (and Cyrus beaten, for the Guitarist's new line): every blocker says its line, and the
    Spear Pillar grunts and the Victory Road guard step the player back.
  - With all 11 trials done and eight Badges: the Windworks and Celestic grunts are back to Platinum's lines; the
    Eterna door grunt and the Route 218 blockade are gone; the Spear Pillar grunts start their usual scene; and the
    player walks into Victory Road.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — The last six Totems on the map (decision 18)

All 11 Totems now stand on the map (`docs/TotemTrials.md`, "On the map"). Each appears once the fight before its
trial is won, like the four before.
- **Totem Alolan Raticate**, the Galactic Warehouse (Veilstone): in the lower hall (x 13, z 10). It shows with the
  Relic Badge once Looker has found HM02 there, so it stays out of his scene.
- **Totem Lurantis**, Great Marsh Area 3: at the edge of the marsh grass (x 54, z 84), with the Cobble Badge.
  - It's reached in a Safari Game. The trial is a normal battle with the player's own Pokémon.
  - Area 3's OnTransition was Platinum's Safari tram script. It's now the map's own, which hides or shows the Totem
    and then runs `InitGreatMarshTram`, as the old one did.
  - **A loss in a Safari Game.** A blackout doesn't end the game, so the player would wake up at home with Safari
    battles still on. The trial's loss branch now clears `FLAG_SAFARI_GAME_ACTIVE` and the gate's state.
    `EndSafariGame` itself can't be used there: it records the game for TV and the journal, and with no field loaded
    after a lost battle that hangs the game.
- **Totem Araquanid**, Route 213: on the beach below the hotel (x 713, z 826), with the Fen Badge.
- **Totem Salazzle**, Fuego Ironworks: north of the yard (x 181, z 585), once Cyrus is beaten at Celestic Town. The
  Ironworks can be walked to from Route 205 after Mars.
- **Totem Kommo-o**, Mt. Coronet 6F: beside the path to Spear Pillar (x 5, z 13), once Saturn is beaten at the
  Galactic HQ. It stands out of the Galactic grunt's line of sight, and 5F has no script file of its own.
- **Totem Togedemaru**, Vista Lighthouse: on the top floor (x 10, z 7), once Cyrus is beaten in the Distortion World.
- **Test build:** SELECT+L+R's stops 14 to 19 are in front of Raticate, Lurantis, Araquanid, Salazzle, Kommo-o and
  Togedemaru.
- **Verified in the test build:**
  - In a new game, all six are hidden.
  - In a temporary build with every condition met, all six show. Kommo-o's talk works, and Togedemaru's and
    Lurantis's battles open (with Skarmory and Trumbeak).
  - **A real loss** (a temporary build that left the player's battle party at 1 HP): "A blacked out!", then home with
    Mom, the screen drawn normally. With a Safari Game running, the same, and the start menu no longer shows RETIRE.
  - The earlier loss checks (CB-0028) sent a won battle down the loss branch. That reaches home but over a black
    screen, because after a real loss the field is never reloaded before the blackout. The real-loss check replaces
    them.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.

## FM — Totems Ribombee, Vikavolt, Mimikyu and Alolan Marowak on the map (decision 18)

Five of the 11 Totems now stand on the map (`docs/TotemTrials.md`, "On the map").
- **Totem Ribombee**, Floaroma Meadow: in the flowers just past the entrance (x 18, z 43).
- **Totem Vikavolt**, Eterna Forest: in a clearing west of the path (x 22, z 68).
- **Totem Mimikyu** (Disguised), the Old Chateau: in the dining area (x 26, z 10).
- **Totem Alolan Marowak**, Lost Tower 5F: left of the stairs (x 3, z 4), in the tower's fog.
- **Each trial opens after its "After" fight.** The meadow, the chateau and the tower can be reached earlier, so
  those Totems stay hidden until then: Ribombee until Mars is beaten at the Valley Windworks, Mimikyu until Jupiter has
  left the Eterna Building, Marowak until the Relic Badge. Eterna Forest itself opens after Mars, so Vikavolt needs no
  check.
  - How: the map's OnTransition script sets `FLAG_MAP_LOCAL_HIDE_TOTEM` (the unused map-local flag 0x3E), the
    Totem's hidden flag, while the trial is done or not yet open. Map-local flags are cleared on every map change.
- **Test build:** SELECT+L+R's stops 10 to 13 are in front of Ribombee, Vikavolt, Mimikyu and Marowak.
- **Verified in the test build:**
  - In a new game, Ribombee, Mimikyu and Marowak are hidden and Vikavolt stands in the forest.
  - In temporary builds with the fight before each one won: Ribombee shows, and its trial runs through to "A found an
    Oval Emerald!" with the Totem gone afterwards. Mimikyu and Marowak show, and their trials open (Mimikyu with
    Haunter, Marowak with Salazzle).
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.
- **Not done yet:** Alolan Raticate, Lurantis, Araquanid, Salazzle, Kommo-o and Togedemaru.

## Item 11 (part 14) — Psychic Noise and Steel Beam

- **Psychic Noise:** after the hit, the target can't heal for two turns (Heal Block's message).
- **Steel Beam:** after the hit, the user loses half its max HP, rounded up (Magic Guard prevents it). "Approximate":
  in Gen IX the HP is lost even when the move misses.
- **Freeze-Dry:** super effective against Water (a per-move override of the type chart, `Sovereign_ChartMul`, used by
  the damage and effectiveness paths), and its 10% freeze chance is back.
- **Sound moves and Infiltrator get past Substitute** (Gen VI+): damage hits the Pokémon, and status and stat effects
  aren't blocked. Confide is now exact.
- Move checklist: exact 231, approximate 42, placeholder 107.

**Verified in the test build:** Garchomp fainted after its second Steel Beam (half its max HP each time). Psychic Noise,
Freeze-Dry and the Substitute bypass aren't tested in game yet.

## Item 11 (part 12) — Wide Guard, Quick Guard, Dragon Tail, Smack Down, Soak, Retaliate, Poltergeist

- **Wide Guard / Quick Guard:** protect the user's side this turn from spread moves / foes' priority moves (new side
  flags `sovereignSideGuards`, "Wide Guard protected your team!").
- **Dragon Tail, Circle Throw:** drag the target out after the hit (end a wild battle), quietly doing nothing when it
  can't (Suction Cups, Ingrain, no Pokémon to switch in).
- **Smack Down:** grounds the target until it switches out ("{0} fell straight down!" if it was airborne); grounded
  Pokémon feel terrains and Ground moves.
- **Soak:** the target becomes pure Water-type ("{0} transformed into the Water type!").
- **Retaliate:** double power if a Pokémon on the user's side fainted last turn (new `sovereignSideFaintTurn`).
- **Poltergeist:** fails against a target with no item (the item message isn't shown yet).
- `gen_stat_moves.py` adds Venom Drench (Attack, Sp. Atk and Speed −1, fails unless the target is poisoned), No Retreat
  and Clangorous Soul (all stats +1; the trapping and HP cost aren't reproduced yet, so they stay "approximate"). Shelter
  uses Iron Defense's effect. These four aren't tested in game yet.
- **Fix: Heal Pulse and Floral Healing healed the user** (they used Recover's effect). They now heal the target by 1/2;
  Heal Pulse heals 3/4 with Mega Launcher, Floral Healing 2/3 in Grassy Terrain. **Life Dew** heals the user and its ally
  by 1/4.
- **Meteor Beam:** uses Electro Shot's effect without the rain shortcut: the charge turn raises Sp. Atk ("{0} is
  overflowing with space power!", two-part animation), it attacks next turn, and a Power Herb skips the charge.
- **After You / Quash:** the target acts right after the user / last this turn ("{0} took the kind offer!", "{0}'s move
  was postponed!"); they fail against a target that has already moved.
- Move checklist: exact 228, approximate 43, placeholder 109.

**Verified in the test build:** Venusaur's Wide Guard stopped Garchomp's Hyper Voice on both foes for two turns
(Archaludon stayed at full HP). Garchomp's Heal Pulse restored the foe it targeted (Venusaur back to 302/302 between
Turtwig's Tackles). Meteor Beam charged (Sp. Atk +1) and hit next turn for 32, the +1 value. Venusaur's Quash on Turtwig printed
"TURTWIG's move was postponed!" (Turtwig already moved last, so the order didn't visibly change).

## Item 11 (part 11) — Laser Focus and Throat Chop

- **Laser Focus:** the user's moves always crit this turn and the next ("{0} concentrated intensely!").
- **Throat Chop:** the target can't use sound moves this turn and the next. They're greyed out at selection with
  Heal Block's "{0} can't use {2} because of {1}!" message, and a sound move chosen before the hit fails with it.
- New per-battler counters `sovereignLaserFocus` / `sovereignThroatChop`, which wear off at the start of each turn, and
  the subscript pointers `MOVE_SUBSCRIPT_PTR_SOVEREIGN_LASER_FOCUS` / `_THROAT_CHOP`.
- Move checklist: exact 213, approximate 46, placeholder 121.

**Verified in the test build:** after Venusaur's Throat Chop hit Garchomp, Garchomp's Hyper Voice didn't go off.

## Item 11 (part 10) — Terrains

Electric, Grassy, Misty and Psychic Terrain, as in Gen IX: 5 turns (8 with a Terrain Extender), set by the four moves or
by Electric/Grassy/Misty/Psychic Surge and Hadron Engine on entry, with start and end messages.

| Terrain | Effect on grounded Pokémon |
|---|---|
| Electric | their Electric moves ×1.3; can't fall asleep or be made drowsy |
| Grassy | their Grass moves ×1.3; heal 1/16 of max HP each turn; Earthquake, Bulldoze and Magnitude halved against them |
| Misty | Dragon moves against them halved; can't be statused or confused |
| Psychic | their Psychic moves ×1.3; foes' priority moves can't hit them |

- Moves: Rising Voltage, Expanding Force (single target), Misty Explosion, Psyblade, Terrain Pulse (type and power), Grassy
  Glide (+1 priority); Steel Roller fails without a terrain, and it and Ice Spinner remove the terrain (no message yet).
- Abilities: Quark Drive (in Electric Terrain), Surge Surfer, Grass Pelt, Hadron Engine, Orichalcum Pulse (sets sun like
  Drought, Attack ×1.33 in it).
- Implementation: one bit per terrain plus a 4-bit turn count in `fieldConditionsMask` (bits 19–26), a read-only script
  variable `BTLVAR_SOVEREIGN_TERRAIN_EFFECT_MON` for the status subscripts, and `Sovereign_TerrainUnder`.
- Terrain Seeds: the Electric and Grassy Seeds raise Defense, the Misty and Psychic Seeds Sp. Def, when their terrain
  is up (checked after every move, so a terrain set mid-turn triggers them).
- Not yet: Mimicry and the background tint.
- Move checklist: exact 211, approximate 47, placeholder 122.

**Verified in the test build:** with an Electric Surge Archaludon on the field, Garchomp's Thunder Fang dealt 26
pre-variance (the ×1.3 value; 21 without) and Venusaur's Sleep Powder put neither Garchomp nor Turtwig to sleep; a
Venusaur holding an Electric Seed ended at Defense +1 with the Seed used up.

## Item 11 (part 9) — Booster Energy and moves that read the turn

- **Booster Energy:** a Protosynthesis (outside sun) or Quark Drive Pokémon uses it on switch-in ("{0} used its
  Booster Energy!", a new battle string), and its highest stat stays boosted until it switches out.
- New per-turn flags (stats raised, stats lowered, used Round) and a per-battler "last move failed":
  - Stomping Tantrum and Temper Flare double after a failed move; Lash Out doubles after the user's stats fell this
    turn; Round doubles after its ally's Round (the ally doesn't move up in turn order yet).
  - Burning Jealousy and Alluring Voice burn / confuse only a target whose stats rose this turn.
- Draining Kiss and Oblivion Wing drain 3/4 of the damage.
- Sacred Sword, Chip Away and Darkest Lariat are now marked exact (their engine rule landed in part 6).
- Move checklist: exact 203, approximate 43, placeholder 134.

**Verified in the test build:** a Protosynthesis Archaludon and a Quark Drive Venusaur both used up their Booster
Energy at the start of the battle; Turtwig's Round after Garchomp's dealt the power-120 value (3; 2 with Tackle's
control run at power 60).

## Item 11 (part 8) — Intimidate reactions and AI scores

- Intimidate now triggers Defiant (Attack +2), Competitive (Sp. Atk +2) and Rattled (Speed +1), through a new switch-in
  step (`SWITCH_IN_CHECK_STATE_SOVEREIGN_STAT_DROP_REACTION`) that shares `Sovereign_SetupStatDropReaction` with the
  after-move Defiant step.
- Guard Dog: Intimidate raises its Attack instead. Inner Focus, Oblivious, Own Tempo and Scrappy block Intimidate (Gen
  VIII+), with Clear Body's "suppressed" message.
- AI: Clanging Scales, Hyperspace Fury and Spin Out score like Close Combat, Make It Rain like Overheat, and Storm Throw,
  Frost Breath, Wicked Blow and Flower Trick like high-critical moves.

**Verified in the test build:** an Intimidate Garchomp left a Defiant Archaludon at Attack +1 (−1 then +2) and a Guard
Dog Venusaur at Attack +1.

## Item 11 (part 7) — 44 more abilities

| Kind | Abilities |
|---|---|
| Attacker power | Tough Claws, Mega Launcher, Sharpness, Punk Rock, Transistor, Dragon's Maw, Rocky Payload, Steelworker, Water Bubble, Toxic Boost, Flare Boost, Gorilla Tactics (no move lock yet), Defeatist, Analytic, Steely Spirit, Neuroforce |
| Move type | Pixilate, Refrigerate, Aerilate, Galvanize, Dragonize (Normal moves change type, ×1.2), Liquid Voice; Normalize and all of these go through one helper, `Sovereign_AbilityMoveType`, used by the type chart, absorbing abilities, Color Change and the AI |
| Damage taken | Multiscale, Shadow Shield, Fur Coat, Ice Scales, Punk Rock, Purifying Salt, Water Bubble, Prism Armor |
| Field | Sword/Tablets/Vessel/Beads of Ruin, Dark Aura, Fairy Aura, Aura Break, Protosynthesis (sun only; Booster Energy not yet) |
| Priority | Gale Wings, Triage (through the new `Sovereign_MovePriority`, with Prankster); Queenly Majesty, Dazzling and Armor Tail block foes' priority moves |
| Other | Full Metal Body (as Clear Body), Merciless (always crits a poisoned target), Wonder Skin |

The sound-move list (Soundproof) gains the Gen V+ sound moves.

**Verified in the test build:** Tough Claws Flame Charge dealt 407, the value for power 65 (313 without); Pixilate
Extreme Speed into a Multiscale Venusaur dealt 16 pre-variance (power 80 × 1.2 ÷ 2; 13 without Pixilate) and was
resisted (Fairy vs Poison).

## Item 11 (part 6) — Gen IX move data and 74 more exact moves

- **Fix: moves #827–919 had no flags.** PokeAPI has no flags for the Legends: Arceus and Scarlet/Violet moves, so
  Protect didn't block them and none made contact (Rough Skin, Iron Barbs, Gooey...). `tools/engine/gen9_move_fixes.py`
  now sets contact / Protect / Mirror Move / Magic Coat / Snatch for each, from a hand-written Gen IX table.
- **Secondary effects for Gen VIII–IX moves**, which PokeAPI also lacks: Mountain Gale (flinch), Bitter Malice,
  Chilling Water, Pounce, Springtide Storm, Lumina Crash (stat drops), Wave Crash (recoil), Headlong Rush and Armor
  Cannon (as Close Combat), Bitter Blade (drain), Aqua Cutter (high crit), Twin Beam and Tachyon Cutter (two hits),
  Ruination (halves HP), Comeuppance (as Metal Burst), Malignant Chain (bad poison), the four Torques, Raging Fury
  (rampage), Torch Song and Mystical Power (Sp. Atk +1).
- **New effects, damage then a stat change on the user:** Flame Charge, Trailblaze, Aqua Step, Esper Wing (Speed +1),
  Diamond Storm (Defense +2, 50%), Clanging Scales and Hyperspace Fury (Defense −1), Make It Rain (Sp. Atk −1), Spin
  Out (Speed −2).
- **Engine rules:** Storm Throw, Frost Breath, Wicked Blow, Surging Strikes and Flower Trick always crit; Esper Wing
  has a raised crit ratio; Sacred Sword, Chip Away and Darkest Lariat ignore the target's Defense and evasion stages;
  Infernal Parade and Barb Barrage double like Hex and Venoshock; Fishious Rend and Bolt Beak double if the target
  hasn't moved; Hard Press scales with the target's HP; Fickle Beam has a 30% chance of double power; Grav Apple is
  1.5x under Gravity; Hydro Steam is boosted in sun; Bleakwind, Wildbolt and Sandsear Storm never miss in rain.
- 27 moves were already Gen IX-accurate and only mislabelled in the checklist (Lunge, Nuzzle, Acid Spray, Power-Up
  Punch, Jet Punch...). Move checklist: exact 193, approximate 45, placeholder 142.

**Verified in the test build:** Spin Out left Garchomp at Speed −2; Flame Charge left Archaludon at Speed +1; Storm
Throw dealt 111, the critical value (74 x 1.5).

## Item 11 (part 5) — stat moves and battle-dependent power

**10 stat-changing status moves** are exact, each with its own subscript written by `tools/engine/gen_stat_moves.py`:
Hone Claws, Work Up, Coil, Quiver Dance, Shell Smash, Cotton Guard, Shift Gear, Victory Dance, Noble Roar, Tearful Look.

**12 damaging moves** now follow Gen IX (`Sovereign_MovePower` and the stat swaps in `BattleSystem_CalcMoveDamage`):

| Move | Effect |
|---|---|
| Hex, Venoshock | power doubles if the target has a status / is poisoned |
| Acrobatics | power doubles if the user holds no item |
| Electro Ball | 40–150 power from the Speed ratio |
| Heavy Slam, Heat Crash | 40–120 power from the weight ratio (Heavy/Light Metal count) |
| Stored Power, Power Trip | 20 + 20 per positive stat stage |
| Psyshock, Psystrike, Secret Sword | special damage against the target's Defense |
| Foul Play | uses the target's Attack and Attack stage |

**Verified in the test build:**
- Shell Smash: Defense and Sp. Def −1; Attack, Sp. Atk and Speed +2. Noble Roar: target Attack and Sp. Atk −1.
- Archaludon's Heavy Slam on Garchomp dealt 59, the exact value for power 40 (weight ratio under 2).
- Venusaur's Foul Play read Garchomp's Attack (148), not its own.

## Item 11 (part 4) — 13 more abilities

| Ability | Effect |
|---|---|
| Moxie, Chilling Neigh, Grim Neigh, Beast Boost | a stat +1 for each foe the holder's move knocks out (new after-hit step) |
| Defiant, Competitive | Attack/Sp. Atk +2 after a foe's move lowers a stat (Intimidate not yet) |
| Gooey, Tangling Hair | contact lowers the attacker's Speed |
| Iron Barbs | as Rough Skin |
| Unnerve | foes can't eat Berries (the damage-halving Berries not yet) |
| Cursed Body | 30% chance to disable the move that hit it |
| Poison Touch | 30% chance to poison on contact |
| Moody | +2 to one stat and −1 to another each turn |

**Verified in the test build:**
- Moxie: Eruption knocking out both foes gives Attack +2.
- Gooey: contact leaves the attacker at Speed −1.
- Defiant and Competitive: after Snarl, Attack +2 and Sp. Atk +1 (−1 then +2).
- Moody: Attack +2, Defense −1.

## FM — The first Totem trial on the map, and the crown pieces (decisions 18 and 23)

Totem Gumshoos stands on Route 205 South, and every trial now leaves its crown piece. The other 10 Totems use the same
script and sprites; they're placed next.
- **The Totems on the map.** Each Totem is a huge 64x64 overworld sprite (like Platinum's Regigigas), made from its
  Totem form's sprite with an orange aura outline (`tools/sprites/make_totem_overworld.py`, new
  `OBJ_EVENT_GFX_TOTEM_*`). All 11 are in the ROM.
- **Totem Gumshoos** stands in the flower bed by the river on Route 205 South (x 197, z 656), next to the road to
  Valley Windworks. The north bank, where Yungoos live, is past the Galactic grunts, so the trial waits on the near
  side.
- **The trial** (`CommonScript_SovereignTotemTrial`, one common script for all 11):
  - Talking to the Totem: its cry, then "A huge GUMSHOOS glares at you! A strange aura surrounds it...", then the
    battle.
  - With fewer than two Pokémon that can battle: "Its aura is overwhelming! You'll need two Pokémon that can battle to
    stand against it." (until 1 vs 2 exists).
  - **Win or catch:** "Totem GUMSHOOS disappeared from view..." (unless caught), "Something is glinting on the ground
    where the Totem stood...", then "A found a Gold Shard!" and "A put the Gold Shard in the KEY ITEMS Pocket."
  - **Lose:** the player blacks out, and the Totem is back next time.
  - The map's OnLoad script removes the Totem as the field comes back after the battle, as Platinum does for
    Regigigas.
  - One flag per trial (`FLAG_SOVEREIGN_TOTEM_TRIAL_*`, the unused flags 0x167–0x171) marks it done and hides the Totem.
  - New script commands: `SovereignGetTotemTrialSpecies` and `SovereignClearFlagFromVar`.
- **The crown pieces** (decision 23, `docs/Story.md`): 13 new key items in `data/items_sovereign.yaml`. They are the 11
  pieces (Gold Shard, Oval Emerald, Gold Fragment, Oval Sapphire, Oval Ruby, Gold Sliver, Rose Emerald, Rose Sapphire,
  Rose Ruby, Gold Flake, Crown Diamond), the Crown and the Sovereign Crown.
  - Their descriptions hint more and more that the pieces fit together.
  - With all 11 in the bag, "The crown pieces began to glow! The gold, the jewels and the diamond fit together
    perfectly...": the pieces are removed and the player obtains the Crown.
  - The icons are placeholders drawn by `tools/sprites/make_crown_icons.py`, until the owner's arrive.
  - `gen_items.py` takes `icon: drawn` for an item whose icon a tool draws.
- **Test build:** SELECT+L+R's 9th stop is 3 steps south of Totem Gumshoos.
- **`tools/test/find_tiles.py`** marks every water tile the engine lets you Surf on (`~`). It used to know only
  the river behaviour, so Route 205 South's river showed as walkable.
- **Verified in the test build** (Garchomp and Turtwig):
  - The talk, the battle (two helpers called), the win, "disappeared from view", and the Gold Shard with its icon and
    description in the Key Items pocket.
  - The Totem stays gone after leaving and coming back.
  - The merge, in a temporary build that started with the other 10 pieces: the Crown obtained, all 11 pieces removed.
  - The loss branch, in a temporary build that sent every result there: blacked out home, and the Totem was back.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.
- **Not done yet:** the other 10 Totems on the map, and the Galactic gates (`docs/Story.md`).

## FM — Totem forms and the Totem trial battle (decision 18)

The 12 Totem forms exist, and the battle the trials will use works. The trials aren't on the map yet. The places,
levels, auras and helpers are in `docs/TotemTrials.md` (generated from `data/totem_trials.yaml`).
- **The forms** (`gen_forms.py`, new kind `SOVEREIGN_FORM_TOTEM`):
  - Totem Gumshoos, Ribombee, Vikavolt, Araquanid, Lurantis, Salazzle, Togedemaru, Kommo-o, Alolan Raticate, Alolan
    Marowak, and Mimikyu's Totem Disguised and Busted.
  - Mimikyu's Busted Form is data only for now, like Zen Darmanitan, so the Totem forms keep their official numbers.
  - A Totem learns what its usual form learns, the Alolan one for Raticate and Marowak. PokeAPI only has the Totems'
    old Ultra Sun/Ultra Moon learnsets.
  - Totem Alolan Raticate's Eggs hatch into Alolan Rattata. Totems don't evolve. Sprites are the base form's until
    E12.
- **The trial battle** (`Encounter_SovereignNewTotemTrial`, script command `SovereignStartTotemTrial`):
  - It's a wild double battle: the Totem and its first helper are out from the start.
  - Opening lines: "Totem GUMSHOOS appeared! It called its ally, YUNGOOS!", then "Go! X and Y!".
  - **The aura.** The aura raises the Totem's stats once, at the start: "Totem X's aura flared to life!", then
    "Totem X's Defense rose!", or "Totem X's stats rose!" when it raises several.
  - **Helpers.** When a helper faints, the Totem calls the next one into the empty slot ("Totem X called its ally,
    Y!"), up to 3 helpers in all.
  - **After the Totem faints.** It calls no more helpers, and the trial is won once the field is clear, even with
    helpers left.
  - **Catching.** Poké Balls can be thrown only at a Pokémon alone on its side ("It's impossible to aim when there are
    two Pokémon!"). The Totem is caught in its Totem form.
  - **No escape.** RUN says "There's no running from a Totem!". Roar, Whirlwind and Teleport fail, and the Poké Doll
    and Fluffy Tail can't be used.
  - **AI.** The Totem and its helpers choose moves with the trainer AI (basic, attack evaluation and expert).
  - The aura's stages travel in the battle status mask (`BATTLE_STATUS_TOTEM_AURA`).
- **The auras, checked.** They were written from memory. Against Serebii's trial pages, Lurantis, Alolan Marowak and
  Araquanid raise Speed, and Vikavolt and Ribombee every stat. Stages Serebii doesn't give are marked "check".
- **Helpers** are proposed from each trial's original allies, 2 levels below the Totem.
- **Test build:** SELECT+B+R starts the next trial.
- **Verified in the test build** with Totem Gumshoos (Lv. 18) against Garchomp and Turtwig:
  - The opening, the aura (RAM: form 1, Defense +1) and RUN refused.
  - A ball refused with two foes out.
  - The three Yungoos called in one after another, then the lone Totem caught.
  - The Totem knocked out first: no more calls, and the lone Yungoos catchable.
  - Precipice Blades knocking out both at once: an immediate win with helpers left.
  - The release ROM builds without warnings and passes boot smoke; the docs regenerate clean.
- **Not done yet:** a trial against a player with only one able Pokémon (the owner's 1-vs-2 rule). Platinum can't start
  a double battle with one, so the trial scripts will need two until the engine can.


## FM — The Regional Forms Park (decision 22)

Pal Park's grounds on Route 221 are now the Regional Forms Park, where the regional forms live as wild Pokémon.
Contents, odds and levels are in `docs/RegionalFormsPark.md` (a proposal for the owner).
- **Visiting.** The lobby worker welcomes the player and lets them in. There's no Catching Show, no Park Balls and no
  timer: the park is a normal wild area where the player catches with their own balls.
  - Inside, the worker by the gate names each region's zone and offers to see the player out. Stepping into the gate
    asks the same. Either way the player is back in the lobby.
  - `VAR_PAL_PARK_STATE` 3 marks a visit. The Catching Show's start, gate and tally scripts don't run for it, and the
    lobby's exit script walks the player out as after a show.
- **Encounters.** Pal Park now has an encounter table, `encounters_pal_park`, so grass, Surf and fishing work as on
  any route (step rates, Repel, abilities, Sweet Scent).
  - Each quadrant is one region's zone, as in the Catching Show's areas: Galar in the forest (north-west), Hisui on the
    mountain and its lake (north-east), Alola in the field (south-west), Paldea at sea (south-east).
  - An encounter picks one form from its zone by weight, at a random level in its range, and fills every slot with
    it, so the slot rules still apply.
  - New `data/regional_forms_park.yaml` → `tools/engine/gen_regional_forms_park.py` →
    `include/data/regional_forms_park.h` and `docs/RegionalFormsPark.md`.
  - An encounter slot's species can now carry a form in its upper 16 bits (`WILD_SLOT` in
    `constants/wild_encounters.h`). The wild Pokémon is created with that form, with its stats and ability.
  - The Poké Radar can't chain in the park, which has no radar Pokémon of its own.
- **The map.** It plays the Catching Show's music (the Great Marsh's) from the start (in Platinum the map is silent until the show begins), and running is
  allowed.
- **Text.**
  - Professor Oak's first-visit lines in the lobby now introduce the park.
  - The lobby worker has a new welcome and explains the zones.
  - Route 221's workers and sign follow `docs/Story.md`.
- **Opening.** The park opens after the Hall of Fame. Route 221's workers still check the National Dex flag, which
  means the Hall of Fame since DX.
- **Verified in the test build** (new test warp to Route 221 outside the lobby):
  - Oak's first-visit event and the worker's welcome and zones text.
  - Walking in: no countdown, the normal start menu, the worker by the gate.
  - The field gave Lv51 Geodude and Lv58 Raichu. RAM showed the Raichu as form 1, Electric/Psychic, with Surge
    Surfer, so it's Alolan Raichu.
  - The gate: No steps the player back, Yes returns to the lobby, where the player walks out and the worker steps
    back. The worker inside: zones text, then Yes leaves the same way.
  - Not tested in game: Surf and fishing at sea (the test party has no Surf), and the other three zones. They use the
    same code with another table.


## E8 — The Mega symbol moves next to the name

The Mega symbol is now a 16×16 stone next to the Pokémon's name, as in Pokémon Insurgence. Before, it was an 8×8
ring at the left end of the HP bar's strip, where it looked like a status condition.
- **The art.** A Mega shows a rainbow stone split by the white swirl of the Mega Evolution symbol. Primal Kyogre shows
  a blue stone with α, and Primal Groudon a red stone with Ω.
- **The position.** It sits on the name's row, over the box's border:
  - on the foe's boxes, right after the level;
  - on the player's boxes, just left of the name, where nothing else is drawn.
- **How it's drawn.** It's a sprite of its own, one per healthbox (`healthbox.c`). It moves with its box when the box
  slides in or out and when it bobs, and it hides when the box does.
  - The art is `res/graphics/battle/healthbox/sovereign_mega_icon.png` (new
    `tools/sprites/make_mega_icon.py`), in the HP bar's own palette.
  - The healthboxes share one set of resources.
  - The 8×8 tile is gone, and `healthbox_parts.png` is back to Platinum's.
- **Verified in the test build:**
  - Garchomp in a wild battle.
  - Doubles: Garchomp and the foe's Charizard show it; Turtwig and Venusaur don't. Both boxes and their symbols hide
    during the Drought animation.
  - Switching Turtwig in shows a clean box, and switching Garchomp back brings the symbol back.
  - Primal Kyogre (α) and Primal Groudon (Ω), each as a temporary lead.
  - The release ROM builds with no warnings.


## Item 11 (part 3) — 22 common Gen V+ abilities

Ranked by how many species can have each ability:

| Ability | Effect |
|---|---|
| Sand Rush, Slush Rush | Speed ×2 in sandstorm / snow (Sand Rush, Sand Force and Overcoat: no sandstorm damage) |
| Sand Force | Rock, Ground and Steel moves ×1.3 in a sandstorm |
| Strong Jaw | biting moves ×1.5 (Iron Fist also gains the Gen V+ punching moves) |
| Sheer Force | moves with a chance effect ×1.3, and the effect and Life Orb recoil are skipped |
| Fluffy | contact damage ½, Fire ×2 |
| Friend Guard | the partner takes 25% less damage |
| Infiltrator | ignores Reflect and Light Screen |
| Heavy Metal, Light Metal | weight ×2 / ×½ for Low Kick and Grass Knot |
| Big Pecks | Defense can't be lowered |
| Contrary | stat changes reversed |
| Prankster | status moves +1 priority; they don't affect Dark-type foes |
| Telepathy | avoids its partner's attacks |
| Bulletproof | immune to ball and bomb moves |
| Regenerator | 1/3 of max HP restored on switching out (not at the end of a battle) |
| Justified, Rattled, Water Compaction, Thermal Exchange, Weak Armor | stat changes when hit by the matching moves |

**Verified in the test build** (Garchomp's first move and the foes' abilities swapped for each test):
- Snarl vs Justified/Rattled: Attack +1 and Speed +1.
- Precipice Blades vs Weak Armor: Defense −1 and Speed +2.
- Surf vs Water Compaction: Defense +2.
- Crunch with Strong Jaw: 28, the exact formula value.
- Precipice Blades with Sand Force in sand: 25 and 29, both exact.
- Sheer Force Snarl: no Sp. Atk drops.
- Contrary: Snarl gives Sp. Atk +1.

Not tested in game: Prankster, Regenerator, Telepathy, Bulletproof, Infiltrator, Heavy/Light Metal, Friend Guard,
Fluffy, Slush Rush, Big Pecks.

## Item 11 (part 2) and 12b #4–#5 — absorbing abilities and redirection

- **Gen V+ absorbing abilities** (`BattleSystem_TriggerImmunityAbility`):

  | Ability | Absorbs | Effect |
  |---|---|---|
  | Sap Sipper | Grass | Attack +1 |
  | Storm Drain | Water | Sp. Atk +1 |
  | Lightning Rod | Electric | Sp. Atk +1 |
  | Well-Baked Body | Fire | Defense +2 |
  | Earth Eater | Ground | restores 1/4 of max HP |

  - Storm Drain and Lightning Rod already drew single-target moves in Platinum; now they also absorb them, as since
    Gen V.
  - Three new subscripts modelled on Motor Drive's.
- **AI:**
  - The basic immunity check, the Thunder Wave check and the doubles partner/other-foe estimates know these
    abilities.
  - Platinum's immunity check tested Levitate twice where it meant Dry Skin; fixed.
  - New command `LoadTargetPartnerRedirects`: a single-target Electric or Water move aimed at a foe whose partner has
    Lightning Rod or Storm Drain scores −10, unless the attacker has Mold Breaker.
- **Verified in the test build:**
  - Garchomp's spread moves against the developer team's Archaludon (ability set for each test). Archaludon took no
    damage and got the right boost; its partner took normal damage:
    - Razor Leaf vs Sap Sipper: Attack +1;
    - Surf vs Storm Drain: Sp. Atk +1;
    - Heat Wave vs Well-Baked Body: Defense +2;
    - Discharge vs Lightning Rod: Sp. Atk +1;
    - Precipice Blades vs Earth Eater: no HP lost.
  - With Lightning Rod on Garchomp, the AI's check read "redirected" only for Electro Shot aimed at Garchomp's
    partner.

## FM (part 3) — the regional forms

- **All 57 regional forms exist**, plus Blue- and White-Striped Basculin.
  - Alolan, Galarian, Hisuian and Paldean, each with its own stats, types and abilities.
  - Each has its own Gen IX learnset from PokeAPI: level-up moves and TMs (Alolan Vulpix learns Ice Beam at Lv.
    32).
  - Sprites and icons are the base form's until E12. Where they live in the wild is the Regional Forms Park's job
    (decision 22), so for now nothing in the game gives one.
- **Form numbers follow the official games** (Alolan Raichu 1, Galarian Meowth 2, Galarian Darmanitan 2, the
  Paldean Tauros 1–3).
  - A species' saved forms now come before its Megas. So Mega Raichu X and Y are forms 2 and 3, and adding a Mega
    can never change a saved form number.
  - Zen Mode Darmanitan (Unova and Galar) is in the form data too, waiting for Zen Mode itself.
- **Regional forms evolve into their region's form.**
  - Alolan Rattata becomes Alolan Raticate, and Galarian Darumaka becomes Galarian Darmanitan.
  - Where the regional form leads to its own species, it evolves into that species' base form (Galarian Meowth →
    Perrserker).
  - Some regional forms evolve by their own method: official where Platinum has the method, otherwise Sovereign's
    method for the base species. They're listed in `EvolutionChanges_Sovereign.md` (Alolan Vulpix uses an Ice Stone,
    Galarian Meowth reaches Perrserker at Lv. 28, Galarian Slowpoke uses the Galarica Cuff or Wreath…).
  - Every other form keeps its number when it evolves, as in Platinum (Burmy → Wormadam).
- **Eggs hatch in the parent's regional form.** The form comes from the mother, or from the parent that isn't Ditto
  (Platinum took Ditto's form). A baby with no form of that region hatches in its base form (Alolan Raichu → Pichu).
  Perrserker, Sirfetch'd, Cursola, Obstagoon, Runerigus, Sneasler, Overqwil, Clodsire and Basculegion hatch in their
  regional form (Perrserker → Galarian Meowth).
- **The other FM forms get their own learnsets as well:** the Therian Formes, Hoopa Unbound, the fusions, Crowned
  Zacian/Zamazenta, Ogerpon's masks and the Origin forms. Megas keep their base species' learnsets.
- **`data/forms.csv` categories:**
  - Pikachu's Alola cap is a cap (other), not a regional form.
  - Galarian Zen Darmanitan is a battle form.
  - White-Striped Basculin is regional (Hisui).
- `tools/engine/gen_forms.py` now needs the PokeAPI path. It reads the regional evolutions and Egg rules from
  `data/evolution_changes.yaml`.
- Verified in the test build (a temporary test party):
  - **Learnset:** a Rare Candy taught Alolan Vulpix Ice Beam at Lv. 32.
  - **Ice Stone evolutions:** the party menu marked Alolan Vulpix and Galarian Darumaka "ABLE!" and both Galarian
    Meowth "UNABLE!".
    - Vulpix became Alolan Ninetales (Ice/Fairy, Snow Cloak).
    - Darumaka became Galarian Darmanitan (Ice, Gorilla Tactics).
  - **Level evolution:** Galarian Meowth reached Lv. 28 and became Perrserker (Steel, Battle Armor).
  - **Eggs:** Perrserker and Ditto bred a Galarian Meowth (Steel, Tough Claws, Growl and Fake Out).
  - The release ROM builds and passes `boot_smoke.py`, and the docs regenerate with no diff.

## FM (part 2) — form-change key items and fusions

- **Eleven more forms**, each with its own stats, types and abilities:
  - **Therian Formes** of Tornadus, Thundurus, Landorus and Enamorus.
  - **Hoopa Unbound**.
  - **White and Black Kyurem**, **Dusk Mane and Dawn Wings Necrozma**, and **Ice Rider and Shadow Rider Calyrex**.

  Form numbers follow the official games (Kyurem: 1 White, 2 Black). Sprites and icons are the base form's until
  E12.
- **The key items are used from the bag** (USE, then choose the Pokémon), like the Gracidea. Each change plays the
  party menu's form-change animation and prints "… changed Forme!".
  - **The Reveal Glass and the Prison Bottle** switch the form on and off.
  - **The DNA Splicers, N-Solarizer, N-Lunarizer and Reins of Unity** fuse two party Pokémon. They work when used on
    Kyurem, Necrozma or Calyrex, or on the partner. With both of Kyurem's partners in the party, using the item on
    the partner chooses it. The item holds the partner, which leaves the party.
  - **Using the item on the fused Pokémon separates them.** The partner rejoins the party, unless the party is full
    ("There's no room in your party, so they can't be separated."). An item holds one partner at a time.
  - Otherwise: "It won't have any effect."
- **Moves change with the form**, as in the official games:
  - **Kyurem:** Glaciate becomes Ice Burn (White) or Freeze Shock (Black), and Scary Face becomes Fusion Flare or
    Fusion Bolt. The PP used carries over.
  - **Hoopa Unbound:** Hyperspace Hole becomes Hyperspace Fury.
  - **Necrozma and Calyrex:** they learn Sunsteel Strike, Moongeist Beam, Glacial Lance or Astral Barrage when they
    fuse, if they have a free move slot, and forget it when they separate. If it was their only move, it becomes
    Confusion.
- **A fused Pokémon can't be released** in the PC ("Separate the fusion first."), since its partner would be lost.
- **No "Migrate from…" main-menu option** (decision 22). The partners are kept in Pal Park's transfer storage, so the
  save layout is unchanged. Pal Park only opens with six transferred Pokémon, and the four fusion items can't fill
  that. A GBA game in the DS's second slot still counts for dual-slot encounters.
- **Fix: the 532 new species' party and box icons were garbage** (E6). Their PNGs had 256-colour palettes, so they
  built as 8bpp graphics that the 4bpp icon sprites showed as noise. Reloading one, as the form-change animation does,
  also overwrote the next party slot's icon. The PNGs are now 4-bit with 16 colours, like Platinum's, and
  `tools/sprites/make_placeholder_icons.py` writes them that way. The art and the colour indices are unchanged.
- Verified in the test build (a temporary test party with the key items):
  - **Fusion:** the DNA Splicers used on Zekrom made Kyurem Black Kyurem (Teravolt; Freeze Shock 5/5, Fusion Bolt
    5/5), and Zekrom left the party.
  - **Separation:** used on Black Kyurem, they brought Zekrom back into slot 6, with Glaciate and Scary Face at
    10/10.
  - **Reveal Glass:** Landorus became Therian (Intimidate; Attack 152 at Lv. 50).
  - **Prison Bottle:** Hoopa became Unbound (Psychic/Dark, Magician, Hyperspace Fury).
  - **Reins of Unity:** used on a Calyrex with no partner in the party, they print "It won't have any effect."
  - **PC:** releasing the fused Kyurem printed "Separate the fusion first."
  - **Icons:** every party icon now draws correctly.
  - The release ROM builds and passes `boot_smoke.py`, and the docs regenerate with no diff.

## Item 11 (part 1) — exact effects for the developer team and boss teams

The boss teams (`data/trainers_sovereign.yaml`) and the developer team use only four moves and abilities that weren't
exact yet. All four now are:

- **Hurricane** (new effect `BATTLE_EFFECT_HURRICANE`): Thunder's rules (never misses in rain, 50% accuracy in harsh
  sunlight, hits a Pokémon using Fly or Bounce) with a 30% confusion chance.
- **Body Press** (`BATTLE_EFFECT_BODY_PRESS`): damage uses the user's Defense and Defense stage instead of its Attack.
  Effects that raise Attack (Choice Band, Huge Power, Hustle, Guts) don't apply, as in Gen IX (`battle_lib.c`).
- **Electro Shot** (`BATTLE_EFFECT_ELECTRO_SHOT`): the charge turn raises Sp. Atk 1 stage ("…absorbed electricity!"),
  and the move hits the next turn. In rain, or with a Power Herb, it raises Sp. Atk and hits at once. It has its own
  two-part animation (Charge's, then Thunderbolt's).
- **Stamina**: Defense +1 stage each time a damaging move hits the holder (`BattleSystem_TriggerAbilityOnHit`).
- **AI:** Platinum's weather scoring for Thunder never ran: it checked Solar Beam's effect by mistake. It now scores
  Thunder and Hurricane up in rain and down in sun. Electro Shot is scored like Platinum's other charge moves.
- **Generators:** `gen_moves.py` gains `SOVEREIGN_EFFECTS` (moves with their own new effect) and
  `HANDWRITTEN_SCRIPTS` (moves whose battle script and animation are hand-written), so regenerating keeps them.
  `gen_abilities.py` gains `IMPLEMENTED`.
- **Lesson:** a new subscript must be added in three places, in the same order: the meson file list,
  `generated/battle_subscripts.txt` and `sub_seq.order`. A file missing from the order file is packed alphabetically
  after the listed ones, so the `BATTLE_SUBSCRIPT_*` constants point at the wrong script.
- **Verified in the test build** (the developer team rearranged for each test, hooks on the damage calc):
  - Hurricane runs its new script.
  - Archaludon's Body Press dealt 191, the exact Defense-based value; Attack would give 125.
  - Stamina showed "The foe's ARCHALUDON's Stamina raised its Defense!" and +1 Defense.
  - Electro Shot charged with Sp. Atk +1 then hit for 549. In rain it boosted and hit at once (543).
  - `check_trainer_party.py` and `boot_smoke.py` pass.

## FM (part 1) — held-item forms and form-item locks

- **Seven held-item forms exist** (decision 16):
  - **Crowned Zacian and Crowned Zamazenta**, holding the Rusted Sword or Rusted Shield.
  - **Ogerpon's Wellspring, Hearthflame and Cornerstone Mask forms**.
  - **Origin Dialga and Origin Palkia**, holding the Adamant Crystal or Lustrous Globe.

  Each form has its own stats, types and abilities. `tools/engine/gen_forms.py` packs them after the Megas, in the
  same form table (`TechnicalDesign.md` §4b). Sprites and icons are the base form's until E12, and abilities the
  engine doesn't have yet (Embody Aspect, Intrepid Sword's effect…) wait for item 11.
- **The form follows the held item.**
  - Ogerpon's masks and the Origin items change the form whenever the item changes: giving or taking it in the party
    menu, or giving it in the PC. Stats and ability are recalculated.
  - The Griseous Core now works like the Griseous Orb (Origin Giratina, also in battle).
  - Zacian and Zamazenta become Crowned when a battle starts with them holding their item. Iron Head becomes
    Behemoth Blade or Behemoth Bash, and the PP used carries over.
  - They revert when the battle ends, or when caught, the same way a Mega does. Behemoth Blade/Bash goes back to
    Iron Head.
- **Form items can't be taken.** Knock Off, Thief, Covet, Trick, Switcheroo and Fling fail or leave the item when the
  holder's form depends on it:
  - a Mega Stone on the species it's for;
  - the Blue and Red Orbs on Kyogre and Groudon;
  - the Rusted Sword and Shield, Ogerpon's four masks (the Teal Mask too), the Adamant Crystal, the Lustrous Globe
    and the Griseous Core, each on its own Pokémon.

  On any other Pokémon these items can be taken as usual. This makes `MegaEvolution.md`'s rule true in the engine.
- **`data/forms.csv`** (new, written by `tools/design/build_species_data.py`): every alternate form with its own data
  in PokeAPI, other than Megas and Primals (227). Each has a category: vanilla (already in Platinum), item, battle,
  fusion, regional, Totem, other, or excluded (Gigantamax and the unplayable forms).
- Verified in the test build (temporary test parties):
  - **Crowned Zacian** has Behemoth Blade in battle. After the battle it is Fairy-type with Intrepid Sword, and Iron
    Head is back at 14/15 after one Behemoth Blade.
  - **Ogerpon** given the Wellspring Mask in the party menu is Grass/Water with Water Absorb.
  - **Origin forms** at Lv. 50: Dialga's summary shows Attack 115 and Sp. Def 131, and Palkia's Attack 106 and Speed
    135. Only the Origin forms' base stats allow these values.
  - **Locks:** in the doubles test battle, Zacian's Knock Off hit the foe's Mega Charizard Y and left its
    Charizardite Y. In a wild battle, Zacian's Trick failed: its own Rusted Sword is locked.
  - Knock Off still takes an ordinary item (a wild Chansey's Oval Stone).
  - The release ROM builds without warnings and passes `boot_smoke.py`, and the docs regenerate with no diff.


## DX — the Pokédex (decision 21)

- **Rowan's Pokédex is the National Dex.** The Sandgem lab script sets the National Dex flag right after giving the
  Pokédex, so it opens in National mode with all 1025 species. The Sinnoh dex is the Pokédex's SWITCH view.
- **Post-game gates still wait for the Hall of Fame.** Platinum used the National Dex flag as its "post-game"
  check. The scripts' check (`ScrCmd_GetSetNationalDexEnabled`) now answers "has the player entered the Hall of
  Fame". So Spear Pillar's, Snowpoint Temple's and Stark Mountain's events, Oak's PC (Rowan's until then) and the
  other post-game gates stay post-game.
  - The Trophy Garden and Great Marsh extra Pokémon (`wild_encounters.c`, `great_marsh_binoculars.c`) follow the Hall
    of Fame too.
  - Pal Park is removed (decision 22), so its National Dex gate needs nothing.
  - Rowan's event for a complete Sinnoh dex (Oak's visit and the Poké Radar) used to run only while the National Dex
    was off. It now has its own flag, `FLAG_SOVEREIGN_SHOWED_ROWAN_SINNOH_DEX` (formerly `FLAG_UNUSED_0x0094`), so it
    still runs once, whenever the player shows Rowan all 210 Sinnoh Pokémon, before or after the Hall of Fame. Its
    dialogue still says Oak adds the National Mode and that Pal Park is open; it needs rewriting for Sovereign (the
    Regional Forms Park, decision 22).
  - In Platinum these gates waited for the National Dex, which needed all 210 Sinnoh Pokémon seen as well as the
    Hall of Fame. Now the Hall of Fame alone opens them.
- **National numbers everywhere.** The summary screen and the PC box preview always show the National Dex number.
  The box preview's number window is one tile wider for four digits ("No.1018").
- Test build: a new game gets the Pokédex with the National Dex.
- Verified in the test build:
  - The Pokédex opens in National mode (Turtwig #387) with a SWITCH button.
  - The summary shows Garchomp 445 and Archaludon 1018.
  - Rowan's PC, not Oak's, shows before the Hall of Fame.
  - Rowan's Sinnoh dex event (with a test hook seeing all 210 Sinnoh Pokémon): Oak arrives, the Poké Radar is given,
    and talking to Rowan again gives "The world is immense...".
  - The box preview shows No.445 and No.1018.

## 12b (part 2) — doubles AI: spread moves get credit for hitting both foes

- Each move is scored against one target at a time, so a spread move (Heat Wave, Rock Slide, Earthquake…) got no
  credit for also hitting the other foe. New AI command `LoadOtherFoeDamagePercent` estimates that second hit, and
  `TagStrategy_CheckOtherFoe` scores it: knocks it out +2, a quarter of its HP or more +1, and −2 if the other foe
  absorbs the move's type (Flash Fire, Water Absorb…).
- `LoadPartnerDamagePercent` and the new command share one estimate (`AI_SpreadDamagePercent`, `AI_MoveDealsDamage`).
- Verified in the test build with `log_ai_partner_damage.py --other-foe` (`docs/AIReview.md`). The partner check
  (#1) reads as before.

## 12b (part 1) — doubles AI: moves that hit its own partner

- In double battles, the AI now weighs every damaging move that also hits its partner (any move aimed at all
  adjacent Pokémon) by how much of the partner's HP it would take.
  - The estimate uses the game's damage calc, so type matchups, abilities and HP all count.
  - Platinum checked only Earthquake, Magnitude, Discharge, Lava Plume and Surf, by name and by the partner's type.
    Explosion and every Gen V+ ally-hitting move weren't checked at all.
  - Scoring: partner unhurt (immune or absorbs) +2, knocked out −10, half or more −5, a quarter or more −3,
    less −1.
- New AI script command `LoadPartnerDamagePercent` (`src/battle/trainer_ai/trainer_ai.c`, `asm/macros/aicmd.inc`).
  Platinum's five by-name handlers are removed from `script.s`, which also fixes their known bugs: Discharge next to
  a Ground-type partner, Surf next to Rock types, and a lone Pokémon getting −3 for Earthquake.
- Gen V+ immunities (Sap Sipper, Earth Eater, Telepathy…) are added to the check as item 11 gives those abilities
  their effects.
- Verified in the test build with `tools/test/log_ai_partner_damage.py`: Earthquake reads 0% next to a Flying
  partner, Surf 0% next to Water Absorb, and super-effective, neutral and resisted hits scale as expected. A doubles
  turn plays normally. The trainer checker and `boot_smoke.py` pass. Reference: `docs/AIReview.md`.

## E8 — Mega Evolution and Primal Reversion (in progress)

- **The 99 Mega and Primal forms exist as data** (step 1). `tools/engine/gen_forms.py` reads `data/megas.csv` and
  writes each form's stats, types and ability, packed after Platinum's alternate forms (`TechnicalDesign.md` §4).
  - 42 forms have their Mega ability, because the battle engine has it. The other 57 (an ability the engine lacks, or
    none listed yet) keep the Pokémon's own ability, as `MegaEvolution.md` says.
  - Sprites and icons are the base species' until E12.
  - Verified: with the test Garchomp's form set to 1 (temporary hook), the summary showed Mega Garchomp's stats
    (Attack 182 at Lv. 50).
- **15 Mega Stones in the field** (`data/mega_stones.yaml`), placed by `tools/engine/place_mega_stones.py` in the item
  balls they replace. Verified: the Route 203 ball gives the Alakazite.
- **Fantina gives the Mega Ring** with the Relic Badge, after TM65, and sets `FLAG_SOVEREIGN_MEGA_UNLOCKED`
  (formerly `FLAG_UNUSED_0x006F`). A player who already has the badge gets it by talking to her again. Verified by
  beating Fantina with the test party.
- Test build: SELECT+L+R stops at the Alakazite ball and in front of Fantina.
- **Mega Evolution in battle** (step 2; `battle_controller_player.c`, `battle_lib.c`):
  - It happens after switches and items and before the turn's first move, fastest first. The remaining moves are then
    re-sorted, so the Mega's Speed counts that turn (Gen VII+).
  - Stats, types and (when the engine has it) the ability change. A new ability takes effect at once, like a switch-in
    (Mega Charizard Y's Drought sets the sun).
  - Once per trainer per battle; in multi and tag battles each trainer gets one. The player needs the Mega Ring
    (`FieldBattleDTO.megaUnlocked`). Wild Pokémon never Mega Evolve. Trainers' AI Mega Evolves as soon as it can.
  - The party Pokémon stays Mega while switched out. Every Mega/Primal form reverts when the battle ends
    (`BattleMain_CopyBattleSysToDTOAndFree`).
  - Messages: "<Pokémon>'s <stone> is reacting to the Mega Ring!", then "<Pokémon> has Mega Evolved into Mega
    <species>!". The new subscript is `subscript_sovereign_mega_evolution`; the animation is described below.
  - Verified in the test build:
    - The test trainer's Charizard Mega Evolved on turn 1 and Drought set the sun.
    - The player's Garchomp Mega Evolved in a wild battle (a temporary always-Mega hook stood in for the button) and
      didn't again on turn 2.
    - After the battle, Garchomp was back to its normal stats with its Garchompite.
  - Still to do: the AI review.
- **The MEGA button** (step 3; `battle_subscreen.c`, `battle_display.c`). When the active Pokémon can Mega Evolve, the
  move menu shows a MEGA button above the moves, with the held Mega Stone's item icon in its socket (Mega Rayquaza shows
  the Mega Ring). Off, it's grey; on, it turns pink, violet and blue with white lettering, and its outline pulses
  purple and gold. The move chosen next Mega Evolves the Pokémon.
  - Turn it on or off by touching it, by pressing UP from the top row of moves and then A (DOWN goes back), or by
    pressing SELECT.
  - The server says whether to offer it: it isn't offered when the trainer's other Pokémon chose it this turn, or once
    the trainer has used it.
  - The choice travels in the second byte of the selected move. Battle recordings store it in the move slot's top bit,
    so replays Mega Evolve too.
  - The button is an OBJ sprite in `pl_batt_obj` (`res/graphics/battle/interface/mega_button.png`, drawn by
    `tools/sprites/make_mega_button.py`): three frames, with the pulse animated in `mega_button_anim.json`. The icon is
    a second sprite. Both load when the move menu opens and are freed with the menu's other sprites.
  - Verified:
    - Wild battle: the button shows Garchompite. Touch, SELECT, and UP then A all toggle it. Choosing a move with it on
      Mega Evolved Garchomp, and on turn 2 the button was gone.
    - Doubles vs. the test trainer: Turtwig's menu has no button. Garchomp (toggle on) and the foe's Charizard both
      Mega Evolved that turn, fastest first. (This was checked with the earlier text toggle, which worked the same way.)
- **Primal Reversion** (step 3): Kyogre holding the Blue Orb and Groudon holding the Red Orb revert as they enter
  battle. It runs as a new switch-in state (`SWITCH_IN_CHECK_STATE_SOVEREIGN_PRIMAL`), before weather abilities.
  - No button or Mega Ring is needed, and it doesn't use up the trainer's Mega Evolution.
  - Primordial Sea and Desolate Land aren't in the engine yet, so Primal Kyogre keeps Drizzle.
  - A caught Primal reverts in `BattleSystem_SetPokemonCatchData`, because it skips the battle-end revert.
  - Verified (temporary Kyogre leading the test party): "KYOGRE's Primal Reversion! It reverted to its primal form!",
    then Drizzle's rain. After running from the battle, Kyogre was back to its normal stats.
- **The Mega Evolution and Primal Reversion animation** (step 4; `docs/MegaEvolution.md`). With Battle Scene on:
  1. The background darkens and every other battler on the field dims.
  2. Two beams of light reach the Pokémon (Morning Sun's), and sparkles gather on it (Judgment's and Power Gem's).
  3. A ring of light forms around it (Safeguard's). It pulses pink, cyan and gold as it shakes: blues for Kyogre,
     reds for Groudon.
  4. It turns white and stays white while the subscript swaps its form.
  5. Streaks of light burst out, the new form fades in from white with sparkles, and it cries. The background and the
     other battlers brighten again.

  How it's built:
  - Four new common animations fill unused slots: `sovereign_mega_evolution`, `sovereign_primal_alpha` and
    `sovereign_primal_omega` before the swap, and `sovereign_mega_evolved` after it (`BATTLE_ANIMATION_SOVEREIGN_*`).
    Only Platinum's own particle effects are used.
  - A new animation function, `Func_SovereignFadeSprites`, fades the attacker or every other battler one way and
    leaves them faded, so the second animation can fade them back. `BtlIOCmd_ChangeWeatherForm` re-applies a held fade
    to the reloaded palette, so the new form stays white until then. Platinum's own fades end at 0, so its form
    changes are unaffected.
  - The reveal loads its particles with `LoadParticleSystem` instead of `LoadParticleResource`. The latter draws
    unfaded copies of the battlers while it loads, which flashed them back for 6 frames.
  - The form-change mosaic is gone from both subscripts. With Battle Scene off, the sprite simply swaps.
  - The anim takes about 6 seconds, from the darkening to the "has Mega Evolved" message.
  - The symbol flash (step 6): as the new form fades in, a 32×32 symbol flashes over it and blinks out. It's the Mega
    Evolution symbol for a Mega, Kyogre's α or Groudon's Ω for a Primal.
    - The symbols are original art by `tools/sprites/make_mega_symbols.py`, as animation sprites
      (`res/graphics/battle/moves/sovereign_*_symbol.*`) shown with `SPRITE_FUNC_OFFSET_AND_ANIMATE`.
    - The Primals now have their own reveals, `sovereign_primal_alpha_revealed` and `sovereign_primal_omega_revealed`
      (formerly `dummy43/44`).
    - Verified: Garchomp (wild), the foe's Charizard (doubles) and Kyogre (temporary lead).
- **The Mega symbol on the HP bar** (step 5; `healthbox.c`). A Mega or Primal shows a small rainbow Mega symbol at
  the left end of its HP bar's strip, from the moment its new form fades in until it leaves the field. It returns
  when the Pokémon comes back.
  - The symbol is an 8×8 tile appended to `healthbox_parts.png`, drawn by `tools/sprites/make_mega_button.py`.
  - It goes where Platinum puts the caught-species Poké Ball. Only wild Pokémon show that ball, and they never Mega
    Evolve, so the two never collide.
  - The HP bar reads the form from the party Pokémon, which stays Mega for the whole battle.
  - The symbol's color 0 shows the strip under it. The tile it covers is saved, and put back when a Pokémon that
    isn't Mega takes the slot.
  - The Mega and Primal subscripts redraw the HP bar after the reveal with a new script command,
    `SovereignRefreshHealthBox`. It's appended after `End`, so no existing command ID changes, and it sends the
    existing HP-gauge refresh.
  - Verified in the test build:
    - The symbol shows on Garchomp's bar in singles.
    - In doubles it shows on Garchomp's and the foe's Charizard's bars, and not on Turtwig's or Venusaur's.
    - Switching Turtwig in leaves a clean bar, and switching Garchomp back shows the symbol again.

  Verified frame by frame in the test build (no flicker):
  - Garchomp in a wild battle.
  - Kyogre and Groudon leading the test party (temporary).
  - The foe's Charizard in the doubles test battle: Garchomp, Turtwig and the foe's Venusaur dimmed.
  - Release ROM built without warnings and passed boot smoke.
- Test build: Garchomp holds a Garchompite and the Mega flag is set at new game.
- **The four Mega Stone vendors** (`data/mega_stones.yaml`):
  - **Collector:** Bebe's house in Hearthome, after the Relic Badge.
  - **Trader:** Pastoria's northeast house, after the Fen Badge.
  - **Sage:** Snowpoint's west house, after the Icicle Badge.
  - **Curator:** the Survival Area south house, after the Champion.
  - Each is a new NPC who explains the badge they need until the player has it, then opens a specialty shop.
  - `gen_items.py` writes their stocks and prices: ₽10,000, or ₽30,000 at the Curator (₽15,000 with the post-game
    discount). Stones found only in the field stay at no price.
  - `tools/test/find_tiles.py` now handles indoor maps and marks NPCs and doors. It picked the free tiles.
  - Verified: the Collector refuses without the Relic Badge. With the Hall of Fame flag set (temporary hook), the
    Curator opened her shop with Mewtwonite X at ₽15,000. New SELECT+L+R stops at both.

## E7 part 2 — shops and icon placement (in progress)

- **Post-Champion money** (owner, decision 24). Every check is the Hall of Fame flag (`FLAG_GAME_COMPLETED`):
  - **Half price in every money shop** (`Shop_GetItemPrice`, `overlay007/shop_menu.c`): Poké Marts, specialty
    counters, decorations and Seals. Battle Point shops are unchanged.
  - **3× prize money** from post-game rematches: the Elite Four and Cynthia rematches, the eight Gym Leader rematches
    and the five Battleground trainers (`Sovereign_PostgamePrizeMultiplier`, `battle/battle_script.c`).
  - **Full sell price** for items no shop sells (`Shop_IsItemSoldInMarts`, `scrcmd_shop.c`, scanning every Poké Mart
    and specialty stock). Shop items still sell for half, so buying at half price and reselling can't make money.
  - **Survival Area Youngster** gives 3 Nuggets once a day (`FLAG_DAILY_RECEIVED_SURVIVAL_AREA_NUGGETS`, formerly
    the unused daily flag `0x0AAF`). Before the Champion he says his usual line.
  - Verified in the test build with the Hall of Fame flag set by a temporary hook: Roark paid ₽5040 (₽1680 × 3)
    while on the rematch list for the test; Protein cost ₽4900 at Veilstone; a Nugget sold for ₽10,000 and a Super
    Repel for ₽250; the Youngster gave 3 Nuggets, then said to come back tomorrow. New SELECT+L+R stop at the
    Youngster.
- **Veilstone Department Store sells the new held items** (owner request). The 2F vitamin clerk now shows a menu:
  Vitamins / Held items / Gems.
  - The stock lists are written by `gen_items.py` into `include/data/sovereign_mart_items.h`, as
    `MART_SPECIALTIES_ID_VEILSTONE_2F_HELD_ITEMS` and `_GEMS`.
  - Both count toward the store's regular-customer counter, like the other floors.
  - No map edit was needed.
- **Shop prices show 5 digits**, so ₽10,000–₽30,000 items (Ability Shield, Clear Amulet and so on) no longer show
  "₽?000". Prices stay right-aligned, so Platinum's own prices don't move.
- **Infinite Repel** (QoL #3): a key item, a custom entry in `items_sovereign.yaml` with the Max Repel icon. Using it
  from the bag turns a never-ending Repel on or off (`FLAG_SOVEREIGN_INFINITE_REPEL`, formerly `FLAG_UNUSED_0x006D`).
  `wild_encounters.c` treats it like Repel steps, so it blocks wild Pokémon weaker than the lead, just like a Repel.
  - Tested on Route 202 with Garchomp (Lv. 50) leading: a Bidoof appeared within 60 steps with it off; no encounter
    in 160 steps with it on.
- **Test tools:** a SELECT+L+R stop on Route 202's grass, and `tools/test/find_tiles.py`, which prints a map's
  grass/water/collision layout with world coordinates for warp stops.
- **Item icons are centred like Platinum's.** The art sits in the top-left 24×24 of the 32×32 icon, centred on
  (11.5, 11.5), so it's centred in the bag's preview box. Six sprites larger than 24 px are scaled to fit.
- Verified in the test build: the held-item shop list with prices, icons and descriptions (opened directly through
  a temporary hook); 5-digit prices; icons centred in the bag preview next to vanilla ones.
- Verified in game, via the new SELECT+L+R test warp: the 2F clerk shows Vitamins / Held items / Gems, and each opens
  the right stock. Lesson: `AddMenuEntryImm` stores the text ID in one byte, so menu texts with IDs over 255 (any new
  `menu_entries` text) need `AddMenuEntry`.
- **Test build: SELECT+L+R warps** to the next place in `sSovereignTestWarps` (`src/script_manager.c`), looping. For
  now the stops are the Veilstone Store 2F clerk, Route 202's grass and the Survival Area Youngster. Add stops there
  to test other map scripts.

## E9 — Sovereign trainer format

Trainers can now be written exactly: nature, ability (including Hidden Abilities), IVs, EVs, gender, shininess and
Poké Ball per Pokémon, as optional fields in the trainer JSON. Reference: `docs/TrainerFormat.md`.

- **Format:** a party that uses any of the new fields is packed as `TrainerMonSovereign` (38 bytes per Pokémon,
  `TRDATATYPE_SOVEREIGN`); every other party keeps Platinum's four layouts.
  - Platinum's 928 trainers pack byte-for-byte as before (`trdata.narc` and `trpoke.narc` compared member by member).
  - The new layout stores the whole species ID and the form separately.
- **How the game builds the Pokémon** (`src/trainer_data.c`):
  - It starts from Platinum's seeded personality value and changes it as little as possible to give the requested
    nature, gender and ability slot.
  - A Hidden Ability uses Sovereign's Hidden Ability flag; shininess comes from the OT ID.
  - IVs, EVs and form are set, then the ability and stats are recalculated.
- **Packer checks** (`tools/dataproc/src/trainerproc.c`): IVs 0–31; EVs at most 255 per stat and 510 in total; gender
  `"male"`/`"female"`; ball item IDs below 256.
- **Prize money** reads the new layout too (`BattleScript_CalcPrizeMoney`).
- **Test trainer:** `TRAINER_SOVEREIGN_TEST` ("Ace Trainer Henry"), added at the end of the trainer list with the
  unused flag after the last trainer flag. Its team is the developer team (`docs/DeveloperBattle.md`) at Lv. 100 in a
  double battle, every Pokémon in a Luxury Ball (owner), with every held item from the owner's sets (E7's Charizardite Y, Blue Orb and Assault Vest included; Mega Evolution and Primal Reversion come with E8). The test build's SELECT+R now battles
  it instead of the Route 209 rival.
- **New test tool:** `tools/test/check_trainer_party.py` starts that battle, decrypts each Pokémon the game builds for
  the opponent (hook on `Party_AddPokemon`), and compares it with the JSON, including all six stats recomputed from
  base stats, IVs, EVs and nature.
- Verified:
  - `check_trainer_party.py` passes for all six Pokémon: nature, gender, ability (two Hidden Abilities and one slot
    pick), IVs, EVs, moves, items, shininess (Garchomp, Archaludon), Luxury Balls and stats.
  - It fails as it should against a deliberately wrong JSON.
  - In battle, Charizard ♂ and Venusaur ♀ lead at Lv. 100 and a turn plays out normally.
  - The normal ROM passes `boot_smoke.py`.
  - Not checked in game: prize money for this layout, because the test party can't beat a Lv. 100 team. It reads the
    last Pokémon's level, as the other four layouts do.

## E7 step 1 — 245 new items (in progress)

- **245 items added** after Platinum's last (#468–712), from `data/items_sovereign.yaml` by
  `tools/engine/gen_items.py`:
  - held items and Gems;
  - form-change items (Memories, Drives, Nectars, Sweets, the Rusted Sword/Shield, Ogerpon's masks, the origin
    crystals, Ultranecrozium Z, Blue/Red Orb);
  - evolution items;
  - Mints, Ability Capsule and Ability Patch;
  - key items (Mega Ring, Light/Dark Stone, Prison Bottle, Scrolls, DNA Splicers, N-Solarizer/Lunarizer, Reins of
    Unity, Zygarde Cube, Reveal Glass);
  - 92 Mega Stones.
- Names, prices and descriptions come from PokeAPI. 26 Gen IX descriptions are written in the generator. Three names
  over 16 characters are shortened.
- Descriptions wrap by pixel width, measured with the message font (`res/fonts/font_message.json`). The box fits
  214 pixels: Platinum's widest line. A wrap by character count overflowed it.
- New names reach 94 pixels (Platinum's widest is 72). They fit the bag list, the "was given" message and the summary
  screen's Item field. Shop lists are checked when the shops are added.
- Icons: each new item has a bag icon converted from PokeAPI's item sprites (32×32, 4-bit, 15 colours plus
  transparent; big renders scaled to fit 24 px). They're listed in `res/items/icons/meson.build` and
  `item_icon.order` inside generator-owned blocks.
- **The 16 waiting evolutions are wired up.** Rerunning `gen_new_species.py` resolved all of them; none wait any
  more:
  - Applin → Flapple/Appletun/Dipplin; Charcadet → Armarouge/Ceruledge; Duraludon → Archaludon; Kubfu → Urshifu
    (Single Strike; Rapid Strike comes with the forms milestone); Scyther → Kleavor (Scizor kept); Ursaring →
    Ursaluna; and the rest listed in `NewSpecies.md`.
  - New species' wild held items now include the new items PokeAPI lists (e.g. Absorb Bulb).
- **Mints, Ability Capsule and Ability Patch work** (Medicine pocket; used from the bag on a party Pokémon):
  - A Mint sets the nature used for stats and shown on the summary. It's stored in 5 spare bits of the Pokémon data
    (`mintNature`). Breeding, Synchronize and flavour likes keep the personality value's nature, as in Gen VIII.
  - The Ability Capsule swaps between the two regular abilities. A spare bit (`abilitySlotSwapped`) keeps the swap
    through evolution. It has no effect on a Pokémon with its Hidden Ability or with only one regular ability.
  - The Ability Patch switches between the regular and Hidden Ability (Scarlet/Violet rules).
  - Messages: "X's stats may have changed due to the Adamant Mint!" and "X's Ability changed to Y!".
  - Code: `PartyMenu_TryUseSovereignTrainingItem` (`src/applications/party_menu/main.c`), the `BoxPokemon_GetNature`
    and `BoxPokemon_CalcAbility` overrides (`src/pokemon.c`), and `MON_DATA_MINT_NATURE` /
    `MON_DATA_ABILITY_SLOT_SWAPPED`.
- Not done yet: hold effects.
- Test build:
  - NEW GAME skips Rowan's intro (hold L to play it). Player "A", rival "Barry".
  - The new-game bag has six of the new items.
  - `drive.py` boots with a blank battery: py-desmume reloads `~/.config/desmume/<rom>.dsv`, so "fresh" boots were
    continuing an old save.
  - `new_game.sh` reaches the bedroom from a blank battery.
- Verified with the test build:
  - The new items appear in the right pockets (Mega Ring in Key Items) with names, descriptions and their icons.
  - Heavy-Duty Boots can be given to Garchomp and shows on its summary screen.
  - Using an evolution item opens the party screen, with "UNABLE!" for Pokémon it doesn't evolve.
  - Metal Alloy on Duraludon (temporary test party): ABLE!, then Duraludon evolved into Archaludon and the item was
    used up.
  - Adamant Mint on Garchomp: the message, then "Adamant nature." with Attack raised and Sp. Atk lowered on the stats
    page. Ability Patch on Garchomp: Sand Veil → Rough Skin. Ability Capsule on Archaludon: Sturdy → Stamina. Ability
    Capsule on Garchomp (Hidden Ability): "It won't have any effect."

## E6 step 2 — species #494–1025

All 1025 species are in the game, with species ID = National Dex number (Egg is 1026, Bad Egg 1027).

- **Species data:** `tools/engine/gen_new_species.py` writes the 532 Gen V–IX species from PokeAPI into
  `res/pokemon/<species>/`: stats, types, abilities with Hidden Abilities, learnsets (same rules as #1–493), egg
  data, evolutions, Pokédex text, Pal Park data, footprints (blank, as in Gen V+) and placeholder icons. It also
  writes `docs/NewSpecies.md`.
  - Names over 10 characters are shortened Gen V-style (e.g. CORVKNIGHT); the list is in the generator.
  - 16 evolutions wait for items from E7 and are marked ⏳ in `docs/NewSpecies.md`.
  - Evolutions from Platinum's species into new ones are added to the parents (e.g. Eevee → Sylveon).
    `MAX_EVOLUTIONS` is 8 so Eevee fits.
  - `gen_species_gen9.py` shares its learnset builder with the new generator. Its output is unchanged.
- **Placeholder sprites:** Unown-? until E12, for both genders (Platinum shows the female sprite for female
  Pokémon).
- **No cries yet (owner decision):** Platinum's sound archive is unchanged and the new species play silently
  (`Sound_Impl_HasCry`). Packing 532 more cries needs about 25.5 KB more sound heap at boot than the 21.4 KB that is
  free. Cries are the project's last step.
- **English-only Pokédex (owner decision):** the per-species foreign-language table is removed from the save, which
  keeps the save inside Platinum's 32 sectors (33 crashed on boot). The Route 226 foreign-entry upgrade shows no
  language tabs.
- **Easy Chat:** `tools/engine/gen_easy_chat_species.py` adds the new species to the Easy Chat lists in display-name
  order: A–L to POKéMON, M–Z to POKéMON 2, and each one to its ABC-mode letter. As in Platinum, a species appears once
  it has been seen. The word buffers are sized from the text banks, so they grow on their own (2,670 words, well below
  the 4,096 the word decoder allows).
  - `easy_chat_word_list.c` moved from the static ARM9 into the `easy_chat` overlay (owner request), since only that
    overlay uses it. The word lists load only while Easy Chat is open. This frees 9,504 bytes of RAM, which includes
    the 2,128 bytes the new species added. Every overlay starts 9.5 KB lower and keeps the same layout.
- **Test build:** Archaludon (#1018) replaces the Sharpness Gallade in the test party, and SELECT+B opens the Easy
  Chat word picker.

Verified with the test build:
- The ROM boots (`boot_smoke.py`), and in-game save and continue work.
- Archaludon's summary, stats and ability show correctly. In a wild battle it switches in, attacks, and the battle
  ends normally.
- Easy Chat (SELECT+B): POKéMON lists the seen species in order (ARCHALUDON, GALLADE, GARCHOMP). ABC mode's A
  list reads ANTICIPATION, ARCHALUDON, ARENA TRAP, ATTACK, AUNT, so the other words still decode correctly with
  the shifted word IDs. Choosing ARCHALUDON and confirming returns to the field, and a wild battle afterwards
  works.

## Rename: Pokémon Sovereign Platinum

- The project is renamed from "Imperial Platinum" to **Pokémon Sovereign Platinum** (owner, 2026-10-22).
  - ROM header title: `SOVEREIGN PL`.
  - DS menu banner: "Pokémon Sovereign Platinum".
  - Code, docs, data and tools use "Sovereign" everywhere: file names such as `sovereign_options.c` and
    `docs/*_Sovereign.md`, identifiers such as `SovereignOptions`, the test-build option
    `meson -Dsovereign_test=true`, and code comments.
- **Unchanged:**
  - The save signature (`0x20261022`).
  - Every game mechanic.
  - The GitHub repository name (`pokemon-imperial-platinum`). The owner can rename the repository on GitHub, and
    GitHub redirects the old URL.

## E6 step 1 — engine prep for 1025 species (still 493 species)

Platinum assumed its 493 species in a dozen places. Each is now tied to the species list, so adding #494–1025
(step 2) won't break them. At 493 species the game behaves the same. The plan is in `docs/SpeciesExpansionPlan.md`.

- **Form data indices:** `Pokemon_GetFormNarcIndex` now counts from `SPECIES_BAD_EGG` instead of using literal
  496–503.
- **Trainer parties:** species uses 11 bits and form 5 (it was 10 and 6), so species up to 2047 fit.
- **Cries:** the sound archive's cry slots equal the species number.
  - Shaymin-Sky's cry moves from slot 494 to 1050.
  - The BASIC/BGM/SE banks move from 700–770 to 1100–1170.
  - Tools: `tools/audio/relayout_sound_banks.py`, plus `cjson_format.py`, which edits the archive's JSON without
    reformatting it.
- **Battle Hall records:** this save block gets 2 sectors (it holds 3 streaks per species), and the recordings move up
  one sector. A compile-time check confirms the block fits.
- **4-digit Pokédex numbers:**
  - Dex numbers and counts show 4 digits from 1000 on (`DEX_NUMBER_DIGITS`). This covers the Pokédex, the summary
    screen, the main menu, the save window, the Trainer Card and the numbered species names (including Japanese
    full-width digits).
- **Oak's National Dex ratings** scale with the dex size. The tiers are unchanged at 493.
- **GTS and Global Terminal:** the "by name" letter groups come from a header that speciesproc generates
  (`species_alphabet_groups.h`) instead of hard-coded numbers. The generated values match Platinum's.
- **Contests and dress-up:** these use the Diamond/Pearl sprites only for #1–493, since that archive stops there.
- **Smaller fixes:**
  - The Wi-Fi party check uses `MAX_SPECIES` and `MAX_MOVES`.
  - The Battle Hall record list can't overflow.
  - `NUM_EXCLUDED_NATIONAL` is a checked constant, so other files can use the dex goal.

## E14 (part) — HM field moves without HM slaves, Gen VI+ breeding

- **HM field moves:** once the bag has an HM, its field move works even if no party Pokémon knows it. Badge
  requirements are unchanged.
  - Cut, Rock Smash, Strength, Rock Climb, Surf and Waterfall work from their field prompts. The first non-Egg party
    Pokémon does the move.
  - Fly and Defog are added to every party Pokémon's menu.
  - Code: `src/sovereign_field_moves.c`, the script command `FindPartySlotForFieldMove`, and the Surf and Waterfall
    checks in `field_control.c`.
  - HM moves can be forgotten when learning a new move, on the summary screen and in battle
    (`SOVEREIGN_HMS_FORGETTABLE`). This builds but hasn't been tried in-game yet.
- **Gen VI+ breeding** (`daycare.c`):
  - An Everstone passes its holder's nature every time, from either parent.
  - A Destiny Knot passes 5 IVs instead of 3. This also fixes Gen IV's bug that could pick the same stat twice.
  - Egg moves come from either parent.
  - The egg comes in the mother's Poké Ball, or the non-Ditto parent's when breeding with Ditto (Master and Cherish
    Balls become a Poké Ball).
  - A parent with its Hidden Ability passes it 60% of the time.
  - The ball and Hidden Ability are kept when the egg hatches.
- Test build:
  - The bag now has HM02 and HM05, and there's a Ditto (Adamant, Everstone, 31 IVs). The Hidden Ability Gallade holds
    a Destiny Knot, is in an Ultra Ball, and has 31 IVs.
  - SELECT+L breeds the two and hatches the egg straight away.
  - `drive.py` accepts key combos such as `SELECT+L`.

Verified in the emulator:
- Fly and Defog show in the menus of Garchomp and Turtwig, which don't know them.
- The hatched Ralts has Adamant nature, an Ultra Ball, Telepathy (its Hidden Ability), and 31 in five IVs.
- The hatch shortcut skips the normal hatch script, so the test Ralts shows no hatch place or date.

## 10b (part 1) — Pokémon Champions battle rules

Rules and sources: `docs/BattleMechanics.md`. IVs, EVs and levels are unchanged (owner decision).

- **Status conditions:**
  - Full paralysis 1/8 (was 1/4); paralysis halves Speed (was ×0.25); Electric types can't be paralysed.
  - Sleep lasts 1 turn (1/3) or 2 turns (2/3) and the Pokémon acts on the turn it wakes (was 1–4 turns).
  - Freeze thaws 1/4 of the time on each move attempt and always on the third (was 1/5, no limit).
  - Burn deals 1/16 (was 1/8). Confusion self-hit chance is 33% (was 50%).
- **Turn order is dynamic:** before each action, the Pokémon still waiting to move are re-sorted by their current
  Speed and priority.
- **Critical hits:** ×1.5 (Sniper ×2.25) instead of ×2 (×3). Odds by stage are 1/24, 1/8, 1/2 and always.
- **Multi-hit moves:** 35/35/15/15% for 2/3/4/5 hits. **Protect** in a row: 1/3 the chance each time (was 1/2).
- **Weather:** weather from Drizzle, Drought, Sand Stream and Snow Warning lasts 5 turns, or 8 with the matching rock
  (it was permanent). These abilities do nothing if that weather is already up.
- **Hail becomes Snow:** no chip damage, and Ice types get ×1.5 Defense; the messages say snow. Hail and Snowscape
  both set it.
- **Fake Out** can't be selected after the user's first turn on the field. Choosing it shows "X can use Fake Out only
  on its first turn!".
- **Champions move values** (`tools/engine/apply_champions_moves.py`): 23 power/accuracy changes, Iron Head 20% flinch,
  Moonblast 10% Sp. Atk drop, Freeze-Dry no longer freezes, Snap Trap Steel, Growth Grass.
- **Not adopted for now:** Champions' fixed PP scale with no PP Ups (Sovereign keeps PP Ups, pending the owner's call),
  and its item and move roster limits (they are roster rules, not battle rules).
- **Verified:** both ROMs build; in the test build a wild battle runs several turns (new moves, damage, AI turns) with no errors. The odds-based rules are code changes checked by review, not by in-game sampling.
- **Left for roadmap item 11:** ability and move behaviour changes. These are Healer, Run Away, Unseen Fist, Make It
  Rain, Salt Cure, Rage Fist, the slicing/punching/sound flags, terrains, and the Gen V+ ability rules (Prankster vs
  Dark, Intimidate immunities).

## E14 (part) — Repel prompt

- When a Repel, Super Repel or Max Repel wears off and the bag still has one of the same kind, the game asks
  "Use another …?" (YES/NO). YES uses it straight away. Without one, the old "Repel's effect wore off..." message shows.
- The Repel used last is saved (a spare 2 bytes at the end of the special-encounter save block); two new script
  commands, `GetLastRepel` and `UseRepel`, drive the prompt in `CommonScript_RepelsEffectWoreOff`.

Verified in the emulator (test build: a Super Repel that ends after 3 steps, 2 more in the bag): the prompt names
the Super Repel, YES prints "A used the Super Repel." and the bag goes from 2 to 1.

## E2 / E4 — Gen IX abilities and Hidden Abilities

- **All 314 abilities**, ability ID = official ability number (`tools/engine/gen_abilities.py`, from PokeAPI;
  `docs/AbilityChecklist.md`). Platinum's 123 keep their Gen IV battle behaviour. The 191 newer ones (Gen V–IX and
  the Legends: Z-A Mega abilities) have names and descriptions that show on the summary screen, but **no battle effect
  yet**; the checklist tracks which get implemented (roadmap item 11). Names over 15 characters are shortened Gen V-style
  (e.g. NeutralizingGas); 79 descriptions were rewritten by hand to fit Gen IV's two-line box.
- **Ability IDs above 255:** the ability is stored as 9 bits in the Pokémon data (the old byte plus a spare bit in
  block B), and battle, AI, day care, wild-encounter and Battle Frontier code now carry it as 16 bits.
- **Hidden Abilities:** species data has a third ability slot. A Pokémon has a "hidden ability" flag (block B, kept
  through evolution); with it set, the Pokémon uses its species' Hidden Ability. Nothing gives the flag yet (wild
  Pokémon and gifts never start with it); breeding, the Ability Patch and boss trainers will use it later.
- **Species abilities (#1–493 and forms):** Gen IX ability 1 / ability 2 / Hidden Ability
  (`tools/engine/gen_species_gen9.py`; changes listed in `docs/SpeciesGen9Changes.md`).

Verified in the emulator (test build): a Gallade with the flag shows **Justified** (its Hidden Ability) and one given
**Sharpness** (ID 292) shows it with the new description, so the 9th bit is stored and read back; the IV/EV viewer
(E14) cycles stats → IVs → EVs on the SKILLS page as intended. The normal build passes.

## E3 — Gen IX moves (data pass)

- **All 919 moves**, move ID = official move number (`tools/engine/gen_moves.py`, from PokeAPI; `docs/MoveChecklist.md`).
- **Platinum's 467 moves** keep their battle effects; 103 of them take Gen IX power, accuracy, PP, type or priority
  (e.g. Tackle 40/100, Flamethrower 90, Charm/Sweet Kiss/Moonlight → Fairy, Protect +4, Fake Out +3). Priorities all
  use the Gen IX scale, so relative order stays consistent.
- **380 new moves** (#468–919) with Gen IX type, category, power, accuracy, PP, priority, target, contact/protect/
  Magic Coat/Snatch/Mirror Move flags, a description (newest flavour text that fits Gen IV's box) and an animation
  borrowed from an existing move of the same type and category. Each is mapped to Platinum's battle effects:
  **93 exact, 76 approximate, 211 placeholder** (plain hit / does nothing). Names over 15 characters are shortened
  Gen V-style (e.g. PrecipiceBlade); the rest fit the move buttons as they are.
- **No Z-Moves or Max Moves** (owner decision): their 72 numbers are empty slots with 0 PP that nothing can learn;
  Metronome skips them.
- **Learnset format:** level-up entries are now 32-bit (`u16` move + `u16` level), up to 48 per species; the move
  reminder and day care follow.

Verified in the emulator (test build): Garchomp with Precipice Blades, Dazzling Gleam, Play Rough and Electroweb —
names, types and PP show on the move buttons, and Precipice Blades hits with its animation; the battle (AI move
table now 920 entries) runs normally. Boot smoke test passes. **Next:** E5 learnsets so species actually learn the
new moves; effect fidelity for the approximate/placeholder moves is roadmap item 11.

## Test build (never shipped)

- `meson -Dsovereign_test=true` (`tools/test/build_test_rom.sh` → `decomp/build_test/`): a new game starts with a test
  party (Garchomp 50 with Gen IX moves, Turtwig 15, Starly 5, two Gallade 30 with Justified and Sharpness) and items (3 Rare Candies, 10 Potions, 10 Poké Balls). In the overworld,
  **SELECT** starts a wild battle (Chansey Lv. 30) and **SELECT+R** a trainer battle (Barry, Route 209). Normal builds
  and CI don't define `SOVEREIGN_TEST`, so none of this is in the real game.
- Fixed while building it: the setup first allocated from a heap that doesn't exist yet at new-game start (the NULL
  write corrupted ITCM code → crash); it now uses `HEAP_ID_FIELD2`. The first battle hook used the script engine and
  landed on the wrong script; it now starts the battle from a small field task.

## E1 — Sovereign identity and save format

- **Own save signature** (`SECTOR_SIGNATURE` 0x20261022 instead of Platinum's 0x20060623). A Platinum or Renegade
  Platinum save fails the check and loads as "no save data" (the game goes straight to a new game) instead of being
  misread by Sovereign's different save layout.
- **ROM header title** `SOVEREIGN PL` and **DS menu banner** "Pokémon Sovereign Platinum". The game code stays `CPUE`
  so emulators, save tools and cheat databases still recognise the game and its save type.

Verified: a save written by the previous build loads on that build (Continue → Route 201) and is treated as empty by
the new build (new game starts); header and banner read back from the ROM; boot smoke test passes.

## E14 (part) — IV/EV viewer on the summary screen

- On the **SKILLS** page, **SELECT** cycles the six numbers between stats, IVs and EVs. The page title changes to
  "POKéMON SKILLS" / "POKéMON IVs" / "POKéMON EVs"; the view is kept while switching Pokémon or pages.

Verified in the emulator (test build, with the E2/E4 pass): SELECT cycles the SKILLS page through stats, IVs and EVs, with the title changing to match.

## E13 — Options additions (level cap, Infinite Rare Candy, party Exp. Share, music volume)

- **Options menu:** four new rows in the normal OPTIONS list, after FRAME: **LEVEL CAP** (ON/OFF, default OFF),
  **INF. CANDY** (ON/OFF, default OFF; grayed out and locked while the level cap is OFF), **EXP. SHARE** (ON/OFF,
  default ON) and **MUSIC** (0–100 in steps of 5, shown as a number and a bar; hold left/right to move quickly, and the
  volume changes as you move it). The list now has 11 rows and scrolls, with arrows at the right of the title bar
  when there are rows above or below. The YES/NO confirmation covers the new settings too.
- **Save data:** the settings live in `SovereignOptions` (`include/sovereign_options.h`), a 16-bit field in the player
  save block that used to be padding, so the save size is unchanged.
- **Level cap** (`src/level_cap.c`, table `include/data/level_caps.h` generated from `data/level_caps.yaml` by
  `tools/engine/gen_level_caps.py`): the cap is the ace level of the first big fight not yet beaten, checked with the
  trainers' defeated flags. While on, party Pokémon at the cap gain no EXP (EVs are still gained), and EXP that would
  go past the cap stops at the cap. Rare Candies can't raise a Pokémon past it.
- **Infinite Rare Candy:** Rare Candies aren't removed from the bag when used. Turning the option on gives one Rare Candy
  if the bag has none.
- **Party Exp. Share:** when on, every non-fainted party member gets EXP from each battle: Pokémon that battled get the
  full amount, the rest get half. When off, the held Exp. Share works as in vanilla.
- **Music volume:** scales the field and BGM players (`Sound_SetMusicVolumePercent`); sound effects and cries are
  unaffected. Applied at boot from the save and whenever the option changes.

Verified in the emulator (`tools/test/drive.py`) on a new save: the list scrolls and wraps in both directions with
the right arrows; the toggles work; INF. CANDY stays locked while the level cap is OFF and turns off with it; the
slider moves; YES saves and reopening shows the saved values; turning INF. CANDY on adds a Rare Candy to the Medicine
pocket. Build passes. **In-battle check (test build, 2026-10-22):** with the cap at 16 and party Exp. Share on, one
wild battle left Garchomp (fought, Lv. 50, above the cap) at Lv. 50, took Turtwig (didn't fight) from 15 to exactly 16,
and Starly (didn't fight) from 5 to 10; a Rare Candy then raised Starly to 11 and was used up (Infinite Candy off), and
on Turtwig at the cap it said "It won't have any effect".

## Fairy type and Gen VI+ type chart

- **Fairy type added**, taking the slot of the unused `???` type (index 9), as Renegade Platinum does.
  - Type chart: Fairy beats Fighting, Dragon and Dark; is resisted by Fire, Poison and Steel. Fighting, Bug and Dark are
    resisted by Fairy; Poison and Steel beat it; Dragon has no effect on it.
  - Steel no longer resists Ghost or Dark (Gen VI change).
  - New FAIRY type icon (`res/graphics/battle/type_icons/fairy.png`), assembled from the game's own type-icon letters in
    the official Fairy pink; the type name is "FAIRY".
  - The Pokétch Move Tester chart has the same changes.
- **Curse is Ghost-type** (Gen V+). Conversion no longer treats `???`-type moves as Curse.
- Hidden Power still can't be Fairy-type (Gen VI+ rule).
- The TV "type of the day" segment can now pick Fairy.
- **Not yet:** Fairy in the Pokédex type search (the search screen has 17 slots), Battle Hall type grid, and Fairy-type
  moves and Pokémon (these arrive with the Gen IX move and species data, milestones E3/E5).

Verified: `tools/test/check_type_chart.py` (all 324 matchups in both charts match PokeAPI's official chart; vanilla fails
with 40 mismatches), build, headless boot test.

## E0 — decomp import

- pret/pokeplatinum @ `76620288` vendored as `decomp/`. The build reproduces the retail US Rev 1 ROM
  (sha1 `0862ec35b24de5c7e2dcb88c9eea0873110d755c`).
- rapidjson/yyjson build overlays vendored (no wrapdb downloads needed).
