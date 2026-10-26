#!/usr/bin/env python3
"""Receive every Pokémon gift Sovereign added, in the test build, and check what arrives in the party.

The gifts:
- the event-gift deliveryman in the Fight Area Pokémon Center: each event form of his list (sSovereignEventGifts,
  src/scrcmd.c) that is a gift, in its form and at its level, knowing its form's level-up moves with its signature move
  last; and his Mythicals' entries, which restyle a Magearna or Zarude shown to him into its event form;
- the Ace Trainer there: Battle Bond Greninja, Lv. 50, with Water Shuriken, Aerial Ace, Double Team and Night Slash;
- the eight Pokémon Center Interviewers: the quiz (its right answers read from the script) and the battle against
  the region's starters, then, talking again, the prize: the three starters at the gift level, each with its
  type's held item (docs/GiftPokemon_Sovereign.md). The player has all eight badges (gSovereignTestBadges), as the
  later Interviewers wait on one;
- the other gifts Sovereign added: Lapras, Steven's Beldum, Porygon, the Twinleaf Eevee (Mom's state set to after the
  Journal) and Rowan's briefcase (the two starters the player didn't pick; Rowan back in his lab);
- the Mining Museum's Paradox dealers (all eight badges): each pair of their list (sParadoxForms), the Paradox
  Pokémon of a present-day one shown to them, at its level;
- the Trainers' School Cowgirl's Egg: one of the 18 babies her script picks from at random, an Egg at Lv. 1 knowing
  its species' moves at that level.
For a gift that needs a Pokémon shown, the next test warp adds it to the party (gSovereignTestPartyAdd, Lv. 50), and
the script's party screen is answered like its other menus.

Each gift is a run from the save state: the party is cut to its lead to make room (gSovereignTestPartyKeep), the
player comes in by the map's way in and warps next to the giver (talk_to_objects.arrive), and talks, as many times as
the gift takes. Each script plays out on the real menus: when it waits on one (gSovereignTestMenu), the test moves the
cursor down to the entry it wants and presses A, or answers a yes/no question (no nickname); A pages through the text
and fights a battle otherwise (god mode). Then the party's last Pokémon (gSovereignTestParty) must be the gifts: each
one's species, form, level, an ability of its form's (not its Hidden Ability), held item and moves (its form's
level-up moves at its level, unless the gift sets them), and whether it's an Egg.

Needs what talk_to_objects.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/gift_pokemon.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR
"""
import collections
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_trainers import HANG_FRAMES, SWITCH_FRAMES, TAPS, VBLANK_COUNTER, heap_info  # noqa: E402
from battle_evolutions import data_of  # noqa: E402
from heap_check import heap_problems  # noqa: E402
from talk_to_objects import (DECOMP, FRAME_LIMIT, START_FRAMES, SYMBOLS, arrive, cases as talk_cases,  # noqa: E402
                             parse_args, symbols, u32, var_ids)

EVENTS = 'events_fight_area_pokecenter_1f'
DELIVERYMAN = 'LOCALID_FIGHT_AREA_SOVEREIGN_EVENT_DELIVERYMAN'
GRENINJA_TRAINER = 'LOCALID_FIGHT_AREA_SOVEREIGN_GRENINJA_TRAINER'
MENU_LIST, MENU_YES_NO, MENU_PARTY = 1, 2, 3  # enum SovereignTestMenuKind
PARTY = {'wanted': 0, 'count': 1, 'mons': 4}  # struct SovereignTestParty
# struct SovereignTestPartyMon: species, ability, held item, moves, form, level, hasHiddenAbility, isEgg.
MON = '<HHH4HBBBB'
ALL_BADGES = 0xff
STEP = 10
MENU_SETTLE = 10
PARTY_SETTLE = 90  # the party screen fades in
SHOWN_LEVEL = 50  # the level of a Pokémon shown to a dealer


def names(kind):
    return [line.strip() for line in open(os.path.join(DECOMP, 'generated', kind + '.txt')) if line.strip()]


def event_gifts():
    """sSovereignEventGifts: [(species, form, level, signature move)], in the deliveryman's list order."""
    source = open(os.path.join(DECOMP, 'src', 'scrcmd.c'), encoding='utf-8').read()
    table = re.search(r'sSovereignEventGifts\[\]\[4\] = \{(.*?)\n\};', source, re.S).group(1)
    return [(s, int(f), int(lv), m) for s, f, lv, m in
            re.findall(r'\{ (SPECIES_\w+), (\d+), (\d+), (MOVE_\w+) \}', table)]


def default_moves(species, form, level):
    """The moves a Pokémon of this form knows at this level (Pokemon_SovereignSetDefaultMoves): its level-up moves up
    to the level, in order, the oldest dropped once it knows four."""
    known = []
    for at, move in data_of(species, form)['learnset']['by_level']:
        if at <= level and move not in known:
            known = (known + [move])[-4:]
    return known + ['MOVE_NONE'] * (4 - len(known))


def interviewers():
    """[(events, the Interviewer's object, [quiz answers], [(species, level, held item)])] from the Pokémon Center
    scripts: each yes/no question's right answer (the one that doesn't go to ...Wrong or ...Declined), and the
    prize's GivePokemon lines."""
    out = []
    folder = os.path.join(DECOMP, 'res', 'field', 'scripts')
    for name in sorted(os.listdir(folder)):
        text = open(os.path.join(folder, name), encoding='utf-8').read()
        quiz = re.search(r'^(\w+)_SovereignInterviewer:\n(.*?)StartTrainerBattle', text, re.M | re.S)
        if not quiz:
            continue
        answers = []
        for check in re.findall(r'ShowYesNoMenu VAR_RESULT\n(\s*\S.*)', quiz.group(2)):
            ne = re.match(r'\s*GoToIfNe VAR_RESULT, MENU_(YES|NO), \w+_SovereignInterviewerWrong', check)
            answers.append(ne.group(1) == 'YES' if ne else True)  # no check (the last question) or Declined: yes
        prize = re.search(r'^\w+_SovereignInterviewerPrize:\n(.*?)\n\s*End\b', text, re.M | re.S).group(1)
        gifts = [(sp, int(lv), it) for sp, lv, it in
                 re.findall(r'GivePokemon (SPECIES_\w+), (\d+), (ITEM_\w+), VAR_RESULT', prize)]
        local = re.search(r'RemoveObject (LOCALID_\w+_SOVEREIGN_INTERVIEWER)\b', text).group(1)
        out.append(('events_' + name[len('scripts_'):-2], local, answers, gifts))
    return out


Gift = collections.namedtuple('Gift', 'name events giver badges var talks gifts add', defaults=[None])
# Gifts given straight away, with no list to read them from: (name, events, giver, story var set first, the answers
# of each talk, [(species, level, held item)]). Their moves are their level-up moves.
SIMPLE = [
    ('Lapras', 'events_pastoria_city_north_house', 'LOCALID_SOVEREIGN_SOCIALITE', None, [[True, True, False]],
     [('SPECIES_LAPRAS', 35, 'ITEM_NEVERMELTICE')]),
    ("Steven's Beldum", 'events_oreburgh_city_south_house', 'LOCALID_STEVEN', None, [[True, False]],
     [('SPECIES_BELDUM', 10, 'ITEM_NONE')]),
    ('Porygon', 'events_team_galactic_eterna_building_4f', 'LOCALID_SOVEREIGN_PORYGON_BALL', None, [[True, False]],
     [('SPECIES_PORYGON', 22, 'ITEM_NONE')]),
    # Mom suggests it once she has given the Journal.
    ('Twinleaf Eevee', 'events_twinleaf_town_player_house_1f', 'LOCALID_SOVEREIGN_EEVEE_BALL',
     ('VAR_PLAYER_HOUSE_STATE', 6), [[True, False]], [('SPECIES_EEVEE', 5, 'ITEM_NONE')]),
    # Later in the story: Rowan is back in his lab (VAR_SANDGEM_TOWN_LAB_STATE 3: placed on entering, with no scene).
    # The test save's starter is Turtwig, so he gives the other two.
    ("Rowan's briefcase", 'events_sandgem_town_pokemon_research_lab', 'LOCALID_SOVEREIGN_BRIEFCASE',
     ('VAR_SANDGEM_TOWN_LAB_STATE', 3), [[True, False, False]],
     [('SPECIES_CHIMCHAR', 5, 'ITEM_NONE'), ('SPECIES_PIPLUP', 5, 'ITEM_NONE')]),
]


def school_egg():
    """The species the Trainers' School Cowgirl's Egg can be: those her script picks from at random."""
    script = open(os.path.join(DECOMP, 'res', 'field', 'scripts', 'scripts_trainers_school.s'), encoding='utf-8').read()
    body = re.search(r'^TrainersSchool_SovereignCowgirl:\n(.*?)^TrainersSchool_SovereignGiveEgg:', script, re.M | re.S)
    return tuple(re.findall(r'SetVar VAR_0x8004, (SPECIES_\w+)', body.group(1)))


def paradox_dealers():
    """[(era, dealer, present species, Paradox species)] from sParadoxForms (src/scrcmd.c): the Mining Museum's fossil
    maniac gives the ancient ones, the futuristic scientist the future ones."""
    source = open(os.path.join(DECOMP, 'src', 'scrcmd.c'), encoding='utf-8').read()
    table = re.search(r'sParadoxForms\[\w+\]\[\w+ \+ 1\]\[2\] = \{(.*?)\n\};', source, re.S).group(1)
    dealers = ('LOCALID_SOVEREIGN_FOSSIL_MANIAC', 'LOCALID_SOVEREIGN_FUTURE_SCIENTIST')
    return [(era, dealers[era], present, paradox)
            for era, block in enumerate(re.findall(r'\{\n(.*?)\n    \}', table, re.S))
            for present, paradox in re.findall(r'\{ (SPECIES_\w+), (SPECIES_\w+) \}', block)
            if present != 'SPECIES_NONE']


def cases():
    """[Gift]: the gifts the party's last slots must hold, each (species, form, level, held item, moves), in order."""
    out = []
    for index, (species, form, level, move) in enumerate(event_gifts()):
        if level == 0:  # a Mythical's event form: he restyles one the player caught instead
            continue
        moves = default_moves(species, form, level)
        if move != 'MOVE_NONE':
            moves[3] = move
        out.append(Gift(f'event gift {index}', EVENTS, DELIVERYMAN, 0, None, [[index, False]],
                        [(species, form, level, 'ITEM_NONE', moves)]))
    out.append(Gift('Battle Bond Greninja', EVENTS, GRENINJA_TRAINER, 0, None, [[True, False]],
                    [('SPECIES_GRENINJA', 1, 50, 'ITEM_NONE',
                      ['MOVE_WATER_SHURIKEN', 'MOVE_AERIAL_ACE', 'MOVE_DOUBLE_TEAM', 'MOVE_NIGHT_SLASH'])]))
    for events, local, answers, gifts in interviewers():
        out.append(Gift(f'Interviewer {events[len("events_"):-len("_pokecenter_1f")]}', events, local, ALL_BADGES,
                        None, [answers, [False] * len(gifts)],
                        [(sp, 0, lv, it, default_moves(sp, 0, lv)) for sp, lv, it in gifts]))
    for index, (species, form, level, move) in enumerate(event_gifts()):
        if level == 0:  # the deliveryman restyles a party Pokémon of a Mythical's into its event form
            out.append(Gift(f'event restyle {index}', EVENTS, DELIVERYMAN, 0, None, [[index, ('party', 1)]],
                            [(species, form, SHOWN_LEVEL, 'ITEM_NONE', default_moves(species, 0, SHOWN_LEVEL))],
                            add=(species, 0, SHOWN_LEVEL)))
    for era, giver, present, paradox in paradox_dealers():
        out.append(Gift(f'{paradox[8:].lower()} for {present[8:].lower()}', 'events_mining_museum', giver,
                        ALL_BADGES, None, [[True, ('party', 1), False]],
                        [(present, 0, SHOWN_LEVEL, 'ITEM_NONE', default_moves(present, 0, SHOWN_LEVEL)),
                         (paradox, 0, SHOWN_LEVEL, 'ITEM_NONE', default_moves(paradox, 0, SHOWN_LEVEL))],
                        add=(present, 0, SHOWN_LEVEL)))
    for name, events, giver, var, talks, gifts in SIMPLE:
        out.append(Gift(name, events, giver, 0, var, talks,
                        [(sp, 0, lv, it, default_moves(sp, 0, lv)) for sp, lv, it in gifts]))
    # An Egg of one of these at random, at Lv. 1 (Egg_CreateEgg), knowing its species' moves at that level.
    out.append(Gift("Trainers' School Egg", 'events_trainers_school', 'LOCALID_COWGIRL', 0, None, [[True]],
                    [(school_egg(), 0, 1, 'ITEM_NONE', None)]))
    return out


def talk_and_answer(d, sym, answers, limit=FRAME_LIMIT, press_a=True, done=None):
    """Talk (A) and play the script out on its menus: each time it shows one, the next answer is given (an entry
    number for a list menu, True or False for a yes/no question, ('party', slot) for the party screen). Otherwise, as
    in talk_to_objects.play_out, A pages through the text and taps pick moves in a battle (god mode). A menu is
    counted as the script shows it, before it reads any input, so A is never pressed into one the test hasn't seen.
    Without press_a, it plays out a script that starts on its own (a scene on entering a map); with done, it stops as
    soon as done() is true, with all the answers given, even if the script goes on.
    Returns ('ok', 'NOSCRIPT', 'HANG', 'STUCK', 'HEAP' (as in talk_to_objects.play_out) or 'MENU ...' (a menu with no
    answer, or of the wrong kind, or answers left over), frames)."""
    answers = list(answers)
    menu = sym['gSovereignTestMenu']
    seen = u32(d, menu)
    if press_a:
        d.press('A', frames=4, after=0)
    frames, stalled, started, idle, step = 0, 0, False, 0, 0
    vblank = u32(d, sym['gSystem'] + VBLANK_COUNTER)
    while frames < limit:
        before = u32(d, sym['gSovereignTestIdleFrames'])
        d.run(STEP)
        frames += STEP
        now = u32(d, sym['gSystem'] + VBLANK_COUNTER)
        stalled = stalled + STEP if now == vblank else 0
        vblank = now
        if stalled >= HANG_FRAMES:
            return 'HANG', frames
        if done and not answers and done():
            return heap_result(d), frames
        if u32(d, sym['gSovereignTestIdleFrames']) != before:
            if started:
                idle += 1
                if idle >= 2:
                    return (heap_result(d) if not answers else f'MENU {len(answers)} answers left'), frames
            elif frames >= START_FRAMES:
                return 'NOSCRIPT', frames
            continue
        started, idle = True, 0
        if u32(d, menu) != seen:  # the script shows a menu
            if not answers:
                return 'MENU with no answer', frames
            answer, kind = answers.pop(0), u32(d, menu + 4)
            d.run(MENU_SETTLE)  # a menu takes no input for its first frames
            frames += MENU_SETTLE
            if kind == MENU_LIST and type(answer) is int:
                for _ in range(answer):
                    d.press('DOWN', frames=2, after=4)
                d.press('A', frames=4, after=0)
            elif kind == MENU_YES_NO and type(answer) is bool:
                d.press('A' if answer else 'B', frames=4, after=0)
            elif kind == MENU_PARTY and type(answer) is tuple and answer[0] == 'party':
                d.run(PARTY_SETTLE)
                frames += PARTY_SETTLE
                for key in ['DOWN'] * (answer[1] // 2) + ['RIGHT'] * (answer[1] % 2):  # two columns of slots
                    d.press(key, frames=2, after=6)
                d.press('A', frames=4, after=0)
            else:
                return f'MENU kind {kind} for {answer!r}', frames
            seen = u32(d, menu)
            continue
        step += 1
        if step % 3 == 0:  # a page of text
            d.press('A', frames=2, after=0)
        else:  # the move a tap opens in a battle
            d.touch(*TAPS[frames // SWITCH_FRAMES % len(TAPS)], frames=4, after=0)
    return 'STUCK', frames


def heap_result(d):
    """'ok', or 'HEAP' when a heap's block lists are broken (heap_check.py)."""
    return 'HEAP' if heap_problems(d.emu.memory, heap_info()) else 'ok'


def note_party(d, sym):
    """[(species, ability, held item, [moves], form, level, has Hidden Ability, is an Egg)] of the party, from the
    game."""
    mem, at = d.emu.memory, sym['gSovereignTestParty']
    mem.write_byte(at + PARTY['wanted'], 1)
    for _ in range(60):
        d.run(2)
        if mem.unsigned[at + PARTY['wanted']] == 0:
            break
    size = struct.calcsize(MON)
    party = []
    for i in range(mem.unsigned[at + PARTY['count']]):
        species, ability, item, *rest = struct.unpack(MON, bytes(mem.unsigned[at + PARTY['mons'] + i * size:
                                                                           at + PARTY['mons'] + (i + 1) * size]))
        party.append((species, ability, item, rest[:4], rest[4], rest[5], rest[6], rest[7]))
    return party


def main():
    from drive import Driver

    rom, state, out, only, _, _ = parse_args(sys.argv[1:])
    sym = symbols(SYMBOLS + ('gSovereignTestMenu', 'gSovereignTestPartyKeep', 'gSovereignTestParty',
                             'gSovereignTestBadges', 'gSovereignTestPartyAdd'))
    variables = var_ids()
    species_names, move_names, ability_names, item_names = (names(k) for k in ('species', 'moves', 'abilities',
                                                                                 'items'))
    places = {(c[0], c[1]): c for c in talk_cases()}
    chosen = [c for c in cases() if not only or c.name in only]
    d = Driver(rom, state)
    d.added, d.armed = [], False
    mem = d.emu.memory

    def setup(gift):  # all applied by the way-in warp
        mem.write_byte(sym['gSovereignTestPartyKeep'], 1)
        mem.write_byte(sym['gSovereignTestBadges'], gift.badges)
        if gift.var:
            mem.write_short(sym['gSovereignTestVar'], variables[gift.var[0]])
            mem.write_short(sym['gSovereignTestVar'] + 2, gift.var[1])
        if gift.add:
            mem.write_short(sym['gSovereignTestPartyAdd'], species_names.index(gift.add[0]))
            mem.write_byte(sym['gSovereignTestPartyAdd'] + 2, gift.add[1])
            mem.write_byte(sym['gSovereignTestPartyAdd'] + 3, gift.add[2])

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for gift in chosen:
            name, events, giver, talks, gifts = gift.name, gift.events, gift.giver, gift.talks, gift.gifts
            _, _, header, way_in, x, z, face = places[(events, giver)]
            result, frames = arrive(d, sym, state, variables, events, header, way_in, x, z, face,
                                    setup=lambda: setup(gift))
            for answers in talks:
                if result != 'ok':
                    break
                d.press(['UP', 'DOWN', 'LEFT', 'RIGHT'][face], frames=2, after=10)  # face the giver again
                result, frames = talk_and_answer(d, sym, answers)
            wrong, hatches = [], None
            if result == 'ok':
                party = note_party(d, sym)
                if len(party) != 1 + len(gifts):
                    wrong.append(f'party size {len(party)} (want {1 + len(gifts)})')
                for got, (species, form, level, item, moves) in zip(party[1:], gifts):
                    got_species, ability, got_item, got_moves, got_form, got_level, hidden, egg = got
                    want_egg = type(species) is tuple  # an Egg of one of these species
                    if want_egg:
                        hatches = species_names[got_species][8:].lower()
                        species = species_names[got_species] if species_names[got_species] in species \
                            else ' or '.join(species)
                        moves = default_moves(species, form, level) if species in species_names else None
                    # The third ability is its Hidden Ability.
                    abilities = data_of(species, form)['abilities'][:2] if species in species_names else []
                    checks = [('species', species_names[got_species], species), ('form', got_form, form),
                              ('level', got_level, level), ('held item', item_names[got_item], item),
                              ('moves', [move_names[m] for m in got_moves], moves), ('Hidden Ability', hidden, 0),
                              ('Egg', egg, int(want_egg))]
                    wrong += [f'{species[8:].lower()} {what} {g} (want {w})' for what, g, w in checks if g != w]
                    if ability_names[ability] not in abilities:
                        wrong.append(f'{species[8:].lower()} ability {ability_names[ability]} (want '
                                     f'{" or ".join(abilities)})')
            if result != 'ok' or wrong:
                bad += 1
                d.screenshot().save(os.path.join(out, f'{name.replace(" ", "_")}.png'))
            what = ', '.join(f'{f"an Egg ({hatches})" if type(sp) is tuple else sp[8:].lower()}'
                             f'{f" form {fo}" if fo else ""} Lv. {lv}' for sp, fo, lv, _, _ in gifts)
            line = f'{name}: {what}: {result} {frames}' + ''.join(f'\n    WRONG {w}' for w in wrong)
            print(line, file=f, flush=True)
            print(line, flush=True)
        print(f'{len(chosen) - bad} of {len(chosen)} gifts ok', file=f)
    print(f'{len(chosen) - bad} of {len(chosen)} gifts ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
