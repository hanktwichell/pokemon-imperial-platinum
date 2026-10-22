# Sovereign Platinum — Story

Status: **draft**. Owner decisions are marked **(owner)**; everything else is a proposal for the owner to choose
from or change.

## Decided (owner, 2026-10-22)

- **The Sovereign** were the old ruling class of Sinnoh. Their story runs **in parallel with Team Galactic's**.
- The Sovereign are **never seen by the player**. Behind the scenes they are **merging other Pokémon worlds into
  Sinnoh**, toward a goal the player doesn't know (see *The end goal* below).
- The game makes a **vague reference to the Sovereign early on**. The player then **discovers more about them
  passively** as the Totem trials and the other regions' content open up.
- The **Totem trials are tests run by the Sovereign**. The **Chronicles** (post-game) widen the world.
- **The whole story comes together in the final battle** with the Sovereign trainer.
- That trainer is **Sovereign Twich** (class "Sovereign", name "Twich"; renamed from Sovereign Dev Twich). His
  dialogue refers to Twich being the game's developer.
- **Twich is a descendant of the old ruling class, and the only surviving member of the Sovereign lineage.**
- **The battle unlocks after the Elite Four rematch *and* after the Dialga and Palkia encounters at Spear Pillar.**

## The end goal (choose one, or mix)

Three directions, each giving a different ending to the final battle:

1. **Succession: "The Sovereign need an heir."**
   - The Sovereign line is fading. They are pulling other worlds' Pokémon into Sinnoh to build the hardest possible
     proving ground, and the Totem trials are its tests.
   - The goal is to find someone fit to inherit the role. Twich is the last of the lineage, and beating him makes the
     player the new Sovereign.
   - *Ending:* a coronation. The player earns the title the game is named after.
2. **Restoration: "One world, as it was."**
   - Long ago, all Pokémon worlds were one, and the Sovereign kept it from the throne at Spear Pillar until it split
     apart.
   - They are reuniting the pieces, using Sinnoh as the anchor.
   - *Mirror of Galactic:* Cyrus wants a new world with no spirit; the Sovereign want the old world with every
     spirit in it.
   - *Ending:* the player decides whether the world should be made whole, and Twich tests whether the player has the
     strength to make that call.
3. **Shield: "Holding the seams."**
   - The Sovereign foresaw that Cyrus would tear Sinnoh's space and time at Spear Pillar.
   - They are stitching other worlds into Sinnoh to hold it together: the Ultra Wormholes, Distortion World echoes and
     strange wild Pokémon are the stitches.
   - *Ending:* the stitches can't hold forever. Someone has to take over, which is the same coronation as option 1,
     with a clearer reason.

**Recommendation: 3 leading into 1.** It fits the owner's decision that Twich is the last of the line: the
Sovereign who stitched the worlds together are gone, and Twich, their only heir, has been holding the seams alone.
- It ties to Galactic directly: Cyrus is the crisis the Sovereign are bracing for.
- It explains why every region's Pokémon is in Sinnoh.
- It explains why the Totems are tests (they're looking for a successor).
- It ends with the player earning the title "Sovereign" from Twich at the throne at Spear Pillar.

## Story beats (proposal)

How the player learns about the Sovereign, without ever meeting one before Twich.

### Early: one vague reference
- **Oreburgh Mining Museum** (first Gym town): a new exhibit, a stone fragment carved with a crown and the line
  *"The Sovereign keep the seams."* Nobody knows what it means.
  - Alternative spots: Professor Rowan mentioning that Pokémon never seen in Sinnoh have started appearing, or the
    Jubilife TV station.

### Along the main story, alongside Galactic
- **Each Totem trial** ends with something left behind by an unseen trial keeper: the same crown mark, plus one line
  of a message that builds up across the 11 trials.
  - The player never sees who sets the trials.
  - The last trial (Togedemaru, Vista Lighthouse) completes the message.
- **Celestic Town** (Galactic's attack on the ruins): the elder's mural or story mentions the rulers who sat at
  Spear Pillar "before the Pokémon of the lakes were named".
- **Canalave Library**: a new book on the Sovereign, mostly missing pages.
- **Spear Pillar** (Galactic's climax): a moment's glimpse. Ruins on the summit show a throne that was never part of
  Platinum's map. It goes unexplained, and the story moves on to Giratina.

### After the Hall of Fame
- **The Chronicles** (Archivist): each chapter's legendaries arrive from another world. The Archivist works out that
  someone opened the way on purpose, and starts to suspect the Sovereign.
- **Regional Forms Park**: its owner keeps a log of where each regional form "came through".
- **Elite Four rematch**, then **Dialga and Palkia at Spear Pillar**. Once both are done, the throne room opens.

### The final battle: Sovereign Twich at the throne
- Twich explains what the Sovereign were doing (the end goal above). Every hint from the early game, the trials and
  the Chronicles pays off here.
- The developer reference: Twich speaks as the last surviving Sovereign, but some lines wink at him being the game's maker, for
  example: *"I've rebuilt this world more times than you've reset your game."* The owner writes the final text.
- Afterwards: the ending of the chosen end goal (for example, the player is named Sovereign).

## Engineering notes

- **Unlock condition** needs two flags:
  - the Elite Four rematch won (Sovereign's E4 format: `docs/EliteFourFormat.md`);
  - both Dialga and Palkia encountered at Spear Pillar. That's caught or defeated, depending on how Platinum's
    script sets its flags; check which flags it sets.
- **National Dex from the start** (owner decision 21): Platinum gates the post-game Spear Pillar event on the
  National Pokédex. That gate needs a new condition, probably the Hall of Fame.
- **Totem trial messages:** one short text per trial, plus the crown mark (a small graphic or a symbol in the text).
- **New text:** Oreburgh exhibit, Celestic elder lines, a Canalave book, the Archivist's lines, the Regional Forms
  Park log, Twich's intro, defeat text and ending. The owner writes Twich's.
- **The throne room at Spear Pillar:** a map change (new area or new state of the existing map).

## Open questions for the owner

1. Which end goal: 1, 2, 3, or 3 leading into 1?
2. Where does the early reference go: Oreburgh Museum, Rowan, or somewhere else?
3. Is the player told by name that the trials are Sovereign tests, or only through the crown mark and message?
4. Should Cynthia know about the Sovereign (she's Celestic Town's historian's granddaughter)?
5. After Twich, does anything change in the world (title, outfit, Twich available for rematches)?
