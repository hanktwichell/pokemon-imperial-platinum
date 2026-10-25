#!/usr/bin/env python3
"""Find field-script messages with more than two lines in one text box, or a line too wide for it.

The field message box shows two lines. A text moves to a new box only at a scroll (\\r) or a clear (\\f); a third line
after two \\n is printed below the box, so the player never sees it. This was found in the Battle Tower Ability
researcher's "There!" text (QoL #11), whose third line was the new Ability's name.

The box is also 27 tiles (216 pixels) wide, and a line is never wrapped: the part past the edge is cut off. A line's
width is the sum of its characters' glyph widths in the message font (decomp/res/fonts/font_message.json, indexed by the
character's code in decomp/tools/msgenc/charmap.txt, minus one; the font adds no spacing between letters). Vanilla's
widest lines are exactly 216 pixels. Placeholders such as {STRVAR_1 ...} (names, numbers) count as nothing, so this
only finds lines whose fixed text alone is too wide.

This reads every text that a field script shows through a message command (Message, NPCMessage and the like), splits it
into boxes at \\r and \\f, and reports each box with more than two lines, and each line wider than the box. A trailing
\\n doesn't count. Signposts use their own windows and aren't checked. Exits 1 if it finds any.

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
BOX_WIDTH = 27 * 8


def glyph_widths(decomp):
    """Each character's width in pixels in the message font, and the multi-character sequences the charmap encodes."""
    widths = json.load(open(os.path.join(decomp, 'res', 'fonts', 'font_message.json'), encoding='utf-8'))['glyphWidths']
    width_of = {}
    with open(os.path.join(decomp, 'tools', 'msgenc', 'charmap.txt'), encoding='utf-8') as f:
        for line in f:
            line = line.rstrip('\n')
            code, sep, chars = line.partition('=')
            if not sep or line.lstrip().startswith('//') or chars.startswith(('{', '\\x')):
                continue
            try:
                code = int(code.strip(), 16)
            except ValueError:
                continue
            if 0 < code <= len(widths):
                width_of.setdefault(chars, widths[code - 1])
    return width_of, sorted((c for c in width_of if len(c) > 1), key=len, reverse=True)


def line_width(line, width_of, sequences):
    width, i = 0, 0
    while i < len(line):
        if line[i] == '{':  # a placeholder or a control code: no fixed width
            i = line.index('}', i) + 1
            continue
        seq = next((c for c in sequences if line.startswith(c, i)), line[i])
        width += width_of.get(seq, 0)
        i += len(seq)
    return width


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
    width_of, sequences = glyph_widths(decomp)
    bad, wide = [], []
    for text_id in sorted(used):
        for box in re.split(r'[\r\f]', texts.get(text_id, '')):
            lines = box.rstrip('\n').count('\n') + 1
            if lines > 2:
                bad.append((text_id, lines, box))
                break
        for line in re.split(r'[\n\r\f]', texts.get(text_id, '')):
            width = line_width(line, width_of, sequences)
            if width > BOX_WIDTH:
                wide.append((text_id, width, line))
    for text_id, lines, box in bad:
        print(f'{text_id}: {lines} lines in one box: {box!r}')
    for text_id, width, line in wide:
        print(f'{text_id}: a line is {width} pixels wide, more than the box\'s {BOX_WIDTH}: {line!r}')
    if bad:
        print(f'{len(bad)} message(s) have a line the player can\'t see; split the box with \\r')
    if wide:
        print(f'{len(wide)} line(s) are cut off at the box\'s right edge; reword or move a line break')
    if bad or wide:
        sys.exit(1)
    print(f'ok: all {len(used)} field messages fit their boxes, in lines and in width')


if __name__ == '__main__':
    main()
