#!/usr/bin/env python3
"""Breed every form of every species that can breed in the test build, hatch the Egg and check its species and form.

The cases, from every form but the battle forms (Mega, Primal, Zen Mode...) of a species outside the Undiscovered egg
group, and from each base form of a species with forms, whose baby has forms, or found only through a regional form
(Perrserker):
- the form as the mother, with a Ditto (when the species can be female);
- the form as the father, with a Ditto (when the species can be male or has no gender);
- for a regional form that passes on its region (Alolan Vulpix) of a species with both genders: a base-form mother with
  the regional father, whose form must not pass on;
- for a parent whose baby is an incense baby (Mr. Mime's Mime Jr.): with and without the incense.
A species with a female's form (Meowstic) is the mother only in that form and the father only in its base form.

For each case this loads a save state in the overworld and writes the two parents to gSovereignTestBreed
(include/sovereign_test.h): their species, form, gender and held item, and the Egg's personality. The game breeds
them in the Day Care as Daycare_GiveEggFromDaycare does, hatches the Egg at once and makes it the party's lead, and it
battles a wild Chansey as in battle_form_changes.py.

The Egg's species is its parent's baby (the female's, or the one that isn't Ditto; data.json's offspring), or the
evolved species for an incense baby with no incense held (sIncenseBabyTable, src/overlay005/daycare.c). Its form is
worked out as the game does it (Daycare_GiveEggFromDaycare, Pokemon_SovereignBabyForm):
- the form parent is the mother, or the father when the mother slot is a Ditto;
- a form parent in sSovereignBabyForms gives its baby's form (its region's, or 0);
- a form parent in any other Sovereign form (a Totem, a female's form, Low Key Toxtricity) gives 0;
- a Platinum form (Burmy's cloak, Shellos's sea) comes from the mother slot, as in Platinum;
- an Egg species whose form comes from its personality (the Flabébé line's colors, the Vivillon line's patterns)
  takes that one, and a Deerling the season (the test sets the clock to March: autumn).
The names cross-check it when the Egg is another species: a regional parent's Egg must be the baby's form of the same
name (Alolan Raichu: Pichu, with no Alolan form; Galarian Rapidash: Galarian Ponyta), or its base form.

Each case gets a result: ok, EGG (wrong Egg species or form), HATCH (the hatched Pokémon isn't the Egg's species and
form), NAMES (the form isn't the one the names give), FORM (its form changed in the battle; a Burmy takes the Trash
Cloak, as the test battles indoors), HANG or STUCK. Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_eggs.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [-v] [--part I/N] [SPECIES ...]
SPECIES (a constant) limits the list to the cases with a parent of those species, and --part I/N to every Nth case
from the Ith (from 0; to run N at once, each with its own OUT_DIR). Each result is a line in OUT_DIR/results.txt.
"""
import functools
import os
import random
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_species import entries  # noqa: E402
from battle_all_trainers import DECOMP, fight, symbols  # noqa: E402
from battle_evolutions import BATTLE_KINDS, CLOCK, GENDER_FEMALE, GENDER_MALE, Forms, data_of, qualifier  # noqa: E402
from battle_form_changes import FOE  # noqa: E402
from check_trainer_party import consts  # noqa: E402

FRAME_LIMIT = 6400
# struct SovereignTestBreed
BREED = {'species': 0, 'forms': 4, 'genders': 6, 'items': 8, 'personality': 12, 'breed': 16, 'egg_form': 17,
         'egg_species': 18, 'hatched_species': 20, 'hatched_form': 22}
MONTH = 3  # March: (3 - 1) % 4 = autumn for a Deerling
EGG_GENDER_MALE = 0x8000  # include/constants/daycare.h
DITTO = 'SPECIES_DITTO'
# BattleSystem_SetBurmyForm (as in Platinum): a Burmy takes the cloak of where it battled, the Trash Cloak indoors.
FORM_AFTER_BATTLE = {'SPECIES_BURMY': 2}


@functools.lru_cache(maxsize=None)
def baby_table():
    """sSovereignBabyForms {(species, form): (baby species, baby form)} from include/data/sovereign_forms.h."""
    text = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_forms.h')).read()
    text = text[text.index('sSovereignBabyForms[]'):]
    return {(s, int(f)): (b, int(bf)) for s, f, bf, b in
            re.findall(r'\{ (SPECIES_\w+), (\d+), (\d+), (SPECIES_\w+) \}', text[:text.index('};')])}


@functools.lru_cache(maxsize=None)
def incense_table():
    """sIncenseBabyTable {baby: (incense, the species without it)} from src/overlay005/daycare.c."""
    text = open(os.path.join(DECOMP, 'src', 'overlay005', 'daycare.c')).read()
    text = text[text.index('sIncenseBabyTable'):]
    return {b: (i, s) for b, i, s in
            re.findall(r'\{ (SPECIES_\w+), (ITEM_\w+), (SPECIES_\w+) \}', text[:text.index('};')])}


def egg_species(parents, personality):
    """Egg_DetermineEggSpeciesAndParentSlots and Daycare_AlterEggSpeciesWithIncenseItem."""
    parent = next(p for p in parents if p['species'] != DITTO and (p['gender'] == GENDER_FEMALE + 1
                                                                    or DITTO in (q['species'] for q in parents)))
    baby = data_of(parent['species'])['offspring']
    if baby == 'SPECIES_NIDORAN_F' and personality & EGG_GENDER_MALE:
        baby = 'SPECIES_NIDORAN_M'
    if baby == 'SPECIES_ILLUMISE' and personality & EGG_GENDER_MALE:
        baby = 'SPECIES_VOLBEAT'
    if baby == 'SPECIES_MANAPHY':
        baby = 'SPECIES_PHIONE'
    if baby in incense_table() and incense_table()[baby][0] not in (p['item'] for p in parents):
        baby = incense_table()[baby][1]
    return baby


def egg_form(forms, parents, egg, personality):
    """The Egg's form, as Daycare_GiveEggFromDaycare gives it."""
    mother = next((p for p in parents if p['gender'] == GENDER_FEMALE + 1), None)
    if mother is None or DITTO in (p['species'] for p in parents) and mother['species'] == DITTO:
        mother = next(p for p in parents if p['species'] == DITTO)  # Ditto takes the mother's slot from a male
    form_parent = mother if mother['species'] != DITTO else next(p for p in parents if p['species'] != DITTO)
    key = (form_parent['species'], form_parent['form'])
    if key in baby_table():
        baby, baby_form = baby_table()[key]
        form = baby_form if egg == baby else form_parent['form'] if egg == form_parent['species'] else 0
    elif forms.kind(*key) is not None:
        form = 0
    else:
        form = mother['form'] if mother['species'] != DITTO else 0
    if egg == 'SPECIES_DEERLING':
        return (MONTH - 1) % 4
    own = forms.personality_form(egg, personality)
    return own if own >= 0 else form


def names_form(forms, form_parent, egg, forms_of):
    """The Egg's form the names give, or None when they don't say."""
    if form_parent['species'] == egg or forms.kind(form_parent['species'], form_parent['form']) in (
            'SOVEREIGN_FORM_GENDER', None) or forms.forms_of(egg):
        return None
    q = qualifier(form_parent['species'], form_parent['form'])
    if q is None:
        return None
    q = ' '.join(w for w in q.split() if w != 'totem')
    return next((f for f in forms_of.get(egg, []) if qualifier(egg, f) == q), 0)


def breeds(species, form, kind):
    data = data_of(species, form) if kind == 'SOVEREIGN_FORM_REGIONAL' else data_of(species)
    return 'EGG_GROUP_UNDISCOVERED' not in data['egg_groups'] and species != DITTO


def cases(forms, verbose=False):
    rng = random.Random(1)
    all_forms = entries()
    kinds = {(s, f): kind for s, f, kind, _ in forms.table}
    has_forms = {s for s, f in all_forms if f}
    forms_of = {}
    for s, f in all_forms:
        forms_of.setdefault(s, []).append(f)
    out, skipped = [], []

    def parent(species, form, gender, item='ITEM_NONE'):
        return {'species': species, 'form': form, 'gender': gender, 'item': item}

    for species, form in all_forms:
        kind = kinds.get((species, form))
        if kind in BATTLE_KINDS:
            continue
        baby = data_of(species)['offspring']
        incense_species = incense_table().get(baby, (None, None))[1]
        if not form and species not in has_forms and baby not in has_forms and incense_species not in has_forms \
                and (species, 0) not in baby_table():
            continue
        if not breeds(species, form, kind):
            skipped.append(f'{species} {form}: Undiscovered egg group')
            continue
        ratio = forms.ratio(species)
        gender_form = forms.kinds(species)[0]
        pairs = []
        if ratio not in (0, 255) and (gender_form is None or form == gender_form):
            pairs.append(('mother', [parent(species, form, GENDER_FEMALE + 1), parent(DITTO, 0, 0)]))
        if ratio != 254 and (gender_form is None or form == 0):
            pairs.append(('father', [parent(species, form, GENDER_MALE + 1 if ratio != 255 else 0),
                                     parent(DITTO, 0, 0)]))
        passes_on = form and baby_table().get((species, form), (None, 0))[1]
        if passes_on and ratio not in (0, 254, 255) and gender_form is None:
            pairs.append(('father, base mother', [parent(species, 0, GENDER_FEMALE + 1),
                                                  parent(species, form, GENDER_MALE + 1)]))
        if baby in incense_table():
            pairs += [(f'{role}, {incense_table()[baby][0]}',
                       [dict(ps[0], item=incense_table()[baby][0]), ps[1]]) for role, ps in list(pairs)]
        for role, parents in pairs:
            p = rng.getrandbits(32) or 1
            egg = egg_species(parents, p)
            want = egg_form(forms, parents, egg, p)
            form_parent = next(q for q in parents if q['species'] == species and q['form'] == form)
            if role.startswith('father, base'):
                form_parent = parents[0]
            out.append({'label': f'{species} {form} as the {role}', 'parents': parents, 'personality': p,
                        'egg': egg, 'want': want, 'names_want': names_form(forms, form_parent, egg, forms_of),
                        'species': species})
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
    part, parts = 0, 1
    if '--part' in args:
        at = args.index('--part')
        part, parts = map(int, args[at + 1].split('/'))
        del args[at:at + 2]
    rom, state, out = args[:3]
    only = set(args[3:])
    os.makedirs(out, exist_ok=True)
    species_ids, items, moves = consts('species.txt'), consts('items.txt'), consts('moves.txt')
    sym = symbols(('gSovereignTestBreed', 'gSovereignTestWild', 'gSovereignTestClock', 'gSovereignTestLeadFormAfter',
                   'gSovereignTestFoeSurvivesTurns', 'gSovereignTestGodMode', 'gSovereignTestIdleFrames', 'gSystem'))
    chosen = [(i, c) for i, c in enumerate(cases(Forms(), verbose))
              if (not only or only & {p['species'] for p in c['parents']}) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory

    def u16(addr):
        return struct.unpack('<H', bytes(mem.unsigned[addr:addr + 2]))[0]

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, c in chosen:
            d.load_state(state)
            mem.write_byte(sym['gSovereignTestClock'] + CLOCK['month'], MONTH)
            d.run(30)  # the game reads the clock every 10 frames (rtc.c)
            breed, wild = sym['gSovereignTestBreed'], sym['gSovereignTestWild']
            for i, p in enumerate(c['parents']):
                mem.write_short(breed + BREED['species'] + 2 * i, species_ids.index(p['species']))
                mem.write_byte(breed + BREED['forms'] + i, p['form'])
                mem.write_byte(breed + BREED['genders'] + i, p['gender'])
                mem.write_short(breed + BREED['items'] + 2 * i, items.index(p['item']))
            mem.write_short(breed + BREED['personality'], c['personality'] & 0xFFFF)
            mem.write_short(breed + BREED['personality'] + 2, c['personality'] >> 16)
            mem.write_byte(breed + BREED['breed'], 1)
            mem.write_short(wild, species_ids.index(FOE[0]))
            mem.write_byte(wild + 3, FOE[1])
            mem.write_short(wild + 4, moves.index(FOE[2]))
            mem.write_byte(sym['gSovereignTestLeadFormAfter'], 0xFF)
            mem.write_byte(sym['gSovereignTestGodMode'], 1)
            d.press('SELECT')
            result, frames = fight(d, sym, FRAME_LIMIT)

            egg, form = species_ids[u16(breed + BREED['egg_species'])], mem.unsigned[breed + BREED['egg_form']]
            hatched = species_ids[u16(breed + BREED['hatched_species'])], mem.unsigned[breed + BREED['hatched_form']]
            after = mem.unsigned[sym['gSovereignTestLeadFormAfter']]
            problems = []
            if (egg, form) != (c['egg'], c['want']):
                problems.append(f'Egg {egg} form {form}, want {c["egg"]} form {c["want"]}')
                result = 'EGG' if result == 'ok' else result + '+EGG'
            elif hatched != (egg, form):
                problems.append(f'hatched {hatched[0]} form {hatched[1]}')
                result = 'HATCH' if result == 'ok' else result + '+HATCH'
            elif c['names_want'] is not None and c['names_want'] != form:
                problems.append(f'the forms\' names give form {c["names_want"]}')
                result = 'NAMES' if result == 'ok' else result + '+NAMES'
            elif after != FORM_AFTER_BATTLE.get(egg, form):
                problems.append(f'form after the battle {after}, want {FORM_AFTER_BATTLE.get(egg, form)}')
                result = 'FORM' if result == 'ok' else result + '+FORM'
            if result != 'ok':
                d.screenshot().save(os.path.join(out, f'{index:03d}_{c["species"]}_{result}.png'))
                bad += 1
            line = f'{index} {c["label"]} personality {c["personality"]:08x} -> {c["egg"]} form {c["want"]}: ' \
                f'{result} {frames}' + (' | ' + '; '.join(problems) if problems else '')
            print(line, file=f, flush=True)
            print(line, flush=True)
    print(f'{len(chosen) - bad} of {len(chosen)} ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
