#!/usr/bin/env python3
"""Check that every field-script menu fits on the screen and stays clear of the message box.

A script menu (InitGlobalTextMenu or InitLocalTextMenu, then AddMenuEntryImm and ShowMenu; the list-menu versions
likewise) gets a window sized by the engine (src/overlay005/field_menu.c, CalcMenuWidth): its width is the widest
entry in the system font (decomp/res/fonts/font_system.json, indexed like the message font by the character's code
in decomp/tools/msgenc/charmap.txt, minus one) plus a 12-pixel cursor margin, rounded up to tiles. Each entry is two
tiles high; a list menu shows at most 8 at a time. The origin is the window's top-left tile; SetMenuXOriginToRight
and SetMenuYOriginToBottom make it the right or bottom edge instead (not for ShowListMenuSetWidth, which takes the
width in tiles). The frame takes one more tile on every side.

The screen is 32 by 24 tiles, so the window must lie within columns 1 to 30 and rows 1 to 22, or the frame and the
text past the edge are not shown. The field message box's frame takes rows 18 to 23, and a menu is shown with the
box still open, so a menu window must also end by row 16, or it is drawn over the box and leaves a hole in its frame
when it closes. Vanilla's lowest menus end at row 16.

A menu is followed from its Init command through the script's jumps and calls to its Show command; entries added in
branches and in called subroutines count, and the menu's size is the largest any path gives it. Entries added by
AddMenuEntry take their text from a variable, and placeholders such as {STRVAR_1 ...} count as nothing, so their
width can't be known here; -v lists them.

Usage: python3 tools/test/check_menus.py decomp [-v]
"""
import glob
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_message_box_lines import glyph_widths, line_width, text_of  # noqa: E402

SCREEN_COLUMNS = 32
MESSAGE_BOX_FRAME_TOP = 18
CURSOR_MARGIN = 12
ENTRY_ROWS = 2
LIST_MENU_MAX_DISPLAY = 8
INIT = re.compile(r'Init(Global|Local)Text(List)?Menu$')
ENTRIES = ('AddMenuEntryImm', 'AddListMenuEntry', 'AddMenuEntry')
SHOWS = ('ShowMenu', 'ShowMenuMultiColumn', 'ShowUnionRoomMenu', 'ShowListMenu', 'ShowListMenuRememberCursor',
         'ShowListMenuSetWidth')
LABEL = re.compile(r'^(\w+):')
CURSOR_X = re.compile(r'\{CURSOR_X (\d+)\}')


def statements(path):
    """The script file as (line number, command, arguments), and each label's statement index."""
    out, labels = [], {}
    with open(path, encoding='utf-8') as f:
        for n, line in enumerate(f, 1):
            line = line.split('@')[0].strip()
            m = LABEL.match(line)
            if m:
                labels[m.group(1)] = len(out)
                line = line[m.end():].strip()
            if not line or line.startswith(('.', '#')):
                continue
            command, _, args = line.partition(' ')
            out.append((n, command, [a.strip() for a in args.split(',') if a.strip()]))
    return out, labels


def menus_in(path, entry_width):
    """Each menu in a script file: its line, origin, and the largest size any path from Init to Show gives it."""
    code, labels = statements(path)

    memo, visiting = {}, set()

    def walk(pc, stack):
        """From statement pc (with stack the return points of the calls made), the paths that reach a Show:
        (most entries, widest entry, anchors set on some path, entries seen, Show commands), or None."""
        key = (pc, stack)
        if key in memo:
            return memo[key]
        if key in visiting or pc >= len(code):  # a loop adds nothing new
            return None
        visiting.add(key)
        memo[key] = result = step(pc, stack)
        visiting.discard(key)
        return result

    def branch(command, target, pc, stack):
        if command.startswith('Call'):
            return walk(target, stack + (pc,))
        return walk(target, stack)

    def step(pc, stack):
        n, command, args = code[pc]
        if command in SHOWS:
            return 0, 0, frozenset(), frozenset(), frozenset([(command, args[0] if args else '')])
        if command == 'End' or INIT.match(command):
            return None
        if command == 'Return':
            return walk(stack[-1], stack[:-1]) if stack else None
        target = next((labels[a] for a in args if a in labels), None)
        if command == 'GoTo' and target is not None:
            return walk(target, stack)
        if command == 'Call' and target is not None:
            return walk(target, stack + (pc + 1,))
        pair = opposite_test(code, labels, pc)
        if pair:  # "if set, A" then "if unset, B" on one flag: exactly one of the two runs
            (first, first_target), (second, second_target) = pair
            here = merge(branch(first, first_target, pc + 2, stack), branch(second, second_target, pc + 2, stack))
        else:
            here = walk(pc + 1, stack)
            if target is not None and command.startswith(('GoTo', 'CallIf')):
                here = merge(here, branch(command, target, pc + 1, stack))
        if here is None:
            return None
        count, widest, anchors, seen, shows = here
        if command in ENTRIES:
            return count + 1, max(widest, entry_width(command, args[0])), anchors, seen | {(command, args[0])}, shows
        if command in ('SetMenuXOriginToRight', 'SetMenuYOriginToBottom'):
            anchors |= {command}
        return count, widest, anchors, seen, shows

    callers = {}
    for pc, (n, command, args) in enumerate(code):
        if command.startswith('Call'):
            for a in args:
                callers.setdefault(a, []).append(pc + 1)
    label_at = sorted((pc, label) for label, pc in labels.items())

    for pc, (n, command, args) in enumerate(code):
        m = INIT.match(command)
        if m:
            result = walk(pc + 1, ())
            if result is None:  # set up in a subroutine: the callers add to it and show it
                routine = next((label for at, label in reversed(label_at) if at <= pc), None)
                for back in callers.get(routine, []):
                    result = merge(result, walk(pc + 1, (back,)))
            if result is not None:
                count, widest, anchors, seen, shows = result
                yield {'line': n, 'list': bool(m.group(2)), 'x': int(args[0], 0), 'y': int(args[1], 0),
                       'count': count, 'widest': widest, 'right': 'SetMenuXOriginToRight' in anchors,
                       'bottom': 'SetMenuYOriginToBottom' in anchors, 'entries': seen, 'shows': shows}


def opposite_test(code, labels, pc):
    """For a flag test at pc followed by the opposite test of the same flag, each one's command and target."""
    tests = []
    for n, command, args in code[pc:pc + 2]:
        if not command.endswith(('IfSet', 'IfUnset')) or len(args) < 2 or args[-1] not in labels:
            return None
        tests.append((command, args[0], command.endswith('IfSet'), labels[args[-1]]))
    (c1, f1, set1, t1), (c2, f2, set2, t2) = tests
    if f1 != f2 or set1 == set2 or c1.startswith('Call') != c2.startswith('Call'):
        return None
    return (c1, t1), (c2, t2)


def merge(a, b):
    if a is None or b is None:
        return a or b
    return max(a[0], b[0]), max(a[1], b[1]), a[2] | b[2], a[3] | b[3], a[4] | b[4]


def main():
    sys.setrecursionlimit(20000)
    decomp, verbose = sys.argv[1], '-v' in sys.argv[2:]
    texts = {}
    for path in glob.glob(os.path.join(decomp, 'res', 'text', '*.json')):
        for m in json.load(open(path, encoding='utf-8')).get('messages', []):
            if text_of(m) is not None:
                texts[m['id']] = text_of(m)
    width_of, sequences = glyph_widths(decomp, 'font_system')

    def entry_width(command, entry):
        """As FontManager_CalcStringWidthWithCursorControl: {CURSOR_X n} moves to n pixels from the window's left
        edge, which is n - 12 past the cursor margin."""
        if entry not in texts:
            return 0
        *_, x, rest = [None] + CURSOR_X.split(texts[entry])
        return (int(x) - CURSOR_MARGIN if x else 0) + line_width(rest, width_of, sequences)

    bad, unknown, count = [], set(), 0
    for path in sorted(glob.glob(os.path.join(decomp, 'res', 'field', 'scripts', '*.s'))):
        for menu in menus_in(path, entry_width):
            count += 1
            where = f'{os.path.basename(path)}:{menu["line"]}'
            for command, entry in menu['entries']:
                if entry not in texts:
                    unknown.add(f'{where}: {entry} (text from a variable)')
                elif '{STRVAR' in texts[entry]:
                    unknown.add(f'{where}: {entry} (a placeholder)')
            columns, width, anchored = 1, -(-(menu['widest'] + CURSOR_MARGIN) // 8), True
            for show, arg in menu['shows']:
                if show == 'ShowListMenuSetWidth':  # a set width, and the origin is used as it is
                    width, anchored = int(arg, 0), False
                elif show == 'ShowMenuMultiColumn':
                    columns = int(arg, 0)
            rows = -(-menu['count'] // columns)
            if menu['list']:
                rows = min(rows, LIST_MENU_MAX_DISPLAY)
            width, height = width * columns, rows * ENTRY_ROWS
            left = menu['x'] - width if menu['right'] and anchored else menu['x']
            top = menu['y'] - height if menu['bottom'] and anchored else menu['y']
            problems = []
            if left < 1 or left + width > SCREEN_COLUMNS - 1:
                problems.append(f'columns {left} to {left + width - 1} (the screen shows 1 to {SCREEN_COLUMNS - 2})')
            if top < 1 or top + height > MESSAGE_BOX_FRAME_TOP - 1:
                problems.append(f'rows {top} to {top + height - 1} (the message box starts at row '
                                f'{MESSAGE_BOX_FRAME_TOP}, so a menu ends by {MESSAGE_BOX_FRAME_TOP - 2})')
            if problems:
                bad.append(f'{where}: a {width}x{height}-tile menu with up to {menu["count"]} entries: '
                           + '; '.join(problems))

    if verbose:
        for line in sorted(unknown):
            print('unknown width:', line)
    for line in bad:
        print(line)
    if bad:
        print(f'{len(bad)} menu(s) of {count} do not fit')
        sys.exit(1)
    print(f'ok: all {count} field-script menus fit on the screen above the message box '
          f'({len(unknown)} entries of unknown width, from a variable or with a placeholder; -v lists them)')


if __name__ == '__main__':
    main()
