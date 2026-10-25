import sys
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

C,V,RP,RN,T="Chronicle","Vanilla","Renegade (ported)","Renegade (not ported yet)","Totem trial"
# Pokemon, category, chapter/group, map, spot, level, appears when, conflict, notes
R=[
# Unova
("Cobalion",C,"Unova","Iron Island B2F, right room","(17, 1)",65,"Unova Chronicle open","None","Registeel's ruins are on B3F, a different map"),
("Terrakion",C,"Unova","Route 227, north rock pocket","(759, 258)",65,"Unova Chronicle open","None","Slythe (Renegade NPC) at (748, 280); Stakataka rare roll has no tile"),
("Virizion",C,"Unova","Eterna Forest","(80, 10)",65,"Unova Chronicle open","None","Tile check 2026-10-25: clear. Shares the forest with Xerneas (70, 14), Totem Vikavolt (22, 68) and Celebi (70, 58) with its portals (E10 part 28)"),
("Keldeo",C,"Unova","Lake Valor","(36, 14)",55,"Cobalion, Terrakion, Virizion in the party","None",""),
("Victini",C,"Unova","Vista Lighthouse, top floor","(2, 7)",55,"Unova Chronicle open","None","Tile check 2026-10-25: clear. Same floor as Totem Togedemaru (10, 7) and the Electric Master (4, 3); reachable even while both stand"),
("Meloetta",C,"Unova","Contest Hall stage (no contest)","(27, 8)",55,"Composer hears Sing","None","Contests use their own stage map (CONTEST_HALL_STAGE_ONGOING_CONTEST), so it never shows during one. Tile check 2026-10-25: clear."),
("Genesect",C,"Unova","Galactic HQ lab, back room","(34, 5)",60,"Lab scientist confesses","None","Type: Null (24, 10) follows after the catch"),
("Reshiram",C,"Unova","Fuego Ironworks building, furnace pocket","(49, 5)",70,"Light Stone in the bag","None","Inside map; Chi-Yu and Totem Salazzle are on the outside map"),
("Zekrom",C,"Unova","Route 215, the north-west loop by the big tree","(590, 578)",70,"Dark Stone in the bag, night","None","MOVED 2026-10-25 from Valley Windworks' island (236, 650), decision 34. Tile check: clear"),
("Kyurem",C,"Unova","Mt. Coronet, Iceberg Ruins doorway room","(7, 5)",70,"Reshiram and Zekrom caught; no Relicanth+Wailord pair","None","The Relicanth/Wailord pair sends the doorway to Regice's chamber; without the pair it leads here. Works as designed (checked 2026-10-25)"),
("Tornadus / Thundurus",C,"Unova","Roam the mainland","—",65,"Forces of Nature read","None","Roamers"),
("Landorus",C,"Unova","Route 228, north end of the first sand field","(782, 323)",65,"Tornadus and Thundurus in the party","None","MOVED 2026-10-24 from the Rock Peak Ruins doorway room (7, 5). Ace Trainer Jose (779, 325) looks west/east on another row"),
("Enamorus",C,"Unova","Route 224, beach field","(912, 535)",65,"Landorus caught","None","MOVED 2026-10-24 from (914, 494), beside the Flower Paradise tablet. Pecharunt (898, 526) is 16 tiles away"),
# Kalos
("Xerneas",C,"Kalos","Eterna Forest, west of the Old Chateau door","(70, 14)",70,"Kalos Chronicle open","None","Tile check 2026-10-25: clear. Same forest as Virizion (80, 10), Totem Vikavolt and Celebi (70, 58)"),
("Yveltal",C,"Kalos","Route 229, nook behind the Cut tree","(813, 426)",70,"Kalos Chronicle open","None","MOVED 2026-10-24 from Lost Tower 5F (13, 14), which holds Totem Marowak and Ho-Oh (7, 12). Next to the Reaper Cloth ball (816, 426); Gene at (827, 438)"),
("Zygarde (50%)",C,"Kalos","Wayward Cave B1F, north-west alcove","(12, 4)",70,"Xerneas and Yveltal caught","None","MOVED 2026-10-25 from (21, 4): that alcove lies under a bike bridge and can't be reached. Mira's quest is on 1F"),
("Diancie",C,"Kalos","Oreburgh Mine B2F, west nook","(2, 22)",55,"Carbink in the party","None","Tile check 2026-10-25: clear. Meltan (5, 20) and Melmetal (5, 24) within 4 tiles; none blocks the path"),
("Hoopa",C,"Kalos","Solaceon Ruins Room 6, north-west dead end","(2, 3)",55,"Prison Bottle in the bag","None","MOVED 2026-10-24 from Room 7 (5, 4), below Jirachi. The dead end holds nothing else"),
("Volcanion",C,"Kalos","Stark Mountain room 2, north-east dead-end tunnel","(73, 15)",60,"Kalos Chronicle open","None","MOVED 2026-10-24 from room 1 (34, 24), which Groudon uses. Room 2 has trainers and Buck's escort, but the tunnel is a dead end. The hidden Iron it stood on moved a tile east (2026-10-25)"),
# Alola
("Tapu Koko",C,"Alola","Route 222, east end of the sand strip","(813, 795)",65,"Alola Chronicle open","None","MOVED 2026-10-25 from (808, 795), which blocked the only way to the Quick Ball and three hidden items. Xurkitree rare roll has no tile"),
("Tapu Lele",C,"Alola","Fullmoon Island forest, grove","(13, 12)",65,"Alola Chronicle open","None","Tile check 2026-10-25: clear. Three tiles from Cresselia's / the Lati rock's tile (16, 15), which are sequenced"),
("Tapu Bulu",C,"Alola","Floaroma Meadow, north field","(24, 36)",65,"Alola Chronicle open","None","Tile check 2026-10-25: clear. Totem Ribombee (18, 43) on the same map; the Grass Master at (47, 41)"),
("Tapu Fini",C,"Alola","Route 226, beach under the cliffs","(716, 345)",65,"Alola Chronicle open","None","Tile check 2026-10-25: clear. Wyver (Renegade NPC) stands at (717, 346), diagonal to it; it can be reached even with Wyver in the way"),
("Cosmog",C,"Alola","Mt. Coronet outside north, top snowfield","(35, 21)",5,"Alola Chronicle open","None","Tile check 2026-10-25: clear. Articuno (33, 20) stands two tiles away (E10 part 27)"),
("Necrozma",C,"Alola","Wayward Cave 1F, dark north-east chamber","(70, 9)",70,"Solgaleo or Lunala caught","None","Tile check 2026-10-25: clear. Through the hidden entrance, past Mira's gate (her Renegade quest)"),
("Type: Null",C,"Alola","Galactic HQ lab","(24, 10)",40,"Genesect caught","None","Sequenced after Genesect"),
("Magearna",C,"Alola","Sunyshore Gym, Volkner's room","(11, 13)",50,"Alola Chronicle open","None","Tile check 2026-10-25: clear. Beside Volkner; it blocks neither his rematch nor the exit"),
("Marshadow",C,"Alola","Old Chateau dining area","(21, 9)",50,"Alola Chronicle open","None","Tile check 2026-10-25: clear. Totem Mimikyu (26, 10) in the same room; reachable even while it stands"),
("Zeraora",C,"Alola","Roams the mainland","—",50,"Other legends read","None","Roamer"),
("Meltan",C,"Alola","Oreburgh Mine B2F","(5, 20)",40,"Alola Chronicle open","None","Tile check 2026-10-25: clear. See Diancie"),
("Melmetal",C,"Alola","Oreburgh Mine B2F","(5, 24)",50,"Meltan caught","None","Tile check 2026-10-25: clear. See Diancie"),
# Galar
("Zacian",C,"Galar","Route 210 North, fog ledge","(542, 528)",70,"Galar Chronicle open","None","Renegade's counterpart coord event is about 60 tiles west"),
("Zamazenta",C,"Galar","Route 210 North","(540, 528)",70,"Zacian caught","None","Sequenced"),
("Eternatus",C,"Galar","Victory Road B1F, the TM59 island (Surf)","(14, 19)",70,"Zacian and Zamazenta caught","None","MOVED 2026-10-24 from Turnback Cave's Giratina room (8, 13). Shares the island with the TM59 ball (13, 18); Moltres stands on 2F (20, 3)"),
("Calyrex",C,"Galar","Celestic Town","(461, 527)",70,"Galar Chronicle open","None","Tile check 2026-10-25: clear. Off the paths to the ruins and the elder"),
("Glastrier / Spectrier",C,"Galar","Roam the mainland","—",70,"Calyrex caught","None","Roamers"),
("Kubfu",C,"Galar","Veilstone Gym","(13, 17)",10,"Galar Chronicle open","None","Tile check 2026-10-25: clear. Off every punching-bag track (the Gym's track table in src/overlay008/gym_features.c)"),
("Zarude",C,"Galar","Route 212 South, marsh","(516, 850)",60,"Galar Chronicle open","None",""),
("Regieleki",C,"Galar","Valley Windworks building","(8, 9)",65,"Regirock, Regice, Registeel in the party","None","Inside map; Zekrom and Zapdos are on the outside map"),
("Regidrago",C,"Galar","Route 228, Rock Peak Ruins chamber","(5, 6)",65,"Regirock, Regice, Registeel in the party","None","Landorus moved outside on 2026-10-24"),
# Paldea
("Wo-Chien",C,"Paldea","Route 212 North","(464, 788)",65,"Stakes 1 and 2 pulled","None","Renegade's Mansion grunts not ported yet: check their spots then"),
("Chien-Pao",C,"Paldea","Acuity Lakefront","(325, 240)",65,"Stakes 3 and 4 pulled","None",""),
("Ting-Lu",C,"Paldea","Route 214","(722, 695)",65,"Stakes 5 and 6 pulled","None",""),
("Chi-Yu",C,"Paldea","Fuego Ironworks outside","(180, 593)",65,"Stakes 7 and 8 pulled","None","Tile check 2026-10-25: clear. Totem Salazzle (181, 585) on the same map, 8 tiles north"),
("Okidogi / Munkidori / Fezandipiti",C,"Paldea","Roam the mainland","—",65,"The Loyal Three read","None","Roamers"),
("Pecharunt",C,"Paldea","Route 224","(898, 526)",60,"The Loyal Three caught","None","Enamorus (912, 535) is 16 tiles away"),
("Ogerpon",C,"Paldea","Route 211 East","(435, 531)",65,"Paldea Chronicle open","None","Entei (424, 514) is 11–17 tiles away"),
("Koraidon",C,"Paldea","Sendoff Spring","(29, 36)",70,"All ten ancient Paradox Pokémon traded","None","Cynthia's Sendoff Spring scene is before the Hall of Fame, and the Paldea Chronicle opens after it, so they never meet. Tile check 2026-10-25: clear."),
("Miraidon",C,"Paldea","Sendoff Spring","(27, 37)",70,"All ten future Paradox Pokémon traded","None","See Koraidon"),
("Terapagos",C,"Paldea","Sendoff Spring","(30, 34)",70,"Koraidon and Miraidon caught","None","See Koraidon"),
# Vanilla
("Uxie / Mesprit / Azelf",V,"Vanilla","Acuity, Verity and Valor Caverns","vanilla spots",60,"After the Distortion World","None",""),
("Dialga / Palkia",V,"Vanilla","Spear Pillar","vanilla spots",70,"Post-game, the Orb carried","None",""),
("Giratina",V,"Vanilla","Distortion World; then Turnback Cave, Giratina's room","vanilla spot",70,"Story; after a Hall of Fame if not caught","None","Eternatus moved out on 2026-10-24"),
("Heatran",V,"Vanilla","Stark Mountain room 3","vanilla spot",68,"Post-game, Buck","None","Room 3 is a different map from room 1"),
("Regigigas",V,"Vanilla","Snowpoint Temple B5F","vanilla spot",70,"After the Hall of Fame; Regirock, Regice, Registeel in the party","None","Renegade's story scene (Candice, Maylene, HM08) stands beside it before the Gym (decision 29)"),
("Cresselia",V,"Vanilla","Fullmoon Island forest, clearing","(16, 15)",68,"After the Lunar Wing quest","None","Tapu Lele (13, 12) three tiles away; Latias/Latios take the same tile only after Cresselia (sequenced). Tile check 2026-10-25: clear."),
("Darkrai",V,"Vanilla","Newmoon Island","vanilla spot",68,"Member Card (Route 217 woman, Lunar Wing)","None",""),
("Shaymin",V,"Vanilla","Flower Paradise","vanilla spot",30,"Oak's Letter (Route 224 tablet)","None","Enamorus no longer stands by the tablet"),
("Arceus",V,"Vanilla","Hall of Origin","vanilla spot",80,"Azure Flute (Foreign Building elder, 16 Plates)","None",""),
("Rotom",V,"Vanilla","Old Chateau, TV room","vanilla spot",20,"Night","None","Different room from Marshadow and Mimikyu"),
# Renegade ported
("Raikou",RP,"Renegade","Route 208, Rock Climb ledge","(391, 717)",60,"After the Distortion World","None",""),
("Entei",RP,"Renegade","Route 211 East, Rock Climb ledge","(424, 514)",60,"After the Distortion World","None","Ogerpon (435, 531) 11–17 tiles away"),
("Suicune",RP,"Renegade","Route 213, Rock Climb ledge","(689, 826)",60,"After the Distortion World","None","Tile check 2026-10-25: clear. Totem Araquanid (713, 826) on the same route, 24 tiles east"),
("Regirock / Regice / Registeel",RP,"Renegade","Rock Peak, Iceberg and Iron Ruins","vanilla statues",60,"Relicanth and Wailord in the party","None","Iceberg: the pair sends Mt. Coronet's doorway here instead of Kyurem's room (works as designed). Rock Peak is settled (Landorus moved)"),
("Latias / Latios",RP,"Renegade","Fullmoon Island forest, clearing","(16, 15)",68,"Cresselia caught, Soul Dew","None","Sequenced after Cresselia"),
("Kyogre",RP,"Renegade","Mt. Coronet B1F, lake island","(22, 36)",70,"After the Hall of Fame (Steven's Orbs)","None",""),
("Groudon",RP,"Renegade","Stark Mountain room 1","(6, 6)",70,"After the Hall of Fame (Steven's Orbs)","None","Volcanion moved to room 2 on 2026-10-24"),
("Rayquaza",RP,"Renegade","Pokémon League, below the waterfall","(847, 572)",70,"After the Hall of Fame","None","The Flying Master stands at (859, 564)"),
("Mewtwo",RP,"Renegade","Oreburgh Gate B1F, north-west pocket","(7, 9)",70,"After the Hall of Fame","None",""),
("Jirachi",RP,"Renegade","Solaceon Ruins Room 7","(5, 3)",40,"Three wishes granted","None","Hoopa moved to Room 6 on 2026-10-24"),
("Deoxys",RP,"Renegade","Veilstone City, by the meteorites","(731, 630)",70,"After the Hall of Fame, touch a meteorite","None",""),
("Mew",RP,"Renegade","Route 201, a Pachirisu's spot","(108, 846)",40,"Renegade's berry chain","None",""),
("Manaphy",RP,"Renegade","Pokémon Mansion, Mr. Backlot's office","(18, 7)",40,"After Team Galactic's siege of the Mansion; the Egg hatches","None","Beside Backlot's maid. A win or a run makes it vanish until the next visit"),
# Renegade not ported
("Articuno",RP,"Renegade","Mt. Coronet outside north, top snowfield","(33, 20)",60,"After the Distortion World (decision 33)","None","Tile check 2026-10-25: clear. E10 part 27. Two tiles from Cosmog (35, 21), on its own hidden flag; Renegade's portal was at (35, 20)"),
("Zapdos",RP,"Renegade","Valley Windworks outside, the small island north of the building (Surf)","(241, 644)",60,"After the Distortion World (decision 33)","None","E10 part 27. Beside the TM24 ball (242, 644), Renegade's portal tile. Zekrom moved to Route 215 (2026-10-25), so the islands are Zapdos's alone. Tile check: clear"),
("Moltres",RP,"Renegade","Victory Road 2F, the small room past the Strength boulders","(20, 3)",60,"After the Distortion World (decision 33)","None","Tile check 2026-10-25: clear. E10 part 27. Off the tiles the boulder puzzle for TM79 needs (column 19 and (18, 3))"),
("Lugia",RP,"Renegade","Route 220, the sandbar island at the bottom (Surf)","(190, 921)",70,"After the Hall of Fame, Silver Wing","None","E10 part 29. Oak gives the Silver Wing with Articuno, Zapdos and Moltres in the party"),
("Ho-Oh",RP,"Renegade","Lost Tower 5F, below the old women's graves","(7, 12)",70,"After the Hall of Fame, Rainbow Wing","None","Tile check 2026-10-25: clear. E10 part 29. Clear of Totem Marowak's tile (3, 4). Oak gives the Rainbow Wing with Raikou, Entei and Suicune in the party"),
("Celebi",RP,"Renegade","Eterna Forest, near the middle","(70, 58)",40,"GS Ball from Celestic Town, then the eight time portals","None","Tile check 2026-10-25: clear. E10 part 28. Its eight portals are clear of Virizion, Xerneas and Totem Vikavolt"),
# Totems
("Totem Gumshoos",T,"Totem","Route 205 South, flower bed","(197, 656)",18,"After Roark","None",""),
("Totem Ribombee",T,"Totem","Floaroma Meadow","(18, 43)",22,"After Mars (Valley Windworks)","None","Tile check 2026-10-25: clear. Tapu Bulu (24, 36) on the same map, post-game"),
("Totem Vikavolt",T,"Totem","Eterna Forest, clearing","(22, 68)",25,"After Mars","None","Tile check 2026-10-25: clear. Virizion and Xerneas post-game; far apart on the map"),
("Totem Mimikyu",T,"Totem","Old Chateau dining area","(26, 10)",31,"After Jupiter (Eterna)","None","Tile check 2026-10-25: clear. Marshadow (21, 9) in the same room, post-game"),
("Totem Marowak (Alolan)",T,"Totem","Lost Tower 5F, left of the stairs","(3, 4)",34,"Relic Badge","None","Tile check 2026-10-25: clear. Ho-Oh stands on this floor at (7, 12), after the Hall of Fame (E10 part 29). Yveltal moved out"),
("Totem Raticate (Alolan)",T,"Totem","Galactic Warehouse, lower hall","(13, 10)",37,"Relic Badge","None",""),
("Totem Lurantis",T,"Totem","Great Marsh Area 3","(54, 84)",42,"Cobble Badge (Safari Game)","None",""),
("Totem Araquanid",T,"Totem","Route 213, beach below the hotel","(713, 826)",45,"Fen Badge","None","Tile check 2026-10-25: clear. Suicune (689, 826) on the same route, 24 tiles west"),
("Totem Salazzle",T,"Totem","Fuego Ironworks outside, north of the yard","(181, 585)",48,"After Cyrus (Celestic)","None","Tile check 2026-10-25: clear. Chi-Yu (180, 593) and its stakes on the same map, post-game"),
("Totem Kommo-o",T,"Totem","Mt. Coronet 6F","(5, 13)",57,"After Saturn (Galactic HQ)","None",""),
("Totem Togedemaru",T,"Totem","Vista Lighthouse, top floor","(10, 7)",60,"After the Distortion World","None","Tile check 2026-10-25: clear. Victini (2, 7) on the same floor, post-game"),
]

wb=Workbook(); ws=wb.active; ws.title="Static encounters"
F="Arial"; thin=Side(style="thin",color="BFBFBF"); B=Border(left=thin,right=thin,top=thin,bottom=thin)
fills={"Clash":"F4B6B6","Check":"FCE4A8","None":"D5EBD0"}
catfill={C:"DDEBF7",V:"EDEDED",RP:"E2EFDA",RN:"FFF2CC",T:"F2DCDB"}
hdr=["#","Pokémon","Category","Chronicle / group","Map","Spot (x, z)","Level","Appears when","Conflict","Notes"]
ws.append(["Sovereign Platinum: static encounters, including Totems (2026-10-25)"]); ws["A1"].font=Font(name=F,bold=True,size=14)
ws.append(["Coordinates are the object's tile from the map's events file (outdoor maps: world coordinates). Conflict: Clash = must be settled; Check = shares a map, verify the tiles or timing; None = nothing found."])
ws["A2"].font=Font(name=F,italic=True,size=9)
ws.append([]); ws.append(hdr)
for c in range(1,len(hdr)+1):
    x=ws.cell(row=4,column=c); x.font=Font(name=F,bold=True,color="FFFFFF"); x.fill=PatternFill("solid",fgColor="1F3864"); x.alignment=Alignment(vertical="center",wrap_text=True); x.border=B
for i,r in enumerate(R,1):
    ws.append([i,*r])
    row=ws.max_row
    for c in range(1,len(hdr)+1):
        x=ws.cell(row=row,column=c); x.font=Font(name=F,size=10); x.border=B; x.alignment=Alignment(vertical="top",wrap_text=c in (5,8,10))
    ws.cell(row=row,column=3).fill=PatternFill("solid",fgColor=catfill[r[1]])
    k=ws.cell(row=row,column=9); k.fill=PatternFill("solid",fgColor=fills[r[7]]); k.font=Font(name=F,size=10,bold=r[7]!="None")
for c,w in enumerate([5,26,22,15,38,13,7,34,10,70],1): ws.column_dimensions[get_column_letter(c)].width=w
ws.freeze_panes="C5"; ws.auto_filter.ref=f"A4:J{ws.max_row}"

# Conflicts by map
ws2=wb.create_sheet("Conflicts by map")
ws2.append(["Map","Encounters there","Conflict","What to do"])
CL=[
("Stark Mountain","Groudon (room 1, 6, 6); Volcanion (room 2, 73, 15); Heatran (room 3)","None","Settled 2026-10-24: Volcanion moved to room 2"),
("Solaceon Ruins","Jirachi (Room 7, 5, 3); Hoopa (Room 6 north-west dead end, 2, 3)","None","Settled 2026-10-24: Hoopa moved to Room 6"),
("Turnback Cave / Victory Road B1F","Giratina (its room); Eternatus (Victory Road B1F, 14, 19)","None","Settled 2026-10-24: Eternatus moved to Victory Road B1F"),
("Route 228","Landorus (782, 323, outside); Regidrago (Rock Peak Ruins doorway room, 5, 6)","None","Settled 2026-10-24: Landorus moved to the sand field"),
("Valley Windworks outside","Zapdos (241, 644, north island); Regieleki (building)","None","Settled 2026-10-25: Zekrom moved to Route 215 (decision 34)"),
("Mt. Coronet","Kyurem (Iceberg doorway room, 7, 5); Regice's ruins; Cosmog (35, 21); Articuno (33, 20); Kyogre (B1F); Totem Kommo-o (6F)","None","Kyurem works by design: the Relicanth/Wailord pair swaps the doorway to Regice's chamber. Articuno stands two tiles from Cosmog. Tile check 2026-10-25: clear"),
("Eterna Forest","Virizion (80, 10); Xerneas (70, 14); Totem Vikavolt (22, 68); Celebi (70, 58) and its eight time portals","None","Tile check 2026-10-25: clear. Settled in E10 part 28: the portals keep Renegade's tiles, clear of all three (the one beside Totem Vikavolt moved to (24, 68))"),
("Lost Tower 5F","Totem Marowak (3, 4); Ho-Oh (7, 12)","None","Tile check 2026-10-25: clear. Settled for Yveltal (moved 2026-10-24). Ho-Oh stands at (7, 12), clear of Marowak (E10 part 29)"),
("Old Chateau dining area","Totem Mimikyu (26, 10); Marshadow (21, 9)","None","Tile check 2026-10-25: clear. Both stand only if the Totem trial was skipped. Different eras of play"),
("Vista Lighthouse top floor","Totem Togedemaru (10, 7); Victini (2, 7); Electric Master (4, 3)","None","Tile check 2026-10-25: clear. As above"),
("Fuego Ironworks outside","Totem Salazzle (181, 585); Chi-Yu (180, 593) and stakes 7–8","None","Tile check 2026-10-25: clear. As above"),
("Floaroma Meadow","Totem Ribombee (18, 43); Tapu Bulu (24, 36)","None","Tile check 2026-10-25: clear. As above"),
("Route 213","Totem Araquanid (713, 826); Suicune (689, 826)","None","Tile check 2026-10-25: clear. 24 tiles apart; fine"),
("Route 226","Tapu Fini (716, 345); Wyver (717, 346)","None","Tile check 2026-10-25: clear. Adjacent tiles; check the encounter can be reached"),
("Oreburgh Mine B2F","Diancie (2, 22); Meltan (5, 20); Melmetal (5, 24)","None","Tile check 2026-10-25: clear. Sequenced or conditional; check they don't block the path"),
("Fullmoon Island forest","Tapu Lele (13, 12); Cresselia then Latias/Latios (16, 15)","None","Tile check 2026-10-25: clear. Sequenced; crowded but fine"),
("Sendoff Spring","Koraidon (29, 36); Miraidon (27, 37); Terapagos (30, 34)","None","Tile check 2026-10-25: clear. Check Cynthia's scene tiles"),
("Wayward Cave","Zygarde (B1F 12, 4); Necrozma (1F 70, 9); Mira's quest","None","Checked 2026-10-25: Mira waits on 1F at the hidden entrance, Zygarde is on B1F"),
("Sunyshore Gym, Volkner's room","Magearna (11, 13); Volkner","None","Tile check 2026-10-25: clear. Check the rematch and exit"),
("Veilstone Gym","Kubfu (13, 17); the Gym puzzle","None","Tile check 2026-10-25: clear. Check the puzzle"),
("Celestic Town","Calyrex (461, 527); the elder, the ruins path","None","Tile check 2026-10-25: clear. Check the ruins path"),
("Contest Hall stage","Meloetta (27, 8)","None","Tile check 2026-10-25: clear. Check it never shows during a contest"),
("Route 224","Enamorus (912, 535); Pecharunt (898, 526); Shaymin tablet (908, 491)","None","Settled 2026-10-24: Enamorus moved off the tablet"),
("Route 229","Yveltal (813, 426); Gene (827, 438)","None","Yveltal's new spot (2026-10-24)"),
]
for r in CL: ws2.append(list(r))
for row in ws2.iter_rows(min_row=1,max_row=ws2.max_row):
    for x in row:
        x.font=Font(name=F,size=10,bold=x.row==1,color="FFFFFF" if x.row==1 else "000000"); x.border=B; x.alignment=Alignment(vertical="top",wrap_text=True)
        if x.row==1: x.fill=PatternFill("solid",fgColor="1F3864")
    if row[0].row>1: row[2].fill=PatternFill("solid",fgColor=fills[row[2].value])
for c,w in enumerate([32,70,10,60],1): ws2.column_dimensions[get_column_letter(c)].width=w
ws2.freeze_panes="A2"

# Legend
ws3=wb.create_sheet("Legend")
L=[("Conflict",""),("Clash","Two encounters (or an encounter and a story scene) share a small room or tile and can stand at once. Must be settled."),
("Check","Shares a map with another encounter, NPC or puzzle. Verify the tiles or timing in game."),("None","Nothing found on the map."),("",""),
("Category",""),(C,"Post-game Chronicles from the Legend Archivist (Canalave Library 2F)."),(V,"Platinum's own legendaries."),(RP,"Renegade Platinum's events already ported (E10)."),(RN,"Renegade's events still to port."),(T,"Story Totem trials (data/totem_trials.yaml). Each hides once its trial is done."),("",""),
("Sources","docs/LegendaryTriggers.md, docs/LegendaryPlacementReview.md, data/totem_trials.yaml, decomp/res/field/events/*.json")]
for a,b in L: ws3.append([a,b])
for row in ws3.iter_rows():
    for x in row: x.font=Font(name=F,size=10,bold=x.column==1 and row[1].value=="" ); x.alignment=Alignment(wrap_text=True,vertical="top")
    v=row[0].value
    if v in fills: row[0].fill=PatternFill("solid",fgColor=fills[v])
    if v in catfill: row[0].fill=PatternFill("solid",fgColor=catfill[v])
ws3.column_dimensions["A"].width=26; ws3.column_dimensions["B"].width=100
wb.save(sys.argv[1]); print(len(R),"rows")
