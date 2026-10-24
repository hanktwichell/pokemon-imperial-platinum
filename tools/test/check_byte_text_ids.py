#!/usr/bin/env python3
"""Find field-script commands whose text ID doesn't fit in their one-byte argument.

Message, MessageInstant, MessageSynchronized, the signpost messages and AddMenuEntryImm store the text's index in its
archive as one byte (asm/macros/scrcmd.inc), so an index past 255 is cut to its low byte and the game shows another
text, or a blank one. This was found in decision 43's half-price menus: menu_entries.json has more than 256 entries,
and its new entries showed blank. AddMenuEntry takes the ID as a halfword and has no limit.

This maps every text ID in decomp/res/text/*.json to its index, then reports each use in decomp/res/field/scripts
whose ID is past 255. Exits 1 if it finds any.

Usage: python3 tools/test/check_byte_text_ids.py decomp
"""
import glob
import json
import os
import re
import sys

# The commands (and the macros that wrap them) whose first argument is a one-byte text ID.
BYTE_ID_COMMANDS = ('Message', 'MessageInstant', 'MessageSynchronized', 'DrawSignpostInstantMessage',
                    'DrawSignpostScrollingMessage', 'AddMenuEntryImm', 'ShowMapSign', 'ShowArrowSign',
                    'ShowLandmarkSign', 'ShowScrollingSign', 'NPCMessage', 'EventMessage', 'PokemonCryAndMessage')
USE = re.compile(r'^\s*(' + '|'.join(BYTE_ID_COMMANDS) + r')\s+(\w+)')


def main():
    decomp = sys.argv[1]
    index = {}
    for path in sorted(glob.glob(os.path.join(decomp, 'res', 'text', '*.json'))):
        with open(path, encoding='utf-8') as f:
            messages = json.load(f).get('messages', [])
        for i, m in enumerate(messages):
            index.setdefault(m['id'], i)
    bad = []
    for path in sorted(glob.glob(os.path.join(decomp, 'res', 'field', 'scripts', '*.s'))):
        with open(path, encoding='utf-8') as f:
            for n, line in enumerate(f, 1):
                m = USE.match(line.split('@')[0])
                if m and index.get(m.group(2), 0) > 255:
                    bad.append(f'{os.path.relpath(path, decomp)}:{n}: {m.group(1)} {m.group(2)} '
                               f'(index {index[m.group(2)]})')
    for b in bad:
        print(b)
    if bad:
        print(f'{len(bad)} text IDs past 255 in one-byte commands; use AddMenuEntry for menu entries, '
              'or move the text below index 256')
        sys.exit(1)
    print('ok: every one-byte text ID fits')


if __name__ == '__main__':
    main()
