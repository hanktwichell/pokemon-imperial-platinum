#!/usr/bin/env python3
"""Battle mechanics regression suite: replays the in-game checks made for each battle change (moves, abilities, held
items, Platinum's own mechanics under the later rules) and compares each battle with the one recorded when the change
was checked.

Each case (tools/test/battle_mechanics_cases.py) is one test battle from a save state in the test build:
- **Singles** (no `trainer`): a wild battle (SELECT). The lead (gSovereignTestLead) has the case's moves; the wild
  Pokémon (gSovereignTestWild, a Lv. 100 Ninjask unless set) knows one move, so it acts first each turn.
- **Doubles** (`trainer`): a double battle against that trainer (SELECT+R), with `partner` as the party's second
  Pokémon (gSovereignTestPartner).
The harness taps the bottom screen's first move slot (and A) whenever the battle waits for the player, until the field
is back. Some options are poked into the battle's Pokémon once they are in it (gSovereignTestBattleMons, offsets from
the test build): abilities, held items, HP, friendship, statuses.

Every battle starts from the same random seed (gSovereignTestBattleSeed; the game seeds a battle from the clock), so a
case plays the same on every run of one build. What a battle did is how it ended ('ended': the field came back;
'limit': it was still on at the case's frame limit, as for a foe that can't be knocked out), its message log
(gSovereignTestMessageLog: every message the battle printed, in order) and its HP log (each change of the battlers'
current HP). A case passes when all three match the ones recorded for it in tools/test/battle_mechanics_expected.json
(--record writes them). The battle's clock starts on the frame its first message comes up (inputs, pokes and the frame
limit count from it), so a case plays the same from any save state. A battle cut off at its frame limit can still get
a few frames further on another build (a longer animation), so there the messages are compared up to the last turn
both began, and the HP logs as far as both go. A comment above a case, and the batch's entry in EngineChangelog.md, say what its battle
showed when the change was made. A change that makes a battle use the random numbers differently (or take a different
number of frames to start) can change a damage roll, a critical hit or who moves first, so read a difference before
calling it a bug, and re-record the case (--record CASE) once it's understood.

Results per case: ok, DIFF (the end, messages or HP differ; both shown), NEW (nothing recorded for it), HANG (the
frame counter stopped). A case that doesn't end normally also saves a screenshot.

Usage (repo root, with SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy):
  python3 tools/test/battle_mechanics.py decomp/build_test/pokeplatinum.us.nds STATE OUT [--jobs N] [--record]
          [--list] [CASE ...]
STATE is a save state in the field of the test build (the one the other battle harnesses use). CASE names (or name
prefixes ending in *) pick cases; --list prints them. The whole suite takes about an hour with 4 jobs.
"""
import json
import os
import subprocess
import sys

TEST_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, TEST_DIR)
from battle_all_trainers import HANG_FRAMES, STEP, TAPS, VBLANK_COUNTER, symbols  # noqa: E402
from battle_form_changes import LEAD  # noqa: E402
from battle_mechanics_cases import CASES  # noqa: E402
from check_trainer_party import consts  # noqa: E402
from talk_to_objects import u32  # noqa: E402

DECOMP = os.path.join(TEST_DIR, '..', '..', 'decomp')
EXPECTED = os.path.join(TEST_DIR, 'battle_mechanics_expected.json')
WILD = {'species': 0, 'form': 2, 'level': 3, 'move': 4, 'item': 8, 'balls': 10}
LEAD_PERSONALITY = 20  # offsetof(struct SovereignTestLead, personality)
PARTNER = {'species': 0, 'level': 3, 'moves': 4, 'hp': 12}
# struct SovereignTestBattleMons: the pointer, then u16 fields
MON_FIELDS = ('size', 'moves', 'statBoosts', 'types', 'ability', 'ppCur', 'friendship', 'curHP', 'maxHP', 'status',
              'statusVolatile', 'heldItem')
LOG_CHARS = 8192  # SOVEREIGN_TEST_MESSAGE_LOG_CHARS
START_FRAMES = 1800  # the most frames from SELECT to the battle's first message
SYMBOLS = ('gSovereignTestLead', 'gSovereignTestWild', 'gSovereignTestGodMode', 'gSystem', 'gSovereignTestIdleFrames',
           'gSovereignTestFoeSurvivesTurns', 'gSovereignTestPartner', 'gSovereignTestBattleTrainer',
           'gSovereignTestMessageLog', 'gSovereignTestBattleMons', 'gSovereignTestBattleSeed')
SEED = 0x5EED5EED  # every case's battle seed (gSovereignTestBattleSeed), so each battle plays the same every run
# The player's lead, the foe (or the first foe), the player's partner and the second foe (doubles)
LEAD_B, FOE_B, PARTNER_B, FOE2_B = 0, 1, 2, 3


def charmap():
    """Character code -> text, from the message encoder's map (newlines and page breaks read as spaces)."""
    chars = {}
    with open(os.path.join(DECOMP, 'tools', 'msgenc', 'charmap.txt'), encoding='utf-8') as f:
        for line in f:
            code, sep, text = line.rstrip('\n').partition('=')
            if not sep or line.lstrip().startswith('//'):
                continue
            try:
                chars.setdefault(int(code.strip(), 16), text)
            except ValueError:
                continue
    for code in (0xE000, 0x25BC, 0x25BD):  # \n, \r, \f
        chars[code] = ' '
    return chars


def decode_log(codes, chars):
    """The messages, one string each. What follows a format code (0xFFFE) is left out: the prompt "What will X do?"
    ends in one, with codes for the touch screen."""
    messages, cur, skip = [], [], False
    for c in codes:
        if c == 0xFFFF:
            messages.append(' '.join(''.join(cur).split()))
            cur, skip = [], False
        elif c == 0xFFFE:
            skip = True
        elif not skip:
            cur.append(chars.get(c, '{%04X}' % c))
    return messages


class Battle:
    """The battle's Pokémon, through the test build's gSovereignTestBattleMons."""

    def __init__(self, d, sym):
        self.d, self.mem = d, d.emu.memory
        self.ptr = sym['gSovereignTestBattleMons']
        self.off = None

    def mons(self):
        """Where the battle's Pokémon are, 0 before the battle starts; the offsets are read once it has."""
        mons = u32(self.d, self.ptr)
        if mons and self.off is None:
            self.off = {name: self.mem.unsigned[self.ptr + 4 + 2 * i] | self.mem.unsigned[self.ptr + 5 + 2 * i] << 8
                        for i, name in enumerate(MON_FIELDS)}
        return mons

    def addr(self, battler, field):
        return self.mons() + battler * self.off['size'] + self.off[field]

    def read(self, battler, field, size):
        a = self.addr(battler, field)
        return int.from_bytes(bytes(self.mem.unsigned[a:a + size]), 'little')

    def write(self, battler, field, value, size):
        a = self.addr(battler, field)
        {1: self.mem.write_byte, 2: self.mem.write_short, 4: self.mem.write_long}[size](a, value)

    def species(self, battler):
        a = self.mons() + battler * self.off['size']  # species is BattleMon's first field
        return self.mem.unsigned[a] | self.mem.unsigned[a + 1] << 8

    def write_move(self, battler, slot, move):
        self.mem.write_short(self.addr(battler, 'moves') + 2 * slot, move)

    def hp(self, count):
        return tuple(self.read(b, 'curHP', 4) for b in range(count))


def setup(d, sym, case, names):
    """Write the case's test-build hooks, from the save state, and start its battle."""
    species, moves, items = names['species'], names['moves'], names['items']
    mem = d.emu.memory
    lead, wild, partner = sym['gSovereignTestLead'], sym['gSovereignTestWild'], sym['gSovereignTestPartner']
    doubles = 'trainer' in case
    mem.write_short(lead + LEAD['species'], species.index('SPECIES_' + case['lead']))
    mem.write_byte(lead + LEAD['level'], case.get('lead_level', 50))
    if case.get('item'):
        mem.write_short(lead + LEAD['item'], items.index('ITEM_' + case['item']))
        mem.write_byte(sym['gSovereignTestFoeSurvivesTurns'], 2)  # an item acting at the end of the turn gets a turn
    if case.get('survive'):
        mem.write_byte(sym['gSovereignTestFoeSurvivesTurns'], case['survive'])
    if case.get('hp'):
        mem.write_byte(lead + LEAD['hp'], case['hp'])
    if case.get('form'):
        mem.write_byte(lead + LEAD['form'], case['form'])
    mem.write_long(lead + LEAD_PERSONALITY, case.get('personality', 2))
    if case.get('hidden'):
        mem.write_byte(lead + LEAD['hidden'], 1)
    lead_move = case.get('lead_move')  # none: the lead keeps its own moves
    if lead_move:
        mem.write_short(lead + LEAD['moves'] + 2, moves.index('MOVE_' + lead_move))  # slot 1: the one the taps pick
        for slot, mv in enumerate(case.get('slots', ())):
            mem.write_short(lead + LEAD['moves'] + 2 * slot, moves.index('MOVE_' + mv))
        if case.get('all_moves'):
            for slot in (0, 2, 3):
                mem.write_short(lead + LEAD['moves'] + 2 * slot, moves.index('MOVE_' + lead_move))
    mem.write_short(wild + WILD['item'], items.index('ITEM_' + case['wild_item']) if case.get('wild_item') else 0)
    mem.write_short(wild + WILD['species'], species.index('SPECIES_' + case.get('wild_species', 'NINJASK')))
    mem.write_byte(wild + WILD['level'], case.get('wild_level', 100))
    mem.write_short(wild + WILD['move'], moves.index('MOVE_' + case.get('foe_move', 'TACKLE')))
    mem.write_byte(sym['gSovereignTestGodMode'], 0 if case.get('nogod') else 1)
    if case.get('throw'):
        mem.write_byte(wild + WILD['balls'], 5)
    if doubles:
        for slot, mv in enumerate(case.get('partner_moves', ())):
            mem.write_short(partner + PARTNER['moves'] + 2 * slot, moves.index('MOVE_' + mv))
        mem.write_short(partner + PARTNER['species'], species.index('SPECIES_' + case['partner']))
        mem.write_byte(partner + PARTNER['level'], case.get('partner_level', 50))
        mem.write_short(sym['gSovereignTestBattleTrainer'], names['trainers'].index('TRAINER_' + case['trainer']))
    else:
        mem.write_short(partner + PARTNER['species'],
                        species.index('SPECIES_' + case['partner']) if case.get('partner') else 0)
        if case.get('partner'):
            mem.write_byte(partner + PARTNER['level'], case.get('partner_level', 50))
            for slot in range(4):
                mem.write_short(partner + PARTNER['moves'] + 2 * slot,
                                moves.index('MOVE_' + case.get('partner_moves', ['SPLASH'] * 4)[slot]))
            mem.write_byte(partner + PARTNER['hp'], 100)
    mem.write_short(sym['gSovereignTestMessageLog'], 0)
    mem.write_long(sym['gSovereignTestBattleSeed'], SEED)
    d.press('SELECT+R' if doubles else 'SELECT')


def poke_start(b, case, names):
    """Pokes made once the battle's Pokémon are in it."""
    items, abilities = names['items'], names['abilities']
    if case.get('lead_ability'):
        b.write(LEAD_B, 'ability', abilities.index('ABILITY_' + case['lead_ability']), 2)
    if case.get('lead_friendship') is not None:
        b.write(LEAD_B, 'friendship', case['lead_friendship'], 1)
    if case.get('lead_volatile'):
        b.write(LEAD_B, 'statusVolatile', b.read(LEAD_B, 'statusVolatile', 4) | case['lead_volatile'], 4)
    if case.get('wild_ability'):
        b.write(FOE_B, 'ability', abilities.index('ABILITY_' + case['wild_ability']), 2)
    if case.get('foe_hp'):
        b.write(FOE_B, 'curHP', case['foe_hp'], 4)
    if 'trainer' in case:
        if case.get('partner_item'):
            b.write(PARTNER_B, 'heldItem', items.index('ITEM_' + case['partner_item']), 2)
        if case.get('partner_ability'):
            b.write(PARTNER_B, 'ability', abilities.index('ABILITY_' + case['partner_ability']), 2)
        if case.get('partner_hp'):
            b.write(PARTNER_B, 'curHP', case['partner_hp'], 4)
        for battler, item in zip((FOE_B, FOE2_B), case.get('foe_items', ())):
            b.write(battler, 'heldItem', items.index('ITEM_' + item), 2)
        if case.get('foe2_ability'):
            b.write(FOE2_B, 'ability', abilities.index('ABILITY_' + case['foe2_ability']), 2)


def log_length(d, sym):
    log = sym['gSovereignTestMessageLog']
    return d.emu.memory.unsigned[log] | d.emu.memory.unsigned[log + 1] << 8


def run_case(d, sym, case, state, names, chars, out):
    d.load_state(state)
    d.run(30)
    setup(d, sym, case, names)
    # The battle's clock starts on the frame its first message comes up: every input, poke and the frame limit count
    # from there, so a case plays the same from any save state (the field takes more or fewer frames to start it).
    for _ in range(START_FRAMES):
        if log_length(d, sym):
            break
        d.run(1)
    b = Battle(d, sym)
    count = 4 if 'trainer' in case else 2
    lead_sp = names['species'].index('SPECIES_' + case['lead'])
    frames, stalled, started, idle, poked = 0, 0, False, 0, False
    vblank = u32(d, sym['gSystem'] + VBLANK_COUNTER)
    result, hplog, last, foe_pp = 'limit', [], None, None
    state_ = {'hits': 0, 'drops': 0}
    limit = case.get('stop_at', (14000 if 'trainer' in case else 4000) + 1000 * case.get('survive', 0))
    while frames < limit:
        before = u32(d, sym['gSovereignTestIdleFrames'])
        d.run(STEP)
        frames += STEP
        now = u32(d, sym['gSystem'] + VBLANK_COUNTER)
        stalled = stalled + STEP if now == vblank else 0
        vblank = now
        if stalled >= HANG_FRAMES:
            result = 'HANG'
            break
        if b.mons() and b.species(LEAD_B) == lead_sp and b.read(LEAD_B, 'maxHP', 4):
            # the pokes land on the first whole second after the Pokémon are in (as when the cases were checked)
            if not poked and frames >= 60 and frames % 60 == 0:
                poke_start(b, case, names)
                poked = True
        if poked and b.mons():
            hp = b.hp(count)
            pp = b.read(FOE_B, 'ppCur', 1)
            if case.get('poke_maxhp') and last and hp[LEAD_B] < last[LEAD_B]:
                state_['hits'] += 1
                if state_['hits'] == case['poke_maxhp']:
                    b.write(LEAD_B, 'maxHP', 999, 4)
            if foe_pp is not None and pp < foe_pp:
                state_['drops'] += 1
                mv = case.get('move_pokes', {}).get(state_['drops'])
                if mv:
                    for slot in range(4):
                        b.write_move(LEAD_B, slot, names['moves'].index('MOVE_' + mv))
                wmv = case.get('wild_move_pokes', {}).get(state_['drops'])
                if wmv:
                    b.write_move(FOE_B, 0, names['moves'].index('MOVE_' + wmv))
            foe_pp = pp
            if hp != last:
                hplog.append(list(hp))
                last = hp
        if u32(d, sym['gSovereignTestIdleFrames']) == before:
            started, idle = True, 0
            # the action menu is up when the BAG button's orange shows at (20, 350) of the two stacked screens
            if (case.get('throw') and not state_.get('thrown')
                    and d.screenshot().convert('RGB').getpixel((20, 350)) == (224, 152, 40)):
                state_['thrown'] = True
                for x, y in ((35, 165), (190, 50), (64, 30), (100, 170)):
                    d.touch(x, y, frames=4, after=60)
                    d.run(60)
                    frames += 124
                continue
            taps = [tuple(t) for t in case.get('taps', TAPS)]
            if frames % (3 * STEP):
                d.touch(*(case.get('party_tap') or taps[frames // 2000 % len(taps)]), frames=4, after=0)
            else:
                d.press('A', frames=4, after=0)
        elif started:
            idle += 1
            if idle >= 2:
                result = 'ended'
                break
    if result != 'ended':
        d.screenshot().save(os.path.join(out, f"{case['name']}_{result}.png"))
    log = sym['gSovereignTestMessageLog']
    length = log_length(d, sym)
    raw = bytes(d.emu.memory.unsigned[log + 2:log + 2 + 2 * min(length, LOG_CHARS)])
    codes = [raw[i] | raw[i + 1] << 8 for i in range(0, len(raw), 2)]
    return {'result': result, 'messages': decode_log(codes, chars), 'hp': hplog}


def pick(args):
    if not args:
        return CASES
    out = []
    for a in args:
        found = [c for c in CASES if (c['name'].startswith(a[:-1]) if a.endswith('*') else c['name'] == a)]
        if not found:
            sys.exit(f'no case {a}')
        out += [c for c in found if c not in out]
    return out


def whole_turns(messages):
    """The messages of a battle cut off at its frame limit up to the last time it asked for a move ("What will ...
    do?", once): where the limit falls in the turn after that moves with any change to how many frames the battle
    takes."""
    asks = [i for i, m in enumerate(messages) if m.startswith('What will ')]
    if not asks:
        return messages
    out = messages[:asks[-1] + 1]
    while len(out) > 1 and out[-1] == out[-2]:
        out.pop()
    return out


def same_start(a, b):
    """Whether the shorter list is the start of the longer one."""
    n = min(len(a), len(b))
    return a[:n] == b[:n]


def compare(name, got, expected):
    """'ok', 'NEW' or 'DIFF', with the lines that explain a DIFF. Two battles cut off at the frame limit match when
    their messages agree up to the last turn they began (whole_turns) and one's HP log is the start of the other's."""
    want = expected.get(name)
    if got['result'] == 'HANG':
        return 'HANG', []
    if want is None:
        return 'NEW', []
    notes = []
    limit = got['result'] == want['result'] == 'limit'
    if got['result'] != want['result']:
        notes.append(f"  the battle: expected {want['result']}, got {got['result']}")
    if not (same_start(whole_turns(got['messages']), whole_turns(want['messages'])) if limit
            else got['messages'] == want['messages']):
        notes.append('  messages: expected')
        notes += ['    ' + m for m in want['messages']]
        notes.append('  got')
        notes += ['    ' + m for m in got['messages']]
    if not (same_start(got['hp'], want['hp']) if limit else got['hp'] == want['hp']):
        notes.append(f"  HP: expected {want['hp']}")
        notes.append(f"  got {got['hp']}")
    return ('DIFF' if notes else 'ok'), notes


def main():
    args = sys.argv[1:]
    flags = {a for a in args if a in ('--record', '--list')}
    jobs, worker = 1, None
    if '--jobs' in args:
        i = args.index('--jobs')
        jobs = int(args[i + 1])
        del args[i:i + 2]
    if '--worker' in args:
        i = args.index('--worker')
        worker = tuple(map(int, args[i + 1].split('/')))
        del args[i:i + 2]
    args = [a for a in args if a not in flags]
    if '--list' in flags:
        for c in CASES:
            print(c['name'])
        return
    rom, state, out = args[:3]
    cases = pick(args[3:])
    os.makedirs(out, exist_ok=True)
    if jobs > 1:
        procs = [subprocess.Popen([sys.executable, '-W', 'ignore', __file__, rom, state, out, '--worker', f'{k}/{jobs}']
                                  + [c['name'] for c in cases], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                 for k in range(jobs)]
        for p in procs:
            p.wait()
        got = {}
        for k in range(jobs):
            path = os.path.join(out, f'got_{k}.json')
            if os.path.exists(path):
                got.update(json.load(open(path)))
        report(cases, got, out, '--record' in flags)
        return
    from drive import Driver
    sym = symbols(SYMBOLS)
    names = {k: consts(k + '.txt') for k in ('species', 'moves', 'items', 'abilities', 'trainers')}
    chars = charmap()
    d = Driver(rom, state)
    mine = [c for i, c in enumerate(cases) if not worker or i % worker[1] == worker[0]]
    path = os.path.join(out, f'got_{worker[0]}.json' if worker else 'got.json')
    got = {}
    for c in mine:
        got[c['name']] = run_case(d, sym, c, state, names, chars, out)
        with open(path, 'w') as f:
            json.dump(got, f, indent=1)
        if not worker:
            print(c['name'], got[c['name']]['result'], flush=True)
    if not worker:
        report(cases, got, out, '--record' in flags)


def report(cases, got, out, record):
    expected = json.load(open(EXPECTED)) if os.path.exists(EXPECTED) else {}
    lines, counts = [], {}
    for c in cases:
        g = got.get(c['name'])
        if g is None:
            status, notes = 'NO-RESULT', []
        else:
            status, notes = compare(c['name'], g, expected)
        counts[status] = counts.get(status, 0) + 1
        lines.append(f"{c['name']} {status}")
        lines += notes
    with open(os.path.join(out, 'results.txt'), 'w') as f:
        f.write('\n'.join(lines) + '\n')
    print('\n'.join(line for line in lines if not line.endswith(' ok')))
    print(', '.join(f'{v} {k}' for k, v in sorted(counts.items())))
    if record:
        for c in cases:
            g = got.get(c['name'])
            if g and g['result'] != 'HANG':
                expected[c['name']] = {'result': g['result'], 'messages': g['messages'], 'hp': g['hp']}
        with open(EXPECTED, 'w') as f:
            json.dump(dict(sorted(expected.items())), f, indent=1, ensure_ascii=False)
            f.write('\n')
        print('recorded', sum(1 for c in cases if got.get(c['name'], {}).get('result') not in (None, 'HANG')), 'cases')


if __name__ == '__main__':
    main()
