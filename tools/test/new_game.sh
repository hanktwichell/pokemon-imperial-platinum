#!/usr/bin/env bash
# Start a new game headlessly and play the intro up to the player's bedroom (player "A" (boy), rival "Barry").
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
  wait:600 'A*30' 'START*20' wait:120                            # title -> Rowan
  $(rep 10 A wait:40)                                            # Rowan's speech -> info menu
  DOWN DOWN A wait:60 $(rep 11 A wait:40)                        # NO INFO NEEDED
  wait:180 touch:128,97 wait:240 $(rep 7 A wait:40)              # touch the Poke Ball
  $(rep 17 A wait:60)                                            # -> boy or girl
  wait:60 touch:120,80 wait:150 A wait:100 A wait:100            # boy
  A wait:200 A A wait:30 START wait:30 A wait:200                # name "A"
  wait:60 touch:120,80 wait:150 $(rep 3 A wait:100) A wait:100 A wait:150
  A wait:100 A wait:100
  wait:120 DOWN wait:20 A wait:200                               # rival name menu
  DOWN wait:20 A wait:150 touch:120,80 wait:150                  # Barry
  A wait:150 touch:120,80 wait:200
  A wait:150 A wait:200 $(rep 40 A wait:60)                      # -> bedroom
  shot:bedroom
)
python3 -W ignore tools/test/drive.py "$rom" - "$out" "$dir" "${acts[@]}" >/dev/null 2>&1
echo "bedroom state: $out (screenshot: $dir/bedroom.png)"
