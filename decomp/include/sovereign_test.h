#ifndef POKEPLATINUM_SOVEREIGN_TEST_H
#define POKEPLATINUM_SOVEREIGN_TEST_H

#ifdef SOVEREIGN_TEST
#include "generated/roaming_slots.h"

// Test build only (meson -Dsovereign_test=true): hooks that test harnesses in tools/test read and write through the
// build's symbol map (build_test/main.nef.xMAP). They are in the static ARM9, so loading an overlay doesn't clear them.

struct SovereignTestWarpTarget {
    u16 mapHeaderID;
    u16 x;
    u16 z;
    u16 dir; // when set, the way the player faces + 1 (FACE_UP + 1...); else down
};

// Vars and flags the next test warp sets first, so a harness can mark a story scene as seen or a part of the story as
// done. With no warp target set, the SELECT+L+R only sets them (a map's own local vars are cleared as the player comes
// in, so they are set after).
#define SOVEREIGN_TEST_VARS 16
#define SOVEREIGN_TEST_PARTY_ADDS 3

struct SovereignTestVar {
    u16 var; // when set: a var, or a flag (below VARS_START), which a value of 0 clears and any other sets
    u16 value;
};

// A Pokémon the next test warp adds to the party (script_manager.c), for a script to be shown.
struct SovereignTestPartyAdd {
    u16 species; // when set
    u8 form;
    u8 level;
};

// The player's party, written down on request while the field is free (field_system.c).
struct SovereignTestPartyMon {
    u16 species;
    u16 ability;
    u16 heldItem;
    u16 moves[4];
    u8 form;
    u8 level;
    u8 hasHiddenAbility;
    u8 isEgg;
};

struct SovereignTestParty {
    u8 wanted; // set by a harness: the field's next free frame writes the party down and clears it
    u8 count;
    u16 padding;
    struct SovereignTestPartyMon mons[6];
};

// The menus scripts have shown for the player's choice, and the last one's kind (scrcmd.c), so a harness can tell when
// to choose. It is counted as the script starts waiting, before the menu reads any input, so a harness that checks
// it before pressing a button never presses into a menu it hasn't seen.
enum SovereignTestMenuKind {
    SOVEREIGN_TEST_MENU_LIST = 1, // a list or multiple-choice menu: the cursor moves down the entries, A picks one
    SOVEREIGN_TEST_MENU_YES_NO, // A picks Yes, B No
    SOVEREIGN_TEST_MENU_PARTY, // the party screen, to pick a Pokémon: the cursor moves to its slot, A picks it
};

struct SovereignTestMenu {
    u32 shown;
    u32 kind;
};

struct SovereignTestScripts {
    u16 count;
    u16 first;
};

// The trainer battles the field has started (Encounter_NewVsTrainer) since a harness cleared count, so it can check
// which trainer a script battled and in which format.
#define SOVEREIGN_TEST_TRAINER_BATTLES_MAX 8

struct SovereignTestTrainerBattle {
    u16 trainerIDs[2]; // the opponents (the same one twice, or the second 0, for one trainer)
    u32 battleType; // with the trainer data's BATTLE_TYPE_DOUBLES
    u32 resultMask; // BATTLE_IN_PROGRESS until it ends, then the result (BATTLE_RESULT_WIN...)
};

struct SovereignTestTrainerBattles {
    u32 count; // all started, though only the first SOVEREIGN_TEST_TRAINER_BATTLES_MAX are written down
    struct SovereignTestTrainerBattle battles[SOVEREIGN_TEST_TRAINER_BATTLES_MAX];
};

// A survey of the wild Pokémon the real encounter code makes (SovereignTest_WildSurvey, wild_encounters.c).
#define SOVEREIGN_TEST_SURVEY_MAX 64

enum SovereignTestSurveyTerrain {
    SOVEREIGN_TEST_SURVEY_LAND = 0, // the map's grass or cave encounters
    SOVEREIGN_TEST_SURVEY_SURF,
    SOVEREIGN_TEST_SURVEY_OLD_ROD,
    SOVEREIGN_TEST_SURVEY_GOOD_ROD,
    SOVEREIGN_TEST_SURVEY_SUPER_ROD,
};

struct SovereignTestWildMon {
    u32 personality;
    u16 species;
    u8 form;
    u8 level;
};

struct SovereignTestWildSurvey {
    u8 wanted; // when set, the encounters to run
    u8 terrain; // enum SovereignTestSurveyTerrain
    u8 count; // the Pokémon made
    u8 active; // while it runs
    struct SovereignTestWildMon mons[SOVEREIGN_TEST_SURVEY_MAX];
};

struct SovereignTestWild {
    u16 species;
    u8 form;
    u8 level;
    u16 move; // when set, the only move it knows
    u8 shiny; // when set, it's shiny
    u16 item; // when set, it holds this item
    u8 balls; // when set, the player first gets this many Poké Balls (Ball Fetch)
};

// In SovereignTestLead.moves: the slot is empty.
#define SOVEREIGN_TEST_NO_MOVE 0xFFFF

struct SovereignTestLead {
    u16 species;
    u8 form;
    u8 level;
    u16 item;
    u16 moves[4]; // a move set here replaces that slot's Fairy move (Dragon Ascent for Mega Rayquaza, Relic Song)
    u8 mega; // while set, every move the player picks has the MEGA toggle on (battle_display.c)
    u8 hpPercent; // when set, its HP starts at this percentage of its max (Zen Mode, Shields Down, Power Construct)
    u8 hiddenAbility; // when set, it has its hidden ability (Zen Mode)
    u8 gender; // when set, GENDER_MALE + 1 or GENDER_FEMALE + 1: its personality gives it that gender
    u8 friendship; // when set, its friendship
    u32 personality; // when set, its personality (over gender)
    u8 shiny; // when set, a personality that makes it shiny (over personality and gender)
};

// Evolves the lead before the battle, as the evolution screen does: Pokemon_GetEvolutionTargetSpecies with this class
// and parameter (the item used, or the map's evolution method for a level-up), then Pokemon_SovereignSetEvolvedSpecies.
// The game writes the target species and the lead's species and form afterwards.
struct SovereignTestEvolve {
    u8 evolve; // when set, it evolves
    u8 evoClass; // enum EvolutionClass
    u16 param;
    u16 target; // SPECIES_NONE: it can't evolve this way
    u16 species;
    u8 form;
};

// Breeds two Pokémon in the Day Care before the battle, as Daycare_GiveEggFromDaycare does with this offspring
// personality, and hatches the Egg at once (Egg_CreateHatchedMon) as the party's lead. The game writes the Egg's
// species and form and the hatched Pokémon's afterwards.
struct SovereignTestBreed {
    u16 species[2];
    u8 forms[2];
    u8 genders[2]; // GENDER_MALE + 1 or GENDER_FEMALE + 1, or 0 for any
    u16 items[2]; // what they hold (an incense)
    u32 personality; // the Egg's
    u8 breed; // when set, it breeds
    u8 eggForm;
    u16 eggSpecies;
    u16 hatchedSpecies;
    u8 hatchedForm;
};

// The clock the game reads instead of the DS's (rtc.c), so a test can pick the time of day and the season.
struct SovereignTestClock {
    u8 hour; // when set, the hour + 1
    u8 month; // when set, the month (1 to 12)
};

struct SovereignTestPartner {
    u16 species;
    u8 form;
    u8 level;
    u16 moves[4]; // a move set here replaces that slot's move
    u8 hpPercent; // when set, its HP starts at this percentage of its max (Emergency Exit after the entry hazards)
};

// A form-change key item used on the lead from the bag (SovereignFormItem_Use, as the party menu does), before the
// battle and, the second time, after it. The game writes what each use did.
struct SovereignTestItemUse {
    u16 item;
    u8 times; // 1, or 2 (on and off again)
    u8 results[2]; // enum SovereignFormItemResult
    u8 forms[2]; // the lead's form after each use
    u8 partyCounts[2];
    u16 lastSpecies[2]; // the species in the party's last slot after each use (a fused partner coming back)
    u16 moves[2][4]; // the lead's moves after each use
};

// A var a harness watches: while var is set, the field writes its value down while it is free (field_system.c).
#define SOVEREIGN_TEST_WATCHES 8

struct SovereignTestWatch {
    u16 var;
    u16 value;
};

// A roaming slot (generated/roaming_slots.txt), written down while the field is free (field_system.c).
struct SovereignTestRoamer {
    u16 mapHeaderID; // the map it is on, or 0 when it isn't roaming
    u8 routeIndex; // its place in RoamingPokemonRoutes (roaming_pokemon.c)
    u8 level;
    u16 species;
    u16 hp; // its HP now
    u32 personality;
};

// When mapHeaderID is set, the next SELECT+L+R warps here instead of to the next test location (script_manager.c).
extern struct SovereignTestWarpTarget gSovereignTestWarpTarget;
// When wanted is set, the next SELECT+L+R runs the map's wild encounter of that terrain that many times instead, with no
// encounter roll and no battle, and records each Pokémon made (its species, form, level and personality), so a harness
// can check the forms the real encounter code gives on that map and tile.
extern struct SovereignTestWildSurvey gSovereignTestWildSurvey;
// The next SELECT+L+R sets each var or flag that is set here first, and only those with no warp target (see struct
// SovereignTestVar).
extern struct SovereignTestVar gSovereignTestVar[SOVEREIGN_TEST_VARS];
// When set, the next SELECT+R battles this trainer instead of TRAINER_SOVEREIGN_TEST (field_control.c).
extern u16 gSovereignTestBattleTrainer;
// When species is set, the next SELECT battles this wild Pokémon instead of a Chansey (field_control.c).
extern struct SovereignTestWild gSovereignTestWild;
// When species is set, the next test battle (SELECT or SELECT+R) first makes the party's lead this Pokémon, given
// the item as the party menu gives one (a held-item form takes its form) and knowing four Fairy moves: Moonblast, Dazzling Gleam, Play Rough (the moves the battle harnesses pick) and
// Draining Kiss, or the moves set instead (field_control.c).
extern struct SovereignTestLead gSovereignTestLead;
// When species is set, the party's second Pokémon becomes this one too, with its level-up moves (a fusion partner).
extern struct SovereignTestPartner gSovereignTestPartner;
// When item is set, the next test battle uses it on the lead first (see struct SovereignTestItemUse).
extern struct SovereignTestItemUse gSovereignTestItemUse;
// When evolve is set, the next test battle evolves the lead first, after the item use (see struct SovereignTestEvolve).
extern struct SovereignTestEvolve gSovereignTestEvolve;
// When breed is set, the next test battle first breeds two Pokémon and hatches the Egg (see struct SovereignTestBreed).
extern struct SovereignTestBreed gSovereignTestBreed;
// While a field is set, the game's clock reads that hour or month (see struct SovereignTestClock).
extern struct SovereignTestClock gSovereignTestClock;
// The first form a battle form change gave a Pokémon on the player's side (Mega Evolution, Primal Reversion, Ultra
// Burst...; BattleSystem_SovereignChangeBattleForm), and the lead's form once the test battle is over (field_control.c).
extern u8 gSovereignTestPlayerBattleForm;
extern u8 gSovereignTestLeadFormAfter;
// While set (god mode), test battles are one-sided, so one sends out every Pokémon the opponent has:
// - a foe that loses any HP loses all of it, and the player's Pokémon lose none (BtlCmd_UpdateHealthBarValue);
// - the player's moves ignore the foes' abilities (Battler_IgnorableAbility) and cost no PP
//   (BattleControllerPlayer_DecrementPP);
// - no EXP is gained, so there are no level-up prompts (BtlCmd_CalcExpGain);
// - the battle style is Set, with no "Will you change Pokémon?" prompt (BattleSystem_GetBattleStyle);
// - the text is fast (BattleSystem_GetTextSpeed).
extern u8 gSovereignTestGodMode;
// In god mode, a foe loses no HP in the battle's first this many turns, so the form changes at the end of a turn have one
// to happen in, and it gets to use its move (BtlCmd_UpdateHealthBarValue).
extern u8 gSovereignTestFoeSurvivesTurns;
// The frames the field map has run with no task (no script, warp or battle), and the map it was on (field_system.c).
extern u32 gSovereignTestIdleFrames;
extern u32 gSovereignTestIdleMapHeaderID;
// The party, written down when a harness asks (see struct SovereignTestParty), so it can check a gift.
extern struct SovereignTestParty gSovereignTestParty;
// When set, the next SELECT+L+R first leaves only this many Pokémon in the party (the first ones), to make room for
// gifts.
extern u8 gSovereignTestPartyKeep;
// For each one whose species is set, the next SELECT+L+R first adds that Pokémon to the party (after
// gSovereignTestPartyKeep).
extern struct SovereignTestPartyAdd gSovereignTestPartyAdd[SOVEREIGN_TEST_PARTY_ADDS];
// When set, the next SELECT+L+R first puts one of this item in the bag.
extern u16 gSovereignTestBagItem;
// When set, the next SELECT+L+R first gives the player these badges (bit 0 the Coal Badge... bit 7 the Beacon Badge).
extern u8 gSovereignTestBadges;
// The menus scripts have shown, and the last one's kind (see struct SovereignTestMenu).
extern struct SovereignTestMenu gSovereignTestMenu;
// The scripts the field has started (ScriptManager_Set: an object's, a sign's, a trigger's...) since a harness cleared
// count, and the ID of the first, so it can tell that a script that ends at once ran.
extern struct SovereignTestScripts gSovereignTestScripts;
// The trainer battles started, and how each ended (see struct SovereignTestTrainerBattles).
extern struct SovereignTestTrainerBattles gSovereignTestTrainerBattles;
// When set, scripts count every species but this one as caught (SovereignCheckSpeciesCaught), so a legendary whose
// static encounter waits on others being caught (and on its own not being caught) is on its map.
extern u16 gSovereignTestCaughtAllBut;
// When set, the rare wild encounters' roll (SovereignRareWild_TryFillEncounterTable, data/sovereign_rare_wild.yaml) is
// this minus 1 instead of a random number from 0 to 99, so a test can pick each of a map's entries.
extern u8 gSovereignTestRareWildRoll;
// The vars harnesses watch (see struct SovereignTestWatch).
extern struct SovereignTestWatch gSovereignTestWatch[SOVEREIGN_TEST_WATCHES];
// Each roaming slot: where it is and what it is (see struct SovereignTestRoamer).
extern struct SovereignTestRoamer gSovereignTestRoamers[ROAMING_SLOT_MAX];
// When set, the next SELECT+L+R first releases these roaming slots (bit 0 the first...), as the Legend Archivist's
// ActivateRoamingPokemon does.
extern u16 gSovereignTestRoamerRelease;
// When set, a wild survey (gSovereignTestWildSurvey) meets the roaming Pokémon on the map too, as a step in the grass
// would, and records them as it records the others. With SOVEREIGN_TEST_SURVEY_ROAMERS_BATTLE, the first roamer met
// is battled for real too, and the survey ends there.
#define SOVEREIGN_TEST_SURVEY_ROAMERS_BATTLE 2
extern u8 gSovereignTestSurveyRoamers;
#endif

#endif // POKEPLATINUM_SOVEREIGN_TEST_H
