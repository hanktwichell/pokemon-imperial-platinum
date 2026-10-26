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
| `check_type_chart.py` **CI** | the type charts match the official chart (needs PokeAPI's CSVs) |
| `find_tiles.py` | prints a map's tiles, to find spots for warps and new objects |

## The test build

The playtest harnesses run the test ROM, which has hooks for them (`decomp/include/sovereign_test.h`).
- `build_test_rom.sh` builds it into `decomp/build_test/`.
- `new_game.sh` makes a save state in the player's bedroom on a new game. Make a new one after every rebuild: a state
  holds the old code in RAM.
- `drive.py` drives the ROM from a state with a list of button presses. Its `Driver` is what the harnesses use.
- `boot_smoke.py` boots a ROM headlessly. CI runs it on the shipping ROM.

## Playtest harnesses (test build, local)

Run them headless with `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy`. The heap check (`heap_check.py`) runs in each
one and reports **HEAP**. The times are rough.

| Tool | Covers | Time |
|---|---|---|
| `battle_all_trainers.py` | every trainer: party matches its JSON, the battle ends | ~2 h with `--jobs 4` |
| `battle_all_species.py` | every species and form as a wild Pokémon | ~1 h with 4 jobs |
| `battle_form_changes.py` | Megas, Primals, Ultra Burst, in-battle forms, form-change items | ~1 h |
| `battle_evolutions.py` | every evolution that involves a form | ~25 min in 4 parts |
| `battle_eggs.py` | every form bred in the Day Care and hatched | ~1 h in 4 parts |
| `wild_forms.py` | wild Pokémon's forms on every map, through the real encounter code | ~20 min in 4 parts |
| `talk_to_objects.py` | every added or moved object runs its own script to its end | ~1 h in 4 parts |
| `signs_and_triggers.py` | every added sign, hidden item and coord trigger | ~10 min in 4 parts |
| `gift_pokemon.py` | every Pokémon gift: species, form, level, moves, ability | ~20 min |
| `elite_four_runs.py` | every path through the Elite Four's battle formats (13 runs) | ~40 min in 4 parts |
| `visit_changed_maps.py` | every changed map loads and the field runs | ~1 h |

Most take `--part I/N` (`battle_all_trainers.py` and `battle_all_species.py` take `--jobs N`) to split a run
across processes, one per core.

## Other

- `check_trainer_party.py`: one trainer's party in game against its JSON (used by `battle_all_trainers.py`).
- `log_ai_partner_damage.py`: logs the doubles AI's estimates of its spread moves' damage to its partner (item 12b).
