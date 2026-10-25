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

// When mapHeaderID is set, the next SELECT+L+R warps here instead of to the next test location (script_manager.c).
extern struct SovereignTestWarpTarget gSovereignTestWarpTarget;
// When set, the next SELECT+R battles this trainer instead of TRAINER_SOVEREIGN_TEST (field_control.c).
extern u16 gSovereignTestBattleTrainer;
// While set, a foe that loses any HP loses all of it, the player's Pokémon lose none (BtlCmd_UpdateHealthBarValue)
// and no EXP is gained (BtlCmd_CalcExpGain), so a test battle sends out every Pokémon the opponent has, with no
// level-up prompts. The battle style is Set, with no "Will you change Pokémon?" prompt (BattleSystem_GetBattleStyle),
// and the text is fast (BattleSystem_GetTextSpeed).
extern u8 gSovereignTestGodMode;
// The frames the field map has run with no task (no script, warp or battle), and the map it was on (field_system.c).
extern u32 gSovereignTestIdleFrames;
extern u32 gSovereignTestIdleMapHeaderID;
#endif

#endif // POKEPLATINUM_SOVEREIGN_TEST_H
