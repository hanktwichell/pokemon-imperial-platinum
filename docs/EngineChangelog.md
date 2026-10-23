# Sovereign Platinum — Engine Changelog

Changes made to the pret/pokeplatinum decompilation in `decomp/`, newest first. Each entry lists what changed for
players and the verification that was run.


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
## E11 — The Chronicles begin: the Legend Archivist and Virizion

The first part of the post-game legendaries (`docs/PostgameLegendaries.md`):
- **The Legend Archivist** stands in Canalave Library 2F from the first Hall of Fame. His first talk opens the Unova
  Chronicle: "Since your Hall of Fame entry, people have reported Pokémon never before recorded in Sinnoh... Its
  legends tell of three Pokémon who stood together like swords. And now one of them, VIRIZION, has been seen in
  northern Eterna Forest." Later talks give the hint again, then "You found VIRIZION!..." once it's caught.
- **Virizion** (Lv. 65) stands at the top of Eterna Forest's north corridor, past the Cut trees, once the Chronicle
  is open.
  - Talking to it: "VIRIZION cried out!", then the battle.
  - After a win or a run: "VIRIZION vanished... It might show itself here again." It is back on the next visit,
    until it's caught.
- **For the rest of the Chronicles:** a shared encounter script, a script command that checks the Pokédex for a
  caught species (so no flag is needed per Pokémon), and overworld sprites made from PokeAPI's front sprites by
  `tools/sprites/make_legendary_overworld.py`. Cobalion, Terrakion and Keldeo are drawn already.
  `make_totem_overworld.py` gained an `aura` switch; the Totem sprites come out byte for byte the same.
- `docs/PostgameLegendaries.md` now shows what is built.
- **Verified** (test build; a temporary patch set the game completed and added Master Balls, with test warps):
  - Virizion hidden before the Chronicle opens, the Archivist's lines, then Virizion in the forest.
  - A run (the vanished line, gone, and back on the next visit), and a Master Ball catch.
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
