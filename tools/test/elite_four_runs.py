#!/usr/bin/env python3
"""Run the Elite Four and the Champion in the test build on each path through the battle formats, and check that
each battle has the trainer and the format docs/EliteFourFormat.md gives it.

Each run starts from the save state with god mode on. The first test warp sets FLAG_GAME_COMPLETED for a rematch
(Aaron's three-way menu) and FLAG_ARRESTED_CHARON_STARK_MOUNTAIN for the rematch teams (gSovereignTestVar), and with
a lone Pokémon cuts the party to its lead (gSovereignTestPartyKeep). Then, room by room, the player warps onto the
room's entrance, as the elevator brings them (the scene on entering walks them in), walks up to the member and talks;
Cynthia's scene starts on its own. Each script plays out on the real menus, as in gift_pokemon.py: "single battle or
double battle?" and the rematch menu are answered with the run's picks, and the warning before a double battle with
one Pokémon able to fight with its answers (yes keeps doubles). A pages through the text and the battle is fought
with taps (god mode).

The battles the game starts are written down (gSovereignTestTrainerBattles): each one's trainer, format (the battle
type's BATTLE_TYPE_DOUBLES) and result must be the ones the doc's rules give for the run's picks (plan()), and won.
A pick of doubles that the lone Pokémon's warning turns down counts as singles for the rest of the run, as the
scripts keep it; a forced format turned down changes only that battle. After each battle the game's heaps must be
intact (heap_check.py): a broken heap shows up only later, as a crash or memory written over. The run stops after
Cynthia's battle, before the Hall of Fame.

Needs what talk_to_objects.py needs. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/elite_four_runs.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--part I/N] [RUN ...]
RUN is a run's number (from 0). A run takes about 5 minutes alone; all 13 take about 40 with --part I/4 in 4 jobs.
"""
import collections
import json
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from battle_all_trainers import VBLANK_COUNTER, trainer_ids  # noqa: E402
from gift_pokemon import MENU_SETTLE, talk_and_answer  # noqa: E402
from heap_check import heap_info_address, heap_problems  # noqa: E402
from talk_to_objects import (DECOMP, FRAME_LIMIT, SYMBOLS, header_names, parse_args, play_out, start_warp,  # noqa: E402
                             symbols, u32, var_ids, warp)

MEMBERS = ('AARON', 'BERTHA', 'FLINT', 'LUCIAN', 'CHAMPION')
S, D = 0, 1  # the formats, as the scripts' menus number them
FACE_UP = 0
BATTLE_TYPE_DOUBLES = 1 << 1
BATTLE_RESULT_WIN = 1 << 0
BATTLE = struct.Struct('<HHII')  # struct SovereignTestTrainerBattle
AFTER_CHAMPION = 600  # frames of Cynthia's script played out after her battle

# menu: the rematch menu's entry (0 all singles, 1 all doubles, 2 two and two), or None for the first challenge.
# picks: the format picked at each "single battle or double battle?", in order.
# keep: with a lone Pokémon, the answer to each warning before a double battle, in order (True keeps doubles); None
#   for the whole party.
# rematch_teams: Charon arrested at Stark Mountain, so the members use their rematch teams.
Run = collections.namedtuple('Run', 'name menu picks keep rematch_teams')
RUNS = [
    Run('first challenge: singles, singles', None, (S, S), None, False),
    Run('first challenge: doubles, doubles', None, (D, D), None, False),
    Run('first challenge: singles, doubles, Flint singles', None, (S, D, S), None, False),
    Run('first challenge: singles, doubles, Flint doubles', None, (S, D, D), None, False),
    Run('first challenge: doubles, singles, Flint singles', None, (D, S, S), None, False),
    Run('first challenge: doubles, singles, Flint doubles', None, (D, S, D), None, False),
    Run('rematch: all singles', 0, (), None, True),
    Run('rematch: all doubles', 1, (), None, True),
    Run('rematch: two and two, doubles, singles, Flint doubles', 2, (D, S, D), None, True),
    Run('rematch before Stark Mountain: all doubles', 1, (), None, False),
    Run('one Pokemon, first challenge: doubles (no), singles', None, (D, S), (False, True, False, False), False),
    Run('one Pokemon, first challenge: singles, doubles, Flint doubles (no)', None, (S, D, D),
        (True, False, True, True), False),
    Run('one Pokemon, rematch: all doubles', 1, (), (True, False, True, False, True), True),
]


def plan(run):
    """From docs/EliteFourFormat.md: ([the answers to each member's menus], [the format of each battle]) for the
    run's five battles."""
    picks, keep = list(run.picks), list(run.keep or ())
    answers = [[] for _ in MEMBERS]

    def warned(member, fmt):  # before a double battle, with one Pokémon able to fight
        if fmt == D and run.keep is not None:
            answers[member].append(keep[0])
            return D if keep.pop(0) else S
        return fmt

    def ask(member):
        answers[member].append(picks[0])
        return warned(member, picks.pop(0))

    if run.menu is not None:
        answers[0].append(run.menu)
    if run.menu == 0:
        formats = [S] * 5
    elif run.menu == 1:
        formats = [warned(member, D) for member in range(5)]
    else:
        aaron = ask(0)
        bertha = ask(1)
        if aaron == bertha:  # Flint and Lucian get the other format
            flint, lucian = warned(2, 1 - aaron), warned(3, 1 - aaron)
        else:
            flint = ask(2)
            lucian = warned(3, 1 - flint)
        formats = [aaron, bertha, flint, lucian, warned(4, D)]
    assert not picks and not keep, run.name
    return answers, formats


def trainer(member, fmt, rematch_teams):
    """The trainer the member battles in that format."""
    base = 'CHAMPION_CYNTHIA' if member == 'CHAMPION' else 'ELITE_FOUR_' + member
    rematch = '_REMATCH' if rematch_teams else ''
    return f'TRAINER_SOVEREIGN_{base}{rematch}_DOUBLES' if fmt == D else f'TRAINER_{base}{rematch}'


def rooms():
    """{member: (header ID, x, z of the room's entrance, where the elevator brings the player)}."""
    ids = header_names()
    out = {}
    for member in MEMBERS:
        room = f'pokemon_league_{member.lower()}_room'
        events = json.load(open(os.path.join(DECOMP, 'res', 'field', 'events', f'events_{room}.json'),
                                encoding='utf-8'))
        entrance = next(w for w in events['warp_events']
                        if w['dest_header_id'] == f'MAP_HEADER_POKEMON_LEAGUE_ELEVATOR_TO_{member}_ROOM')
        out[member] = (ids.index(f'MAP_HEADER_{room.upper()}'), entrance['x'], entrance['z'])
    return out


def battles(d, sym):
    """[(trainer IDs, battle type, result mask)] of the trainer battles started since the count was cleared."""
    at = sym['gSovereignTestTrainerBattles']
    mem = bytes(d.emu.memory.unsigned[at:at + 4 + 8 * BATTLE.size])
    count = min(struct.unpack_from('<I', mem)[0], 8)
    return [BATTLE.unpack_from(mem, 4 + i * BATTLE.size) for i in range(count)]


def walk_up(d, sym):
    """Walk up to the member, who stops the player. The test save's Super Repel runs out on the way (3 steps): its
    "Use another?" is answered no. Returns play_out's result."""
    menu, idle = sym['gSovereignTestMenu'], sym['gSovereignTestIdleFrames']
    seen = u32(d, menu)
    d.press('UP', frames=64, after=0)
    free = 0
    for _ in range(60):  # until the field is free twice in a row, or the prompt shows
        before = u32(d, idle)
        d.run(10)
        if u32(d, menu) != seen:
            break
        free = free + 1 if u32(d, idle) != before else 0
        if free >= 2:
            return 'ok', 0
    else:
        return 'STUCK', 0
    d.run(MENU_SETTLE)
    d.press('B', frames=4, after=0)
    result, frames = play_out(d, sym, FRAME_LIMIT, press_a=False)
    d.press('UP', frames=16, after=10)
    return ('ok' if result == 'NOSCRIPT' else result), frames  # NOSCRIPT: no closes it at once


def run_league(d, sym, state, variables, places, run, heaps):
    """Play the run through (heaps: sHeapInfo's address). Returns ([(member, the format its battle had or None, what
    was wrong)], frames)."""
    mem = d.emu.memory
    answers, formats = plan(run)
    names = dict(trainer_ids())
    d.load_state(state)
    d.run(30)
    mem.write_byte(sym['gSovereignTestGodMode'], 1)
    mem.write_long(sym['gSovereignTestTrainerBattles'], 0)
    if run.keep is not None:
        mem.write_byte(sym['gSovereignTestPartyKeep'], 1)
    flags = (('FLAG_GAME_COMPLETED', run.menu is not None), ('FLAG_ARRESTED_CHARON_STARK_MOUNTAIN', run.rematch_teams))
    for i, (flag, on) in enumerate(flags):  # all applied by the first warp
        mem.write_short(sym['gSovereignTestVar'] + 4 * i, variables[flag])
        mem.write_short(sym['gSovereignTestVar'] + 4 * i + 2, int(on))
    out, total = [], 0
    for m, member in enumerate(MEMBERS):
        header, x, z = places[member]
        if member == 'CHAMPION':  # the scene on entering is the battle
            start_warp(d, sym, header, x, z, FACE_UP + 1)
            result, frames = talk_and_answer(d, sym, answers[m], FRAME_LIMIT, press_a=False,
                                             done=lambda: any(b[3] for b in battles(d, sym)[4:5]))
            if result == 'ok':
                for _ in range(AFTER_CHAMPION // 20):  # her words, then on to the Hall of Fame
                    d.press('A', frames=2, after=18)
                frames += AFTER_CHAMPION
        else:
            result, frames = warp(d, sym, header, x, z, FACE_UP + 1)
            if result == 'ok':
                result, frames = walk_up(d, sym)
            if result == 'ok':
                result, frames = talk_and_answer(d, sym, answers[m])
        total += frames
        noted = battles(d, sym)
        got = noted[m] if len(noted) > m else None
        want = trainer(member, formats[m], run.rematch_teams)
        wrong = [] if result == 'ok' else [result]
        if got is None:
            wrong.append(f'no battle (want {want})')
        else:
            (first, _, kind, won), fmt = got, D if got[2] & BATTLE_TYPE_DOUBLES else S
            if names.get(first) != want:
                wrong.append(f'trainer {names.get(first, first)} (want {want})')
            if fmt != formats[m]:
                wrong.append(f'{"doubles" if fmt else "singles"} (want {"doubles" if formats[m] else "singles"})')
            if won != BATTLE_RESULT_WIN:
                wrong.append(f'result {won:#x}')
        if len(noted) > m + 1:
            wrong.append(f'{len(noted) - m - 1} more battles')
        wrong += [f'heap {heap_id}: {problem}' for heap_id, problem in heap_problems(mem, heaps)]
        out.append((member, None if got is None else D if got[2] & BATTLE_TYPE_DOUBLES else S, wrong))
        if wrong:
            break
    return out, total


def main():
    from drive import Driver

    rom, state, out, only, part, parts = parse_args(sys.argv[1:])
    sym = symbols(SYMBOLS + ('gSovereignTestMenu', 'gSovereignTestPartyKeep', 'gSovereignTestTrainerBattles'))
    variables = var_ids()
    places = rooms()
    heaps = heap_info_address()
    chosen = [(i, r) for i, r in enumerate(RUNS) if (not only or str(i) in only) and i % parts == part]
    d = Driver(rom, state)
    d.added, d.armed = [], False

    bad = 0
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        for index, run in chosen:
            steps, frames = run_league(d, sym, state, variables, places, run, heaps)
            vblank = u32(d, sym['gSystem'] + VBLANK_COUNTER)
            d.run(30)
            if u32(d, sym['gSystem'] + VBLANK_COUNTER) == vblank:
                steps[-1][2].append('HANG after the run')
            failed = len(steps) < len(MEMBERS) or any(wrong for _, _, wrong in steps)
            if failed:
                bad += 1
                d.screenshot().save(os.path.join(out, f'{index:02d}.png'))
            what = ', '.join(f'{member.lower()} {"-" if fmt is None else "SD"[fmt]}' for member, fmt, _ in steps)
            line = f'{index} {run.name}: {what}: {"FAIL" if failed else "ok"} {frames}' + ''.join(
                f'\n    WRONG {member.lower()}: {w}' for member, _, wrong in steps for w in wrong)
            print(line, file=f, flush=True)
            print(line, flush=True)
        print(f'{len(chosen) - bad} of {len(chosen)} runs ok', file=f)
    print(f'{len(chosen) - bad} of {len(chosen)} runs ok')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
