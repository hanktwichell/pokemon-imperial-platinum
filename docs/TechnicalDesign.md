# Sovereign Platinum — Technical Design

This document covers the engine work needed to turn Renegade Platinum v1.3.0 into Sovereign Platinum. The design data
(encounters, trainers, Megas, evolutions, legendaries) is engine-independent and lives in `data/` and `docs/`.

## Starting point

- **Renegade Platinum is distributed as xdelta patches** (`RenegadePlatinumV130/Base Patches - USE ONE OF THESE FIRST/`).
  Applying one needs a clean US Pokémon Platinum ROM (3541 or 4997/4998 dump). **The ROM isn't in this repository and
  can't be provided by Claude.** Each developer supplies their own dump; `tools/build/apply_renegade_patch.sh` applies
  and checks the patch.
- Renegade is a **binary hack** (no public source). Its changes include expanded NARCs (which is why the Universal
  Randomizer can't read it, per its FAQ), edited scripts, trainer data, learnsets and engine patches (Fairy type, move
  replacements, abilities).

## Two ways to build Sovereign

| | **A. Binary hack on the Renegade ROM** | **B. Rebuild on the pret/pokeplatinum decompilation** |
|---|---|---|
| Tools | DSPRE (maps, scripts, encounters, trainers), Tinke / NitroPaint (graphics), custom ASM injected into a new overlay | C source + Make; data in JSON/text; assets as PNGs |
| Renegade content | Kept automatically | Must be re-implemented from Renegade's docs (all documented in `RenegadePlatinumV130/Documentation`) |
| Adding 532 species, 900+ forms | Very hard: dozens of tables hard-coded around 493; NARC expansion by hand | Feasible: tables are C arrays and data files; species constants can be extended |
| Mega battle mechanic | ASM hooks in the battle overlay | C changes in `src/battle/` |
| New moves/abilities | ASM per effect | C per effect |
| Maintainability / collaboration | Low (binary diffs) | High (text diffs, reviewable PRs) |

**Recommendation: B.** Adding every species from Gen V–IX touches the same hard-coded tables that make A impractical
at this scale. To our knowledge the mature "add every species and Megas to Gen IV" engine (hg-engine) targets HeartGold
and SoulSilver, not Platinum. Its approach (expanded tables in a new overlay, new battle effects) is the model to follow,
or to port, whichever route is chosen. This decision is the project owner's to make. It decides how every item below is
implemented.

## Work packages

### 1. Species expansion (493 → 1025)
- Personal data (base stats, types, abilities, EV yields, egg groups, gender, growth), evolution table, level-up
  learnsets, TM/HM and tutor compatibility, egg moves, Pokédex text, height and weight. Source: `data/species.csv`
  (generated from PokeAPI) plus a learnset export (to be added).
- Pokédex: national dex arrays, Sinnoh dex order (decide whether added species extend the regional dex), and the
  **Pokédex save bitfields, which are sized for 493**. Expanding them **breaks save compatibility with Renegade**.
- Box/party data stores species as 16-bit, so that's fine. Check the PID-based form/gender logic for new species.
- Icons (party/PC), footprints, cries (SDAT; can start as pitch-shifted placeholders), overworld follower sprites (not
  needed: Platinum has no followers).
- Pal Park, Poké Radar, honey trees and swarm tables only need data once species exist.

### 2. Moves and abilities
- Sovereign's move list = Gen IV moves + Renegade's 11 replacements. **Added species need learnsets built from that move
  list** unless new moves are added. Decision needed: (a) remap learnsets to existing moves (cheap; a generator can do
  it), or (b) add selected Gen V–IX moves (each needs a battle effect and animation).
- Most added species' abilities are Gen V+. Same decision: map to Gen IV abilities, or implement new abilities. Mega
  abilities used by boss trainers must be implemented first (Magic Bounce, Parental Bond, Strong Jaw, Tough Claws,
  Aura Guard). See `MegaEvolution.md`.

### 3. Items
- Add 95 Mega Stones/orbs, the Mega Ring, 16 evolution items and the legendary key items (Light Stone, Dark Stone, Prison
  Bottle, Scrolls, etc.). Platinum's item table ends at ~467; expansion needs new item data, icons and palettes, names
  and descriptions, and bag-pocket assignment.
- Field-item replacements are listed in `MegaEvolution.md` (vanilla script names from the decomp; verify against Renegade).

### 4. Mega Evolution / Primal Reversion
- Battle: a per-battler "mega pending" bit set from the move-select UI; at the start of the turn (before moves), swap
  the battler's form → recalculate stats/type/ability → play the animation → print text. Platinum already changes form
  mid-battle (Castform, Cherrim, Giratina, Shaymin), so the form-change plumbing exists.
- UI: a MEGA toggle on the touch-screen fight menu, shown only when `FLAG_SOVEREIGN_MEGA_UNLOCKED` is set, the Pokémon
  holds its stone, and the trainer hasn't Mega Evolved yet this battle.
- AI: trainers Mega Evolve on the first turn possible.
- Forms: 99 new form entries (stats, types, abilities, sprites). Revert on battle end/faint.
- Animation: new battle animation script and particles; spec in `MegaEvolution.md`.

### 5. Trainer data
- Vanilla Gen IV trainer Pokémon can't specify EVs, natures directly (nature comes from the PID seeded by trainer
  data), or abilities. **The EV spreads and natures in `TrainerPokemon_Sovereign.md` need an extended trainer-Pokémon
  format** (as hg-engine does for HGSS: per-mon nature, ability, IVs, EVs, ball, shiny).
- New trainer IDs: 19 for the League (see `EliteFourFormat.md`) plus edited story bosses.

### 6. Scripts and maps
- Elite Four format prompts (`EliteFourFormat.md`), the Mega Ring gift after Fantina, four Mega Stone vendors, five new
  starter Interviewers, the Legend Archivist and ~35 post-game events, some of them in new rooms/maps (Sendoff Spring
  crater, Spear Pillar rifts, Oreburgh Mine B3F, …).
- Wild encounter tables per `WildPokemon_Sovereign.md` / `data/encounters_sovereign.json` (slot-exact, 12 grass + 5×4 water).

### 7. Graphics
- Gen IV battle sprites: 80×80 per frame, two frames per sheet (160×80), 4bpp, **one 16-colour palette shared by the
  front and back sprite**, plus a shiny palette with the **same index order**.
- The owner-supplied "DPPt Style Gen VI and Beyond" pack provides **back sprites only** (normal + shiny, 2× scale).
  `data/sprite_index.csv` flags each file's colour count and whether it's a clean 2× upscale. Conversion steps:
  downscale 2× (nearest), quantise to ≤15 colours + transparency, then build a **shared** palette with the matching front
  sprite (fronts still needed) and remap the shiny back to the same indices.
- Mega Garchomp Z's owner-supplied front art is 116×95 px and must be redrawn to fit 80×80.

### 8. Testing
- Play-test each badge segment with the encounter tables and boss teams; check that every Renegade species is still
  obtainable (the encounter generator guarantees this for the wild tables).
- Battle tests for each Mega ability, the Mega UI, multi battles with two Mega trainers (Spear Pillar, Fight Area), and
  all E4 format paths (including the one-healthy-Pokémon fallback).
