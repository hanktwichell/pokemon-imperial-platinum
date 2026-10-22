# Imperial Platinum — Species expansion plan (E6: 493 → 1025)

New species go in before `SPECIES_EGG`, so a species' ID is its National Dex number. After the change, Egg is 1026
and Bad Egg is 1027. `MAX_SPECIES` (= `SPECIES_BAD_EGG`), `NATIONAL_DEX_COUNT` (= `MAX_SPECIES - 2`) and most data
generated from `generated/species.txt` scale on their own.

This list comes from a read-only survey of the decomp (2026-10-22). It lists the places that **don't** scale on their
own. Paths are under `decomp/`.

## Step 1: engine prep (still 493 species; the ROM must keep working) — ✅ done

Everything in this table is fixed (see the E6 step 1 entry in `EngineChangelog.md`), except two items that need no
code. The Pokédex save growth is checked when the species go in (step 2). Imperial's post-game gives every Gen V–IX
mythical, so `sExcludedMonsNational` stays Platinum's list (Gen I–IV event mythicals).

| Area | Where | Problem | Fix |
|---|---|---|---|
| Form data indices | `src/pokemon.c` `Pokemon_GetFormNarcIndex` (~4946) | literal 496/499/501/502/503 (speciesproc packs forms at `SPECIES_BAD_EGG + 1 + i`) | `SPECIES_BAD_EGG + n` |
| Wi-Fi party check | `src/overlay065/ov65_0222DCE0.c:3700` | literal `495` | `MAX_SPECIES` |
| Trainer party species | `include/struct_defs/trainer_data.h:12`, `src/trainer_data.c` (4 places), `tools/dataproc/src/trainerproc.c:129` | species is 10 bits (max 1023), form 6 bits | 11 bits / 5 bits |
| Cries | `res/sound/pl_sound_data.json`, `src/sound_playback.c`, `src/sound.c` | bank/wave ID = species. Shaymin-Sky's cry is at 494, BASIC/BGM banks are at 700+ and SE banks at 750+ | move Shaymin-Sky above 1027 and the BGM/SE banks above it (code uses the naix symbols) |
| DP sprite archives | `src/pokemon.c` `BuildPokemonSpriteTemplateDP`, `LoadPokemonDPSpriteHeight`. Callers: contests (ov17), dress-up (ov22), `unk_020298BC.c` | prebuilt `pokegra.narc` and `dp_height.narc` hold only 494 species | use the Platinum archives for every species |
| Battle Hall save block | `include/battle_hall_win_records.h`, `src/savedata/save_table.c:115` | 3 × `u16[MAX_SPECIES]` grows from 2976 to 6168 bytes, overflowing its 4 KB sector | give it 2 sectors (primary sectors 44–63 are free) and shift what follows |
| Pokédex save | `include/pokedex.h` | grows by about 800 bytes (only checked at runtime) | check the normal save block size |
| Dex numbers | `pokedex_main.c:610`, `ov21_021D5AEC.c:732…`, `pokemon_summary_screen/window.c:1051`, `tools/dataproc/src/speciesproc.c:735,772` | 3 digits | 4 digits |
| Seen/caught counts | `main_menu/main_menu.c:696`, `overlay005/save_info_window.c:73`, `trainer_case/card_text.c:210` | 3 digits | 4 digits |
| Pokédex rating | `src/unk_0205DFC4.c:129-211` | national tiers written by hand (≤481) | new tiers |
| National Dex goal | `src/pokedex.c:15` `sExcludedMonsNational` | lists only Gen I–IV mythicals | add the Gen V–IX mythicals |
| GTS / Global Terminal by-name index | `gts_application/screens/deposit.c:1062`, `overlay062/ov62_02237D24.c:124`, `ov62_02241204.c:216` | split points into the alphabetical list are hard-coded | compute them |
| Battle Hall record selector | `overlay005/ov5_021F6454.c:64` | `MAX_LIST_ENTRIES 120`, `u8 numOptions` | raise it / widen the type |

## Step 2: the 532 species

- **Folder per species:** each needs a `res/pokemon/<name>/` folder with `data.json` (stats, types, abilities, learnsets,
  evolutions, egg moves, Pokédex data in all six languages, Pal Park data), `sprite_data.json`, `meson.build`,
  sprites, `icon.png`, `footprint.png` and a cry. Generated from PokeAPI with a new tool.
- **Placeholders:** placeholder sprites are used until E12. Cries come from PokeAPI's archive (`docs/CryChecklist.xlsx`).
- **Easy Chat:** the alphabetical species lists in `src/easy_chat_word_list.c` are written by hand. Easy Chat word IDs
  shift by +532, which is fine for Imperial's own save format.
- **Already scales:** the Sinnoh dex stays as it is (`sinnoh_pokedex.json`), and the National Dex list scales on its
  own.

## Already scaling (no change needed)

- Personal data, learnsets, evolutions and egg moves.
- Icons, icon palettes, footprints and Pal Park.
- Height/weight, the Pokédex sort lists and the Pokédex area data.
- Text banks (names, categories, entries).
- Frontier mons (11-bit species), mail icons (12 bits), and species stored as u16 everywhere else.
