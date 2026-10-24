import re, json, glob, os, csv, sys
D = "/home/user/pokemon-imperial-platinum/decomp"
items = {}
for f in glob.glob(f"{D}/res/items/data/*.json"):
    j = json.load(open(f))
    const = "ITEM_" + os.path.basename(f)[:-5].upper()
    items[const] = (j["name"], j["price"], j.get("fieldPocket", ""))
H = open(f"{D}/include/data/mart_items.h").read() + open(f"{D}/include/data/sovereign_mart_items.h").read()
arrays = {m.group(1): re.findall(r"ITEM_\w+", m.group(2)) for m in re.finditer(r"u16 (\w+)\[\] = \{(.*?)\};", H, re.S)}
SHOPS = {
 "JubilifeMartSpecialties": ("Jubilife City Poké Mart (specialty counter)", ""),
 "OreburghMartSpecialties": ("Oreburgh City Poké Mart (specialty counter)", ""),
 "FloaromaMartSpecialties": ("Floaroma Town Poké Mart (specialty counter)", ""),
 "EternaMartSpecialties": ("Eterna City Poké Mart (specialty counter)", ""),
 "EternaHerbShopStock": ("Eterna City herb shop", ""),
 "HearthomeMartSpecialties": ("Hearthome City Poké Mart (specialty counter)", ""),
 "SolaceonMartSpecialties": ("Solaceon Town Poké Mart (specialty counter)", ""),
 "PastoriaMartSpecialties": ("Pastoria City Poké Mart (specialty counter)", ""),
 "VeilstoneDeptStoreStock_1F_RIGHT": ("Veilstone Dept. Store 1F (right counter)", ""),
 "VeilstoneDeptStoreStock_1F_LEFT": ("Veilstone Dept. Store 1F (left counter)", ""),
 "VeilstoneDeptStoreStock_2F_UP": ("Veilstone Dept. Store 2F (upper counter)", ""),
 "VeilstoneDeptStoreStock_2F_MID": ("Veilstone Dept. Store 2F (vitamin clerk)", ""),
 "VeilstoneDeptStoreStock_2F_HeldItems": ("Veilstone Dept. Store 2F (vitamin clerk → Held items)", ""),
 "VeilstoneDeptStoreStock_2F_Gems": ("Veilstone Dept. Store 2F (vitamin clerk → Gems)", ""),
 "VeilstoneDeptStoreStock_3F_UP": ("Veilstone Dept. Store 3F (upper counter)", ""),
 "VeilstoneDeptStoreStock_3F_DOWN": ("Veilstone Dept. Store 3F (lower counter)", ""),
 "VeilstoneDeptStoreStock_B1F_DOWN_LEFT": ("Veilstone Dept. Store B1F", ""),
 "CelesticMartSpecialties": ("Celestic Town Poké Mart (specialty counter)", ""),
 "SnowpointMartSpecialties": ("Snowpoint City Poké Mart (specialty counter)", ""),
 "CanalaveMartSpecialties": ("Canalave City Poké Mart (specialty counter)", ""),
 "SunyshoreMartSpecialties": ("Sunyshore City Poké Mart (specialty counter)", ""),
 "PokemonLeagueMartSpecialties": ("Pokémon League Poké Mart (specialty counter)", ""),
 "MegaStoneStock_Hearthome": ("Mega Stone Collector, Hearthome City (Bebe's house)", "Relic Badge"),
 "MegaStoneStock_Pastoria": ("Mega Stone Trader, Pastoria City (northeast house)", "Fen Badge"),
 "MegaStoneStock_Snowpoint": ("Mega Stone Sage, Snowpoint City (west house)", "Icicle Badge"),
 "MegaStoneStock_SurvivalArea": ("Mega Stone Curator, Survival Area (south house)", "After the Hall of Fame"),
 "SnowpointEvolutionItemStock": ("Evolution-item seller, Snowpoint City", ""),
 "RareBerryStock_Route208": ("Rare Berry seller, Route 208", ""),
}
FIXED = {"SnowpointEvolutionItemStock": 10000, "RareBerryStock_Route208": 10000}
BADGE = {1: "From the start (1 badge counts as start)", 2: "2 badges", 3: "3 badges", 4: "4 badges", 5: "5 badges", 6: "6 badges"}
sales = {}  # item -> list of (where, unlock, before, after, currency, note)
def add(it, where, unlock, before, after, cur="₽", note=""):
    sales.setdefault(it, []).append((where, unlock, before, after, cur, note))
# common Poke Mart stock
for it, b in re.findall(r"\{ (ITEM_\w+), 0x(\d+) \}", H):
    p = items[it][1]
    add(it, "Every Poké Mart (main counter)", "From the start" if int(b) <= 1 else f"{int(b)} badges", p, p // 2)
for arr, (where, unlock) in SHOPS.items():
    for it in arrays.get(arr, []):
        if it == "ITEM_END": continue
        p = FIXED.get(arr, items[it][1])
        add(it, where, unlock, p, p // 2)
# Battle Frontier (BP, not halved)
BP = dict((k, int(v)) for k, v in re.findall(r"\{ (ITEM_\w+), (\d+) \}", open(f"{D}/src/overlay007/shop_menu.c").read().split("Shop_GetItemBPPrice(ShopMenu *shopMenu, u16 itemId)\n{")[1].split("for (u32")[0]))
for it, bp in BP.items():
    add(it, "Battle Frontier, Exchange Service Corner", "After the Hall of Fame (Fight Area)", bp, bp, "BP", "Battle Points; not halved")
# Game Corner prizes (coins, not halved)
for it, c in re.findall(r"\{ (ITEM_\w+), (\d+) \}", open(f"{D}/src/scrcmd_game_corner_prize.c").read()):
    add(it, "Veilstone City Prize Exchange", "", int(c), int(c), "Coins", "Game Corner coins; not halved")
# scripted NPC sales (full price after the Hall of Fame too)
NOTE = "Scripted sale: not halved after the Hall of Fame"
add("ITEM_HONEY", "Floaroma Meadow, the honey seller", "", 100, 100, "₽", NOTE)
add("ITEM_MOOMOO_MILK", "Café Cabin (Route 210)", "", 500, 500, "₽", NOTE + "; ₽6,000 for a dozen")
for it, p in (("ITEM_FRESH_WATER", 200), ("ITEM_SODA_POP", 300), ("ITEM_LEMONADE", 350)):
    add(it, "Veilstone Dept. Store 5F vending machine", "", p, p, "₽", NOTE)
for it in ("ITEM_POMEG_BERRY", "ITEM_KELPSY_BERRY", "ITEM_QUALOT_BERRY", "ITEM_HONDEW_BERRY", "ITEM_GREPA_BERRY", "ITEM_TAMATO_BERRY"):
    add(it, "Solaceon Day Care, the rancher (bundle of 15 of each EV berry)", "", 5000, 5000, "₽", NOTE + "; the ₽5,000 buys the whole bundle")
rows = []
for it, (name, price, pocket) in items.items():
    if not name or name.startswith("?") or name.lower() in ("none", "dummy"): continue
    pk = pocket.replace("POCKET_", "").replace("_", " ").title()
    if it in sales:
        for where, unlock, b, a, cur, note in sales[it]:
            fmt = (lambda v: f"₽{v:,}") if cur == "₽" else (lambda v, c=cur: f"{v:,} {c}")
            rows.append([name, pk, "Yes", where, unlock, fmt(b), fmt(a), note])
    else:
        rows.append([name, pk, "Cannot be purchased", "", "", "", "", ""])
POCKETS = {"Tmhms": "TMs & HMs", "Battle Items": "Battle items", "Key Items": "Key items"}
merged = {}
for r in rows:
    r[1] = POCKETS.get(r[1], r[1])
    k = (r[0], r[1], r[2], r[4], r[5], r[6], r[7])
    merged.setdefault(k, []).append(r[3])
rows = []
for (name, pk, buy, unlock, b, a, note), wheres in merged.items():
    marts = sorted(w.replace(" Poké Mart (specialty counter)", "") for w in wheres if w.endswith("Poké Mart (specialty counter)"))
    others = [w for w in wheres if not w.endswith("Poké Mart (specialty counter)")]
    if marts:
        others.append(("Poké Mart specialty counter: " if len(marts) > 1 else "") + ", ".join(marts) + ("" if len(marts) > 1 else " Poké Mart (specialty counter)"))
    rows.append([name, pk, buy, "; ".join(others), unlock, b, a, note])
rows.sort(key=lambda r: (r[0].lower(), r[3]))
hdr = ["Item", "Bag pocket", "Purchasable?", "Where to buy", "Unlock", "Price before the Hall of Fame", "Price after the Hall of Fame", "Notes"]
with open(sys.argv[1], "w", newline="") as f:
    w = csv.writer(f); w.writerow(hdr); w.writerows(rows)
print(len(rows), sum(1 for r in rows if r[2] == "Yes"), "purchasable rows;", len({r[0] for r in rows if r[2]=="Yes"}), "items")
