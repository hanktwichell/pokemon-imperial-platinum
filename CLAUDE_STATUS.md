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

---

## CA-0001 — 2026-10-22, 3:02 pm US Central (session on `claude/festive-bardeen-5h7beo`)

Second session, working alongside the CB-#### session (E6/E7 on `claude/sweet-wright-rk4wl1`). Entries from this
session are numbered CA-#### and only ever appended here.

**Reviewed the other session's work:** E6 step 2 is merged to main (PR #14), including Easy Chat; my own
uncommitted Easy Chat lists were identical, so I discarded them. Owner decisions since then: every form is in the
game (milestone FM), Totem trials, MEGA button, Terapagos-Stellar shelved. E7 (245 items, icons, test bag) is in
progress on `claude/sweet-wright-rk4wl1`.

**Picked: milestone E9, the trainer format** (`docs/EngineRoadmap.md` row 12): per-Pokémon nature, ability, IVs,
EVs, held item, form, gender and shininess in trainer data, with 16-bit species. It doesn't touch E7's files
(items, shops, evolutions); trainers only refer to item IDs. It unblocks T1 (boss teams) and T2 (the developer
battle).

**Files modified:** `CLAUDE_STATUS.md` (this entry). My branch was reset to main `5b427e88`, since all of its
earlier commits were merged through PR #14.

**Next 3 steps:**
1. Survey the trainer pipeline: `include/struct_defs/trainer_data.h`, `src/trainer_data.c`,
   `tools/dataproc/src/trainerproc.c` and the trainer source files.
2. Design the Sovereign trainer-mon format (one layout carrying every field), keeping Platinum's trainers loading
   the same.
3. Build it, convert the existing trainers, and test a trainer battle in the test build (SELECT+R).

---

## CA-0002 — 2026-10-22, 3:21 pm US Central (session on `claude/festive-bardeen-5h7beo`)

**Implemented: milestone E9, the Sovereign trainer format.** Reference: `docs/TrainerFormat.md`.
- **New optional fields** on each trainer party member: `nature`, `ability`, `ivs`, `evs`, `gender`, `shiny` and
  `ball`.
  - Any one of them switches the party to the new 38-byte layout `TrainerMonSovereign` (`TRDATATYPE_SOVEREIGN`),
    which also stores the whole species ID.
  - Platinum's 928 trainers pack byte-for-byte as before.
- **How the game builds each Pokémon:**
  - It takes Platinum's seeded personality value and changes it as little as possible to get the nature, gender and
    ability slot.
  - Hidden Abilities use Sovereign's flag; shininess comes from the OT ID.
  - IVs, EVs and form are set, then the ability and stats are recalculated.
- **Test trainer `TRAINER_SOVEREIGN_TEST`:** the developer team at Lv. 100, as a double battle. The test build's
  SELECT+R battles it now (it was the Route 209 rival).
  - It took the unused `FLAG_UNK_0x08F0` as its defeated flag.
  - "Adding a trainer" steps are in `TrainerFormat.md`.
- **New tool `tools/test/check_trainer_party.py ROM XMAP SAVE [JSON]`:** decrypts the opponent's Pokémon in game and
  compares them with the JSON, stats included.
- **Verified:**
  - The checker passes for all six Pokémon (two Hidden Abilities, two shinies, an Ultra Ball, every nature, IV and EV
    stat) and fails, as it should, on a wrong JSON.
  - The battle starts and a turn plays out normally.
  - The normal ROM passes `boot_smoke.py`.
  - The docs regeneration (`tools/regenerate_docs.sh`) shows no change apart from `SpriteChecklist.xlsx`, which is
    unrelated (probably my local PokeAPI copy) and was not committed.
- **Owner clarification recorded:** EVs cap at 255 per stat in the game, and 252 is the useful most (4 EVs = 1 stat
  point). The packer allows 255.

**Files modified:**
- `decomp/include/struct_defs/trainer_data.h`
- `decomp/tools/dataproc/src/trainerproc.c`
- `decomp/src/trainer_data.c`
- `decomp/src/battle/battle_script.c` (prize money)
- `decomp/generated/trainers.txt` and `decomp/generated/vars_flags.txt`
- `decomp/res/trainers/data/sovereign_test.json` (new)
- `decomp/src/overlay005/field_control.c` (test hook)
- `tools/test/check_trainer_party.py` (new) and `tools/test/build_test_rom.sh` (comment)
- `docs/TrainerFormat.md` (new), `docs/EngineChangelog.md`, `docs/EngineRoadmap.md`, `docs/ProjectStatus.md`,
  `docs/DeveloperBattle.md`
- `CLAUDE_STATUS.md`

**Next 3 steps:**
1. Open the E9 PR, get CI green and merge. The CB session's E7 branch will meet a small merge conflict at the top of
   `docs/EngineChangelog.md` and the bottom of this file; keep both sides.
2. Next non-E7 item: **12b, the AI review for doubles**. It builds on this (the test trainer is a ready doubles
   opponent) and leads into T2's custom weather AI. Alternatively item 11 (effect fidelity), avoiding hold-item effects
   (E7).
3. Once E7 is merged: give `sovereign_test.json`'s Charizard, Kyogre and Archaludon their Charizardite Y, Blue Orb
   and Assault Vest.

**Testing tips:**
- A bedroom battery save that works with `check_trainer_party.py`:
  `/tmp/claude-0/-home-user-pokemon-imperial-platinum/320147ff-836b-5cb0-8a81-b2884a5e01ab/scratchpad/arch/bedroom_new.sav`.
  Scratch files may not survive the session; make a new one with `drive.py` (menu → SAVE, wait about 1,500 frames,
  `export:`).
- In a double battle, the A button doesn't confirm a target; tap it (e.g. `touch:60,40` for the left opponent).
