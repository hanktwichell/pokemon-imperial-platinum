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
- **Totem trials:** each one ends with something left behind by an unseen trial keeper, the same crown mark plus one
  line of a message that builds up across the trials. The last trial (Totem Togedemaru, Vista Lighthouse) completes
  the message.
- **Celestic Town** (Galactic's attack on the ruins): the elder's story mentions the rulers who sat at Spear Pillar.
- **Canalave Library:** a new book on the Sovereign, mostly missing pages.
- **Spear Pillar** (Galactic's climax): a brief glimpse of ruins on the summit showing a throne that was never part
  of Platinum's map. It goes unexplained, and the story moves on to Giratina.

### After the Hall of Fame: event order (owner)

1. **First time as Champion** (first Hall of Fame entry). The player is directed to **Spear Pillar** to resolve a
   disturbance involving Dialga and Palkia. Both can be **caught** there. Who directs the player is open (see *Open*).
2. **The Elite Four rematch stays locked until both the Dialga and Palkia encounters are completed.** The NPC at the
   Pokémon League who prompts you to save before the Elite Four blocks the rematch until then.
3. **Elite Four rematch.** Once it's open, the player may rematch the Elite Four any number of times, from completing
   Dialga and Palkia up to the Sovereign battle.
4. **After beating Cynthia the second time,** Cynthia directs the player back to Spear Pillar to resolve the mystery
   that has been unfolding all game. That opens the throne room and the battle with Sovereign Henry.

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

## Totem trials: prompts and gates (proposal, 2026-10-22)

Owner: the game needs prompts that push the player to complete the Totem trials, and maybe events gated behind them.
Henry's pre-battle line ("all 11 of my trials") already implies one gate, so this is the proposal:

**The gate**
- **The Sovereign battle needs all 11 trials.** After the second win against Cynthia, she still sends the player to
  Spear Pillar, but the throne room stays sealed until every trial is passed.
  - The seal shows the crown mark, with one light per trial passed.
- **Nothing in the main story is gated.** Decision 18 keeps the trials optional along the way, so a player who skips
  some can come back for them after the Hall of Fame. The trials stay open after the Elite Four.
- Possible second gate (owner's call): the last Chronicle chapter, or a Sovereign-themed reward, only after all 11.

**The prompts**
- **A progress item** (key item, e.g. *Sovereign Seal*): received at the first trial passed. It shows the crown with
  one gem lit per trial, and its description names the next unfinished trial's region ("A faint light points
  toward Eterna…").
- **Rumours as the story goes on:** once a trial is open and unfinished, a Pokémon Center NPC in the nearby towns
  mentions "a huge Pokémon that won't leave" the trial's area.
- **The Town Map** marks open, unfinished trials (if the Town Map can show it cheaply; otherwise the rumours are
  enough).
- **After the Hall of Fame:** if trials remain, Cynthia (at the throne-room seal, or in her scene after the second
  win) points out the unlit gems.

**Open questions**
1. Is gating only the Sovereign battle the right amount, or should something earlier wait on trials too?
2. The progress item: a key item, a mark on the Trainer Card, or both?

## Engineering notes

- **Dialga/Palkia trigger:** the first Hall of Fame entry, instead of the National Pokédex. Find the flag or variable
  Platinum's Spear Pillar post-game script checks, plus a scene or message directing the player there.
- **Elite Four rematch lock:** the League's save-prompt NPC checks a "Dialga and Palkia both done" condition
  (caught or defeated) before letting the player through for a rematch.
- **Henry's unlock:** the second win against Cynthia (the Elite Four rematch, Sovereign's E4 format:
  `docs/EliteFourFormat.md`) sets the flag that opens the throne room, and Cynthia's scene sends the player there.
  Elite Four rematches stay repeatable afterwards (unlimited until the Sovereign battle).
- **The Sovereign title** shows in three places (owner): the Trainer Card, the Hall of Fame record, and NPC lines
  after the battle (a flag the relevant scripts check).
- **Cynthia's appearance:** a scripted scene after the battle at Spear Pillar, using her existing overworld sprite.
- **Totem trial messages:** one short text per trial, plus the crown mark (a small graphic or a symbol in the text).
- **New text:** the Oreburgh exhibit, Rowan's remark, the Celestic elder's lines, a Canalave book, the Archivist's
  lines, the Regional Forms Park log, Cynthia's lines after the battle. Henry's intro, defeat and ending text: the
  owner.
- **The throne room at Spear Pillar:** a map change (a new area or a new state of the existing map).
- **Who builds what** (owner's plan split): the story content is E11 (Claude B). The developer battle itself is T2
  (Claude A).

## Open

- **Who directs the player to Spear Pillar after the first Hall of Fame?** Options: Cynthia at the Hall of Fame,
  Professor Rowan by phone/visit, or the Celestic Town elder.
- **After the Sovereign battle,** can the Elite Four still be rematched? (The owner's rule covers the time up to
  the Sovereign battle.)

## Settled after review

- **11 trials** (owner): Henry's line refers to 11 Totem trials, the number in `data/totem_trials.yaml`.
- **The title** shows on the Trainer Card, in the Hall of Fame record and in NPC lines (owner).
