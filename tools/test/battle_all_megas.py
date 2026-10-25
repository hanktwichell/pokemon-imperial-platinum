#!/usr/bin/env python3
"""Mega Evolve every Mega, Primal and Ultra Burst form from the player's side in the test build, and check that a
form with no Mega of its own can't.

The list comes from include/data/sovereign_forms.h:
- each Mega: the species in the form it Mega Evolves from (sSovereignBattleFormBases, else its base form), holding
  the form's stone; Mega Rayquaza knowing Dragon Ascent and holding nothing;
- each Primal: Kyogre or Groudon holding its Orb (it reverts as it comes in, with no button);
- each Ultra Burst: Dusk Mane or Dawn Wings Necrozma holding the Ultranecrozium Z;
- and each other form of a species with a Mega (a regional form, a Floette's flower color, 10% Zygarde...) holding
  each of that species' stones, which must not Mega Evolve. (It may still take another battle form: Battle Bond
  Greninja becomes Ash-Greninja when it knocks the foe out.)

For each one this loads a save state in the overworld (where the test build has given the Mega Ring), writes the
Pokémon to gSovereignTestLead (include/sovereign_test.h), so the party's lead becomes it at Lv. 50 with four Fairy
moves, with the MEGA toggle on for every move, and presses SELECT for a wild battle. God mode is on and the battle is
played as in battle_all_trainers.py. Afterwards it reads two test-build hooks: the first form a battle form change
gave the player's side (gSovereignTestPlayerBattleForm), which must be the Mega's (or, for a form with no Mega, none
of the species' Megas), and the lead's form once the battle is over (gSovereignTestLeadFormAfter), which must be the
one it started in.

Each one gets a result: ok, FORM (the wrong form in battle or after it, as the line says), HANG or STUCK (as in
battle_all_trainers.py), with a screenshot for any that isn't ok.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_all_megas.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [SPECIES ...]
SPECIES (a constant, e.g. SPECIES_MEOWSTIC) limits the list to those species. The whole list takes about 20 minutes.
Each result is a line in OUT_DIR/results.txt.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_species import sovereign_forms  # noqa: E402
from battle_all_trainers import DECOMP, fight, symbols  # noqa: E402
from check_trainer_party import consts  # noqa: E402

LEVEL = 50
FRAME_LIMIT = 6400
LEAD = 'gSovereignTestLead'  # struct SovereignTestLead: u16 species, u8 form, u8 level, u16 item, u16 move, u8 mega
# Forms that are a battle's only (they go back when it ends), so no party Pokémon is in one.
MEGA_KINDS = ('SOVEREIGN_FORM_MEGA', 'SOVEREIGN_FORM_PRIMAL', 'SOVEREIGN_FORM_MEGA_BY_MOVE',
              'SOVEREIGN_FORM_ULTRA_BURST')
BATTLE_KINDS = MEGA_KINDS + ('SOVEREIGN_FORM_BATTLE', 'SOVEREIGN_FORM_BATTLE_ITEM', 'SOVEREIGN_FORM_BATTLE_MOVE')


def battle_form_bases():
    """{(species, battle form): the form it comes from} for battle forms that don't come from form 0."""
    table = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_forms.h')).read()
    table = table[table.index('sSovereignBattleFormBases['):]
    return {(s, int(f)): int(b) for s, f, b in re.findall(r'\{ (SPECIES_\w+), (\d+), (\d+) \}',
                                                           table[:table.index('};')])}


def cases():
    """[(species, lead form, item, move, expected battle form, label)]."""
    forms = sovereign_forms()
    bases = battle_form_bases()
    out = []
    stones = {}
    for species, form, kind, trigger in forms:
        if kind == 'SOVEREIGN_FORM_MEGA':
            base = bases.get((species, form), 0)
            out.append((species, base, trigger, 'MOVE_NONE', form, 'Mega'))
            stones.setdefault(species, {}).setdefault(trigger, set()).add(base)
        elif kind == 'SOVEREIGN_FORM_MEGA_BY_MOVE':
            out.append((species, 0, 'ITEM_NONE', trigger, form, 'Mega by move'))
        elif kind == 'SOVEREIGN_FORM_PRIMAL':
            out.append((species, 0, trigger, 'MOVE_NONE', form, 'Primal'))
        elif kind == 'SOVEREIGN_FORM_ULTRA_BURST':
            out.append((species, int(trigger), 'ITEM_ULTRANECROZIUM_Z', 'MOVE_NONE', form, 'Ultra Burst'))
    for species, form, kind, _ in forms:
        if species in stones and kind not in BATTLE_KINDS:
            for stone, from_forms in stones[species].items():
                if form not in from_forms:
                    out.append((species, form, stone, 'MOVE_NONE', 0, 'no Mega'))
    for species in stones:  # the base form, with a stone whose Mega comes from another form (Mega Floette)
        for stone, from_forms in stones[species].items():
            if 0 not in from_forms:
                out.append((species, 0, stone, 'MOVE_NONE', 0, 'no Mega'))
    return out


def main():
    from drive import Driver

    rom, state, out = sys.argv[1:4]
    only = set(sys.argv[4:])
    os.makedirs(out, exist_ok=True)
    species_ids, items, moves = consts('species.txt'), consts('items.txt'), consts('moves.txt')
    sym = symbols(('gSovereignTestLead', 'gSovereignTestPlayerBattleForm', 'gSovereignTestLeadFormAfter',
                   'gSovereignTestGodMode', 'gSovereignTestIdleFrames', 'gSystem'))
    megas = {}
    for species, form, kind, _ in sovereign_forms():
        if kind in MEGA_KINDS:
            megas.setdefault(species, set()).add(form)
    d = Driver(rom, state)
    d.added, d.armed = [], False
    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, (species, form, item, move, want, label) in enumerate(cases()):
            if only and species not in only:
                continue
            d.emu.savestate.load_file(state)
            d.run(30)
            lead = sym[LEAD]
            d.emu.memory.write_short(lead, species_ids.index(species))
            d.emu.memory.write_byte(lead + 2, form)
            d.emu.memory.write_byte(lead + 3, LEVEL)
            d.emu.memory.write_short(lead + 4, items.index(item))
            d.emu.memory.write_short(lead + 6, moves.index(move))
            d.emu.memory.write_byte(lead + 8, 1)
            d.emu.memory.write_byte(sym['gSovereignTestLeadFormAfter'], 0xFF)
            d.emu.memory.write_byte(sym['gSovereignTestGodMode'], 1)
            d.press('SELECT')
            result, frames = fight(d, sym, FRAME_LIMIT)

            got = d.emu.memory.unsigned[sym['gSovereignTestPlayerBattleForm']]
            after = d.emu.memory.unsigned[sym['gSovereignTestLeadFormAfter']]
            problems = []
            if (got != want) if want else (got in megas[species]):
                problems.append(f'battle form {got}, want {want or "none of " + str(sorted(megas[species]))}')
            if after != form:
                problems.append(f'form after the battle {after}, want {form}')
            if problems:
                result = 'FORM' if result == 'ok' else result + '+FORM'
            if result != 'ok':
                d.screenshot().save(os.path.join(out, f'{index:03d}_{species}_{form}_{result}.png'))
                bad += 1
            line = f'{index} {species} {form} {item} {move} ({label}) {result} {frames}' + \
                (' | ' + '; '.join(problems) if problems else '')
            print(line, file=f, flush=True)
            print(line, flush=True)
    total = sum(1 for c in cases() if not only or c[0] in only)
    print(f'{total - bad} of {total} ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
