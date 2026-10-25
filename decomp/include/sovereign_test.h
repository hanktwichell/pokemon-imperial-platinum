#ifndef POKEPLATINUM_SOVEREIGN_TEST_H
#define POKEPLATINUM_SOVEREIGN_TEST_H

#ifdef SOVEREIGN_TEST
// Test build only (meson -Dsovereign_test=true): hooks that test harnesses in tools/test read and write through the
// build's symbol map (build_test/main.nef.xMAP). They are in the static ARM9, so loading an overlay doesn't clear them.

struct SovereignTestWarpTarget {
    u16 mapHeaderID;
    u16 x;
    u16 z;
};

struct SovereignTestWild {
    u16 species;
    u8 form;
    u8 level;
    u16 move; // when set, the only move it knows
};

struct SovereignTestLead {
    u16 species;
    u8 form;
    u8 level;
    u16 item;
    u16 moves[4]; // a move set here replaces that slot's Fairy move (Dragon Ascent for Mega Rayquaza, Relic Song)
    u8 mega; // while set, every move the player picks has the MEGA toggle on (battle_display.c)
    u8 hpPercent; // when set, its HP starts at this percentage of its max (Zen Mode, Shields Down, Power Construct)
    u8 hiddenAbility; // when set, it has its hidden ability (Zen Mode)
};

// When mapHeaderID is set, the next SELECT+L+R warps here instead of to the next test location (script_manager.c).
extern struct SovereignTestWarpTarget gSovereignTestWarpTarget;
// When set, the next SELECT+R battles this trainer instead of TRAINER_SOVEREIGN_TEST (field_control.c).
extern u16 gSovereignTestBattleTrainer;
// When species is set, the next SELECT battles this wild Pokémon instead of a Chansey (field_control.c).
extern struct SovereignTestWild gSovereignTestWild;
// When species is set, the next test battle (SELECT or SELECT+R) first makes the party's lead this Pokémon, holding
// the item and knowing four Fairy moves: Moonblast, Dazzling Gleam, Play Rough (the moves the battle harnesses pick) and
// Draining Kiss, or the moves set instead (field_control.c).
extern struct SovereignTestLead gSovereignTestLead;
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
