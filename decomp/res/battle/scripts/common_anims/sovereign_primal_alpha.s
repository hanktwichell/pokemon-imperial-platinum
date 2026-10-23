#include "macros/btlanimcmd.inc"

.data

// Sovereign (E8): Primal Reversion of Kyogre (alpha), up to the form change (docs/MegaEvolution.md): as
// sovereign_mega_evolution.s, with the Pokemon pulsing in blues. The subscript then swaps the sprite and plays
// sovereign_primal_alpha_revealed.s.
L_0:
    LoadParticleResource 0, morning_sun_spa
    LoadParticleResource 1, judgment_spa
    LoadParticleResource 2, power_gem_spa
    LoadParticleResource 3, safeguard_spa
    Func_FadeBg FADE_BG_TYPE_BASE, 1, 0, 12, BATTLE_COLOR_BLACK
    // The other battlers dim until sovereign_primal_alpha_revealed.s.
    Func_SovereignFadeSprites SOVEREIGN_FADE_OTHERS, 0, 10, 1, BATTLE_COLOR_BLACK

    // Two streams of light reach the Pokemon, and sparkles gather on it.
    PlaySoundEffectC SEQ_SE_DP_W234_sseq
    CreateEmitter 0, 1, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 0, 2, EMITTER_CB_SET_POS_TO_ATTACKER
    Delay 20
    CreateEmitter 1, 4, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 2, 2, EMITTER_CB_SET_POS_TO_ATTACKER
    Delay 20

    // A sphere of light forms around it, and it pulses in blues as it shakes.
    PlayLoopedSoundEffectL SEQ_SE_DP_W208_sseq, 4, 4
    CreateEmitter 3, 1, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 3, 0, EMITTER_CB_SET_POS_TO_ATTACKER
    Func_FadeBattlerSprite BATTLE_ANIM_ATTACKER, 0, 1, BATTLE_COLOR_LIGHT_BLUE, 12, 0
    Func_Shake 1, 0, 1, 4, BATTLE_ANIM_BATTLER_SPRITE_ATTACKER
    Delay 14
    Func_FadeBattlerSprite BATTLE_ANIM_ATTACKER, 0, 1, BATTLE_COLOR_LIGHT_CYAN, 12, 0
    Func_Shake 1, 0, 1, 4, BATTLE_ANIM_BATTLER_SPRITE_ATTACKER
    Delay 14
    Func_FadeBattlerSprite BATTLE_ANIM_ATTACKER, 0, 1, BATTLE_COLOR_LIGHT_BLUE, 12, 0
    Func_Shake 2, 0, 1, 6, BATTLE_ANIM_BATTLER_SPRITE_ATTACKER
    Delay 14

    // It turns white and the light clears. It stays white while the subscript swaps the sprite, and
    // sovereign_primal_alpha_revealed.s fades the new form in.
    WaitForAnimTasks
    PlaySoundEffectL SEQ_SE_DP_W085C_sseq
    Func_SovereignFadeSprites SOVEREIGN_FADE_ATTACKER, 0, 16, 0, BATTLE_COLOR_WHITE
    UnloadParticleSystem 0
    UnloadParticleSystem 1
    UnloadParticleSystem 2
    UnloadParticleSystem 3
    WaitForAnimTasks
    End
