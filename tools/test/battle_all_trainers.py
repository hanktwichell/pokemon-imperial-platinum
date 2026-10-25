#!/usr/bin/env python3
"""Battle every trainer in the test build: the party matches its JSON, the battle runs to the end, nothing hangs.

For each trainer (decomp/generated/trainers.txt; TRAINER_X is decomp/res/trainers/data/x.json) this loads a save
state in the overworld and sets two test-build hooks (include/sovereign_test.h):
- gSovereignTestBattleTrainer, so SELECT+R battles that trainer (doubles if its data says so).
- God mode: a foe that loses any HP loses all of it, the player's Pokémon lose none, the player's moves ignore the
  foes' abilities, no EXP is gained, the battle style is Set and the text is fast. (A few moves set HP directly, such
  as Pain Split; the player's Pokémon can still lose HP to those.)
Every 20 frames it then taps the touch screen, or every third time presses A. The tap is FIGHT in the command menu,
and in the move menu the second move or, every other 2,000 frames, the third: the test party's Garchomp has Dazzling
Gleam (which hits both foes) and Play Rough there, Fairy moves that no type is immune to. Switching between them gets
past Torment, Disable and a move out of PP. A pages through the messages that wait for a button and, in a
double battle, confirms the move's target. (B would undo the first Pokémon's choice there.) When A lands in the move
menu it picks the first move instead, which costs at most a turn. So every Pokémon the trainer has is sent out, and
those faster than Garchomp use a move first.

Each trainer gets one result:
- **PARTY:** the Pokémon the game built (caught with a hook on Party_AddPokemon) differ from the JSON
  (check_trainer_party.compare_party: species, form, level, item, moves, nature, ability, IVs, EVs, stats...).
- **HANG:** the main loop stopped (gSystem's vblankCounter didn't move for 120 frames), which is a crash.
- **STUCK:** the battle didn't end in time: a prompt the taps don't answer, or a soft lock. See its screenshot.
- **ok:** the battle ended and the field runs again.
- **NO-RESULT:** (with --jobs) the worker for it stopped first, e.g. killed by a time limit.

Needs the test build (tools/test/build_test_rom.sh), its symbol map (decomp/build_test/main.nef.xMAP), a save state
in the overworld made with that build (tools/test/new_game.sh), py-desmume and Pillow. From the repo root:
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy python3 tools/test/battle_all_trainers.py \\
        decomp/build_test/pokeplatinum.us.nds STATE OUT_DIR [--jobs N] [--shots] [TRAINER ...]
TRAINER is a constant (TRAINER_LEADER_ROARK) or an index range (100-199); the default is every trainer. Each result
is a line in OUT_DIR/results.txt, with a screenshot for any that isn't ok; --shots also saves a screen every 600
frames. All 1,039 take a little over 2 hours with 4 jobs, so give a background run more time than that.
"""
import json
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_trainer_party import compare_party  # noqa: E402

DECOMP = 'decomp'
# Both are FIGHT in the command menu; in the move menu the second move and the third (the test Garchomp's Dazzling
# Gleam and Play Rough, both Fairy). The tap switches between them every SWITCH_FRAMES, so Torment, Disable or a move
# out of PP can't hold the battle up.
TAPS = ((190, 60), (64, 112))
SWITCH_FRAMES = 2000
FRAME_LIMIT = 4000, 2400  # the frames a battle may take: a base, and more for each of the trainer's Pokémon
HANG_FRAMES = 120
STEP = 20  # frames between inputs
VBLANK_COUNTER = 0x2C  # offsetof(System, vblankCounter)


def symbols(names=('gSovereignTestBattleTrainer', 'gSovereignTestGodMode', 'gSovereignTestIdleFrames', 'gSystem')):
    """The addresses of these .bss symbols and of Party_AddPokemon, from the test build's map."""
    xmap = open(os.path.join(DECOMP, 'build_test', 'main.nef.xMAP'), encoding='utf-8', errors='replace').read()

    def find(name, section):
        return int(re.search(r'^\s*([0-9A-F]{8}) [0-9A-F]{8} \.' + section + r'\s+' + name + r'\b', xmap, re.M)
                   .group(1), 16)

    return {name: find(name, 'bss') for name in names} | {'Party_AddPokemon': find('Party_AddPokemon', 'text')}


def trainer_ids():
    names = [line.strip() for line in open(os.path.join(DECOMP, 'generated', 'trainers.txt')) if line.strip()]
    return [(i, name) for i, name in enumerate(names) if name not in ('TRAINER_NONE', 'MAX_TRAINERS')]


def pick(args):
    trainers = trainer_ids()
    if not args:
        return trainers
    chosen = []
    for arg in args:
        if re.fullmatch(r'\d+-\d+', arg):
            lo, hi = map(int, arg.split('-'))
            chosen += [t for t in trainers if lo <= t[0] <= hi]
        else:
            chosen += [t for t in trainers if t[1] == arg]
    return chosen


def fight(d, sym, limit, shot=None):
    """Play the battle just started (with SELECT or SELECT+R) to its end, as the docstring says: taps and A presses
    while the field is busy, until the field runs again. d.armed is cleared after 400 frames, when both parties are
    built. shot(frames), if given, is called every 600 frames. Returns ('ok', 'HANG' or 'STUCK', frames run)."""
    def u32(addr):
        return struct.unpack('<I', bytes(d.emu.memory.unsigned[addr:addr + 4]))[0]

    frames, stalled, started, idle = 0, 0, False, 0
    vblank = u32(sym['gSystem'] + VBLANK_COUNTER)
    result = 'STUCK'
    while frames < limit:
        before = u32(sym['gSovereignTestIdleFrames'])
        d.run(STEP)
        frames += STEP
        d.armed = frames < 400  # long enough for both parties
        if shot and frames % 600 < STEP:
            shot(frames)
        now = u32(sym['gSystem'] + VBLANK_COUNTER)
        stalled = stalled + STEP if now == vblank else 0
        vblank = now
        if stalled >= HANG_FRAMES:
            result = 'HANG'
            break
        if u32(sym['gSovereignTestIdleFrames']) == before:
            started, idle = True, 0
            if frames % (3 * STEP):
                d.touch(*TAPS[frames // SWITCH_FRAMES % len(TAPS)], frames=4, after=0)
            else:  # A every third step: messages that wait for a button, and a doubles move's target
                d.press('A', frames=4, after=0)
        elif started:
            idle += 1
            if idle >= 2:
                result = 'ok'
                break

    return result, frames


def battle(d, sym, state, index, name, out, shots=False):
    trainer = json.load(open(os.path.join(DECOMP, 'res', 'trainers', 'data', name[len('TRAINER_'):].lower() + '.json')))
    d.emu.savestate.load_file(state)
    d.run(30)
    d.emu.memory.write_short(sym['gSovereignTestBattleTrainer'], index)
    d.emu.memory.write_byte(sym['gSovereignTestGodMode'], 1)
    d.added.clear()
    d.armed = True  # the parties are built as the battle starts
    d.press('SELECT+R')

    shot = (lambda frames: d.screenshot().save(os.path.join(out, f'{index:04d}_{frames:05d}.png'))) if shots else None
    result, frames = fight(d, sym, FRAME_LIMIT[0] + FRAME_LIMIT[1] * len(trainer['party']), shot)

    failures, report = compare_party(d.added, trainer)
    if failures:
        result = 'PARTY' if result == 'ok' else result + '+PARTY'
    if result != 'ok':
        d.screenshot().save(os.path.join(out, f'{index:04d}_{name}_{result}.png'))
    detail = ' | '.join(line.strip() for line in report if line.startswith(('FAIL', ' ')))
    return f'{index} {name} {result} {frames}' + (f' {detail}' if detail else '')


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
    trainers = pick(args[3:])
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
        lines += [f'{index} {name} NO-RESULT 0 (its worker stopped)' for index, name in trainers if index not in done]
        open(os.path.join(out, 'results.txt'), 'w').write('\n'.join(lines) + '\n')
        bad = [line for line in lines if line.split()[2] != 'ok']
        print('\n'.join(bad))
        print(f'{len(lines) - len(bad)} of {len(lines)} trainers ok')
        sys.exit(1 if bad else 0)

    from drive import Driver

    sym = symbols()
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
        trainers = trainers[k::n]
    path = os.path.join(out, f'results_{worker[0]}.txt' if worker else 'results.txt')
    bad = 0
    with open(path, 'w') as f:
        for index, name in trainers:
            line = battle(d, sym, state, index, name, out, shots)
            bad += line.split()[2] != 'ok'
            print(line, file=f, flush=True)
            if not worker:
                print(line, flush=True)
    if not worker:
        print(f'{len(trainers) - bad} of {len(trainers)} trainers ok')
        sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
