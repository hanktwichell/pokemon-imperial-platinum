#include "macros/btlcmd.inc"

// Sovereign (item 11): Grassy Terrain heals each grounded Pokemon by 1/16 of its max HP at the end of the turn.

_000:
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_MSG_TEMP, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 16
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} was healed by the Grassy Terrain!
    PrintMessage BattleStrings_Text_SovereignHealedByGrassyTerrain_Ally, TAG_NICKNAME, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
