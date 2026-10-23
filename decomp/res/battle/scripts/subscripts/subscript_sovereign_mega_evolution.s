#include "macros/btlcmd.inc"

// Sovereign (E8): Mega Evolution. The C side (BattleControllerPlayer_SovereignMegaEvolve) has already changed the
// battler's form, stats, types and ability; this shows it. MSG_TEMP is 1 for Mega Rayquaza, which needs no stone.

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 1, _wish
    // {0}'s {1} is reacting to the Mega Ring!
    PrintMessage BattleStrings_Text_SovereignMegaReacting_Ally, TAG_NICKNAME_ITEM, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
    GoTo _evolve

_wish:
    // {0} is answering your fervent wish!
    PrintMessage BattleStrings_Text_SovereignMegaFerventWish_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP

_evolve:
    Wait 
    WaitButtonABTime 30
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_MSG_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE, _sprite
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUB_OUT
    Wait 
    RestoreSprite BTLSCR_MSG_TEMP
    Wait 
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SUB_IN
    Wait 

_sprite:
    // The animation (with Battle Scene on) leaves the Pokemon white; the sprite is swapped while it's white, and
    // sovereign_mega_evolved.s fades the new form in.
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SOVEREIGN_MEGA_EVOLUTION
    Wait 
    ChangeForm BTLSCR_MSG_TEMP
    Wait 
    PlayBattleAnimation BTLSCR_MSG_TEMP, BATTLE_ANIMATION_SOVEREIGN_MEGA_EVOLVED
    Wait 
    // {0} has Mega Evolved into Mega {1}!
    PrintMessage BattleStrings_Text_SovereignMegaEvolved_Ally, TAG_NICKNAME_POKE, BTLSCR_MSG_TEMP, BTLSCR_MSG_TEMP
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
