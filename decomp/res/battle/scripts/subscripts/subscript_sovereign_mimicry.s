#include "macros/btlcmd.inc"


    // Sovereign (item 11): Mimicry. The holder (BTLSCR_MSG_BATTLER_TEMP) has taken the terrain's type, in
    // BTLVAR_MSG_TEMP, or its own types back (0xFF there) (BattleSystem_TriggerEffectOnSwitch).
_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_MSG_TEMP, 0xFF, _returned
    // {0}’s {1} made it the {2} type!
    PrintMessage BattleStrings_Text_PokemonsAbilityMadeItType_Ally, TAG_NICKNAME_ABILITY_TYPE, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_TEMP
    GoTo _wait

_returned:
    // {0} returned to its original type!
    PrintMessage BattleStrings_Text_SovereignReturnedToOriginalType_Ally, TAG_NICKNAME, BTLSCR_MSG_BATTLER_TEMP

_wait:
    Wait 
    WaitButtonABTime 30
    End 
