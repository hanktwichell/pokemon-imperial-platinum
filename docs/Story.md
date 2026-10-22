# Sovereign Platinum — Story

Status: **direction decided by the owner (2026-10-22)**. Text is still to be written. The owner writes Twich's
dialogue; the other text follows the beats below. Owner decision 23 in `docs/ProjectStatus.md`.

## The Sovereign

- **Who they are:** the old ruling class of Sinnoh, who held its throne at Spear Pillar.
- **What the player sees:** nothing directly. The Sovereign are never seen by the player, and their story runs in
  parallel with Team Galactic's.
- **What they've been doing:** working behind the scenes to merge other Pokémon worlds into Sinnoh.
- **The last of the line:** Twich, a descendant of the old ruling class and the only surviving member of the
  lineage. He is the final opponent: **Sovereign Twich** (class "Sovereign", name "Twich"). His dialogue nods to him
  being the game's developer; the owner writes it.

## The end goal: shield, leading into succession (owner: "3 leading into 1")

1. **The shield.** The Sovereign foresaw that Team Galactic's leader would tear Sinnoh's space and time apart at
   Spear Pillar. To hold the region together they began stitching other Pokémon worlds into it. The Ultra Wormholes,
   the Pokémon from other regions, the regional forms and the Totems are those stitches.
2. **The succession.** The Sovereign who began the stitching are gone. Twich, their only heir, has held the seams
   alone, and they can't be held by one person forever. The Totem trials are how he has been looking for someone fit
   to take over.
3. **The ending.** At the throne at Spear Pillar, Twich tests the player. Beating him hands the role on: **the player
   is granted the Sovereign title**, the name the game is called by.

How it ties together:
- **Team Galactic** is the crisis the Sovereign were bracing for, so the two stories run side by side and meet at
  Spear Pillar.
- It explains why every region's Pokémon is in Sinnoh.
- It explains why the Totems are tests.
- It ends with the player earning the game's title.

## Story beats

The player learns about the Sovereign passively, without ever meeting one before Twich.

### Early: two vague references (owner: both)
- **Oreburgh Mining Museum** (first Gym town): a new exhibit, a stone fragment carved with a crown and the line
  *"The Sovereign keep the seams."* Nobody knows what it means.
- **Professor Rowan:** a remark that Pokémon never recorded in Sinnoh have started turning up, and he can't explain
  where they're coming from.

### Along the main story, alongside Galactic
- **Totem trials:** each one ends with something left behind by an unseen trial keeper, the same crown mark plus one
  line of a message that builds up across the trials. The last trial (Totem Togedemaru, Vista Lighthouse) completes
  the message.
- **Celestic Town** (Galactic's attack on the ruins): the elder's story mentions the rulers who sat at Spear Pillar.
- **Canalave Library:** a new book on the Sovereign, mostly missing pages.
- **Spear Pillar** (Galactic's climax): a brief glimpse of ruins on the summit showing a throne that was never part
  of Platinum's map. It goes unexplained, and the story moves on to Giratina.

### After the Hall of Fame
- **Dialga and Palkia** appear at Spear Pillar once the player has **entered the Hall of Fame** (owner). This replaces
  Platinum's National Dex condition, since Sovereign gives the National Dex from the start (decision 21).
- **The Chronicles** (Archivist): each chapter's legendaries arrive from another world. The Archivist works out that
  someone opened the way on purpose, and starts to suspect the Sovereign.
- **Regional Forms Park:** its owner keeps a log of where each regional form "came through".
- **Elite Four rematch.** Once that and Dialga and Palkia are both done, the throne room at Spear Pillar opens.

### The final battle: Sovereign Twich at the throne
- **Before the battle,** Twich refers to the Totem trials: the player has passed all **11** of his trials, so they're
  the one he has been waiting for. The owner writes the dialogue, along with what the Sovereign were doing; every hint from the
  early game, the trials and the Chronicles pays off here.
- **The battle:** the developer team, Lv. 100 doubles (`docs/DeveloperBattle.md`).
- **After the battle:** the player is granted the **Sovereign title**. It shows on the Trainer Card, in the Hall of
  Fame record, and in how NPCs address the player from then on (owner).
- **Cynthia arrives** to congratulate the player (owner):
  - She is very close to Twich. Their exact relationship is hinted at but never stated, and kept PG.
  - She is the reason Twich uses a Garchomp, her signature Pokémon.

## Engineering notes

- **Dialga/Palkia trigger:** set by entering the Hall of Fame instead of by the National Pokédex. Find the flag or
  variable Platinum's Spear Pillar post-game script checks.
- **Twich's unlock:** the Elite Four rematch won (Sovereign's E4 format: `docs/EliteFourFormat.md`) and both Dialga
  and Palkia encountered at Spear Pillar (caught or defeated, depending on how Platinum's script sets its flags).
- **The Sovereign title** shows in three places (owner): the Trainer Card, the Hall of Fame record, and NPC lines
  after the battle (a flag the relevant scripts check).
- **Cynthia's appearance:** a scripted scene after the battle at Spear Pillar, using her existing overworld sprite.
- **Totem trial messages:** one short text per trial, plus the crown mark (a small graphic or a symbol in the text).
- **New text:** the Oreburgh exhibit, Rowan's remark, the Celestic elder's lines, a Canalave book, the Archivist's
  lines, the Regional Forms Park log, Cynthia's lines after the battle. Twich's intro, defeat and ending text: the
  owner.
- **The throne room at Spear Pillar:** a map change (a new area or a new state of the existing map).
- **Who builds what** (owner's plan split): the story content is E11 (Claude B). The developer battle itself is T2
  (Claude A).

## Settled after review

- **11 trials** (owner): Twich's line refers to 11 Totem trials, the number in `data/totem_trials.yaml`.
- **The title** shows on the Trainer Card, in the Hall of Fame record and in NPC lines (owner).
