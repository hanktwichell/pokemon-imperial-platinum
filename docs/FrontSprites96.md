# 96×96 front sprites

**Owner, 2026-10-28:** every Pokémon's front sprite becomes PokeAPI's 96×96 front, shown at full size instead of shrunk
to 80×80 (the shrink broke the outlines of 113 form fronts and 103 species fronts: Primal Kyogre, the Megas). For
#1–493 that means PokeAPI's Black/White fronts, with a build option to go back to Platinum's own fronts (and their
second animation frame). Back sprites stay 80×80. The cartridge grows to 256 MB when the data passes 128 MB
(`tools/nitrorom` picks the size from the content; nothing to force).

Status: done in the test build (2026-10-28); **Where it stands** is at the end. This file began as the map of what had
to change, from a read-through of every place that loads or draws a battle sprite; line numbers are as of that day.

## The sprite as stored and drawn today

- A battle sprite is a 160×80 4bpp image: two 80×80 frames side by side, 6400 bytes, scrambled
  (`PokemonSprite_DecryptPt`/`DecryptDP` in `src/pokemon_sprite.c`, which assume 6400 bytes). `nitrogfx` scrambles any
  size, and `tools/scripts/make_pl_pokegra.py` packs any PNG, so the tools need no change.
- **3D path** (`PokemonSpriteManager`, `src/pokemon_sprite.c`): one 256×256 texture (32 KB) holds four sprites (slots
  0–2 stacked at rows 0/80/160, slot 3 split at x 160) and the shadows. Each screen reserves 0x8000 bytes of texture VRAM
  for it. Used by the battle, summary, Pokédex, PC, evolution, egg hatch, trade, contests, Battle Factory, starter
  choice, game opening, poffin cutscene, capsule menu, battle recorder.
- **2D path** (`src/character_sprite.c`): copies 10×10 tiles of frame 0 into OAM, split 64×64 + strips. Used by battle
  sprite copies (move animations, Transform, Substitute), Hall of Fame, PC Hall of Fame, trade room, GTS, Mystery Gift,
  HM cut-in, Great Marsh binoculars, Battle Frontier scenes, the script Pokémon preview window, the trade BG.
- **Placement:** each species' y offset (`height.narc`, from `sprite_data.json`) is the clear rows under the art in the
  80 box; the battle adds it to the sprite's centre y. Elevation and shadow come from `pl_poke_data`.

## Design

- **Slots of 96×96, mixed sizes:** a 96×96 two-frame slot is 192×96. Keep the 256-px texture width (row stride 0x80)
  and stack four slots at rows 0/96/192/288, shadows at x 192–255. Declare 256×512, use 384 rows: 0xC000 (48 KB).
- **The loader reads each sprite's size** from its NCGR (`charData->W/H`) and puts an 80×80 sprite centred in its slot
  (8 px each side: one tile), so every 80×80 sprite (all backs, Platinum's fronts when chosen, the DP archives the
  contests use) lands exactly where it does today.
- **Decrypt by size** (a size argument for `PokemonSprite_DecryptPt/DP`; six call sites).
- **y offsets keep meaning "relative to an 80 box centred in the slot"**, so all existing data stays valid. A 96-tall
  front with fewer than 8 clear rows under it needs a negative offset: store offsets signed (`height.narc` and the u8
  readers) or clamp such art up by a few rows.
- **2D copies:** 12×12-tile copies, OAM cells 64×64 + 32×64 + 64×32 + 32×32 (144 tiles, 4608 bytes); an 80×80 sprite
  placed at tile (1,1). Some placeholder cells come from prebuilt archives (`tradelist.narc`, `worldtrade.narc`,
  `field_cutin.narc`, the `pl_batt_bg.narc` tilemaps 262–265): build those in code or patch the archives.
- **Option for #1–493:** a meson option picks Platinum's fronts (kept untouched in `res/pokemon/<species>/`) or the
  96×96 fronts for #1–493 when packing `pl_pokegra`.

## What changes where

- **Core rework:** `src/pokemon_sprite.c` (layout, per-sprite size, centring, flips/mosaic, both coordinate tables,
  decrypt size, Spinda spots' stride and frame offset); `src/character_sprite.c` and `include/character_sprite.h`
  (12×12 regions, normalising 80×80 into 12×12, decrypt, Spinda).
- **Texture VRAM reservations 0x8000 → 0xC000:** `battle/battle_main.c:1469`, `unk_0207C63C.c:73`,
  `cutscenes/egg_hatch/graphics.c:92`, `applications/capsule_menu/graphics.c:359`, `game_opening/ov77_021D25B0.c:802`,
  `applications/pokedex/pokedex_graphics.c:689`, `choose_starter/choose_starter_app.c:86`,
  `overlay017/ov17_0223B140.c:525`, `ov17_0223CB1C.c:539`, `ov17_0224F4D4.c:549`; dress-up key 0x2800 → 0x3000
  (`overlay022/ov22_02255094.c:89, 293`); the trade sequence's 0x4000 still fits slot 0.
- **3200 → 4608-byte buffers and OAM uploads:** `battle_main.c:545`, `battle_display.c:5892`, `ov17_022413D8.c`,
  `ov17_02250744.c:202`, `hall_of_fame.c`, `pc_hall_of_fame/display.c`, `trade_room` (`defs.h:140`,
  `application.c:936, 1270`), `gts_application/screens/listing.c:551–563`, `main_menu/main_menu_util.c:69–587`,
  `overlay006/hm_cut_in.c:2090–2123`, `overlay006/great_marsh_lookout_sprite.c:135`, `overlay104/ov104_02231F74.c:796–809`,
  `render_window.c:870–1001`, `trade_sequence/main.c:493–543`, `battle_anim/battle_anim_system.c` (1657–1764, 1919,
  3950).
- **Battle animations that assume the 80 frame:** `battle_anim/script_funcs_1.c` (Snatch, partial draw, Sketch),
  `script_funcs_2.c` (Extrasensory, Drill Peck, Acid Armor, Spite, Memento), `script_funcs_3.c` (Rotate, off-screen
  moves, partial draws), `battle_anim_helpers.c:509`; the fainting partial draw (`battle_display.c:5087`).
- **Dress-up / contests** (`overlay022`): hit tests and sizes hard-coded to 80; they use the DP archives for #1–493,
  which stay 80×80.
- **Pokédex height check:** per-species scale and position data tuned for 80.

## Risks to check first (a battle-only prototype on Primal Kyogre and Mega Rayquaza)

1. **Upload time:** the manager uploads its whole texture during VBlank on every sprite change; 48 KB instead of 32 KB
   may not fit. Upload only the slot that changed.
2. **Heap:** +16 KB per manager. Tight: Battle Factory (128 KB heap), the trade phases (96 KB), the dance contest (four
   managers).
3. **OBJ VRAM:** the battle (64 KB, up to 9 sprite copies at 4608 bytes) and the Hall of Fame (about 59 of 64 KB).
4. **On screen:** evolution's letterbox is 80 px tall; a 96-wide foe at doubles x 216 runs 8 px off the right edge;
   contest results and the PC Hall of Fame space sprites 56–80 px apart.

## Where it stands

Done (test build):
- **Data.** `tools/sprites/fetch_pokeapi_fronts.py` fetches PokeAPI's fronts for #1–493 and for the forms Platinum keeps
  in `pl_otherpoke.narc` (Unown, Castform, Deoxys, Burmy, Wormadam, Cherrim, Shellos, Gastrodon, Rotom, Giratina,
  Shaymin, Arceus); `convert_fronts96.py` makes them game sprites in `res/pokemon/sovereign_fronts96/` (480 species,
  76 forms). `convert_battle_sprites.py` and `convert_form_sprites.py` keep #494–1025's and the Sovereign forms'
  fronts at 96×96. Spinda keeps Platinum's front (its spots).
- **The option.** `meson configure -Dplatinum_fronts=true` packs Platinum's own fronts for #1–493 and their forms again
  (`make_pl_pokegra.py --platinum-fronts`, `SOVEREIGN_PLATINUM_FRONTS`), with their offsets from `height.narc` and
  their second animation frame. #494–1025 and the Sovereign forms stay 96×96 either way.
- **y offsets are signed** (`LoadPokemonSpriteYOffset` and its callers): 144 of the 1473 96×96 fronts reach below
  the 80×80 box (Dialga, Ho-Oh, Zekrom, Xerneas...). The 96×96 fronts' offsets are in `sovereign_fronts96.h`,
  `sovereign_form_sprites.h` and, for #494+, `height.narc` (read as signed).
- **3D sprites** (`pokemon_sprite.c`): 96×96 slots; a partial draw (fainting, Dig...) whose side is on the 80×80 box's
  edge reaches the slot's edge.
- **2D copies** at 96×96 (`CharacterSprite_LoadPokemonSprite96`, cells `misc/pokesprite_96*` in the battle sprite
  archive for the 32K, 64K and 128K OBJ modes): battle (move animations, Transform, the BG copy), Hall of Fame, PC Hall
  of Fame, the trade cutscene, the HM cut-in, the Battle Frontier's scene sprites. Contests share the battle's.
- The dress-up reads the 80×80 box in the middle of a 96×96 sprite; evolution's band is 96 rows tall.
- The HM cut-in's band stays 80 rows tall (Platinum's art for it): a tall front loses a few rows at its edges there.

Checked in the test build (2026-10-28):
- Battle: fronts of all kinds (#1–493, #494+, Megas and Primals, Platinum's forms such as Unown, Deoxys, Rotom,
  Arceus), feet on the platform for the fronts with a negative offset (Dialga), Double Team's copies, Extrasensory's
  BG copy, fainting.
- An Elite Four run into the Hall of Fame: each Pokémon's panel and the closing group picture.
- A trade (the Meister's on Route 226): every phase, the heaps intact after it.
- Surf's HM cut-in; an evolution by Rare Candy (Charmander to Charmeleon, no heap assert); the summary screen; the
  Pokédex entry.
- A `platinum_fronts` build: #1–493 and their forms show Platinum's fronts, #494+ and the Megas 96×96.
- The Battle Factory's rental screen (a single Lv. 50 challenge): the Factory app's heap is at least 14,048 bytes free
  throughout (30,432 on the 80×80 build: the sprite manager's buffer is 16 KB bigger), and a rental's summary screen
  14,712 (31,088) before the summary screen kept one slot (below). `tools/test/heap_check.py`'s `heap_free` reads
  them.
- Screens that show one Pokémon at a time keep a texture of one slot (`PokemonSpriteManager_NewOneSlot`, 12 KB where
  the four-slot manager takes 48 and Platinum's took 32): the dress-up and its photos, and the PC boxes. Found by
  heap checks: with the four-slot manager the PC boxes' graphics heap ran out (9,336 bytes free, then a hang; 27,552
  on the 80×80 build), and a practice dance contest, which makes a dress-up photo for each of the four contestants,
  crashed as it started. The script's Pokémon preview window also makes one (and draws nothing with it): Mom's Eevee
  in Twinleaf took 60,576 bytes of the field heap (4) with the four-slot manager, 23,712 with one slot (44,188 on
  the 80×80 build).
- The poffin cutscene (a Poffin fed from the Poffin Case) and the summary screen keep one slot too. The cutscene's
  heap is 64 KB: with one slot it has 20,332 bytes free at the lowest (9,032 on the 80×80 build); the four-slot
  manager takes 36,864 bytes more, so it would run out. The summary screen (all six of the party, switching from
  one to the next) 44,516 (30,080); with four slots it had 13,692, and 14,712 in the Battle Factory's rentals.
- Practice contests (Hearthome's Contest Hall): the visual, dance and acting competitions run as on the 80×80 build.
  The lowest free space: the dress-up's heap 69,268 bytes (48,792 on the 80×80 build), the dance's 84,432 (18,968),
  the acting's 141,216 (169,980).
- A wild battle: the battle heap 315,060 bytes free at the lowest (342,620).
- A practice visual competition with Zekrom (#644, its front's y offset −6): its 96×96 front in the dress-up and on
  stage. Before the fix the dress-up kept the offset in a `u8` (250), so Zekrom was drawn below the screen there
  (`UnkStruct_ov22_022596B0`'s margins are signed now).
- The acting competition's stand-in defender (a blank copy that move animations copy from) is cleared whole; only its
  first 3,200 bytes were, so the bottom of a 96×96 copy could show leftover memory.
- The egg hatch scene (the Trainers' School Egg, an Elekid): the hatched Pokémon's 96×96 front whole, the scene's heap
  46,772 bytes free at the lowest (63,160).
- The Battle Hall (a single challenge with Garchomp, three battles): the battle room's banner shows the Pokémon's
  96×96 front whole (the Frontier scene sprite, `ov104_02232CE0`); the battle heap 243,876 bytes free at the lowest
  (265,884).
- The starter choice (Route 201's briefcase): the chosen starter's 96×96 front in its bubble; the app's heap 48,500
  bytes free at the lowest (64,884).
- The Pokédex: the list, the entry and the size page (Turtwig, Garchomp; the height check's silhouette is the 96×96
  front, at about the same height against the player's as Platinum's). Its frame (the list's and the entry's) is
  80×80 inside, Platinum's sprite size, with a 7-pixel border, and the PC boxes' Pokémon panel is the same kind of
  frame. 420 of the 2,402 96×96 front images have art past the middle 80×80 (Ho-Oh, Lugia, Zekrom, Yveltal...), up to
  8 pixels over such a border. **Owner, 2026-10-28: clip it to the frame.** `PokemonSprite_ClipToFrame` draws only what
  lies in the frame (the Pokédex's sprites, its "registered" screen and the PC boxes' panel); a scaled sprite is drawn
  whole, so the height check's silhouette keeps all its art. Checked with Ho-Oh in the Pokédex's list and entry, its
  "registered" screen after a catch, and the PC boxes' panel.
- The PC's Hall of Fame records (2026-10-28): an Elite Four run into the Hall of Fame and its save, the credits,
  CONTINUE, then Jubilife's Pokémon Center PC. Record No. 1 shows the six 96×96 fronts, with each Pokémon's page and
  its moves. The first try said the records were corrupted: another harness running at the same time had blanked the
  shared emulator battery (`tools/test/drive.py` now gives each process its own). The six places are fixed centres,
  as in Platinum: 80 pixels apart in a row, the rows at y 56 and 112. An 80×80 front there already reached the title
  bar (it ends at y 27) and the move box (it starts at y 145); a 96×96 box reaches 8 pixels further each way, so a
  tall Pokémon in the bottom row (Stonjourner) covers up to 8 more pixels of the move box's frame. Boxes overlap a
  neighbour's by up to 16 pixels across (Platinum's 80×80 boxes touched), and art at the right edge of the box placed
  at x 216 is cut by up to 8 pixels at the screen's edge.

Show the middle 80×80 of a 96×96 front (the old 2D functions; safe, art past it is cut): the script's Pokémon preview
window (an 80×80 frame; Mom's Eevee checked), the GTS listing, the Union Room trade card, the Mystery Gift card, the
Great Marsh binoculars, Rowan's intro, `ov64`.

Not run in the game:
- By their heaps' size: the capsule menu (512 KB) and the Vs. Recorder's app (`overlay062`, 340 KB) take the
  four-slot manager's 16 KB more with room to spare.

**Tall fronts fit the battle screen** (owner, 2026-10-29: "shrink the big sprites that get cut. maybe move them down
too so we don't have to shrink em as much"). With its feet on the platform, and a floating Pokémon raised by its
elevation, a front whose art fills its 96×96 box started above the screen: 66 fronts lost up to 22 rows in a single
battle (Celesteela, Yveltal), and 167 up to 30 as the second foe of a double battle (y 42). Platinum's own fronts never
did in singles (6, by up to 7 rows, as the second foe). `tools/sprites/fit_front96.py` now fits every front at the
second foe's place, the highest:
- it moves the front down, by up to 4 pixels (a standing Pokémon's feet stay above the player's HP box, at y 94), and
  a floating one also by up to half its elevation, so it still floats;
- what is left, it shrinks: it removes rows, and columns in proportion, choosing the ones most like their neighbour
  so outlines stay whole, keeps the palette indices (the shiny palette still fits) and keeps the feet where they
  were.
- 169 fronts changed: 92 only move down, 77 also shrink (to 91% at the median; Celesteela and Yveltal to 81%, the
  smallest). `convert_fronts96.py`, `convert_battle_sprites.py` and `convert_form_sprites.py` call it on every 96×96
  front they write, so the fit comes back each time the fronts are converted again.
