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
  *"The Sovereign keep the seams."* Nobody knows what it means.
- **Professor Rowan:** a remark that Pokémon never recorded in Sinnoh have started turning up, and he can't explain
  where they're coming from.

### Along the main story, alongside Galactic
- **Totem trials:** each one leaves a crown piece behind (see *The crown*). The Galactic encounters wait on them,
  and the pieces slowly reveal a crown. The last trial (Totem Togedemaru, Vista Lighthouse) gives the Crown Diamond
  that completes it.
- **Celestic Town** (Galactic's attack on the ruins): the elder's story mentions the rulers who sat at Spear Pillar.
- **Canalave Library:** a new book on the Sovereign, mostly missing pages.
- **Spear Pillar** (Galactic's climax): a brief glimpse of ruins on the summit showing a throne that was never part
  of Platinum's map. It goes unexplained, and the story moves on to Giratina.

### After the Hall of Fame: event order (owner)

1. **First time as Champion** (first Hall of Fame entry). The player is directed to **Spear Pillar** to resolve a
   disturbance involving Dialga and Palkia. Both can be **caught** there. The **Celestic Town elder** meets the
   player at home (where they wake after the Hall of Fame) and sends them to Spear Pillar (owner).
2. **The Elite Four rematch stays locked until both the Dialga and Palkia encounters are completed.** The NPC at the
   Pokémon League who prompts you to save before the Elite Four blocks the rematch until then.
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
  (`docs/SpriteChecklist.xlsx`, sheet *Item Icons*, from `data/item_sprites.csv`).

## Engineering notes

- **Dialga/Palkia trigger:** the first Hall of Fame entry, instead of the National Pokédex. Find the flag or variable
  Platinum's Spear Pillar post-game script checks, plus a scene or message directing the player there.
- **Celestic elder at home:** a scene in the player's house the first time they wake there after the Hall of Fame.
- **Galactic gates:** each gating NPC's script checks the trial flags in the table above (one flag per trial, set
  when its catch encounter ends).
- **Crown pieces:** 13 new key items (key items can't be sold or tossed): the 11 pieces, the Crown and the
  Sovereign Crown. Picking up the 11th piece removes the 11 and gives the Crown. Beating Cynthia in the rematch
  swaps the Crown for the Sovereign Crown.
- **Victory Road gate:** the existing check at Victory Road's entrance also needs Togedemaru's trial flag.
- **Elite Four rematch lock:** the League's save-prompt NPC checks a "Dialga and Palkia both done" condition
  (caught or defeated) before letting the player through for a rematch.
- **Henry's unlock:** the second win against Cynthia (the Elite Four rematch, Sovereign's E4 format:
  `docs/EliteFourFormat.md`) sets the flag, and Cynthia's scene sends the player there. Henry appears only if the
  player also holds all 11 crown pieces. Elite Four rematches stay repeatable throughout.
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
