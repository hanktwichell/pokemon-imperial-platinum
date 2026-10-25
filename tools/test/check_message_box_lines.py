#!/usr/bin/env python3
"""Find field-script messages with more than two lines in one text box.

The field message box shows two lines. A text moves to a new box only at a scroll (\\r) or a clear (\\f); a third line
after two \\n is printed below the box, so the player never sees it. This was found in the Battle Tower Ability
researcher's "There!" text (QoL #11), whose third line was the new Ability's name.

This reads every text that a field script shows through a message command (Message, NPCMessage and the like), splits it
into boxes at \\r and \\f, and reports each box with more than two lines. A trailing \\n doesn't count. Signposts use
their own windows and aren't checked. Exits 1 if it finds any.

Usage: python3 tools/test/check_message_box_lines.py decomp
"""
import glob
import json
import os
import re
import sys

MESSAGE_COMMANDS = ('Message', 'MessageInstant', 'MessageSynchronized', 'NPCMessage', 'EventMessage',
                    'PokemonCryAndMessage')
USE = re.compile(r'^\s*(' + '|'.join(MESSAGE_COMMANDS) + r')\s+(\w+)')


def text_of(message):
    text = message.get('en_US')
    return ''.join(text) if isinstance(text, list) else text


def main():
    decomp = sys.argv[1]
    texts = {}
    for path in sorted(glob.glob(os.path.join(decomp, 'res', 'text', '*.json'))):
        with open(path, encoding='utf-8') as f:
            for m in json.load(f).get('messages', []):
                text = text_of(m)
                if isinstance(text, str):
                    texts.setdefault(m['id'], text)
    used = set()
    for path in sorted(glob.glob(os.path.join(decomp, 'res', 'field', 'scripts', '*.s'))):
        with open(path, encoding='utf-8') as f:
            for line in f:
                m = USE.match(line.split('@')[0])
                if m:
                    used.add(m.group(2))
    bad = []
    for text_id in sorted(used):
        for box in re.split(r'[\r\f]', texts.get(text_id, '')):
            lines = box.rstrip('\n').count('\n') + 1
            if lines > 2:
                bad.append((text_id, lines, box))
                break
    for text_id, lines, box in bad:
        print(f'{text_id}: {lines} lines in one box: {box!r}')
    if bad:
        print(f'{len(bad)} message(s) have a line the player can\'t see; split the box with \\r')
        sys.exit(1)
    print(f'ok: all {len(used)} field messages fit their boxes')


if __name__ == '__main__':
    main()
