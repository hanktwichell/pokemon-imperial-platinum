#include "macros/btlanimcmd.inc"

.data

// Sovereign (E8): Mega Evolution, after the form change. The sphere of light bursts into streaks, the new form fades in
// from white with sparkles while the Mega Evolution symbol flashes over it, it cries, and the background and the other
// battlers brighten again (sovereign_mega_evolution.s darkened them).
L_0:
    // LoadParticleResource would draw unfaded copies of the battlers while it loads, flashing the white sprite and the
    // dimmed battlers back for a few frames, so load the particle systems directly.
    LoadParticleSystem 0, judgment_spa
    LoadParticleSystem 1, status_effect_spa
    InitSpriteManager 0, 1, 1, 1, 1, 1, 0, 0
    LoadCharResObj 0, sovereign_mega_symbol_NCGR_lz
    LoadPlttRes 0, sovereign_mega_symbol_NCLR, 1
    LoadCellResObj 0, sovereign_mega_symbol_cell_NCER_lz
    LoadAnimResObj 0, sovereign_mega_symbol_anim_NANR_lz
    PlaySoundEffectL SEQ_SE_DP_REAPOKE_sseq
    CreateEmitter 0, 0, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 1, 0, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 1, 1, EMITTER_CB_SET_POS_TO_ATTACKER
    Func_SovereignFadeSprites SOVEREIGN_FADE_ATTACKER, 16, 0, 1, BATTLE_COLOR_WHITE
    // The Mega Evolution symbol flashes over it (tools/sprites/make_mega_symbols.py).
    AddSpriteWithFunc 0, SPRITE_FUNC_OFFSET_AND_ANIMATE, sovereign_mega_symbol_NCGR_lz, sovereign_mega_symbol_NCLR, sovereign_mega_symbol_cell_NCER_lz, sovereign_mega_symbol_anim_NANR_lz, 0, 0, 0, 0
    Delay 10
    PlayPokemonCry 0, -117, 127
    Func_FadeBg FADE_BG_TYPE_BASE, 1, 12, 0, BATTLE_COLOR_BLACK
    Func_SovereignFadeSprites SOVEREIGN_FADE_OTHERS, 10, 0, 1, BATTLE_COLOR_BLACK
    Delay 30
    // The streaks are off screen by now; the sparkles finish.
    UnloadParticleSystem 0
    WaitForAllEmitters
    UnloadParticleSystem 1
    WaitForAnimTasks
    FreeSpriteManager 0
    End
