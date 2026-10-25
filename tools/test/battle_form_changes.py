#!/usr/bin/env python3
"""Make every Pokémon that changes form in battle do so from the player's side in the test build: each Mega, Primal
and Ultra Burst, and each form an ability, a held item or a move gives in battle. Check too that a form with no Mega of
its own can't Mega Evolve.

The list comes from include/data/sovereign_forms.h. Each case is the species in the form the change comes from
(sSovereignBattleFormBases, else its base form), with:
- **Mega:** the form's stone; Mega Rayquaza knows Dragon Ascent and holds nothing.
- **Primal:** Kyogre or Groudon with its Orb (it reverts as it comes in, with no button).
- **Ultra Burst:** Dusk Mane or Dawn Wings Necrozma with the Ultranecrozium Z.
- **no Mega:** each other form of a species with a Mega (a regional form, a Floette's flower color, 10% Zygarde...),
  holding each of that species' stones. It must not Mega Evolve, though it may take another battle form (Battle Bond
  Greninja becomes Ash-Greninja when it knocks the foe out).
- **Ability forms** (SOVEREIGN_FORM_BATTLE), each set up so its ability acts:
  - Zen Mode, Shields Down and Power Construct at 40% HP;
  - Gulp Missile using Surf, at full HP (Gulping) or 40% (Gorging);
  - Disguise and Ice Face hit by the foe's Bullet Punch;
  - Stance Change attacking;
  - Schooling, Tera Shift and Fairy Aura as it comes in;
  - Hunger Switch at the end of a turn;
  - Battle Bond knocking the foe out.

  Zero to Hero needs a switch and isn't covered.
- **Item forms** (SOVEREIGN_FORM_BATTLE_ITEM): Crowned Zacian and Zamazenta, holding the Rusted Sword or Shield.
- **Move forms** (SOVEREIGN_FORM_BATTLE_MOVE): Pirouette Meloetta, using Relic Song.
- **Key items** (SOVEREIGN_FORM_KEY_ITEM, SOVEREIGN_FORM_FUSION; src/sovereign_form_items.c), used on the lead before
  the battle (gSovereignTestItemUse) as from the bag:
  - the Reveal Glass, Prison Bottle and Zygarde Cube, from each form to the next;
  - each fusion (DNA Splicers, N-Solarizer, N-Lunarizer, Reins of Unity), with its partner second in the party,
    used again after the battle to separate them;
  - each nectar on an Oricorio in another style, and one on an Oricorio already in its style;
  - the Reveal Glass on a Pokémon with no Therian Forme, and the DNA Splicers on a Kyurem with no partner.

  Each use must do what it should: change the form or not, take the partner out of the party and give it back, and
  change the moves a form brings (Kyurem's Glaciate and Scary Face, Hoopa's Hyperspace Hole, the fusions' signature
  moves). The form it gives lasts through the battle.
- **Held-item forms**, given the item as the party menu gives one (Pokemon_SetArceusForm,
  Pokemon_SetGiratinaFormByHeldItem): Ogerpon's masks, Origin Dialga and Palkia (SOVEREIGN_FORM_HELD_ITEM), Arceus with
  each Plate, Silvally with each Memory, Genesect with each Drive, and Giratina with the Griseous Orb or Core; and
  Arceus with an item that isn't a Plate. The form lasts through the battle.

For each one this loads a save state in the overworld, where the test build has given the Mega Ring. It writes the
Pokémon to gSovereignTestLead (include/sovereign_test.h), so the party's lead becomes it at Lv. 50, at the HP and with
the moves the case needs, with the MEGA toggle on for every move. The foe is a wild Chansey (Lv. 30) that knows only
Bullet Punch (gSovereignTestWild), and it can't faint in the first turn (gSovereignTestFoeSurvivesTurns), so the lead's
turn-end abilities act and the foe gets to hit it. Then it presses SELECT for the wild battle. God mode is on and the
battle is played as in battle_all_trainers.py.

Afterwards it reads two test-build hooks:
- gSovereignTestPlayerBattleForm, the first form a battle form change gave the player's side. It must be the case's
  form (for a "no Mega" case, none of the species' Megas).
- gSovereignTestLeadFormAfter, the lead's form once the battle is over. It must be the one it started in.

Each one gets a result: ok, FORM (the wrong form in battle or after it, or a key item doing the wrong thing, as the line
says), HANG or STUCK (as in battle_all_trainers.py), with a screenshot for any that isn't ok.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_form_changes.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [SPECIES ...]
SPECIES (a constant, e.g. SPECIES_MEOWSTIC) limits the list to those species. The whole list (210 cases) takes about
an hour.
Each result is a line in OUT_DIR/results.txt.
"""
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_species import sovereign_forms  # noqa: E402
from battle_all_trainers import DECOMP, fight, symbols  # noqa: E402
from check_trainer_party import consts, species_data  # noqa: E402

LEVEL = 50
FRAME_LIMIT = 6400
FOE = ('SPECIES_CHANSEY', 30, 'MOVE_BULLET_PUNCH')  # physical, first to move, and no type is immune to Steel
# struct SovereignTestLead: u16 species, u8 form, u8 level, u16 item, u16 moves[4], u8 mega, u8 hpPercent,
# u8 hiddenAbility
LEAD = {'species': 0, 'form': 2, 'level': 3, 'item': 4, 'moves': 6, 'mega': 14, 'hp': 15, 'hidden': 16}
MEGA_KINDS = ('SOVEREIGN_FORM_MEGA', 'SOVEREIGN_FORM_PRIMAL', 'SOVEREIGN_FORM_MEGA_BY_MOVE',
              'SOVEREIGN_FORM_ULTRA_BURST')
# Forms that are a battle's only (they go back when it ends), so no party Pokémon is in one.
BATTLE_KINDS = MEGA_KINDS + ('SOVEREIGN_FORM_BATTLE', 'SOVEREIGN_FORM_BATTLE_ITEM', 'SOVEREIGN_FORM_BATTLE_MOVE')
# What an ability form needs to happen: the lead's HP (percent) and its moves. None: not covered.
ABILITY_SETUP = {
    'ABILITY_ZEN_MODE': {'hp': 40},
    'ABILITY_SHIELDS_DOWN': {'hp': 40},
    'ABILITY_POWER_CONSTRUCT': {'hp': 40},
    'ABILITY_DISGUISE': {},
    'ABILITY_ICE_FACE': {},
    'ABILITY_STANCE_CHANGE': {},
    'ABILITY_SCHOOLING': {},
    'ABILITY_TERA_SHIFT': {},
    'ABILITY_FAIRY_AURA': {},
    'ABILITY_HUNGER_SWITCH': {},
    'ABILITY_BATTLE_BOND': {},
    'ABILITY_ZERO_TO_HERO': None,  # Palafin becomes a hero when it switches out
}
# Gulp Missile: Cramorant catches an Arrokuda (Gulping Form) above half its HP and a Pikachu (Gorging Form) at half
# or less.
GULP_MISSILE_HP = {1: 0, 2: 40}
NO_MOVE = 0xFFFF  # SOVEREIGN_TEST_NO_MOVE: an empty move slot for the lead
# enum SovereignFormItemResult
ITEM_NO_EFFECT, ITEM_CHANGED = 1, 3
# struct SovereignTestItemUse: u16 item, u8 times, u8 results[2], u8 forms[2], u8 partyCounts[2], u16 lastSpecies[2],
# u16 moves[2][4]
ITEM_USE = {'item': 0, 'times': 2, 'results': 3, 'forms': 5, 'counts': 7, 'last': 10, 'moves': 14}
NECTARS = ['ITEM_RED_NECTAR', 'ITEM_YELLOW_NECTAR', 'ITEM_PINK_NECTAR', 'ITEM_PURPLE_NECTAR']  # Oricorio forms 0-3
FAIRY_MOVES = ['MOVE_MOONBLAST', 'MOVE_DAZZLING_GLEAM', 'MOVE_PLAY_ROUGH', 'MOVE_DRAINING_KISS']


def battle_form_bases():
    """{(species, battle form): the form it comes from} for battle forms that don't come from form 0."""
    table = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_forms.h')).read()
    table = table[table.index('sSovereignBattleFormBases['):]
    return {(s, int(f)): int(b) for s, f, b in re.findall(r'\{ (SPECIES_\w+), (\d+), (\d+) \}',
                                                           table[:table.index('};')])}


def case(species, form, want, label, item='ITEM_NONE', moves=(), hp=0):
    """A case as a dict; the lead gets its hidden ability when the ability the case needs is only that."""
    return {'species': species, 'form': form, 'want': want, 'label': label, 'item': item,
            'moves': list(moves) + ['MOVE_NONE'] * (4 - len(moves)), 'hp': hp, 'hidden': 0, 'use': None}


def form_item_tables():
    """src/sovereign_form_items.c's sFormMoves [(species, form, base form's move, form's move)] and sFusionItems
    {partner species: item}."""
    source = open(os.path.join(DECOMP, 'src', 'sovereign_form_items.c')).read()
    moves = re.findall(r'\{ (SPECIES_\w+), (\d+), (MOVE_\w+), (MOVE_\w+) \}', source)
    fusions = {}
    for item, partners in re.findall(r'\{ (ITEM_\w+), \{ ([\w, ]+) \} \}', source):
        for partner in partners.split(', '):
            fusions[partner] = item
    return [(s, int(f), b, m) for s, f, b, m in moves], fusions


def change_moves(moves, form_moves, species, form, enter):
    """The lead's moves after it enters (or leaves) a form, as ChangeFormMoves (src/sovereign_form_items.c) does."""
    moves = list(moves)
    for row_species, row_form, base, form_move in form_moves:
        if (row_species, row_form) != (species, form):
            continue
        if base != 'MOVE_NONE':
            old, new = (base, form_move) if enter else (form_move, base)
            moves = [new if m == old else m for m in moves]
        elif enter:
            if form_move not in moves and 'MOVE_NONE' in moves:
                moves[moves.index('MOVE_NONE')] = form_move
        elif form_move in moves:
            if moves[1] == 'MOVE_NONE':  # its only move: it learns Confusion
                moves[moves.index(form_move)] = 'MOVE_CONFUSION'
            else:  # the slots after it move up (Pokemon_ClearMoveSlot)
                moves.remove(form_move)
                moves.append('MOVE_NONE')
    return moves


def item_case(species, form, item, label, form_moves, results, forms, partner=None, after=None):
    """A key item used on the lead (once, or twice for a fusion), with what each use must do."""
    moves = list(FAIRY_MOVES)
    rows = [r for r in form_moves if r[0] == species]
    for slot, base in zip((0, 3), dict.fromkeys(r[2] for r in rows if r[2] != 'MOVE_NONE')):
        moves[slot] = base  # the moves its forms change, where the harness's taps don't need them
    if any(r[2] == 'MOVE_NONE' for r in rows):
        moves[3] = 'MOVE_NONE'  # a free slot for the move a fusion teaches
    if form:
        moves = change_moves(moves, form_moves, species, form, True)
    want_moves = []
    current, start = moves, form
    for f in forms:
        if f != start:
            current = change_moves(current, form_moves, species, start, False) if start else current
            current = change_moves(current, form_moves, species, f, True) if f else current
        want_moves.append(current)
        start = f
    c = case(species, form, 0, label, moves=[m if m != 'MOVE_NONE' else NO_MOVE for m in moves])
    c['use'] = {'item': item, 'results': results, 'forms': forms, 'partner': partner, 'moves': want_moves}
    c['after'] = forms[0] if after is None else after
    return c


def held_item_cases():
    """Each item that gives its holder a form, and the form."""
    types = consts('pokemon_types.txt')
    items = consts('items.txt')
    plates = {'FIST': 'FIGHTING', 'SKY': 'FLYING', 'TOXIC': 'POISON', 'EARTH': 'GROUND', 'STONE': 'ROCK',
              'INSECT': 'BUG', 'SPOOKY': 'GHOST', 'IRON': 'STEEL', 'PIXIE': 'FAIRY', 'FLAME': 'FIRE', 'SPLASH': 'WATER',
              'MEADOW': 'GRASS', 'ZAP': 'ELECTRIC', 'MIND': 'PSYCHIC', 'ICICLE': 'ICE', 'DRACO': 'DRAGON',
              'DREAD': 'DARK'}  # Arceus's form is its Plate's type
    out = [case(species, 0, 0, 'held item', item=trigger) | {'after': form}
           for species, form, kind, trigger in sovereign_forms() if kind == 'SOVEREIGN_FORM_HELD_ITEM']
    for plate, type_name in plates.items():
        out.append(case('SPECIES_ARCEUS', 0, 0, 'Plate', item=f'ITEM_{plate}_PLATE')
                   | {'after': types.index('TYPE_' + type_name)})
    out.append(case('SPECIES_ARCEUS', 0, 0, 'not a Plate', item='ITEM_LEFTOVERS') | {'after': 0})
    for item in items:
        if item.endswith('_MEMORY'):
            out.append(case('SPECIES_SILVALLY', 0, 0, 'Memory', item=item)
                       | {'after': types.index('TYPE_' + item[5:-7])})
        elif item.endswith('_DRIVE'):
            out.append(case('SPECIES_GENESECT', 0, 0, 'Drive', item=item)
                       | {'after': items.index(item) - items.index('ITEM_DOUSE_DRIVE') + 1})
    for item in ('ITEM_GRISEOUS_ORB', 'ITEM_GRISEOUS_CORE'):
        out.append(case('SPECIES_GIRATINA', 0, 0, 'Griseous', item=item) | {'after': 1})
    return out


def key_item_cases():
    form_moves, fusions = form_item_tables()
    out, cycles = [], {}
    for species, form, kind, trigger in sovereign_forms():
        if kind == 'SOVEREIGN_FORM_KEY_ITEM':
            cycles.setdefault((species, trigger), []).append(form)
        elif kind == 'SOVEREIGN_FORM_FUSION':
            out.append(item_case(species, 0, fusions[trigger], f'fusion with {trigger[8:].title()}', form_moves,
                                 [ITEM_CHANGED] * 2, [form, 0], partner=trigger))
    for (species, item), forms in cycles.items():
        order = [0] + forms
        for i, start in enumerate(order):
            out.append(item_case(species, start, item, 'key item', form_moves, [ITEM_CHANGED],
                                 [order[(i + 1) % len(order)]]))
    for form, nectar in enumerate(NECTARS):
        out.append(item_case('SPECIES_ORICORIO', (form + 1) % 4, nectar, 'nectar', form_moves, [ITEM_CHANGED], [form]))
    out.append(item_case('SPECIES_ORICORIO', 0, NECTARS[0], 'nectar, same style', form_moves, [ITEM_NO_EFFECT], [0]))
    out.append(item_case('SPECIES_GARCHOMP', 0, 'ITEM_REVEAL_GLASS', 'no Therian Forme', form_moves, [ITEM_NO_EFFECT],
                         [0]))
    out.append(item_case('SPECIES_KYUREM', 0, 'ITEM_DNA_SPLICERS', 'no partner', form_moves, [ITEM_NO_EFFECT], [0]))
    return out


def cases():
    forms = sovereign_forms()
    bases = battle_form_bases()
    out, stones = [], {}
    for species, form, kind, trigger in forms:
        base = bases.get((species, form), 0)
        if kind == 'SOVEREIGN_FORM_MEGA':
            out.append(case(species, base, form, 'Mega', item=trigger))
            stones.setdefault(species, {}).setdefault(trigger, set()).add(base)
        elif kind == 'SOVEREIGN_FORM_MEGA_BY_MOVE':
            out.append(case(species, 0, form, 'Mega by move', moves=['MOVE_NONE'] * 3 + [trigger]))
        elif kind == 'SOVEREIGN_FORM_PRIMAL':
            out.append(case(species, 0, form, 'Primal', item=trigger))
        elif kind == 'SOVEREIGN_FORM_ULTRA_BURST':
            out.append(case(species, int(trigger), form, 'Ultra Burst', item='ITEM_ULTRANECROZIUM_Z'))
        elif kind == 'SOVEREIGN_FORM_BATTLE_ITEM':
            out.append(case(species, base, form, 'item', item=trigger))
        elif kind == 'SOVEREIGN_FORM_BATTLE_MOVE':
            out.append(case(species, base, form, 'move', moves=[trigger] * 3))
        elif kind == 'SOVEREIGN_FORM_BATTLE' and trigger == 'ABILITY_GULP_MISSILE':
            out.append(case(species, base, form, trigger[8:].replace('_', ' ').title(), moves=['MOVE_SURF'] * 3,
                            hp=GULP_MISSILE_HP[form]))
        elif kind == 'SOVEREIGN_FORM_BATTLE' and ABILITY_SETUP.get(trigger) is not None:
            c = case(species, base, form, trigger[8:].replace('_', ' ').title(), **ABILITY_SETUP[trigger])
            abilities = species_data(species, base)['abilities']
            c['hidden'] = int(trigger not in abilities[:2])
            out.append(c)
    for species, form, kind, _ in forms:
        if species in stones and kind not in BATTLE_KINDS:
            for stone, from_forms in stones[species].items():
                if form not in from_forms:
                    out.append(case(species, form, 0, 'no Mega', item=stone))
    for species in stones:  # the base form, with a stone whose Mega comes from another form (Mega Floette)
        for stone, from_forms in stones[species].items():
            if 0 not in from_forms:
                out.append(case(species, 0, 0, 'no Mega', item=stone))
    return out + key_item_cases() + held_item_cases()


def u16(mem, addr):
    return struct.unpack('<H', bytes(mem.unsigned[addr:addr + 2]))[0]


def check_item_use(mem, base, use, species_ids, moves):
    """What the key item did (gSovereignTestItemUse), against what it should have."""
    problems = []
    party = 6  # the test party (src/script_manager.c)
    for i, (want_result, want_form, want_moves) in enumerate(zip(use['results'], use['forms'], use['moves'])):
        result = mem.unsigned[base + ITEM_USE['results'] + i]
        form = mem.unsigned[base + ITEM_USE['forms'] + i]
        count = mem.unsigned[base + ITEM_USE['counts'] + i]
        last = u16(mem, base + ITEM_USE['last'] + 2 * i)
        got_moves = [moves[u16(mem, base + ITEM_USE['moves'] + 8 * i + 2 * j)] for j in range(4)]
        if use['partner'] and want_result == ITEM_CHANGED:
            party += -1 if i == 0 else 1
        if (result, form) != (want_result, want_form):
            problems.append(f'use {i + 1}: result {result}, form {form}; want {want_result}, {want_form}')
        if count != party:
            problems.append(f'use {i + 1}: {count} in the party, want {party}')
        if use['partner'] and i == 1 and species_ids[last] != use['partner']:
            problems.append(f'use 2: {species_ids[last]} came back, want {use["partner"]}')
        if got_moves != want_moves:
            problems.append(f'use {i + 1}: moves {got_moves}, want {want_moves}')
    return problems


def main():
    from drive import Driver

    rom, state, out = sys.argv[1:4]
    only = set(sys.argv[4:])
    os.makedirs(out, exist_ok=True)
    species_ids, items, moves = consts('species.txt'), consts('items.txt'), consts('moves.txt')
    sym = symbols(('gSovereignTestLead', 'gSovereignTestWild', 'gSovereignTestPartner', 'gSovereignTestItemUse',
                   'gSovereignTestPlayerBattleForm', 'gSovereignTestLeadFormAfter', 'gSovereignTestFoeSurvivesTurns',
                   'gSovereignTestGodMode', 'gSovereignTestIdleFrames', 'gSystem'))
    megas = {}
    for species, form, kind, _ in sovereign_forms():
        if kind in MEGA_KINDS:
            megas.setdefault(species, set()).add(form)
    chosen = [(i, c) for i, c in enumerate(cases()) if not only or c['species'] in only]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory
    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, c in chosen:
            d.emu.savestate.load_file(state)
            d.run(30)
            lead, wild = sym['gSovereignTestLead'], sym['gSovereignTestWild']
            mem.write_short(lead + LEAD['species'], species_ids.index(c['species']))
            mem.write_byte(lead + LEAD['form'], c['form'])
            mem.write_byte(lead + LEAD['level'], LEVEL)
            mem.write_short(lead + LEAD['item'], items.index(c['item']))
            for slot, move in enumerate(c['moves']):
                mem.write_short(lead + LEAD['moves'] + 2 * slot, move if move == NO_MOVE else moves.index(move))
            mem.write_byte(lead + LEAD['mega'], 1)
            mem.write_byte(lead + LEAD['hp'], c['hp'])
            mem.write_byte(lead + LEAD['hidden'], c['hidden'])
            mem.write_short(wild, species_ids.index(FOE[0]))
            mem.write_byte(wild + 2, 0)
            mem.write_byte(wild + 3, FOE[1])
            mem.write_short(wild + 4, moves.index(FOE[2]))
            mem.write_byte(sym['gSovereignTestFoeSurvivesTurns'], 1)
            mem.write_byte(sym['gSovereignTestLeadFormAfter'], 0xFF)
            mem.write_byte(sym['gSovereignTestGodMode'], 1)
            use = c['use']
            if use:
                item_use = sym['gSovereignTestItemUse']
                mem.write_short(item_use + ITEM_USE['item'], items.index(use['item']))
                mem.write_byte(item_use + ITEM_USE['times'], len(use['results']))
                if use['partner']:
                    mem.write_short(sym['gSovereignTestPartner'], species_ids.index(use['partner']))
                    mem.write_byte(sym['gSovereignTestPartner'] + 3, LEVEL)
            d.press('SELECT')
            result, frames = fight(d, sym, FRAME_LIMIT)

            got = mem.unsigned[sym['gSovereignTestPlayerBattleForm']]
            after = mem.unsigned[sym['gSovereignTestLeadFormAfter']]
            want = c['want']
            problems = []
            species_megas = sorted(megas.get(c['species'], ()))
            if (got != want) if want else (got in species_megas):
                problems.append(f'battle form {got}, want {want or "none of " + str(species_megas)}')
            if after != c.get('after', c['form']):
                problems.append(f'form after the battle {after}, want {c.get("after", c["form"])}')
            if use:
                problems += check_item_use(mem, sym['gSovereignTestItemUse'], use, species_ids, moves)
            if problems:
                result = 'FORM' if result == 'ok' else result + '+FORM'
            if result != 'ok':
                d.screenshot().save(os.path.join(out, f'{index:03d}_{c["species"]}_{c["form"]}_{result}.png'))
                bad += 1
            setup = ' '.join(x for x in (c['item'] if c['item'] != 'ITEM_NONE' else '',
                                         use['item'] if use else '',
                                         ','.join(m for m in c['moves'] if m not in ('MOVE_NONE', NO_MOVE)),
                                         f'{c["hp"]}% HP' if c['hp'] else '',
                                         'hidden ability' if c['hidden'] else '') if x)
            line = f'{index} {c["species"]} {c["form"]} ({c["label"]}; {setup or "as it is"}) {result} {frames}' + \
                (' | ' + '; '.join(problems) if problems else '')
            print(line, file=f, flush=True)
            print(line, flush=True)
    print(f'{len(chosen) - bad} of {len(chosen)} ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
