#include "macros/btlanimcmd.inc"

// Sovereign (item 11): Meteor Beam. Charge turn (L_1): Charge's animation on the user. Attack (L_2): Power Gem's.
L_0:
    JumpIfEffectChanceOdd L_1, L_2
    End

L_1:
    LoadParticleResource 0, charge_spa
    Func_FadeBg FADE_BG_TYPE_BASE, 1, 0, 12, BATTLE_COLOR_BLACK
    WaitForAnimTasks
    CreateEmitter 0, 0, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 0, 1, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 0, 2, EMITTER_CB_SET_POS_TO_ATTACKER
    CreateEmitter 0, 3, EMITTER_CB_SET_POS_TO_ATTACKER
    Delay 15
    PlayLoopedSoundEffectL SEQ_SE_DP_W360_sseq, 12, 5
    Delay 77
    PlaySoundEffectL SEQ_SE_DP_W085C_sseq
    WaitForAllEmitters
    UnloadParticleSystem 0
    Func_FadeBg FADE_BG_TYPE_BASE, 1, 12, 0, BATTLE_COLOR_BLACK
    WaitForAnimTasks
    End

L_2:
    LoadParticleResource 0, power_gem_spa
    Func_FadeBg FADE_BG_TYPE_BASE, 1, 0, 12, BATTLE_COLOR_BLACK
    WaitForAnimTasks
    PlaySoundEffectL SEQ_SE_DP_W408_sseq
    CreateEmitter 0, 2, EMITTER_CB_GENERIC
    SetExtraParams 0, 2, 1, 0, 0, 0
    CreateEmitter 0, 1, EMITTER_CB_GENERIC
    SetExtraParams 0, 2, 6, 1, 0, 0
    Delay 40
    PlayMovingSoundEffectAtkDef SEQ_SE_DP_185_sseq, BATTLE_SOUND_PAN_LEFT, BATTLE_SOUND_PAN_RIGHT, 4, 2
    Delay 20
    PlayLoopedSoundEffectR SEQ_SE_DP_143_sseq, 4, 5
    CreateEmitter 0, 0, EMITTER_CB_SET_POS_TO_DEFENDER
    Func_Shake 1, 0, 1, 10, BATTLE_ANIM_BATTLER_SPRITE_DEFENDER
    WaitForAllEmitters
    UnloadParticleSystem 0
    Func_FadeBg FADE_BG_TYPE_BASE, 1, 12, 0, BATTLE_COLOR_BLACK
    WaitForAnimTasks
    End
