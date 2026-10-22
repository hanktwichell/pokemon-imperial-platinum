#!/usr/bin/env bash
# Apply Drayano's Renegade Platinum v1.3.0 patch to YOUR OWN Pokémon Platinum (US) ROM dump.
#
#   tools/build/apply_renegade_patch.sh <3541|4997> <platinum.nds> [output.nds]
#
# 3541: early-print carts / "3541" dumps. 4997: later carts / "4997" or "4998" dumps.
# Requires xdelta3 (apt install xdelta3 / brew install xdelta). xdelta3 checks the source
# checksum embedded in the patch, so the wrong base ROM fails here instead of freezing in-game.
# ROMs are never committed to this repository (see .gitignore).
set -euo pipefail

here="$(cd "$(dirname "$0")/../.." && pwd)"
rev="${1:-}"; rom="${2:-}"; out="${3:-RenegadePlatinum.nds}"
case "$rev" in
  3541|4997) ;;
  *) echo "usage: $0 <3541|4997> <platinum.nds> [output.nds]" >&2; exit 2 ;;
esac
[ -f "$rom" ] || { echo "ROM not found: $rom" >&2; exit 2; }
command -v xdelta3 >/dev/null || { echo "xdelta3 is not installed" >&2; exit 2; }

patch="$here/RenegadePlatinumV130/Base Patches - USE ONE OF THESE FIRST/RenegadePlatinum${rev}.xdelta"
xdelta3 -d -s "$rom" "$patch" "$out"
echo "Wrote $out"
