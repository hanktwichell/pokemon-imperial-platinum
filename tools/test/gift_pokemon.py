#!/usr/bin/env python3
"""Receive every Pokémon gift Sovereign added, in the test build, and check what arrives in the party.

The gifts:
- the event-gift deliveryman in the Fight Area Pokémon Center: each event form of his list (sSovereignEventGifts,
  src/scrcmd.c) that is a gift, in its form and at its level, knowing its form's level-up moves with its signature move
  last (the Mythicals' entries are restyles, not gifts);
- the Ace Trainer there: Battle Bond Greninja, Lv. 50, with Water Shuriken, Aerial Ace, Double Team and Night Slash;
- the eight Pokémon Center Interviewers: the quiz (its right answers read from the script) and the battle against
  the region's starters, then, talking again, the prize: the three starters at the gift level, each with its
  type's held item (docs/GiftPokemon_Sovereign.md). The player has all eight badges (gSovereignTestBadges), as the
  later Interviewers wait on one;
- the other gifts Sovereign added: Lapras, Steven's Beldum, Porygon, the Twinleaf Eevee (Mom's state set to after the
  Journal) and Rowan's briefcase (the two starters the player didn't pick).

Each gift is a run from the save state: the party is cut to its lead to make room (gSovereignTestPartyKeep), the
player comes in by the map's way in and warps next to the giver (talk_to_objects.arrive), and talks, as many times as
the gift takes. Each script plays out on the real menus: when it waits on one (gSovereignTestMenu), the test moves the
cursor down to the entry it wants and presses A, or answers a yes/no question (no nickname); A pages through the text
and fights a battle otherwise (god mode). Then the party's last Pokémon (gSovereignTestParty) must be the gifts: each
one's species, form, level, an ability of its form's (not its Hidden Ability), held item and moves (its form's
level-up moves at its level, unless the gift sets them).

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
from battle_all_trainers import HANG_FRAMES, SWITCH_FRAMES, TAPS, VBLANK_COUNTER  # noqa: E402
from battle_evolutions import data_of  # noqa: E402
from talk_to_objects import (DECOMP, FRAME_LIMIT, START_FRAMES, SYMBOLS, arrive, cases as talk_cases,  # noqa: E402
                             parse_args, symbols, u32, var_ids)

EVENTS = 'events_fight_area_pokecenter_1f'
DELIVERYMAN = 'LOCALID_FIGHT_AREA_SOVEREIGN_EVENT_DELIVERYMAN'
GRENINJA_TRAINER = 'LOCALID_FIGHT_AREA_SOVEREIGN_GRENINJA_TRAINER'
MENU_LIST, MENU_YES_NO = 1, 2  # enum SovereignTestMenuKind
PARTY = {'wanted': 0, 'count': 1, 'mons': 4}  # struct SovereignTestParty
# struct SovereignTestPartyMon: species, ability, held item, moves, form, level, hasHiddenAbility.
MON = '<HHH4HBBBx'
ALL_BADGES = 0xff
STEP = 10
MENU_SETTLE = 10


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


Gift = collections.namedtuple('Gift', 'name events giver badges var talks gifts')
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
    # The test save's starter is Turtwig, so Rowan gives the other two.
    ("Rowan's briefcase", 'events_sandgem_town_pokemon_research_lab', 'LOCALID_SOVEREIGN_BRIEFCASE', None,
     [[True, False, False]], [('SPECIES_CHIMCHAR', 5, 'ITEM_NONE'), ('SPECIES_PIPLUP', 5, 'ITEM_NONE')]),
]


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
    for name, events, giver, var, talks, gifts in SIMPLE:
        out.append(Gift(name, events, giver, 0, var, talks,
                        [(sp, 0, lv, it, default_moves(sp, 0, lv)) for sp, lv, it in gifts]))
    return out


def talk_and_answer(d, sym, answers, limit=FRAME_LIMIT):
    """Talk (A) and play the script out on its menus: each time it shows one, the next answer is given (an entry
    number for a list menu, True or False for a yes/no question). Otherwise, as in talk_to_objects.play_out, A pages
    through the text and taps pick moves in a battle (god mode). A menu is counted as the script shows it, before it
    reads any input, so A is never pressed into one the test hasn't seen. Returns ('ok', 'NOSCRIPT', 'HANG', 'STUCK'
    or 'MENU ...' (a menu with no answer, or of the wrong kind, or answers left over), frames)."""
    answers = list(answers)
    menu = sym['gSovereignTestMenu']
    seen = u32(d, menu)
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
        if u32(d, sym['gSovereignTestIdleFrames']) != before:
            if started:
                idle += 1
                if idle >= 2:
                    return ('ok' if not answers else f'MENU {len(answers)} answers left'), frames
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


def note_party(d, sym):
    """[(species, ability, held item, [moves], form, level, has Hidden Ability)] of the party, from the game."""
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
        party.append((species, ability, item, rest[:4], rest[4], rest[5], rest[6]))
    return party


def main():
    from drive import Driver

    rom, state, out, only, _, _ = parse_args(sys.argv[1:])
    sym = symbols(SYMBOLS + ('gSovereignTestMenu', 'gSovereignTestPartyKeep', 'gSovereignTestParty',
                             'gSovereignTestBadges'))
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
            wrong = []
            if result == 'ok':
                party = note_party(d, sym)
                if len(party) != 1 + len(gifts):
                    wrong.append(f'party size {len(party)} (want {1 + len(gifts)})')
                for got, (species, form, level, item, moves) in zip(party[1:], gifts):
                    got_species, ability, got_item, got_moves, got_form, got_level, hidden = got
                    abilities = data_of(species, form)['abilities'][:2]  # the third is its Hidden Ability
                    checks = [('species', species_names[got_species], species), ('form', got_form, form),
                              ('level', got_level, level), ('held item', item_names[got_item], item),
                              ('moves', [move_names[m] for m in got_moves], moves), ('Hidden Ability', hidden, 0)]
                    wrong += [f'{species[8:].lower()} {what} {g} (want {w})' for what, g, w in checks if g != w]
                    if ability_names[ability] not in abilities:
                        wrong.append(f'{species[8:].lower()} ability {ability_names[ability]} (want '
                                     f'{" or ".join(abilities)})')
            if result != 'ok' or wrong:
                bad += 1
                d.screenshot().save(os.path.join(out, f'{name.replace(" ", "_")}.png'))
            what = ', '.join(f'{sp[8:].lower()}{f" form {fo}" if fo else ""} Lv. {lv}' for sp, fo, lv, _, _ in gifts)
            line = f'{name}: {what}: {result} {frames}' + ''.join(f'\n    WRONG {w}' for w in wrong)
            print(line, file=f, flush=True)
            print(line, flush=True)
        print(f'{len(chosen) - bad} of {len(chosen)} gifts ok', file=f)
    print(f'{len(chosen) - bad} of {len(chosen)} gifts ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
