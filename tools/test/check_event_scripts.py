#!/usr/bin/env python3
"""Find map events and init scripts whose script number points past the map's script table.

A map's objects, signs (bg events) and coord triggers name the script they run by number: 1 is the first
`ScriptEntry` of the map's scripts file (its map header's `scriptsArchiveID`), and numbers from 2000 up are common
scripts (2000 + the entry's index in scripts_common.s). The map's init scripts (`InitScriptEntry_OnTransition N`,
`InitScriptGoToIfEqual var, value, N` and the like) name local scripts the same way. A number past the end of the
table runs nothing, or another map's data: an NPC that never answers. This was found with the Battle Tower Ability
researcher (QoL #11), whose object named script 26 of a 25-entry table.

This reads every map header in decomp/include/data/map_headers.h, counts the `ScriptEntry` lines of its scripts file,
and checks each local (1-1999) and common (2000-2499) script number in its events file and init scripts. Vanilla's
own out-of-range numbers (one Oreburgh City sign) are listed in VANILLA and skipped. Exits 1 if it finds any other.

Usage: python3 tools/test/check_event_scripts.py decomp
"""
import json
import os
import re
import sys

COMMON_BASE, COMMON_END = 2000, 2500
# Vanilla Platinum already has these; they're kept as they are.
VANILLA = {
    'events_oreburgh_city bg_events[1]',  # a sign at (256, 808) naming script 45 of 22
}


def entries(path):
    with open(path, encoding='utf-8') as f:
        return sum(1 for line in f if re.match(r'\s*ScriptEntry\s+\w', line))


def main():
    decomp = sys.argv[1]
    scripts_dir = os.path.join(decomp, 'res', 'field', 'scripts')
    events_dir = os.path.join(decomp, 'res', 'field', 'events')
    headers = open(os.path.join(decomp, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
    pairs = set()
    for block in re.findall(r'\[MAP_HEADER_\w+\] = \{(.*?)\n    \},', headers, re.S):
        fields = dict(re.findall(r'\.(\w+) = (\w+)', block))
        if 'scriptsArchiveID' in fields and 'eventsArchiveID' in fields:
            pairs.add((fields['scriptsArchiveID'], fields.get('initScriptsArchiveID'), fields['eventsArchiveID']))
    common = entries(os.path.join(scripts_dir, 'scripts_common.s'))
    counts = {}
    bad = []

    def check(where, number, scripts):
        if where.split(' (')[0] in VANILLA:
            return
        if scripts not in counts:
            path = os.path.join(scripts_dir, scripts + '.s')
            counts[scripts] = entries(path) if os.path.exists(path) else None
        local = counts[scripts]
        if 1 <= number < COMMON_BASE and local is not None and number > local:
            bad.append(f'{where}: script {number}, but {scripts}.s has {local} entries')
        elif COMMON_BASE <= number < COMMON_END and number - COMMON_BASE >= common:
            bad.append(f'{where}: common script {number}, but scripts_common.s has {common} entries')

    for scripts, init, events in sorted(pairs, key=lambda p: (p[0], p[1] or '', p[2])):
        path = os.path.join(events_dir, events + '.json')
        if os.path.exists(path):
            data = json.load(open(path, encoding='utf-8'))
            for kind in ('object_events', 'bg_events', 'coord_events'):
                for i, e in enumerate(data.get(kind, [])):
                    number = e.get('script')
                    if isinstance(number, int):
                        check(f'{events} {kind}[{i}] ({e.get("id", "")})', number, scripts)
        if init:
            path = os.path.join(scripts_dir, init + '.s')
            if os.path.exists(path):
                with open(path, encoding='utf-8') as f:
                    for n, line in enumerate(f, 1):
                        m = re.match(r'\s*(InitScriptEntry_\w+|InitScriptGoToIf\w+)\s+(.*)', line)
                        if m and not m.group(1).endswith('Table'):
                            last = m.group(2).split('@')[0].split(',')[-1].strip()
                            if last.isdigit():
                                check(f'{init}.s:{n}', int(last), scripts)
    for line in sorted(set(bad)):
        print(line)
    if bad:
        print(f'{len(set(bad))} script number(s) out of range')
        sys.exit(1)
    print(f'ok: every event and init script number of {len(pairs)} map headers is in range')


if __name__ == '__main__':
    main()
