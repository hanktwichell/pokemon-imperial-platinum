#!/usr/bin/env python3
"""Evolve every Pokémon whose evolution involves a form in the test build, and check the form it evolves into.

The cases (each evolution in the species' data, res/pokemon/*/data.json, that the test can set up), from every form
but the battle forms (Mega, Primal, Zen Mode...):
- a regional form (kind SOVEREIGN_FORM_REGIONAL: Alolan Vulpix, Galarian Meowth, the cap Pikachu) evolves by its
  form's own evolutions, and any other form by its species' (Pokemon_GetEvolutionTargetSpecies). A regional form with
  none of its own (a cap Pikachu, Partner Eevee, Eternal Floette, Spiky-eared Pichu) must not evolve by its species';
- each base form of a species with forms, or that evolves into one (Pikachu into Raichu, Espurr into Meowstic);
- once for each form the evolution can give: each gender for a species with a female's form, a personality for each
  of a species' personality forms (Pumpkaboo's sizes, Low Key Toxtricity), each item for an item evolution into a
  form (the Scroll of Waters), each Sweet for Milcery, and day, night and twilight for
  Rockruff;
- the teapots both ways: only an Antique Sinistea evolves with the Chipped Pot, and only an ordinary one with the
  Cracked Pot (Poltchageist's teacups the same).

Evolutions that hang on something the test can't set up (stats, beauty, Shedinja) are left out, and listed with -v.

For each case this loads a save state in the overworld, sets the clock (gSovereignTestClock: the hour for a day or
night evolution, Rockruff and Milcery, and for a Deerling a month of another season than its own) and writes the
Pokémon to gSovereignTestLead (include/sovereign_test.h): the species and form, a level that meets the evolution's,
its personality, full friendship, a held item or a move the evolution needs, and the partner species it needs second
in the party (gSovereignTestPartner). gSovereignTestEvolve evolves it as the evolution screen does
(Pokemon_GetEvolutionTargetSpecies with the evolution's class and item, then Pokemon_SovereignSetEvolvedSpecies), and
it battles a wild Chansey in its new form as in battle_form_changes.py.

The evolved form it must have is worked out as src/pokemon.c does: an item evolution into a form takes that form
(sSovereignItemEvolutionForms); a regional form takes its region's form of the target (sSovereignFormEvolutions), or
0; any other form is kept (a Deerling keeps its season); a target whose form comes from the personality takes that
one (Pokemon_SovereignPersonalityForm, mirrored in personality_form below); and Rockruff's comes from the time. The
player gets only the base form of the cosmetic Pokémon (decision 50, docs/ProjectStatus.md): Milcery always evolves into
Vanilla Cream Strawberry Sweet Alcremie, whatever the Sweet and the time, and Spewpa into Meadow Vivillon. The names
cross-check it: an evolved form must be the target's form named as the start form is (Galarian Darumaka: Galarian
Darmanitan), or its base form when the target has none so named. Not for decision 50's flower colors and patterns,
which only trainers' Pokémon have: a Yellow Flower Flabébé evolves into the base Floette.

Each case gets a result: ok, EVOLVE (it didn't evolve, or into the wrong species or form, or it evolved when it
mustn't), NAMES (the form isn't the one the names give), FORM (its form changed in the battle), HANG or STUCK. Needs
what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_evolutions.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [-v] [--part I/N] [SPECIES ...]
SPECIES (a constant) limits the list to the cases that start from those species, and --part I/N to every Nth case
from the Ith (from 0; to run N at once, each with its own OUT_DIR). Each result is a line in OUT_DIR/results.txt.
"""
import functools
import json
import os
import random
import re
import struct
import sys
import unicodedata

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_species import entries, sovereign_forms  # noqa: E402
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
# struct SovereignTestClock: u8 hour (+ 1), u8 month
CLOCK = {'hour': 0, 'month': 1}
DAY, NIGHT, TWILIGHT = 12, 22, 18
# Forms only a battle gives: no Pokémon is in one when it evolves.
BATTLE_KINDS = {'SOVEREIGN_FORM_' + kind for kind in ('BATTLE', 'BATTLE_ITEM', 'BATTLE_MOVE', 'MEGA', 'MEGA_BY_MOVE',
                                                       'PRIMAL', 'ULTRA_BURST')}
# Pokemon_SovereignEvolutionItem: the Antique Sinistea and the Artisan Poltchageist evolve with these instead.
TEAPOTS = {('SPECIES_SINISTEA', 'ITEM_CRACKED_POT'): 'ITEM_CHIPPED_POT',
           ('SPECIES_POLTCHAGEIST', 'ITEM_UNREMARKABLE_TEACUP'): 'ITEM_MASTERPIECE_TEACUP'}
SWEETS = ['ITEM_STRAWBERRY_SWEET', 'ITEM_LOVE_SWEET', 'ITEM_BERRY_SWEET', 'ITEM_CLOVER_SWEET', 'ITEM_FLOWER_SWEET',
          'ITEM_STAR_SWEET', 'ITEM_RIBBON_SWEET']
# Words a form's name differs by that don't make it another form: the official names of the Artisan Poltchageist's
# line say Masterpiece for Sinistcha, and Standard Galarian Darmanitan is named for its Zen Mode.
QUALIFIER_ALIASES = {'artisan': 'masterpiece', 'standard': ''}
# Decision 50: the player gets only these species' base forms; their other forms (flower colors, patterns, creams) are
# for trainers' Pokémon and don't carry over as they evolve.
BASE_FORM_ONLY = {'SPECIES_FLABEBE', 'SPECIES_FLOETTE', 'SPECIES_FLORGES', 'SPECIES_VIVILLON', 'SPECIES_ALCREMIE'}


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
    items = {(s, i): (t, int(f)) for s, i, t, f in re.findall(r'\{ (SPECIES_\w+), (ITEM_\w+), (SPECIES_\w+), (\d+) \}',
                                                              block('sSovereignItemEvolutionForms'))}
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

    def kind(self, species, form):
        return next((kind for s, f, kind, _ in self.table if (s, f) == (species, form)), None)

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
        if species in ('SPECIES_DEERLING', 'SPECIES_SAWSBUCK'):
            return -1  # the month's season, not the personality's: a Deerling keeps its own as it evolves
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


def norm(word):
    return re.sub(r'[^a-z0-9]', '', unicodedata.normalize('NFKD', word).encode('ascii', 'ignore').decode().lower())


@functools.lru_cache(maxsize=None)
def form_names():
    """{(species, form): its name} from the comments in include/data/sovereign_forms.h's sSovereignForms."""
    text = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_forms.h')).read()
    text = text[text.index('sSovereignForms['):]
    return {(s, int(f)): name for s, f, name in
            re.findall(r'\{ (SPECIES_\w+), (\d+), SOVEREIGN_FORM_\w+, \w+ \}, // (.+)', text[:text.index('};')])}


def qualifier(species, form):
    """What a form's name says besides the species' name ("galarian", "small", "yellow flower"), or None."""
    name = form_names().get((species, form))
    if name is None:
        return None
    own = set(species[8:].lower().split('_')) | {species[8:].lower().replace('_', '')}
    words = [norm(w) for w in re.split(r'[\s(),]+', name) if norm(w) and norm(w) not in own]
    return ' '.join(w for w in (QUALIFIER_ALIASES.get(w, w) for w in words) if w)


def lycanroc_form(form, hour):
    """Pokemon_SovereignSetEvolvedSpecies: Own Tempo Rockruff at twilight (17:00 to 19:59) gives Dusk Lycanroc, 6:00 to
    17:59 Midday, other hours Midnight."""
    return 2 if form == 1 and 17 <= hour <= 19 else 0 if 6 <= hour < 18 else 1


def setup_for(method, params):
    """The lead's level, item, move or partner, the evolution's class and parameter, and the hour an evolution needs,
    or None when the test can't set it up."""
    setup = {'level': 50, 'gender': 0, 'item': 'ITEM_NONE', 'move': None, 'partner': None,
             'class': EVO_CLASS_BY_LEVEL, 'param': 0, 'hour': 0, 'month': 0}
    if method in ('EVO_LEVEL', 'EVO_LEVEL_MALE', 'EVO_LEVEL_FEMALE'):
        setup['level'] = max(params[0], 2)
    elif method == 'EVO_LEVEL_HAPPINESS':
        pass  # full friendship
    elif method in ('EVO_LEVEL_HAPPINESS_DAY', 'EVO_LEVEL_HAPPINESS_NIGHT'):
        setup['hour'] = DAY if method.endswith('_DAY') else NIGHT
    elif method in ('EVO_LEVEL_WITH_HELD_ITEM_DAY', 'EVO_LEVEL_WITH_HELD_ITEM_NIGHT'):
        setup.update({'item': params[0], 'hour': DAY if method.endswith('_DAY') else NIGHT})
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
        return None
    if method.endswith('_MALE'):
        setup['gender'] = GENDER_MALE + 1
    elif method.endswith('_FEMALE'):
        setup['gender'] = GENDER_FEMALE + 1
    return setup


def cases(forms, verbose=False):
    regional, item_forms = form_tables()
    rng = random.Random(1)
    out, skipped = [], []
    all_forms = entries()
    kinds = {(s, f): kind for s, f, kind, _ in forms.table}
    has_forms = {s for s, f in all_forms if f}
    forms_of = {}
    for s, f in all_forms:
        forms_of.setdefault(s, []).append(f)

    def add(c, species, form, target, label, p):
        c = dict(c, species=species, form=form, target=target, personality=p, label=label)
        # The form the names give: the target's form named as the start form is ("Galarian", "(Yellow Flower)"), or
        # its base form if it has none. Not for a target whose gender picks its form.
        q = qualifier(species, form)
        c['names_want'] = None
        if q is not None and target != 'SPECIES_NONE' and forms.kinds(target)[0] is None \
                and species != 'SPECIES_ROCKRUFF' and species not in BASE_FORM_ONLY:
            c['names_want'] = next((f for f in forms_of.get(target, []) if qualifier(target, f) == q), 0)
        out.append(c)

    for species, form in all_forms:
        kind = kinds.get((species, form))
        if kind in BATTLE_KINDS:
            continue
        own = data_of(species, form).get('evolutions') or [] if kind == 'SOVEREIGN_FORM_REGIONAL' else \
            data_of(species).get('evolutions') or []
        base = data_of(species).get('evolutions') or []
        if not form and species not in has_forms and not any(e[-1] in has_forms for e in base):
            continue
        evolutions = [(e, False) for e in own]
        if kind == 'SOVEREIGN_FORM_REGIONAL' and not own:
            evolutions = [(e, True) for e in base]  # it can't evolve (a cap Pikachu, Partner Eevee, Eternal Floette)
        for (method, *params, target), never in evolutions:
            label = f'{species} {form} -> {target} ({method} {" ".join(map(str, params))})'
            setup = setup_for(method, params)
            if setup is None:
                skipped.append(label + ': the test can\'t set this up')
                continue
            items = [setup['item'] if setup['class'] != EVO_CLASS_BY_ITEM else setup['param']]
            if species == 'SPECIES_MILCERY':
                items = SWEETS
            teapot = TEAPOTS.get((species, setup['param']))
            hours = [setup['hour']]
            if species in ('SPECIES_ROCKRUFF', 'SPECIES_MILCERY'):
                hours = [DAY, NIGHT, TWILIGHT]
            for item in items:
                for hour in hours:
                    run = dict(setup, hour=hour)
                    if setup['class'] == EVO_CLASS_BY_ITEM:
                        run['param'] = item
                    if species == 'SPECIES_DEERLING':
                        run['month'] = (form + 1) % 4 + 1  # a season other than its own: it keeps its own
                    # The variants whose forms differ: each target form a personality can give, each cream.
                    variants = sorted(forms.forms_of(target) | {0}) if forms.forms_of(target) and not never \
                        and species != 'SPECIES_DEERLING' else [None]
                    if species == 'SPECIES_MILCERY':
                        variants = [None]
                    found = 0
                    for variant in variants:
                        def ok(p, variant=variant):
                            if run['gender'] and forms.gender_of(species, p) != run['gender'] - 1:
                                return False
                            mine = forms.personality_form(species, p)
                            if mine >= 0 and mine != form and kind != 'SOVEREIGN_FORM_REGIONAL':
                                return False  # the start form is the one its personality gives (not Eternal Floette's)
                            return variant is None or forms.personality_form(target, p) == variant
                        p = find_personality(rng, ok)
                        if p is None:
                            continue  # this start form can't evolve into that one (a Small Pumpkaboo into a Large)
                        found += 1
                        tags = ([item] if species == 'SPECIES_MILCERY' else []) + ([f'{hour}:00'] if hour else []) + \
                            ([f'month {run["month"]}'] if run['month'] else [])
                        name = label + (f' [{", ".join(tags)}]' if tags else '')
                        if never:
                            add(dict(run, want=None), species, form, 'SPECIES_NONE', name + ' (can\'t evolve)', p)
                            continue
                        if teapot:
                            # Only the Antique or Artisan one evolves with the Chipped Pot or Masterpiece Teacup.
                            if form:
                                add(dict(run, want=None), species, form, 'SPECIES_NONE', f'{name} (needs {teapot})', p)
                                run = dict(run, param=teapot)
                                name = f'{name} [{teapot}]'
                            else:
                                add(dict(run, param=teapot, want=None), species, form, 'SPECIES_NONE',
                                    f'{name} [{teapot}] (an ordinary one)', p)
                        want = expected(forms, regional, item_forms, species, form, target, run, p)
                        add(dict(run, want=want), species, form, target, name, p)
                    if not found:
                        skipped.append(label + ': no personality gives this start form')
    if verbose:
        for line in skipped:
            print('left out:', line)
    return out


def expected(forms, regional, item_forms, species, form, target, run, p):
    """The form it must evolve into, as src/pokemon.c gives it."""
    if species == 'SPECIES_ROCKRUFF':
        return lycanroc_form(form, run['hour'])
    if species == 'SPECIES_MILCERY':
        return 0  # decision 50: Vanilla Cream Strawberry Sweet, whatever the Sweet and the time
    if run['class'] == EVO_CLASS_BY_ITEM and (species, run['param']) in item_forms:
        want = item_forms[(species, run['param'])][1]
    elif forms.kind(species, form) == 'SOVEREIGN_FORM_REGIONAL':
        want = regional.get((species, form, target), 0)
    else:
        want = form
    if species != 'SPECIES_DEERLING' and forms.personality_form(target, p) >= 0:
        want = forms.personality_form(target, p)
    return want


def main():
    from drive import Driver

    args = sys.argv[1:]
    verbose = '-v' in args
    if verbose:
        args.remove('-v')
    part, parts = 0, 1
    if '--part' in args:
        at = args.index('--part')
        part, parts = map(int, args[at + 1].split('/'))
        del args[at:at + 2]
    rom, state, out = args[:3]
    only = set(args[3:])
    os.makedirs(out, exist_ok=True)
    species_ids, items, moves = consts('species.txt'), consts('items.txt'), consts('moves.txt')
    methods = consts('evolution_methods.txt')
    sym = symbols(('gSovereignTestLead', 'gSovereignTestWild', 'gSovereignTestPartner', 'gSovereignTestEvolve',
                   'gSovereignTestClock', 'gSovereignTestLeadFormAfter', 'gSovereignTestFoeSurvivesTurns',
                   'gSovereignTestGodMode', 'gSovereignTestIdleFrames', 'gSystem'))
    chosen = [(i, c) for i, c in enumerate(cases(Forms(), verbose))
              if (not only or c['species'] in only) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory

    def u16(addr):
        return struct.unpack('<H', bytes(mem.unsigned[addr:addr + 2]))[0]

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, c in chosen:
            d.load_state(state)
            mem.write_byte(sym['gSovereignTestClock'] + CLOCK['hour'], c['hour'] + 1 if c['hour'] else 0)
            mem.write_byte(sym['gSovereignTestClock'] + CLOCK['month'], c['month'])
            d.run(30)  # the game reads the clock every 10 frames (rtc.c)
            lead, wild, evolve = sym['gSovereignTestLead'], sym['gSovereignTestWild'], sym['gSovereignTestEvolve']
            mem.write_short(lead + LEAD['species'], species_ids.index(c['species']))
            mem.write_byte(lead + LEAD['form'], c['form'])
            mem.write_byte(lead + LEAD['level'], c['level'])
            mem.write_short(lead + LEAD['item'], items.index(c['item']))
            if c['move']:
                mem.write_short(lead + LEAD['moves'] + 6, moves.index(c['move']))  # its fourth move
            mem.write_byte(lead + LEAD_EXTRA['friendship'], 255)
            mem.write_short(lead + LEAD_EXTRA['personality'], c['personality'] & 0xFFFF)
            mem.write_short(lead + LEAD_EXTRA['personality'] + 2, c['personality'] >> 16)
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

            target = species_ids[u16(evolve + EVOLVE['target'])]
            species, form = species_ids[u16(evolve + EVOLVE['species'])], mem.unsigned[evolve + EVOLVE['form']]
            after = mem.unsigned[sym['gSovereignTestLeadFormAfter']]
            problems = []
            if c['target'] == 'SPECIES_NONE':
                want = ('SPECIES_NONE', c['species'], c['form'])  # it stays as it is
            else:
                want = (c['target'], c['target'], c['want'])
            if (target, species, form) != want:
                problems.append(f'became {species} form {form} (target {target}), want {want[1]} form {want[2]}')
                result = 'EVOLVE' if result == 'ok' else result + '+EVOLVE'
            elif c['names_want'] is not None and c['names_want'] != form:
                problems.append(f'the forms\' names give form {c["names_want"]}')
                result = 'NAMES' if result == 'ok' else result + '+NAMES'
            elif after != form:
                problems.append(f'form after the battle {after}, want {form}')
                result = 'FORM' if result == 'ok' else result + '+FORM'
            if result != 'ok':
                d.screenshot().save(os.path.join(out, f'{index:03d}_{c["species"]}_{result}.png'))
                bad += 1
            line = f'{index} {c["label"]} personality {c["personality"]:08x} -> ' \
                f'{"no evolution" if c["want"] is None else "form " + str(c["want"])}: {result} {frames}' + \
                (' | ' + '; '.join(problems) if problems else '')
            print(line, file=f, flush=True)
            print(line, flush=True)
    print(f'{len(chosen) - bad} of {len(chosen)} ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
