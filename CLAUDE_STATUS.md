# Sovereign Platinum — development status

_Last updated: 2026-10-22, during E6 step 2 (adding species #494–1025). Branch `claude/festive-bardeen-5h7beo`,
based on main `f9f50b3d`. Nothing from this step is committed yet._

## 1. What was just implemented

**Merged to main already** (PRs #10–#13):
- E2/E4 Gen IX abilities.
- Repel prompt.
- Champions battle rules (core).
- HM-free field moves and forgettable HMs.
- Breeding (Destiny Knot, Everstone, ball and Hidden Ability inheritance).
- E6 step 1 engine prep for 1025 species.
- Rename to Pokémon Sovereign Platinum; developer battle doc.

**Done in the working tree (uncommitted):**
- **New-species generator** `tools/engine/gen_new_species.py`. It writes all 532 species (#494–1025) from PokeAPI:
  stats, types, abilities, learnsets, Pokédex text, evolutions, placeholder sprites and icons, footprints, and real
  cries. It also adds them to `generated/species.txt` and the sound archive, and writes `docs/NewSpecies.md`.
  - 16 evolutions wait on items that arrive with E7.
- **`gen_species_gen9.py`** refactored into `load_context()` and `build_learnset()`. The output is byte-identical to
  before.
- **`MAX_EVOLUTIONS` is now 8**, so Eevee can evolve into Sylveon.
- **The test build's party** now includes Archaludon (#1018) in place of the Sharpness Gallade.
- **The Pokédex is English-only** (owner decision, this session). The per-species foreign-language table is removed,
  and the Route 226 foreign-entry upgrade shows no language tabs. This brings the save back inside Platinum's 32
  sectors.
  - The save now loads correctly on boot. It previously crashed with a 33rd sector.

**Boot fixed (with one temporary step back):** the ROM with all 1025 species boots to the title, intro and Rowan
(`tools/test/boot_smoke.py` passes).
- The blank screen came from the 532 new cries. Each adds a bank and a wave archive to the sound archive, about
  1,064 more entries, and their index tables are loaded into the fixed 750 KB sound heap at boot.
- For now `pl_sound_data.json` is back to main's version. The new version is saved in the scratchpad and can be
  regenerated with `gen_new_species.py`.
- So the new species have no cries yet. Choosing how to fit the cries back in is waiting on the owner.

## 2. Files modified (uncommitted)

- `decomp/generated/species.txt`: 532 species added before `SPECIES_EGG`.
- `decomp/include/pokedex.h`: `recordedLanguages` removed.
- `decomp/src/pokedex.c`: language tracking removed; `Pokedex_IsLanguageObtained` and `Pokedex_CanDetectLanguages`
  now return FALSE.
- `decomp/include/struct_defs/species.h`: `MAX_EVOLUTIONS` changed to 8.
- `decomp/res/pokemon/<532 new folders>/`: new species data.
- Vanilla species `data.json` evolution edits: corsola, dunsparce, eevee, farfetchd, girafarig, linoone, meowth,
  mr_mime, primeape, qwilfish, sneasel, stantler, wooper.
- `decomp/res/sound/pl_sound_data.json`: temporarily back to main's version (see above).
- `decomp/src/script_manager.c` and `tools/test/build_test_rom.sh`: Archaludon in the test party.
- `tools/engine/gen_species_gen9.py` (refactor) and `tools/engine/gen_new_species.py` (new).
- `docs/NewSpecies.md` (new).
- `CLAUDE.md` (new): the status-file rule.
- `CLAUDE_STATUS.md` (this file).

## 3. Next 3 steps

1. **Put the new cries back without overflowing the sound heap.** The approach is waiting on the owner. Options:
   pack the new cries into a few shared banks and wave archives, enlarge the sound heap, or measure the headroom
   first. Until then, playing a new species' cry must not touch a missing bank.
2. **Finish E6 step 2.**
   - Test Archaludon in battle and its summary and cry.
   - Easy Chat species lists (`src/easy_chat_word_list.c`).
   - Docs and citations (PokeAPI cries and icons).
   - Commit, PR, merge.
3. **E7 items.** Add every held item. New held items go on sale at the Veilstone Department Store (owner request).
   Also add the 16 evolution items, Mega Stones, Charizardite Y, Blue Orb and Assault Vest.
