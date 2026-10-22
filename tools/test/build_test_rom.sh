#!/usr/bin/env bash
# Build the Imperial *test* ROM (never ship it) into decomp/build_test/pokeplatinum.us.nds.
# The test build adds: a test party and items at new game (Garchomp 50 with Gen IX moves, Turtwig 15, Starly 5, two Gallade 30 with Justified [hidden ability] and Sharpness [ID 292], 3 Rare Candies, a Super Repel that ends after 3 steps + 2 in the bag),
# SELECT in the overworld = wild battle (Chansey 30), SELECT+R = trainer battle (src/overlay005/field_control.c).
set -euo pipefail
cd "$(dirname "$0")/../../decomp"
make BUILD=build_test configure >/dev/null
python3 subprojects/meson-*/meson.py configure build_test -Dimperial_test=true  # the meson the Makefile downloads
make BUILD=build_test rom
echo "test ROM: decomp/build_test/pokeplatinum.us.nds"
