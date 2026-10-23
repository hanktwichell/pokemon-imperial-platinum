# Sovereign Platinum — Story

Status: **direction decided by the owner (2026-10-22)**. Text is still to be written. The owner writes Henry's
dialogue; the other text follows the beats below. Owner decision 23 in `docs/ProjectStatus.md`.

## The Sovereign

- **Who they are:** the old ruling class of Sinnoh, who held its throne at Spear Pillar.
- **What the player sees:** nothing directly. The Sovereign are never seen by the player, and their story runs in
  parallel with Team Galactic's.
- **What they've been doing:** working behind the scenes to merge other Pokémon worlds into Sinnoh.
- **The last of the line:** Henry, a descendant of the old ruling class and the only surviving member of the
  lineage. He is the final opponent: **Sovereign Henry** (class "Sovereign", name "Henry"). His dialogue nods to him
  being the game's developer; the owner writes it.

## The end goal: shield, leading into succession (owner: "3 leading into 1")

1. **The shield.** The Sovereign foresaw that Team Galactic's leader would tear Sinnoh's space and time apart at
   Spear Pillar. To hold the region together they began stitching other Pokémon worlds into it. The Ultra Wormholes,
   the Pokémon from other regions, the regional forms and the Totems are those stitches.
2. **The succession.** The Sovereign who began the stitching are gone. Henry, their only heir, has held the seams
   alone, and they can't be held by one person forever. The Totem trials are how he has been looking for someone fit
   to take over.
3. **The ending.** At the throne at Spear Pillar, Henry tests the player. Beating him hands the role on: **the player
   is granted the Sovereign title**, the name the game is called by.

How it ties together:
- **Team Galactic** is the crisis the Sovereign were bracing for, so the two stories run side by side and meet at
  Spear Pillar.
- It explains why every region's Pokémon is in Sinnoh.
- It explains why the Totems are tests.
- It ends with the player earning the game's title.

## Story beats

The player learns about the Sovereign passively, without ever meeting one before Henry.

### Early: two vague references (owner: both)
- **Oreburgh Mining Museum** (first Gym town): a new exhibit, a stone fragment carved with a crown and the line
  *"The Sovereign keep the seams."* Nobody knows what it means. Built (CB-0034): under the window at the top right
  (18, 3), drawn with Mt. Coronet's cave-painting shards.
- **Professor Rowan:** a remark that Pokémon never recorded in Sinnoh have started turning up, and he can't explain
  where they're coming from. Built (CB-0034): right after he gives the Pokédex.

### Along the main story, alongside Galactic
- **Totem trials:** each one leaves a crown piece behind (see *The crown*). The Galactic encounters wait on them,
  and the pieces slowly reveal a crown. The last trial (Totem Togedemaru, Vista Lighthouse) gives the Crown Diamond
  that completes it.
- **Celestic Town** (Galactic's attack on the ruins): the elder's story mentions the rulers who sat at Spear Pillar.
  Built (CB-0034): two lines in her speech after Cyrus leaves, before she gives HM03.
- **Canalave Library:** a new book on the Sovereign, mostly missing pages. Built (CB-0034): "The Sovereign", on the
  3F myth shelf at (12, 3), beside "Sinnoh Region's Mythology".
- **Spear Pillar** (Galactic's climax): a brief glimpse of ruins on the summit showing a throne that was never part
  of Platinum's map. It goes unexplained, and the story moves on to Giratina.

### After the Hall of Fame: event order (owner)

1. **First time as Champion** (first Hall of Fame entry). The player is directed to **Spear Pillar** to resolve a
   disturbance involving Dialga and Palkia. Both can be **caught** there. The **Celestic Town elder** meets the
   player at home (where they wake after the Hall of Fame) and sends them to Spear Pillar (owner).
2. **The Elite Four rematch stays locked until both the Dialga and Palkia encounters are completed.** Platinum has
   no NPC who prompts you to save, so the door guard in the League's north Pokémon Center blocks the rematch until
   then (built, CB-0033).
3. **Elite Four rematch.** Once it's open, the player may rematch the Elite Four any number of times, from completing
   Dialga and Palkia up to the Sovereign battle.
4. **After beating Cynthia the second time,** Cynthia directs the player back to Spear Pillar to resolve the mystery
   that has been unfolding all game. With the complete crown (all 11 trials), Sovereign Henry appears at the throne.
5. **After the Sovereign battle,** the Elite Four can still be rematched, and from then on **every Elite Four member
   and Cynthia has a Lv. 100 team** (owner).

Alongside these, after the first Hall of Fame:
- **The Chronicles** (Archivist): each chapter's legendaries arrive from another world. The Archivist works out that
  someone opened the way on purpose, and starts to suspect the Sovereign.
- **Regional Forms Park:** its owner keeps a log of where each regional form "came through".

### The final battle: Sovereign Henry at the throne
- **Before the battle,** Henry refers to the Totem trials: the player has passed all **11** of his trials, so they're
  the one he has been waiting for. The owner writes the dialogue, along with what the Sovereign were doing; every hint from the
  early game, the trials and the Chronicles pays off here.
- **The battle:** the developer team, Lv. 100 doubles (`docs/DeveloperBattle.md`).
- **After the battle:** the player is granted the **Sovereign title**. It shows on the Trainer Card, in the Hall of
  Fame record, and in how NPCs address the player from then on (owner).
- **Cynthia arrives** to congratulate the player (owner):
  - She is very close to Henry. Their exact relationship is hinted at but never stated, and kept PG.
  - She is the reason Henry uses a Garchomp, her signature Pokémon.
  - **The two Garchomp are a pair** (owner): Henry's is male, Cynthia's is female. A quiet hint at the two of
    them. Cynthia's Garchomp is female in Platinum already (trainers' 50/50 species take the trainer's gender);
    Sovereign's Cynthia teams set it explicitly (T1) so it can't change.

## Totem trials: gates and the crown (owner, 2026-10-22)

The Totem trials are part of the story's path: Team Galactic's encounters wait on them, and the crown they leave
behind is what calls the Sovereign to Spear Pillar.

### Galactic encounters wait on the trials (owner)

Each Team Galactic encounter stays out of reach until the trials placed before it (`data/totem_trials.yaml`, in the
fight order of `data/level_caps.yaml`) are completed. The gate uses NPCs who already block the way in Platinum: where
one stands somewhere useful, "the trial is done" is added to what moves them (owner: "There are a few NPCs who block
the map already; if they're placed in opportune areas, add the totem trial to the criteria to unlock them"). Where no
such NPC exists, a new one is placed (E11 finds them).

| Galactic encounter | Trials needed first |
|---|---|
| Commander Mars (Valley Windworks) | Gumshoos (Route 205 South) |
| Commander Jupiter (Eterna Building) | Ribombee (Floaroma Meadow), Vikavolt (Eterna Forest) |
| Galactic Boss Cyrus (Celestic Town) | Mimikyu (Old Chateau), Alolan Marowak (Lost Tower), Alolan Raticate (Galactic Warehouse), Lurantis (Great Marsh), Araquanid (Route 213) |
| Saturn and Mars (the lakes) | Salazzle (Fuego Ironworks) |
| Mars and Jupiter (Spear Pillar) | Kommo-o (Mt. Coronet) |
| Victory Road (owner) | Togedemaru (Vista Lighthouse): the last trial, after the Distortion World. The gate at Victory Road's entrance checks it as well as the eight badges |

- The blocking NPC's line nudges the player toward the open trial (e.g. a huge Pokémon nearby that won't leave),
  so the gate doubles as the prompt.
- This changes decision 18: the trials are no longer optional. All 11 are done before the Elite Four, so the crown
  is always complete by the first Hall of Fame.
- **Built (CB-0031):** each gate and what it says while its trials are open.
  - **Mars:** the Galactic grunt at the Valley Windworks door won't battle: "There's a huge GUMSHOOS glaring at me
    from the flowers by the river!"
  - **Jupiter:** a new grunt guards the Galactic Eterna Building's door, behind the Cut trees: "nobody gets in while
    the Totems roam! There's a huge RIBOMBEE in Floaroma Meadow, and a VIKAVOLT in the forest." He's gone once both
    are done.
  - **Cyrus:** the grunt in front of the Celestic ruins won't battle, and names the five places: "You haven't even
    faced every Totem roaming Sinnoh yet!"
  - **Saturn and Mars:** the Route 218 blockade (the dancers and their Clefairy and Pikachu) now stays until Salazzle's
    trial is done, instead of leaving once Cyrus is beaten. After Cyrus the Guitarist says a huge SALAZZLE chased them
    out of their practice spot at the Fuego Ironworks. So Canalave, Barry and Byron wait on it too, which matches
    Salazzle's level, set under Barry's cap.
  - **Mars and Jupiter:** the Spear Pillar grunts send the player back: "You couldn't even get past that KOMMO-O down
    on the mountain, huh?"
  - **Victory Road:** Platinum has no check there (Waterfall is the real gate), so a new guard stands at the entrance.
    Without all eight Badges: "Only Trainers who have gathered all eight Badges may enter Victory Road." With them
    but before Togedemaru's trial: "But a huge TOGEDEMARU is sparking atop Sunyshore's Vista Lighthouse."

### The crown (owner)

- **After each trial,** once the follow-up encounter where the Totem can be caught is over (**whether or not the
  player catches it**), the player finds a crown piece on the ground.
- **The pieces** (owner: a mix of rubies, emeralds, sapphires and gold shards/fragments). The key-items pocket shows
  no counts, so each piece has its own name. Every jewel is a finished, cut stone fit for royalty (owner: no uncut
  gems on the Sovereign's crown); each kind comes twice, told apart by cut (oval and rose; the rose cut is the classic cut of old crown jewels). Names and order are a
  proposal; the owner can rename any of them:

  | # | Trial | Piece |
  |---|---|---|
  | 1 | Gumshoos (Route 205 South) | Gold Shard |
  | 2 | Ribombee (Floaroma Meadow) | Oval Emerald |
  | 3 | Vikavolt (Eterna Forest) | Gold Fragment |
  | 4 | Mimikyu (Old Chateau) | Oval Sapphire |
  | 5 | Alolan Marowak (Lost Tower) | Oval Ruby |
  | 6 | Alolan Raticate (Galactic Warehouse) | Gold Sliver |
  | 7 | Lurantis (Great Marsh) | Rose Emerald |
  | 8 | Araquanid (Route 213) | Rose Sapphire |
  | 9 | Salazzle (Fuego Ironworks) | Rose Ruby |
  | 10 | Kommo-o (Mt. Coronet) | Gold Flake |
  | 11 | Togedemaru (Vista Lighthouse) | **Crown Diamond** |

  Each piece belongs to its trial, so the order a player finds them in can vary slightly where two trials share a
  stretch of the story (e.g. Ribombee and Vikavolt). Gumshoos always comes first and Togedemaru always last.
- **Can't be sold or thrown away:** all are key items.
- **The realisation:** as the pieces add up, their descriptions start to hint that they fit together into a crown.
- **The Crown** (owner): when the 11th piece is found, the pieces merge into one key item, the **Crown**.
- **The Sovereign Crown** (owner): after the player beats Cynthia in the Elite Four rematch, the Crown becomes the
  **Sovereign Crown**.
- **The gate:** the **complete crown is required for the Sovereign to appear at Spear Pillar.** With Victory Road
  gated on the last trial, every player has it by then.
- **Icons:** the 11 pieces, the Crown and the Sovereign Crown are on the owner's sprite list
  (`docs/SpriteChecklist.xlsx`, sheet *Item Icons*, from `data/item_sprites.csv`). Until they arrive, the game uses
  placeholders drawn by `tools/sprites/make_crown_icons.py`.

## Oak's visit to Rowan's lab (redo, draft for the owner)

Platinum's scene: when the player shows Rowan a complete Sinnoh Pokédex, Oak arrives, upgrades it to the National
Pokédex (fanfare) and sends the player to Pal Park on Route 221. In Sovereign the National Dex comes with the Pokédex
(decision 21) and Pal Park is gone (decision 22), so both halves are wrong. Worse, the script only plays it while the
National Dex is off, so as things stand the scene, and the Fight Area unlock it carries, would never play.

**Proposed:** keep the trigger (a complete Sinnoh Pokédex) and the cameo, drop the upgrade, and make Oak's errand part
of the story: Pokémon from every region are turning up, the strange regional forms gather on Route 221, and that's
the **Regional Forms Park**. It follows on from Rowan's early remark (*Early: two vague references*).

Draft text (new lines in **bold**; the greetings stay as in Platinum):

- Oak: Greetings, Professor Rowan! It's been a very long time! … *(unchanged)*
- Rowan: Oh! If it isn't my old colleague, Professor Oak! … *(unchanged)*
- Rowan: Professor Oak, let me introduce you to my young assistant. This youngster has filled every page of the
  Sinnoh Pokédex for me. *(unchanged)*
- **Oak: Ah, very glad to meet you! My name is Oak. Professor Rowan has told me a great deal about you.**
  **I see you already carry a National Pokédex. Rowan was ahead of us all, it seems.**
  **In truth, that's why I've come. Pokémon from Kanto, from every region, have been turning up here in Sinnoh,**
  **and no one can say how they got here.**
- **Rowan: Then I was right to worry. I'd hoped it was a quirk of this region alone.**
- **Oak: Stranger still, some of them look like no Pokémon I know. A Vulpix as white as snow… a Meowth from Galar…**
  **The odd ones keep gathering on the old grounds at the end of Route 221. They've been made into a park for them:**
  **the Regional Forms Park.**
- **Oak: {PLAYER}, you should take a look. Whatever is bringing them here, someone ought to keep a record.**
  Oops! I'll be late for my meeting if I don't get going! OK, it was a pleasure seeing the both of you! Bye, now!
  *(the farewell unchanged)*

Removed: "Let me upgrade your Pokédex", "…was upgraded with the National Mode!" and its fanfare, "It won't be easy
to complete the National Pokédex", and both Pal Park lines. Rowan still gives the Poké Radar afterwards.

**Engineering:** the scene's check changes from "National Dex off" to a new "Oak's visit seen" flag. The Fight Area
blockade it lifts and the `FLAG_GAME_COMPLETED` step stay. If the Regional Forms Park opens with this scene, it
sets that flag too.

**Route 221 text:**
- "Pal Park isn't open yet. We're still setting up." → **"The park isn't open yet. We're still setting up."**
- "We're getting Pal Park ready. I wonder what you can do there?" → **"We're getting the park ready. Some very odd
  Pokémon have been wandering in…"**
- Sign: "Pal Park / A Place for New Beginnings" → **"Regional Forms Park / Where Far-Off Forms Gather"**
- These three are in the game (CB-0026), with the park's lobby: Oak's first-visit lines ("This is it! The Regional
  Forms Park! … They gather here, in forms from Alola, Galar, Hisui and Paldea.") and the worker's welcome.
- **Lobby visitors** (drafts, CB-0026). Their Catching Show lines now talk about the park:
  - the girl wants to see a white Vulpix, and her dad says she makes him bring her to the park;
  - the boy loves seeing Pokémon from far-off regions;
  - a Trainer says the evolved ones are rare and the Galarian birds rarer;
  - another says each region keeps to its own corner;
  - two ladies' "Pal Park" and "Catching Show" lines now say "this park" and "the Pokémon in the park".

**Other lines:** Dawn/Lucas, Bebe (Hearthome) and the woman in the counterpart's house mention the National Pokédex
as something newly earned. They still read fine with the National Dex from the start, but they'd appear from early
on. Pal Park's lobby, the GBA Migrate text and the Pal Park TV commercial go with Pal Park (decision 22).

Owner's call:
1. Keep the trigger at a complete Sinnoh Pokédex, or move it (e.g. the first Hall of Fame)?
2. Should the park open with this scene, or earlier or later? This also settles the open Regional Forms Park question.
3. Since there's no upgrade any more, should Oak give the player something?

## Engineering notes

- **Dialga/Palkia trigger:** the first Hall of Fame entry. In Platinum it isn't the National Pokédex: the Celestic
  elder sets `FLAG_UNLOCKED_DIALGA_PALKIA_SPEAR_PILLAR` in her house after the Hall of Fame, and Mt. Coronet 6F then
  leads to Dialga or Palkia for a player holding the Adamant or Lustrous Orb. Built (CB-0033): the elder's scene at
  home sets it, and her line tells the player about the Orbs.
- **Celestic elder at home:** a scene in the player's house the first time they wake there after the Hall of Fame.
  Built (CB-0033): she waits downstairs with Mom, sends the player to the Spear Pillar and leaves. Mom's Platinum
  line about the rival follows.
- **Galactic gates:** each gating NPC's script checks the trial flags in the table above (one flag per trial, set
  when its catch encounter ends). Built (CB-0031), see the list under the table.
- **Crown pieces:** 13 new key items (key items can't be sold or tossed): the 11 pieces, the Crown and the
  Sovereign Crown. Picking up the 11th piece removes the 11 and gives the Crown. Beating Cynthia in the rematch
  swaps the Crown for the Sovereign Crown. Built (CB-0028): the 13 items, each trial's piece, and the merge into the
  Crown (`CommonScript_SovereignTotemTrial`). Built (CB-0033): the swap for the Sovereign Crown, in the Champion room
  after the first rematch win.
- **Victory Road gate:** Platinum has no check at Victory Road's entrance, so a new guard checks the eight Badges and
  Togedemaru's trial flag (CB-0031).
- **Elite Four rematch lock:** the League's door guard checks a "Dialga and Palkia both done" condition (caught, or
  the battle won or fled) before letting the player through for a rematch. Built (CB-0033).
- **Henry's unlock:** the second win against Cynthia (the Elite Four rematch, Sovereign's E4 format:
  `docs/EliteFourFormat.md`) sets the flag, and Cynthia's scene sends the player there. Henry appears only if the
  player also holds all 11 crown pieces. Elite Four rematches stay repeatable throughout. Built (CB-0033): the flag
  (`FLAG_SOVEREIGN_CALLED_TO_SPEAR_PILLAR`) and Cynthia's lines; Henry's appearance comes with the throne room.
- **Elite Four after the Sovereign:** a third set of teams for the Elite Four and Cynthia, all Lv. 100, used once
  Henry is beaten (T1, with the boss team compositions).
- **The Sovereign title** shows in three places (owner): the Trainer Card, the Hall of Fame record, and NPC lines
  after the battle (a flag the relevant scripts check).
- **Cynthia's appearance:** a scripted scene after the battle at Spear Pillar, using her existing overworld sprite.
- **New text:** the crown pieces' descriptions, the gating NPCs' lines, the Celestic elder at home, the Oreburgh exhibit, Rowan's remark, the Celestic elder's lines, a Canalave book, the Archivist's
  lines, the Regional Forms Park log, Cynthia's lines after the battle. Henry's intro, defeat and ending text: the
  owner.
- **The throne room at Spear Pillar:** a map change (a new area or a new state of the existing map).
- **Who builds what** (owner's plan split): the story content is E11 (Claude B). The developer battle itself is T2
  (Claude A).

## Open

- The crown piece names in the table above are a proposal: the owner can rename any of them.

## Settled after review

- **11 trials** (owner): Henry's line refers to 11 Totem trials, the number in `data/totem_trials.yaml`.
- **The title** shows on the Trainer Card, in the Hall of Fame record and in NPC lines (owner).
- **Who directs the player to Spear Pillar after the first Hall of Fame:** the Celestic Town elder, at the
  player's home (owner).
- **Elite Four after the Sovereign battle:** rematches continue, all at Lv. 100 (owner).
- **Totem gates:** Galactic encounters wait on the trials before them, and Victory Road waits on Togedemaru's; the
  full crown calls the Sovereign (owner).
- **The crown:** the pieces are a mix of rubies, emeralds, sapphires and gold; they merge into the Crown, which
  becomes the Sovereign Crown after the Elite Four rematch's win over Cynthia (owner).
