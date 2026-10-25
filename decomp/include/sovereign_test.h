#ifndef POKEPLATINUM_SOVEREIGN_TEST_H
#define POKEPLATINUM_SOVEREIGN_TEST_H

#ifdef SOVEREIGN_TEST
// Test build only (meson -Dsovereign_test=true): hooks that test harnesses in tools/test read and write through the
// build's symbol map (build_test/main.nef.xMAP). They are in the static ARM9, so loading an overlay doesn't clear them.

struct SovereignTestWarpTarget {
    u16 mapHeaderID;
    u16 x;
    u16 z;
    u16 dir; // when set, the way the player faces + 1 (FACE_UP + 1...); else down
};

struct SovereignTestWild {
    u16 species;
    u8 form;
    u8 level;
    u16 move; // when set, the only move it knows
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

// When mapHeaderID is set, the next SELECT+L+R warps here instead of to the next test location (script_manager.c).
extern struct SovereignTestWarpTarget gSovereignTestWarpTarget;
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
// - the player's moves ignore the foes' abilities (Battler_IgnorableAbility);
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
#endif

#endif // POKEPLATINUM_SOVEREIGN_TEST_H
