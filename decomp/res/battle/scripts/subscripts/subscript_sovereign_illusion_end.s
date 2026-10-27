#include "macros/btlcmd.inc"

// Sovereign (item 11): Illusion ended (a damaging hit, or its holder lost the ability). The C side has cleared the
// disguise of MSG_BATTLER_TEMP, which now shows as itself. Behind a substitute only the health box changes: the doll
// gives way to the real sprite later (RestoreSprite).

_000:
    CompareMonDataToValue OPCODE_FLAG_SET, BTLSCR_MSG_BATTLER_TEMP, BATTLEMON_VOLATILE_STATUS, VOLATILE_CONDITION_SUBSTITUTE, _healthbox
    SetMosaic BTLSCR_MSG_BATTLER_TEMP, 8, 1
    Wait 
    ChangeForm BTLSCR_MSG_BATTLER_TEMP
    SetMosaic BTLSCR_MSG_BATTLER_TEMP, 0, 1
    Wait 

_healthbox:
    SovereignRefreshHealthBox BTLSCR_MSG_BATTLER_TEMP
    Wait 
    // {0}'s illusion wore off!
    PrintMessage BattleStrings_Text_SovereignIllusionWoreOff_Ally, TAG_NICKNAME, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    End 
