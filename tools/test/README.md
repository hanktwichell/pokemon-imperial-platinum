# Test tools

Each tool's docstring has the details: what it checks, its results, its options. Run them from the repo root.

## Static checks (no emulator)

These read the decomp's files. CI runs the ones marked **CI** on every PR.

| Tool | Checks |
|---|---|
| `check_battle_scripts.py` **CI** | every built battle script fits in its buffer |
| `check_byte_text_ids.py` **CI** | field-script text IDs fit their one-byte arguments |
| `check_message_box_lines.py` **CI** | field messages fit their two-line boxes |
| `check_event_scripts.py` **CI** | map events and init scripts name scripts that exist |
| `check_map_links.py` **CI** | warps lead to warps that exist; map scripts show their own map's texts |
| `check_menus.py` **CI** | script menus fit on the screen, clear of the message box |
| `check_object_tiles.py` **CI** | every added or moved object can be reached and blocks nothing (needs vanilla's import commit) |
| `check_double_close.py` **CI** | no script path closes a message twice (that hangs the game) |
| `check_battle_sprites.py` **CI** | every battle sprite is a 160×80 indexed image with its first four pixels clear (else the game can't unscramble it) |
| `check_type_chart.py` **CI** | the type charts match the official chart (needs PokeAPI's CSVs) |
| `find_tiles.py` | prints a map's tiles, to find spots for warps and new objects |
| `rom_space.py` | prints the ROM's free space and what the cries take (needs a built ROM) |

## The test build

The playtest harnesses run the test ROM, which has hooks for them (`decomp/include/sovereign_test.h`).
- `build_test_rom.sh` builds it into `decomp/build_test/`.
- `new_game.sh` makes a save state in the player's bedroom on a new game. Make a new one after every rebuild: a state
  holds the old code in RAM.
- `drive.py` drives the ROM from a state with a list of button presses. Its `Driver` is what the harnesses use. On the
  test build its `pos()` (and the `pos` and `step:` actions) read the player's tile from `gSovereignTestPlayerTile`.
- Each process that imports `drive.py` keeps the emulator's battery (the in-game saves) in a folder of its own,
  removed when the process ends. It used to be one file per ROM name (`~/.config/desmume/<rom>.dsv`), and harnesses
  run side by side wiped each other's saves. A save state holds the battery as it was when the state was saved.
- `boot_smoke.py` boots a ROM headlessly. CI runs it on the shipping ROM.

## Playtest harnesses (test build, local)

Run them headless with `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy`. The heap check (`heap_check.py`) runs in each
one and reports **HEAP**. The times are rough.

| Tool | Covers | Time |
|---|---|---|
| `battle_all_trainers.py` | every trainer: party matches its JSON, the battle ends | ~2 h with `--jobs 4` |
| `battle_all_species.py` | every species and form as a wild Pokémon | ~1 h with 4 jobs |
| `battle_form_changes.py` | Megas, Primals, Ultra Burst, in-battle forms, form-change items | ~1 h |
| `battle_mechanics.py` | the battle checks made for each move, ability and held-item change (526 cases in `battle_mechanics_cases.py`): each battle's messages and HP against the ones recorded in `battle_mechanics_expected.json` | ~1 h with 4 jobs |
| `battle_evolutions.py` | every evolution that involves a form | ~25 min in 4 parts |
| `battle_eggs.py` | every form bred in the Day Care and hatched | ~1 h in 4 parts |
| `sprite_check.py` | contact sheets of #494–1025's battle sprites in a battle (front and back, normal and shiny), to check by eye | ~40 min in 4 parts |
| `wild_forms.py` | wild Pokémon's forms on every map, through the real encounter code | ~20 min in 4 parts |
| `rare_wild.py` | every rare wild encounter (the Ultra Beasts) on each of its maps once its gate is met, and never before | ~10 min in 4 parts |
| `roamers.py` | the roamers the scripts release: species and level, where flights and walks move them, meeting each on its map, a real battle with each, a catch, and the Pokétch's Marking Map | ~15 min |
| `talk_to_objects.py` | every added or moved object runs its own script to its end (on a new game; `--postgame` after the Hall of Fame, `--chronicles` with every Chronicle open too, `--unhide` with the object's own hide flag cleared) | ~1 h in 4 parts |
| `signs_and_triggers.py` | every added sign, hidden item and coord trigger (`--postgame` and `--chronicles` as above) | ~10 min in 4 parts |
| `gift_pokemon.py` | every Pokémon gift: species, form, level, moves, ability | ~20 min |
| `elite_four_runs.py` | every path through the Elite Four's battle formats (13 runs) | ~40 min in 4 parts |
| `visit_changed_maps.py` | every changed map loads and the field runs | ~1 h |
| `pokedex_area.py` | the Pokédex's area map for the species given, as screenshots to check by eye | ~15 s a species |

Most take `--part I/N` (`battle_all_trainers.py`, `battle_all_species.py` and `battle_mechanics.py` take `--jobs N`)
to split a run across processes, one per core.

## Other

- `check_trainer_party.py`: one trainer's party in game against its JSON (used by `battle_all_trainers.py`).
- `log_ai_partner_damage.py`: logs the doubles AI's estimates of its spread moves' damage to its partner (item 12b).
- `log_ai_move_rating.py`: logs the trainer AI's ratings of the Gen V+ moves Platinum's AI script doesn't know (item 12b, `docs/AIReview.md` #11).
