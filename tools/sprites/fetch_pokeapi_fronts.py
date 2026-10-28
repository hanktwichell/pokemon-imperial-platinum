#!/usr/bin/env python3
"""Fetch PokeAPI's 96x96 front sprites (Black/White's) for species #1-493.

For each species, from the PokeAPI sprites repository (https://github.com/PokeAPI/sprites):
  sprites/pokemon/<dex>.png               -> front.png
  sprites/pokemon/shiny/<dex>.png         -> shiny_front.png
  sprites/pokemon/female/<dex>.png        -> female_front.png         (species drawn differently as females)
  sprites/pokemon/shiny/female/<dex>.png  -> female_shiny_front.png
into assets/sprites/packs/pokeapi_fronts_bw/NNNN-Name/. Files already there are kept (delete one to fetch it again).
tools/sprites/convert_fronts96.py converts them for the game.

Usage: python3 -I tools/sprites/fetch_pokeapi_fronts.py
"""
import csv
import os
import sys
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "sprites", "packs", "pokeapi_fronts_bw")
BASE = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
FILES = {"front.png": "", "shiny_front.png": "shiny/", "female_front.png": "female/",
         "female_shiny_front.png": "shiny/female/"}
LAST = 493


def fetch(job):
    dex, folder, name, sub = job
    path = os.path.join(folder, name)
    if os.path.exists(path):
        return path, "kept"
    try:
        with urllib.request.urlopen(f"{BASE}{sub}{dex}.png", timeout=60) as r:
            data = r.read()
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return path, "none"
        raise
    with open(path, "wb") as f:
        f.write(data)
    return path, "fetched"


def main():
    rows = csv.DictReader(open(os.path.join(ROOT, "data", "species.csv"), encoding="utf-8"))
    jobs = []
    for r in rows:
        dex = int(r["dex"])
        if dex > LAST:
            continue
        folder = os.path.join(OUT, f"{dex:04}-{r['name']}")
        os.makedirs(folder, exist_ok=True)
        jobs += [(dex, folder, name, sub) for name, sub in FILES.items()]
    counts = {}
    with ThreadPoolExecutor(8) as pool:
        for path, result in pool.map(fetch, jobs):
            counts[result] = counts.get(result, 0) + 1
            if result == "none" and not os.path.basename(path).startswith("female"):
                print("missing:", os.path.relpath(path, ROOT), file=sys.stderr)
    print(", ".join(f"{v} {k}" for k, v in sorted(counts.items())))


if __name__ == "__main__":
    main()
