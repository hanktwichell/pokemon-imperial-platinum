#!/usr/bin/env python3
"""Check that warps lead to warps that exist, and that map scripts show their own map's texts.

- **Warps:** each warp in a map's events names a destination map header and a warp index there. The index must be
  below the destination's warp count (0x100 is the engine's "back to the saved position" and is skipped). A missing
  warp leaves the player at a wrong or garbage position.
- **Text banks:** a map's scripts show texts from the map header's `msgArchiveID` bank. A text ID from another bank
  assembles fine, but the game looks its index up in the map's own bank and shows the wrong line. Global menus
  (`AddMenuEntryImm` with `InitGlobalTextMenu`) may also use the menu entries bank.

Reads decomp/include/data/map_headers.h, decomp/res/field/events/*.json, decomp/res/field/scripts/*.s and
decomp/res/text/*.json. Exits 1 on any problem.

Usage: python3 tools/test/check_map_links.py decomp
"""
import collections
import glob
import json
import os
import re
import sys

TEXT_COMMANDS = ('Message', 'MessageInstant', 'MessageSynchronized', 'NPCMessage', 'EventMessage',
                 'PokemonCryAndMessage', 'AddMenuEntryImm', 'ShowMapSign', 'ShowArrowSign', 'ShowLandmarkSign',
                 'ShowScrollingSign', 'DrawSignpostInstantMessage', 'DrawSignpostScrollingMessage')
TEXT_USE = re.compile(r'^\s*(' + '|'.join(TEXT_COMMANDS) + r')\s+(\w+)')
WARP_TO_SAVED_POSITION = 0x100


def main():
    decomp = sys.argv[1]
    headers = open(os.path.join(decomp, 'include', 'data', 'map_headers.h'), encoding='utf-8').read()
    events_of, banks_of = {}, collections.defaultdict(set)
    for name, block in re.findall(r'\[(MAP_HEADER_\w+)\] = \{(.*?)\n    \},', headers, re.S):
        fields = dict(re.findall(r'\.(\w+) = (\w+)', block))
        if 'eventsArchiveID' in fields:
            events_of[name] = fields['eventsArchiveID']
        if 'scriptsArchiveID' in fields and 'msgArchiveID' in fields:
            banks_of[fields['scriptsArchiveID']].add(fields['msgArchiveID'])
    bad = []

    warps = {}
    for events in set(events_of.values()):
        path = os.path.join(decomp, 'res', 'field', 'events', events + '.json')
        if os.path.exists(path):
            warps[events] = json.load(open(path, encoding='utf-8')).get('warp_events', [])
    for events, ws in sorted(warps.items()):
        for i, w in enumerate(ws):
            dest, index = w['dest_header_id'], w['dest_warp_id']
            if index == WARP_TO_SAVED_POSITION:
                continue
            if dest not in events_of or events_of[dest] not in warps:
                bad.append(f'{events} warp {i}: destination {dest} has no events')
            elif index >= len(warps[events_of[dest]]):
                bad.append(f'{events} warp {i}: {dest} warp {index}, but it has {len(warps[events_of[dest]])}')

    bank_of_id = collections.defaultdict(set)
    for path in glob.glob(os.path.join(decomp, 'res', 'text', '*.json')):
        bank = 'TEXT_BANK_' + os.path.basename(path)[:-len('.json')].upper()
        for m in json.load(open(path, encoding='utf-8')).get('messages', []):
            bank_of_id[m['id']].add(bank)
    for scripts, banks in sorted(banks_of.items()):
        path = os.path.join(decomp, 'res', 'field', 'scripts', scripts + '.s')
        if not os.path.exists(path):
            continue
        with open(path, encoding='utf-8') as f:
            for n, line in enumerate(f, 1):
                m = TEXT_USE.match(line.split('@')[0])
                if not m or m.group(2) not in bank_of_id:
                    continue
                allowed = banks | ({'TEXT_BANK_MENU_ENTRIES'} if m.group(1) == 'AddMenuEntryImm' else set())
                if not bank_of_id[m.group(2)] & allowed:
                    bad.append(f'{scripts}.s:{n}: {m.group(2)} is in {sorted(bank_of_id[m.group(2)])}, '
                               f'but the map shows {sorted(banks)}')

    for line in bad:
        print(line)
    if bad:
        print(f'{len(bad)} problem(s)')
        sys.exit(1)
    print(f'ok: {sum(len(w) for w in warps.values())} warps lead to warps that exist, and {len(banks_of)} script '
          'files show their own map\'s texts')


if __name__ == '__main__':
    main()
