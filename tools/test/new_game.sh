#!/usr/bin/env bash
# Start a new game headlessly up to the player's bedroom (player "A" (boy), rival "Barry"). Needs the test build,
# which skips Professor Rowan's intro (src/game_start.c); drive.py boots with a blank battery.
# Writes an emulator save state at the bedroom. Save states only work with the ROM they were made with, so
# rerun this after every rebuild.
#
#   tools/test/new_game.sh ROM STATE_OUT [OUT_DIR]
set -euo pipefail
cd "$(dirname "$0")/../.."
rom="${1:?usage: $0 ROM STATE_OUT [OUT_DIR]}"
out="${2:?usage: $0 ROM STATE_OUT [OUT_DIR]}"
dir="${3:-build/new_game}"
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-dummy}" SDL_AUDIODRIVER="${SDL_AUDIODRIVER:-dummy}"

rep() { local n=$1; shift; for _ in $(seq "$n"); do echo -n "$* "; done; }

acts=(
  wait:600 A wait:200 A wait:200                                 # title -> main menu (a blank battery has no CONTINUE)
  A wait:400                                                     # NEW GAME: the test build skips Rowan's intro
  $(rep 12 A wait:60) wait:120                                   # the TV program in the bedroom -> free to move
  shot:bedroom
)
python3 -W ignore tools/test/drive.py "$rom" - "$out" "$dir" "${acts[@]}" >/dev/null 2>&1
echo "bedroom state: $out (screenshot: $dir/bedroom.png)"
