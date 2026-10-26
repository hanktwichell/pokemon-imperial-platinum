#!/usr/bin/env python3
"""Find field-script paths that run CloseMessage twice with no message opened in between.

ScrCmd_CloseMessage erases and removes the message window each time; a second CloseMessage removes the already
removed window, and the game hangs with the last message still on screen (found in E10 part 28). This walks every
script in decomp/res/field/scripts along its GoTo/GoToIf/Call branches and reports each pair (first close, second
close) as label+instruction index. A Call, CallIf or any message-like command resets the state, so it only reports
definite cases. Vanilla has two, both harmless: a link-contest error path and unused Route 201 scripts (VANILLA,
shown as known). Any other case fails the check (CI runs it).

Usage: python3 tools/test/check_double_close.py decomp
"""
import re, sys, glob
OPEN = re.compile(r'^(Message|MessageVar|MessageNoSkip|MessageInstant|MessageSeenBanlistSpecies|EventMessage|NonNpcMsg|NPCMessage|PrintTrainerDialogue|BufferAndMessage|Common_\w+|CallCommonScript|ShowYesNoMenu|DrawSignpost\w*|MessageUnown\w*|OpenMessage|\w*Message\w*)\b')
def parse(path):
    labels, cur = {}, None
    order = []
    for line in open(path):
        s = line.split('@')[0].rstrip()
        m = re.match(r'^(\w+):\s*$', s)
        if m:
            cur = m.group(1); labels[cur] = []; order.append(cur); continue
        if cur and s.strip():
            labels[cur].append(s.strip())
    return labels, order
def check(path):
    labels, order = parse(path)
    nxt = {order[i]: order[i + 1] for i in range(len(order) - 1)}
    out = set()
    def run(label, idx, closed_by, seen):
        key = (label, idx, closed_by is not None)
        if key in seen: return
        seen.add(key)
        ins = labels.get(label, [])
        while idx < len(ins):
            op = ins[idx]
            word = op.split()[0].rstrip(',')
            if word == 'CloseMessage':
                if closed_by: out.add((closed_by, f'{label}+{idx}'))
                closed_by = f'{label}+{idx}'
            elif word in ('CloseMessageWithoutErasing',):
                closed_by = None
            elif OPEN.match(word):
                closed_by = None
            if word in ('End', 'Return', 'ReturnCommonScript'): return
            m = re.match(r'^(GoTo|Call)\s+(\w+)$', op)
            if m:
                run(m.group(2), 0, closed_by, seen)
                if m.group(1) == 'GoTo': return
                closed_by = None
            m = re.match(r'^(GoToIf\w*|CallIf\w*)\s+.*,\s*(\w+)$', op)
            if m:
                run(m.group(2), 0, closed_by, seen)
                if m.group(1).startswith('CallIf'): closed_by = None
            idx += 1
        if label in nxt and not ins[-1:] == ['.balign 4, 0']:
            run(nxt[label], 0, closed_by, seen)
    for l in order:
        if 'Movement' in l: continue
        run(l, 0, None, set())
    return out
VANILLA = {'scripts_contests.s', 'scripts_route_201.s'}  # the two harmless vanilla cases
if __name__ == '__main__':
    bad = 0
    for f in sorted(glob.glob(sys.argv[1] + '/res/field/scripts/scripts_*.s')):
        r = check(f)
        if r:
            name = f.split('/')[-1]
            print(('known: ' if name in VANILLA else '') + name, sorted(r)[:4])
            bad += name not in VANILLA
    sys.exit(1 if bad else 0)
