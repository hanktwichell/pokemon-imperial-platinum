# Imperial Platinum — Engine Changelog

Changes made to the pret/pokeplatinum decompilation in `decomp/`, newest first. Each entry lists what changed for
players and the verification that was run.

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
