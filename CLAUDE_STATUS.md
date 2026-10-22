# Sovereign Platinum — development status

_Last updated: 2026-10-22, during E6 step 2 (adding species #494–1025). Branch `claude/festive-bardeen-5h7beo`,
based on main `f9f50b3d`. Everything below is committed and pushed to the branch; no PR yet (E6 step 2 isn't
finished)._

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

**The ROM boots and plays with all 1025 species.**
- `boot_smoke.py` passes.
- In the test build, Archaludon's summary, stats and ability show correctly. In a wild battle it switches in (placeholder
  sprite, silent cry), attacks, and the battle ends normally.
- In-game save and continue work with the 32-sector save.

**Cries (owner decision):** Platinum's sound archive stays unchanged. The 532 new species have no cries and play
silently: `Sound_Impl_HasCry` in `src/sound_playback.c`. Cries are the project's last step, and removing all cries
is the fallback if space ever runs out.
- Measured: adding the cries grows the sound archive's boot-time index from 72,412 to 97,948 bytes (+25,536). The
  sound heap has only 21,356 bytes free at boot and on the title screen, so they'd be about 4.2 KB short before
  gameplay.

**Placeholder sprites:** the new species use Unown-? until milestone E12. Both male and female copies are written,
since Platinum shows the female sprite for female Pokémon.

**Developer battle (owner):** the team has been revised.
- Charizard-Y: Hurricane replaced Ancient Power.
- Tyranitar: Ice Punch replaced Protect; Choice Band replaced Assault Vest.
- Archaludon: a new set (♀, Modest, Assault Vest, 252 HP / 156 SpD / 100 Spe, with Electro Shot, Body Press,
  Flash Cannon and Dragon Pulse).

## 2. Files modified on this branch (all committed)

- `decomp/generated/species.txt`: 532 species added before `SPECIES_EGG`.
- `decomp/include/pokedex.h`: `recordedLanguages` removed.
- `decomp/src/pokedex.c`: language tracking removed; `Pokedex_IsLanguageObtained` and `Pokedex_CanDetectLanguages`
  now return FALSE.
- `decomp/include/struct_defs/species.h`: `MAX_EVOLUTIONS` changed to 8.
- `decomp/res/pokemon/<532 new folders>/`: new species data.
- Vanilla species `data.json` evolution edits: corsola, dunsparce, eevee, farfetchd, girafarig, linoone, meowth,
  mr_mime, primeape, qwilfish, sneasel, stantler, wooper.
- `decomp/src/sound_playback.c` and `decomp/src/sound.c`: new species have no cry (silent).
- `decomp/res/pokemon/meson.build`: a cry is packed only when the species has `cry.wav`.
- `docs/DeveloperBattle.md`: the owner's team revisions.
- `decomp/src/script_manager.c` and `tools/test/build_test_rom.sh`: Archaludon in the test party.
- `tools/engine/gen_species_gen9.py` (refactor) and `tools/engine/gen_new_species.py` (new).
- `docs/NewSpecies.md` (new).
- `CLAUDE.md` (new): the status-file rule.
- `CLAUDE_STATUS.md` (this file).

## 3. Next 3 steps

1. **Easy Chat species lists** (`decomp/src/easy_chat_word_list.c`), the last code item of E6 step 2. Findings so far:
   - A species' word ID is its species ID. Other words are offset by the text bank sizes (`MOVE_WORD` etc. in
     `include/applications/easy_chat/defs.h`), so they shift automatically and the list entries can stay as they are.
   - The Pokémon words are split into two groups by name: `sPokemonWords` runs Abomasnow–Luxray (235) and
     `sPokemon2Words` runs Machamp–Zubat (258). Both are in display-name order, not constant-name order.
   - The A–Z lists (`sAWords` … `sZWords`) hold all 493 species mixed in with other words.
   - To do: write a small generator that inserts the 532 new species (A–L into group 1, M–Z into group 2, plus each
     into its letter list) in display-name order. Then check that the buffers sized by word count (`wordsByGroup`,
     `addedWordBits`) cope with 532 more words. Test in game with the Easy Chat screen (e.g. the Trainer Card or a
     Pokémon Center interview).
2. **Wrap up E6 step 2.**
   - Docs: changelog, roadmap, ProjectStatus (decisions: English-only Pokédex, no new cries until last), the step 2
     section of SpeciesExpansionPlan, and CITATIONS for the PokeAPI icons.
   - Fix the "an Sovereign" grammar left by the rename (e.g. the `tools/test/boot_smoke.py` docstring).
   - Open a PR from `claude/festive-bardeen-5h7beo` and merge it.
3. **E7 items.** Add every held item. New held items go on sale at the Veilstone Department Store (owner request).
   Also add the 16 evolution items, Mega Stones, Charizardite Y, Blue Orb and Assault Vest. After that, E12 sprites
   for the 532 new species; cries come last of all.

**Testing tips:**
- Test ROM: `tools/test/build_test_rom.sh` → `decomp/build_test/pokeplatinum.us.nds`.
- Intro inputs that work on the current build: `$S/arch/intro_full.txt`, where `$S` is
  `/tmp/claude-0/-home-user-pokemon-imperial-platinum/320147ff-836b-5cb0-8a81-b2884a5e01ab/scratchpad`. Scratch
  files may not survive the session.
- An in-game save is slow in the emulator: wait about 1,500 frames before exporting it.
