#include "macros/btlcmd.inc"

// Sovereign (E8): Primal Reversion, on switch-in. BattleSystem_TriggerEffectOnSwitch has already changed the battler's
// form, stats, types and ability; this shows it.

_000:
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE, _sprite
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUB_OUT
    Wait 
    RestoreSprite BTLSCR_MSG_TEMP
    Wait 
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUB_IN
    Wait 

_sprite:
    // The animation (with Battle Scene on) leaves the Pokemon white, after pulsing in blues for Kyogre or reds for
    // Groudon; the sprite is swapped while it's white, and sovereign_mega_evolved.s fades the new form in.
    CompareMonDataToValue OPCODE_EQU, BTLSCR_MSG_TEMP, BATTLEMON_SPECIES, SPECIES_GROUDON, _omega
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SOVEREIGN_PRIMAL_ALPHA
    GoTo _swap

_omega:
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SOVEREIGN_PRIMAL_OMEGA

_swap:
    Wait 
    ChangeForm BTLSCR_MSG_TEMP
    Wait 
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SOVEREIGN_MEGA_EVOLVED
    Wait 
    SovereignRefreshHealthBox BTLSCR_MSG_TEMP
    Wait 
    // {0}'s Primal Reversion! It reverted to its primal form!
    PrintMessage BattleStrings_Text_SovereignPrimalReversion_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE, _end
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUB_OUT
    Wait 
    RefreshSprite BTLSCR_MSG_TEMP
    Wait 
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUB_IN
    Wait 

_end:
    End 
