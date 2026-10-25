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
  - Disguise and Ice Face hit by the foe's Tackle;
  - Stance Change attacking;
  - Schooling, Tera Shift and Fairy Aura as it comes in;
  - Hunger Switch at the end of a turn;
  - Battle Bond knocking the foe out.

  Zero to Hero needs a switch and isn't covered.
- **Item forms** (SOVEREIGN_FORM_BATTLE_ITEM): Crowned Zacian and Zamazenta, holding the Rusted Sword or Shield.
- **Move forms** (SOVEREIGN_FORM_BATTLE_MOVE): Pirouette Meloetta, using Relic Song.

For each one this loads a save state in the overworld, where the test build has given the Mega Ring. It writes the
Pokémon to gSovereignTestLead (include/sovereign_test.h), so the party's lead becomes it at Lv. 50, at the HP and with
the moves the case needs, with the MEGA toggle on for every move. The foe is a wild Chansey (Lv. 30) that knows only
Tackle (gSovereignTestWild), and it can't faint in the first turn (gSovereignTestFoeSurvivesTurns), so the lead's
turn-end abilities act and the foe gets to hit it. Then it presses SELECT for the wild battle. God mode is on and the
battle is played as in battle_all_trainers.py.

Afterwards it reads two test-build hooks:
- gSovereignTestPlayerBattleForm, the first form a battle form change gave the player's side. It must be the case's
  form (for a "no Mega" case, none of the species' Megas).
- gSovereignTestLeadFormAfter, the lead's form once the battle is over. It must be the one it started in.

Each one gets a result: ok, FORM (the wrong form in battle or after it, as the line says), HANG or STUCK (as in
battle_all_trainers.py), with a screenshot for any that isn't ok.

Needs what battle_all_trainers.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_form_changes.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [SPECIES ...]
SPECIES (a constant, e.g. SPECIES_MEOWSTIC) limits the list to those species. The whole list takes about 25 minutes.
Each result is a line in OUT_DIR/results.txt.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_species import sovereign_forms  # noqa: E402
from battle_all_trainers import DECOMP, fight, symbols  # noqa: E402
from check_trainer_party import consts, species_data  # noqa: E402

LEVEL = 50
FRAME_LIMIT = 6400
FOE = ('SPECIES_CHANSEY', 30, 'MOVE_TACKLE')
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


def battle_form_bases():
    """{(species, battle form): the form it comes from} for battle forms that don't come from form 0."""
    table = open(os.path.join(DECOMP, 'include', 'data', 'sovereign_forms.h')).read()
    table = table[table.index('sSovereignBattleFormBases['):]
    return {(s, int(f)): int(b) for s, f, b in re.findall(r'\{ (SPECIES_\w+), (\d+), (\d+) \}',
                                                           table[:table.index('};')])}


def case(species, form, want, label, item='ITEM_NONE', moves=(), hp=0):
    """A case as a dict; the lead gets its hidden ability when the ability the case needs is only that."""
    return {'species': species, 'form': form, 'want': want, 'label': label, 'item': item,
            'moves': list(moves) + ['MOVE_NONE'] * (4 - len(moves)), 'hp': hp, 'hidden': 0}


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
    return out


def main():
    from drive import Driver

    rom, state, out = sys.argv[1:4]
    only = set(sys.argv[4:])
    os.makedirs(out, exist_ok=True)
    species_ids, items, moves = consts('species.txt'), consts('items.txt'), consts('moves.txt')
    sym = symbols(('gSovereignTestLead', 'gSovereignTestWild', 'gSovereignTestPlayerBattleForm',
                   'gSovereignTestLeadFormAfter', 'gSovereignTestFoeSurvivesTurns', 'gSovereignTestGodMode',
                   'gSovereignTestIdleFrames', 'gSystem'))
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
                mem.write_short(lead + LEAD['moves'] + 2 * slot, moves.index(move))
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
            d.press('SELECT')
            result, frames = fight(d, sym, FRAME_LIMIT)

            got = mem.unsigned[sym['gSovereignTestPlayerBattleForm']]
            after = mem.unsigned[sym['gSovereignTestLeadFormAfter']]
            want = c['want']
            problems = []
            if (got != want) if want else (got in megas[c['species']]):
                problems.append(f'battle form {got}, want {want or "none of " + str(sorted(megas[c["species"]]))}')
            if after != c['form']:
                problems.append(f'form after the battle {after}, want {c["form"]}')
            if problems:
                result = 'FORM' if result == 'ok' else result + '+FORM'
            if result != 'ok':
                d.screenshot().save(os.path.join(out, f'{index:03d}_{c["species"]}_{c["form"]}_{result}.png'))
                bad += 1
            setup = ' '.join(x for x in (c['item'] if c['item'] != 'ITEM_NONE' else '',
                                         ','.join(m for m in c['moves'] if m != 'MOVE_NONE'),
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
