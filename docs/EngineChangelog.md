# Imperial Platinum — Engine Changelog

Changes made to the pret/pokeplatinum decompilation in `decomp/`, newest first. Each entry lists what changed for
players and the verification that was run.

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
- **Not adopted for now:** Champions' fixed PP scale with no PP Ups (Imperial keeps PP Ups, pending the owner's call),
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

- `meson -Dimperial_test=true` (`tools/test/build_test_rom.sh` → `decomp/build_test/`): a new game starts with a test
  party (Garchomp 50 with Gen IX moves, Turtwig 15, Starly 5, two Gallade 30 with Justified and Sharpness) and items (3 Rare Candies, 10 Potions, 10 Poké Balls). In the overworld,
  **SELECT** starts a wild battle (Chansey Lv. 30) and **SELECT+R** a trainer battle (Barry, Route 209). Normal builds
  and CI don't define `IMPERIAL_TEST`, so none of this is in the real game.
- Fixed while building it: the setup first allocated from a heap that doesn't exist yet at new-game start (the NULL
  write corrupted ITCM code → crash); it now uses `HEAP_ID_FIELD2`. The first battle hook used the script engine and
  landed on the wrong script; it now starts the battle from a small field task.

## E1 — Imperial identity and save format

- **Own save signature** (`SECTOR_SIGNATURE` 0x20261022 instead of Platinum's 0x20060623). A Platinum or Renegade
  Platinum save fails the check and loads as "no save data" (the game goes straight to a new game) instead of being
  misread by Imperial's different save layout.
- **ROM header title** `IMPERIAL PL` and **DS menu banner** "Pokémon Imperial Platinum". The game code stays `CPUE`
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
