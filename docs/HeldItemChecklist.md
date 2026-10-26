# Sovereign Platinum — Held Item Checklist

The Gen V+ held items that Sovereign sells: Veilstone Dept. Store 2F, held items and Gems
(`data/items_sovereign.yaml`, `include/data/sovereign_mart_items.h`). This list says which items already work in
battle (roadmap item 11).

Platinum's own held items keep their Gen IV behaviour. Mega Stones, Orbs, Plates, Drives, Memories and other
form-setting items work through the form tables (milestone FM), so they aren't listed here.

The new items have no hold effect constant (`HOLD_EFFECT_NONE`). The battle code checks the item itself, with
`Battler_HeldItem`, which already gives `ITEM_NONE` under Klutz, Embargo and Magic Room.

| Item | Battle effect |
|---|---|
| Eviolite | yes: Defense and Sp. Def ×1.5 while the holder can still evolve (`Pokemon_SovereignCanEvolve`; regional forms have their own evolutions, Megas and other battle forms never evolve) |
| Float Stone | yes: the holder's weight is halved (Low Kick, Grass Knot, Heavy Slam, Heat Crash), on top of Light Metal |
| Rocky Helmet | yes: an attacker that makes contact loses 1/6 of its max HP, each hit, even as the holder faints (not through a Substitute, Magic Guard or Protective Pads) |
| Air Balloon | yes: Ground moves don't affect the holder ("It doesn't affect {0}…"), and it isn't grounded (terrain, Spikes, Toxic Spikes, Sticky Web). Shown on entry; pops when a damaging move hits the holder. Gravity, Ingrain and Smack Down ground it as they ground Magnet Rise |
| Red Card | yes: when a damaging move hits the holder, the attacker is dragged out as by Dragon Tail ("{0} held up its Red Card against {1}!"), used up even if Suction Cups or Ingrain keep it in; a wild attacker flees. Not after U-turn and the like, through a Substitute, or when Sheer Force powered the move |
| Ring Target | yes: the holder's type immunities don't apply (a Ghost type takes Normal and Fighting moves, a Flying type Ground moves...); its Abilities still do (Levitate, Volt Absorb...) |
| Binding Band | yes: a binding move the holder used costs its target twice as much at the end of each turn (1/8 of its max HP; Sovereign keeps Platinum's 1/16) |
| Absorb Bulb | yes: Sp. Atk +1 when a Water move hits the holder, used up |
| Cell Battery | yes: Attack +1 when an Electric move hits the holder, used up |
| Eject Button | yes: when a damaging move hits the holder, it switches out to a Pokémon its trainer picks ("{0} is switched out with the Eject Button!"), used up. Nothing happens with no Pokémon to switch to (a wild holder). After U-turn and the like, both switch out (Champions). Not through a Substitute, or when Sheer Force powered the move |
| Weakness Policy | yes: Attack and Sp. Atk +2 when a super-effective move hits the holder, used up |
| Assault Vest | yes: Sp. Def ×1.5; status moves can't be selected ("The Assault Vest prevents status moves from being used!") |
| Luminous Moss | yes: Sp. Def +1 when a Water move hits the holder, used up |
| Snowball | yes: Attack +1 when an Ice move hits the holder, used up |
| Safety Goggles | yes: powder moves and Effect Spore don't affect the holder, nor does sandstorm damage (Snow does none) |
| Adrenaline Orb | yes: Speed +1 after an Intimidate that targets the holder, even one an Ability keeps off (Hyper Cutter...); not when its Attack is already at -6. Used up |
| Terrain Extender | yes: terrain lasts 8 turns |
| Protective Pads | yes: the holder's moves make no contact |
| Electric Seed, Psychic Seed, Misty Seed, Grassy Seed | yes: Defense or Sp. Def +1 in their terrain, used up |
| Throat Spray | yes: Sp. Atk +1 after the holder uses a sound move that works, used up |
| Eject Pack | not yet (not in Champions) |
| Heavy-Duty Boots | yes: no Stealth Rock, Spikes, Toxic Spikes or Sticky Web on entry (a grounded Poison type still takes the Toxic Spikes away) |
| Blunder Policy | yes: Speed +2 after the holder's move misses, used up |
| Room Service | yes: Speed -1 under Trick Room, on entry or as Trick Room starts, used up |
| Utility Umbrella | yes: rain and harsh sunlight don't act on the holder. Fire and Water moves hitting it take no weather change, and its Abilities (Swift Swim, Chlorophyll, Rain Dish, Dry Skin, Hydration, Solar Power, Leaf Guard, Flower Gift, Forecast, Orichalcum Pulse) and moves (Solar Beam, Solar Blade, Electro Shot, Synthesis, Weather Ball, Hydro Steam) act as if there were none. Thunder and Hurricane aimed at it, and freezing, ignore the weather too. Its own Fire and Water moves are still boosted, Protosynthesis still works, and a primal weather's Fire or Water moves still fail |
| Booster Energy | yes: starts Protosynthesis or Quark Drive |
| Ability Shield | yes: the holder's Ability can't be changed or suppressed (Worry Seed, Gastro Acid, Simple Beam, Entrainment, Role Play, Skill Swap: "{0}'s Ability Shield protects its Ability!"; Mummy, Lingering Aroma, Wandering Spirit and Trace do nothing), and Mold Breaker, Turboblaze and Teravolt don't ignore it. Klutz doesn't stop it; Magic Room and Embargo do |
| Clear Amulet | yes: other Pokémon's moves and Abilities can't lower the holder's stats ("{0}'s Clear Amulet prevents stat loss!") |
| Mirror Herb | yes: copies the stat rises the holder's foes get (moves, Abilities, items) after the move, switch-in or Mega Evolution that gave them, then is used up ("The Mirror Herb raised {0}'s Attack!"). A rise at the end of a turn (Speed Boost) is copied after the next move. Not its own copied rises |
| Punching Glove | yes: punching moves ×1.1 and make no contact |
| Covert Cloak | yes: other Pokémon's moves' chance effects don't affect the holder |
| Loaded Dice | yes: the holder's 2-5 hit moves hit 4 or 5 times |
| Fairy Feather | yes: Fairy moves ×1.2 |
| Pixie Plate | yes: Fairy moves ×1.2; Arceus becomes Fairy type |
| Pass Orb | no battle effect (none in the main games either) |
| The 18 Gems | yes: the holder's first damaging move of the Gem's type is ×1.3 (Gen VI+), and the Gem is used up as it hits ("The Normal Gem strengthened Tackle's power!", after "used"). Status moves and fixed-damage moves don't use it |
