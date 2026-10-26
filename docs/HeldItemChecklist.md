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
| Float Stone | not yet |
| Rocky Helmet | yes: an attacker that makes contact loses 1/6 of its max HP, each hit, even as the holder faints (not through a Substitute, Magic Guard or Protective Pads) |
| Air Balloon | not yet |
| Red Card | not yet |
| Ring Target | not yet |
| Binding Band | not yet |
| Absorb Bulb | not yet |
| Cell Battery | not yet |
| Eject Button | not yet |
| Weakness Policy | not yet |
| Assault Vest | yes: Sp. Def ×1.5; status moves can't be selected ("The Assault Vest prevents status moves from being used!") |
| Luminous Moss | not yet |
| Snowball | not yet |
| Safety Goggles | yes: powder moves and Effect Spore don't affect the holder, nor does sandstorm damage (Snow does none) |
| Adrenaline Orb | not yet |
| Terrain Extender | yes: terrain lasts 8 turns |
| Protective Pads | yes: the holder's moves make no contact |
| Electric Seed, Psychic Seed, Misty Seed, Grassy Seed | yes: Defense or Sp. Def +1 in their terrain, used up |
| Throat Spray | not yet |
| Eject Pack | not yet |
| Heavy-Duty Boots | yes: no Stealth Rock, Spikes, Toxic Spikes or Sticky Web on entry (a grounded Poison type still takes the Toxic Spikes away) |
| Blunder Policy | not yet |
| Room Service | not yet |
| Utility Umbrella | not yet |
| Booster Energy | yes: starts Protosynthesis or Quark Drive |
| Ability Shield | not yet |
| Clear Amulet | yes: other Pokémon's moves and Abilities can't lower the holder's stats ("{0}'s Clear Amulet prevents stat loss!") |
| Mirror Herb | not yet |
| Punching Glove | yes: punching moves ×1.1 and make no contact |
| Covert Cloak | yes: other Pokémon's moves' chance effects don't affect the holder |
| Loaded Dice | not yet |
| Fairy Feather | yes: Fairy moves ×1.2 |
| Pixie Plate | yes: Fairy moves ×1.2; Arceus becomes Fairy type |
| Pass Orb | no battle effect (none in the main games either) |
| The 18 Gems | not yet |
