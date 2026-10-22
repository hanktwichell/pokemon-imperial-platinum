#!/usr/bin/env python3
"""Add species #494-1025 to the Easy Chat word lists in decomp/src/easy_chat_word_list.c (milestone E6 step 2).

A species' Easy Chat word is its species ID, and every other word is offset by the text bank sizes
(include/applications/easy_chat/defs.h), so the existing list entries stay valid as the species bank grows. What the
new species need is a place in the lists the Easy Chat screen browses:
  sPokemonWords   group mode, "POKéMON" (names A-L)
  sPokemon2Words  group mode, "POKéMON 2" (names M-Z)
  sAWords..sZWords  ABC mode, every word starting with that letter
Platinum keeps all of these in display-name order (the in-game name, character by character), so each new species is
inserted after the last entry whose name sorts at or before its own. Platinum's entries are never moved.

Running it again changes nothing (species already in a list are skipped).

Usage: python3 tools/engine/gen_easy_chat_species.py [--check]
  --check  exit 1 if the file would change (nothing is written)
"""
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DECOMP = os.path.join(ROOT, "decomp")
WORD_LIST = os.path.join(DECOMP, "src", "easy_chat_word_list.c")
FIRST, LAST = 494, 1025

# Text banks behind the XXX_WORD(Bank_Text_Entry) macros.
BANK_FILES = ["trainer_words", "people_words", "greetings", "lifestyle_words", "feelings", "tough_words",
              "union_words"]


def species_names():
    """Return ({const: display name}, [new species consts in ID order])."""
    consts = [l.strip() for l in open(os.path.join(DECOMP, "generated", "species.txt")) if l.strip()]
    names = {}
    for c in consts:
        path = os.path.join(DECOMP, "res", "pokemon", c[len("SPECIES_"):].lower(), "data.json")
        if os.path.exists(path):
            pd = json.load(open(path, encoding="utf-8")).get("pokedex_data", {})
            if "en" in pd:
                names[c] = pd["en"]["name"]
    return names, consts[FIRST:LAST + 1]


def word_names(species):
    """Map every word token used in the lists to its in-game text."""
    names = dict(species)
    for bank in BANK_FILES:
        for m in json.load(open(os.path.join(DECOMP, "res", "text", bank + ".json"), encoding="utf-8"))["messages"]:
            names[m["id"]] = m.get("en_US", "")
    abilities = json.load(open(os.path.join(DECOMP, "res", "text", "ability_names_uppercase.json"),
                               encoding="utf-8"))["messages"]
    ability_consts = [l.strip() for l in open(os.path.join(DECOMP, "generated", "abilities.txt")) if l.strip()]
    for c, m in zip(ability_consts, abilities):
        names[c] = m["en_US"]
    return names


def token_name(token, names):
    m = re.fullmatch(r"\w+_WORD\((\w+)\)", token)
    inner = m.group(1) if m else token
    if inner in names:
        return names[inner]
    if inner.startswith("MOVE_"):
        path = os.path.join(DECOMP, "res", "moves", inner[len("MOVE_"):].lower(), "data.json")
        return json.load(open(path, encoding="utf-8"))["name"].upper()
    if inner.startswith("TYPE_"):
        return inner[len("TYPE_"):]
    raise KeyError(f"no name for Easy Chat word {token}")


def sort_key(name):
    # Platinum's lists compare names character by character, with ’ before the letters (I’VE ARRIVED, ICE) as in
    # ASCII; É sorts with E (FLABÉBÉ).
    return name.upper().replace("’", "'").replace("É", "E")


def list_span(src, name):
    m = re.search(r"static const u16 " + name + r"\[\] = \{\n(.*?)\n\};", src, re.S)
    if not m:
        raise SystemExit(f"{name} not found in {WORD_LIST}")
    return m.start(1), m.end(1)


def insert(src, list_name, new_species, names):
    """Insert new_species into list_name in display-name order; return the new source."""
    start, end = list_span(src, list_name)
    lines = src[start:end].split("\n")
    # One sort position per line; a DUPLICATE_WORDS group sorts by the word after its count.
    keys, i = [], 0
    while i < len(lines):
        tok = lines[i].strip().rstrip(",").split(",")[0].strip()
        if tok == "DUPLICATE_WORDS":
            count = int(lines[i].strip().rstrip(",").split(",")[1])
            group = [l.strip().rstrip(",") for l in lines[i + 1:i + 1 + count]]
            k = sort_key(token_name(group[0], names))
            keys += [k] * (count + 1)
            i += count + 1
        elif tok == "WORD_NONE":
            keys.append(None)
            i += 1
        else:
            keys.append(sort_key(token_name(tok, names)))
            i += 1
    present = {l.strip().rstrip(",") for l in lines}
    added = 0
    for sp in sorted((s for s in new_species if s not in present), key=lambda s: sort_key(names[s])):
        k = sort_key(names[sp])
        if k in keys:
            # Platinum lists same-text words once, as a DUPLICATE_WORDS group; none of the new species needs one.
            raise SystemExit(f"{sp} has the same text as a word already in {list_name}: add a DUPLICATE_WORDS group")
        # A DUPLICATE_WORDS group's lines all share one key, so this never lands inside a group.
        pos = max((j + 1 for j, kj in enumerate(keys) if kj is not None and kj < k), default=0)
        lines.insert(pos, f"    {sp},")
        keys.insert(pos, k)
        added += 1
    return src[:start] + "\n".join(lines) + src[end:], added


def main():
    check = "--check" in sys.argv[1:]
    species, new = species_names()
    missing = [s for s in new if s not in species]
    if missing:
        raise SystemExit(f"species without an English name: {missing[:5]}")
    names = word_names(species)
    src = open(WORD_LIST, encoding="utf-8").read()
    out = src

    first = lambda s: sort_key(species[s])[0]
    out, n1 = insert(out, "sPokemonWords", [s for s in new if first(s) <= "L"], names)
    out, n2 = insert(out, "sPokemon2Words", [s for s in new if first(s) >= "M"], names)
    by_letter = 0
    for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        out, n = insert(out, f"s{letter}Words", [s for s in new if first(s) == letter], names)
        by_letter += n
    others = [s for s in new if not first(s).isalpha()]
    if others:
        raise SystemExit(f"names not starting with a letter need a place in sOtherWords: {others}")

    if check:
        if out != src:
            sys.exit(f"{WORD_LIST} is out of date: run tools/engine/gen_easy_chat_species.py")
        print("Easy Chat lists up to date")
        return
    if out != src:
        with open(WORD_LIST, "w", encoding="utf-8") as f:
            f.write(out)
    print(f"added to POKéMON: {n1}, POKéMON 2: {n2}, A-Z lists: {by_letter}")


if __name__ == "__main__":
    main()
