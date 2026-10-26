#!/usr/bin/env bash
# Rebuild every generated data file and document, and run all validators.
#
#   tools/regenerate_docs.sh /path/to/pokeapi/data/v2/csv [/path/to/pokeplatinum]
#
# PokeAPI: git clone --depth 1 https://github.com/PokeAPI/pokeapi  (only data/v2/csv is needed)
# pokeplatinum (optional, validates Mega Stone field-item scripts): https://github.com/pret/pokeplatinum
# Python 3.9+ with PyYAML and Pillow.
set -euo pipefail
cd "$(dirname "$0")/.."
pokeapi="${1:?usage: $0 /path/to/pokeapi/data/v2/csv [/path/to/pokeplatinum]}"
decomp="${2:-}"

python3 tools/design/build_species_data.py "$pokeapi"
python3 tools/design/gen_encounters.py
python3 tools/engine/gen_wild_encounters.py
python3 tools/design/gen_trainer_docs.py --pokeapi "$pokeapi"
python3 tools/engine/gen_level_caps.py
python3 tools/engine/gen_regional_forms_park.py
python3 tools/engine/gen_rare_wild.py
python3 tools/engine/gen_totem_trials.py
if [ -n "$decomp" ]; then
  python3 tools/design/gen_mega_doc.py --decomp "$decomp"
else
  python3 tools/design/gen_mega_doc.py
fi
python3 tools/design/gen_evolution_doc.py
python3 tools/design/gen_legendary_doc.py
python3 -I tools/sprites/import_sprite_pack.py assets/sprites/packs/dppt_gen6_and_beyond
python3 tools/sprites/gen_sprite_checklist.py
python3 tools/sprites/smogon_credits.py
echo "All docs regenerated and validated."
