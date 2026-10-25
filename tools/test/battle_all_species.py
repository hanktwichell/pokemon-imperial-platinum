#!/usr/bin/env python3
"""Battle every species in every form as a wild Pokémon in the test build: the game builds it right, the battle runs
to the end, nothing hangs.

The list is every species (decomp/generated/species.txt, but not the Egg) in its base form, and every form of one:
Platinum's (decomp/res/pokemon/form_registry.json) and Sovereign's (include/data/sovereign_forms.h). For each, this
loads a save state in the overworld, writes the species, form and level 50 to the test build's gSovereignTestWild
(include/sovereign_test.h) and presses SELECT for a wild battle against it, made the way the game makes a wild
Pokémon in a form (CreateWildMon_SovereignScriptedForm, as for a Regional Forms Park slot or a Totem). God mode is on
and the battle is played as in battle_all_trainers.py, so the player's Garchomp knocks the foe out with a Fairy move.

The Pokémon the game built (caught with a hook on Party_AddPokemon) is checked against the form's data
(check_trainer_party.species_data): species, form and level; moves, which must be the form's level-up moves;
all six stats, recomputed from the form's base stats and the Pokémon's own IVs, EVs and nature; the ability, which
must be the one its personality picks from the form's (or its hidden ability, if it has one); and its held item, none
or one of the form's. A base form may come back as a form its personality picks (Minior's core, a Female Meowstic)
or the map does (an Unown letter, East Sea Shellos and Gastrodon), and is then checked as that form.

Each one gets a result:
- **DATA:** the Pokémon differs from its form's data (the line says how).
- **HANG:** the main loop stopped (gSystem's vblankCounter didn't move for 120 frames), which is a crash.
- **STUCK:** the battle didn't end in time: a prompt the taps don't answer, or a soft lock. See its screenshot.
- **ok:** the battle ended and the field runs again.
- **NO-RESULT:** (with --jobs) the worker for it stopped first, e.g. killed by a time limit.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_all_species.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--jobs N] [--shots] [ENTRY ...]
ENTRY is a species constant (SPECIES_ROTOM, all its forms), SPECIES_X:FORM, or an index range in the list (100-199);
the default is the whole list. Each result is a line in OUT_DIR/results.txt (its place in the list, the species, the
form, the result, the frames the battle took), with a screenshot for any that isn't ok; --shots also saves a screen
every 600 frames. Each battle takes about 1,000 frames, so the whole list is about an hour with 4 jobs.
"""
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_trainers import DECOMP, fight, symbols  # noqa: E402
from check_trainer_party import (consts, default_moves, expected_stats, form_dirs, read_pokemon,  # noqa: E402
                                 species_data)

LEVEL = 50
FRAME_LIMIT = 6400
# Forms a Pokémon can get from its personality when it's made (Pokemon_SovereignPersonalityForm, src/pokemon.c).
PERSONALITY_KINDS = ('SOVEREIGN_FORM_PERSONALITY', 'SOVEREIGN_FORM_GENDER')


def sovereign_forms():
    """[(species constant, form, kind, trigger)] in include/data/sovereign_forms.h's sSovereignForms."""
    table = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_forms.h')).read()
    table = table[table.index('sSovereignForms['):]
    return [(s, int(f), k, t) for s, f, k, t in re.findall(r'\{ (SPECIES_\w+), (\d+), (SOVEREIGN_FORM_\w+), (\w+) \}',
                                                             table[:table.index('};')])]


def entries():
    """[(species constant, form)]: each species' base form, then its forms."""
    species = consts('species.txt')
    registry = json.load(open(os.path.join(DECOMP, 'res', 'pokemon', 'form_registry.json')))
    forms = {}
    for name, names in registry.items():
        count = len([n for n in names if not n.startswith('__')])
        forms.setdefault('SPECIES_' + name.upper(), set()).update(range(1, count + 1))
    for name, form in form_dirs():
        forms.setdefault(name, set()).add(form)
    for name, form, *_ in sovereign_forms():
        forms.setdefault(name, set()).add(form)
    out = []
    for name in species:
        if name in ('SPECIES_NONE', 'SPECIES_EGG', 'SPECIES_BAD_EGG'):
            continue
        out += [(name, form) for form in [0] + sorted(forms.get(name, ()))]
    return out


def pick(args):
    listed = entries()
    if not args:
        return list(enumerate(listed))
    chosen = []
    for arg in args:
        if re.fullmatch(r'\d+-\d+', arg):
            lo, hi = map(int, arg.split('-'))
            chosen += [(i, e) for i, e in enumerate(listed) if lo <= i <= hi]
        else:
            name, _, form = arg.partition(':')
            chosen += [(i, e) for i, e in enumerate(listed) if e[0] == name and (not form or e[1] == int(form))]
    return chosen


def check(raw, name, form, personality_forms):
    """The ways the Pokémon the game built differs from its form's data (empty if none)."""
    species, moves, items, abilities = consts('species.txt'), consts('moves.txt'), consts('items.txt'), \
        consts('abilities.txt')
    got = read_pokemon(raw)
    problems = []
    if species[got['species']] != name:
        return [f'species {species[got["species"]]}']
    if got['form'] != form and not (form == 0 and got['form'] in personality_forms.get(name, ())):
        problems.append(f'form {got["form"]}')
    form = got['form']
    if got['level'] != LEVEL:
        problems.append(f'level {got["level"]}')
    want = default_moves(name, form, LEVEL)
    if [moves[m] for m in got['moves']] != want:
        problems.append(f'moves {[moves[m] for m in got["moves"]]}, want {want}')
    nature = got['personality'] % 25
    want = expected_stats(name, LEVEL, got['ivs'], got['evs'], nature, form)
    if got['stats'] != want:
        problems.append(f'stats {got["stats"]}, want {want}')
    data = species_data(name, form)
    regular, hidden = data['abilities'][:2], data['abilities'][2] if len(data['abilities']) > 2 else 'ABILITY_NONE'
    if got['hidden_ability'] and hidden != 'ABILITY_NONE':
        want = hidden
    else:
        want = regular[got['personality'] & 1] if regular[1] != 'ABILITY_NONE' else regular[0]
    if abilities[got['ability']] != want:
        problems.append(f'ability {abilities[got["ability"]]}, want {want}')
    held = ('ITEM_NONE', data['held_items']['common'], data['held_items']['rare'])
    if items[got['item']] not in held:
        problems.append(f'item {items[got["item"]]}, want one of {held}')
    return problems


def battle(d, sym, state, index, name, form, out, personality_forms, shots=False):
    d.emu.savestate.load_file(state)
    d.run(30)
    d.emu.memory.write_short(sym['gSovereignTestWild'], consts('species.txt').index(name))
    d.emu.memory.write_byte(sym['gSovereignTestWild'] + 2, form)
    d.emu.memory.write_byte(sym['gSovereignTestWild'] + 3, LEVEL)
    d.emu.memory.write_byte(sym['gSovereignTestGodMode'], 1)
    d.added.clear()
    d.armed = True  # the foe is made as the battle starts
    d.press('SELECT')

    shot = (lambda frames: d.screenshot().save(os.path.join(out, f'{index:04d}_{frames:05d}.png'))) if shots else None
    result, frames = fight(d, sym, FRAME_LIMIT, shot)

    problems = check(d.added[0], name, form, personality_forms) if len(d.added) == 1 \
        else [f'{len(d.added)} Pokémon made']
    if problems:
        result = 'DATA' if result == 'ok' else result + '+DATA'
    if result != 'ok':
        d.screenshot().save(os.path.join(out, f'{index:04d}_{name}_{form}_{result}.png'))
    return f'{index} {name} {form} {result} {frames}' + (' | ' + '; '.join(problems) if problems else '')


def main():
    args = sys.argv[1:]
    jobs, worker = 1, None
    if '--jobs' in args:
        i = args.index('--jobs')
        jobs = int(args[i + 1])
        del args[i:i + 2]
    shots = '--shots' in args
    if shots:
        args.remove('--shots')
    if '--worker' in args:
        i = args.index('--worker')
        worker = tuple(map(int, args[i + 1].split('/')))
        del args[i:i + 2]
    rom, state, out = args[:3]
    chosen = pick(args[3:])
    os.makedirs(out, exist_ok=True)

    if jobs > 1:
        procs = [subprocess.Popen([sys.executable, '-W', 'ignore', __file__, rom, state, out, '--worker',
                                   f'{k}/{jobs}'] + (['--shots'] if shots else []) + args[3:],
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                 for k in range(jobs)]
        for p in procs:
            p.wait()
        lines = []
        for k in range(jobs):
            path = os.path.join(out, f'results_{k}.txt')
            lines += open(path).read().splitlines()
            os.remove(path)
        lines.sort(key=lambda line: int(line.split()[0]))
        done = {int(line.split()[0]) for line in lines}
        lines += [f'{index} {name} {form} NO-RESULT 0 (its worker stopped)' for index, (name, form) in chosen
                  if index not in done]
        open(os.path.join(out, 'results.txt'), 'w').write('\n'.join(lines) + '\n')
        bad = [line for line in lines if line.split()[3] != 'ok']
        print('\n'.join(bad))
        print(f'{len(lines) - len(bad)} of {len(lines)} species and forms ok')
        sys.exit(1 if bad else 0)

    from drive import Driver

    sym = symbols(('gSovereignTestWild', 'gSovereignTestGodMode', 'gSovereignTestIdleFrames', 'gSystem'))
    personality_forms = {}
    for name, form, kind, _ in sovereign_forms():
        if kind in PERSONALITY_KINDS:
            personality_forms.setdefault(name, set()).add(form)
    # Platinum gives these their form from the map as they're added to the battle (AddWildMonToParty).
    personality_forms['SPECIES_UNOWN'] = set(range(28))  # the area's letters
    personality_forms['SPECIES_SHELLOS'] = personality_forms['SPECIES_GASTRODON'] = {1}  # East Sea

    d = Driver(rom, state)
    d.added, d.armed = [], False

    def on_add(_addr, _size):
        if d.armed:
            r1 = d.emu.memory.register_arm9.r1
            d.added.append(bytes(d.emu.memory.unsigned[r1:r1 + 236]))
        return True

    d.emu.memory.register_exec(sym['Party_AddPokemon'], on_add)
    if worker:
        k, n = worker
        chosen = chosen[k::n]
    path = os.path.join(out, f'results_{worker[0]}.txt' if worker else 'results.txt')
    bad = 0
    with open(path, 'w') as f:
        for index, (name, form) in chosen:
            line = battle(d, sym, state, index, name, form, out, personality_forms, shots)
            bad += line.split()[3] != 'ok'
            print(line, file=f, flush=True)
            if not worker:
                print(line, flush=True)
    if not worker:
        print(f'{len(chosen) - bad} of {len(chosen)} species and forms ok')
        sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
