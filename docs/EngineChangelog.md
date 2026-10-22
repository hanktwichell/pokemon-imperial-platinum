# Imperial Platinum — Engine Changelog

Changes made to the pret/pokeplatinum decompilation in `decomp/`, newest first. Each entry lists what changed for
players and the verification that was run.

## E13 — Options additions (level cap, Infinite Rare Candy, party Exp. Share, music volume)

- **Options menu:** four new rows in the normal OPTIONS list, after FRAME: **LEVEL CAP** (ON/OFF, default OFF),
  **INF. CANDY** (ON/OFF, default OFF; grayed out and locked while the level cap is OFF), **EXP. SHARE** (ON/OFF,
  default ON) and **MUSIC** (0–100 in steps of 5, shown as a number and a bar; hold left/right to move quickly, and the
  volume changes as you move it). The list now has 11 rows and scrolls, with arrows at the right of the title bar
  when there are rows above or below. The YES/NO confirmation covers the new settings too.
- **Save data:** the settings live in `ImperialOptions` (`include/imperial_options.h`), a 16-bit field in the player
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
pocket. Build passes. **Not yet tested in-game:** EXP stopping at the cap and party-wide EXP in an actual battle, and
a Rare Candy not being used up (both need a party Pokémon; to be tested once the starter is obtained in a test save).

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
