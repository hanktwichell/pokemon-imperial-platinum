#!/usr/bin/env python3
"""Write docs/CryChecklist.xlsx: which cries we have for all 1025 species (and every Mega / Primal form).

A check mark means we have it; a highlighted empty cell means we still need it.
  * #1-493 use the cries already in Platinum (decomp/res/pokemon/<species>/cry.wav).
  * #494-1025 have no cry in the ROM. Source cries come from PokeAPI's cry archive
    (https://github.com/PokeAPI/cries): cries/pokemon/latest/<id>.ogg (current games) and
    cries/pokemon/legacy/<id>.ogg (Gen V/VI-era versions, where they exist). Forms use their PokeAPI
    pokemon id (the form_id column of data/megas.csv).
  * "Converted for DS" turns green once assets/audio/cries/<dex>.wav (or <form_id>.wav) exists.

Usage: python3 tools/audio/gen_cry_checklist.py /path/to/PokeAPI/cries
(a blobless clone is enough: git clone --filter=blob:none --no-checkout https://github.com/PokeAPI/cries)
"""
import csv
import os
import subprocess
import sys

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CHECK = "✓"
FONT = "Arial"
MISSING = PatternFill("solid", start_color="F4CCCC")
HEADER = PatternFill("solid", start_color="1F3864")
THIN = Side(style="thin", color="BFBFBF")
BORDER = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)
CONVERTED_DIR = os.path.join(ROOT, "assets", "audio", "cries")
CRIES_URL = "https://github.com/PokeAPI/cries/blob/main/cries/pokemon"


def cry_listing(repo):
    files = subprocess.run(["git", "-C", repo, "ls-tree", "-r", "--name-only", "HEAD"],
                           check=True, capture_output=True, text=True).stdout.split()
    commit = subprocess.run(["git", "-C", repo, "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
    latest = {int(f.rsplit("/", 1)[1][:-4]) for f in files if f.startswith("cries/pokemon/latest/") and f.endswith(".ogg")}
    legacy = {int(f.rsplit("/", 1)[1][:-4]) for f in files if f.startswith("cries/pokemon/legacy/") and f.endswith(".ogg")}
    return latest, legacy, commit


def rom_species_with_cries():
    """Decomp species folder names that have a cry; matched to dex numbers via generated/species.txt order."""
    names = [l.strip() for l in open(os.path.join(ROOT, "decomp", "generated", "species.txt")) if l.strip()]
    have = set()
    for dex, const in enumerate(names):
        folder = const.replace("SPECIES_", "").lower()
        if 1 <= dex <= 493 and os.path.exists(os.path.join(ROOT, "decomp", "res", "pokemon", folder, "cry.wav")):
            have.add(dex)
    return have


def converted(key):
    return os.path.exists(os.path.join(CONVERTED_DIR, f"{key}.wav"))


def write_table(ws, headers, rows, widths, check_cols):
    for c, h in enumerate(headers, 1):
        cell = ws.cell(row=1, column=c, value=h)
        cell.font = Font(name=FONT, bold=True, color="FFFFFF")
        cell.fill = HEADER
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        cell.border = BORDER
    ws.row_dimensions[1].height = 32
    ws.freeze_panes = "C2"
    for r, row in enumerate(rows, 2):
        for c, value in enumerate(row, 1):
            cell = ws.cell(row=r, column=c, value=value)
            cell.font = Font(name=FONT)
            cell.border = BORDER
            if c in check_cols:
                cell.alignment = Alignment(horizontal="center")
                if value != CHECK:
                    cell.fill = MISSING
    for c, w in enumerate(widths, 1):
        ws.column_dimensions[get_column_letter(c)].width = w
    ws.auto_filter.ref = f"A1:{get_column_letter(len(headers))}{len(rows) + 1}"


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    latest, legacy, commit = cry_listing(sys.argv[1])
    in_rom = rom_species_with_cries()
    species = list(csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8")))
    megas = list(csv.DictReader(open(os.path.join(ROOT, "data", "megas.csv"), encoding="utf-8")))

    wb = Workbook()
    ws = wb.active
    ws.title = "Cries"
    rows = []
    for s in species:
        dex = int(s["dex"])
        rom = dex in in_rom
        have = rom or converted(dex)
        if rom:
            note = "Platinum's own cry is used."
        elif dex in latest:
            note = f"Convert PokeAPI latest/{dex}.ogg" + (" (a Gen V/VI legacy version also exists)" if dex in legacy else "") + "."
        else:
            note = "No source cry found yet."
        rows.append([dex, s["name"], int(s["generation"]),
                     CHECK if have else "",
                     CHECK if (rom or dex in latest) else "",
                     CHECK if dex in latest else "",
                     CHECK if dex in legacy else "",
                     note])
    write_table(ws, ["Dex", "Species", "Gen", "Cry in game", "Source cry available",
                     "PokeAPI latest cry", "PokeAPI legacy cry (Gen V/VI)", "Notes"],
                rows, [7, 16, 6, 12, 14, 13, 16, 58], check_cols={4, 5})

    wm = wb.create_sheet("Megas & forms")
    mrows = []
    for m in megas:
        fid, base_dex = int(m["form_id"]), int(m["dex"])
        base_have = base_dex in in_rom or converted(base_dex) or base_dex in latest
        own = fid in latest
        note = ("Plays the base species' cry (Platinum has no per-form cries for these); "
                + ("PokeAPI also has a form cry if we want a distinct one." if own else "no separate form cry exists."))
        mrows.append([m["form"], m["base_species"], fid, base_dex,
                      CHECK if base_have else "",
                      CHECK if own else "",
                      note])
    write_table(wm, ["Form", "Base species", "PokeAPI id", "Base dex", "Base cry available",
                     "PokeAPI form cry", "Notes"], mrows, [24, 16, 11, 9, 14, 13, 70], check_cols={5})

    su = wb.create_sheet("Summary", 0)
    su["A1"] = "Sovereign Platinum — cry checklist"
    su["A1"].font = Font(name=FONT, bold=True, size=14)
    notes = [
        "✓ = we have it. A highlighted empty cell = still needed.",
        "Cry in game: #1–493 use Platinum's own cries; #494–1025 turn ✓ once converted for the DS (assets/audio/cries/).",
        f"Source: PokeAPI cry archive, https://github.com/PokeAPI/cries @ {commit[:12]} (see CITATIONS.md).",
        "Regenerate: python3 tools/audio/gen_cry_checklist.py /path/to/PokeAPI/cries",
    ]
    for i, n in enumerate(notes, 3):
        su[f"A{i}"] = n
        su[f"A{i}"].font = Font(name=FONT, italic=True)
    hdr = 8
    for c, h in enumerate(["Range", "Species", "Cry in game", "Source cry available", "Still needed in game"], 1):
        cell = su.cell(row=hdr, column=c, value=h)
        cell.font = Font(name=FONT, bold=True, color="FFFFFF")
        cell.fill = HEADER
        cell.border = BORDER
        cell.alignment = Alignment(horizontal="center", wrap_text=True)
    n = len(rows) + 1
    ranges = [("#1–493 (Platinum)", 1, 493), ("#494–1025 (added)", 494, 1025), ("All 1025", 1, 1025)]
    for r, (label, lo, hi) in enumerate(ranges, hdr + 1):
        crit = f'Cries!$A$2:$A${n},">={lo}",Cries!$A$2:$A${n},"<={hi}"'
        values = [label,
                  f"=COUNTIFS({crit})",
                  f'=COUNTIFS({crit},Cries!$D$2:$D${n},"{CHECK}")',
                  f'=COUNTIFS({crit},Cries!$E$2:$E${n},"{CHECK}")',
                  f"=B{r}-C{r}"]
        for c, v in enumerate(values, 1):
            cell = su.cell(row=r, column=c, value=v)
            cell.font = Font(name=FONT, bold=(c == 1))
            cell.border = BORDER
    mr = hdr + len(ranges) + 2
    m_n = len(mrows) + 1
    su.cell(row=mr, column=1, value="Megas & Primal forms").font = Font(name=FONT, bold=True)
    su.cell(row=mr, column=2, value=f"=COUNTA('Megas & forms'!$A$2:$A${m_n})").font = Font(name=FONT)
    su.cell(row=mr, column=3, value=f"=COUNTIF('Megas & forms'!$E$2:$E${m_n},\"{CHECK}\")").font = Font(name=FONT)
    su.cell(row=mr, column=4, value="(base cry available)").font = Font(name=FONT, italic=True)
    su.column_dimensions["A"].width = 26
    for col in "BCDE":
        su.column_dimensions[col].width = 18

    out = os.path.join(ROOT, "docs", "CryChecklist.xlsx")
    wb.save(out)
    missing = sum(1 for r in rows if r[3] != CHECK)
    nosource = sum(1 for r in rows if r[4] != CHECK)
    print(f"wrote {out}: {len(rows)} species, {missing} still need a cry in game, {nosource} without any source; "
          f"{len(mrows)} forms")


if __name__ == "__main__":
    main()
