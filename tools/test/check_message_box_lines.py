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

Signs have two-line windows of their own (FieldMessage_AddSignpostWindow): map and arrow signs are 20 tiles (160
pixels) wide, the other kinds 27 tiles. Vanilla's widest map or arrow sign line is 159 pixels.

This reads every text that a field script shows through a message or sign command (Message, NPCMessage, ShowMapSign
and the like), splits it into boxes at \\r and \\f, and reports each box with more than two lines, and each line wider
than its window. A trailing \\n doesn't count. It also reports a message ID defined twice in one text bank (the
generated header then defines the ID's macro twice, and the second number wins). Exits 1 if it finds any.

Usage: python3 tools/test/check_message_box_lines.py decomp
"""
import glob
import json
import os
import re
import sys

MESSAGE_COMMANDS = ('Message', 'MessageInstant', 'MessageSynchronized', 'NPCMessage', 'EventMessage',
                    'PokemonCryAndMessage')
BOX_WIDTH = 27 * 8
# Each sign command's window width in pixels; message commands use BOX_WIDTH.
SIGN_WIDTHS = {'ShowMapSign': 20 * 8, 'ShowArrowSign': 20 * 8, 'ShowLandmarkSign': BOX_WIDTH,
               'ShowScrollingSign': BOX_WIDTH, 'DrawSignpostInstantMessage': BOX_WIDTH,
               'DrawSignpostScrollingMessage': BOX_WIDTH}
USE = re.compile(r'^\s*(' + '|'.join(MESSAGE_COMMANDS + tuple(SIGN_WIDTHS)) + r')\s+(\w+)')


def glyph_widths(decomp, font='font_message'):
    """Each character's width in pixels in a font (the message font by default), and the multi-character sequences
    the charmap encodes."""
    widths = json.load(open(os.path.join(decomp, 'res', 'fonts', font + '.json'), encoding='utf-8'))['glyphWidths']
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
    twice = []
    for path in sorted(glob.glob(os.path.join(decomp, 'res', 'text', '*.json'))):
        with open(path, encoding='utf-8') as f:
            ids = set()
            for m in json.load(f).get('messages', []):
                if m['id'] in ids:
                    twice.append((os.path.basename(path), m['id']))
                ids.add(m['id'])
                text = text_of(m)
                if isinstance(text, str):
                    texts.setdefault(m['id'], text)
    used = {}  # text ID -> the narrowest window it's shown in
    for path in sorted(glob.glob(os.path.join(decomp, 'res', 'field', 'scripts', '*.s'))):
        with open(path, encoding='utf-8') as f:
            for line in f:
                m = USE.match(line.split('@')[0])
                if m:
                    width = SIGN_WIDTHS.get(m.group(1), BOX_WIDTH)
                    used[m.group(2)] = min(width, used.get(m.group(2), width))
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
            if width > used[text_id]:
                wide.append((text_id, width, used[text_id], line))
    for bank, text_id in twice:
        print(f'{bank}: {text_id} is defined twice')
    for text_id, lines, box in bad:
        print(f'{text_id}: {lines} lines in one box: {box!r}')
    for text_id, width, limit, line in wide:
        print(f'{text_id}: a line is {width} pixels wide, more than its window\'s {limit}: {line!r}')
    if bad:
        print(f'{len(bad)} message(s) have a line the player can\'t see; split the box with \\r')
    if wide:
        print(f'{len(wide)} line(s) are cut off at the window\'s right edge; reword or move a line break')
    if bad or wide or twice:
        sys.exit(1)
    print(f'ok: all {len(used)} field messages and signs fit their boxes, in lines and in width; no message ID is'
          ' defined twice')


if __name__ == '__main__':
    main()
