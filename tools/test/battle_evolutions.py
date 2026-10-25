#!/usr/bin/env python3
"""Evolve every Pokémon whose evolution involves a form in the test build, and check the form it evolves into.

The cases (each evolution in the species' data, res/pokemon/*/data.json, that the test can set up):
- every form with evolutions of its own (Alolan Vulpix, Galarian Meowth, Hisuian Sliggoo...);
- every base form that evolves into a species with forms (Pikachu into Raichu, Espurr into Meowstic, Kubfu into
  Urshifu...), once for each form the evolution can give: each gender for a species with a female's form, a personality
  for each of a species' personality forms (Pumpkaboo's sizes, Low Key Toxtricity, Antique Polteageist), each item
  for an item evolution into a form (the Scroll of Waters).

Evolutions that hang on the time of day or the date (Rockruff's Lycanroc, Alcremie's cream, Deerling's season) or
on something the test can't set up (stats, beauty, Shedinja) are left out, and listed with -v.

For each case this loads a save state in the overworld and writes the Pokémon to gSovereignTestLead
(include/sovereign_test.h): the species and form, a level that meets the evolution's, its gender or personality,
full friendship, a held item or a move the evolution needs, and the partner species it needs second in the party
(gSovereignTestPartner). gSovereignTestEvolve evolves it as the evolution screen does (Pokemon_GetEvolutionTargetSpecies
with the evolution's class and item, then Pokemon_SovereignSetEvolvedSpecies), and it battles a wild Chansey in its
new form as in battle_form_changes.py.

The evolved form it must have is worked out as src/pokemon.c does: an item evolution into a form takes that form
(sSovereignItemEvolutionForms); a regional form takes its region's form of the target (sSovereignFormEvolutions), or
0; any other form is kept; and a target whose form comes from the personality takes that one
(Pokemon_SovereignPersonalityForm, mirrored in personality_form below).

Each case gets a result: ok, EVOLVE (it didn't evolve, or into the wrong species or form), FORM (its form changed in
the battle), HANG or STUCK. Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_evolutions.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [-v] [SPECIES ...]
SPECIES (a constant) limits the list to the cases that start from those species. Each result is a line in
OUT_DIR/results.txt.
"""
import functools
import json
import os
import random
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_species import sovereign_forms  # noqa: E402
from battle_all_trainers import DECOMP, fight, symbols  # noqa: E402
from battle_form_changes import FOE, LEAD  # noqa: E402
from check_trainer_party import consts, form_dirs  # noqa: E402

FRAME_LIMIT = 6400
LEAD_EXTRA = {'gender': 17, 'friendship': 18, 'personality': 20}  # the rest of struct SovereignTestLead
# struct SovereignTestEvolve: u8 evolve, u8 evoClass, u16 param, u16 target, u16 species, u8 form
EVOLVE = {'evolve': 0, 'class': 1, 'param': 2, 'target': 4, 'species': 6, 'form': 8}
EVO_CLASS_BY_LEVEL, EVO_CLASS_BY_TRADE, EVO_CLASS_BY_ITEM = 0, 1, 3
GENDER_MALE, GENDER_FEMALE, GENDER_NONE = 0, 1, 2
# Toxtricity's Low Key natures (Pokemon_SovereignPersonalityForm)
LOW_KEY = {'NATURE_LONELY', 'NATURE_BOLD', 'NATURE_RELAXED', 'NATURE_TIMID', 'NATURE_SERIOUS', 'NATURE_MODEST',
           'NATURE_MILD', 'NATURE_QUIET', 'NATURE_BASHFUL', 'NATURE_CALM', 'NATURE_GENTLE', 'NATURE_CAREFUL'}
# Forms that come from the date or the time of day, which the test doesn't set.
TIMED = {'SPECIES_DEERLING', 'SPECIES_SAWSBUCK', 'SPECIES_LYCANROC', 'SPECIES_ALCREMIE'}


@functools.lru_cache(maxsize=None)
def data_of(species, form=0):
    path = form_dirs().get((species, form), species[8:].lower())
    return json.load(open(os.path.join(DECOMP, 'res', 'pokemon', path, 'data.json')))


def form_tables():
    """sSovereignFormEvolutions {(species, form, target): target form} and sSovereignItemEvolutionForms
    {(species, item): (target, form)} from include/data/sovereign_forms.h."""
    text = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_forms.h')).read()

    def block(name):
        part = text[text.index(name + '[]'):]
        return part[:part.index('};')]

    regional = {(s, int(f), t): int(tf) for s, f, tf, t in
                re.findall(r'\{ (SPECIES_\w+), (\d+), (\d+), (SPECIES_\w+) \}', block('sSovereignFormEvolutions'))}
    items = {(s, i): (t, int(f)) for s, i, t, f in
             re.findall(r'\{ (SPECIES_\w+), (ITEM_\w+), (SPECIES_\w+), (\d+) \}', block('sSovereignItemEvolutionForms'))}
    return regional, items


class Forms:
    def __init__(self):
        self.table = sovereign_forms()
        self.ratios = dict(line.split(' = ') for line in
                           open(os.path.join(DECOMP, 'generated', 'gender_ratios.txt')).read().splitlines() if line)
        self.natures = consts('natures.txt')

    def gender_of(self, species, p):
        """Pokemon_GetGenderOf: the species' own gender ratio (its base form's)."""
        ratio = self.ratio(species)
        return {0: GENDER_MALE, 254: GENDER_FEMALE, 255: GENDER_NONE}.get(ratio, GENDER_FEMALE if ratio > (p & 0xFF)
                                                                            else GENDER_MALE)

    @functools.lru_cache(maxsize=None)
    def ratio(self, species):
        return int(self.ratios[data_of(species)['gender_ratio']])

    @functools.lru_cache(maxsize=None)
    def kinds(self, species):
        """Its gender form, if any, and the personality forms before it in the table (the C function's search stops
        at the first gender form)."""
        gender, personality = None, []
        for s, f, kind, _ in self.table:
            if s == species and kind == 'SOVEREIGN_FORM_GENDER':
                gender = f
                break
            if s == species and kind == 'SOVEREIGN_FORM_PERSONALITY':
                personality.append(f)
        return gender, tuple(personality)

    def personality_form(self, species, p):
        """Pokemon_SovereignPersonalityForm (src/pokemon.c): the form the personality gives, or -1."""
        if species in ('SPECIES_PUMPKABOO', 'SPECIES_GOURGEIST'):
            return [0, 0, 0, 0, 1, 1, 1, 2, 2, 3][p % 10]
        if species == 'SPECIES_TOXTRICITY':
            return int(self.natures[p % 25] in LOW_KEY)
        if species in ('SPECIES_MAUSHOLD', 'SPECIES_DUDUNSPARCE'):
            return int(p % 100 == 0)
        if species in ('SPECIES_SINISTEA', 'SPECIES_POLTEAGEIST', 'SPECIES_POLTCHAGEIST', 'SPECIES_SINISTCHA'):
            return int(p % 10 == 0)
        if species == 'SPECIES_VIVILLON':
            pattern = p % 20
            return 0 if pattern == 6 else pattern + 1 if pattern < 6 else pattern
        gender, personality = self.kinds(species)
        if gender is not None:
            return gender if self.gender_of(species, p) == GENDER_FEMALE else 0
        if not personality:
            return -1
        pick = p % (len(personality) + 1)
        return personality[pick - 1] if pick else 0

    @functools.lru_cache(maxsize=None)
    def forms_of(self, species):
        return {f for s, f, kind, _ in self.table if s == species and kind in ('SOVEREIGN_FORM_PERSONALITY',
                                                                                 'SOVEREIGN_FORM_GENDER')}


def find_personality(rng, want):
    """A personality for which want(p) holds."""
    for _ in range(20000):
        p = rng.getrandbits(32) or 1
        if want(p):
            return p
    return None


def cases(forms, verbose=False):
    regional, item_forms = form_tables()
    species_list = consts('species.txt')
    rng = random.Random(1)
    out, skipped = [], []
    regional_forms = {(s, f) for s, f, kind, _ in forms.table if kind == 'SOVEREIGN_FORM_REGIONAL'}
    has_forms = {s for s, *_ in forms.table}
    starts = [(s, f) for s, f in form_dirs() if data_of(s, f).get('evolutions')]
    starts += [(s, 0) for s in species_list if s.startswith('SPECIES_') and s not in ('SPECIES_NONE', 'SPECIES_EGG',
                                                                                     'SPECIES_BAD_EGG')
               and any(e[-1] in has_forms for e in data_of(s).get('evolutions') or [])]
    for species, form in starts:
        for method, *params, target in data_of(species, form).get('evolutions') or []:
            label = f'{species} {form} -> {target} ({method} {" ".join(map(str, params))})'
            setup = {'level': 50, 'gender': 0, 'item': 'ITEM_NONE', 'move': None, 'partner': None,
                     'class': EVO_CLASS_BY_LEVEL, 'param': 0}
            if method in ('EVO_LEVEL', 'EVO_LEVEL_MALE', 'EVO_LEVEL_FEMALE'):
                setup['level'] = max(params[0], 2)
            elif method == 'EVO_LEVEL_HAPPINESS':
                pass  # full friendship
            elif method in ('EVO_USE_ITEM', 'EVO_USE_ITEM_MALE', 'EVO_USE_ITEM_FEMALE'):
                setup.update({'class': EVO_CLASS_BY_ITEM, 'param': params[0]})
            elif method == 'EVO_TRADE':
                setup['class'] = EVO_CLASS_BY_TRADE
            elif method == 'EVO_TRADE_WITH_HELD_ITEM':
                setup.update({'class': EVO_CLASS_BY_TRADE, 'item': params[0]})
            elif method == 'EVO_LEVEL_KNOW_MOVE':
                setup['move'] = params[0]
            elif method == 'EVO_LEVEL_SPECIES_IN_PARTY':
                setup['partner'] = params[0]
            elif method in ('EVO_LEVEL_MAGNETIC_FIELD', 'EVO_LEVEL_MOSS_ROCK', 'EVO_LEVEL_ICE_ROCK'):
                setup['param'] = method  # the map's evolution method
            else:
                skipped.append(label + ': the test can\'t set this up')
                continue
            if target in TIMED or species in TIMED:
                skipped.append(label + ': the form comes from the time or the date')
                continue
            if method.endswith('_MALE'):
                setup['gender'] = GENDER_MALE + 1
            elif method.endswith('_FEMALE'):
                setup['gender'] = GENDER_FEMALE + 1
            # The variants whose forms differ: each target form a personality can give, and each gender.
            variants = sorted(forms.forms_of(target) | {0}) if forms.forms_of(target) else [None]
            for want_form in variants:
                def ok(p, want_form=want_form):
                    if setup['gender'] and forms.gender_of(species, p) != setup['gender'] - 1:
                        return False
                    own = forms.personality_form(species, p)
                    if own >= 0 and own != form:
                        return False  # the start form must be the one its personality gives
                    return want_form is None or forms.personality_form(target, p) == want_form
                p = find_personality(rng, ok)
                if p is None:
                    if want_form is not None:
                        skipped.append(f'{label}: no personality gives form {want_form}')
                    continue
                if setup['class'] == EVO_CLASS_BY_ITEM and (species, setup['param']) in item_forms:
                    want = item_forms[(species, setup['param'])][1]
                elif (species, form) in regional_forms:
                    want = regional.get((species, form, target), 0)
                else:
                    want = form
                if forms.personality_form(target, p) >= 0:
                    want = forms.personality_form(target, p)
                out.append(dict(setup, species=species, form=form, target=target, want=want, personality=p,
                                label=label))
    if verbose:
        for line in skipped:
            print('left out:', line)
    return out


def main():
    from drive import Driver

    args = sys.argv[1:]
    verbose = '-v' in args
    if verbose:
        args.remove('-v')
    rom, state, out = args[:3]
    only = set(args[3:])
    os.makedirs(out, exist_ok=True)
    species_ids, items, moves = consts('species.txt'), consts('items.txt'), consts('moves.txt')
    methods = consts('evolution_methods.txt')
    sym = symbols(('gSovereignTestLead', 'gSovereignTestWild', 'gSovereignTestPartner', 'gSovereignTestEvolve',
                   'gSovereignTestLeadFormAfter', 'gSovereignTestFoeSurvivesTurns', 'gSovereignTestGodMode',
                   'gSovereignTestIdleFrames', 'gSystem'))
    chosen = [(i, c) for i, c in enumerate(cases(Forms(), verbose)) if not only or c['species'] in only]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory

    def u16(addr):
        return struct.unpack('<H', bytes(mem.unsigned[addr:addr + 2]))[0]

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, c in chosen:
            d.emu.savestate.load_file(state)
            d.run(30)
            lead, wild, evolve = sym['gSovereignTestLead'], sym['gSovereignTestWild'], sym['gSovereignTestEvolve']
            mem.write_short(lead + LEAD['species'], species_ids.index(c['species']))
            mem.write_byte(lead + LEAD['form'], c['form'])
            mem.write_byte(lead + LEAD['level'], c['level'])
            mem.write_short(lead + LEAD['item'], items.index(c['item']))
            if c['move']:
                mem.write_short(lead + LEAD['moves'] + 6, moves.index(c['move']))  # its fourth move
            mem.write_byte(lead + LEAD_EXTRA['friendship'], 255)
            mem.write_long(lead + LEAD_EXTRA['personality'], c['personality'])
            if c['partner']:
                mem.write_short(sym['gSovereignTestPartner'], species_ids.index(c['partner']))
                mem.write_byte(sym['gSovereignTestPartner'] + 3, 50)
            param = c['param']
            param = items.index(param) if str(param).startswith('ITEM_') else \
                methods.index(param) if str(param).startswith('EVO_') else param
            mem.write_byte(evolve + EVOLVE['evolve'], 1)
            mem.write_byte(evolve + EVOLVE['class'], c['class'])
            mem.write_short(evolve + EVOLVE['param'], param)
            mem.write_short(wild, species_ids.index(FOE[0]))
            mem.write_byte(wild + 3, FOE[1])
            mem.write_short(wild + 4, moves.index(FOE[2]))
            mem.write_byte(sym['gSovereignTestLeadFormAfter'], 0xFF)
            mem.write_byte(sym['gSovereignTestGodMode'], 1)
            d.press('SELECT')
            result, frames = fight(d, sym, FRAME_LIMIT)

            target, species, form = (species_ids[u16(evolve + EVOLVE['target'])], species_ids[u16(evolve + EVOLVE['species'])],
                                     mem.unsigned[evolve + EVOLVE['form']])
            after = mem.unsigned[sym['gSovereignTestLeadFormAfter']]
            problems = []
            if (target, species, form) != (c['target'], c['target'], c['want']):
                problems.append(f'evolved into {species} form {form} (target {target}), want {c["target"]} form '
                                f'{c["want"]}')
                result = 'EVOLVE' if result == 'ok' else result + '+EVOLVE'
            elif after != form:
                problems.append(f'form after the battle {after}, want {form}')
                result = 'FORM' if result == 'ok' else result + '+FORM'
            if result != 'ok':
                d.screenshot().save(os.path.join(out, f'{index:03d}_{c["species"]}_{result}.png'))
                bad += 1
            line = f'{index} {c["label"]} personality {c["personality"]:08x} -> form {c["want"]}: {result} {frames}' + \
                (' | ' + '; '.join(problems) if problems else '')
            print(line, file=f, flush=True)
            print(line, flush=True)
    print(f'{len(chosen) - bad} of {len(chosen)} ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
