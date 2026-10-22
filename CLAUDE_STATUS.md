# Sovereign Platinum — development status

_Last updated: 2026-10-22. **E6 step 2 (species #494–1025) is finished.** Branch `claude/sweet-wright-rk4wl1`
continues `claude/festive-bardeen-5h7beo` (all of its commits are included), based on main `f9f50b3d`. Everything
below is committed and pushed. No PR yet._

## 1. What was just implemented

**E6 step 2 is complete: all 1025 species are in the game.**

Earlier on this branch (previous session):
- The species generator (`tools/engine/gen_new_species.py`) adds the 532 new species.
- The Pokédex is English-only, so the save fits in 32 sectors.
- `MAX_EVOLUTIONS` is 8.
- Placeholder Unown-? sprites for both genders.
- New species have no cry (owner decision; cries come last).
- Archaludon is in the test party.

This session:
- **Easy Chat species words.** The new generator `tools/engine/gen_easy_chat_species.py` adds the 532 species to
  `decomp/src/easy_chat_word_list.c`:
  - A–L go to the POKéMON group and M–Z to POKéMON 2, and each one also goes into its ABC-mode letter list.
  - Every list is in display-name order, using the shortened in-game names. ’ sorts before the letters, as in
    Platinum (I’VE ARRIVED comes before ICE), and É sorts as E.
  - Platinum's own entries are never moved. The generator checked that Platinum's lists already follow this sort
    order.
  - Running it again changes nothing, and `--check` exits 1 if the file is out of date.
  - The word buffers size themselves from the text banks: 2,670 words, well under the decoder's 4,096 cap. The
    lists add 2,128 bytes of read-only data to the static ARM9.
- **Test build: SELECT+B opens the Easy Chat word picker.**
  - The task lives in `src/script_manager.c` (static ARM9). It can't go in `field_control.c`: overlay5 is unloaded
    while Easy Chat runs, and an overlay5 task crashed with a black screen when Easy Chat closed.
  - **Lesson for future test hooks:** any field task that opens an app must live outside overlay5.
- **Verified in the emulator (test build):**
  - Easy Chat's POKéMON group shows ARCHALUDON, GALLADE, GARCHOMP.
  - ABC mode's A list reads ANTICIPATION, ARCHALUDON, ARENA TRAP, ATTACK, AUNT, so the shifted word IDs decode
    correctly.
  - Confirming and cancelling both return to the field.
  - A wild battle afterwards works.
  - `boot_smoke.py` passes.
- **Step 2 wrap-up docs:**
  - EngineChangelog: new "E6 step 2" entry.
  - EngineRoadmap: E6 marked ✅.
  - ProjectStatus: E6 done, plus decisions 6 (cries last) and 14 (English-only Pokédex).
  - SpeciesExpansionPlan: step 2 marked done.
  - CITATIONS: Pokédex text, and the PokeAPI icons now in the ROM.
  - Fixed "an Sovereign" in the `boot_smoke.py` docstring.

## 2. Files modified this session

- `decomp/src/easy_chat_word_list.c`: generated insertions of the 532 species.
- `tools/engine/gen_easy_chat_species.py`: new.
- `decomp/src/script_manager.c` and `decomp/include/script_manager.h`: `SovereignTest_OpenEasyChat` (test build
  only), plus a stale comment fixed (Archaludon has no cry).
- `decomp/src/overlay005/field_control.c`: the SELECT+B hook (test build only).
- `tools/test/build_test_rom.sh`: header comment lists SELECT+B.
- `tools/test/boot_smoke.py`: docstring grammar.
- `docs/EngineChangelog.md`, `docs/EngineRoadmap.md`, `docs/ProjectStatus.md`, `docs/SpeciesExpansionPlan.md`,
  `CITATIONS.md`.
- `CLAUDE_STATUS.md`: this file.

## 3. Next 3 steps

1. **Open a PR for E6 and merge it** (from `claude/sweet-wright-rk4wl1`; it includes the festive-bardeen commits).
   CI builds the normal (non-test) ROM. This session built and tested only the test ROM.
2. **E7 items.**
   - Add every held item. New held items go on sale at the Veilstone Department Store (owner request).
   - Also add the 16 evolution items that the ⏳ evolutions in `docs/NewSpecies.md` wait on, Mega Stones,
     Charizardite Y, the Blue Orb and Assault Vest.
   - Then rerun `gen_new_species.py` so those evolutions are written.
3. **Possible follow-ups (ask the owner):**
   - Gen V+ moves and abilities are in the text banks but not in the Easy Chat lists (moves unlock after the game is
     beaten). `gen_easy_chat_species.py` could be extended the same way.
   - If RAM gets tight, the Easy Chat word list (vanilla ~5 KB including the new 2 KB) could move from the static
     ARM9 into the `easy_chat` overlay; only that overlay uses it. Check the mail app first, which opens Easy Chat
     from its own overlay.
   - After that: E12 sprites for the 532 new species. Cries come last of all.

**Testing tips:**
- Test ROM: `tools/test/build_test_rom.sh` → `decomp/build_test/pokeplatinum.us.nds`. A cold build takes about 40
  minutes on 4 cores; install the apt packages from `decomp/INSTALL.md`, then
  `pip install py-desmume pillow pyyaml`.
- `tools/test/new_game.sh` reached the bedroom on this build, but intro timing changes with every build (one run
  stalled on a Yes/No prompt). More reliable: make an in-game save once (menu → SAVE → YES, YES, wait about 1,800
  frames, then `export:`), then boot later builds with `sav:FILE` and continue with
  `wait:600 A wait:200 START wait:200 A wait:300`.
- `drive.py`'s `PLAYER_X/Z_ADDR` read (0,0) on this build, so they need re-finding.
- Easy Chat from the test build: `SELECT+B`, then `A A` opens the POKéMON group.
