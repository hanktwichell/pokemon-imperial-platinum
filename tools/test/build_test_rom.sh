#!/usr/bin/env bash
# Build the Sovereign *test* ROM (never ship it) into decomp/build_test/pokeplatinum.us.nds.
# The test build skips Professor Rowan's intro at NEW GAME (hold L to play it; player "A", rival "Barry"), and adds: a test party and items at new game (Garchomp 50 with Gen IX moves, Turtwig 15, Starly 5, Gallade 30 with Justified [hidden ability], Archaludon 50 [#1018, an E6 species], 3 Rare Candies, a Super Repel that ends after 3 steps + 2 in the bag, HM02 and HM05, a Ditto for the SELECT+L breeding test, and six E7 items: Assault Vest, Heavy-Duty Boots, Unremark. Teacup, Charizardite X, Metal Alloy, Mega Ring),
# SELECT in the overworld = wild battle (Chansey 30), SELECT+R = trainer battle, SELECT+B = Easy Chat word picker (src/overlay005/field_control.c).
set -euo pipefail
cd "$(dirname "$0")/../../decomp"
make BUILD=build_test configure >/dev/null
python3 subprojects/meson-*/meson.py configure build_test -Dsovereign_test=true  # the meson the Makefile downloads
make BUILD=build_test rom
echo "test ROM: decomp/build_test/pokeplatinum.us.nds"
