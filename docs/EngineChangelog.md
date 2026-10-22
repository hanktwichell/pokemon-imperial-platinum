# Sovereign Platinum — Engine Changelog

Changes made to the pret/pokeplatinum decompilation in `decomp/`, newest first. Each entry lists what changed for
players and the verification that was run.


## E8 — Mega Evolution and Primal Reversion (in progress)

- **The 99 Mega and Primal forms exist as data** (step 1). `tools/engine/gen_forms.py` reads `data/megas.csv` and
  writes each form's stats, types and ability, packed after Platinum's alternate forms (`TechnicalDesign.md` §4).
  - 42 forms have their Mega ability, because the battle engine has it. The other 57 (an ability the engine lacks, or
    none listed yet) keep the Pokémon's own ability, as `MegaEvolution.md` says.
  - Sprites and icons are the base species' until E12.
  - Verified: with the test Garchomp's form set to 1 (temporary hook), the summary showed Mega Garchomp's stats
    (Attack 182 at Lv. 50).
- **15 Mega Stones in the field** (`data/mega_stones.yaml`), placed by `tools/engine/place_mega_stones.py` in the item
  balls they replace. Verified: the Route 203 ball gives the Alakazite.
- **Fantina gives the Mega Ring** with the Relic Badge, after TM65, and sets `FLAG_SOVEREIGN_MEGA_UNLOCKED`
  (formerly `FLAG_UNUSED_0x006F`). A player who already has the badge gets it by talking to her again. Verified by
  beating Fantina with the test party.
- Test build: SELECT+L+R stops at the Alakazite ball and in front of Fantina.
- **Mega Evolution in battle** (step 2; `battle_controller_player.c`, `battle_lib.c`):
  - It happens after switches and items and before the turn's first move, fastest first. The remaining moves are then
    re-sorted, so the Mega's Speed counts that turn (Gen VII+).
  - Stats, types and (when the engine has it) the ability change. A new ability takes effect at once, like a switch-in
    (Mega Charizard Y's Drought sets the sun).
  - Once per trainer per battle; in multi and tag battles each trainer gets one. The player needs the Mega Ring
    (`FieldBattleDTO.megaUnlocked`). Wild Pokémon never Mega Evolve. Trainers' AI Mega Evolves as soon as it can.
  - The party Pokémon stays Mega while switched out. Every Mega/Primal form reverts when the battle ends
    (`BattleMain_CopyBattleSysToDTOAndFree`).
  - Messages: "<Pokémon>'s <stone> is reacting to the Mega Ring!", then "<Pokémon> has Mega Evolved into Mega
    <species>!". The new subscript is `subscript_sovereign_mega_evolution`; the sprite flashes with Platinum's
    form-change mosaic.
  - Verified in the test build:
    - The test trainer's Charizard Mega Evolved on turn 1 and Drought set the sun.
    - The player's Garchomp Mega Evolved in a wild battle (a temporary always-Mega hook stood in for the button) and
      didn't again on turn 2.
    - After the battle, Garchomp was back to its normal stats with its Garchompite.
  - Still to do: the MEGA button (until then the player can't choose Mega Evolution), Primal Reversion, the
    animation and the AI review.
- Test build: Garchomp holds a Garchompite and the Mega flag is set at new game.

## E7 part 2 — shops and icon placement (in progress)

- **Post-Champion money** (owner, decision 24). Every check is the Hall of Fame flag (`FLAG_GAME_COMPLETED`):
  - **Half price in every money shop** (`Shop_GetItemPrice`, `overlay007/shop_menu.c`): Poké Marts, specialty
    counters, decorations and Seals. Battle Point shops are unchanged.
  - **3× prize money** from post-game rematches: the Elite Four and Cynthia rematches, the eight Gym Leader rematches
    and the five Battleground trainers (`Sovereign_PostgamePrizeMultiplier`, `battle/battle_script.c`).
  - **Full sell price** for items no shop sells (`Shop_IsItemSoldInMarts`, `scrcmd_shop.c`, scanning every Poké Mart
    and specialty stock). Shop items still sell for half, so buying at half price and reselling can't make money.
  - **Survival Area Youngster** gives 3 Nuggets once a day (`FLAG_DAILY_RECEIVED_SURVIVAL_AREA_NUGGETS`, formerly
    the unused daily flag `0x0AAF`). Before the Champion he says his usual line.
  - Verified in the test build with the Hall of Fame flag set by a temporary hook: Roark paid ₽5040 (₽1680 × 3)
    while on the rematch list for the test; Protein cost ₽4900 at Veilstone; a Nugget sold for ₽10,000 and a Super
    Repel for ₽250; the Youngster gave 3 Nuggets, then said to come back tomorrow. New SELECT+L+R stop at the
    Youngster.
- **Veilstone Department Store sells the new held items** (owner request). The 2F vitamin clerk now shows a menu:
  Vitamins / Held items / Gems.
  - The stock lists are written by `gen_items.py` into `include/data/sovereign_mart_items.h`, as
    `MART_SPECIALTIES_ID_VEILSTONE_2F_HELD_ITEMS` and `_GEMS`.
  - Both count toward the store's regular-customer counter, like the other floors.
  - No map edit was needed.
- **Shop prices show 5 digits**, so ₽10,000–₽30,000 items (Ability Shield, Clear Amulet and so on) no longer show
  "₽?000". Prices stay right-aligned, so Platinum's own prices don't move.
- **Infinite Repel** (QoL #3): a key item, a custom entry in `items_sovereign.yaml` with the Max Repel icon. Using it
  from the bag turns a never-ending Repel on or off (`FLAG_SOVEREIGN_INFINITE_REPEL`, formerly `FLAG_UNUSED_0x006D`).
  `wild_encounters.c` treats it like Repel steps, so it blocks wild Pokémon weaker than the lead, just like a Repel.
  - Tested on Route 202 with Garchomp (Lv. 50) leading: a Bidoof appeared within 60 steps with it off; no encounter
    in 160 steps with it on.
- **Test tools:** a SELECT+L+R stop on Route 202's grass, and `tools/test/find_tiles.py`, which prints a map's
  grass/water/collision layout with world coordinates for warp stops.
- **Item icons are centred like Platinum's.** The art sits in the top-left 24×24 of the 32×32 icon, centred on
  (11.5, 11.5), so it's centred in the bag's preview box. Six sprites larger than 24 px are scaled to fit.
- Verified in the test build: the held-item shop list with prices, icons and descriptions (opened directly through
  a temporary hook); 5-digit prices; icons centred in the bag preview next to vanilla ones.
- Verified in game, via the new SELECT+L+R test warp: the 2F clerk shows Vitamins / Held items / Gems, and each opens
  the right stock. Lesson: `AddMenuEntryImm` stores the text ID in one byte, so menu texts with IDs over 255 (any new
  `menu_entries` text) need `AddMenuEntry`.
- **Test build: SELECT+L+R warps** to the next place in `sSovereignTestWarps` (`src/script_manager.c`), looping. For
  now the stops are the Veilstone Store 2F clerk, Route 202's grass and the Survival Area Youngster. Add stops there
  to test other map scripts.

## E9 — Sovereign trainer format

Trainers can now be written exactly: nature, ability (including Hidden Abilities), IVs, EVs, gender, shininess and
Poké Ball per Pokémon, as optional fields in the trainer JSON. Reference: `docs/TrainerFormat.md`.

- **Format:** a party that uses any of the new fields is packed as `TrainerMonSovereign` (38 bytes per Pokémon,
  `TRDATATYPE_SOVEREIGN`); every other party keeps Platinum's four layouts.
  - Platinum's 928 trainers pack byte-for-byte as before (`trdata.narc` and `trpoke.narc` compared member by member).
  - The new layout stores the whole species ID and the form separately.
- **How the game builds the Pokémon** (`src/trainer_data.c`):
  - It starts from Platinum's seeded personality value and changes it as little as possible to give the requested
    nature, gender and ability slot.
  - A Hidden Ability uses Sovereign's Hidden Ability flag; shininess comes from the OT ID.
  - IVs, EVs and form are set, then the ability and stats are recalculated.
- **Packer checks** (`tools/dataproc/src/trainerproc.c`): IVs 0–31; EVs at most 255 per stat and 510 in total; gender
  `"male"`/`"female"`; ball item IDs below 256.
- **Prize money** reads the new layout too (`BattleScript_CalcPrizeMoney`).
- **Test trainer:** `TRAINER_SOVEREIGN_TEST` ("Ace Trainer Twich"), added at the end of the trainer list with the
  unused flag after the last trainer flag. Its team is the developer team (`docs/DeveloperBattle.md`) at Lv. 100 in a
  double battle, every Pokémon in a Luxury Ball (owner), with every held item from the owner's sets (E7's Charizardite Y, Blue Orb and Assault Vest included; Mega Evolution and Primal Reversion come with E8). The test build's SELECT+R now battles
  it instead of the Route 209 rival.
- **New test tool:** `tools/test/check_trainer_party.py` starts that battle, decrypts each Pokémon the game builds for
  the opponent (hook on `Party_AddPokemon`), and compares it with the JSON, including all six stats recomputed from
  base stats, IVs, EVs and nature.
- Verified:
  - `check_trainer_party.py` passes for all six Pokémon: nature, gender, ability (two Hidden Abilities and one slot
    pick), IVs, EVs, moves, items, shininess (Garchomp, Archaludon), Luxury Balls and stats.
  - It fails as it should against a deliberately wrong JSON.
  - In battle, Charizard ♂ and Venusaur ♀ lead at Lv. 100 and a turn plays out normally.
  - The normal ROM passes `boot_smoke.py`.
  - Not checked in game: prize money for this layout, because the test party can't beat a Lv. 100 team. It reads the
    last Pokémon's level, as the other four layouts do.

## E7 step 1 — 245 new items (in progress)

- **245 items added** after Platinum's last (#468–712), from `data/items_sovereign.yaml` by
  `tools/engine/gen_items.py`:
  - held items and Gems;
  - form-change items (Memories, Drives, Nectars, Sweets, the Rusted Sword/Shield, Ogerpon's masks, the origin
    crystals, Ultranecrozium Z, Blue/Red Orb);
  - evolution items;
  - Mints, Ability Capsule and Ability Patch;
  - key items (Mega Ring, Light/Dark Stone, Prison Bottle, Scrolls, DNA Splicers, N-Solarizer/Lunarizer, Reins of
    Unity, Zygarde Cube, Reveal Glass);
  - 92 Mega Stones.
- Names, prices and descriptions come from PokeAPI. 26 Gen IX descriptions are written in the generator. Three names
  over 16 characters are shortened.
- Descriptions wrap by pixel width, measured with the message font (`res/fonts/font_message.json`). The box fits
  214 pixels: Platinum's widest line. A wrap by character count overflowed it.
- New names reach 94 pixels (Platinum's widest is 72). They fit the bag list, the "was given" message and the summary
  screen's Item field. Shop lists are checked when the shops are added.
- Icons: each new item has a bag icon converted from PokeAPI's item sprites (32×32, 4-bit, 15 colours plus
  transparent; big renders scaled to fit 24 px). They're listed in `res/items/icons/meson.build` and
  `item_icon.order` inside generator-owned blocks.
- **The 16 waiting evolutions are wired up.** Rerunning `gen_new_species.py` resolved all of them; none wait any
  more:
  - Applin → Flapple/Appletun/Dipplin; Charcadet → Armarouge/Ceruledge; Duraludon → Archaludon; Kubfu → Urshifu
    (Single Strike; Rapid Strike comes with the forms milestone); Scyther → Kleavor (Scizor kept); Ursaring →
    Ursaluna; and the rest listed in `NewSpecies.md`.
  - New species' wild held items now include the new items PokeAPI lists (e.g. Absorb Bulb).
- **Mints, Ability Capsule and Ability Patch work** (Medicine pocket; used from the bag on a party Pokémon):
  - A Mint sets the nature used for stats and shown on the summary. It's stored in 5 spare bits of the Pokémon data
    (`mintNature`). Breeding, Synchronize and flavour likes keep the personality value's nature, as in Gen VIII.
  - The Ability Capsule swaps between the two regular abilities. A spare bit (`abilitySlotSwapped`) keeps the swap
    through evolution. It has no effect on a Pokémon with its Hidden Ability or with only one regular ability.
  - The Ability Patch switches between the regular and Hidden Ability (Scarlet/Violet rules).
  - Messages: "X's stats may have changed due to the Adamant Mint!" and "X's Ability changed to Y!".
  - Code: `PartyMenu_TryUseSovereignTrainingItem` (`src/applications/party_menu/main.c`), the `BoxPokemon_GetNature`
    and `BoxPokemon_CalcAbility` overrides (`src/pokemon.c`), and `MON_DATA_MINT_NATURE` /
    `MON_DATA_ABILITY_SLOT_SWAPPED`.
- Not done yet: hold effects.
- Test build:
  - NEW GAME skips Rowan's intro (hold L to play it). Player "A", rival "Barry".
  - The new-game bag has six of the new items.
  - `drive.py` boots with a blank battery: py-desmume reloads `~/.config/desmume/<rom>.dsv`, so "fresh" boots were
    continuing an old save.
  - `new_game.sh` reaches the bedroom from a blank battery.
- Verified with the test build:
  - The new items appear in the right pockets (Mega Ring in Key Items) with names, descriptions and their icons.
  - Heavy-Duty Boots can be given to Garchomp and shows on its summary screen.
  - Using an evolution item opens the party screen, with "UNABLE!" for Pokémon it doesn't evolve.
  - Metal Alloy on Duraludon (temporary test party): ABLE!, then Duraludon evolved into Archaludon and the item was
    used up.
  - Adamant Mint on Garchomp: the message, then "Adamant nature." with Attack raised and Sp. Atk lowered on the stats
    page. Ability Patch on Garchomp: Sand Veil → Rough Skin. Ability Capsule on Archaludon: Sturdy → Stamina. Ability
    Capsule on Garchomp (Hidden Ability): "It won't have any effect."

## E6 step 2 — species #494–1025

All 1025 species are in the game, with species ID = National Dex number (Egg is 1026, Bad Egg 1027).

- **Species data:** `tools/engine/gen_new_species.py` writes the 532 Gen V–IX species from PokeAPI into
  `res/pokemon/<species>/`: stats, types, abilities with Hidden Abilities, learnsets (same rules as #1–493), egg
  data, evolutions, Pokédex text, Pal Park data, footprints (blank, as in Gen V+) and placeholder icons. It also
  writes `docs/NewSpecies.md`.
  - Names over 10 characters are shortened Gen V-style (e.g. CORVKNIGHT); the list is in the generator.
  - 16 evolutions wait for items from E7 and are marked ⏳ in `docs/NewSpecies.md`.
  - Evolutions from Platinum's species into new ones are added to the parents (e.g. Eevee → Sylveon).
    `MAX_EVOLUTIONS` is 8 so Eevee fits.
  - `gen_species_gen9.py` shares its learnset builder with the new generator. Its output is unchanged.
- **Placeholder sprites:** Unown-? until E12, for both genders (Platinum shows the female sprite for female
  Pokémon).
- **No cries yet (owner decision):** Platinum's sound archive is unchanged and the new species play silently
  (`Sound_Impl_HasCry`). Packing 532 more cries needs about 25.5 KB more sound heap at boot than the 21.4 KB that is
  free. Cries are the project's last step.
- **English-only Pokédex (owner decision):** the per-species foreign-language table is removed from the save, which
  keeps the save inside Platinum's 32 sectors (33 crashed on boot). The Route 226 foreign-entry upgrade shows no
  language tabs.
- **Easy Chat:** `tools/engine/gen_easy_chat_species.py` adds the new species to the Easy Chat lists in display-name
  order: A–L to POKéMON, M–Z to POKéMON 2, and each one to its ABC-mode letter. As in Platinum, a species appears once
  it has been seen. The word buffers are sized from the text banks, so they grow on their own (2,670 words, well below
  the 4,096 the word decoder allows).
  - `easy_chat_word_list.c` moved from the static ARM9 into the `easy_chat` overlay (owner request), since only that
    overlay uses it. The word lists load only while Easy Chat is open. This frees 9,504 bytes of RAM, which includes
    the 2,128 bytes the new species added. Every overlay starts 9.5 KB lower and keeps the same layout.
- **Test build:** Archaludon (#1018) replaces the Sharpness Gallade in the test party, and SELECT+B opens the Easy
  Chat word picker.

Verified with the test build:
- The ROM boots (`boot_smoke.py`), and in-game save and continue work.
- Archaludon's summary, stats and ability show correctly. In a wild battle it switches in, attacks, and the battle
  ends normally.
- Easy Chat (SELECT+B): POKéMON lists the seen species in order (ARCHALUDON, GALLADE, GARCHOMP). ABC mode's A
  list reads ANTICIPATION, ARCHALUDON, ARENA TRAP, ATTACK, AUNT, so the other words still decode correctly with
  the shifted word IDs. Choosing ARCHALUDON and confirming returns to the field, and a wild battle afterwards
  works.

## Rename: Pokémon Sovereign Platinum

- The project is renamed from "Imperial Platinum" to **Pokémon Sovereign Platinum** (owner, 2026-10-22).
  - ROM header title: `SOVEREIGN PL`.
  - DS menu banner: "Pokémon Sovereign Platinum".
  - Code, docs, data and tools use "Sovereign" everywhere: file names such as `sovereign_options.c` and
    `docs/*_Sovereign.md`, identifiers such as `SovereignOptions`, the test-build option
    `meson -Dsovereign_test=true`, and code comments.
- **Unchanged:**
  - The save signature (`0x20261022`).
  - Every game mechanic.
  - The GitHub repository name (`pokemon-imperial-platinum`). The owner can rename the repository on GitHub, and
    GitHub redirects the old URL.

## E6 step 1 — engine prep for 1025 species (still 493 species)

Platinum assumed its 493 species in a dozen places. Each is now tied to the species list, so adding #494–1025
(step 2) won't break them. At 493 species the game behaves the same. The plan is in `docs/SpeciesExpansionPlan.md`.

- **Form data indices:** `Pokemon_GetFormNarcIndex` now counts from `SPECIES_BAD_EGG` instead of using literal
  496–503.
- **Trainer parties:** species uses 11 bits and form 5 (it was 10 and 6), so species up to 2047 fit.
- **Cries:** the sound archive's cry slots equal the species number.
  - Shaymin-Sky's cry moves from slot 494 to 1050.
  - The BASIC/BGM/SE banks move from 700–770 to 1100–1170.
  - Tools: `tools/audio/relayout_sound_banks.py`, plus `cjson_format.py`, which edits the archive's JSON without
    reformatting it.
- **Battle Hall records:** this save block gets 2 sectors (it holds 3 streaks per species), and the recordings move up
  one sector. A compile-time check confirms the block fits.
- **4-digit Pokédex numbers:**
  - Dex numbers and counts show 4 digits from 1000 on (`DEX_NUMBER_DIGITS`). This covers the Pokédex, the summary
    screen, the main menu, the save window, the Trainer Card and the numbered species names (including Japanese
    full-width digits).
- **Oak's National Dex ratings** scale with the dex size. The tiers are unchanged at 493.
- **GTS and Global Terminal:** the "by name" letter groups come from a header that speciesproc generates
  (`species_alphabet_groups.h`) instead of hard-coded numbers. The generated values match Platinum's.
- **Contests and dress-up:** these use the Diamond/Pearl sprites only for #1–493, since that archive stops there.
- **Smaller fixes:**
  - The Wi-Fi party check uses `MAX_SPECIES` and `MAX_MOVES`.
  - The Battle Hall record list can't overflow.
  - `NUM_EXCLUDED_NATIONAL` is a checked constant, so other files can use the dex goal.

## E14 (part) — HM field moves without HM slaves, Gen VI+ breeding

- **HM field moves:** once the bag has an HM, its field move works even if no party Pokémon knows it. Badge
  requirements are unchanged.
  - Cut, Rock Smash, Strength, Rock Climb, Surf and Waterfall work from their field prompts. The first non-Egg party
    Pokémon does the move.
  - Fly and Defog are added to every party Pokémon's menu.
  - Code: `src/sovereign_field_moves.c`, the script command `FindPartySlotForFieldMove`, and the Surf and Waterfall
    checks in `field_control.c`.
  - HM moves can be forgotten when learning a new move, on the summary screen and in battle
    (`SOVEREIGN_HMS_FORGETTABLE`). This builds but hasn't been tried in-game yet.
- **Gen VI+ breeding** (`daycare.c`):
  - An Everstone passes its holder's nature every time, from either parent.
  - A Destiny Knot passes 5 IVs instead of 3. This also fixes Gen IV's bug that could pick the same stat twice.
  - Egg moves come from either parent.
  - The egg comes in the mother's Poké Ball, or the non-Ditto parent's when breeding with Ditto (Master and Cherish
    Balls become a Poké Ball).
  - A parent with its Hidden Ability passes it 60% of the time.
  - The ball and Hidden Ability are kept when the egg hatches.
- Test build:
  - The bag now has HM02 and HM05, and there's a Ditto (Adamant, Everstone, 31 IVs). The Hidden Ability Gallade holds
    a Destiny Knot, is in an Ultra Ball, and has 31 IVs.
  - SELECT+L breeds the two and hatches the egg straight away.
  - `drive.py` accepts key combos such as `SELECT+L`.

Verified in the emulator:
- Fly and Defog show in the menus of Garchomp and Turtwig, which don't know them.
- The hatched Ralts has Adamant nature, an Ultra Ball, Telepathy (its Hidden Ability), and 31 in five IVs.
- The hatch shortcut skips the normal hatch script, so the test Ralts shows no hatch place or date.

## 10b (part 1) — Pokémon Champions battle rules

Rules and sources: `docs/BattleMechanics.md`. IVs, EVs and levels are unchanged (owner decision).

- **Status conditions:**
  - Full paralysis 1/8 (was 1/4); paralysis halves Speed (was ×0.25); Electric types can't be paralysed.
  - Sleep lasts 1 turn (1/3) or 2 turns (2/3) and the Pokémon acts on the turn it wakes (was 1–4 turns).
  - Freeze thaws 1/4 of the time on each move attempt and always on the third (was 1/5, no limit).
  - Burn deals 1/16 (was 1/8). Confusion self-hit chance is 33% (was 50%).
- **Turn order is dynamic:** before each action, the Pokémon still waiting to move are re-sorted by their current
  Speed and priority.
- **Critical hits:** ×1.5 (Sniper ×2.25) instead of ×2 (×3). Odds by stage are 1/24, 1/8, 1/2 and always.
- **Multi-hit moves:** 35/35/15/15% for 2/3/4/5 hits. **Protect** in a row: 1/3 the chance each time (was 1/2).
- **Weather:** weather from Drizzle, Drought, Sand Stream and Snow Warning lasts 5 turns, or 8 with the matching rock
  (it was permanent). These abilities do nothing if that weather is already up.
- **Hail becomes Snow:** no chip damage, and Ice types get ×1.5 Defense; the messages say snow. Hail and Snowscape
  both set it.
- **Fake Out** can't be selected after the user's first turn on the field. Choosing it shows "X can use Fake Out only
  on its first turn!".
- **Champions move values** (`tools/engine/apply_champions_moves.py`): 23 power/accuracy changes, Iron Head 20% flinch,
  Moonblast 10% Sp. Atk drop, Freeze-Dry no longer freezes, Snap Trap Steel, Growth Grass.
- **Not adopted for now:** Champions' fixed PP scale with no PP Ups (Sovereign keeps PP Ups, pending the owner's call),
  and its item and move roster limits (they are roster rules, not battle rules).
- **Verified:** both ROMs build; in the test build a wild battle runs several turns (new moves, damage, AI turns) with no errors. The odds-based rules are code changes checked by review, not by in-game sampling.
- **Left for roadmap item 11:** ability and move behaviour changes. These are Healer, Run Away, Unseen Fist, Make It
  Rain, Salt Cure, Rage Fist, the slicing/punching/sound flags, terrains, and the Gen V+ ability rules (Prankster vs
  Dark, Intimidate immunities).

## E14 (part) — Repel prompt

- When a Repel, Super Repel or Max Repel wears off and the bag still has one of the same kind, the game asks
  "Use another …?" (YES/NO). YES uses it straight away. Without one, the old "Repel's effect wore off..." message shows.
- The Repel used last is saved (a spare 2 bytes at the end of the special-encounter save block); two new script
  commands, `GetLastRepel` and `UseRepel`, drive the prompt in `CommonScript_RepelsEffectWoreOff`.

Verified in the emulator (test build: a Super Repel that ends after 3 steps, 2 more in the bag): the prompt names
the Super Repel, YES prints "A used the Super Repel." and the bag goes from 2 to 1.

## E2 / E4 — Gen IX abilities and Hidden Abilities

- **All 314 abilities**, ability ID = official ability number (`tools/engine/gen_abilities.py`, from PokeAPI;
  `docs/AbilityChecklist.md`). Platinum's 123 keep their Gen IV battle behaviour. The 191 newer ones (Gen V–IX and
  the Legends: Z-A Mega abilities) have names and descriptions that show on the summary screen, but **no battle effect
  yet**; the checklist tracks which get implemented (roadmap item 11). Names over 15 characters are shortened Gen V-style
  (e.g. NeutralizingGas); 79 descriptions were rewritten by hand to fit Gen IV's two-line box.
- **Ability IDs above 255:** the ability is stored as 9 bits in the Pokémon data (the old byte plus a spare bit in
  block B), and battle, AI, day care, wild-encounter and Battle Frontier code now carry it as 16 bits.
- **Hidden Abilities:** species data has a third ability slot. A Pokémon has a "hidden ability" flag (block B, kept
  through evolution); with it set, the Pokémon uses its species' Hidden Ability. Nothing gives the flag yet (wild
  Pokémon and gifts never start with it); breeding, the Ability Patch and boss trainers will use it later.
- **Species abilities (#1–493 and forms):** Gen IX ability 1 / ability 2 / Hidden Ability
  (`tools/engine/gen_species_gen9.py`; changes listed in `docs/SpeciesGen9Changes.md`).

Verified in the emulator (test build): a Gallade with the flag shows **Justified** (its Hidden Ability) and one given
**Sharpness** (ID 292) shows it with the new description, so the 9th bit is stored and read back; the IV/EV viewer
(E14) cycles stats → IVs → EVs on the SKILLS page as intended. The normal build passes.

## E3 — Gen IX moves (data pass)

- **All 919 moves**, move ID = official move number (`tools/engine/gen_moves.py`, from PokeAPI; `docs/MoveChecklist.md`).
- **Platinum's 467 moves** keep their battle effects; 103 of them take Gen IX power, accuracy, PP, type or priority
  (e.g. Tackle 40/100, Flamethrower 90, Charm/Sweet Kiss/Moonlight → Fairy, Protect +4, Fake Out +3). Priorities all
  use the Gen IX scale, so relative order stays consistent.
- **380 new moves** (#468–919) with Gen IX type, category, power, accuracy, PP, priority, target, contact/protect/
  Magic Coat/Snatch/Mirror Move flags, a description (newest flavour text that fits Gen IV's box) and an animation
  borrowed from an existing move of the same type and category. Each is mapped to Platinum's battle effects:
  **93 exact, 76 approximate, 211 placeholder** (plain hit / does nothing). Names over 15 characters are shortened
  Gen V-style (e.g. PrecipiceBlade); the rest fit the move buttons as they are.
- **No Z-Moves or Max Moves** (owner decision): their 72 numbers are empty slots with 0 PP that nothing can learn;
  Metronome skips them.
- **Learnset format:** level-up entries are now 32-bit (`u16` move + `u16` level), up to 48 per species; the move
  reminder and day care follow.

Verified in the emulator (test build): Garchomp with Precipice Blades, Dazzling Gleam, Play Rough and Electroweb —
names, types and PP show on the move buttons, and Precipice Blades hits with its animation; the battle (AI move
table now 920 entries) runs normally. Boot smoke test passes. **Next:** E5 learnsets so species actually learn the
new moves; effect fidelity for the approximate/placeholder moves is roadmap item 11.

## Test build (never shipped)

- `meson -Dsovereign_test=true` (`tools/test/build_test_rom.sh` → `decomp/build_test/`): a new game starts with a test
  party (Garchomp 50 with Gen IX moves, Turtwig 15, Starly 5, two Gallade 30 with Justified and Sharpness) and items (3 Rare Candies, 10 Potions, 10 Poké Balls). In the overworld,
  **SELECT** starts a wild battle (Chansey Lv. 30) and **SELECT+R** a trainer battle (Barry, Route 209). Normal builds
  and CI don't define `SOVEREIGN_TEST`, so none of this is in the real game.
- Fixed while building it: the setup first allocated from a heap that doesn't exist yet at new-game start (the NULL
  write corrupted ITCM code → crash); it now uses `HEAP_ID_FIELD2`. The first battle hook used the script engine and
  landed on the wrong script; it now starts the battle from a small field task.

## E1 — Sovereign identity and save format

- **Own save signature** (`SECTOR_SIGNATURE` 0x20261022 instead of Platinum's 0x20060623). A Platinum or Renegade
  Platinum save fails the check and loads as "no save data" (the game goes straight to a new game) instead of being
  misread by Sovereign's different save layout.
- **ROM header title** `SOVEREIGN PL` and **DS menu banner** "Pokémon Sovereign Platinum". The game code stays `CPUE`
  so emulators, save tools and cheat databases still recognise the game and its save type.

Verified: a save written by the previous build loads on that build (Continue → Route 201) and is treated as empty by
the new build (new game starts); header and banner read back from the ROM; boot smoke test passes.

## E14 (part) — IV/EV viewer on the summary screen

- On the **SKILLS** page, **SELECT** cycles the six numbers between stats, IVs and EVs. The page title changes to
  "POKéMON SKILLS" / "POKéMON IVs" / "POKéMON EVs"; the view is kept while switching Pokémon or pages.

Verified in the emulator (test build, with the E2/E4 pass): SELECT cycles the SKILLS page through stats, IVs and EVs, with the title changing to match.

## E13 — Options additions (level cap, Infinite Rare Candy, party Exp. Share, music volume)

- **Options menu:** four new rows in the normal OPTIONS list, after FRAME: **LEVEL CAP** (ON/OFF, default OFF),
  **INF. CANDY** (ON/OFF, default OFF; grayed out and locked while the level cap is OFF), **EXP. SHARE** (ON/OFF,
  default ON) and **MUSIC** (0–100 in steps of 5, shown as a number and a bar; hold left/right to move quickly, and the
  volume changes as you move it). The list now has 11 rows and scrolls, with arrows at the right of the title bar
  when there are rows above or below. The YES/NO confirmation covers the new settings too.
- **Save data:** the settings live in `SovereignOptions` (`include/sovereign_options.h`), a 16-bit field in the player
  save block that used to be padding, so the save size is unchanged.
- **Level cap** (`src/level_cap.c`, table `include/data/level_caps.h` generated from `data/level_caps.yaml` by
  `tools/engine/gen_level_caps.py`): the cap is the ace level of the first big fight not yet beaten, checked with the
  trainers' defeated flags. While on, party Pokémon at the cap gain no EXP (EVs are still gained), and EXP that would
  go past the cap stops at the cap. Rare Candies can't raise a Pokémon past it.
- **Infinite Rare Candy:** Rare Candies aren't removed from the bag when used. Turning the option on gives one Rare Candy
  if the bag has none.
- **Party Exp. Share:** when on, every non-fainted party member gets EXP from each battle: Pokémon that battled get the
  full amount, the rest get half. When off, the held Exp. Share works as in vanilla.
- **Music volume:** scales the field and BGM players (`Sound_SetMusicVolumePercent`); sound effects and cries are
  unaffected. Applied at boot from the save and whenever the option changes.

Verified in the emulator (`tools/test/drive.py`) on a new save: the list scrolls and wraps in both directions with
the right arrows; the toggles work; INF. CANDY stays locked while the level cap is OFF and turns off with it; the
slider moves; YES saves and reopening shows the saved values; turning INF. CANDY on adds a Rare Candy to the Medicine
pocket. Build passes. **In-battle check (test build, 2026-10-22):** with the cap at 16 and party Exp. Share on, one
wild battle left Garchomp (fought, Lv. 50, above the cap) at Lv. 50, took Turtwig (didn't fight) from 15 to exactly 16,
and Starly (didn't fight) from 5 to 10; a Rare Candy then raised Starly to 11 and was used up (Infinite Candy off), and
on Turtwig at the cap it said "It won't have any effect".

## Fairy type and Gen VI+ type chart

- **Fairy type added**, taking the slot of the unused `???` type (index 9), as Renegade Platinum does.
  - Type chart: Fairy beats Fighting, Dragon and Dark; is resisted by Fire, Poison and Steel. Fighting, Bug and Dark are
    resisted by Fairy; Poison and Steel beat it; Dragon has no effect on it.
  - Steel no longer resists Ghost or Dark (Gen VI change).
  - New FAIRY type icon (`res/graphics/battle/type_icons/fairy.png`), assembled from the game's own type-icon letters in
    the official Fairy pink; the type name is "FAIRY".
  - The Pokétch Move Tester chart has the same changes.
- **Curse is Ghost-type** (Gen V+). Conversion no longer treats `???`-type moves as Curse.
- Hidden Power still can't be Fairy-type (Gen VI+ rule).
- The TV "type of the day" segment can now pick Fairy.
- **Not yet:** Fairy in the Pokédex type search (the search screen has 17 slots), Battle Hall type grid, and Fairy-type
  moves and Pokémon (these arrive with the Gen IX move and species data, milestones E3/E5).

Verified: `tools/test/check_type_chart.py` (all 324 matchups in both charts match PokeAPI's official chart; vanilla fails
with 40 mismatches), build, headless boot test.

## E0 — decomp import

- pret/pokeplatinum @ `76620288` vendored as `decomp/`. The build reproduces the retail US Rev 1 ROM
  (sha1 `0862ec35b24de5c7e2dcb88c9eea0873110d755c`).
- rapidjson/yyjson build overlays vendored (no wrapdb downloads needed).
